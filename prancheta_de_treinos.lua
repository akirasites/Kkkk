local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local ENV = getgenv and getgenv() or _G

if ENV.PranchataTreinos and ENV.PranchataTreinos.Destroy then
    pcall(ENV.PranchataTreinos.Destroy)
end

local FOLDER = "Prancheta_de_Treinos"
local FILE = FOLDER .. "/dados.json"

local customTexts = {}
local customCommands = {}

local function saveData()
    if not (writefile and makefolder) then return false end

    local ok = pcall(function()
        if not isfolder(FOLDER) then
            makefolder(FOLDER)
        end

        writefile(FILE, HttpService:JSONEncode({
            texts = customTexts,
            commands = customCommands
        }))
    end)

    return ok
end

local function loadData()
    if not (readfile and isfile) then return end

    local ok, data = pcall(function()
        if not isfile(FILE) then return nil end
        return HttpService:JSONDecode(readfile(FILE))
    end)

    if ok and type(data) == "table" then
        customTexts = type(data.texts) == "table" and data.texts or {}
        customCommands = type(data.commands) == "table" and data.commands or {}
    end
end

loadData()

local texts = {
    {
        category = "APRESENTAÇÃO",
        items = {
            ";hy Olá, meu nome é shanks_9076, e serei o auxiliar de vocês.",
            ";hy Olá, meu nome é shanks_9076, e serei o instrutor de vocês."
        }
    },
    {
        category = "ORIENTAÇÕES",
        items = {
            ";hy Quem eu tocar deverá dirigir-se à linha verde.",
            ";hy Quando terminarem, aguardem até que eu dê o ponto. Logo após, dirijam-se ao meu clone, que estará na linha vermelha."
        }
    },
    {
        category = "MARCHA",
        items = {
            ";hr PREPARAR PARA MARCHAR!",
            ";hr MARCHEM!",
            ";hr AUTO!"
        }
    },
    {
        category = "APROVADOS",
        items = {
            ";hy Aprovados, dirijam-se à STS Central e permaneçam no portão, aguardando novas instruções."
        }
    },
    {
        category = "COMANDOS PP",
        items = {
            ";hy PPA!",
            ";hy PPF!",
            ";hy PPO!"
        }
    }
}

-- Comandos de título que precisam de seleção de player
local titleCommands = {
    {label = "TITLEG APROVADO", cmd = "titleg", suffix = "Aprovado!!"},
    {label = "TITLEY AUXILIAR", cmd = "titley", suffix = "AUXILIAR!!"},
    {label = "TITLER INSTRUTOR", cmd = "titler", suffix = "INSTRUTOR!!"}
}

local purple = Color3.fromRGB(130, 85, 220)
local dark = Color3.fromRGB(10, 10, 14)
local panel = Color3.fromRGB(21, 21, 29)
local cardColor = Color3.fromRGB(29, 29, 39)
local white = Color3.fromRGB(240, 240, 245)
local green = Color3.fromRGB(38, 110, 75)
local gray = Color3.fromRGB(130, 130, 140)

local gui = Instance.new("ScreenGui")
gui.Name = "PranchetaDeTreinos"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local parentGui = CoreGui
pcall(function()
    if gethui then
        parentGui = gethui()
    end
end)

gui.Parent = parentGui

-- ===== JANELA PRINCIPAL (compacta, mobile-friendly) =====
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(265, 340)
main.Position = UDim2.new(0.5, -132, 0.5, -170)
main.BackgroundColor3 = dark
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Visible = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local outline = Instance.new("UIStroke")
outline.Color = purple
outline.Thickness = 1
outline.Parent = main

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -62, 0, 32)
header.Position = UDim2.fromOffset(10, 0)
header.BackgroundTransparency = 1
header.Text = "PRANCHETA"
header.TextColor3 = white
header.Font = Enum.Font.GothamBold
header.TextSize = 12
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = main

-- Botão minimizar
local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(24, 24)
minimize.Position = UDim2.new(1, -58, 0, 4)
minimize.BackgroundColor3 = cardColor
minimize.Text = "-"
minimize.TextColor3 = white
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 16
minimize.Parent = main
Instance.new("UICorner", minimize).CornerRadius = UDim.new(0, 6)

-- Botão fechar
local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(24, 24)
close.Position = UDim2.new(1, -30, 0, 4)
close.BackgroundColor3 = cardColor
close.Text = "X"
close.TextColor3 = white
close.Font = Enum.Font.GothamBold
close.TextSize = 11
close.Parent = main
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)

local tabs = Instance.new("Frame")
tabs.Size = UDim2.new(1, -14, 0, 28)
tabs.Position = UDim2.fromOffset(7, 36)
tabs.BackgroundTransparency = 1
tabs.Parent = main

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 4)
tabLayout.Parent = tabs

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -14, 1, -72)
content.Position = UDim2.fromOffset(7, 68)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = purple
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.CanvasSize = UDim2.new()
content.Parent = main

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 6)
list.Parent = content

-- ===== BUBBLE (ícone flutuante quando minimizado) =====
local bubble = Instance.new("ImageButton")
bubble.Size = UDim2.fromOffset(52, 52)
bubble.Position = UDim2.new(0.5, -26, 0.5, -26)
bubble.BackgroundColor3 = dark
bubble.Image = ""
bubble.Visible = false
bubble.Parent = gui
Instance.new("UICorner", bubble).CornerRadius = UDim.new(1, 0)

local bubbleStroke = Instance.new("UIStroke")
bubbleStroke.Color = purple
bubbleStroke.Thickness = 2
bubbleStroke.Parent = bubble

local bubbleLabel = Instance.new("TextLabel")
bubbleLabel.Size = UDim2.new(1, 0, 1, 0)
bubbleLabel.BackgroundTransparency = 1
bubbleLabel.Text = "PT"
bubbleLabel.TextColor3 = white
bubbleLabel.Font = Enum.Font.GothamBold
bubbleLabel.TextSize = 14
bubbleLabel.Parent = bubble

local function clear()
    for _, v in ipairs(content:GetChildren()) do
        if v:IsA("GuiObject") then
            v:Destroy()
        end
    end
end

local function makeButton(parent, name, color, callback)
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = color
    b.Text = name
    b.TextColor3 = white
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    b.Activated:Connect(callback)
    return b
end

local function makeLabel(value)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -5, 0, 20)
    l.BackgroundTransparency = 1
    l.Text = value
    l.TextColor3 = purple
    l.Font = Enum.Font.GothamBold
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = content
end

local function sendMessage(message)
    local channels = TextChatService:FindFirstChild("TextChannels")
    if not channels then return end

    local channel = channels:FindFirstChild("RBXGeneral")

    if not channel then
        for _, v in ipairs(channels:GetChildren()) do
            if v:IsA("TextChannel") then
                channel = v
                break
            end
        end
    end

    if channel and channel:IsA("TextChannel") then
        local ok, err = pcall(function()
            channel:SendAsync(message)
        end)

        if not ok then
            warn("[Prancheta] Erro ao enviar:", err)
        end
    end
end

local function copyText(value)
    if setclipboard then
        local ok = pcall(setclipboard, value)
        if ok then return end
    end

    local popup = Instance.new("Frame")
    popup.Size = UDim2.fromOffset(235, 105)
    popup.Position = UDim2.new(0.5, -117, 0.5, -52)
    popup.BackgroundColor3 = panel
    popup.ZIndex = 10
    popup.Parent = main
    Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 8)

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -16, 0, 58)
    box.Position = UDim2.fromOffset(8, 8)
    box.BackgroundColor3 = dark
    box.TextColor3 = white
    box.Text = value
    box.TextWrapped = true
    box.MultiLine = true
    box.ClearTextOnFocus = false
    box.Font = Enum.Font.Gotham
    box.TextSize = 10
    box.ZIndex = 11
    box.Parent = popup
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

    local closePopup = makeButton(popup, "FECHAR", purple, function()
        popup:Destroy()
    end)
    closePopup.Size = UDim2.new(1, -16, 0, 25)
    closePopup.Position = UDim2.fromOffset(8, 72)
    closePopup.ZIndex = 11

    box:CaptureFocus()
end

local function makeCard(value, removable, removeCallback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -5, 0, removable and 72 or 66)
    card.BackgroundColor3 = cardColor
    card.Parent = content
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 7)

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, -14, 0, 30)
    txt.Position = UDim2.fromOffset(7, 3)
    txt.BackgroundTransparency = 1
    txt.Text = value
    txt.TextColor3 = white
    txt.Font = Enum.Font.Gotham
    txt.TextSize = 9
    txt.TextWrapped = true
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.Parent = card

    local btnWidth = removable and 58 or 88

    local copy = makeButton(card, "COPIAR", purple, function()
        copyText(value)
    end)
    copy.Size = UDim2.fromOffset(btnWidth, 25)
    copy.Position = UDim2.fromOffset(7, 36)

    local send = makeButton(card, "ENVIAR", green, function()
        sendMessage(value)
    end)
    send.Size = UDim2.fromOffset(btnWidth, 25)
    send.Position = UDim2.fromOffset(7 + btnWidth + 4, 36)

    if removable then
        local remove = makeButton(card, "DEL", Color3.fromRGB(125, 45, 55), removeCallback)
        remove.Size = UDim2.fromOffset(50, 25)
        remove.Position = UDim2.new(1, -57, 0, 36)
    end
end

-- Dropdown genérico; se collapseParent for passado, redimensiona o container pai (usado dentro de cards)
local function dropdown(parent, options, callback, placeholderText)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -5, 0, 30)
    holder.BackgroundColor3 = dark
    holder.ClipsDescendants = true
    holder.ZIndex = 5
    holder.Parent = parent
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 6)

    local current = options[1]

    local select = Instance.new("TextButton")
    select.Size = UDim2.new(1, -8, 0, 26)
    select.Position = UDim2.fromOffset(4, 2)
    select.BackgroundColor3 = cardColor
    select.Text = tostring(current or placeholderText or "Selecione") .. "  v"
    select.TextColor3 = white
    select.Font = Enum.Font.Gotham
    select.TextSize = 10
    select.ZIndex = 5
    select.Parent = holder
    select.ClipsDescendants = true
    select.TextTruncate = Enum.TextTruncate.AtEnd

    Instance.new("UICorner", select).CornerRadius = UDim.new(0, 5)

    local opened = false
    local optionButtons = {}

    local function closeDropdown()
        opened = false
        holder.Size = UDim2.new(1, -5, 0, 30)
        for _, btn in ipairs(optionButtons) do
            btn:Destroy()
        end
        optionButtons = {}
    end

    select.Activated:Connect(function()
        opened = not opened

        closeDropdown()

        if opened then
            opened = true
            local maxVisible = 5
            local shown = math.min(#options, maxVisible)
            holder.Size = UDim2.new(1, -5, 0, 30 + shown * 24)

            local optList = Instance.new("ScrollingFrame")
            optList.Name = "OptList"
            optList.Size = UDim2.new(1, -8, 0, shown * 24)
            optList.Position = UDim2.fromOffset(4, 30)
            optList.BackgroundTransparency = 1
            optList.BorderSizePixel = 0
            optList.ScrollBarThickness = 2
            optList.ScrollBarImageColor3 = purple
            optList.CanvasSize = UDim2.new(0, 0, 0, #options * 24)
            optList.ZIndex = 5
            optList.Parent = holder
            table.insert(optionButtons, optList)

            for i, option in ipairs(options) do
                local opt = Instance.new("TextButton")
                opt.Name = "Option"
                opt.Size = UDim2.new(1, -4, 0, 22)
                opt.Position = UDim2.fromOffset(0, (i - 1) * 24)
                opt.BackgroundColor3 = cardColor
                opt.Text = tostring(option)
                opt.TextColor3 = white
                opt.Font = Enum.Font.Gotham
                opt.TextSize = 9
                opt.ZIndex = 5
                opt.Parent = optList

                opt.Activated:Connect(function()
                    current = option
                    select.Text = tostring(option) .. "  v"
                    closeDropdown()
                    callback(option)
                end)
            end
        end
    end)

    callback(current)

    return holder, function() return current end
end

local function getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        table.insert(names, p.Name)
    end
    table.sort(names)
    if #names == 0 then
        table.insert(names, LocalPlayer.Name)
    end
    return names
end

-- Card de comando de título com dropdown de player embutido
local function makeTitleCommandCard(def)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -5, 0, 108)
    card.BackgroundColor3 = cardColor
    card.Parent = content
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 7)

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, -14, 0, 18)
    txt.Position = UDim2.fromOffset(7, 5)
    txt.BackgroundTransparency = 1
    txt.Text = def.label
    txt.TextColor3 = white
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 10
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.Parent = card

    local ddHolder = Instance.new("Frame")
    ddHolder.Size = UDim2.new(1, -14, 0, 30)
    ddHolder.Position = UDim2.fromOffset(7, 25)
    ddHolder.BackgroundTransparency = 1
    ddHolder.Parent = card

    local getSelected
    local _, getter = dropdown(ddHolder, getPlayerNames(), function() end, "Selecione o player")
    getSelected = getter

    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.fromOffset(26, 26)
    refreshBtn.Position = UDim2.new(1, -26, 0, 2)
    refreshBtn.BackgroundColor3 = dark
    refreshBtn.Text = "⟳"
    refreshBtn.TextColor3 = purple
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.TextSize = 13
    refreshBtn.ZIndex = 6
    refreshBtn.Parent = ddHolder
    Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 5)

    refreshBtn.Activated:Connect(function()
        for _, c in ipairs(ddHolder:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        local _, newGetter = dropdown(ddHolder, getPlayerNames(), function() end, "Selecione o player")
        getSelected = newGetter
        refreshBtn.Parent = ddHolder
    end)

    local send = makeButton(card, "ENVIAR ;" .. def.cmd, green, function()
        local player = getSelected and getSelected() or LocalPlayer.Name
        sendMessage(";" .. def.cmd .. " " .. tostring(player) .. " " .. def.suffix)
    end)
    send.Size = UDim2.new(1, -14, 0, 28)
    send.Position = UDim2.fromOffset(7, 76)
end

local function showTexts()
    clear()

    for _, category in ipairs(texts) do
        makeLabel(category.category)

        for _, message in ipairs(category.items) do
            makeCard(message)
        end
    end

    if #customTexts > 0 then
        makeLabel("TEXTOS PERSONALIZADOS")

        for i, message in ipairs(customTexts) do
            local index = i
            makeCard(message, true, function()
                table.remove(customTexts, index)
                saveData()
                showTexts()
            end)
        end
    end
end

local function showCommands()
    clear()

    makeLabel("COMANDOS")

    makeCard(";clone me")
    makeCard(";clr")

    makeLabel("TÍTULOS COM PLAYER")

    for _, def in ipairs(titleCommands) do
        makeTitleCommandCard(def)
    end

    makeLabel("DISTÂNCIA DO CD")

    local cdHolder = Instance.new("Frame")
    cdHolder.Size = UDim2.new(1, -5, 0, 30)
    cdHolder.BackgroundTransparency = 1
    cdHolder.Parent = content

    local cdValue = 10
    local _, getCd = dropdown(cdHolder, {10, 15, 20, 25, 30, 35, 40, 45, 50}, function(value)
        cdValue = value
    end)

    local cd = makeButton(content, "ENVIAR ;cd", purple, function()
        local value = getCd and getCd() or cdValue
        sendMessage(";cd " .. tostring(value))
    end)
    cd.Size = UDim2.new(1, -5, 0, 30)
end

local function makeInput(placeholder)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -5, 0, 34)
    box.BackgroundColor3 = cardColor
    box.TextColor3 = white
    box.PlaceholderColor3 = gray
    box.PlaceholderText = placeholder
    box.Text = ""
    box.Font = Enum.Font.Gotham
    box.TextSize = 10
    box.ClearTextOnFocus = false
    box.Parent = content
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    return box
end

local function showSettings()
    clear()

    makeLabel("ADICIONAR TEXTO")

    local textInput = makeInput("Digite seu novo texto...")

    local saveText = makeButton(content, "SALVAR TEXTO", purple, function()
        local value = textInput.Text

        if value ~= "" then
            table.insert(customTexts, value)
            textInput.Text = ""
            saveData()
            showSettings()
        end
    end)
    saveText.Size = UDim2.new(1, -5, 0, 30)

    makeLabel("ADICIONAR COMANDO")

    local commandInput = makeInput("Digite seu novo comando...")

    local saveCommand = makeButton(content, "SALVAR COMANDO", purple, function()
        local value = commandInput.Text

        if value ~= "" then
            table.insert(customCommands, value)
            commandInput.Text = ""
            saveData()
            showSettings()
        end
    end)
    saveCommand.Size = UDim2.new(1, -5, 0, 30)

    if #customCommands > 0 then
        makeLabel("COMANDOS PERSONALIZADOS")

        for i, command in ipairs(customCommands) do
            local index = i
            makeCard(command, true, function()
                table.remove(customCommands, index)
                saveData()
                showSettings()
            end)
        end
    end

    makeLabel("SALVAMENTO")

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -5, 0, 40)
    status.BackgroundColor3 = cardColor
    status.TextColor3 = white
    status.TextWrapped = true
    status.Font = Enum.Font.Gotham
    status.TextSize = 9

    if writefile and readfile and isfile and makefolder then
        status.Text = "Salvamento em arquivos disponível. Os dados são carregados automaticamente."
    else
        status.Text = "As funções de arquivos não foram detectadas. Os dados não poderão ser salvos permanentemente."
    end

    status.Parent = content
    Instance.new("UICorner", status).CornerRadius = UDim.new(0, 6)

    local saveNow = makeButton(content, "SALVAR AGORA", green, function()
        status.Text = saveData() and "Dados salvos com sucesso!" or "Não foi possível salvar os dados."
    end)
    saveNow.Size = UDim2.new(1, -5, 0, 30)
end

local function createTab(name, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1/3, -3, 1, 0)
    b.BackgroundColor3 = cardColor
    b.Text = name
    b.TextColor3 = white
    b.Font = Enum.Font.GothamBold
    b.TextSize = 9
    b.Parent = tabs
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    b.Activated:Connect(function()
        for _, child in ipairs(tabs:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = cardColor
            end
        end

        b.BackgroundColor3 = purple
        callback()
    end)

    return b
end

createTab("TEXTOS", showTexts).BackgroundColor3 = purple
createTab("COMANDOS", showCommands)
createTab("CONFIG.", showSettings)

showTexts()

-- ===== Minimizar / Restaurar (bubble) =====
local minimized = false

local function setMinimized(state)
    minimized = state
    main.Visible = not state
    bubble.Visible = state
end

minimize.Activated:Connect(function()
    setMinimized(true)
end)

bubble.Activated:Connect(function()
    setMinimized(false)
end)

-- ===== Arrastar a janela principal pelo cabeçalho =====
local function makeDraggable(frame, dragHandle)
    local dragging = false
    local dragStart
    local startPosition

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - dragStart

            frame.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)
end

makeDraggable(main, header)
makeDraggable(bubble, bubble)

local API = {}

function API.Destroy()
    saveData()
    gui:Destroy()
    ENV.PranchataTreinos = nil
end

ENV.PranchataTreinos = API

close.Activated:Connect(function()
    API.Destroy()
end)

saveData()
