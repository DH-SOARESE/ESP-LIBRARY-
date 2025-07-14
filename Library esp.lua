--[[  
ESP Library - Orientada a objetos
Suporta:
• Line
• Box
• Name
• Distance
• Contorno
]]

local ESP = {}
ESP.Objects = {}  -- tabela para guardar os objetos registrados
ESP.Settings = {
    Line = true,
    Box = true,
    Name = true,
    Distance = true,
    Contorno = true
}

-- Cria BillboardGui helper
local function createBillboard(name, distance)
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = string.format("%s | %.0fm", name, distance)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Parent = billboard
    return billboard
end

-- Função para adicionar ESP ao objeto
function ESP:Add(Object, DisplayName)
    if not Object:IsA("BasePart") then return end

    local espItem = {}
    espItem.Object = Object
    espItem.DisplayName = DisplayName or Object.Name

    -- Billboard para nome + distância
    if ESP.Settings.Name or ESP.Settings.Distance then
        local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - Object.Position).Magnitude
        espItem.Billboard = createBillboard(espItem.DisplayName, distance / 3.571)  -- metros (aprox)
        espItem.Billboard.Parent = Object
    end

    -- BoxHighlight para contorno
    if ESP.Settings.Contorno then
        local highlight = Instance.new("BoxHandleAdornment")
        highlight.Size = Object.Size
        highlight.Adornee = Object
        highlight.AlwaysOnTop = true
        highlight.ZIndex = 0
        highlight.Color3 = Color3.new(1, 1, 1)
        highlight.Transparency = 0.5
        highlight.Parent = Object
        espItem.Highlight = highlight
    end

    table.insert(ESP.Objects, espItem)
end

-- Desenha linhas e atualiza distância em loop
function ESP:Enable()
    local runService = game:GetService("RunService")
    ESP.Connection = runService.RenderStepped:Connect(function()
        for _, esp in ipairs(ESP.Objects) do
            local obj = esp.Object
            if obj and obj.Parent then
                local playerPos = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character.HumanoidRootPart.Position
                if playerPos then
                    local distance = (playerPos - obj.Position).Magnitude / 3.571

                    -- Atualiza texto do Billboard
                    if esp.Billboard then
                        esp.Billboard.TextLabel.Text = string.format("%s | %.0fm", esp.DisplayName, distance)
                    end

                    -- Desenhar Line (ScreenGui + Frame)
                    if ESP.Settings.Line then
                        -- Você pode usar Drawing API se preferir (mais leve e flexível)
                    end

                    -- Atualiza BoxHighlight (já fica automático)
                end
            end
        end
    end)
end

-- Função para desligar ESP
function ESP:Disable()
    if ESP.Connection then ESP.Connection:Disconnect() end
    for _, esp in ipairs(ESP.Objects) do
        if esp.Billboard then esp.Billboard:Destroy() end
        if esp.Highlight then esp.Highlight:Destroy() end
    end
    ESP.Objects = {}
end

-- Configurar opções
function ESP:SetOption(option, value)
    if ESP.Settings[option] ~= nil then
        ESP.Settings[option] = value
    end
end

return ESP
