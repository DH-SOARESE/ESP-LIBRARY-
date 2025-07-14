-- ESP Library por dhsoares01 (Outline, Line, Name, Distância) - Configurável por objeto

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESP = {}
ESP.Objects = {}
ESP.Enabled = true

ESP.Settings = {
	Outline = {
		Color = Color3.fromRGB(255, 255, 0)
	},
	LineColor = Color3.fromRGB(255, 0, 0),
	TextColor = Color3.fromRGB(255, 255, 255)
}

-- Cria o Highlight
local function createHighlight(target: Instance, color: Color3)
	local h = Instance.new("Highlight")
	h.Name = "ESP_Outline"
	h.FillTransparency = 1
	h.OutlineTransparency = 0
	h.OutlineColor = color
	h.Adornee = target
	h.Parent = target
	return h
end

-- Cria o Billboard GUI (Name + Distância)
local function createBillboard(target: Instance)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESP_Billboard"
	billboard.Size = UDim2.new(0, 200, 0, 30)
	billboard.AlwaysOnTop = true
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.Adornee = target
	billboard.Parent = target

	local label = Instance.new("TextLabel", billboard)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = ESP.Settings.TextColor
	label.TextStrokeTransparency = 0.5
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.Name = "ESP_Label"

	return billboard
end

-- Adiciona ESP a um objeto
function ESP:Add(target: Instance, opts)
	if not target or (not target:IsA("BasePart") and not target:IsA("Model")) then return end

	local options = {
		Outline = opts and opts.Outline,
		Line = opts and opts.Line,
		Name = opts and opts.Name,
		Distance = opts and opts.Distance
	}

	local highlight = options.Outline and createHighlight(target, ESP.Settings.Outline.Color) or nil
	local billboard = (options.Name or options.Distance) and createBillboard(target) or nil

	table.insert(self.Objects, {
		Target = target,
		Highlight = highlight,
		Billboard = billboard,
		ShowLine = options.Line,
		ShowName = options.Name,
		ShowDistance = options.Distance
	})
end

-- Atualização por frame
RunService.RenderStepped:Connect(function()
	if not ESP.Enabled then return end

	for i = #ESP.Objects, 1, -1 do
		local obj = ESP.Objects[i]
		local target = obj.Target
		local root = (target:IsA("Model") and target:FindFirstChild("HumanoidRootPart")) or (target:IsA("BasePart") and target)

		if not target or not target.Parent or not root then
			if obj.Highlight then pcall(function() obj.Highlight:Destroy() end) end
			if obj.Billboard then pcall(function() obj.Billboard:Destroy() end) end
			table.remove(ESP.Objects, i)
			continue
		end

		-- Outline
		if obj.Highlight then
			obj.Highlight.Enabled = true
			obj.Highlight.Adornee = target
		end

		-- Name + Distance
		if obj.Billboard then
			local label = obj.Billboard:FindFirstChild("ESP_Label")
			if label then
				local distance = (Camera.CFrame.Position - root.Position).Magnitude
				local nameText = obj.ShowName and target.Name or ""
				local distText = obj.ShowDistance and (" [" .. math.floor(distance) .. "m]") or ""
				label.Text = nameText .. distText
			end
		end

		-- Line
		if obj.ShowLine then
			local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
			if onScreen then
				local line = Drawing.new("Line")
				line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
				line.To = Vector2.new(screenPos.X, screenPos.Y)
				line.Color = ESP.Settings.LineColor
				line.Thickness = 1.5
				line.Transparency = 1
				line.ZIndex = 2
				line.Visible = true

				task.delay(0.03, function()
					line:Remove()
				end)
			end
		end
	end
end)

-- Controles
function ESP:SetEnabled(state: boolean)
	self.Enabled = state
end

function ESP:SetOutlineColor(color: Color3)
	self.Settings.Outline.Color = color
end

function ESP:SetLineColor(color: Color3)
	self.Settings.LineColor = color
end

function ESP:SetTextColor(color: Color3)
	self.Settings.TextColor = color
end

return ESP