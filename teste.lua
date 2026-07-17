-- ============================================================
--      TESTE Hub  |  Developer: ??????????  |  💥
-- ============================================================

-- ============================================================
--  SERVICES
-- ============================================================
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting        = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService     = game:GetService("HttpService")
local VirtualUser     = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

-- ============================================================
--  WIND UI
-- ============================================================
local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

local Window = WindUI:CreateWindow({
    Title           = "TESTE",
    Icon            = "💥",
    Author          = "??????????",
    Folder          = "TESTE_Hub",
    Size            = UDim2.fromOffset(580, 460),
    Draggable       = true,
    LoadingEnabled  = true,
    LoadingTitle    = "TESTE Hub",
    LoadingSubtitle = "by ??????????",
    Theme           = "Default",
})

Window:LoadConfiguration()

-- ============================================================
--  TABS
-- ============================================================
local TabCombat      = Window:Tab({ Title = "Combat",      Icon = "sword"    })
local TabPerformance = Window:Tab({ Title = "Performance", Icon = "zap"      })
local TabPlayer      = Window:Tab({ Title = "Player",      Icon = "user"     })
local TabSettings    = Window:Tab({ Title = "Settings",    Icon = "settings" })

-- ============================================================
--  UTILS
-- ============================================================
local function Notify(title, content, duration)
    WindUI:Notify({ Title = title, Content = content, Duration = duration or 3 })
end

-- ============================================================
--  REMOTE EVENTS (Combat)
-- ============================================================
local HitEvent, CombatEvent
pcall(function()
    local Events = ReplicatedStorage:WaitForChild("Events", 10)
    HitEvent    = Events:WaitForChild("HitEvent",    10)
    CombatEvent = Events:WaitForChild("CombatEvent", 10)
end)

-- ============================================================
--  CLOSEST TARGET
-- ============================================================
local function GetClosestTarget()
    local closest, closestDist = nil, math.huge
    local lc  = LocalPlayer.Character                  ; if not lc  then return nil end
    local lrp = lc:FindFirstChild("HumanoidRootPart") ; if not lrp then return nil end
    local lPos = lrp.Position

    for _, p in Players:GetPlayers() do
        if p == LocalPlayer then continue end
        local c   = p.Character                             ; if not c   then continue end
        local hum = c:FindFirstChild("Humanoid")           ; if not hum or hum.Health <= 0 then continue end
        if c:FindFirstChild("ForceField") then continue end
        if c:GetAttribute("Blocking")     then continue end
        local rp  = c:FindFirstChild("HumanoidRootPart")  ; if not rp  then continue end
        local d   = (rp.Position - lPos).Magnitude         ; if d >= closestDist then continue end
        closestDist = d ; closest = p
    end

    return closest
end

-- ============================================================
--  ════════  COMBAT TAB  ════════
-- ============================================================

------------ Kill Aura ------------
getgenv().KillAuraEnabled = false
if getgenv().KillAuraConn then getgenv().KillAuraConn:Disconnect() end

TabCombat:Toggle({
    Title    = "Kill Aura",
    Default  = false,
    Callback = function(v)
        getgenv().KillAuraEnabled = v
        Notify("Kill Aura", v and "Ativada" or "Desativada", 2)

        if getgenv().KillAuraConn then
            getgenv().KillAuraConn:Disconnect()
            getgenv().KillAuraConn = nil
        end

        if v then
            getgenv().KillAuraConn = RunService.Heartbeat:Connect(function()
                if not getgenv().KillAuraEnabled or not HitEvent or not CombatEvent then return end
                local t  = GetClosestTarget() ; if not t  then return end
                local tc = t.Character        ; if not tc then return end
                CombatEvent:FireServer("Attack")
                HitEvent:FireServer({tc})
            end)
        end
    end,
})

------------ Loop Goto Nearest ------------
getgenv().GotoNearestEnabled = false
if getgenv().GotoNearestConn then getgenv().GotoNearestConn:Disconnect() end

TabCombat:Toggle({
    Title    = "Loop Goto Nearest Player",
    Default  = false,
    Callback = function(v)
        getgenv().GotoNearestEnabled = v
        Notify("Goto Nearest", v and "Ativado" or "Desativado", 2)

        if getgenv().GotoNearestConn then
            getgenv().GotoNearestConn:Disconnect()
            getgenv().GotoNearestConn = nil
        end

        if v then
            getgenv().GotoNearestConn = RunService.Heartbeat:Connect(function()
                if not getgenv().GotoNearestEnabled then return end
                local t   = GetClosestTarget()                       ; if not t   then return end
                local tc  = t.Character                              ; if not tc  then return end
                local lc  = LocalPlayer.Character                    ; if not lc  then return end
                local lrp = lc:FindFirstChild("HumanoidRootPart")   ; if not lrp then return end
                local trp = tc:FindFirstChild("HumanoidRootPart")   ; if not trp then return end
                lrp.CFrame = trp.CFrame + Vector3.new(0, 0, 3)
            end)
        end
    end,
})

------------ Specific Player ------------
TabCombat:Separator({ Title = "Specific Player" })

local SpecificTarget   = nil
local SpecificDropdown = TabCombat:Dropdown({
    Title    = "Select Player",
    Values   = {},
    Default  = nil,
    Callback = function(v) SpecificTarget = v end,
})

local function RefreshSpecificDropdown()
    local list = {}
    for _, p in Players:GetPlayers() do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    pcall(function() SpecificDropdown:Refresh(list) end)
end
RefreshSpecificDropdown()

getgenv().GotoSpecificEnabled = false
if getgenv().GotoSpecificConn then getgenv().GotoSpecificConn:Disconnect() end

TabCombat:Toggle({
    Title    = "Loop Goto Specific Player",
    Default  = false,
    Callback = function(v)
        getgenv().GotoSpecificEnabled = v
        Notify("Goto Specific", v and "Ativado" or "Desativado", 2)

        if getgenv().GotoSpecificConn then
            getgenv().GotoSpecificConn:Disconnect()
            getgenv().GotoSpecificConn = nil
        end

        if v then
            getgenv().GotoSpecificConn = RunService.Heartbeat:Connect(function()
                if not getgenv().GotoSpecificEnabled or not SpecificTarget then return end
                local t = Players:FindFirstChild(SpecificTarget)
                if not t then getgenv().GotoSpecificEnabled = false ; return end
                local tc  = t.Character                              ; if not tc  then return end -- aguarda renascer
                local lc  = LocalPlayer.Character                    ; if not lc  then return end
                local lrp = lc:FindFirstChild("HumanoidRootPart")   ; if not lrp then return end
                local trp = tc:FindFirstChild("HumanoidRootPart")   ; if not trp then return end
                lrp.CFrame = trp.CFrame + Vector3.new(0, 0, 3)
            end)
        end
    end,
})

-- ============================================================
--  ESP SYSTEM
-- ============================================================
TabCombat:Separator({ Title = "ESP" })

local EspObjects   = {}
local EspColor     = Color3.fromRGB(255, 50, 50)
local EspRainbow   = false
local EspTeamCheck = false

local EspFlags = {
    Box = false, Name = false, Distance = false,
    Tracer = false, Health = false, Chams = false, Highlight = false,
}

local function EspAnyActive()
    for _, v in pairs(EspFlags) do if v then return true end end
    return false
end

local function ClearESP(player)
    if EspObjects[player] then
        for _, obj in pairs(EspObjects[player]) do
            pcall(function() obj:Destroy() end)
        end
        EspObjects[player] = nil
    end
end

local function BuildESP(player)
    ClearESP(player)
    if player == LocalPlayer then return end

    local char = player.Character                          ; if not char then return end
    local hrp  = char:FindFirstChild("HumanoidRootPart")  ; if not hrp  then return end

    if EspTeamCheck and player.Team == LocalPlayer.Team then return end

    local objs = {} ; EspObjects[player] = objs

    -- Highlight / Chams
    if EspFlags.Chams or EspFlags.Highlight then
        local hl = Instance.new("Highlight")
        hl.Adornee             = char
        hl.FillColor           = EspColor
        hl.OutlineColor        = EspColor
        hl.FillTransparency    = EspFlags.Chams     and 0.45 or 1
        hl.OutlineTransparency = EspFlags.Highlight and 0    or 1
        hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent              = char
        objs.Highlight = hl
    end

    -- Billboard: Name / Distance / Health
    if EspFlags.Name or EspFlags.Distance or EspFlags.Health then
        local bb = Instance.new("BillboardGui")
        bb.Adornee     = hrp
        bb.Size        = UDim2.fromOffset(200, 72)
        bb.StudsOffset = Vector3.new(0, 3.5, 0)
        bb.AlwaysOnTop = true
        bb.Parent      = hrp
        objs.Billboard = bb

        local y = 0
        local function makeLabel(size, color)
            local lbl = Instance.new("TextLabel")
            lbl.Size                   = UDim2.new(1, 0, 0, size)
            lbl.Position               = UDim2.new(0, 0, 0, y)
            lbl.BackgroundTransparency = 1
            lbl.TextStrokeTransparency = 0.5
            lbl.Font                   = Enum.Font.GothamBold
            lbl.TextSize               = size
            lbl.TextColor3             = color or EspColor
            lbl.Parent                 = bb
            y += size + 2
            return lbl
        end

        if EspFlags.Name     then
            objs.NameLabel = makeLabel(13, EspColor)
            objs.NameLabel.Text = player.Name
        end
        if EspFlags.Distance then
            objs.DistLabel = makeLabel(11, Color3.fromRGB(220, 220, 220))
            objs.DistLabel.Text = "0 studs"
        end
        if EspFlags.Health   then
            objs.HpLabel = makeLabel(11, Color3.fromRGB(100, 255, 100))
            objs.HpLabel.Text = "HP: ?"
        end
    end

    -- Box (SelectionBox)
    if EspFlags.Box then
        local box = Instance.new("SelectionBox")
        box.Adornee             = char
        box.Color3              = EspColor
        box.LineThickness       = 0.04
        box.SurfaceTransparency = 1
        box.SurfaceColor3       = EspColor
        box.Parent              = Camera
        objs.Box = box
    end

    -- Tracer (dot at feet)
    if EspFlags.Tracer then
        local tb = Instance.new("BillboardGui")
        tb.Adornee     = hrp
        tb.Size        = UDim2.fromOffset(6, 6)
        tb.StudsOffset = Vector3.new(0, -3, 0)
        tb.AlwaysOnTop = true
        tb.Parent      = hrp
        local fr = Instance.new("Frame")
        fr.Size             = UDim2.fromScale(1, 1)
        fr.BackgroundColor3 = EspColor
        fr.BorderSizePixel  = 0
        fr.Parent           = tb
        Instance.new("UICorner", fr).CornerRadius = UDim.new(1, 0)
        objs.TracerGui = tb
    end
end

local function RebuildAllESP()
    for _, p in Players:GetPlayers() do
        ClearESP(p)
        if EspAnyActive() and p ~= LocalPlayer then BuildESP(p) end
    end
end

-- ESP Update loop
if getgenv().EspUpdateConn then getgenv().EspUpdateConn:Disconnect() end
getgenv().EspUpdateConn = RunService.Heartbeat:Connect(function()
    if not EspAnyActive() then return end

    local lc  = LocalPlayer.Character
    local lrp = lc and lc:FindFirstChild("HumanoidRootPart")
    local lPos = lrp and lrp.Position
    local t = tick()

    for _, p in Players:GetPlayers() do
        if p == LocalPlayer then continue end
        local objs = EspObjects[p] ; if not objs then continue end
        local char = p.Character   ; if not char then continue end
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChild("Humanoid")

        if EspRainbow then
            EspColor = Color3.fromHSV(t % 1, 1, 1)
            if objs.Highlight then objs.Highlight.FillColor = EspColor ; objs.Highlight.OutlineColor = EspColor end
            if objs.NameLabel then objs.NameLabel.TextColor3 = EspColor end
            if objs.Box       then objs.Box.Color3 = EspColor end
        end

        if objs.DistLabel and hrp and lPos then
            objs.DistLabel.Text = math.floor((hrp.Position - lPos).Magnitude) .. " studs"
        end

        if objs.HpLabel and hum then
            local hp, mhp = math.floor(hum.Health), math.floor(hum.MaxHealth)
            local r = hp / math.max(mhp, 1)
            objs.HpLabel.Text       = "HP: " .. hp .. "/" .. mhp
            objs.HpLabel.TextColor3 = Color3.fromRGB(
                math.floor(255 * (1 - r)), math.floor(255 * r), 50
            )
        end
    end
end)

-- Auto-rebuild ESP on CharacterAdded
local function SetupPlayerESP(p)
    if p == LocalPlayer then return end
    p.CharacterAdded:Connect(function()
        task.delay(0.5, function()
            if EspAnyActive() then BuildESP(p) end
        end)
    end)
end
for _, p in Players:GetPlayers() do SetupPlayerESP(p) end

-- ESP Toggles
for _, entry in {
    { key = "Box",       title = "Box ESP"       },
    { key = "Name",      title = "Name ESP"      },
    { key = "Distance",  title = "Distance ESP"  },
    { key = "Tracer",    title = "Tracer ESP"    },
    { key = "Health",    title = "Health ESP"    },
    { key = "Chams",     title = "Chams ESP"     },
    { key = "Highlight", title = "Highlight ESP" },
} do
    TabCombat:Toggle({
        Title    = entry.title,
        Default  = false,
        Callback = function(v)
            EspFlags[entry.key] = v
            Notify(entry.title, v and "ON" or "OFF", 2)
            RebuildAllESP()
        end,
    })
end

TabCombat:Toggle({
    Title    = "Team Check",
    Default  = false,
    Callback = function(v)
        EspTeamCheck = v
        Notify("Team Check", v and "ON" or "OFF", 2)
        RebuildAllESP()
    end,
})

TabCombat:Toggle({
    Title    = "Rainbow ESP",
    Default  = false,
    Callback = function(v)
        EspRainbow = v
        Notify("Rainbow ESP", v and "ON" or "OFF", 2)
    end,
})

-- ============================================================
--  ════════  PERFORMANCE TAB  ════════
-- ============================================================

local OrigBrightness = Lighting.Brightness
local OrigAmbient    = Lighting.Ambient
local OrigOutdoor    = Lighting.OutdoorAmbient
local OrigFogEnd     = Lighting.FogEnd
local OrigFogStart   = Lighting.FogStart
local OrigClockTime  = Lighting.ClockTime

TabPerformance:Toggle({
    Title    = "FullBright",
    Default  = false,
    Callback = function(v)
        Notify("FullBright", v and "ON" or "OFF", 2)
        Lighting.Brightness     = v and 10 or OrigBrightness
        Lighting.Ambient        = v and Color3.fromRGB(255, 255, 255) or OrigAmbient
        Lighting.OutdoorAmbient = v and Color3.fromRGB(255, 255, 255) or OrigOutdoor
    end,
})

TabPerformance:Toggle({
    Title    = "No Fog",
    Default  = false,
    Callback = function(v)
        Notify("No Fog", v and "ON" or "OFF", 2)
        Lighting.FogEnd   = v and 1e9 or OrigFogEnd
        Lighting.FogStart = v and 1e9 or OrigFogStart
    end,
})

TabPerformance:Toggle({
    Title    = "Night Mode",
    Default  = false,
    Callback = function(v)
        Notify("Night Mode", v and "ON" or "OFF", 2)
        Lighting.ClockTime = v and 0 or OrigClockTime
    end,
})

local OrigSky   = Lighting:FindFirstChildOfClass("Sky")
local CustomSky = nil

TabPerformance:Toggle({
    Title    = "Sky Changer (Space)",
    Default  = false,
    Callback = function(v)
        Notify("Sky Changer", v and "ON" or "OFF", 2)
        if v then
            if OrigSky then OrigSky.Parent = nil end
            CustomSky           = Instance.new("Sky")
            CustomSky.SkyboxBk  = "rbxassetid://159454299"
            CustomSky.SkyboxDn  = "rbxassetid://159454296"
            CustomSky.SkyboxFt  = "rbxassetid://159454293"
            CustomSky.SkyboxLf  = "rbxassetid://159454286"
            CustomSky.SkyboxRt  = "rbxassetid://159454300"
            CustomSky.SkyboxUp  = "rbxassetid://159454302"
            CustomSky.Parent    = Lighting
        else
            if CustomSky then CustomSky:Destroy() ; CustomSky = nil end
            if OrigSky   then OrigSky.Parent = Lighting end
        end
    end,
})

-- ============================================================
--  ════════  PLAYER TAB  ════════
-- ============================================================

-- Anti AFK
local AfkConn = nil
TabPlayer:Toggle({
    Title    = "Anti AFK",
    Default  = false,
    Callback = function(v)
        Notify("Anti AFK", v and "ON" or "OFF", 2)
        if AfkConn then AfkConn:Disconnect() ; AfkConn = nil end
        if v then
            AfkConn = RunService.Heartbeat:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end,
})

-- Rejoin
TabPlayer:Button({
    Title    = "Rejoin Server",
    Callback = function()
        Notify("Rejoin", "Reingressando...", 2)
        task.delay(1, function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end,
})

-- Server Hop
TabPlayer:Button({
    Title    = "Server Hop",
    Callback = function()
        Notify("Server Hop", "Procurando servidor...", 2)
        task.spawn(function()
            local ok, result = pcall(function()
                return HttpService:JSONDecode(
                    HttpService:GetAsync(
                        "https://games.roblox.com/v1/games/" .. game.PlaceId ..
                        "/servers/Public?sortOrder=Asc&limit=100"
                    )
                )
            end)
            if not ok or not result or not result.data then
                Notify("Server Hop", "Falha ao obter servidores.", 3) ; return
            end
            for _, sv in result.data do
                if sv.id ~= game.JobId and sv.playing < sv.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, sv.id, LocalPlayer)
                    return
                end
            end
            Notify("Server Hop", "Nenhum servidor disponivel.", 3)
        end)
    end,
})

TabPlayer:Separator({ Title = "Player Select" })

-- Player Dropdown (real-time)
local SelectedPlayer = nil
local PlayerDropdown = TabPlayer:Dropdown({
    Title    = "Select Player",
    Values   = {},
    Default  = nil,
    Callback = function(v) SelectedPlayer = v end,
})

local function RefreshPlayerDropdown()
    local list = {}
    for _, p in Players:GetPlayers() do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    pcall(function() PlayerDropdown:Refresh(list) end)
end
RefreshPlayerDropdown()

-- Consolidated PlayerAdded / PlayerRemoving
Players.PlayerAdded:Connect(function(p)
    SetupPlayerESP(p)
    task.wait(0.5)
    RefreshPlayerDropdown()
    RefreshSpecificDropdown()
end)

Players.PlayerRemoving:Connect(function(p)
    ClearESP(p)
    if SelectedPlayer == p.Name then SelectedPlayer = nil end
    if SpecificTarget == p.Name then
        SpecificTarget = nil
        getgenv().GotoSpecificEnabled = false
        Notify("Goto Specific", "Jogador saiu. Desativado.", 3)
    end
    task.wait(0.1)
    RefreshPlayerDropdown()
    RefreshSpecificDropdown()
end)

-- Spectate
TabPlayer:Button({
    Title    = "Spectate Player",
    Callback = function()
        if not SelectedPlayer then Notify("Spectate", "Selecione um jogador.", 3) ; return end
        local t = Players:FindFirstChild(SelectedPlayer)
        if not t or not t.Character then Notify("Spectate", "Jogador nao encontrado.", 3) ; return end
        local hum = t.Character:FindFirstChild("Humanoid") ; if not hum then return end
        Camera.CameraType    = Enum.CameraType.Follow
        Camera.CameraSubject = hum
        Notify("Spectate", "Espectando " .. SelectedPlayer, 2)
    end,
})

TabPlayer:Button({
    Title    = "Stop Spectate",
    Callback = function()
        Camera.CameraType = Enum.CameraType.Custom
        local lc = LocalPlayer.Character
        if lc then
            local hum = lc:FindFirstChild("Humanoid")
            if hum then Camera.CameraSubject = hum end
        end
        Notify("Spectate", "Camera restaurada.", 2)
    end,
})

TabPlayer:Button({
    Title    = "Teleport To Player",
    Callback = function()
        if not SelectedPlayer then Notify("Teleport", "Selecione um jogador.", 3) ; return end
        local t = Players:FindFirstChild(SelectedPlayer)
        if not t or not t.Character then Notify("Teleport", "Jogador nao encontrado.", 3) ; return end
        local lc  = LocalPlayer.Character                       ; if not lc  then return end
        local lrp = lc:FindFirstChild("HumanoidRootPart")      ; if not lrp then return end
        local trp = t.Character:FindFirstChild("HumanoidRootPart") ; if not trp then return end
        lrp.CFrame = trp.CFrame + Vector3.new(0, 0, 3)
        Notify("Teleport", "Teleportado para " .. SelectedPlayer, 2)
    end,
})

-- ============================================================
--  ════════  SETTINGS TAB  ════════
-- ============================================================

TabSettings:Toggle({
    Title    = "Tema Claro",
    Default  = false,
    Callback = function(v)
        pcall(function() Window:SetTheme(v and "Light" or "Default") end)
        Notify("Tema", v and "Tema Claro" or "Tema Escuro", 2)
    end,
})

TabSettings:Colorpicker({
    Title    = "Cor Principal (ESP)",
    Default  = Color3.fromRGB(255, 50, 50),
    Callback = function(v)
        EspColor = v
        RebuildAllESP()
        Notify("Cor Principal", "Atualizada.", 2)
    end,
})

TabSettings:Slider({
    Title    = "Transparencia da GUI",
    Value    = { Min = 0, Max = 1, Default = 0 },
    Callback = function(v)
        pcall(function() Window:SetTransparency(v) end)
    end,
})

TabSettings:Button({
    Title    = "Minimizar GUI",
    Callback = function()
        pcall(function() Window:ToggleMinimize() end)
    end,
})

TabSettings:Button({
    Title    = "Salvar Configuracoes",
    Callback = function()
        Window:SaveConfiguration()
        Notify("Settings", "Configuracoes salvas!", 3)
    end,
})

TabSettings:Button({
    Title    = "Unload GUI",
    Callback = function()
        Notify("Unload", "Descarregando hub...", 2)
        task.delay(1.5, function()
            -- Desconectar tudo
            if getgenv().KillAuraConn     then getgenv().KillAuraConn:Disconnect()     end
            if getgenv().GotoNearestConn  then getgenv().GotoNearestConn:Disconnect()  end
            if getgenv().GotoSpecificConn then getgenv().GotoSpecificConn:Disconnect() end
            if getgenv().EspUpdateConn    then getgenv().EspUpdateConn:Disconnect()    end
            if AfkConn then AfkConn:Disconnect() end

            -- Restaurar Lighting
            Lighting.Brightness     = OrigBrightness
            Lighting.Ambient        = OrigAmbient
            Lighting.OutdoorAmbient = OrigOutdoor
            Lighting.FogEnd         = OrigFogEnd
            Lighting.FogStart       = OrigFogStart
            Lighting.ClockTime      = OrigClockTime
            if CustomSky then CustomSky:Destroy() end
            if OrigSky   then OrigSky.Parent = Lighting end

            -- Limpar ESP
            for _, p in Players:GetPlayers() do ClearESP(p) end

            -- Destruir GUI
            pcall(function() Window:Destroy() end)
        end)
    end,
})