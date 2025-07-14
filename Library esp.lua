-- ESP Library by dhsoares01
-- Orientado por referência de endereço ex: Workspace.room.door["1"]

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ESP = {}
ESP.Objects = {}
ESP.Enabled = true

-- Configurações padrão
ESP.Settings = {
    ShowLine = true,
    ShowBox = true,
    ShowName = true,
    ShowDistance = true,
    ShowOutline = true,
    LineColor = Color3.fromRGB(255, 0, 0),
    BoxColor = Color3.fromRGB(0, 255, 0),
    TextColor = Color3.fromRGB(255, 255, 255),
    OutlineColor = Color3.fromRGB(255, 255, 0),
    TextSize = 14
}

-- Função utilitária para desenhar UI
local function createDrawing(type, props)
    local obj = Drawing.new(type)
    for i, v in pairs(props) do
        obj[i] = v
    end
    return obj
end

-- Adiciona um objeto
function ESP:Add(path: Instance, nameOverride)
    if not path or not path:IsA("BasePart") and not path:IsA("Model") then return end

    table.insert(self.Objects, {
        Target = path,
        Name = nameOverride or path.Name,
        Highlight = ESP.Settings.ShowOutline and Instance.new("Highlight", path),
        Line = createDrawing("Line", {Thickness = 1.5, Color = self.Settings.LineColor, Visible = false}),
        Box = createDrawing("Square", {Thickness = 1, Color = self.Settings.BoxColor, Visible = false, Filled = false}),
        NameLabel = createDrawing("Text", {Size = self.Settings.TextSize, Color = self.Settings.TextColor, Center = true, Visible = false, Outline = true}),
        DistanceLabel = createDrawing("Text", {Size = self.Settings.TextSize, Color = self.Settings.TextColor, Center = true, Visible = false, Outline = true}),
    })
end

-- Atualiza a renderização
RunService.RenderStepped:Connect(function()
    if not ESP.Enabled then return end

    for i, obj in pairs(ESP.Objects) do
        local target = obj.Target
        if not target or not target.Parent then continue end

        local part = target:IsA("Model") and target:FindFirstChildWhichIsA("BasePart") or target
        if not part then continue end

        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then
            obj.Line.Visible = false
            obj.Box.Visible = false
            obj.NameLabel.Visible = false
            obj.DistanceLabel.Visible = false
            continue
        end

        -- Line
        if ESP.Settings.ShowLine then
            obj.Line.Visible = true
            obj.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            obj.Line.To = Vector2.new(pos.X, pos.Y)
            obj.Line.Color = ESP.Settings.LineColor
        else
            obj.Line.Visible = false
        end

        -- Box
        if ESP.Settings.ShowBox then
            local size = (Camera:WorldToViewportPoint(part.Position + part.Size / 2) - Camera:WorldToViewportPoint(part.Position - part.Size / 2)).Magnitude
            obj.Box.Visible = true
            obj.Box.Size = Vector2.new(size, size)
            obj.Box.Position = Vector2.new(pos.X - size/2, pos.Y - size/2)
            obj.Box.Color = ESP.Settings.BoxColor
        else
            obj.Box.Visible = false
        end

        -- Text (Name)
        if ESP.Settings.ShowName then
            obj.NameLabel.Visible = true
            obj.NameLabel.Position = Vector2.new(pos.X, pos.Y - 20)
            obj.NameLabel.Text = obj.Name
            obj.NameLabel.Color = ESP.Settings.TextColor
        else
            obj.NameLabel.Visible = false
        end

        -- Distance
        if ESP.Settings.ShowDistance then
            local dist = math.floor((Camera.CFrame.Position - part.Position).Magnitude)
            obj.DistanceLabel.Visible = true
            obj.DistanceLabel.Position = Vector2.new(pos.X, pos.Y + 15)
            obj.DistanceLabel.Text = tostring(dist) .. "m"
            obj.DistanceLabel.Color = ESP.Settings.TextColor
        else
            obj.DistanceLabel.Visible = false
        end

        -- Outline
        if ESP.Settings.ShowOutline and obj.Highlight then
            obj.Highlight.Enabled = true
            obj.Highlight.FillTransparency = 1
            obj.Highlight.OutlineTransparency = 0
            obj.Highlight.OutlineColor = ESP.Settings.OutlineColor
            obj.Highlight.Adornee = target
        elseif obj.Highlight then
            obj.Highlight.Enabled = false
        end
    end
end)

-- Ativa ou desativa
function ESP:SetEnabled(bool)
    self.Enabled = bool
end

return ESP