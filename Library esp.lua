-- ESP Library by [Seu Nome]
-- Versão: 1.0.0
-- Hospedado em: https://github.com/[seu-usuario]/[seu-repositorio]
-- Licença: MIT

local EspLibrary = {}
EspLibrary.__index = EspLibrary

-- Serviços e dependências (adaptar conforme o executor)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Função para criar um novo objeto ESP
function EspLibrary.new(entity, config)
    local self = setmetatable({}, EspLibrary)
    
    -- Configurações padrão
    self.entity = entity -- Entidade (jogador, modelo, etc.)
    self.name = config.name or "Unknown" -- Nome personalizado
    self.tracerEnabled = config.tracer or false -- Linha do centro da tela até a entidade
    self.outlineEnabled = config.outline or false -- Contorno visível
    self.box3DEnabled = config.box3d or false -- Caixa 3D preenchendo o contorno
    self.distanceEnabled = config.distance or false -- Distância em metros
    self.color = config.color or Color3.fromRGB(255, 255, 255) -- Cor padrão
    self.visible = true -- Controla visibilidade geral do ESP
    
    -- Inicialização dos elementos de desenho
    self:Initialize()
    
    return self
end

-- Inicializa os elementos de desenho (Drawing API)
function EspLibrary:Initialize()
    -- Tracer (linha)
    if self.tracerEnabled then
        self.tracer = Drawing.new("Line")
        self.tracer.Thickness = 1
        self.tracer.Color = self.color
        self.tracer.Visible = false
    end
    
    -- Outline (contorno 2D)
    if self.outlineEnabled then
        self.outline = Drawing.new("Square")
        self.outline.Thickness = 1
        self.outline.Color = self.color
        self.outline.Filled = false
        self.outline.Visible = false
    end
    
    -- Box 3D (caixa 3D preenchida)
    if self.box3DEnabled then
        self.box3d = {} -- Array para as linhas da caixa 3D
        for i = 1, 12 do -- 12 linhas para formar um cubo
            self.box3d[i] = Drawing.new("Line")
            self.box3d[i].Thickness = 1
            self.box3d[i].Color = self.color
            self.box3d[i].Visible = false
        end
    end
    
    -- Distância e Nome (texto)
    if self.distanceEnabled or self.name then
        self.text = Drawing.new("Text")
        self.text.Size = 16
        self.text.Color = self.color
        self.text.Visible = false
        self.text.Center = true
        self.text.Outline = true
    end
    
    -- Conectar ao loop de atualização
    self.connection = RunService.RenderStepped:Connect(function()
        self:Update()
    end)
end

-- Atualiza a posição e visibilidade dos elementos
function EspLibrary:Update()
    if not self.entity or not self.entity:IsDescendantOf(workspace) or not self.visible then
        self:SetVisible(false)
        return
    end

    local rootPart = self.entity:FindFirstChild("HumanoidRootPart") or self.entity.PrimaryPart
    if not rootPart then
        self:SetVisible(false)
        return
    end

    local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then
        self:SetVisible(false)
        return
    end

    self:SetVisible(true)

    -- Atualizar Tracer
    if self.tracerEnabled and self.tracer then
        self.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        self.tracer.To = Vector2.new(rootPos.X, rootPos.Y)
    end

    -- Atualizar Outline (caixa 2D)
    if self.outlineEnabled and self.outline then
        local headPos = Camera:WorldToViewportPoint((rootPart.Position + Vector3.new(0, 3, 0)))
        local feetPos = Camera:WorldToViewportPoint((rootPart.Position - Vector3.new(0, 3, 0)))
        local size = Vector2.new(math.abs(headPos.X - feetPos.X) * 2, math.abs(headPos.Y - feetPos.Y))
        self.outline.Size = size
        self.outline.Position = Vector2.new(rootPos.X - size.X / 2, rootPos.Y - size.Y / 2)
    end

    -- Atualizar Box 3D
    if self.box3DEnabled and self.box3d then
        local corners = {
            rootPart.Position + Vector3.new(-1.5, 3, -1.5),
            rootPart.Position + Vector3.new(1.5, 3, -1.5),
            rootPart.Position + Vector3.new(1.5, 3, 1.5),
            rootPart.Position + Vector3.new(-1.5, 3, 1.5),
            rootPart.Position + Vector3.new(-1.5, -3, -1.5),
            rootPart.Position + Vector3.new(1.5, -3, -1.5),
            rootPart.Position + Vector3.new(1.5, -3, 1.5),
            rootPart.Position + Vector3.new(-1.5, -3, 1.5),
        }
        local lines = {
            {1, 2}, {2, 3}, {3, 4}, {4, 1}, -- Topo
            {5, 6}, {6, 7}, {7, 8}, {8, 5}, -- Base
            {1, 5}, {2, 6}, {3, 7}, {4, 8}  -- Laterais
        }
        for i, line in ipairs(lines) do
            local p1 = Camera:WorldToViewportPoint(corners[line[1]])
            local p2 = Camera:WorldToViewportPoint(corners[line[2]])
            self.box3d[i].From = Vector2.new(p1.X, p1.Y)
            self.box3d[i].To = Vector2.new(p2.X, p2.Y)
        end
    end

    -- Atualizar Texto (Nome e Distância)
    if (self.distanceEnabled or self.name) and self.text then
        local text = self.name
        if self.distanceEnabled then
            local distance = (LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and (rootPart.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude / 3.571) or 0
            text = text .. string.format("\n%.1f m", distance)
        end
        self.text.Text = text
        self.text.Position = Vector2.new(rootPos.X, rootPos.Y - 30)
    end
end

-- Controla a visibilidade dos elementos
function EspLibrary:SetVisible(visible)
    if self.tracer then self.tracer.Visible = visible end
    if self.outline then self.outline.Visible = visible end
    if self.box3d then
        for _, line in ipairs(self.box3d) do
            line.Visible = visible
        end
    end
    if self.text then self.text.Visible = visible end
end

-- Destrói o objeto ESP e limpa recursos
function EspLibrary:Destroy()
    if self.connection then
        self.connection:Disconnect()
    end
    if self.tracer then
        self.tracer:Remove()
    end
    if self.outline then
        self.outline:Remove()
    end
    if self.box3d then
        for _, line in ipairs(self.box3d) do
            line:Remove()
        end
    end
    if self.text then
        self.text:Remove()
    end
    self.entity = nil
end

-- Exemplo de uso global
local EspManager = {
    esps = {}
}

-- Adiciona um novo ESP para uma entidade
function EspManager:Add(entity, config)
    if not self.esps[entity] then
        self.esps[entity] = EspLibrary.new(entity, config)
    end
    return self.esps[entity]
end

-- Remove um ESP
function EspManager:Remove(entity)
    if self.esps[entity] then
        self.esps[entity]:Destroy()
        self.esps[entity] = nil
    end
end

-- Limpa todos os ESPs
function EspManager:Clear()
    for entity, esp in pairs(self.esps) do
        esp:Destroy()
        self.esps[entity] = nil
    end
end

return EspManager