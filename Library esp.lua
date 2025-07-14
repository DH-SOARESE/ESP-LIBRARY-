-- ESP Outline, Line, Name, and Distance - por dhsoares01
-- Contorno (Highlight), linhas, nome e distância em metros

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local TextService = game:GetService("TextService")

local ESP = {}
ESP.Objects = {}
ESP.Enabled = true

ESP.Settings = {
	Outline = {
		Enabled = true,
		Color = Color3.fromRGB(255, 255, 0)
	},
	Line = {
		Enabled = true,
		Color = Color3.fromRGB(255, 255, 0),
		Thickness = 1,
		Origin = Enum.PartType.Cylinder
	},
	Name = {
		Enabled = true,
		Color = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.SourceSansBold,
		Size = 14
	},
	Distance = {
		Enabled = true,
		Color = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.SourceSansBold,
		Size = 12
	}
}

-- Função para criar o Highlight
local function createHighlight(target: Instance)
	local h = Instance.new("Highlight")
	h.Name = "ESP_Outline"
	h.FillTransparency = 1
	h.OutlineTransparency = 0
	h.OutlineColor = ESP.Settings.Outline.Color
	h.Adornee = target
	h.Parent = target
	return h
end

-- Função para criar a linha
local function createLine()
	local line = Instance.new("LineHandleAdornment")
	line.Name = "ESP_Line"
	line.Color3 = ESP.Settings.Line.Color
	line.Thickness = ESP.Settings.Line.Thickness
	line.Transparency = 0
	line.Length = 1
	line.CFrame = CFrame.new(Vector3.new(0, 0, 0))
	line.Parent = Camera
	return line
end

-- Função para criar o nome
local function createName(target: Instance)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESP_Name"
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 1000

	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.Text = target.Name
	nameLabel.TextColor3 = ESP.Settings.Name.Color
	nameLabel.Font = ESP.Settings.Name.Font
	nameLabel.TextSize = ESP.Settings.Name.Size
	nameLabel.Parent = billboard

	local distanceLabel = Instance.new("TextLabel")
	distanceLabel.BackgroundTransparency = 1
	distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
	distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
	distanceLabel.Text = "0m"
	distanceLabel.TextColor3 = ESP.Settings.Distance.Color
	distanceLabel.Font = ESP.Settings.Distance.Font
	distanceLabel.TextSize = ESP.Settings.Distance.Size
	distanceLabel.Parent = billboard

	billboard.Parent = target
	return billboard
end

-- Adiciona ESP (contorno, linha, nome e distância) a um alvo
function ESP:Add(target: Instance)
	if not target or (not target:IsA("BasePart") and not target:IsA("Model")) then return end

	local highlight = ESP.Settings.Outline.Enabled and createHighlight(target) or nil
	local line = ESP.Settings.Line.Enabled and createLine() or nil
	local name = ESP.Settings.Name.Enabled and createName(target) or nil

	table.insert(self.Objects, {
		Target = target,
		Highlight = highlight,
		Line = line,
		Name = name
	})
end

-- Função para calcular a distância em metros
local function getDistance(target: Instance)
	local localPos = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and LocalPlayer.Character.PrimaryPart.Position
	local targetPos = target:IsA("Model") and target.PrimaryPart and target.PrimaryPart.Position or target.Position
	if localPos and targetPos then
		return math.floor((localPos - targetPos).Magnitude / 3) -- Aproximadamente 3 studs = 1 metro
	end
	return 0
end

-- Atualização por frame
RunService.RenderStepped:Connect(function()
	if not ESP.Enabled then return end

	local cameraPos = Camera.CFrame.Position

	for i = #ESP.Objects, 1, -1 do
		local obj = ESP.Objects[i]
		local target = obj.Target

		if not target or not target.Parent then
			if obj.Highlight then pcall(function() obj.Highlight:Destroy() end) end
			if obj.Line then pcall(function() obj.Line:Destroy() end) end
			if obj.Name then pcall(function() obj.Name:Destroy() end) end
			table.remove(ESP.Objects, i)
			continue
		end

		-- Atualiza o contorno
		if ESP.Settings.Outline.Enabled then
			if not obj.Highlight or not obj.Highlight.Parent then
				obj.Highlight = createHighlight(target)
			else
				obj.Highlight.Enabled = true
				obj.Highlight.OutlineColor = ESP.Settings.Outline.Color
				obj.Highlight.Adornee = target
			end
		else
			if obj.Highlight then
				obj.Highlight.Enabled = false
			end
		end

		-- Atualiza a linha
		if ESP.Settings.Line.Enabled then
			if not obj.Line or not obj.Line.Parent then
				obj.Line = createLine()
			else
				local targetPos = target:IsA("Model") and target.PrimaryPart and target.PrimaryPart.Position or target.Position
				if targetPos then
					obj.Line.Adornee = target
					obj.Line.Color3 = ESP.Settings.Line.Color
					obj.Line.Thickness = ESP.Settings.Line.Thickness
					local distance = (cameraPos - targetPos).Magnitude
					obj.Line.Length = distance
					obj.Line.CFrame = CFrame.new(Vector3.new(0, 0, -distance/2))
				end
			end
		else
			if obj.Line then
				obj.Line:Destroy()
				obj.Line = nil
			end
		end

		-- Atualiza nome e distância
		if ESP.Settings.Name.Enabled or ESP.Settings.Distance.Enabled then
			if not obj.Name or not obj.Name.Parent then
				obj.Name = createName(target)
			else
				local nameLabel = obj.Name:FindFirstChildOfClass("TextLabel")
				local distanceLabel = obj.Name:FindFirstChildOfClass("TextLabel", true)
				if nameLabel and ESP.Settings.Name.Enabled then
					nameLabel.Text = target.Name
					nameLabel.TextColor3 = ESP.Settings.Name.Color
					nameLabel.Font = ESP.Settings.Name.Font
					nameLabel.TextSize = ESP.Settings.Name.Size
				end
				if distanceLabel and ESP.Settings.Distance.Enabled then
					distanceLabel.Text = tostring(getDistance(target)) .. "m"
					distanceLabel.TextColor3 = ESP.Settings.Distance.Color
					distanceLabel.Font = ESP.Settings.Distance.Font
					distanceLabel.TextSize = ESP.Settings.Distance.Size
				end
				obj.Name.Enabled = true
			end
		else
			if obj.Name then
				obj.Name:Destroy()
				obj.Name = nil
			end
		end
	end
end)

-- Controles externos
function ESP:SetEnabled(state: boolean)
	self.Enabled = state
end

function ESP:SetOutlineEnabled(state: boolean)
	self.Settings.Outline.Enabled = state
end

function ESP:SetOutlineColor(color: Color3)
	self.Settings.Outline.Color = color
end

function ESP:SetLineEnabled(state: boolean)
	self.Settings.Line.Enabled = state
end

function ESP:SetLineColor(color: Color3)
	self.Settings.Line.Color = color
end

function ESP:SetLineThickness(thickness: number)
	self.Settings.Line.Thickness = thickness
end

function ESP:SetNameEnabled(state: boolean)
	self.Settings.Name.Enabled = state
end

function ESP:SetNameColor(color: Color3)
	self.Settings.Name.Color = color
end

function ESP:SetDistanceEnabled(state: boolean)
	self.Settings.Distance.Enabled = state
end

function ESP:SetDistanceColor(color: Color3)
	self.Settings.Distance.Color = color
end

return ESP