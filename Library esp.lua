-- ESP Library orientada a endereço de objetos
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ESP = {}
ESP.Enabled = true
ESP.Objects = {}

-- Configurações padrão
ESP.Options = {
	ShowLine = true,
	ShowBox = true,
	ShowName = true,
	ShowDistance = true,
	ShowOutline = true,
	Color = Color3.fromRGB(0, 255, 0),
	Font = Enum.Font.SourceSansBold,
	TextSize = 13,
}

-- Função para criar um desenho
local function CreateDrawing(class, properties)
	local obj = Drawing.new(class)
	for i, v in pairs(properties) do
		obj[i] = v
	end
	return obj
end

-- Adiciona um objeto na ESP
function ESP:Add(objRef, customName)
	if not objRef:IsA("BasePart") then return end

	local espItem = {
		Target = objRef,
		Name = customName or objRef.Name,

		Line = CreateDrawing("Line", {Thickness = 1.5, Transparency = 1, Color = self.Options.Color, Visible = false}),
		Box = CreateDrawing("Square", {Thickness = 1, Transparency = 1, Color = self.Options.Color, Visible = false}),
		Text = CreateDrawing("Text", {
			Size = self.Options.TextSize,
			Center = true,
			Outline = true,
			Font = self.Options.Font,
			Color = self.Options.Color,
			Visible = false,
		}),
		Outline = CreateDrawing("Square", {
			Thickness = 3,
			Transparency = 0.6,
			Color = Color3.new(0, 0, 0),
			Visible = false,
		})
	}

	table.insert(self.Objects, espItem)
end

-- Atualiza e desenha todos os ESPs
RunService.RenderStepped:Connect(function()
	if not ESP.Enabled then return end

	for _, esp in pairs(ESP.Objects) do
		local obj = esp.Target
		if obj and obj:IsDescendantOf(workspace) then
			local pos, onScreen = Camera:WorldToViewportPoint(obj.Position)
			if onScreen then
				local screenX, screenY = pos.X, pos.Y
				local distance = (Camera.CFrame.Position - obj.Position).Magnitude
				local sizeFactor = math.clamp(1000 / distance, 2, 50)

				-- Linha
				if ESP.Options.ShowLine then
					esp.Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
					esp.Line.To = Vector2.new(screenX, screenY)
					esp.Line.Visible = true
				else
					esp.Line.Visible = false
				end

				-- Caixa e contorno
				if ESP.Options.ShowBox then
					local boxSize = Vector2.new(sizeFactor, sizeFactor * 1.5)
					esp.Box.Size = boxSize
					esp.Box.Position = Vector2.new(screenX, screenY) - boxSize / 2
					esp.Box.Visible = true

					if ESP.Options.ShowOutline then
						esp.Outline.Size = boxSize + Vector2.new(4, 4)
						esp.Outline.Position = esp.Box.Position - Vector2.new(2, 2)
						esp.Outline.Visible = true
					else
						esp.Outline.Visible = false
					end
				else
					esp.Box.Visible = false
					esp.Outline.Visible = false
				end

				-- Nome + Distância
				if ESP.Options.ShowName or ESP.Options.ShowDistance then
					local text = ""
					if ESP.Options.ShowName then
						text = esp.Name
					end
					if ESP.Options.ShowDistance then
						text = text .. string.format(" [%.1fm]", distance)
					end
					esp.Text.Text = text
					esp.Text.Position = Vector2.new(screenX, screenY - (sizeFactor * 1.5) / 2 - 14)
					esp.Text.Visible = true
				else
					esp.Text.Visible = false
				end

			else
				esp.Line.Visible = false
				esp.Box.Visible = false
				esp.Text.Visible = false
				esp.Outline.Visible = false
			end
		end
	end
end)

-- Permite mudar opções externas
function ESP:SetOption(option, value)
	if self.Options[option] ~= nil then
		self.Options[option] = value
	end
end

-- Liga ou desliga o ESP
function ESP:SetEnabled(state)
	self.Enabled = state
end

return ESP
