--[[ 
ESP Library by DH
GitHub Compatible | Executável via loadstring
https://github.com/seu-usuario/seu-repo/esp.lua
]]

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local DrawingLib = {}

local function WorldToViewport(pos)
	local viewportPos, onScreen = Camera:WorldToViewportPoint(pos)
	return viewportPos, onScreen
end

local function createESP(obj, config)
	local esp = {}

	-- Nome
	esp.name = Drawing.new("Text")
	esp.name.Size = 13
	esp.name.Center = true
	esp.name.Outline = true
	esp.name.Font = 2
	esp.name.Color = Color3.fromRGB(255, 255, 255)
	esp.name.Text = config.Name or "Objeto"

	-- Distância
	esp.distance = Drawing.new("Text")
	esp.distance.Size = 13
	esp.distance.Center = true
	esp.distance.Outline = true
	esp.distance.Font = 2
	esp.distance.Color = Color3.fromRGB(200, 200, 200)

	-- Linha
	esp.tracer = Drawing.new("Line")
	esp.tracer.Thickness = 1.5
	esp.tracer.Color = Color3.fromRGB(255, 255, 0)

	-- Caixa
	esp.box = Drawing.new("Square")
	esp.box.Thickness = 1.5
	esp.box.Color = Color3.fromRGB(0, 255, 0)
	esp.box.Filled = false

	-- Outline
	esp.outline = Drawing.new("Square")
	esp.outline.Thickness = 3
	esp.outline.Color = Color3.fromRGB(0, 0, 0)
	esp.outline.Filled = false

	local function remove()
		for _, v in pairs(esp) do
			if typeof(v) == "Drawing" then
				v:Remove()
			end
		end
	end

	local function update()
		if not obj or not obj:IsDescendantOf(workspace) then
			remove()
			return false
		end

		local pos = obj.Position or (obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart)
		if not pos then return end

		local cf = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart")) and obj:GetBoundingBox()
		local size = cf and cf.Size or Vector3.new(2, 3, 1)

		local rootPos = obj.Position or (obj:IsA("Model") and cf.Position)
		local screenPos, onScreen = WorldToViewport(rootPos)
		if not onScreen then
			for _, v in pairs(esp) do if typeof(v) == "Drawing" then v.Visible = false end end
			return true
		end

		local dist = (Camera.CFrame.Position - rootPos).Magnitude

		-- Nome
		if config.Name then
			esp.name.Position = Vector2.new(screenPos.X, screenPos.Y - 15)
			esp.name.Text = config.Name
			esp.name.Visible = true
		end

		-- Distância
		if config.ShowDistance then
			esp.distance.Text = string.format("%.1f m", dist)
			esp.distance.Position = Vector2.new(screenPos.X, screenPos.Y + 15)
			esp.distance.Visible = true
		end

		-- Tracer
		if config.Tracer then
			esp.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
			esp.tracer.To = Vector2.new(screenPos.X, screenPos.Y)
			esp.tracer.Visible = true
		end

		-- Caixa
		if config.Box then
			local width = size.X * (1000 / dist)
			local height = size.Y * (1000 / dist)
			local topLeft = Vector2.new(screenPos.X - width / 2, screenPos.Y - height / 2)

			if config.Outline then
				esp.outline.Position = topLeft
				esp.outline.Size = Vector2.new(width, height)
				esp.outline.Visible = true
			end

			esp.box.Position = topLeft
			esp.box.Size = Vector2.new(width, height)
			esp.box.Visible = true
		end

		return true
	end

	return { Update = update, Remove = remove }
end

return function(settings)
	local espList = {}
	local objects = settings.Objects or {}
	local config = {
		Name = settings.Name or "ESP",
		Tracer = settings.Tracer or false,
		Box = settings.Box or false,
		Outline = settings.Outline or false,
		ShowDistance = settings.ShowDistance or false
	}

	for _, obj in ipairs(objects) do
		local esp = createESP(obj, config)
		table.insert(espList, esp)
	end

	RunService.RenderStepped:Connect(function()
		for i = #espList, 1, -1 do
			local item = espList[i]
			if not item.Update() then
				table.remove(espList, i)
			end
		end
	end)
end
