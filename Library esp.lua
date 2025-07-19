-- ESP Library by DH - Workspace Oriented
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local ESP = {}
ESP.Enabled = true
ESP.Objects = {}
ESP.Settings = {
	ShowTracer = true,
	ShowBox = true,
	ShowOutline = true,
	ShowName = true,
	ShowDistance = true,
	Reference = "Bottom", -- "Bottom" or "Center"
	Color = Color3.fromRGB(0, 255, 0),
	Font = Enum.Font.SourceSansBold,
}

-- Utilidade
local function isOnScreen(pos)
	local _, onScreen = Camera:WorldToViewportPoint(pos)
	return onScreen
end

local function getPosition(obj)
	if obj:IsA("BasePart") then
		return obj.Position
	elseif obj:IsA("Model") and obj.PrimaryPart then
		return obj.PrimaryPart.Position
	elseif obj:IsA("Model") then
		local parts = obj:GetDescendants()
		for _, part in ipairs(parts) do
			if part:IsA("BasePart") then
				return part.Position
			end
		end
	elseif obj:IsA("Attachment") then
		return obj.WorldPosition
	end
	return Vector3.zero
end

local function round(n)
	return math.floor(n * 10 + 0.5) / 10
end

-- Adicionar ESP
function ESP:Add(obj, customName)
	if not obj or ESP.Objects[obj] then return end

	local name = customName or obj.Name
	local holder = Drawing.new("Text")
	holder.Center = true
	holder.Outline = true
	holder.Size = 13
	holder.Font = Drawing.Fonts.UI
	holder.Color = ESP.Settings.Color

	local distance = Drawing.new("Text")
	distance.Center = true
	distance.Outline = true
	distance.Size = 12
	distance.Font = Drawing.Fonts.UI
	distance.Color = Color3.fromRGB(200, 200, 200)

	local tracer = Drawing.new("Line")
	tracer.Thickness = 1.5
	tracer.Color = ESP.Settings.Color

	local box = Drawing.new("Square")
	box.Thickness = 1.5
	box.Color = ESP.Settings.Color
	box.Filled = false

	ESP.Objects[obj] = {
		Object = obj,
		Name = holder,
		Distance = distance,
		Tracer = tracer,
		Box = box,
	}
end

-- Remover ESP
function ESP:Remove(obj)
	local esp = ESP.Objects[obj]
	if esp then
		for _, v in pairs(esp) do
			if typeof(v) == "table" or typeof(v) == "Instance" then continue end
			if typeof(v) == "userdata" and v.Remove then pcall(function() v:Remove() end) end
		end
		ESP.Objects[obj] = nil
	end
end

-- Loop de renderização
RunService.RenderStepped:Connect(function()
	if not ESP.Enabled then return end

	for obj, data in pairs(ESP.Objects) do
		local ok, pos = pcall(getPosition, obj)
		if not ok or not pos then ESP:Remove(obj) continue end

		local screenPos, visible = Camera:WorldToViewportPoint(pos)
		if not visible then
			data.Name.Visible = false
			data.Distance.Visible = false
			data.Tracer.Visible = false
			data.Box.Visible = false
			continue
		end

		local localPlayer = Players.LocalPlayer
		local char = localPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")

		local dist = root and round((root.Position - pos).Magnitude) or 0

		-- Tracer
		if ESP.Settings.ShowTracer then
			data.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
			data.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
			data.Tracer.Visible = true
		else
			data.Tracer.Visible = false
		end

		-- Nome
		if ESP.Settings.ShowName then
			data.Name.Position = Vector2.new(screenPos.X, screenPos.Y - 15)
			data.Name.Text = obj.Name
			data.Name.Visible = true
		else
			data.Name.Visible = false
		end

		-- Distância
		if ESP.Settings.ShowDistance then
			data.Distance.Position = Vector2.new(screenPos.X, screenPos.Y)
			data.Distance.Text = "(" .. dist .. "m)"
			data.Distance.Visible = true
		else
			data.Distance.Visible = false
		end

		-- Box
		if ESP.Settings.ShowBox and obj:IsA("Model") and obj.PrimaryPart then
			local size = obj:GetExtentsSize()
			local screenSize = (Camera:WorldToViewportPoint(obj.PrimaryPart.Position + Vector3.new(size.X/2, size.Y/2, 0)) -
								Camera:WorldToViewportPoint(obj.PrimaryPart.Position - Vector3.new(size.X/2, size.Y/2, 0)))

			data.Box.Size = Vector2.new(math.abs(screenSize.X), math.abs(screenSize.Y))
			data.Box.Position = Vector2.new(screenPos.X - data.Box.Size.X/2, screenPos.Y - data.Box.Size.Y/2)
			data.Box.Visible = true
		else
			data.Box.Visible = false
		end
	end
end)

-- Resetar todos
function ESP:ClearAll()
	for obj in pairs(ESP.Objects) do
		self:Remove(obj)
	end
end

-- Ativar/Desativar ESP
function ESP:SetEnabled(state)
	ESP.Enabled = state
	if not state then
		ESP:ClearAll()
	end
end

return ESP
