--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.9) ~  Much Love, Ferib 

]]--

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/UI-LIBRARY/refs/heads/main/UI%20library.lua"))();
local Window = OrionLib:MakeWindow({Name="DOORS SCRIPT",HidePremium=false,SaveConfig=true,ConfigFolder="Ghost Script"});
OrionLib:MakeNotification({Name="DOORS SCRIPT!",Content="Bem-vindo ao script! Divirta-se!",Image="rbxassetid://4483345998",Time=10});
local Tab1 = Window:MakeTab({Name="Main",Icon="rbxassetid://6023426915",PremiumOnly=false});
local Tab2 = Window:MakeTab({Name="Visual",Icon="rbxassetid://13307406982",PremiumOnly=false});
local Misc = Window:MakeTab({Name="Misc",Icon="rbxassetid://12650016607",PremiumOnly=false});
local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;
local speedBoostValue = 0;
local boostTarget = nil;
local function UpdateSpeedBoost()
	boostTarget = workspace:FindFirstChild(LocalPlayer.Name);
	if boostTarget then
		pcall(function()
			local FlatIdent_95CAC = 0;
			while true do
				if (FlatIdent_95CAC == 0) then
					boostTarget:SetAttribute("SpeedBoost", speedBoostValue);
					boostTarget:SetAttribute("SpeedBoostBehind", speedBoostValue);
					break;
				end
			end
		end);
	end
end
Tab1:AddSlider({Name="SpeedBoost (Forï¿½a)",Min=0,Max=3.2,Default=0,Increment=0.1,ValueName="",Callback=function(value)
	speedBoostValue = value;
	UpdateSpeedBoost();
end});
local Players = game:GetService("Players");
local Workspace = game:GetService("Workspace");
local RunService = game:GetService("RunService");
local VirtualInputManager = game:GetService("VirtualInputManager");
local LocalPlayer = Players.LocalPlayer;
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui");
local autoInteractEnabled = false;
local autoInteractConnection = nil;
local keyPressedForDoor = false;
local PLAYER_FOLDER_NAME = LocalPlayer.Name;
local NOTIFICATION_ICON_ASSET_ID = "rbxassetid://7733964644";
local function simulateKeyPressE()
	local FlatIdent_76979 = 0;
	while true do
		if (FlatIdent_76979 == 1) then
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil);
			break;
		end
		if (FlatIdent_76979 == 0) then
			VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil);
			task.wait(0.05);
			FlatIdent_76979 = 1;
		end
	end
end
Tab1:AddToggle({Name="Auto Interact",Default=false,Callback=function(state)
	autoInteractEnabled = state;
	if state then
		local mainUI = PlayerGui:FindFirstChild("MainUI");
		local interactButton = mainUI and mainUI:FindFirstChild("MainFrame") and mainUI.MainFrame:FindFirstChild("MobileButtons") and mainUI.MainFrame.MobileButtons:FindFirstChild("InteractButton");
		local icon = interactButton and interactButton:FindFirstChild("Icon");
		if (not icon or not interactButton) then
			local FlatIdent_24A02 = 0;
			while true do
				if (FlatIdent_24A02 == 1) then
					return;
				end
				if (FlatIdent_24A02 == 0) then
					if Notify then
						Notify:Notify("Erro", "Elementos da UI de Interaï¿½ï¿½o Automï¿½tica nï¿½o encontrados.", 3, NOTIFICATION_ICON_ASSET_ID);
					end
					autoInteractEnabled = false;
					FlatIdent_24A02 = 1;
				end
			end
		end
		autoInteractConnection = RunService.RenderStepped:Connect(function()
			local playerFolder = Workspace:FindFirstChild(PLAYER_FOLDER_NAME);
			if (icon.ImageTransparency == 0) then
				local FlatIdent_89ECE = 0;
				local iconImage;
				local pressed;
				while true do
					if (FlatIdent_89ECE == 1) then
						if (iconImage:find("10482297351") and (interactButton.AbsoluteSize.Magnitude > 0)) then
							pressed = true;
						elseif iconImage:find("9873368030") then
							if (playerFolder and playerFolder:FindFirstChild("Key")) then
								if not keyPressedForDoor then
									pressed = true;
									keyPressedForDoor = true;
								end
							else
								pressed = true;
							end
						elseif iconImage:find("10058798678") then
							pressed = true;
						end
						if pressed then
							simulateKeyPressE();
						end
						break;
					end
					if (FlatIdent_89ECE == 0) then
						iconImage = icon.Image;
						pressed = false;
						FlatIdent_89ECE = 1;
					end
				end
			end
			if (keyPressedForDoor and (not playerFolder or not playerFolder:FindFirstChild("Key"))) then
				keyPressedForDoor = false;
			end
		end);
	else
		local FlatIdent_1743D = 0;
		while true do
			if (FlatIdent_1743D == 0) then
				if autoInteractConnection then
					local FlatIdent_7366E = 0;
					while true do
						if (0 == FlatIdent_7366E) then
							autoInteractConnection:Disconnect();
							autoInteractConnection = nil;
							break;
						end
					end
				end
				keyPressedForDoor = false;
				break;
			end
		end
	end
end});
local function EnableFullbright()
	local FlatIdent_43862 = 0;
	local Lighting;
	while true do
		if (FlatIdent_43862 == 1) then
			Lighting.OutdoorAmbient = Color3.new(0.7, 0.7, 0.7);
			Lighting.Brightness = 2;
			FlatIdent_43862 = 2;
		end
		if (FlatIdent_43862 == 3) then
			if not Lighting:FindFirstChild("_FullbrightBloom") then
				local FlatIdent_A36C = 0;
				local bloom;
				while true do
					if (FlatIdent_A36C == 1) then
						bloom.Intensity = 0.05;
						bloom.Threshold = 0.8;
						FlatIdent_A36C = 2;
					end
					if (FlatIdent_A36C == 0) then
						bloom = Instance.new("BloomEffect");
						bloom.Name = "_FullbrightBloom";
						FlatIdent_A36C = 1;
					end
					if (FlatIdent_A36C == 2) then
						bloom.Size = 56;
						bloom.Parent = Lighting;
						break;
					end
				end
			end
			break;
		end
		if (0 == FlatIdent_43862) then
			Lighting = game:GetService("Lighting");
			Lighting.Ambient = Color3.new(0.7, 0.7, 0.7);
			FlatIdent_43862 = 1;
		end
		if (FlatIdent_43862 == 2) then
			Lighting.FogEnd = 1000000000;
			Lighting.GlobalShadows = false;
			FlatIdent_43862 = 3;
		end
	end
end
local function DisableFullbright()
	local Lighting = game:GetService("Lighting");
	Lighting.Ambient = Color3.new(0, 0, 0);
	Lighting.OutdoorAmbient = Color3.new(0, 0, 0);
	Lighting.Brightness = 1;
	Lighting.FogEnd = 1000;
	Lighting.GlobalShadows = true;
	local bloom = Lighting:FindFirstChild("_FullbrightBloom");
	if bloom then
		bloom:Destroy();
	end
end
Tab2:AddToggle({Name="Fullbright",Default=false,Callback=function(v)
	if v then
		EnableFullbright();
	else
		DisableFullbright();
	end
end});
local currentFovValue = 70;
local bypassFovEnabled = false;
local camera = workspace.CurrentCamera;
local mt = getrawmetatable(game);
setreadonly(mt, false);
local oldNewIndex = mt.__newindex;
mt.__newindex = newcclosure(function(tbl, key, val)
	local FlatIdent_27957 = 0;
	while true do
		if (0 == FlatIdent_27957) then
			if ((tbl == camera) and (key == "FieldOfView") and bypassFovEnabled and (val ~= currentFovValue)) then
				return;
			end
			return oldNewIndex(tbl, key, val);
		end
	end
end);
setreadonly(mt, true);
task.spawn(function()
	while task.wait(0.05) do
		if (bypassFovEnabled and camera and (camera.FieldOfView ~= currentFovValue)) then
			camera.FieldOfView = currentFovValue;
		end
	end
end);
Tab2:AddToggle({Name="Bypass FOV",Default=false,Callback=function(v)
	bypassFovEnabled = v;
	if v then
		camera.FieldOfView = currentFovValue;
	end
end});
Tab2:AddSlider({Name="FOV Value",Min=70,Max=120,Default=70,Increment=1,ValueName="ï¿½",Callback=function(v)
	currentFovValue = v;
	if bypassFovEnabled then
		camera.FieldOfView = v;
	end
end});
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/ESP-LIBRARY-/refs/heads/main/Library%20esp.lua"))();
local DoorESPEnabled = false;
local WardrobeESPEnabled = false;
local BedESPEnabled = false;
local KeyObtainESPEnabled = false;
local EntityESPEnabled = false;
local ESPMainEnabled = false;
local ToolshedESPEnabled = false;
local roomsPassed = {};
local currentRoomNum = 0;
local function UpdateCurrentRoom()
	local FlatIdent_77C29 = 0;
	local attrRoom;
	while true do
		if (FlatIdent_77C29 == 0) then
			attrRoom = LocalPlayer:GetAttribute("CurrentRoom");
			if attrRoom then
				currentRoomNum = attrRoom;
			else
				local nr = LocalPlayer:FindFirstChild("CurrentRoom");
				if (nr and (typeof(nr.Value) == "number")) then
					currentRoomNum = nr.Value;
				else
					currentRoomNum = 0;
				end
			end
			FlatIdent_77C29 = 1;
		end
		if (FlatIdent_77C29 == 1) then
			if (currentRoomNum > 0) then
				roomsPassed[currentRoomNum] = true;
			end
			break;
		end
	end
end
UpdateCurrentRoom();
LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(UpdateCurrentRoom);
local nr = LocalPlayer:FindFirstChild("CurrentRoom");
if nr then
	nr.Changed:Connect(UpdateCurrentRoom);
end
local function EnsurePrimaryPart(model)
	if not model.PrimaryPart then
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				pcall(function()
					model.PrimaryPart = part;
				end);
				break;
			end
		end
	end
end
local function RemoveESPByName(namePattern)
	for _, obj in pairs(ESP.Objects) do
		if (obj.Instance and obj.Name and tostring(obj.Name):match(namePattern)) then
			ESP:RemoveObject(obj.Instance);
		end
	end
end
local function RemoveOldRoomESPs()
	for _, obj in pairs(ESP.Objects) do
		if (obj.Instance and obj.Name) then
			local FlatIdent_9147D = 0;
			local doorNum;
			while true do
				if (FlatIdent_9147D == 0) then
					doorNum = tonumber(obj.Name:match("Porta (%d+)"));
					if (doorNum and roomsPassed[doorNum]) then
						ESP:RemoveObject(obj.Instance);
					end
					break;
				end
			end
		end
	end
end
local function AddDoorESP()
	for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
		local FlatIdent_6A83E = 0;
		local roomNum;
		while true do
			if (FlatIdent_6A83E == 0) then
				roomNum = tonumber(room.Name) or 0;
				if (roomNum >= currentRoomNum) then
					local doorModel = room:FindFirstChild("Door");
					if (doorModel and doorModel:FindFirstChild("Door")) then
						local FlatIdent_2D2B8 = 0;
						local door;
						while true do
							if (FlatIdent_2D2B8 == 0) then
								door = doorModel:FindFirstChild("Door");
								if (door and not door:FindFirstChild("_ESP_Highlight")) then
									ESP:AddObject(door, {Name=("Door " .. (roomNum + 1)),ShowName=true,ShowDistance=true,ShowOutline=true,Color=Color3.fromRGB(0, 255, 255)});
								end
								break;
							end
						end
					end
				end
				break;
			end
		end
	end
end
local function AddWardrobeESP()
	for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
		local roomNum = tonumber(room.Name) or 0;
		if (roomNum >= currentRoomNum) then
			local FlatIdent_E0D0 = 0;
			local assets;
			while true do
				if (FlatIdent_E0D0 == 0) then
					assets = room:FindFirstChild("Assets");
					if assets then
						for _, obj in pairs(assets:GetChildren()) do
							if (obj:IsA("Model") and (obj.Name == "Wardrobe") and not obj:FindFirstChild("_ESP_Highlight")) then
								local FlatIdent_8DCA9 = 0;
								while true do
									if (FlatIdent_8DCA9 == 0) then
										EnsurePrimaryPart(obj);
										ESP:AddObject(obj, {Name="",ShowName=true,ShowDistance=false,ShowOutline=true,Color=Color3.fromRGB(170, 0, 255)});
										break;
									end
								end
							end
						end
					end
					break;
				end
			end
		end
	end
end
local function AddToolshedESP()
	for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
		local FlatIdent_39EBF = 0;
		local roomNum;
		while true do
			if (FlatIdent_39EBF == 0) then
				roomNum = tonumber(room.Name) or 0;
				if (roomNum >= currentRoomNum) then
					local FlatIdent_8BF78 = 0;
					local assets;
					while true do
						if (FlatIdent_8BF78 == 0) then
							assets = room:FindFirstChild("Assets");
							if assets then
								for _, obj in pairs(assets:GetChildren()) do
									if (obj:IsA("Model") and (obj.Name == "Toolshed") and not obj:FindFirstChild("_ESP_Highlight")) then
										EnsurePrimaryPart(obj);
										ESP:AddObject(obj, {Name="",ShowName=true,ShowDistance=false,ShowOutline=true,Color=Color3.fromRGB(170, 0, 255)});
									end
								end
							end
							break;
						end
					end
				end
				break;
			end
		end
	end
end
local function AddBedESP()
	for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
		local roomNum = tonumber(room.Name) or 0;
		if (roomNum >= currentRoomNum) then
			local FlatIdent_817B0 = 0;
			local assets;
			while true do
				if (FlatIdent_817B0 == 0) then
					assets = room:FindFirstChild("Assets");
					if assets then
						for _, obj in pairs(assets:GetChildren()) do
							if (obj:IsA("Model") and (obj.Name:lower() == "bed") and not obj:FindFirstChild("_ESP_Highlight")) then
								local FlatIdent_52551 = 0;
								while true do
									if (FlatIdent_52551 == 0) then
										EnsurePrimaryPart(obj);
										ESP:AddObject(obj, {Name="",ShowName=true,ShowDistance=false,ShowOutline=true,Color=Color3.fromRGB(255, 128, 0)});
										break;
									end
								end
							end
						end
					end
					break;
				end
			end
		end
	end
end
local function AddKeyObtainESP_Global()
	local FlatIdent_287B5 = 0;
	local room100;
	while true do
		if (FlatIdent_287B5 == 0) then
			for _, obj in pairs(workspace:GetDescendants()) do
				if (obj:IsA("Model") and ((obj.Name == "KeyObtain") or (obj.Name == "Key")) and not obj:FindFirstChild("_ESP_Highlight")) then
					EnsurePrimaryPart(obj);
					ESP:AddObject(obj, {Name="Key",ShowName=true,ShowDistance=false,ShowOutline=true,ShowTracer=true,Color=Color3.fromRGB(255, 215, 0)});
				end
			end
			room100 = workspace.CurrentRooms:FindFirstChild("100");
			FlatIdent_287B5 = 1;
		end
		if (FlatIdent_287B5 == 1) then
			if room100 then
				local FlatIdent_D79D = 0;
				local elecKey;
				while true do
					if (0 == FlatIdent_D79D) then
						elecKey = room100:FindFirstChild("Assets") and room100.Assets:FindFirstChild("ElectricalKeyObtain");
						if (elecKey and not elecKey:FindFirstChild("_ESP_Highlight")) then
							local FlatIdent_40B41 = 0;
							while true do
								if (FlatIdent_40B41 == 0) then
									EnsurePrimaryPart(elecKey);
									ESP:AddObject(elecKey, {Name="Key",ShowName=true,ShowDistance=true,ShowOutline=true,ShowTracer=true,Color=Color3.fromRGB(255, 215, 0)});
									break;
								end
							end
						end
						break;
					end
				end
			end
			break;
		end
	end
end
local function AddFigureESP()
	for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
		local FlatIdent_AC2F = 0;
		local roomNum;
		while true do
			if (FlatIdent_AC2F == 0) then
				roomNum = tonumber(room.Name) or 0;
				if (roomNum >= currentRoomNum) then
					local figureSetup = room:FindFirstChild("FigureSetup");
					if figureSetup then
						local figureRig = figureSetup:FindFirstChild("FigureRig");
						if (figureRig and not figureRig:FindFirstChild("_ESP_Highlight")) then
							EnsurePrimaryPart(figureRig);
							ESP:AddObject(figureRig, {Name="Figure",ShowName=true,ShowDistance=true,ShowOutline=true,Color=Color3.fromRGB(255, 0, 255)});
						end
					end
				end
				break;
			end
		end
	end
end
local function AddSeekESP()
	local FlatIdent_68E92 = 0;
	local seek;
	while true do
		if (FlatIdent_68E92 == 0) then
			seek = workspace:FindFirstChild("SeekMovingNewClone");
			if (seek and not seek:FindFirstChild("_ESP_Highlight")) then
				local FlatIdent_6C033 = 0;
				while true do
					if (0 == FlatIdent_6C033) then
						EnsurePrimaryPart(seek);
						ESP:AddObject(seek, {Name="Seek",ShowName=true,ShowDistance=true,ShowOutline=true,Color=Color3.fromRGB(255, 165, 0)});
						break;
					end
				end
			end
			break;
		end
	end
end
local function AddLeverESP()
	for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
		local FlatIdent_5B2CE = 0;
		local roomNum;
		while true do
			if (FlatIdent_5B2CE == 0) then
				roomNum = tonumber(room.Name) or 0;
				if (roomNum >= currentRoomNum) then
					local FlatIdent_2E9CB = 0;
					local assets;
					while true do
						if (FlatIdent_2E9CB == 0) then
							assets = room:FindFirstChild("Assets");
							if assets then
								local FlatIdent_29E69 = 0;
								local lever;
								while true do
									if (FlatIdent_29E69 == 0) then
										lever = assets:FindFirstChild("LeverForGate");
										if (lever and not lever:FindFirstChild("_ESP_Highlight")) then
											local FlatIdent_466B2 = 0;
											while true do
												if (FlatIdent_466B2 == 0) then
													EnsurePrimaryPart(lever);
													ESP:AddObject(lever, {Name="Lever",ShowName=true,ShowDistance=true,ShowOutline=true,Color=Color3.fromRGB(0, 255, 0)});
													break;
												end
											end
										end
										break;
									end
								end
							end
							break;
						end
					end
				end
				break;
			end
		end
	end
end
local function AddBookESP()
	for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
		local FlatIdent_1A54 = 0;
		local roomNum;
		while true do
			if (0 == FlatIdent_1A54) then
				roomNum = tonumber(room.Name) or 0;
				if (roomNum >= currentRoomNum) then
					local assets = room:FindFirstChild("Assets");
					if assets then
						local bookshelves = assets:FindFirstChild("Bookshelves1");
						if bookshelves then
							for _, book in ipairs(bookshelves:GetChildren()) do
								local FlatIdent_61800 = 0;
								local liveHintBook;
								while true do
									if (FlatIdent_61800 == 0) then
										liveHintBook = book:FindFirstChild("LiveHintBook");
										if (liveHintBook and not liveHintBook:FindFirstChild("_ESP_Highlight")) then
											local FlatIdent_90A41 = 0;
											while true do
												if (FlatIdent_90A41 == 0) then
													EnsurePrimaryPart(liveHintBook);
													ESP:AddObject(liveHintBook, {Name="Book",ShowName=true,ShowDistance=true,ShowOutline=true,Color=Color3.fromRGB(0, 191, 255)});
													break;
												end
											end
										end
										break;
									end
								end
							end
						end
					end
				end
				break;
			end
		end
	end
end
local FigureESPEnabled = false;
local SeekESPEnabled = false;
local LeverESPEnabled = false;
local BookESPEnabled = false;
local function UpdateESPs()
	if not ESPMainEnabled then
		return;
	end
	RemoveOldRoomESPs();
	if DoorESPEnabled then
		AddDoorESP();
	else
		RemoveESPByName("^Door %d+");
	end
	if WardrobeESPEnabled then
		AddWardrobeESP();
	else
		RemoveESPByName("^$");
	end
	if ToolshedESPEnabled then
		AddToolshedESP();
	else
		RemoveESPByName("^$");
	end
	if BedESPEnabled then
		AddBedESP();
	else
		RemoveESPByName("^$");
	end
	if KeyObtainESPEnabled then
		AddKeyObtainESP_Global();
	else
		RemoveESPByName("^Key$");
	end
	if FigureESPEnabled then
		AddFigureESP();
	else
		RemoveESPByName("^Figure$");
	end
	if SeekESPEnabled then
		AddSeekESP();
	else
		RemoveESPByName("^Seek$");
	end
	if LeverESPEnabled then
		AddLeverESP();
	else
		RemoveESPByName("^Lever$");
	end
	if BookESPEnabled then
		AddBookESP();
	else
		RemoveESPByName("^Book$");
	end
end
Tab2:AddToggle({Name="Active ESP",Default=false,Callback=function(enabled)
	local FlatIdent_6D9D2 = 0;
	while true do
		if (FlatIdent_6D9D2 == 0) then
			ESPMainEnabled = enabled;
			if enabled then
				local FlatIdent_6225E = 0;
				while true do
					if (FlatIdent_6225E == 1) then
						task.spawn(function()
							while ESPMainEnabled do
								local FlatIdent_21449 = 0;
								while true do
									if (FlatIdent_21449 == 0) then
										task.wait(5);
										if ESPMainEnabled then
											local FlatIdent_67691 = 0;
											while true do
												if (FlatIdent_67691 == 1) then
													ESP.Enabled = true;
													UpdateESPs();
													break;
												end
												if (FlatIdent_67691 == 0) then
													ESP.Enabled = false;
													ESP:Clear();
													FlatIdent_67691 = 1;
												end
											end
										end
										break;
									end
								end
							end
						end);
						break;
					end
					if (FlatIdent_6225E == 0) then
						ESP.Enabled = true;
						UpdateESPs();
						FlatIdent_6225E = 1;
					end
				end
			else
				ESP.Enabled = false;
				ESP:Clear();
			end
			break;
		end
	end
end});
Tab2:AddToggle({Name="ESP Door",Default=false,Callback=function(v)
	local FlatIdent_284EA = 0;
	while true do
		if (FlatIdent_284EA == 0) then
			DoorESPEnabled = v;
			if ESPMainEnabled then
				UpdateESPs();
			else
				RemoveESPByName("^Porta %d+");
			end
			break;
		end
	end
end});
Tab2:AddToggle({Name="ESP Wardrobe",Default=false,Callback=function(v)
	local FlatIdent_67517 = 0;
	while true do
		if (FlatIdent_67517 == 0) then
			WardrobeESPEnabled = v;
			if ESPMainEnabled then
				UpdateESPs();
			else
				RemoveESPByName("^Wardrobe$");
			end
			break;
		end
	end
end});
Tab2:AddToggle({Name="ESP Toolshed",Default=false,Callback=function(v)
	local FlatIdent_628E3 = 0;
	while true do
		if (FlatIdent_628E3 == 0) then
			ToolshedESPEnabled = v;
			if ESPMainEnabled then
				UpdateESPs();
			else
				RemoveESPByName("^Toolshed$");
			end
			break;
		end
	end
end});
Tab2:AddToggle({Name="ESP Bed",Default=false,Callback=function(v)
	local FlatIdent_2E34E = 0;
	while true do
		if (FlatIdent_2E34E == 0) then
			BedESPEnabled = v;
			if ESPMainEnabled then
				UpdateESPs();
			else
				RemoveESPByName("^Bed$");
			end
			break;
		end
	end
end});
Tab2:AddToggle({Name="ESP KeyObtain",Default=false,Callback=function(v)
	local FlatIdent_2A9F7 = 0;
	while true do
		if (FlatIdent_2A9F7 == 0) then
			KeyObtainESPEnabled = v;
			if ESPMainEnabled then
				UpdateESPs();
			else
				RemoveESPByName("^Key$");
			end
			break;
		end
	end
end});
Tab2:AddToggle({Name="ESP Entity",Default=false,Callback=function(v)
	local FlatIdent_91B54 = 0;
	while true do
		if (FlatIdent_91B54 == 0) then
			EntityESPEnabled = v;
			if (not ESPMainEnabled or not v) then
				RemoveESPByName("^(Rush|Ambush)$");
			end
			break;
		end
	end
end});
Tab2:AddToggle({Name="ESP Figure",Default=false,Callback=function(v)
	FigureESPEnabled = v;
	if ESPMainEnabled then
		UpdateESPs();
	else
		RemoveESPByName("^Figure$");
	end
end});
Tab2:AddToggle({Name="ESP Seek",Default=false,Callback=function(v)
	local FlatIdent_6679B = 0;
	while true do
		if (FlatIdent_6679B == 0) then
			SeekESPEnabled = v;
			if ESPMainEnabled then
				UpdateESPs();
			else
				RemoveESPByName("^Seek$");
			end
			break;
		end
	end
end});
Tab2:AddToggle({Name="ESP Lever",Default=false,Callback=function(v)
	local FlatIdent_63AE4 = 0;
	while true do
		if (FlatIdent_63AE4 == 0) then
			LeverESPEnabled = v;
			if ESPMainEnabled then
				UpdateESPs();
			else
				RemoveESPByName("^Lever$");
			end
			break;
		end
	end
end});
Tab2:AddToggle({Name="ESP Book",Default=false,Callback=function(v)
	local FlatIdent_869A9 = 0;
	while true do
		if (FlatIdent_869A9 == 0) then
			BookESPEnabled = v;
			if ESPMainEnabled then
				UpdateESPs();
			else
				RemoveESPByName("^Book$");
			end
			break;
		end
	end
end});
task.spawn(function()
	local FlatIdent_276C2 = 0;
	local notified;
	local ambushInitialPos;
	local ambushReturning;
	local ambushMoving;
	while true do
		if (FlatIdent_276C2 == 1) then
			ambushReturning = false;
			ambushMoving = false;
			FlatIdent_276C2 = 2;
		end
		if (FlatIdent_276C2 == 0) then
			notified = {};
			ambushInitialPos = nil;
			FlatIdent_276C2 = 1;
		end
		if (FlatIdent_276C2 == 2) then
			while task.wait(0.25) do
				if (ESPMainEnabled and EntityESPEnabled) then
					for _, name in pairs({"RushMoving","AmbushMoving"}) do
						local ent = workspace:FindFirstChild(name);
						if (ent and not ent:FindFirstChild("_ESP_Highlight")) then
							local FlatIdent_8B272 = 0;
							local color;
							local label;
							local icon;
							while true do
								if (FlatIdent_8B272 == 1) then
									icon = ((name == "RushMoving") and "rbxassetid://10716387808") or "rbxassetid://10722835155";
									ESP:AddObject(ent, {Name=label,ShowName=true,ShowDistance=true,ShowOutline=true,ShowTracer=true,Color=color});
									FlatIdent_8B272 = 2;
								end
								if (0 == FlatIdent_8B272) then
									color = ((name == "RushMoving") and Color3.fromRGB(255, 0, 0)) or Color3.fromRGB(0, 255, 0);
									label = ((name == "RushMoving") and "Rush") or "Ambush";
									FlatIdent_8B272 = 1;
								end
								if (2 == FlatIdent_8B272) then
									if not notified[name] then
										local FlatIdent_7063 = 0;
										while true do
											if (FlatIdent_7063 == 0) then
												notified[name] = true;
												OrionLib:MakeNotification({Name=" ENTIDADE DETECTADA",Content=(label .. " estï¿½ vindo!"),Image=icon,Time=6});
												break;
											end
										end
									end
									if (name == "AmbushMoving") then
										local FlatIdent_92F66 = 0;
										local rootPart;
										while true do
											if (FlatIdent_92F66 == 0) then
												rootPart = (ent:IsA("Model") and (ent.PrimaryPart or ent:FindFirstChildWhichIsA("BasePart"))) or ent;
												if rootPart then
													local FlatIdent_957A4 = 0;
													local currentPos;
													local distanceFromInitial;
													while true do
														if (FlatIdent_957A4 == 0) then
															currentPos = rootPart.Position;
															if not ambushInitialPos then
																ambushInitialPos = currentPos;
															end
															FlatIdent_957A4 = 1;
														end
														if (FlatIdent_957A4 == 1) then
															distanceFromInitial = (currentPos - ambushInitialPos).Magnitude;
															if ((distanceFromInitial <= 5) and not ambushReturning) then
																ambushReturning = true;
																ambushMoving = false;
																OrionLib:MakeNotification({Name=" AMBUSH PAROU",Content="Sai do armï¿½rio ou cama, aguarde o prï¿½ximo alerta.",Image="rbxassetid://10722835155",Time=5});
															elseif ((distanceFromInitial > 8) and not ambushMoving) then
																local FlatIdent_7126B = 0;
																while true do
																	if (0 == FlatIdent_7126B) then
																		ambushMoving = true;
																		ambushReturning = false;
																		FlatIdent_7126B = 1;
																	end
																	if (FlatIdent_7126B == 1) then
																		OrionLib:MakeNotification({Name=" ALERTA",Content="Se esconda! Ambush estï¿½ vindo!",Image="rbxassetid://10722835155",Time=5});
																		break;
																	end
																end
															end
															break;
														end
													end
												end
												break;
											end
										end
									end
									break;
								end
							end
						elseif (not ent and notified[name]) then
							local FlatIdent_21CA5 = 0;
							local label;
							local icon;
							while true do
								if (FlatIdent_21CA5 == 0) then
									label = ((name == "RushMoving") and "Rush") or "Ambush";
									icon = ((name == "RushMoving") and "rbxassetid://10716387808") or "rbxassetid://10722835155";
									FlatIdent_21CA5 = 1;
								end
								if (FlatIdent_21CA5 == 1) then
									notified[name] = nil;
									if (name == "AmbushMoving") then
										local FlatIdent_803FB = 0;
										while true do
											if (FlatIdent_803FB == 1) then
												ambushMoving = false;
												OrionLib:MakeNotification({Name=" AMBUSH FOI EMBORA",Content="Ambush desistiu, pode sair do esconderijo!",Image=icon,Time=5});
												break;
											end
											if (FlatIdent_803FB == 0) then
												ambushInitialPos = nil;
												ambushReturning = false;
												FlatIdent_803FB = 1;
											end
										end
									else
										OrionLib:MakeNotification({Name=" SEGURO",Content=(label .. " se foi!"),Image=icon,Time=4});
									end
									break;
								end
							end
						end
					end
				else
					RemoveESPByName("^(Rush|Ambush)$");
				end
			end
			break;
		end
	end
end);
local AntiScreechEnabled = false;
Misc:AddToggle({Name="Anti-Screech",Default=false,Callback=function(v)
	AntiScreechEnabled = v;
end});
local function FindScreechRecursively(parent)
	local FlatIdent_10DED = 0;
	while true do
		if (FlatIdent_10DED == 0) then
			for _, child in ipairs(parent:GetChildren()) do
				local FlatIdent_30F75 = 0;
				local found;
				while true do
					if (0 == FlatIdent_30F75) then
						if (child.Name == "Screech") then
							return child;
						end
						found = FindScreechRecursively(child);
						FlatIdent_30F75 = 1;
					end
					if (1 == FlatIdent_30F75) then
						if found then
							return found;
						end
						break;
					end
				end
			end
			return nil;
		end
	end
end
task.spawn(function()
	while true do
		if AntiScreechEnabled then
			local FlatIdent_360E8 = 0;
			local screech;
			while true do
				if (FlatIdent_360E8 == 0) then
					screech = FindScreechRecursively(workspace);
					if screech then
						local FlatIdent_7B2D6 = 0;
						while true do
							if (FlatIdent_7B2D6 == 0) then
								OrionLib:MakeNotification({Name="Screech Detectado!",Content="O Screech apareceu no jogo!",Image="rbxassetid://4483345998",Time=4});
								while screech and screech.Parent and AntiScreechEnabled do
									local FlatIdent_6DFD9 = 0;
									while true do
										if (FlatIdent_6DFD9 == 1) then
											screech = FindScreechRecursively(workspace);
											break;
										end
										if (FlatIdent_6DFD9 == 0) then
											screech:Destroy();
											task.wait(0.1);
											FlatIdent_6DFD9 = 1;
										end
									end
								end
								FlatIdent_7B2D6 = 1;
							end
							if (FlatIdent_7B2D6 == 1) then
								OrionLib:MakeNotification({Name="Anti-Screech",Content="Screech removido automaticamente!",Image="rbxassetid://4483345998",Time=4});
								break;
							end
						end
					end
					break;
				end
			end
		end
		task.wait(0.5);
	end
end);
OrionLib:Init();