--[[
ESP Library by @seu-usuario
Suporte: Tracer, Outline, Box Outline, Distance (metros), Nome
Uso:
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/seu-usuario/seu-repo/main/esp.lua"))()
ESP:Add(workspace.Part1)
]]

local ESP = {}
ESP.__index = ESP

ESP.Objects = {}

ESP.Settings = {
    Tracer = true,
    BoxOutline = true,
    Outline = true,
    Distance = true,
    Name = true,
    Color = Color3.fromRGB(255, 0, 0),
    Font = Drawing.Fonts.UI,
    UpdateRate = 1/60
}

-- Criação de desenhos
function ESP:CreateDrawing(obj)
    local draw = {
        Tracer = Drawing.new("Line"),
        Box = Drawing.new("Square"),
        Outline = Drawing.new("Square"),
        Distance = Drawing.new("Text"),
        Name = Drawing.new("Text"),
        Target = obj
    }

    for _, d in pairs(draw) do
        if typeof(d) == "Instance" then continue end
        d.Visible = false
        d.Color = self.Settings.Color
        if d.ClassName == "Text" then
            d.Size = 13
            d.Center = true
            d.Outline = true
            d.OutlineColor = Color3.new(0, 0, 0)
            d.Font = self.Settings.Font
        elseif d.ClassName == "Line" then
            d.Thickness = 1
        elseif d.ClassName == "Square" then
            d.Thickness = 1
            d.Filled = false
        end
    end

    table.insert(self.Objects, draw)
end

-- Atualização dos ESPs
function ESP:Update()
    local cam = workspace.CurrentCamera
    for _, draw in ipairs(self.Objects) do
        local obj = draw.Target
        if not obj or not obj:IsDescendantOf(workspace) then
            for _, d in pairs(draw) do
                if typeof(d) == "Instance" then continue end
                d.Visible = false
                d:Remove()
            end
            continue
        end

        local pos, onScreen = cam:WorldToViewportPoint(obj.Position)
        if onScreen then
            local distance = (cam.CFrame.Position - obj.Position).Magnitude

            if self.Settings.Tracer then
                draw.Tracer.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                draw.Tracer.To = Vector2.new(pos.X, pos.Y)
                draw.Tracer.Visible = true
            end

            if self.Settings.BoxOutline then
                local size = 30 / distance * 3
                draw.Box.Size = Vector2.new(size, size)
                draw.Box.Position = Vector2.new(pos.X - size / 2, pos.Y - size / 2)
                draw.Box.Visible = true

                draw.Outline.Size = Vector2.new(size + 2, size + 2)
                draw.Outline.Position = Vector2.new(pos.X - size / 2 - 1, pos.Y - size / 2 - 1)
                draw.Outline.Visible = true
                draw.Outline.Color = Color3.new(0,0,0)
            end

            if self.Settings.Distance then
                draw.Distance.Text = string.format("%.1f m", distance)
                draw.Distance.Position = Vector2.new(pos.X, pos.Y + 20)
                draw.Distance.Visible = true
            end

            if self.Settings.Name then
                draw.Name.Text = obj.Name
                draw.Name.Position = Vector2.new(pos.X, pos.Y - 20)
                draw.Name.Visible = true
            end
        else
            for _, d in pairs(draw) do
                if typeof(d) == "Instance" then continue end
                d.Visible = false
            end
        end
    end
end

-- Loop contínuo
task.spawn(function()
    while task.wait(ESP.Settings.UpdateRate) do
        ESP:Update()
    end
end)

-- Adiciona um objeto à ESP
function ESP:Add(object)
    if typeof(object) == "Instance" and object:IsA("BasePart") then
        self:CreateDrawing(object)
    end
end

-- Limpa tudo
function ESP:Clear()
    for _, draw in ipairs(self.Objects) do
        for _, d in pairs(draw) do
            if typeof(d) == "Instance" then continue end
            d:Remove()
        end
    end
    self.Objects = {}
end

return ESP
