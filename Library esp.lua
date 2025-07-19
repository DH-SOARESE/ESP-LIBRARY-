--// ESP LIBRARY BY DH-SOARES

local ESP = {}
ESP.__index = ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

-- CONFIGURAÇÕES GERAIS
ESP.Settings = {
    Tracer = true,
    Outline = true,
    Box = true,
    Distance = true,
    Name = true
}

ESP.ActiveESP = {}
ESP.Connection = nil

-- UTILIDADE: DESENHO
local function createDrawing(type, props)
    local obj = Drawing.new(type)
    for i, v in pairs(props) do
        obj[i] = v
    end
    return obj
end

-- DISTÂNCIA EM METROS
local function getDistance(part)
    local playerPos = camera.CFrame.Position
    return math.floor((playerPos - part.Position).Magnitude)
end

-- CRIAR ESP PARA UM OBJETO
function ESP:CreateESP(object)
    if not object:IsA("BasePart") and not object:IsA("Model") then return end

    local root = object:IsA("Model") and object:FindFirstChildWhichIsA("BasePart") or object
    if not root then return end

    local espItems = {
        Tracer = createDrawing("Line", { Thickness = 1.5, Color = Color3.new(1, 1, 1), Transparency = 1 }),
        Outline = createDrawing("Quad", { Color = Color3.new(1, 0, 0), Thickness = 1.2, Filled = false, Transparency = 1 }),
        Box = createDrawing("Square", { Color = Color3.new(0, 1, 0), Thickness = 1, Filled = false, Transparency = 1 }),
        Distance = createDrawing("Text", { Color = Color3.new(1, 1, 1), Size = 13, Center = true, Outline = true }),
        Name = createDrawing("Text", { Color = Color3.new(1, 1, 0), Size = 13, Center = true, Outline = true })
    }

    table.insert(self.ActiveESP, {Object = object, Root = root, Drawings = espItems})
end

-- ATUALIZAR TODOS OS ESPS
function ESP:Start()
    if self.Connection then self.Connection:Disconnect() end

    self.Connection = RunService.RenderStepped:Connect(function()
        for i, espData in pairs(self.ActiveESP) do
            local obj = espData.Object
            local root = espData.Root
            local draw = espData.Drawings

            if not obj or not obj.Parent or not root or not root:IsDescendantOf(workspace) then
                for _, d in pairs(draw) do d.Visible = false end
                continue
            end

            local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)

            if onScreen then
                local size = root.Size
                local corners = {
                    camera:WorldToViewportPoint(root.Position + (root.CFrame.RightVector * size.X/2) + (root.CFrame.UpVector * size.Y/2)),
                    camera:WorldToViewportPoint(root.Position + (-root.CFrame.RightVector * size.X/2) + (root.CFrame.UpVector * size.Y/2)),
                    camera:WorldToViewportPoint(root.Position + (-root.CFrame.RightVector * size.X/2) + (-root.CFrame.UpVector * size.Y/2)),
                    camera:WorldToViewportPoint(root.Position + (root.CFrame.RightVector * size.X/2) + (-root.CFrame.UpVector * size.Y/2)),
                }

                if self.Settings.Outline then
                    draw.Outline.Visible = true
                    draw.Outline.PointA = Vector2.new(corners[1].X, corners[1].Y)
                    draw.Outline.PointB = Vector2.new(corners[2].X, corners[2].Y)
                    draw.Outline.PointC = Vector2.new(corners[3].X, corners[3].Y)
                    draw.Outline.PointD = Vector2.new(corners[4].X, corners[4].Y)
                else
                    draw.Outline.Visible = false
                end

                if self.Settings.Box then
                    draw.Box.Visible = true
                    draw.Box.Position = Vector2.new(screenPos.X - 25, screenPos.Y - 35)
                    draw.Box.Size = Vector2.new(50, 70)
                else
                    draw.Box.Visible = false
                end

                if self.Settings.Tracer then
                    draw.Tracer.Visible = true
                    draw.Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    draw.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                else
                    draw.Tracer.Visible = false
                end

                if self.Settings.Distance then
                    draw.Distance.Visible = true
                    draw.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + 40)
                    draw.Distance.Text = tostring(getDistance(root)) .. "m"
                else
                    draw.Distance.Visible = false
                end

                if self.Settings.Name then
                    draw.Name.Visible = true
                    draw.Name.Position = Vector2.new(screenPos.X, screenPos.Y - 40)
                    draw.Name.Text = obj.Name
                else
                    draw.Name.Visible = false
                end
            else
                for _, d in pairs(draw) do d.Visible = false end
            end
        end
    end)
end

-- DELETAR TODOS ESP
function ESP:Clear()
    for _, espData in pairs(self.ActiveESP) do
        for _, drawing in pairs(espData.Drawings) do
            drawing:Remove()
        end
    end
    table.clear(self.ActiveESP)
end

-- CONFIGURAR VISIBILIDADE
function ESP:SetOption(option, state)
    if self.Settings[option] ~= nil then
        self.Settings[option] = state
    end
end

return ESP
