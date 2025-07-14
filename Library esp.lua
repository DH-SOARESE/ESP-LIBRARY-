--- Services
local RunService = game:GetService('RunService')
local CoreGui = game:GetService('CoreGui')
local Players = game:GetService('Players')
local Workspace = game:GetService('Workspace')

--- Constants and Optimizations
local LOCAL_PLAYER = Players.LocalPlayer
local CAMERA = Workspace.CurrentCamera

local NEWCF = CFrame.new
local NEWVEC2 = Vector2.new
local NEWCOLOR3 = Color3.new

local MIN = math.min
local MAX = math.max
local ATAN2 = math.atan2
local CLAMP = math.clamp
local FLOOR = math.floor
local SIN = math.sin
local COS = math.cos
local RAD = math.rad

local LEN = string.len
local LOWER = string.lower
local SUB = string.sub

local TINSERT = table.insert
local TFIND = table.find

local DRAWING_FONT_PLEX = Drawing.Fonts.Plex -- Assuming 'Plex' is a valid font name in Drawing

--- Global ESP Settings (can be configured externally)
local ESP_SETTINGS = {
    enabled = false,
    teamcheck = true,
    visiblecheck = false,
    outlines = true,
    limitdistance = false,
    shortnames = false,

    maxchar = 4,
    maxdistance = 1200,
    fadefactor = 20,
    arrowradius = 500,
    arrowsize = 20,
    arrowinfo = false,

    -- Teammate settings
    team_chams = { false, Color3.new(1, 1, 1), Color3.new(1, 1, 1), .25, .75, true },
    team_boxes = { false, Color3.new(0, 1, 0), Color3.new(0, 1, 0), 0.1 },
    team_healthbar = { false, Color3.new(0, 1, 0), Color3.new(1, 0, 0) },
    team_kevlarbar = { false, Color3.new(0, 0, 1), Color3.new(0.5, 0.5, 1) },
    team_arrow = { false, Color3.new(0, 1, 0), 0.5 },
    team_names = { false, Color3.new(0, 1, 0) },
    team_weapon = { false, Color3.new(0, 1, 0) },
    team_distance = false,
    team_health = false,

    -- Enemy settings
    enemy_chams = { false, Color3.new(1, 0, 0), Color3.new(1, 0, 0), .25, .75, true },
    enemy_boxes = { false, Color3.new(1, 0, 0), Color3.new(1, 0, 0), 0.1 },
    enemy_healthbar = { false, Color3.new(0, 1, 0), Color3.new(1, 0, 0) },
    enemy_kevlarbar = { false, Color3.new(0, 0, 1), Color3.new(0.5, 0.5, 1) },
    enemy_arrow = { false, Color3.new(1, 0, 0), 0.5 },
    enemy_names = { false, Color3.new(1, 0, 0) },
    enemy_weapon = { false, Color3.new(1, 0, 0) },
    enemy_distance = false,
    enemy_health = false,

    -- Priority settings (e.g., specific players)
    priority_chams = { false, Color3.new(1, 1, 0), Color3.new(1, 1, 0), .25, .75, true },
    priority_boxes = { false, Color3.new(1, 1, 0), Color3.new(1, 1, 0), 0.1 },
    priority_healthbar = { false, Color3.new(0, 1, 0), Color3.new(1, 0, 0) },
    priority_kevlarbar = { false, Color3.new(0, 0, 1), Color3.new(0.5, 0.5, 1) },
    priority_arrow = { false, Color3.new(1, 1, 0), 0.5 },
    priority_names = { false, Color3.new(1, 1, 0) },
    priority_weapon = { false, Color3.new(1, 1, 0) },
    priority_distance = false,
    priority_health = false,

    font = 'Plex',
    textsize = 13,

    priority_players = {} -- Players explicitly marked for priority
}

--- Utility Functions
local function draw(elementType, properties)
    local instance = Drawing.new(elementType)
    if type(properties) == 'table' then
        for prop, value in pairs(properties) do
            instance[prop] = value
        end
    end
    return instance
end

local function createInstance(className, properties)
    local instance = Instance.new(className)
    if type(properties) == 'table' then
        for prop, value in pairs(properties) do
            instance[prop] = value
        end
    end
    return instance
end

local function setProperties(instance, properties)
    for i, v in pairs(properties) do
        instance[i] = v
    end
    return instance
end

local function raycast(origin, direction, blacklist)
    local params = RaycastParams.new()
    params.IgnoreWater = true
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = blacklist

    local ray = Workspace:Raycast(origin, direction, params)
    if ray ~= nil then
        -- Recursively ignore transparent parts to find the actual hit
        if ray.Instance.Transparency >= .250 then
            TINSERT(blacklist, ray.Instance)
            local newRay = raycast(origin, direction, blacklist)
            if newRay ~= nil then
                ray = newRay
            end
        end
    end
    return ray
end

local function getCharacter(plr)
    return plr.Character
end

local function checkAlive(plr)
    if not plr then plr = LOCAL_PLAYER end
    local char = plr.Character
    return (char and char:FindFirstChild('Humanoid') and char:FindFirstChild('Head') and
            char.Humanoid.Health > 0 and char:FindFirstChild('LeftUpperArm') and char.LeftUpperArm.Transparency == 0)
end

local function checkTeam(plr, includeLocalPlayer)
    if not plr then plr = LOCAL_PLAYER end
    return (plr ~= LOCAL_PLAYER and not includeLocalPlayer) or (plr.Team ~= LOCAL_PLAYER.Team)
end

local function checkVisible(instance, origin, params)
    if not params then params = {} end
    local hit = raycast(CAMERA.CFrame.p, (origin.Position - CAMERA.CFrame.p).unit * 500, { unpack(params), CAMERA, LOCAL_PLAYER.Character })
    return (hit and hit.Instance:IsDescendantOf(instance))
end

local function returnOffsets(x, y, minY, z)
    return {
        NEWCF(x, y, z), NEWCF(-x, y, z), NEWCF(x, y, -z), NEWCF(-x, y, -z),
        NEWCF(x, -minY, z), NEWCF(-x, -minY, z), NEWCF(x, -minY, -z), NEWCF(-x, -minY, -z)
    }
end

local function returnTriangleOffsets(triangle)
    local minX = MIN(triangle.PointA.X, triangle.PointB.X, triangle.PointC.X)
    local minY = MIN(triangle.PointA.Y, triangle.PointB.Y, triangle.PointC.Y)
    local maxX = MAX(triangle.PointA.X, triangle.PointB.X, triangle.PointC.X)
    local maxY = MAX(triangle.PointA.Y, triangle.PointB.Y, triangle.PointC.Y)
    return minX, minY, maxX, maxY
end

local function convertNumRange(val, oldMin, oldMax, newMin, newMax)
    return (val - oldMin) * (newMax - newMin) / (oldMax - oldMin) + newMin
end

local function fadeViaDistance(data)
    if not data.limit then return 1 end
    local distance = FLOOR(((data.cframe.p - CAMERA.CFrame.p)).magnitude)
    return 1 - CLAMP(convertNumRange(distance, (data.maxdistance - data.factor), data.maxdistance, 0, 1), 0, 1)
end

local function floorVector(vector)
    return NEWVEC2(FLOOR(vector.X), FLOOR(vector.Y))
end

local function rotateVector2(v2, r)
    local c = COS(r)
    local s = SIN(r)
    return NEWVEC2(c * v2.X - s * v2.Y, s * v2.X + c * v2.Y)
end

--- ESPPlayer Class
local ESPPlayer = {}
ESPPlayer.__index = ESPPlayer

function ESPPlayer.new(player, folder)
    local self = setmetatable({}, ESPPlayer)
    self.Player = player
    self.Drawings = {}
    self.Chams = nil
    self.ChamsFolder = folder -- Parent for the highlight instance

    self:createDrawings()
    return self
end

function ESPPlayer:createDrawings()
    local drawings = {
        box_fill = draw('Square', { Filled = true, Thickness = 1 }),
        box_outline = draw('Square', { Filled = false, Thickness = 1 }),
        box = draw('Square', { Filled = false, Thickness = 1, Color = NEWCOLOR3(1, 1, 1) }),
        arrow_name_outline = draw('Text', { Color = NEWCOLOR3(), Font = DRAWING_FONT_PLEX, Size = ESP_SETTINGS.textsize }),
        arrow_name = draw('Text', { Color = NEWCOLOR3(1, 1, 1), Font = DRAWING_FONT_PLEX, Size = ESP_SETTINGS.textsize }),
        arrow_bar_outline = draw('Square', { Filled = true, Thickness = 1 }),
        arrow_bar_inline = draw('Square', { Filled = true, Thickness = 1, Color = NEWCOLOR3(0.3, 0.3, 0.3) }),
        arrow_bar = draw('Square', { Filled = true, Thickness = 1, Color = NEWCOLOR3(1, 1, 1) }),
        arrow_kevlarbar_outline = draw('Square', { Filled = true, Thickness = 1 }),
        arrow_kevlarbar_inline = draw('Square', { Filled = true, Thickness = 1, Color = NEWCOLOR3(0.3, 0.3, 0.3) }),
        arrow_kevlarbar = draw('Square', { Filled = true, Thickness = 1, Color = NEWCOLOR3(1, 1, 1) }),
        arrow = draw('Triangle', { Filled = true, Thickness = 1 }),
        bar_outline = draw('Square', { Filled = true, Thickness = 1 }),
        bar_inline = draw('Square', { Filled = true, Thickness = 1, Color = NEWCOLOR3(0.3, 0.3, 0.3) }),
        bar = draw('Square', { Filled = true, Thickness = 1, Color = NEWCOLOR3(1, 1, 1) }),
        kevlarbar_outline = draw('Square', { Filled = true, Thickness = 1 }),
        kevlarbar_inline = draw('Square', { Filled = true, Thickness = 1, Color = NEWCOLOR3(0.3, 0.3, 0.3) }),
        kevlarbar = draw('Square', { Filled = true, Thickness = 1, Color = NEWCOLOR3(1, 1, 1) }),
        name_outline = draw('Text', { Color = NEWCOLOR3(), Font = DRAWING_FONT_PLEX, Size = ESP_SETTINGS.textsize }),
        name = draw('Text', { Color = NEWCOLOR3(1, 1, 1), Font = DRAWING_FONT_PLEX, Size = ESP_SETTINGS.textsize }),
        distance_outline = draw('Text', { Color = NEWCOLOR3(), Font = DRAWING_FONT_PLEX, Size = ESP_SETTINGS.textsize }),
        distance = draw('Text', { Color = NEWCOLOR3(1, 1, 1), Font = DRAWING_FONT_PLEX, Size = ESP_SETTINGS.textsize }),
        weapon_outline = draw('Text', { Color = NEWCOLOR3(), Font = DRAWING_FONT_PLEX, Size = ESP_SETTINGS.textsize }),
        weapon = draw('Text', { Color = NEWCOLOR3(1, 1, 1), Font = DRAWING_FONT_PLEX, Size = ESP_SETTINGS.textsize }),
        health = draw('Text', { Color = NEWCOLOR3(1, 1, 1), Font = DRAWING_FONT_PLEX, Size = ESP_SETTINGS.textsize, Center = true })
    }
    self.Drawings = drawings
    self.Chams = createInstance('Highlight', { Name = self.Player.Name, Parent = self.ChamsFolder })
end

function ESPPlayer:disable()
    for _, v in pairs(self.Drawings) do
        v.Visible = false
    end
    if self.Chams then
        self.Chams.Enabled = false
    end
end

function ESPPlayer:remove()
    for _, v in pairs(self.Drawings) do
        v:Remove()
    end
    if self.Chams then
        self.Chams:Destroy()
    end
end

function ESPPlayer:update()
    if self.Player == LOCAL_PLAYER then
        self:disable()
        return
    end

    local character = getCharacter(self.Player)
    if not character or not checkAlive(self.Player) then
        self:disable()
        return
    end

    local isAlive = checkAlive(self.Player)
    local isLocalPlayer = (self.Player == LOCAL_PLAYER)
    local isTeammate = checkTeam(self.Player, false)
    local isPriority = TFIND(ESP_SETTINGS.priority_players, self.Player)

    local flag = 'enemy_'
    if isTeammate then
        flag = 'team_'
    end
    if isPriority then
        flag = 'priority_'
    end

    local canDisplay = true
    if ESP_SETTINGS.limitdistance and (character.PrimaryPart.CFrame.p - CAMERA.CFrame.p).magnitude > ESP_SETTINGS.maxdistance then
        canDisplay = false
    end
    if ESP_SETTINGS.teamcheck and not isTeammate and not isPriority then -- If teamcheck is on, and it's not a teammate or priority, check if it's an enemy
         if isTeammate then canDisplay = true else canDisplay = false end
    end
    if ESP_SETTINGS.visiblecheck and not checkVisible(character, character.Head, ESP_SETTINGS.visiblecheckparams) then
        canDisplay = false
    end
    
    local _, onScreen = CAMERA:WorldToViewportPoint(character.HumanoidRootPart.Position)

    if not isAlive or not canDisplay or not ESP_SETTINGS.enabled then
        self:disable()
        return
    end

    local playerName = LEN(self.Player.Name) > ESP_SETTINGS.maxchar and ESP_SETTINGS.shortnames and SUB(self.Player.Name, 0, ESP_SETTINGS.maxchar) .. '..' or self.Player.Name
    local distance = tostring(FLOOR((character.PrimaryPart.CFrame.p - CAMERA.CFrame.p).Magnitude / 3)) .. 'm'
    local centerMassPos = character.HumanoidRootPart.CFrame
    local transparency = fadeViaDistance({
        limit = ESP_SETTINGS.limitdistance,
        cframe = centerMassPos,
        maxdistance = ESP_SETTINGS.maxdistance,
        factor = ESP_SETTINGS.fadefactor
    })
    local kevlar = 0
    if self.Player:FindFirstChild('Kevlar') then
        kevlar = self.Player.Kevlar.Value
    end
    local health = FLOOR(character.Humanoid.Health)

    -- Chams
    self.Chams.Enabled = ESP_SETTINGS[flag .. 'chams'][1]
    if self.Chams.Enabled then
        self.Chams.Adornee = character
        self.Chams.FillColor = ESP_SETTINGS[flag .. 'chams'][2]
        self.Chams.OutlineColor = ESP_SETTINGS[flag .. 'chams'][3]
        self.Chams.FillTransparency = ESP_SETTINGS[flag .. 'chams'][4]
        self.Chams.OutlineTransparency = ESP_SETTINGS[flag .. 'chams'][5]
        self.Chams.DepthMode = ESP_SETTINGS[flag .. 'chams'][6] and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
    end

    -- Arrows (for off-screen players)
    self.Drawings.arrow.Visible = ESP_SETTINGS[flag .. 'arrow'][1] and not onScreen
    if self.Drawings.arrow.Visible then
        local proj = CAMERA.CFrame:PointToObjectSpace(centerMassPos.p)
        local ang = ATAN2(proj.Z, proj.X)
        local dir = NEWVEC2(COS(ang), SIN(ang))
        local a = (dir * ESP_SETTINGS.arrowradius * .5) + CAMERA.ViewportSize / 2
        local b, c = a - rotateVector2(dir, RAD(30)) * ESP_SETTINGS.arrowsize, a - rotateVector2(dir, (-RAD(30))) * ESP_SETTINGS.arrowsize
        self.Drawings.arrow.PointA = a
        self.Drawings.arrow.PointB = b
        self.Drawings.arrow.PointC = c
        self.Drawings.arrow.Color = ESP_SETTINGS[flag .. 'arrow'][2]
        self.Drawings.arrow.Transparency = ESP_SETTINGS[flag .. 'arrow'][3]

        if ESP_SETTINGS.arrowinfo then
            local smallestX, smallestY, biggestX, biggestY = returnTriangleOffsets(self.Drawings.arrow)
            local arrowBaseY = biggestY + 2
            local arrowBaseX = smallestX + (biggestX - smallestX) / 2

            -- Arrow Healthbar
            self.Drawings.arrow_bar.Visible = ESP_SETTINGS[flag .. 'healthbar'][1]
            self.Drawings.arrow_bar_inline.Visible = self.Drawings.arrow_bar.Visible
            self.Drawings.arrow_bar_outline.Visible = ESP_SETTINGS.outlines and self.Drawings.arrow_bar.Visible
            if self.Drawings.arrow_bar.Visible then
                self.Drawings.arrow_bar.Color = ESP_SETTINGS[flag .. 'healthbar'][3]:Lerp(ESP_SETTINGS[flag .. 'healthbar'][2], health / 100)
                self.Drawings.arrow_bar.Size = floorVector(NEWVEC2(1, ( - health / 100 * ( biggestY - smallestY + 2)) + 3))
                self.Drawings.arrow_bar.Position = floorVector(NEWVEC2(smallestX - 3, smallestY + self.Drawings.arrow_bar_outline.Size.Y))
                self.Drawings.arrow_bar.Transparency = transparency
                self.Drawings.arrow_bar_inline.Size = floorVector(NEWVEC2(1, ( - 1 * ( biggestY - smallestY + 2)) + 3))
                self.Drawings.arrow_bar_inline.Position = self.Drawings.arrow_bar.Position
                self.Drawings.arrow_bar_inline.Transparency = transparency
                self.Drawings.arrow_bar_outline.Size = floorVector(NEWVEC2(1, biggestY - smallestY))
                self.Drawings.arrow_bar_outline.Position = floorVector(NEWVEC2(smallestX - 2, smallestY + 1))
                self.Drawings.arrow_bar_outline.Transparency = transparency
            end

            -- Arrow Kevlarbar
            self.Drawings.arrow_kevlarbar.Visible = ESP_SETTINGS[flag .. 'kevlarbar'][1]
            self.Drawings.arrow_kevlarbar_inline.Visible = self.Drawings.arrow_kevlarbar.Visible
            self.Drawings.arrow_kevlarbar_outline.Visible = ESP_SETTINGS.outlines and self.Drawings.arrow_kevlarbar.Visible
            if self.Drawings.arrow_kevlarbar.Visible then
                self.Drawings.arrow_kevlarbar.Color = ESP_SETTINGS[flag .. 'kevlarbar'][3]:Lerp(ESP_SETTINGS[flag .. 'kevlarbar'][2], kevlar / 100)
                self.Drawings.arrow_kevlarbar.Size = floorVector(NEWVEC2(( kevlar / 100 * ( biggestX - smallestX)), 1))
                self.Drawings.arrow_kevlarbar.Position = floorVector(NEWVEC2(smallestX, biggestY + 2))
                self.Drawings.arrow_kevlarbar.Transparency = transparency
                self.Drawings.arrow_kevlarbar_inline.Size = floorVector(NEWVEC2((biggestX - smallestX), 1))
                self.Drawings.arrow_kevlarbar_inline.Position = self.Drawings.arrow_kevlarbar.Position
                self.Drawings.arrow_kevlarbar_inline.Transparency = transparency
                self.Drawings.arrow_kevlarbar_outline.Size = self.Drawings.arrow_kevlarbar_inline.Size
                self.Drawings.arrow_kevlarbar_outline.Position = floorVector(NEWVEC2(smallestX + 1, biggestY + 3))
                self.Drawings.arrow_kevlarbar_outline.Transparency = transparency
            end

            -- Arrow Name
            self.Drawings.arrow_name.Visible = ESP_SETTINGS[flag .. 'names'][1]
            self.Drawings.arrow_name_outline.Visible = ESP_SETTINGS.outlines and self.Drawings.arrow_name.Visible
            if self.Drawings.arrow_name.Visible then
                self.Drawings.arrow_name.Text = ESP_SETTINGS[flag .. 'distance'] and '['..distance..'] '.. playerName or playerName
                self.Drawings.arrow_name.Color = ESP_SETTINGS[flag .. 'names'][2]
                self.Drawings.arrow_name.Position = floorVector(NEWVEC2(arrowBaseX - (self.Drawings.arrow_name.TextBounds.X / 2), smallestY - self.Drawings.arrow_name.TextBounds.Y - 2))
                self.Drawings.arrow_name.Transparency = transparency
                self.Drawings.arrow_name_outline.Text = self.Drawings.arrow_name.Text
                self.Drawings.arrow_name_outline.Position = self.Drawings.arrow_name.Position + NEWVEC2(1,1)
                self.Drawings.arrow_name_outline.Transparency = transparency
            end
        end
    end

    -- If player is on screen, draw regular ESP
    if onScreen then
        local smallestX, biggestX = math.huge, -math.huge
        local smallestY, biggestY = math.huge, -math.huge

        local headPos = character:FindFirstChild('Head') and character.Head.Position or character.HumanoidRootPart.Position
        local torsoPos = character.HumanoidRootPart.Position
        local leftArmPos = character:FindFirstChild('LeftUpperArm') and character.LeftUpperArm.Position or torsoPos
        local rightArmPos = character:FindFirstChild('RightUpperArm') and character.RightUpperArm.Position or torsoPos
        local leftLegPos = character:FindFirstChild('LeftLowerLeg') and character.LeftLowerLeg.Position or torsoPos
        local rightLegPos = character:FindFirstChild('RightLowerLeg') and character.RightLowerLeg.Position or torsoPos

        -- More accurate bounding box based on extremities
        local yOffset = (headPos - torsoPos).magnitude + (character.Head.Size.Y / 2)
        local xOffset = math.max((torsoPos - leftArmPos).magnitude, (torsoPos - rightArmPos).magnitude)
        local minYOffset = math.max((torsoPos - leftLegPos).magnitude, (torsoPos - rightLegPos).magnitude)

        local offsets = returnOffsets(xOffset, yOffset, minYOffset, character.HumanoidRootPart.Size.Z / 2)

        for _, v in pairs(offsets) do
            local pos = CAMERA:WorldToViewportPoint(centerMassPos * v.p)
            if smallestX > pos.X then smallestX = pos.X end
            if biggestX < pos.X then biggestX = pos.X end
            if smallestY > pos.Y then smallestY = pos.Y end
            if biggestY < pos.Y then biggestY = pos.Y end
        end

        local boxWidth = biggestX - smallestX
        local boxHeight = biggestY - smallestY
        local boxPosition = floorVector(NEWVEC2(smallestX, smallestY))

        -- Box
        self.Drawings.box.Visible = ESP_SETTINGS[flag .. 'boxes'][1]
        self.Drawings.box_fill.Visible = self.Drawings.box.Visible
        self.Drawings.box_outline.Visible = ESP_SETTINGS.outlines and self.Drawings.box.Visible
        if self.Drawings.box.Visible then
            self.Drawings.box.Color = ESP_SETTINGS[flag .. 'boxes'][2]
            self.Drawings.box.Size = floorVector(NEWVEC2(boxWidth, boxHeight))
            self.Drawings.box.Position = boxPosition
            self.Drawings.box.Transparency = transparency
            self.Drawings.box_fill.Size = self.Drawings.box.Size
            self.Drawings.box_fill.Position = self.Drawings.box.Position
            self.Drawings.box_fill.Color = ESP_SETTINGS[flag .. 'boxes'][3]
            self.Drawings.box_fill.Transparency = MIN(ESP_SETTINGS[flag .. 'boxes'][4], transparency)
            self.Drawings.box_outline.Size = self.Drawings.box.Size
            self.Drawings.box_outline.Position = self.Drawings.box.Position + NEWVEC2(1, 1)
            self.Drawings.box_outline.Transparency = transparency
        end

        -- Healthbar
        self.Drawings.bar.Visible = ESP_SETTINGS[flag .. 'healthbar'][1]
        self.Drawings.bar_inline.Visible = self.Drawings.bar.Visible
        self.Drawings.bar_outline.Visible = ESP_SETTINGS.outlines and self.Drawings.bar.Visible
        if self.Drawings.bar.Visible then
            self.Drawings.bar.Color = ESP_SETTINGS[flag .. 'healthbar'][3]:Lerp(ESP_SETTINGS[flag .. 'healthbar'][2], health / 100)
            self.Drawings.bar.Size = floorVector(NEWVEC2(1, ( - health / 100 * (boxHeight + 2)) + 3))
            self.Drawings.bar.Position = floorVector(NEWVEC2(smallestX - 3, smallestY + self.Drawings.bar.Size.Y))
            self.Drawings.bar.Transparency = transparency
            self.Drawings.bar_inline.Size = floorVector(NEWVEC2(1, ( - 1 * (boxHeight + 2)) + 3))
            self.Drawings.bar_inline.Position = self.Drawings.bar.Position
            self.Drawings.bar_inline.Transparency = transparency
            self.Drawings.bar_outline.Size = floorVector(NEWVEC2(1, boxHeight))
            self.Drawings.bar_outline.Position = floorVector(NEWVEC2(smallestX - 2, smallestY + 1))
            self.Drawings.bar_outline.Transparency = transparency
        end

        -- Kevlarbar
        self.Drawings.kevlarbar.Visible = ESP_SETTINGS[flag .. 'kevlarbar'][1]
        self.Drawings.kevlarbar_inline.Visible = self.Drawings.kevlarbar.Visible
        self.Drawings.kevlarbar_outline.Visible = ESP_SETTINGS.outlines and self.Drawings.kevlarbar.Visible
        if self.Drawings.kevlarbar.Visible then
            self.Drawings.kevlarbar.Color = ESP_SETTINGS[flag .. 'kevlarbar'][3]:Lerp(ESP_SETTINGS[flag .. 'kevlarbar'][2], kevlar / 100)
            self.Drawings.kevlarbar.Size = floorVector(NEWVEC2(( kevlar / 100 * boxWidth), 1))
            self.Drawings.kevlarbar.Position = floorVector(NEWVEC2(smallestX, biggestY + 2))
            self.Drawings.kevlarbar.Transparency = transparency
            self.Drawings.kevlarbar_inline.Size = floorVector(NEWVEC2(boxWidth, 1))
            self.Drawings.kevlarbar_inline.Position = self.Drawings.kevlarbar.Position
            self.Drawings.kevlarbar_inline.Transparency = transparency
            self.Drawings.kevlarbar_outline.Size = floorVector(NEWVEC2(boxWidth, 1))
            self.Drawings.kevlarbar_outline.Position = floorVector(NEWVEC2(smallestX + 1, biggestY + 3))
            self.Drawings.kevlarbar_outline.Transparency = transparency
        end

        -- Distance
        local distanceText = '[' .. distance .. ']'
        local nameText = ESP_SETTINGS[flag .. 'distance'] and distanceText .. ' ' .. playerName or playerName

        self.Drawings.distance.Visible = not ESP_SETTINGS[flag .. 'names'][1] and ESP_SETTINGS[flag .. 'distance']
        self.Drawings.distance_outline.Visible = ESP_SETTINGS.outlines and self.Drawings.distance.Visible
        if self.Drawings.distance.Visible then
            self.Drawings.distance.Text = distanceText
            self.Drawings.distance.Color = ESP_SETTINGS[flag .. 'names'][2]
            self.Drawings.distance.Position = floorVector(NEWVEC2(smallestX + (boxWidth / 2) - (self.Drawings.distance.TextBounds.X / 2), smallestY - self.Drawings.distance.TextBounds.Y - 2))
            self.Drawings.distance.Transparency = transparency
            self.Drawings.distance_outline.Text = self.Drawings.distance.Text
            self.Drawings.distance_outline.Position = self.Drawings.distance.Position + NEWVEC2(1,1)
            self.Drawings.distance_outline.Transparency = transparency
        end

        -- Name
        self.Drawings.name.Visible = ESP_SETTINGS[flag .. 'names'][1]
        self.Drawings.name_outline.Visible = ESP_SETTINGS.outlines and self.Drawings.name.Visible
        if self.Drawings.name.Visible then
            self.Drawings.name.Text = nameText
            self.Drawings.name.Color = ESP_SETTINGS[flag .. 'names'][2]
            self.Drawings.name.Position = floorVector(NEWVEC2(smallestX + (boxWidth / 2) - (self.Drawings.name.TextBounds.X / 2), smallestY - self.Drawings.name.TextBounds.Y - 2))
            self.Drawings.name.Transparency = transparency
            self.Drawings.name_outline.Text = self.Drawings.name.Text
            self.Drawings.name_outline.Position = self.Drawings.name.Position + NEWVEC2(1,1)
            self.Drawings.name_outline.Transparency = transparency
        end

        -- Health Text
        self.Drawings.health.Visible = health ~= 100 and health ~= 0 and ESP_SETTINGS[flag .. 'health']
        if self.Drawings.health.Visible then
            self.Drawings.health.Text = tostring(health)
            self.Drawings.health.Outline = ESP_SETTINGS.outlines
            self.Drawings.health.Color = ESP_SETTINGS[flag .. 'healthbar'][3]:Lerp(ESP_SETTINGS[flag .. 'healthbar'][2], health / 100)
            self.Drawings.health.Position = floorVector(NEWVEC2(smallestX - 3, self.Drawings.bar.Position.Y + self.Drawings.bar.Size.Y - self.Drawings.health.TextBounds.Y + 5))
            self.Drawings.health.Transparency = transparency
        end

        -- Weapon
        self.Drawings.weapon.Visible = ESP_SETTINGS[flag .. 'weapon'][1] and character:FindFirstChild('EquippedTool') and character.EquippedTool.Value ~= nil
        self.Drawings.weapon_outline.Visible = ESP_SETTINGS.outlines and self.Drawings.weapon.Visible
        if self.Drawings.weapon.Visible then
            self.Drawings.weapon.Text = LOWER(character.EquippedTool.Value)
            self.Drawings.weapon.Color = ESP_SETTINGS[flag .. 'weapon'][2]
            self.Drawings.weapon.Position = floorVector(NEWVEC2(smallestX + (boxWidth / 2) - (self.Drawings.weapon.TextBounds.X / 2), biggestY + 4))
            self.Drawings.weapon.Transparency = transparency
            self.Drawings.weapon_outline.Text = self.Drawings.weapon.Text
            self.Drawings.weapon_outline.Position = self.Drawings.weapon.Position + NEWVEC2(1,1)
            self.Drawings.weapon_outline.Transparency = transparency
        end
    else -- Player is off-screen, ensure on-screen elements are hidden
        self.Drawings.box.Visible = false
        self.Drawings.box_fill.Visible = false
        self.Drawings.box_outline.Visible = false
        self.Drawings.bar.Visible = false
        self.Drawings.bar_inline.Visible = false
        self.Drawings.bar_outline.Visible = false
        self.Drawings.kevlarbar.Visible = false
        self.Drawings.kevlarbar_inline.Visible = false
        self.Drawings.kevlarbar_outline.Visible = false
        self.Drawings.distance.Visible = false
        self.Drawings.distance_outline.Visible = false
        self.Drawings.name.Visible = false
        self.Drawings.name_outline.Visible = false
        self.Drawings.health.Visible = false
        self.Drawings.weapon.Visible = false
        self.Drawings.weapon_outline.Visible = false
    end
end

--- ESPManager Class
local ESPManager = {}
ESPManager.__index = ESPManager

function ESPManager.new(settings)
    local self = setmetatable({}, ESPManager)
    self.PlayerESPObjects = {}
    self.Connections = {}
    self.ChamsFolder = createInstance('Folder', { Parent = CoreGui, Name = 'ESPHighlights' })
    setProperties(ESP_SETTINGS, settings or {}) -- Apply custom settings if provided

    self:init()
    return self
end

function ESPManager:init()
    -- Add existing players
    for _, player in ipairs(Players:GetPlayers()) do
        self:addPlayer(player)
    end

    -- Connect to PlayerAdded and PlayerRemoving events
    TINSERT(self.Connections, Players.PlayerAdded:Connect(function(player)
        self:addPlayer(player)
    end))
    TINSERT(self.Connections, Players.PlayerRemoving:Connect(function(player)
        self:removePlayer(player)
    end))

    -- Bind update to RenderStep
    TINSERT(self.Connections, RunService.RenderStepped:Connect(function()
        self:update()
    end))
end

function ESPManager:addPlayer(player)
    if player == LOCAL_PLAYER then return end
    if not self.PlayerESPObjects[player.Name] then
        self.PlayerESPObjects[player.Name] = ESPPlayer.new(player, self.ChamsFolder)
    end
end

function ESPManager:removePlayer(player)
    local espPlayer = self.PlayerESPObjects[player.Name]
    if espPlayer then
        espPlayer:remove()
        self.PlayerESPObjects[player.Name] = nil
    end
end

function ESPManager:update()
    if not ESP_SETTINGS.enabled then
        for _, espPlayer in pairs(self.PlayerESPObjects) do
            espPlayer:disable()
        end
        return
    end

    for _, espPlayer in pairs(self.PlayerESPObjects) do
        espPlayer:update()
    end
end

function ESPManager:clearConnections()
    for _, connection in pairs(self.Connections) do
        connection:Disconnect()
    end
    self.Connections = {}
end

function ESPManager:destroy()
    self:clearConnections()
    for _, espPlayer in pairs(self.PlayerESPObjects) do
        espPlayer:remove()
    end
    self.PlayerESPObjects = {}
    if self.ChamsFolder then
        self.ChamsFolder:Destroy()
    end
end

function ESPManager:getSettings()
    return ESP_SETTINGS
end

function ESPManager:setSetting(key, value)
    if ESP_SETTINGS[key] ~= nil then
        ESP_SETTINGS[key] = value
    else
        warn("Attempted to set non-existent ESP setting:", key)
    end
end

return ESPManager
