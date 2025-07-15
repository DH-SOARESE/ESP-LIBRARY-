-- ESP/Core.lua

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local workspace = game:GetService("Workspace")

local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/ESP-LIBRARY-/refs/heads/main/Library%20esp.lua"))()
local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/SCRIPT-DOORS/main/ESP/Config.lua"))()

local Core = {}

Core.roomsPassed = {}
Core.currentRoomNum = 0

-- Atualiza número da sala atual do jogador
function Core.UpdateCurrentRoom()
	local attrRoom = LocalPlayer:GetAttribute("CurrentRoom")
	if attrRoom then
		Core.currentRoomNum = attrRoom
	else
		local nr = LocalPlayer:FindFirstChild("CurrentRoom")
		if nr and typeof(nr.Value) == "number" then
			Core.currentRoomNum = nr.Value
		else
			Core.currentRoomNum = 0
		end
	end

	if Core.currentRoomNum > 0 then
		Core.roomsPassed[Core.currentRoomNum] = true
	end
end

-- Observa mudanças de sala
Core.UpdateCurrentRoom()
LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(Core.UpdateCurrentRoom)
local nr = LocalPlayer:FindFirstChild("CurrentRoom")
if nr then nr.Changed:Connect(Core.UpdateCurrentRoom) end

-- Garante PrimaryPart para modelos
function Core.EnsurePrimaryPart(model)
	if not model.PrimaryPart then
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				pcall(function() model.PrimaryPart = part end)
				break
			end
		end
	end
end

-- Remove ESPs por nome (regex)
function Core.RemoveESPByName(namePattern)
	for _, obj in pairs(ESP.Objects) do
		if obj.Instance and obj.Name and tostring(obj.Name):match(namePattern) then
			ESP:RemoveObject(obj.Instance)
		end
	end
end

-- Remove ESPs de salas já passadas
function Core.RemoveOldRoomESPs()
	for _, obj in pairs(ESP.Objects) do
		if obj.Instance and obj.Name then
			local doorNum = tonumber(obj.Name:match("Door (%d+)"))
			if doorNum and Core.roomsPassed[doorNum] then
				ESP:RemoveObject(obj.Instance)
			end
		end
	end
end

-- Funções Add ESP (por tipo)
function Core.AddDoorESP()
	for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
		local num = tonumber(room.Name) or 0
		if num >= Core.currentRoomNum then
			local doorModel = room:FindFirstChild("Door")
			local door = doorModel and doorModel:FindFirstChild("Door")
			if door and not door:FindFirstChild("_ESP_Highlight") then
				ESP:AddObject(door, {
					Name = "Door " .. (num + 1),
					ShowName = true,
					ShowDistance = true,
					ShowOutline = true,
					Color = Color3.fromRGB(0, 255, 255)
				})
			end
		end
	end
end

function Core.AddWardrobeESP()
	for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
		local num = tonumber(room.Name) or 0
		if num >= Core.currentRoomNum then
			local assets = room:FindFirstChild("Assets")
			if assets then
				for _, obj in pairs(assets:GetChildren()) do
					if obj:IsA("Model") and obj.Name == "Wardrobe" and not obj:FindFirstChild("_ESP_Highlight") then
						Core.EnsurePrimaryPart(obj)
						ESP:AddObject(obj, {
							Name = "Wardrobe",
							ShowName = true,
							ShowDistance = false,
							ShowOutline = true,
							Color = Color3.fromRGB(170, 0, 255)
						})
					end
				end
			end
		end
	end
end

function Core.AddToolshedESP()
	for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
		local num = tonumber(room.Name) or 0
		if num >= Core.currentRoomNum then
			local assets = room:FindFirstChild("Assets")
			if assets then
				for _, obj in pairs(assets:GetChildren()) do
					if obj:IsA("Model") and obj.Name == "Toolshed" and not obj:FindFirstChild("_ESP_Highlight") then
						Core.EnsurePrimaryPart(obj)
						ESP:AddObject(obj, {
							Name = "Toolshed",
							ShowName = true,
							ShowDistance = false,
							ShowOutline = true,
							Color = Color3.fromRGB(170, 0, 255)
						})
					end
				end
			end
		end
	end
end

function Core.AddBedESP()
	for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
		local num = tonumber(room.Name) or 0
		if num >= Core.currentRoomNum then
			local assets = room:FindFirstChild("Assets")
			if assets then
				for _, obj in pairs(assets:GetChildren()) do
					if obj:IsA("Model") and obj.Name:lower() == "bed" and not obj:FindFirstChild("_ESP_Highlight") then
						Core.EnsurePrimaryPart(obj)
						ESP:AddObject(obj, {
							Name = "Bed",
							ShowName = true,
							ShowDistance = false,
							ShowOutline = true,
							Color = Color3.fromRGB(255, 128, 0)
						})
					end
				end
			end
		end
	end
end

function Core.AddKeyESP()
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and (obj.Name == "KeyObtain" or obj.Name == "Key") and not obj:FindFirstChild("_ESP_Highlight") then
			Core.EnsurePrimaryPart(obj)
			ESP:AddObject(obj, {
				Name = "Key",
				ShowName = true,
				ShowDistance = false,
				ShowOutline = true,
				ShowTracer = true,
				Color = Color3.fromRGB(255, 215, 0)
			})
		end
	end

	local room100 = workspace.CurrentRooms:FindFirstChild("100")
	if room100 then
		local ek = room100:FindFirstChild("Assets") and room100.Assets:FindFirstChild("ElectricalKeyObtain")
		if ek and not ek:FindFirstChild("_ESP_Highlight") then
			Core.EnsurePrimaryPart(ek)
			ESP:AddObject(ek, {
				Name = "Key",
				ShowName = true,
				ShowDistance = true,
				ShowOutline = true,
				ShowTracer = true,
				Color = Color3.fromRGB(255, 215, 0)
			})
		end
	end
end

function Core.AddFigureESP()
	for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
		local num = tonumber(room.Name) or 0
		if num >= Core.currentRoomNum then
			local setup = room:FindFirstChild("FigureSetup")
			local rig = setup and setup:FindFirstChild("FigureRig")
			if rig and not rig:FindFirstChild("_ESP_Highlight") then
				Core.EnsurePrimaryPart(rig)
				ESP:AddObject(rig, {
					Name = "Figure",
					ShowName = true,
					ShowDistance = true,
					ShowOutline = true,
					Color = Color3.fromRGB(255, 0, 255)
				})
			end
		end
	end
end

function Core.AddSeekESP()
	local seek = workspace:FindFirstChild("SeekMovingNewClone")
	if seek and not seek:FindFirstChild("_ESP_Highlight") then
		Core.EnsurePrimaryPart(seek)
		ESP:AddObject(seek, {
			Name = "Seek",
			ShowName = true,
			ShowDistance = true,
			ShowOutline = true,
			Color = Color3.fromRGB(255, 165, 0)
		})
	end
end

function Core.AddLeverESP()
	for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
		local num = tonumber(room.Name) or 0
		if num >= Core.currentRoomNum then
			local lever = room:FindFirstChild("Assets") and room.Assets:FindFirstChild("LeverForGate")
			if lever and not lever:FindFirstChild("_ESP_Highlight") then
				Core.EnsurePrimaryPart(lever)
				ESP:AddObject(lever, {
					Name = "Lever",
					ShowName = true,
					ShowDistance = true,
					ShowOutline = true,
					Color = Color3.fromRGB(0, 255, 0)
				})
			end
		end
	end
end

function Core.AddBookESP()
	for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
		local num = tonumber(room.Name) or 0
		if num >= Core.currentRoomNum then
			local shelves = room:FindFirstChild("Assets") and room.Assets:FindFirstChild("Bookshelves1")
			if shelves then
				for _, shelf in ipairs(shelves:GetChildren()) do
					local book = shelf:FindFirstChild("LiveHintBook")
					if book and not book:FindFirstChild("_ESP_Highlight") then
						Core.EnsurePrimaryPart(book)
						ESP:AddObject(book, {
							Name = "Book",
							ShowName = true,
							ShowDistance = true,
							ShowOutline = true,
							Color = Color3.fromRGB(0, 191, 255)
						})
					end
				end
			end
		end
	end
end

return Core