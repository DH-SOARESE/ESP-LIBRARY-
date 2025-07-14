-- ESP Library por dhsoares01
-- Suporte a Tracer, Outline, Box3D, Distance, Name via Loadstring

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ESP = {}
ESP.Objects = {}
ESP.Enabled = true

ESP.DefaultSettings = {
	Name = "ESP", -- Nome padrão mostrado
	ShowName = true,
	ShowDistance = true,
	ShowTracer = true,
	ShowOutline = true,
	ShowBox3D = true,
	Color = Color3.fromRGB(0, 255, 0)
}

local function IsOnScreen(pos)
	local vec, onScreen = Camera:WorldToViewportPoint(pos)
	return onScreen, vec
end

local function CreateDrawing(class, props)
	local obj = Drawing.new(class)
	for i, v in pairs(props) do
		obj[i] = v
	end
	return obj
end

function ESP:AddObject(target, settings)
	settings = setmetatable(settings or {}, { __index = self.DefaultSettings })
	if not target or not target:IsDescendantOf(workspace) then return end

	local espData = {
		Target = target,
		Settings = settings,
		Drawings = {},
		Highlight = nil
	}

	-- Tracer
	if settings.ShowTracer then
		espData.Drawings.Tracer = CreateDrawing("Line", {
			Thickness = 1.5,
			Color = settings.Color,
			Transparency = 1,
			Visible = false
		})
	end

	-- Name
	if settings.ShowName then
		espData.Drawings.Name = CreateDrawing("Text", {
			Color = settings.Color,
			Size = 14,
			Center = true,
			Outline = true,
			Visible = false
		})
	end

	-- Distance
	if settings.ShowDistance then
		espData.Drawings.Distance = CreateDrawing("Text", {
			Color = settings.Color,
			Size = 13,
			Center = true,
			Outline = true,
			Visible = false
		})
	end

	-- Box 3D
	if settings.ShowBox3D then
		espData.Drawings.Box = CreateDrawing("Square", {
			Thickness = 1,
			Color = settings.Color,
			Transparency = 1,
			Filled = false,
			Visible = false
		})
	end

	-- Outline (Highlight)
	if settings.ShowOutline and target:IsA("Model") or target:IsA("BasePart") then
		local highlight = Instance.new("Highlight")
		highlight.Name = "_ESP_Highlight"
		highlight.FillColor = settings.Color
		highlight.OutlineColor = settings.Color
		highlight.FillTransparency = 0.7
		highlight.OutlineTransparency = 0
		highlight.Adornee = target
		highlight.Parent = target
		espData.Highlight = highlight
	end

	table.insert(self.Objects, espData)
end

function ESP:Clear()
	for _, esp in pairs(self.Objects) do
		for _, draw in pairs(esp.Drawings) do
			draw:Remove()
		end
		if esp.Highlight then
			pcall(function() esp.Highlight:Destroy() end)
		end
	end
	self.Objects = {}
end

RunService.RenderStepped:Connect(function()
	if not ESP.Enabled then return end
	for _, esp in pairs(ESP.Objects) do
		local target = esp.Target
		local root = target:IsA("Model") and target:FindFirstChild("HumanoidRootPart") or target:IsA("BasePart") and target or nil
		if not root then continue end

		local onscreen, pos = IsOnScreen(root.Position)
		if not onscreen then
			for _, draw in pairs(esp.Drawings) do
				draw.Visible = false
			end
			continue
		end

		local dist = (Camera.CFrame.Position - root.Position).Magnitude
		local settings = esp.Settings

		-- Tracer
		if settings.ShowTracer and esp.Drawings.Tracer then
			local line = esp.Drawings.Tracer
			line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
			line.To = Vector2.new(pos.X, pos.Y)
			line.Visible = true
		end

		-- Name
		if settings.ShowName and esp.Drawings.Name then
			local text = esp.Drawings.Name
			text.Position = Vector2.new(pos.X, pos.Y - 20)
			text.Text = settings.Name
			text.Visible = true
		end

		-- Distance
		if settings.ShowDistance and esp.Drawings.Distance then
			local dtext = esp.Drawings.Distance
			dtext.Position = Vector2.new(pos.X, pos.Y + 12)
			dtext.Text = string.format("%.1f m", dist)
			dtext.Visible = true
		end

		-- Box 3D
		if settings.ShowBox3D and esp.Drawings.Box then
			local box = esp.Drawings.Box
			local size = Vector2.new(50 / (dist / 10), 80 / (dist / 10)) -- escalar conforme distância
			box.Size = size
			box.Position = Vector2.new(pos.X - size.X / 2, pos.Y - size.Y / 2)
			box.Visible = true
		end

		-- Reaplicar highlight caso sumir
		if settings.ShowOutline and (not esp.Highlight or not esp.Highlight.Parent) then
			local hl = Instance.new("Highlight")
			hl.Name = "_ESP_Highlight"
			hl.FillColor = settings.Color
			hl.OutlineColor = settings.Color
			hl.FillTransparency = 0.7
			hl.OutlineTransparency = 0
			hl.Adornee = target
			hl.Parent = target
			esp.Highlight = hl
		end
	end
end)

return ESP