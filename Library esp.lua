-- ESP Library for Roblox
-- Features: ESP Line, ESP Box, ESP Name, ESP Distance, ESP Contour
-- Compatible with Delta and similar executors
-- Host on GitHub and execute via loadstring

local ESP = {}
ESP.__index = ESP

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ESP Settings
ESP.Settings = {
    Enabled = true,
    Line = true,
    Box = true,
    Name = true,
    Distance = true,
    Contour = true,
    LineColor = Color3.fromRGB(255, 0, 0),
    BoxColor = Color3.fromRGB(0, 255, 0),
    NameColor = Color3.fromRGB(255, 255, 255),
    DistanceColor = Color3.fromRGB(255, 255, 255),
    ContourColor = Color3.fromRGB(255, 255, 0),
    LineThickness = 1,
    ContourThickness = 2,
    TextSize = 14,
    MaxDistance = 1000, -- Max distance to render ESP
    TeamCheck = false -- Set to true to ignore teammates
}

-- Cache for ESP objects
ESP.Objects = {}

-- Create new ESP instance
function ESP.new(target)
    local self = setmetatable({}, ESP)
    self.Target = target
    self.Drawings = {}
    self:Setup()
    return self
end

-- Setup ESP drawings
function ESP:Setup()
    local target = self.Target
    if not target or not target:IsA("Model") or not target:FindFirstChild("HumanoidRootPart") then
        return
    end

    -- ESP Line
    if ESP.Settings.Line then
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = ESP.Settings.LineColor
        line.Thickness = ESP.Settings.LineThickness
        line.Transparency = 1
        self.Drawings.Line = line
    end

    -- ESP Box
    if ESP.Settings.Box then
        local box = Drawing.new("Square")
        box.Visible = false
        box.Color = ESP.Settings.BoxColor
        box.Thickness = 1
        box.Filled = false
        box.Transparency = 1
        self.Drawings.Box = box
    end

    -- ESP Name
    if ESP.Settings.Name then
        local name = Drawing.new("Text")
        name.Visible = false
        name.Color = ESP.Settings.NameColor
        name.Size = ESP.Settings.TextSize
        name.Center = true
        name.Outline = true
        name.Text = target.Name
        self.Drawings.Name = name
    end

    -- ESP Distance
    if ESP.Settings.Distance then
        local distance = Drawing.new("Text")
        distance.Visible = false
        distance.Color = ESP.Settings.DistanceColor
        distance.Size = ESP.Settings.TextSize
        distance.Center = true
        distance.Outline = true
        self.Drawings.Distance = distance
    end

    -- ESP Contour
    if ESP.Settings.Contour then
        local contour = Drawing.new("Square")
        contour.Visible = false
        contour.Color = ESP.Settings.ContourColor
        contour.Thickness = ESP.Settings.ContourThickness
        contour.Filled = false
        contour.Transparency = 1
        self.Drawings.Contour = contour
    end
end

-- Update ESP drawings
function ESP:Update()
    if not ESP.Settings.Enabled or not self.Target or not self.Target.Parent or not self.Target:FindFirstChild("HumanoidRootPart") then
        self:Destroy()
        return
    end

    local humanoidRootPart = self.Target:FindFirstChild("HumanoidRootPart")
    local humanoid = self.Target:FindFirstChildOfClass("Humanoid")
    if not humanoidRootPart or (humanoid and humanoid.Health <= 0) then
        self:Destroy()
        return
    end

    -- Team check
    if ESP.Settings.TeamCheck and self.Target:IsA("Model") and self.Target:FindFirstChild("Humanoid") then
        local player = Players:GetPlayerFromCharacter(self.Target)
        if player and player.Team == LocalPlayer.Team then
            self:Destroy()
            return
        end
    end

    -- Get 3D position
    local rootPos, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
    local distance = (Camera.CFrame.Position - humanoidRootPart.Position).Magnitude

    if onScreen and distance <= ESP.Settings.MaxDistance then
        -- ESP Line
        if self.Drawings.Line then
            self.Drawings.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            self.Drawings.Line.To = Vector2.new(rootPos.X, rootPos.Y)
            self.Drawings.Line.Visible = true
        end

        -- ESP Box
        if self.Drawings.Box then
            local head = self.Target:FindFirstChild("Head")
            local headPos = head and Camera:WorldToViewportPoint(head.Position) or rootPos
            local boxSize = Vector2.new(2000 / rootPos.Z, 3000 / rootPos.Z) -- Adjust size based on distance
            self.Drawings.Box.Size = boxSize
            self.Drawings.Box.Position = Vector2.new(rootPos.X - boxSize.X / 2, rootPos.Y - boxSize.Y / 2)
            self.Drawings.Box.Visible = true
        end

        -- ESP Name
        if self.Drawings.Name then
            self.Drawings.Name.Position = Vector2.new(rootPos.X, rootPos.Y - 30)
            self.Drawings.Name.Visible = true
        end

        -- ESP Distance
        if self.Drawings.Distance then
            self.Drawings.Distance.Text = math.floor(distance) .. " studs"
            self.Drawings.Distance.Position = Vector2.new(rootPos.X, rootPos.Y + 10)
            self.Drawings.Distance.Visible = true
        end

        -- ESP Contour
        if self.Drawings.Contour then
            local contourSize = Vector2.new(2200 / rootPos.Z, 3200 / rootPos.Z) -- Slightly larger than box
            self.Drawings.Contour.Size = contourSize
            self.Drawings.Contour.Position = Vector2.new(rootPos.X - contourSize.X / 2, rootPos.Y - contourSize.Y / 2)
            self.Drawings.Contour.Visible = true
        end
    else
        for _, drawing in pairs(self.Drawings) do
            drawing.Visible = false
        end
    end
end

-- Destroy ESP instance
function ESP:Destroy()
    for _, drawing in pairs(self.Drawings) do
        drawing:Remove()
    end
    self.Drawings = {}
    ESP.Objects[self.Target] = nil
end

-- Initialize ESP for all objects in Workspace
function ESP:Init()
    -- Clear existing ESPs
    for _, esp in pairs(ESP.Objects) do
        esp:Destroy()
    end
    ESP.Objects = {}

    -- Scan Workspace for valid objects
    for _, object in pairs(Workspace:GetDescendants()) do
        if object:IsA("Model") and object:FindFirstChild("HumanoidRootPart") and object ~= LocalPlayer.Character then
            ESP.Objects[object] = ESP.new(object)
        end
    end

    -- Handle new objects
    Workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Model") and descendant:FindFirstChild("HumanoidRootPart") and descendant ~= LocalPlayer.Character then
            ESP.Objects[descendant] = ESP.new(descendant)
        end
    end)

    -- Handle removed objects
    Workspace.DescendantRemoving:Connect(function(descendant)
        if ESP.Objects[descendant] then
            ESP.Objects[descendant]:Destroy()
        end
    end)
end

-- Update loop
RunService.RenderStepped:Connect(function()
    if not ESP.Settings.Enabled then return end
    for _, esp in pairs(ESP.Objects) do
        esp:Update()
    end
end)

-- Toggle ESP
function ESP:Toggle(state)
    ESP.Settings.Enabled = state
    for _, esp in pairs(ESP.Objects) do
        for _, drawing in pairs(esp.Drawings) do
            drawing.Visible = false
        end
    end
end

-- Configure ESP settings
function ESP:Configure(settings)
    for key, value in pairs(settings) do
        ESP.Settings[key] = value
    end
    -- Reinitialize to apply new settings
    ESP:Init()
end

-- Example usage
ESP:Init()

-- Return the ESP library
return ESP
