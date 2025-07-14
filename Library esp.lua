-- ESP Library by dhsoares01 (versão otimizada)
-- Suporte a Model/BasePart com Line, Outline, Distância, Nome e controle via código

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ESP = {}
ESP.Objects = {}
ESP.Enabled = true

ESP.Settings = {
	ShowLine = true,
	ShowName = true,
	ShowDistance = true,
	ShowOutline = true,
	LineColor = Color3.fromRGB(255, 0, 0),
	TextColor = Color3.fromRGB(255, 255, 255),
	OutlineColor = Color3.fromRGB(255, 255, 0),
	TextSize = 14,
	PositionMode = "Center" -- Top, Center, Bottom, LeftCenter, RightCenter
}

-- Criação de Drawings
local function createDrawing(type, props)
	local obj = Drawing.new(type)
	for i, v in pairs(props) do
		obj[i] = v
	end
	return obj
end

-- Centro de um Model
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

-- Offset baseado no modo selecionado
local function getOffset(part)
	local y = part.Size.Y / 2
	local x = part.Size.X / 2

	if ESP.Settings.PositionMode == "Top" then
		return Vector3.new(0, y, 0)
	elseif ESP.Settings.PositionMode == "Bottom" then
		return Vector3.new(0, -y, 0)
	elseif ESP.Settings.PositionMode == "LeftCenter" then
		return Vector3.new(-x, 0, 0)
	elseif ESP.Settings.PositionMode == "RightCenter" then
		return Vector3.new(x, 0, 0)
	else
		return Vector3.zero
	end
end

-- Adiciona novo objeto com ESP
function ESP:Add(target: Instance, nameOverride)
	if not target or (not target:IsA("BasePart") and not target:IsA("Model")) then return end

	local highlight
	if ESP.Settings.ShowOutline then
		highlight = Instance.new("Highlight")
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 0
		highlight.OutlineColor = ESP.Settings.OutlineColor
		highlight.Adornee = target
		highlight.Parent = target
	end

	table.insert(self.Objects, {
		Target = target,
		Name = nameOverride or target.Name,
		Highlight = highlight,
		Line = createDrawing("Line", {Thickness = 1.5, Color = self.Settings.LineColor, Visible = false}),
		NameLabel = createDrawing("Text", {Size = self.Settings.TextSize, Color = self.Settings.TextColor, Center = true, Visible = false, Outline = true}),
		DistanceLabel = createDrawing("Text", {Size = self.Settings.TextSize, Color = self.Settings.TextColor, Center = true, Visible = false, Outline = true}),
	})
end

-- Atualiza os objetos a cada frame
RunService.RenderStepped:Connect(function()
	if not ESP.Enabled then return end

	for i = #ESP.Objects, 1, -1 do
		local obj = ESP.Objects[i]
		local target = obj.Target
		if not target or not target.Parent then
			if obj.Highlight then pcall(function() obj.Highlight:Destroy() end) end
			for _, key in ipairs({"Line", "NameLabel", "DistanceLabel"}) do
				if obj[key] then pcall(function() obj[key]:Remove() end) end
			end
			table.remove(ESP.Objects, i)
			continue
		end

		local position
		if target:IsA("Model") then
			position = getModelCenter(target)
		elseif target:IsA("BasePart") then
			position = target.Position + getOffset(target)
		else
			continue
		end

		local screenPos, onScreen = Camera:WorldToViewportPoint(position)
		if not onScreen then
			obj.Line.Visible = false
			obj.NameLabel.Visible = false
			obj.DistanceLabel.Visible = false
			continue
		end

		local screen2D = Vector2.new(screenPos.X, screenPos.Y)

		-- Linha
		if ESP.Settings.ShowLine then
			obj.Line.Visible = true
			obj.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
			obj.Line.To = screen2D
			obj.Line.Color = ESP.Settings.LineColor
		else
			obj.Line.Visible = false
		end

		-- Nome
		if ESP.Settings.ShowName then
			obj.NameLabel.Visible = true
			obj.NameLabel.Position = screen2D - Vector2.new(0, 20)
			obj.NameLabel.Text = obj.Name
			obj.NameLabel.Color = ESP.Settings.TextColor
		else
			obj.NameLabel.Visible = false
		end

		-- Distância
		if ESP.Settings.ShowDistance then
			local dist = math.floor((Camera.CFrame.Position - position).Magnitude)
			obj.DistanceLabel.Visible = true
			obj.DistanceLabel.Position = screen2D + Vector2.new(0, 15)
			obj.DistanceLabel.Text = tostring(dist) .. "m"
			obj.DistanceLabel.Color = ESP.Settings.TextColor
		else
			obj.DistanceLabel.Visible = false
		end

		-- Outline
		if ESP.Settings.ShowOutline and obj.Highlight then
			obj.Highlight.Enabled = true
			obj.Highlight.OutlineColor = ESP.Settings.OutlineColor
			obj.Highlight.Adornee = target
		elseif obj.Highlight then
			obj.Highlight.Enabled = false
		end
	end
end)

-- Controles públicos
function ESP:SetEnabled(state: boolean)
	self.Enabled = state
end

function ESP:SetPositionMode(mode: string)
	self.Settings.PositionMode = mode
end

return ESP