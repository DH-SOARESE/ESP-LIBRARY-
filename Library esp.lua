-- ESP Library by dhsoares01 - controle individual (Line, Name, Distance, Outline)
-- Suporte a Model/BasePart com ativação separada de cada recurso visual

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESP = {}
ESP.Objects = {}
ESP.Enabled = true -- controla a atualização em si

-- Configurações de cada ESP separadamente
ESP.Settings = {
	Line = {
		Enabled = true,
		Color = Color3.fromRGB(255, 0, 0)
	},
	Name = {
		Enabled = true,
		Color = Color3.fromRGB(255, 255, 255),
		Size = 14
	},
	Distance = {
		Enabled = true,
		Color = Color3.fromRGB(255, 255, 255),
		Size = 14
	},
	Outline = {
		Enabled = true,
		Color = Color3.fromRGB(255, 255, 0)
	},
	PositionMode = "Center" -- Top, Center, Bottom, LeftCenter, RightCenter
}

-- Função auxiliar para criar Drawings
local function createDrawing(type, props)
	local obj = Drawing.new(type)
	for i, v in pairs(props) do
		obj[i] = v
	end
	return obj
end

-- Calcula o centro de um modelo
local function getModelCenter(model)
	local total = Vector3.zero
	local count = 0
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			total += part.Position
			count += 1
		end
	end
	return (count > 0 and total / count) or Vector3.zero
end

-- Offset para posições
local function getOffset(part)
	local y, x = part.Size.Y / 2, part.Size.X / 2
	local mode = ESP.Settings.PositionMode

	if mode == "Top" then
		return Vector3.new(0, y, 0)
	elseif mode == "Bottom" then
		return Vector3.new(0, -y, 0)
	elseif mode == "LeftCenter" then
		return Vector3.new(-x, 0, 0)
	elseif mode == "RightCenter" then
		return Vector3.new(x, 0, 0)
	else
		return Vector3.zero
	end
end

-- Adiciona ESP a um alvo
function ESP:Add(target: Instance, nameOverride)
	if not target or (not target:IsA("BasePart") and not target:IsA("Model")) then return end

	local function createHighlight()
		local h = Instance.new("Highlight")
		h.FillTransparency = 1
		h.OutlineTransparency = 0
		h.OutlineColor = ESP.Settings.Outline.Color
		h.Adornee = target
		h.Parent = target
		return h
	end

	local highlight = ESP.Settings.Outline.Enabled and createHighlight() or nil

	table.insert(self.Objects, {
		Target = target,
		Name = nameOverride or target.Name,
		Highlight = highlight,
		Line = createDrawing("Line", {Thickness = 1.5, Visible = false}),
		NameLabel = createDrawing("Text", {Center = true, Outline = true, Visible = false}),
		DistanceLabel = createDrawing("Text", {Center = true, Outline = true, Visible = false})
	})
end

-- Loop de renderização
RunService.RenderStepped:Connect(function()
	if not ESP.Enabled or not Camera then return end

	for i = #ESP.Objects, 1, -1 do
		local obj = ESP.Objects[i]
		local target = obj.Target

		if not target or not target.Parent then
			if obj.Highlight then pcall(function() obj.Highlight:Destroy() end) end
			for _, key in ipairs({"Line", "NameLabel", "DistanceLabel"}) do
				if obj[key] then pcall(function() obj[key]:Destroy() end) end
			end
			table.remove(ESP.Objects, i)
			continue
		end

		-- Recria Highlight se sumiu
		if ESP.Settings.Outline.Enabled and (not obj.Highlight or not obj.Highlight.Parent) then
			obj.Highlight = Instance.new("Highlight")
			obj.Highlight.FillTransparency = 1
			obj.Highlight.OutlineTransparency = 0
			obj.Highlight.OutlineColor = ESP.Settings.Outline.Color
			obj.Highlight.Adornee = target
			obj.Highlight.Parent = target
		end

		local position = target:IsA("Model") and getModelCenter(target) or (target:IsA("BasePart") and target.Position + getOffset(target))
		if not position then continue end

		local screenPos, onScreen = Camera:WorldToViewportPoint(position)
		local screen2D = Vector2.new(screenPos.X, screenPos.Y)

		-- Line
		if ESP.Settings.Line.Enabled then
			obj.Line.Visible = onScreen
			obj.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
			obj.Line.To = screen2D
			obj.Line.Color = ESP.Settings.Line.Color
		else
			obj.Line.Visible = false
		end

		-- Name
		if ESP.Settings.Name.Enabled then
			obj.NameLabel.Visible = onScreen
			obj.NameLabel.Position = screen2D - Vector2.new(0, 20)
			obj.NameLabel.Text = obj.Name
			obj.NameLabel.Size = ESP.Settings.Name.Size
			obj.NameLabel.Color = ESP.Settings.Name.Color
		else
			obj.NameLabel.Visible = false
		end

		-- Distance
		if ESP.Settings.Distance.Enabled then
			obj.DistanceLabel.Visible = onScreen
			obj.DistanceLabel.Position = screen2D + Vector2.new(0, 15)
			obj.DistanceLabel.Text = tostring(math.floor((Camera.CFrame.Position - position).Magnitude)) .. "m"
			obj.DistanceLabel.Size = ESP.Settings.Distance.Size
			obj.DistanceLabel.Color = ESP.Settings.Distance.Color
		else
			obj.DistanceLabel.Visible = false
		end

		-- Outline
		if obj.Highlight then
			obj.Highlight.Enabled = ESP.Settings.Outline.Enabled
			obj.Highlight.OutlineColor = ESP.Settings.Outline.Color
		end
	end
end)

-- Controles externos
function ESP:SetEnabled(state: boolean) self.Enabled = state end
function ESP:SetLineEnabled(state: boolean) self.Settings.Line.Enabled = state end
function ESP:SetNameEnabled(state: boolean) self.Settings.Name.Enabled = state end
function ESP:SetDistanceEnabled(state: boolean) self.Settings.Distance.Enabled = state end
function ESP:SetOutlineEnabled(state: boolean) self.Settings.Outline.Enabled = state end
function ESP:SetPositionMode(mode: string) self.Settings.PositionMode = mode end

return ESP