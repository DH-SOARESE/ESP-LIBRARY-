-- ESP Library OOP - by STSTSS
local ESP = {}
ESP.__index = ESP

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Utilidades
local function WorldToViewport(pos)
	local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
	return screenPos, onScreen
end

local function GetDistance(pos)
	return (Camera.CFrame.Position - pos).Magnitude
end

function ESP.new(target)
	local self = setmetatable({}, ESP)
	self.Target = target
	self.Name = "ESP"
	self.Color = Color3.fromRGB(0, 255, 0)
	self.Thickness = 1
	self.Text = ""
	self.Enabled = true
	self.Drawings = {
		Tracer = Drawing.new("Line"),
		BoxOutline = Drawing.new("Square"),
		Box = Drawing.new("Square"),
		Name = Drawing.new("Text"),
		Distance = Drawing.new("Text"),
	}
	for _, v in pairs(self.Drawings) do
		v.Visible = false
	end
	self:_setup()
	return self
end

function ESP:_setup()
	RunService.RenderStepped:Connect(function()
		if not self.Enabled then return end
		local target = self.Target
		local pos
		if target:IsA("Model") then
			local primary = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
			if not primary then return end
			pos = primary.Position
		elseif target:IsA("BasePart") then
			pos = target.Position
		else
			return
		end

		local screenPos, onScreen = WorldToViewport(pos)
		if not onScreen then
			for _, v in pairs(self.Drawings) do v.Visible = false end
			return
		end

		-- Tracer
		local tracer = self.Drawings.Tracer
		tracer.Visible = true
		tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
		tracer.To = Vector2.new(screenPos.X, screenPos.Y)
		tracer.Color = self.Color
		tracer.Thickness = self.Thickness

		-- Box
		local box = self.Drawings.Box
		local outline = self.Drawings.BoxOutline
		local size = Vector2.new(50, 100) / (GetDistance(pos) / 15)

		box.Visible = true
		box.Position = Vector2.new(screenPos.X - size.X/2, screenPos.Y - size.Y/2)
		box.Size = size
		box.Color = self.Color
		box.Thickness = 1
		box.Transparency = 1
		box.Filled = false

		outline.Visible = true
		outline.Position = box.Position
		outline.Size = box.Size
		outline.Color = Color3.new(0, 0, 0)
		outline.Thickness = 3
		outline.Transparency = 1
		outline.Filled = false

		-- Name
		local nameText = self.Drawings.Name
		nameText.Visible = true
		nameText.Text = self.Text
		nameText.Position = Vector2.new(screenPos.X - size.X/2, screenPos.Y - size.Y/2 - 16)
		nameText.Color = self.Color
		nameText.Size = 14
		nameText.Center = false
		nameText.Outline = true

		-- Distance
		local distText = self.Drawings.Distance
		distText.Visible = true
		distText.Text = string.format("%.1f m", GetDistance(pos))
		distText.Position = Vector2.new(screenPos.X - size.X/2, screenPos.Y + size.Y/2 + 2)
		distText.Color = Color3.fromRGB(255, 255, 255)
		distText.Size = 14
		distText.Center = false
		distText.Outline = true
	end)
end

function ESP:SetName(text)
	self.Text = text
end

function ESP:SetColor(color)
	self.Color = color
end

function ESP:Destroy()
	for _, v in pairs(self.Drawings) do
		v:Remove()
	end
	self.Enabled = false
end

return ESP
