-- ESP/Main.lua

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/UI-LIBRARY-/main/UI%20library.lua"))()

local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/ESP-LIBRARY-/refs/heads/main/Library%20esp.lua"))()
local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/SCRIPT-DOORS/main/ESP/Config.lua"))()
local Core = loadstring(game:HttpGet("https://raw.githubusercontent.com/DH-SOARESE/SCRIPT-DOORS/main/ESP/Core.lua"))()

local Window = OrionLib:MakeWindow({
    Name = "DOORS ESP",
    HidePremium = true,
    SaveConfig = true,
    ConfigFolder = "DOORS-ESP-Config"
})

local Tab = Window:MakeTab({
    Name = "ESP Settings",
    Icon = "rbxassetid://6023426915",
    PremiumOnly = false
})

-- Flags de controle
local ESPMainEnabled = false

-- Função para atualizar ESPs
local function UpdateESPs()
    if not ESPMainEnabled then
        ESP.Enabled = false
        ESP:Clear()
        return
    end

    ESP.Enabled = true
    ESP:Clear()

    if Config.DoorESPEnabled then Core.AddDoorESP() else Core.RemoveESPByName("^Door %d+") end
    if Config.WardrobeESPEnabled then Core.AddWardrobeESP() else Core.RemoveESPByName("^Wardrobe$") end
    if Config.ToolshedESPEnabled then Core.AddToolshedESP() else Core.RemoveESPByName("^Toolshed$") end
    if Config.BedESPEnabled then Core.AddBedESP() else Core.RemoveESPByName("^Bed$") end
    if Config.KeyObtainESPEnabled then Core.AddKeyESP() else Core.RemoveESPByName("^Key$") end
    if Config.FigureESPEnabled then Core.AddFigureESP() else Core.RemoveESPByName("^Figure$") end
    if Config.SeekESPEnabled then Core.AddSeekESP() else Core.RemoveESPByName("^Seek$") end
    if Config.LeverESPEnabled then Core.AddLeverESP() else Core.RemoveESPByName("^Lever$") end
    if Config.BookESPEnabled then Core.AddBookESP() else Core.RemoveESPByName("^Book$") end
    -- Entidade ESP deve ser tratada à parte (pois envolve notificações)
end

-- Toggle principal ESP
Tab:AddToggle({
    Name = "Activate ESP",
    Default = false,
    Callback = function(enabled)
        ESPMainEnabled = enabled
        if enabled then
            UpdateESPs()

            -- Loop de refresh automático a cada 5 segundos
            task.spawn(function()
                while ESPMainEnabled do
                    task.wait(5)
                    if ESPMainEnabled then
                        UpdateESPs()
                    end
                end
            end)
        else
            ESP.Enabled = false
            ESP:Clear()
        end
    end
})

-- Toggles individuais (atualizam Config e chamam UpdateESPs)
local function AddIndividualToggle(name, configKey)
    Tab:AddToggle({
        Name = name,
        Default = Config[configKey],
        Callback = function(value)
            Config[configKey] = value
            if ESPMainEnabled then
                UpdateESPs()
            else
                Core.RemoveESPByName("^" .. name:gsub("%s","") .. "$") -- tenta remover caso desabilitado fora do ESP principal
            end
        end
    })
end

AddIndividualToggle("ESP Door", "DoorESPEnabled")
AddIndividualToggle("ESP Wardrobe", "WardrobeESPEnabled")
AddIndividualToggle("ESP Toolshed", "ToolshedESPEnabled")
AddIndividualToggle("ESP Bed", "BedESPEnabled")
AddIndividualToggle("ESP KeyObtain", "KeyObtainESPEnabled")
AddIndividualToggle("ESP Figure", "FigureESPEnabled")
AddIndividualToggle("ESP Seek", "SeekESPEnabled")
AddIndividualToggle("ESP Lever", "LeverESPEnabled")
AddIndividualToggle("ESP Book", "BookESPEnabled")

-- Controle especial para ESP Entity (Rush e Ambush)
Config.EntityESPEnabled = false
Tab:AddToggle({
    Name = "ESP Entity (Rush & Ambush)",
    Default = false,
    Callback = function(enabled)
        Config.EntityESPEnabled = enabled
        if not ESPMainEnabled or not enabled then
            Core.RemoveESPByName("^(Rush|Ambush)$")
        end
    end
})

-- Monitoramento e notificação para entidades (Rush e Ambush)
task.spawn(function()
    local notified = {}
    local ambushInitialPos = nil
    local ambushReturning = false
    local ambushMoving = false

    local ChatRemote = game.ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") 
        and game.ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")

    local function SendChatMessage(msg)
        if ChatRemote then
            ChatRemote:FireServer(msg, "All")
        end
    end

    while true do
        task.wait(0.25)
        if ESPMainEnabled and Config.EntityESPEnabled then
            for _, name in pairs({"RushMoving", "AmbushMoving"}) do
                local ent = workspace:FindFirstChild(name)
                if ent and not ent:FindFirstChild("_ESP_Highlight") then
                    local color = (name == "RushMoving") and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                    local label = (name == "RushMoving") and "Rush" or "Ambush"
                    local icon = (name == "RushMoving") and "rbxassetid://10716387808" or "rbxassetid://10722835155"

                    ESP:AddObject(ent, {
                        Name = label,
                        ShowName = true,
                        ShowDistance = true,
                        ShowOutline = true,
                        ShowTracer = true,
                        Color = color
                    })

                    if not notified[name] then
                        notified[name] = true
                        OrionLib:MakeNotification({
                            Name = "⚠ ENTIDADE DETECTADA",
                            Content = label .. " está vindo!",
                            Image = icon,
                            Time = 6
                        })

                        SendChatMessage("[ALERTA] " .. label .. " detectado! Se esconda!")
                    end

                    if name == "AmbushMoving" then
                        local rootPart = ent:IsA("Model") and (ent.PrimaryPart or ent:FindFirstChildWhichIsA("BasePart")) or ent
                        if rootPart then
                            local currentPos = rootPart.Position

                            if not ambushInitialPos then
                                ambushInitialPos = currentPos
                            end

                            local distanceFromInitial = (currentPos - ambushInitialPos).Magnitude

                            if distanceFromInitial <= 5 and not ambushReturning then
                                ambushReturning = true
                                ambushMoving = false
                                OrionLib:MakeNotification({
                                    Name = "⚠ AMBUSH PAROU",
                                    Content = "Sai do armário ou cama, aguarde o próximo alerta.",
                                    Image = "rbxassetid://10722835155",
                                    Time = 5
                                })
                                SendChatMessage("[INFO] Ambush parou temporariamente!")
                            elseif distanceFromInitial > 8 and not ambushMoving then
                                ambushMoving = true
                                ambushReturning = false
                                OrionLib:MakeNotification({
                                    Name = "⚠ ALERTA",
                                    Content = "Se esconda! Ambush está vindo!",
                                    Image = "rbxassetid://10722835155",
                                    Time = 5
                                })
                                SendChatMessage("[ALERTA] Ambush está se movendo novamente!")
                            end
                        end
                    end
                elseif not ent and notified[name] then
                    local label = (name == "RushMoving") and "Rush" or "Ambush"
                    local icon = (name == "RushMoving") and "rbxassetid://10716387808" or "rbxassetid://10722835155"

                    notified[name] = nil

                    if name == "AmbushMoving" then
                        ambushInitialPos = nil
                        ambushReturning = false
                        ambushMoving = false
                        OrionLib:MakeNotification({
                            Name = "⚠ AMBUSH FOI EMBORA",
                            Content = "Ambush desistiu, pode sair do esconderijo!",
                            Image = icon,
                            Time = 5
                        })
                        SendChatMessage("[SEGURO] Ambush foi embora!")
                    else
                        OrionLib:MakeNotification({
                            Name = "✅ SEGURO",
                            Content = label .. " se foi!",
                            Image = icon,
                            Time = 4
                        })
                        SendChatMessage("[SEGURO] " .. label .. " se foi!")
                    end
                end
            end
        else
            Core.RemoveESPByName("^(Rush|Ambush)$")
        end
    end
end)