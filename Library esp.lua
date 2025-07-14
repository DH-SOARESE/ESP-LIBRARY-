-- ESP Library by dhsoares01
-- Suporte a: Tracer, Outline, Box3D, Distância, Name (definido ao adicionar)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESP = {}
ESP.Objects = {}

function ESP:WorldToScreen(pos)
	local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
	return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

function ESP:CreateLine()
	local line = Drawing.new("Line")
	line.Color = Color3.fromRGB(255, 0, 0)
	line.Thickness = 1.5
	line.Transparency = 1
	line.Visible = false
	return line
end

function ESP:CreateText()
	local text = Drawing.new("Text")
	text.Color = Color3.fromRGB(255, 255, 255)
	text.Size = 16
	text.Center = true
	text.Outline = true
	text.Transparency = 1
	text.Visible = false
	return text
end

function ESP:AddObject(object, options)
	if not object or not object:IsA("Model") then return end

	local primary = object:FindFirstChildWhichIsA("BasePart")
	if not primary then return end

	local data = {
		Object = object,
		Primary = primary,
		Options = options or {},
		Tracer = options.Tracer and self:CreateLine() or nil,
		NameText = options.Name and (options.Name ~= "" and options.Name) and self:CreateText() or nil,
		DistanceText = options.Distance and self:CreateText() or nil,
	}

	-- Highlight (Outline e Box3D)
	if options.Outline or options.Box3D then
		local hl = Instance.new("Highlight")
		hl.Name = "ESP_Highlight"
		hl.Adornee = object
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.FillTransparency = options.Box3D and 0.5 or 1
		hl.FillColor = Color3.fromRGB(255, 0, 0)
		hl.OutlineColor = Color3.fromRGB(255, 0, 0)
		hl.OutlineTransparency = options.Outline and 0 or 1
		hl.Parent = object
		data.Highlight = hl
	end

	self.Objects[#self.Objects + 1] = data
end

function ESP:RemoveObject(object)
	for i, v in ipairs(self.Objects) do
		if v.Object == object then
			if v.Tracer then v.Tracer:Remove() end
			if v.NameText then v.NameText:Remove() end
			if v.DistanceText then v.DistanceText:Remove() end
			if v.Highlight and v.Highlight.Parent then v.Highlight:Destroy() end
			table.remove(self.Objects, i)
			break
		end
	end
end

RunService.RenderStepped:Connect(function()
	for i, v in ipairs(ESP.Objects) do
		local obj = v.Object
		local part = v.Primary

		if not obj or not obj.Parent or not part or not part:IsDescendantOf(workspace) then
			ESP:RemoveObject(obj)
		else
			local screenPos, onScreen, distance = ESP:WorldToScreen(part.Position)

			if v.Tracer then
				v.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
				v.Tracer.To = screenPos
				v.Tracer.Visible = onScreen
			end

			if v.NameText then
				v.NameText.Position = screenPos - Vector2.new(0, 20)
				v.NameText.Text = v.Options.Name or "Object"
				v.NameText.Visible = onScreen
			end

			if v.DistanceText then
				v.DistanceText.Position = screenPos + Vector2.new(0, 15)
				v.DistanceText.Text = string.format("%.1f m", distance)
				v.DistanceText.Visible = onScreen
			end

			if v.Highlight then
				v.Highlight.Adornee = obj
			end
		end
	end
end)

return ESP