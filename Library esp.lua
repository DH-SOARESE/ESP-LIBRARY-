-- ESP Library por dhsoares01
-- Suporte a: Tracer, Outline, Box3D, Distance, Name (custom)
-- Endereço de objetos: Model ou BasePart

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESP = {}
ESP.Objects = {}

function ESP:AddObject(target, options)
	if not target then return end
	options = options or {}

	local config = {
		Target = target,
		Name = options.Name or target.Name,
		Tracer = options.Tracer or false,
		Outline = options.Outline or false,
		Box3D = options.Box3D or false,
		Distance = options.Distance or false,
	}

	local highlight
	if config.Outline and target:IsA("Model") or target:IsA("BasePart") then
		highlight = Instance.new("Highlight")
		highlight.Adornee = target
		highlight.FillColor = Color3.fromRGB(255, 0, 0)
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = config.Box3D and 0.5 or 1
		highlight.OutlineTransparency = 0
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = target
	end

	table.insert(ESP.Objects, {
		Target = target,
		Config = config,
		Highlight = highlight
	})
end

function ESP:RemoveAll()
	for _, obj in ipairs(ESP.Objects) do
		if obj.Highlight then
			obj.Highlight:Destroy()
		end
	end
	ESP.Objects = {}
end

RunService.RenderStepped:Connect(function()
	for i, obj in ipairs(ESP.Objects) do
		local target = obj.Target
		if not target or not target:IsDescendantOf(workspace) then continue end

		local pos
		if target:IsA("Model") then
			local primary = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
			if primary then pos = primary.Position else continue end
		elseif target:IsA("BasePart") then
			pos = target.Position
		else
			continue
		end

		local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
		if not onScreen then continue end

		local config = obj.Config
		local distance = (Camera.CFrame.Position - pos).Magnitude

		if config.Tracer then
			if not obj.TracerLine then
				local line = Drawing.new("Line")
				line.Color = Color3.fromRGB(0, 255, 0)
				line.Thickness = 1.5
				line.Transparency = 1
				line.ZIndex = 2
				obj.TracerLine = line
			end
			obj.TracerLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
			obj.TracerLine.To = Vector2.new(screenPos.X, screenPos.Y)
			obj.TracerLine.Visible = true
		elseif obj.TracerLine then
			obj.TracerLine.Visible = false
		end

		local text = ""
		if config.Name then text = config.Name end
		if config.Distance then
			text = text .. string.format(" (%.1fm)", distance)
		end

		if not obj.NameLabel then
			local label = Drawing.new("Text")
			label.Color = Color3.new(1, 1, 1)
			label.Size = 16
			label.Center = true
			label.Outline = true
			label.Font = 2
			obj.NameLabel = label
		end
		obj.NameLabel.Text = text
		obj.NameLabel.Position = Vector2.new(screenPos.X, screenPos.Y - 10)
		obj.NameLabel.Visible = true
	end
end)

return ESP