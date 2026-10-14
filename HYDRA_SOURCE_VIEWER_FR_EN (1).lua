-- HYDRA SOURCE VIEWER | SIMPLE EDITOR + MINIMAP
-- Lecture et analyse statique uniquement : ne lance jamais le code telecharge.
-- Bouton SV et touche RightShift pour ouvrir/fermer.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local parent = player:WaitForChild("PlayerGui")
if type(gethui) == "function" then
    local ok, result = pcall(gethui)
    if ok and typeof(result) == "Instance" then parent = result end
end
local previous = parent:FindFirstChild("HYDRA_SourceViewer")
if previous then previous:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name = "HYDRA_SourceViewer"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = parent

local C = {
    bg = Color3.fromRGB(17, 17, 24),
    panel = Color3.fromRGB(25, 25, 35),
    input = Color3.fromRGB(20, 20, 29),
    purple = Color3.fromRGB(134, 100, 219),
    purple2 = Color3.fromRGB(92, 69, 162),
    edge = Color3.fromRGB(74, 70, 91),
    white = Color3.fromRGB(238, 238, 248),
    soft = Color3.fromRGB(158, 154, 176),
    green = Color3.fromRGB(131, 211, 166),
    red = Color3.fromRGB(239, 121, 132)
}

local function round(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
end
local function outline(obj, alpha)
    local s = Instance.new("UIStroke")
    s.Color = C.edge
    s.Thickness = 1
    s.Transparency = alpha or 0.55
    s.Parent = obj
end
local function label(parentObj, text, pos, sz, font, px, color)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.Position = pos
    l.Size = sz
    l.Font = font or Enum.Font.Gotham
    l.TextSize = px or 12
    l.TextColor3 = color or C.white
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parentObj
    return l
end

-- FR / EN : seules l'interface et les rapports changent. Le code source reste intact.
local language = "fr"
local translations = {
    fr = {
        subtitle = "Lire et analyser un script sans l'executer",
        inputTitle = "URL OU LOADSTRING", placeholder = 'Colle un lien GitHub Raw ou loadstring(game:HttpGet("..."))()',
        read = "LIRE", analyze = "ANALYSER", viewCode = "VOIR CODE", copy = "COPIER",
        saveLua = "SAUVER .LUA", saveTxt = "SAUVER .TXT", up = "HAUT", down = "BAS",
        minimap = "MINIMAP", lines = "Lignes %d-%d / %d", initialStatus = "Colle une URL pour commencer.",
        initialCode = "-- Colle ton loadstring puis clique sur LIRE.",
        emptyCode = "-- Aucun texte a afficher.", sourceVisible = "Code source affiche.",
        readFirst = "Lis d'abord une source.", reportShown = "Rapport affiche. Clique sur VOIR CODE pour revenir.",
        analyzing = "Analyse statique en cours...", analyzingButton = "ANALYSE...",
        analysisDone = "Analyse terminee sans executer le script.", analysisError = "Erreur d'analyse : %s",
        invalidURL = "Lien HTTPS invalide.", fetching = "Recuperation en cours...", loading = "CHARGEMENT...",
        retrieved = "Source recuperee : %d caracteres", failed = "Echec : %s", nothingCopy = "Rien a copier.",
        copied = "Code entier copie !", copyError = "Copie impossible : %s", noClipboard = "Copie auto indisponible dans cet executeur.",
        nothingSave = "Rien a enregistrer.", noSave = "La sauvegarde de fichier n'est pas disponible.",
        saved = "Enregistre : %s", saveError = "Erreur : %s", noSource = "Aucune source chargee.",
        reportTitle = "HYDRA SOURCE VIEWER / ANALYSE STATIQUE", reportSource = "Source : %s",
        reportSize = "Taille : %d octets | %d lignes", reportServices = "Services Roblox : %s",
        notSpecified = "non precisee", noneFound = "aucun detecte",
        warning1 = "ATTENTION : analyse par mots-cles. Les resultats sont des indices.",
        warning2 = "Les scripts obfusques peuvent cacher leur logique.",
        warning3 = "Le script telecharge n'est JAMAIS execute.",
        emptySection = "  Aucun element repere.", sectionLimit = "  ... Liste limitee a 70 elements.",
        cat1 = "FONCTIONS", cat2 = "LIENS WEB", cat3 = "REQUETES HTTP ET REMOTES",
        cat4 = "FONCTIONS D'EXECUTEUR", cat5 = "FICHIERS ET CLIPBOARD",
        cat6 = "INTERFACE", cat7 = "TRADE / AUTO-ACCEPT", cat8 = "OBFUSCATION",
    },
    en = {
        subtitle = "Read and analyze scripts without running them",
        inputTitle = "URL OR LOADSTRING", placeholder = 'Paste a GitHub Raw URL or loadstring(game:HttpGet("..."))()',
        read = "READ", analyze = "ANALYZE", viewCode = "VIEW CODE", copy = "COPY",
        saveLua = "SAVE .LUA", saveTxt = "SAVE .TXT", up = "UP", down = "DOWN",
        minimap = "MINIMAP", lines = "Lines %d-%d / %d", initialStatus = "Paste a URL to get started.",
        initialCode = "-- Paste your loadstring and click READ.",
        emptyCode = "-- No text to display.", sourceVisible = "Source code displayed.",
        readFirst = "Read a source file first.", reportShown = "Report displayed. Click VIEW CODE to return.",
        analyzing = "Static analysis in progress...", analyzingButton = "ANALYZING...",
        analysisDone = "Analysis complete without executing the script.", analysisError = "Analysis error: %s",
        invalidURL = "Invalid HTTPS URL.", fetching = "Fetching source...", loading = "LOADING...",
        retrieved = "Source retrieved: %d characters", failed = "Failed: %s", nothingCopy = "Nothing to copy.",
        copied = "Full text copied!", copyError = "Copy failed: %s", noClipboard = "Clipboard not available in this executor.",
        nothingSave = "Nothing to save.", noSave = "File saving is not available.",
        saved = "Saved: %s", saveError = "Error: %s", noSource = "No source loaded.",
        reportTitle = "HYDRA SOURCE VIEWER / STATIC ANALYSIS", reportSource = "Source: %s",
        reportSize = "Size: %d bytes | %d lines", reportServices = "Roblox services: %s",
        notSpecified = "not specified", noneFound = "none found",
        warning1 = "WARNING: keyword-based analysis. Results are only indicators.",
        warning2 = "Obfuscated scripts can hide their behavior.",
        warning3 = "Downloaded scripts are NEVER executed.",
        emptySection = "  No items found.", sectionLimit = "  ... List limited to 70 items.",
        cat1 = "FUNCTIONS", cat2 = "WEB LINKS", cat3 = "HTTP REQUESTS AND REMOTES",
        cat4 = "EXECUTOR FUNCTIONS", cat5 = "FILES AND CLIPBOARD",
        cat6 = "INTERFACE", cat7 = "TRADE / AUTO-ACCEPT", cat8 = "OBFUSCATION",
    }
}
local function tr(key, ...)
    local value = translations[language][key] or key
    if select("#", ...) > 0 then return string.format(value, ...) end
    return value
end

-- Petite pastille toujours visible meme quand le menu est masque.
local toggle = Instance.new("TextButton")
toggle.Name = "OpenClose"
toggle.Size = UDim2.fromOffset(54, 38)
toggle.Position = UDim2.new(0, 14, 0.5, -19)
toggle.BackgroundColor3 = C.purple2
toggle.Text = "SV"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 15
toggle.TextColor3 = C.white
toggle.BorderSizePixel = 0
toggle.AutoButtonColor = true
toggle.Parent = gui
round(toggle, 10)

local main = Instance.new("Frame")
main.Name = "Window"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromOffset(700, 480) -- dynamic height adjusted to script length
main.BackgroundColor3 = C.bg
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui
round(main, 10)
outline(main, 0.35)

local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1000,700)
local scale = math.clamp(math.min((viewport.X - 24) / 710, 1), 0.45, 1)
local uiScale = Instance.new("UIScale")
uiScale.Scale = scale
uiScale.Parent = main

local header = Instance.new("Frame")
header.Name = "DragHandle"
header.Size = UDim2.new(1, 0, 0, 57)
header.BackgroundColor3 = C.panel
header.BorderSizePixel = 0
header.Parent = main
round(header, 10)
local headerMask = Instance.new("Frame")
headerMask.BorderSizePixel = 0
headerMask.BackgroundColor3 = C.panel
headerMask.Position = UDim2.fromOffset(0, 42)
headerMask.Size = UDim2.new(1, 0, 0, 15)
headerMask.Parent = header
local separator = Instance.new("Frame")
separator.BorderSizePixel = 0
separator.BackgroundColor3 = C.edge
separator.BackgroundTransparency = 0.55
separator.Position = UDim2.new(0,0,1,-1)
separator.Size = UDim2.new(1,0,0,1)
separator.Parent = header

label(header, "HYDRA SOURCE VIEWER", UDim2.fromOffset(20,8), UDim2.fromOffset(570,23), Enum.Font.GothamBold, 17)
local subtitleLabel = label(header, tr("subtitle"), UDim2.fromOffset(20,32), UDim2.fromOffset(590,15), Enum.Font.Gotham, 11, C.soft)
local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(31,31)
close.Position = UDim2.new(1,-45,0,12)
close.BackgroundColor3 = C.input
close.BorderSizePixel = 0
close.Text = "X"
close.TextColor3 = C.soft
close.Font = Enum.Font.GothamBold
close.TextSize = 12
close.Parent = header
round(close,7)

local languageButton = Instance.new("TextButton")
languageButton.Name = "LanguageToggle"
languageButton.Size = UDim2.fromOffset(49,31)
languageButton.Position = UDim2.new(1,-102,0,12)
languageButton.BackgroundColor3 = C.input
languageButton.BorderSizePixel = 0
languageButton.Text = "FR"
languageButton.TextColor3 = C.white
languageButton.Font = Enum.Font.GothamBold
languageButton.TextSize = 12
languageButton.AutoButtonColor = true
languageButton.Parent = header
round(languageButton,7)
outline(languageButton,0.6)

local inputLabel = label(main, tr("inputTitle"), UDim2.fromOffset(20,65), UDim2.fromOffset(500,15), Enum.Font.GothamBold, 10, C.soft)
local input = Instance.new("TextBox")
input.Name = "ScriptInput"
input.Position = UDim2.fromOffset(20,83)
input.Size = UDim2.new(1,-40,0,62)
input.BackgroundColor3 = C.input
input.BorderSizePixel = 0
input.Text = ""
input.PlaceholderText = tr("placeholder")
input.PlaceholderColor3 = Color3.fromRGB(110,107,126)
input.TextColor3 = C.white
input.Font = Enum.Font.Code
input.TextSize = 12
input.TextXAlignment = Enum.TextXAlignment.Left
input.TextYAlignment = Enum.TextYAlignment.Top
input.ClearTextOnFocus = false
input.TextWrapped = true
input.MultiLine = true
input.Parent = main
round(input,7)
outline(input,0.72)
local pad = Instance.new("UIPadding")
pad.PaddingTop=UDim.new(0,9)
pad.PaddingBottom=UDim.new(0,6)
pad.PaddingLeft=UDim.new(0,10)
pad.PaddingRight=UDim.new(0,10)
pad.Parent=input

local function button(text,x,w,accent)
    local b = Instance.new("TextButton")
    b.Text=text
    b.Size=UDim2.fromOffset(w,34)
    b.Position=UDim2.fromOffset(x,156)
    b.BackgroundColor3=accent and C.purple2 or C.panel
    b.TextColor3=C.white
    b.TextSize=11
    b.Font=Enum.Font.GothamBold
    b.BorderSizePixel=0
    b.AutoButtonColor=true
    b.Parent=main
    round(b,7)
    return b
end
local fetchButton = button(tr("read"),20,104,true)
local analyzeButton = button(tr("analyze"),132,110,true)
local copyButton = button(tr("copy"),250,100)
local saveButton = button(tr("saveLua"),358,132)
local previousButton = button(tr("up"),515,65)
local nextButton = button(tr("down"),588,65)

local pageLabel = label(main,tr("lines",0,0,0),UDim2.fromOffset(20,199),UDim2.fromOffset(120,15),Enum.Font.GothamBold,10,C.soft)
local state = label(main,tr("initialStatus"),UDim2.fromOffset(151,199),UDim2.new(1,-171,0,15),Enum.Font.Gotham,10,C.soft)
state.TextXAlignment = Enum.TextXAlignment.Right
state.TextTruncate = Enum.TextTruncate.AtEnd

-- Editeur virtualise : le texte entier est consultable sans qu'un TextBox deborde.
-- La mini-vue de droite represente tout le fichier et sert aussi a naviguer.
local outputPanel = Instance.new("Frame")
outputPanel.Name = "SourcePanel"
outputPanel.Size = UDim2.new(1,-40,1,-251)
outputPanel.Position = UDim2.fromOffset(20,223)
outputPanel.BackgroundColor3 = C.input
outputPanel.BorderSizePixel = 0
outputPanel.ClipsDescendants = true
outputPanel.Parent = main
round(outputPanel,7)
outline(outputPanel,0.75)

local minimap = Instance.new("Frame")
minimap.Name = "Minimap"
minimap.Position = UDim2.new(1,-100,0,6)
minimap.Size = UDim2.new(0,93,1,-12)
minimap.BackgroundColor3 = Color3.fromRGB(21,20,31)
minimap.BorderSizePixel = 0
minimap.ClipsDescendants = true
minimap.Active = true
minimap.Parent = outputPanel
round(minimap,5)
local miniTop = Instance.new("TextLabel")
miniTop.Name="MiniHeader"
miniTop.Text=tr("minimap")
miniTop.TextColor3=C.soft
miniTop.BackgroundTransparency=1
miniTop.Font=Enum.Font.GothamBold
miniTop.TextSize=9
miniTop.Position=UDim2.fromOffset(8,3)
miniTop.Size=UDim2.new(1,-12,0,15)
miniTop.TextXAlignment=Enum.TextXAlignment.Left
miniTop.Parent=minimap
local miniContent = Instance.new("Frame")
miniContent.BackgroundTransparency = 1
miniContent.Position = UDim2.fromOffset(2,21)
miniContent.Size = UDim2.new(1,-4,1,-23)
miniContent.ClipsDescendants = true
miniContent.Parent = minimap

local editor = Instance.new("ScrollingFrame")
editor.Name = "CodeScroll"
editor.Position = UDim2.fromOffset(6,6)
editor.Size = UDim2.new(1,-116,1,-12)
editor.BackgroundTransparency = 1
editor.BorderSizePixel = 0
editor.ScrollBarThickness = 5
editor.ScrollBarImageColor3 = C.purple2
editor.ScrollingDirection = Enum.ScrollingDirection.Y
editor.ElasticBehavior = Enum.ElasticBehavior.Never
editor.CanvasSize = UDim2.fromOffset(0,0)
editor.ClipsDescendants = true
editor.Parent = outputPanel

local minimapView = Instance.new("Frame")
minimapView.Name = "VisibleArea"
minimapView.BackgroundColor3 = C.purple
minimapView.BackgroundTransparency = 0.82
minimapView.BorderSizePixel = 0
minimapView.Size = UDim2.new(1,0,0,35)
minimapView.ZIndex = 5
minimapView.Parent = miniContent
local miniViewStroke = Instance.new("UIStroke")
miniViewStroke.Color = C.purple
miniViewStroke.Transparency = 0.45
miniViewStroke.Thickness = 1
miniViewStroke.Parent = minimapView

-- Garder la zone de l'editeur au-dessus du fond mais a l'interieur de la fenetre.
local LINE_HEIGHT = 16
local currentRows = {}
local totalRows = 0
local rowPool = {}
local miniLabels = {}
local showRows -- definie plus bas, apres le chargement des donnees

local function addVirtualRow()
    local num = Instance.new("TextLabel")
    num.Name = "LineNumber"
    num.Size = UDim2.fromOffset(43,LINE_HEIGHT)
    num.BackgroundTransparency = 1
    num.Font = Enum.Font.Code
    num.TextSize = 11
    num.TextColor3 = Color3.fromRGB(110,105,137)
    num.TextXAlignment = Enum.TextXAlignment.Right
    num.Parent = editor
    local text = Instance.new("TextLabel")
    text.Name = "CodeLine"
    text.Position = UDim2.fromOffset(53,0)
    text.Size = UDim2.new(1,-69,0,LINE_HEIGHT)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.Code
    text.TextSize = 12
    text.TextColor3 = C.white
    text.TextWrapped = false
    text.TextTruncate = Enum.TextTruncate.AtEnd
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = editor
    rowPool[#rowPool+1] = {num=num,code=text}
end
for _ = 1, 58 do addVirtualRow() end

local function adjustedHeight(rowCount)
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(800,650)
    scale = math.clamp(math.min((vp.X - 24) / 710, 1), 0.45, 1)
    uiScale.Scale = scale
    local screenLimit = math.max(320, math.floor((vp.Y - 24) / scale))
    local ideal = 251 + math.clamp(rowCount * LINE_HEIGHT + 24, 95, 510)
    main.Size = UDim2.fromOffset(700, math.min(ideal, screenLimit))
end

local function rebuildMinimap()
    for _, item in ipairs(miniLabels) do item:Destroy() end
    table.clear(miniLabels)
    if totalRows == 0 then return end
    local h = math.max(1,miniContent.AbsoluteSize.Y)
    local count = math.max(1,math.min(totalRows,math.floor(h / 3)))
    for i=1,count do
        local index = math.clamp(math.floor((i-0.5)*totalRows/count)+1, 1,totalRows)
        local row = currentRows[index]
        local strip = Instance.new("TextLabel")
        strip.Name = "MiniLine"
        strip.BackgroundTransparency = 1
        strip.Font = Enum.Font.Code
        strip.TextSize = 5
        strip.TextXAlignment = Enum.TextXAlignment.Left
        strip.TextYAlignment = Enum.TextYAlignment.Center
        strip.TextWrapped = false
        strip.TextTruncate = Enum.TextTruncate.AtEnd
        strip.TextColor3 = (i%7==0) and C.purple or Color3.fromRGB(147,133,177)
        strip.TextTransparency = 0.12
        strip.Text = row and row.code:sub(1,42) or ""
        strip.Size = UDim2.new(1,-2,0,4)
        strip.Position = UDim2.new(0,1,(i-1)/count,0)
        strip.Parent = miniContent
        miniLabels[#miniLabels+1] = strip
    end
end

local function refreshViewport()
    if not gui.Parent then return end
    local first = math.max(1,math.floor(editor.CanvasPosition.Y / LINE_HEIGHT)+1)
    local showing = math.max(1,math.ceil(editor.AbsoluteSize.Y / LINE_HEIGHT)+3)
    if showing > #rowPool then
        for _=#rowPool+1,math.min(showing,150) do addVirtualRow() end
    end
    for i, view in ipairs(rowPool) do
        local idx = first+i-1
        local data = currentRows[idx]
        local visible = i<=showing and data ~= nil
        view.num.Visible = visible
        view.code.Visible = visible
        if visible then
            local y=(idx-1)*LINE_HEIGHT
            view.num.Position=UDim2.fromOffset(1,y)
            view.code.Position=UDim2.fromOffset(53,y)
            view.num.Text=data.number and tostring(data.number) or ""
            view.code.Text=data.code
        end
    end
    local last=math.min(totalRows,first+showing-1)
    pageLabel.Text = tr("lines",totalRows==0 and 0 or first,last,totalRows)
    local contentH=totalRows*LINE_HEIGHT
    local h=math.max(1,miniContent.AbsoluteSize.Y)
    local editorH=math.max(1,editor.AbsoluteSize.Y)
    local region = (contentH<=editorH) and h or math.max(11,h*editorH/math.max(1,contentH))
    local maxOffset=math.max(0,contentH-editorH)
    local position = maxOffset<=0 and 0 or editor.CanvasPosition.Y/maxOffset*(h-region)
    minimapView.Position=UDim2.fromOffset(0,position)
    minimapView.Size=UDim2.new(1,0,0,region)
end

local function prepareRows(source)
    -- Un grand code sur UNE SEULE ligne est decoupe visuellement, sans changer la source originale.
    -- Cette methode evite aussi le debordement horizontal des textes obfusques.
    local width=math.max(160,editor.AbsoluteSize.X)
    local cols=math.max(20,math.floor((width-74)/7.3))
    currentRows={}
    local number=0
    for line in (source.."\n"):gmatch("(.-)\n") do
        number=number+1
        line=line:gsub("\r$","")
        if line=="" then
            currentRows[#currentRows+1]={number=number, code=" "}
        else
            for at=1,#line,cols do
                currentRows[#currentRows+1]={number=at==1 and number or nil,code=line:sub(at,at+cols-1)}
            end
        end
    end
    totalRows=#currentRows
    adjustedHeight(totalRows)
    editor.CanvasSize=UDim2.new(0,0,0,totalRows*LINE_HEIGHT+8)
    editor.CanvasPosition=Vector2.new(0,0)
    task.defer(function()
        rebuildMinimap()
        refreshViewport()
    end)
end

editor:GetPropertyChangedSignal("CanvasPosition"):Connect(refreshViewport)
editor:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshViewport)
miniContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(rebuildMinimap)
local miniDragging=false
local function navigateMinimap(y)
    if totalRows==0 then return end
    local h=math.max(1,miniContent.AbsoluteSize.Y)
    local totalH=totalRows*LINE_HEIGHT
    local region=(totalH<=editor.AbsoluteSize.Y) and h or math.max(11,h*editor.AbsoluteSize.Y/math.max(1,totalH))
    local offset=math.clamp(y-miniContent.AbsolutePosition.Y-region/2,0,math.max(1,h-region))
    local ratio=(h-region)<=0 and 0 or offset/(h-region)
    local maxScroll=math.max(0,totalH-editor.AbsoluteSize.Y)
    editor.CanvasPosition=Vector2.new(0,ratio*maxScroll)
end
minimap.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        miniDragging=true
        navigateMinimap(i.Position.Y)
    end
end)
UIS.InputChanged:Connect(function(i)
    if miniDragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        navigateMinimap(i.Position.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then miniDragging=false end
end)

-- Source et rapport partagent le meme affichage; le texte original n'est jamais modifie.

local opened = true
local function setOpen(v)
    opened = v
    main.Visible = v
    toggle.BackgroundColor3 = v and C.panel or C.purple2
end
close.MouseButton1Click:Connect(function() setOpen(false) end)
toggle.MouseButton1Click:Connect(function() setOpen(not opened) end)
UIS.InputBegan:Connect(function(obj, processed)
    if processed then return end
    if obj.KeyCode == Enum.KeyCode.RightShift then setOpen(not opened) end
end)

local rawSource = ""
local reportText = ""
local reportTexts = {fr="", en=""}
local lastURL = ""
local mode = "source"
local currentPage = 1
local isBusy = false

local lastStatus = {key="initialStatus", args={}, color=C.soft}
local function status(key, color, ...)
    local args = {...}
    lastStatus = {key=key, args=args, color=color or C.soft}
    state.Text = tr(key, table.unpack(args))
    state.TextColor3 = lastStatus.color
end

local function currentText()
    return mode == "report" and reportText or rawSource
end

local function showPage(number)
    -- Les fleches defilent d'un ecran entier; la mini-vue permet le saut direct.
    if totalRows==0 then return end
    local jump=math.max(120,editor.AbsoluteSize.Y*0.86)
    local maxY=math.max(0,totalRows*LINE_HEIGHT-editor.AbsoluteSize.Y)
    editor.CanvasPosition=Vector2.new(0,math.clamp(editor.CanvasPosition.Y+(number*jump),0,maxY))
    refreshViewport()
end

local function setMode(which)
    mode = which
    analyzeButton.Text = mode == "report" and tr("viewCode") or tr("analyze")
    copyButton.Text = tr("copy")
    saveButton.Text = mode == "report" and tr("saveTxt") or tr("saveLua")
    local src=currentText()
    prepareRows(src ~= "" and src or tr("emptyCode"))
end

-- Analyse par texte uniquement : aucun code du script distant n'est execute.
local function analyzeSource(source)
    local categories = {
        {"cat1", {}}, {"cat2", {}}, {"cat3", {}},
        {"cat4", {}}, {"cat5", {}},
        {"cat6", {}}, {"cat7", {}}, {"cat8", {}}
    }
    local count = 0
    local seen = {}
    local function add(id, lineNumber, item, unique)
        local key = tostring(id) .. "|" .. item
        if unique and seen[key] then return end
        if unique then seen[key] = true end
        local list = categories[id][2]
        if #list < 70 then list[#list + 1] = ("L%d  %s"):format(lineNumber, item) end
    end
    local function scanList(id, line, number, patterns)
        for _, keyword in ipairs(patterns) do
            if line:find(keyword, 1, true) then add(id, number, keyword, true) end
        end
    end
    local foundServices = {}
    for line in (source .. "\n"):gmatch("(.-)\n") do
        count = count + 1
        local code = line:sub(1, 5000):gsub("%-%-.*$", "")
        local name = code:match("local%s+function%s+([%w_]+)%s*%(")
            or code:match("function%s+([%w_%.:]+)%s*%(")
            or code:match("([%w_%.:]+)%s*=%s*function%s*%(")
        if name then add(1, count, name, false) end
        for u in line:gmatch("https?://[^%s\"'<>%)%]]+") do
            add(2, count, u:gsub("[%,;%.]+$", ""), true)
        end
        scanList(3, code, count, {"game:HttpGet", "HttpService:RequestAsync", "HttpService:GetAsync", "HttpService:PostAsync", "syn.request", "http_request", "request(", ":FireServer(", ":InvokeServer(", "RemoteEvent", "RemoteFunction", "discord.com/api/webhooks"})
        scanList(4, code, count, {"getgc", "getgenv", "hookfunction", "hookmetamethod", "getconnections", "firesignal", "getrawmetatable", "setreadonly", "debug.getupvalues", "gethui"})
        scanList(5, code, count, {"readfile", "writefile", "delfile", "appendfile", "setclipboard", "toclipboard"})
        scanList(6, code, count, {"ScreenGui", "TextButton", "TextBox", "MouseButton1Click", "InputBegan", "TweenService"})
        scanList(7, code:lower(), count, {"trade", "accept", "confirm", "ready", "autoaccept"})
        scanList(8, code, count, {"loadstring", "bit32.bxor", "string.char", "LPH_", "setfenv", "getfenv"})
        local service = code:match("GetService%s*%(%s*['\"]([^'\"]+)['\"]%s*%)")
        if service then foundServices[service] = true end
        if count % 300 == 0 then task.wait() end
    end
    local serviceNames = {}
    for service in pairs(foundServices) do serviceNames[#serviceNames + 1] = service end
    table.sort(serviceNames)
    local reports = {}
    for _, lang in ipairs({"fr", "en"}) do
        local D = translations[lang]
        local report = {
            D.reportTitle,
            string.format(D.reportSource, lastURL ~= "" and lastURL or D.notSpecified),
            string.format(D.reportSize, #source, count),
            string.format(D.reportServices, #serviceNames > 0 and table.concat(serviceNames, ", ") or D.noneFound),
            "",
            D.warning1,
            D.warning2,
            D.warning3,
        }
        for _, section in ipairs(categories) do
            report[#report + 1] = ""
            report[#report + 1] = "[ " .. D[section[1]] .. " ]"
            if #section[2] == 0 then
                report[#report + 1] = D.emptySection
            else
                for _, item in ipairs(section[2]) do report[#report + 1] = "  " .. item end
                if #section[2] >= 70 then report[#report + 1] = D.sectionLimit end
            end
        end
        reports[lang] = table.concat(report, "\n")
    end
    return reports
end

analyzeButton.MouseButton1Click:Connect(function()
    if isBusy then return end
    if mode == "report" then
        setMode("source")
        status("sourceVisible", C.soft)
        return
    end
    if rawSource == "" then status("readFirst", C.red); return end
    if reportText ~= "" then
        setMode("report")
        status("reportShown", C.green)
        return
    end
    isBusy = true
    analyzeButton.Text = tr("analyzingButton")
    status("analyzing", C.soft)
    task.spawn(function()
        local ok, result = pcall(analyzeSource, rawSource)
        isBusy = false
        if not gui.Parent then return end
        if ok then
            reportTexts = result
            reportText = reportTexts[language]
            setMode("report")
            status("analysisDone", C.green)
        else
            analyzeButton.Text = tr("analyze")
            status("analysisError", C.red, tostring(result):sub(1, 80))
        end
    end)
end)

local function extractURL(value)
    if type(value) ~= "string" then return nil end
    -- Certains messages copient les URLs avec les slashs echappes : https\://raw\.github...
    local normalized = value:gsub("\\", "")
    local url = normalized:match("https?://[^%s\"']+")
    if not url then return nil end
    -- Ignore les caracteres de fermeture du loadstring et des liens Markdown.
    url = url:match("^[^%)]+") or url
    url = url:match("^[^%]]+") or url
    url = url:gsub("[>,;]+$", "")
    url = url:gsub(" ", "%%20")
    if url:sub(1, 8) ~= "https://" then
        return nil
    end
    -- Les liens GitHub de consultation peuvent etre convertis en liens source directs.
    url = url:gsub(
        "^https://github%.com/([^/]+)/([^/]+)/blob/([^/]+)/",
        "https://raw.githubusercontent.com/%1/%2/%3/"
    )
    return url
end

local function fetchSource(url)
    -- Ne fait qu'obtenir du texte. N'appelle jamais loadstring sur ce texte.
    local ok, data = pcall(function() return game:HttpGet(url, true) end)
    if ok and type(data) == "string" and #data > 0 then
        if data:match("^404:%s*Not Found") or data:match('"message"%s*:%s*"Not Found"') then
            return false, language == "fr" and "404 Not Found : verifie le nom du fichier GitHub." or "404 Not Found: check the GitHub filename."
        end
        return true, data
    end
    local lastError = ok and (language == "fr" and "Reponse vide" or "Empty response") or tostring(data)

    -- Alternatives pour certains environnements qui exposent une requete HTTP.
    local http = nil
    if type(request) == "function" then
        http = request
    elseif type(http_request) == "function" then
        http = http_request
    elseif type(syn) == "table" and type(syn.request) == "function" then
        http = syn.request
    end
    if http then
        local ok2, response = pcall(http, {Url = url, Method = "GET"})
        if ok2 and type(response) == "table" then
            local body = response.Body or response.body
            if type(body) == "string" and #body > 0 then
                if response.StatusCode and response.StatusCode >= 400 then
                    return false, "HTTP " .. tostring(response.StatusCode)
                end
                return true, body
            end
        end
    end
    return false, lastError
end

fetchButton.MouseButton1Click:Connect(function()
    if isBusy then return end
    local url = extractURL(input.Text)
    if not url then
        status("invalidURL", C.red)
        return
    end
    isBusy = true
    status("fetching", C.soft)
    fetchButton.Text = tr("loading")
    task.spawn(function()
        local ok, result = fetchSource(url)
        isBusy = false
        fetchButton.Text = tr("read")
        if not gui.Parent then return end
        if ok then
            rawSource = result
            reportText = ""
            reportTexts = {fr="",en=""}
            lastURL = url
            setMode("source")
            status("retrieved", C.green, #result)
        else
            rawSource, reportText = "", ""
            reportTexts = {fr="",en=""}
            setMode("source")
            status("failed", C.red, tostring(result):sub(1, 65))
        end
    end)
end)

copyButton.MouseButton1Click:Connect(function()
    local text = currentText()
    if text == "" then status("nothingCopy", C.red); return end
    local clipboard = setclipboard or toclipboard
    if type(clipboard) == "function" then
        local ok, message = pcall(clipboard, text)
        if ok then status("copied", C.green) else status("copyError", C.red, tostring(message)) end
    else
        status("noClipboard", C.red)
    end
end)

saveButton.MouseButton1Click:Connect(function()
    local text = currentText()
    if text == "" then status("nothingSave", C.red); return end
    if type(writefile) ~= "function" then
        status("noSave", C.red)
        return
    end
    local filename = "HYDRA_" .. (mode == "report" and "rapport_" or "source_") .. tostring(os.time()) .. (mode == "report" and ".txt" or ".lua")
    local ok, err = pcall(writefile, filename, text)
    if ok then status("saved", C.green, filename) else status("saveError", C.red, tostring(err)) end
end)

-- Change la langue instantanement, sans modifier ni recharger le script distant.
local function applyLanguage()
    subtitleLabel.Text = tr("subtitle")
    inputLabel.Text = tr("inputTitle")
    input.PlaceholderText = tr("placeholder")
    languageButton.Text = language == "fr" and "FR" or "EN"
    fetchButton.Text = isBusy and tr("loading") or tr("read")
    analyzeButton.Text = isBusy and tr("analyzingButton") or (mode == "report" and tr("viewCode") or tr("analyze"))
    copyButton.Text = tr("copy")
    saveButton.Text = mode == "report" and tr("saveTxt") or tr("saveLua")
    previousButton.Text = tr("up")
    nextButton.Text = tr("down")
    miniTop.Text = tr("minimap")
    state.Text = tr(lastStatus.key, table.unpack(lastStatus.args))
    -- Toujours synchroniser le rapport, meme si on regarde le code source.
    reportText = reportTexts[language] or ""
    if mode == "report" and reportText ~= "" then
        prepareRows(reportText)
    elseif rawSource == "" then
        prepareRows(tr("initialCode"))
    else
        refreshViewport()
    end
end
languageButton.MouseButton1Click:Connect(function()
    language = language == "fr" and "en" or "fr"
    applyLanguage()
end)

previousButton.MouseButton1Click:Connect(function() showPage(-1) end)
nextButton.MouseButton1Click:Connect(function() showPage(1) end)


-- Deplacement de la fenetre par l'entete, sans fermer le menu.
local moving, originInput, originPosition = false, nil, nil
header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        moving = true
        originInput = i.Position
        originPosition = main.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if moving and originInput and originPosition and
       (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - originInput
        main.Position = UDim2.new(originPosition.X.Scale, originPosition.X.Offset + delta.X / scale,
                                  originPosition.Y.Scale, originPosition.Y.Offset + delta.Y / scale)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        moving = false
    end
end)

-- Initial display before any code is loaded.
prepareRows(tr("initialCode"))
