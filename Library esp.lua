--[[  
ESP Library (Model/BasePart based)
Suporte: Tracer, Outline, Box Outline, Distance, Name
Uso:
  ESP:Add(object, {
    Name = "Objeto XPTO",
    Color = Color3.fromRGB(255, 255, 0),
    Tracer = true,
    Outline = true,
    Box = true,
    Distance = true,
    NameVisible = true
  })

  ESP:Remove(object)
  ESP:Clear()
  ESP:Toggle(true/false)
--]]

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESP = {
	Enabled = true,
	Objects = {}
}

local function IsOnScreen(pos)
	local _, onScreen = Camera:WorldToViewportPoint(pos)
	return onScreen
end

local function GetDistance(pos)
	return math.floor((Camera.CFrame.Position - pos).Magnitude)
end

local function DrawLine()
	local line = Drawing.new("Line")
	line.Thickness = 1.5
	line.Color = Color3.new(1, 1, 1)
	line.Transparency = 1
	return line
end

local function DrawText()
	local text = Drawing.new("Text")
	text.Size = 13
	text.Center = true
	text.Outline = true
	text.Font = 2
	text.Color = Color3.new(1, 1, 1)
	text.Transparency = 1
	return text
end

local function DrawBox()
	local box = {}
	box.TopLeft = Drawing.new("Line")
	box.TopRight = Drawing.new("Line")
	box.BottomLeft = Drawing.new("Line")
	box.BottomRight = Drawing.new("Line")

	for _, line in pairs(box) do
		line.Thickness = 1.5
		line.Color = Color3.new(1, 1, 1)
		line.Transparency = 1
	end

	return box
end

function ESP:Add(object, settings)
	if not object then return end
	if self.Objects[object] then return end

	settings = settings or {}
	local tracer = settings.Tracer and DrawLine() or nil
	local nameText = settings.NameVisible and DrawText() or nil
	local distText = settings.Distance and DrawText() or nil
	local box = settings.Box and DrawBox() or nil
	local outline = settings.Outline and Drawing.new("Quad") or nil

	if outline then
		outline.Thickness = 1
		outline.Transparency = 1
		outline.Filled = false
		outline.Color = settings.Color or Color3.new(1, 1, 1)
	end

	self.Objects[object] = {
		Target = object,
		Settings = settings,
		Tracer = tracer,
		NameText = nameText,
		DistanceText = distText,
		Box = box,
		Outline = outline,
	}
end

function ESP:Remove(object)
	local esp = self.Objects[object]
	if not esp then return end

	if esp.Tracer then esp.Tracer:Remove() end
	if esp.NameText then esp.NameText:Remove() end
	if esp.DistanceText then esp.DistanceText:Remove() end
	if esp.Outline then esp.Outline:Remove() end
	if esp.Box then
		for _, line in pairs(esp.Box) do
			line:Remove()
		end
	end

	self.Objects[object] = nil
end

function ESP:Clear()
	for obj in pairs(self.Objects) do
		self:Remove(obj)
	end
end

function ESP:Toggle(state)
	self.Enabled = state
end

RunService.RenderStepped:Connect(function()
	if not ESP.Enabled then return end

	for obj, esp in pairs(ESP.Objects) do
		local part = (obj:IsA("Model") and obj.PrimaryPart) or (obj:IsA("BasePart") and obj)
		if not part or not part:IsDescendantOf(workspace) then
			ESP:Remove(obj)
			continue
		end

		local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
		if not onScreen then
			if esp.Tracer then esp.Tracer.Visible = false end
			if esp.NameText then esp.NameText.Visible = false end
			if esp.DistanceText then esp.DistanceText.Visible = false end
			if esp.Outline then esp.Outline.Visible = false end
			if esp.Box then
				for _, line in pairs(esp.Box) do
					line.Visible = false
				end
			end
			continue
		end

		local color = esp.Settings.Color or Color3.new(1, 1, 1)

		if esp.Tracer then
			esp.Tracer.Visible = true
			esp.Tracer.Color = color
			esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
			esp.Tracer.To = Vector2.new(pos.X, pos.Y)
		end

		if esp.NameText then
			esp.NameText.Visible = true
			esp.NameText.Text = tostring(esp.Settings.Name or obj.Name)
			esp.NameText.Position = Vector2.new(pos.X, pos.Y - 16)
			esp.NameText.Color = color
		end

		if esp.DistanceText then
			esp.DistanceText.Visible = true
			esp.DistanceText.Text = tostring(GetDistance(part.Position)) .. "m"
			esp.DistanceText.Position = Vector2.new(pos.X, pos.Y)
			esp.DistanceText.Color = color
		end

		if esp.Box then
			local size = part.Size
			local corners = {
				Camera:WorldToViewportPoint((part.CFrame * CFrame.new(-size.X/2, size.Y/2, -size.Z/2)).Position),
				Camera:WorldToViewportPoint((part.CFrame * CFrame.new(size.X/2, size.Y/2, -size.Z/2)).Position),
				Camera:WorldToViewportPoint((part.CFrame * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2)).Position),
				Camera:WorldToViewportPoint((part.CFrame * CFrame.new(size.X/2, -size.Y/2, -size.Z/2)).Position),
			}

			esp.Box.TopLeft.From = Vector2.new(corners[1].X, corners[1].Y)
			esp.Box.TopLeft.To = Vector2.new(corners[2].X, corners[2].Y)

			esp.Box.TopRight.From = Vector2.new(corners[2].X, corners[2].Y)
			esp.Box.TopRight.To = Vector2.new(corners[4].X, corners[4].Y)

			esp.Box.BottomRight.From = Vector2.new(corners[4].X, corners[4].Y)
			esp.Box.BottomRight.To = Vector2.new(corners[3].X, corners[3].Y)

			esp.Box.BottomLeft.From = Vector2.new(corners[3].X, corners[3].Y)
			esp.Box.BottomLeft.To = Vector2.new(corners[1].X, corners[1].Y)

			for _, line in pairs(esp.Box) do
				line.Color = color
				line.Visible = true
			end
		end

		if esp.Outline then
			esp.Outline.Visible = true
			local size = part.Size
			local cf = part.CFrame

			local p1 = Camera:WorldToViewportPoint((cf * CFrame.new(-size.X/2, size.Y/2, -size.Z/2)).Position)
			local p2 = Camera:WorldToViewportPoint((cf * CFrame.new(size.X/2, size.Y/2, -size.Z/2)).Position)
			local p3 = Camera:WorldToViewportPoint((cf * CFrame.new(size.X/2, -size.Y/2, -size.Z/2)).Position)
			local p4 = Camera:WorldToViewportPoint((cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2)).Position)

			esp.Outline.PointA = Vector2.new(p1.X, p1.Y)
			esp.Outline.PointB = Vector2.new(p2.X, p2.Y)
			esp.Outline.PointC = Vector2.new(p3.X, p3.Y)
			esp.Outline.PointD = Vector2.new(p4.X, p4.Y)
			esp.Outline.Color = color
		end
	end
end)

return ESP
