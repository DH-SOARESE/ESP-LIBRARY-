-- ESP Library (versão com reparentamento de Highlight)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESP = {}
ESP.Objects = {}

-- Adiciona um novo objeto à ESP
function ESP:AddObject(target, options)
	if not target then return end
	options = options or {}

	local config = {
		Target = target,
		Name = options.Name or target.Name,
		Tracer = options.Tracer or false,
		Outline = options.Outline or false,
		Box3D = options.Box3D or false,
		Distance = options.Distance or false
	}

	table.insert(ESP.Objects, {
		Target = target,
		Config = config,
		Highlight = nil,
		TracerLine = nil,
		NameLabel = nil
	})
end

-- Remove todos os objetos ESP e limpa recursos
function ESP:RemoveAll()
	for _, obj in ipairs(ESP.Objects) do
		if obj.Highlight then obj.Highlight:Destroy() end
		if obj.TracerLine then pcall(function() obj.TracerLine:Remove() end) end
		if obj.NameLabel then pcall(function() obj.NameLabel:Remove() end) end
	end
	ESP.Objects = {}
end

-- Atualiza os ESPs a cada frame
RunService.RenderStepped:Connect(function()
	for i, obj in ipairs(ESP.Objects) do
		local target = obj.Target
		if not target or not target:IsDescendantOf(workspace) then continue end

		local config = obj.Config
		local part

		if target:IsA("Model") then
			part = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
		elseif target:IsA("BasePart") then
			part = target
		end

		if not part then continue end

		local pos = part.Position
		local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
		local distance = (Camera.CFrame.Position - pos).Magnitude

		-- 🔲 Outline (Highlight)
		if config.Outline then
			if not obj.Highlight then
				local h = Instance.new("Highlight")
				h.Name = "_ESPHighlight"
				h.FillColor = Color3.fromRGB(255, 0, 0)
				h.OutlineColor = Color3.fromRGB(255, 255, 255)
				h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				h.FillTransparency = config.Box3D and 0.5 or 1
				h.OutlineTransparency = 0
				obj.Highlight = h
			end
			obj.Highlight.Adornee = target
			obj.Highlight.FillTransparency = config.Box3D and 0.5 or 1
			obj.Highlight.Parent = target
		elseif obj.Highlight then
			obj.Highlight:Destroy()
			obj.Highlight = nil
		end

		-- 📍 Tracer (linha até o centro da tela)
		if config.Tracer then
			if not obj.TracerLine then
				local line = Drawing.new("Line")
				line.Color = Color3.fromRGB(0, 255, 0)
				line.Thickness = 1.5
				line.Transparency = 1
				line.ZIndex = 2
				obj.TracerLine = line
			end
			if onScreen then
				obj.TracerLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
				obj.TracerLine.To = Vector2.new(screenPos.X, screenPos.Y)
				obj.TracerLine.Visible = true
			else
				obj.TracerLine.Visible = false
			end
		elseif obj.TracerLine then
			obj.TracerLine.Visible = false
		end

		-- 🏷️ Nome + Distância
		if config.Name or config.Distance then
			if not obj.NameLabel then
				local label = Drawing.new("Text")
				label.Color = Color3.fromRGB(255, 255, 255)
				label.Size = 15
				label.Center = true
				label.Outline = true
				label.Font = 2
				obj.NameLabel = label
			end

			local text = ""
			if config.Name then text = config.Name end
			if config.Distance then
				text = text .. string.format(" (%.1fm)", distance)
			end

			if onScreen then
				obj.NameLabel.Text = text
				obj.NameLabel.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
				obj.NameLabel.Visible = true
			else
				obj.NameLabel.Visible = false
			end
		elseif obj.NameLabel then
			obj.NameLabel.Visible = false
		end
	end
end)

return ESP