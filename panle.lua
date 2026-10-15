-- ============================================
-- PAINEL DO CRIS - VERSION 4.3 (HOLOGRAMA FIX & ALL FEATURES)
-- ============================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Limpar versão antiga
if CoreGui:FindFirstChild("CrisTabHub") then
    CoreGui.CrisTabHub:Destroy()
end

-- Estado do Script
local CurrentLang = "PT"
local CurrentTheme = "Dark"

local ESPHoloActive = false
local ESPNamesActive = false
local ESPBoxActive = false
local ESPLinesActive = false
local ESPDistanceActive = false
local ESPRainbowActive = false
local LineOriginTop = false
local ESPColor = Color3.fromRGB(0, 255, 150)

local FOVVisible = false
local FOVRadiusPercent = 0.5
local AimbotActive = false
local AutoShootActive = false

local NoclipActive = false
local FlyActive = false
local FlySpeedPercent = 0.3
local SpinActive = false
local SpinSpeedPercent = 0.3
local CharacterSpeedPercent = 0.0

-- Dicionário
local Trans = {
    PT = {
        Title = "PAINEL DO CRIS - v4.3",
        TabESP = "ESP",
        TabAim = "AIMBOT",
        TabSpeed = "VELOCIDADE",
        TabHack = "HACKS",
        TabMap = "MAPA",
        TabSet = "CONFIGS",
        Holo = "👁️ ESP Holograma: ",
        Name = "🏷️ ESP Name: ",
        Box = "📦 ESP Box: ",
        Line = "📏 ESP Linha: ",
        LinePos = "📐 Linha: ",
        Dist = "📍 ESP Distância: ",
        Rainbow = "🌈 Linha Rainbow: ",
        Color = "🎨 Cor do ESP (RGB)",
        FOV = "⚪ Bolinha FOV: ",
        Aim = "🎯 Aimbot Cabeça: ",
        Shoot = "🔫 Atirar Automático: ",
        FOVSize = "Tamanho da Bolinha: ",
        WalkSpd = "Velocidade do Personagem: ",
        Noclip = "🧱 Atravessar Parede: ",
        Fly = "🕊️ Voar (Fly): ",
        FlySpd = "Velocidade do Voo: ",
        Spin = "🌀 Girar Personagem: ",
        SpinSpd = "Velocidade do Giro: ",
        Targets = "Alvos Detectados: ",
        Theme = "🎨 Tema: ",
        Lang = "🌐 Idioma: ",
        On = "LIGADO",
        Off = "DESLIGADO",
        Top = "CIMA",
        Bottom = "BAIXO",
        Go = "Ir até",
        Bring = "Trazer"
    },
    ES = {
        Title = "PANEL DE CRIS - v4.3",
        TabESP = "ESP",
        TabAim = "AIMBOT",
        TabSpeed = "VELOCIDAD",
        TabHack = "HACKS",
        TabMap = "MAPA",
        TabSet = "CONFIGS",
        Holo = "👁️ ESP Holograma: ",
        Name = "🏷️ ESP Nombre: ",
        Box = "📦 ESP Caja: ",
        Line = "📏 ESP Línea: ",
        LinePos = "📐 Línea: ",
        Dist = "📍 ESP Distancia: ",
        Rainbow = "🌈 Línea Arcoíris: ",
        Color = "🎨 Color del ESP (RGB)",
        FOV = "⚪ Círculo FOV: ",
        Aim = "🎯 Aimbot Cabeza: ",
        Shoot = "🔫 Disparo Automático: ",
        FOVSize = "Tamaño del Círculo: ",
        WalkSpd = "Velocidad de Personaje: ",
        Noclip = "🧱 Atravesar Paredes: ",
        Fly = "🕊️ Volar (Fly): ",
        FlySpd = "Velocidad de Vuelo: ",
        Spin = "🌀 Girar Personaje: ",
        SpinSpd = "Velocidad de Giro: ",
        Targets = "Enemigos Detectados: ",
        Theme = "🎨 Tema: ",
        Lang = "🌐 Idioma: ",
        On = "ACTIVADO",
        Off = "DESACTIVADO",
        Top = "ARRIBA",
        Bottom = "ABAJO",
        Go = "Ir a",
        Bring = "Traer"
    }
}

local function L(key)
    return Trans[CurrentLang][key] or key
end

-- ScreenGui Principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CrisTabHub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- DETECÇÃO DE TIME E ALVOS
local function isEnemy(player, char)
    if player and player == LocalPlayer then return false end
    if player and LocalPlayer.Team and player.Team then
        return player.Team ~= LocalPlayer.Team
    end
    return true
end

local function getTargetHead(char)
    if not char then return nil end
    return char:FindFirstChild("Head") or char:FindFirstChild("HeadPart") or char:FindFirstChild("Hitbox") or char:FindFirstChild("UpperTorso")
end

local function getAllTargets()
    local targets = {}
    for _, p in pairs(Players:GetPlayers()) do
        if isEnemy(p, p.Character) and p.Character then
            table.insert(targets, {Player = p, Character = p.Character})
        end
    end
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:FindFirstChildOfClass("Humanoid") and obj ~= LocalPlayer.Character then
            local p = Players:GetPlayerFromCharacter(obj)
            if isEnemy(p, obj) then
                local alreadyAdded = false
                for _, t in pairs(targets) do
                    if t.Character == obj then alreadyAdded = true break end
                end
                if not alreadyAdded then
                    table.insert(targets, {Player = p, Character = obj})
                end
            end
        end
    end
    return targets
end

-- CÍRCULO FOV & AIMBOT
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Radius = 100
FOVCircle.Filled = false
FOVCircle.Visible = false

local function getClosestHeadToCursor()
    local targetHead = nil
    local shortestDist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local maxRadius = FOVCircle.Radius

    for _, target in pairs(getAllTargets()) do
        local char = target.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        local head = getTargetHead(char)

        if hum and hum.Health > 0 and head then
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local screenPos2D = Vector2.new(screenPos.X, screenPos.Y)
                local dist = (screenPos2D - center).Magnitude
                if dist < maxRadius and dist < shortestDist then
                    shortestDist = dist
                    targetHead = head
                end
            end
        end
    end
    return targetHead
end

RunService.RenderStepped:Connect(function()
    if Camera then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = 10 + (FOVRadiusPercent * 240)
    end

    local currentTargetHead = getClosestHeadToCursor()

    if AimbotActive and currentTargetHead then
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, currentTargetHead.Position)
    end

    if AutoShootActive and currentTargetHead then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                else
                    VirtualUser:Button1Down(Vector2.new(0, 0))
                    task.wait(0.02)
                    VirtualUser:Button1Up(Vector2.new(0, 0))
                end
            end
        end)
    end
end)

-- PAINEL PRINCIPAL
local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
ToggleButton.Position = UDim2.new(0, 15, 0.4, 0)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Text = "⚡"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 22
ToggleButton.Active = true
ToggleButton.Draggable = true
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)
local ToggleStroke = Instance.new("UIStroke", ToggleButton)
ToggleStroke.Thickness = 2.5

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.Position = UDim2.new(0.5, -160, 0.08, 0)
MainFrame.Size = UDim2.new(0, 320, 0, 490)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 2.5

-- Plexus
local PlexusCanvas = Instance.new("Frame", MainFrame)
PlexusCanvas.Size = UDim2.new(1, 0, 1, 0)
PlexusCanvas.BackgroundTransparency = 1
PlexusCanvas.ZIndex = 0

local nodes = {}
for i = 1, 15 do
    local dot = Instance.new("Frame", PlexusCanvas)
    dot.Size = UDim2.new(0, 4, 0, 4)
    dot.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    dot.BackgroundTransparency = 0.4
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    table.insert(nodes, {
        gui = dot,
        pos = Vector2.new(math.random(10, 310), math.random(10, 480)),
        vel = Vector2.new(math.random(-20, 20)/10, math.random(-20, 20)/10)
    })
end

RunService.RenderStepped:Connect(function(dt)
    local hue = (tick() % 5) / 5
    local rgbColor = Color3.fromHSV(hue, 1, 1)
    MainStroke.Color = rgbColor
    ToggleStroke.Color = rgbColor

    for _, node in pairs(nodes) do
        node.pos = node.pos + (node.vel * (dt * 30))
        if node.pos.X < 5 or node.pos.X > 315 then node.vel = Vector2.new(-node.vel.X, node.vel.Y) end
        if node.pos.Y < 5 or node.pos.Y > 485 then node.vel = Vector2.new(node.vel.X, -node.vel.Y) end
        node.gui.Position = UDim2.new(0, node.pos.X, 0, node.pos.Y)
    end
end)

local TitleLabel = Instance.new("TextLabel", MainFrame)
TitleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
TitleLabel.Size = UDim2.new(1, 0, 0, 38)
TitleLabel.Text = L("Title")
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.ZIndex = 2
Instance.new("UICorner", TitleLabel).CornerRadius = UDim.new(0, 12)

local TabBar = Instance.new("Frame", MainFrame)
TabBar.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
TabBar.Position = UDim2.new(0, 5, 0, 42)
TabBar.Size = UDim2.new(1, -10, 0, 30)
TabBar.ZIndex = 2
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 8)

local function createTabBtn(text, posX, width)
    local btn = Instance.new("TextButton", TabBar)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 48)
    btn.Position = UDim2.new(0, posX, 0, 2)
    btn.Size = UDim2.new(0, width, 1, -4)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextSize = 8
    btn.Font = Enum.Font.GothamBold
    btn.ZIndex = 3
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local TabBtnESP = createTabBtn(L("TabESP"), 2, 45)
local TabBtnAim = createTabBtn(L("TabAim"), 49, 52)
local TabBtnSpeed = createTabBtn(L("TabSpeed"), 103, 65)
local TabBtnHack = createTabBtn(L("TabHack"), 170, 45)
local TabBtnMap = createTabBtn(L("TabMap"), 217, 45)
local TabBtnSet = createTabBtn(L("TabSet"), 264, 44)

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 10, 0, 78)
ContentFrame.Size = UDim2.new(1, -20, 1, -88)
ContentFrame.ZIndex = 2

local function createPage()
    local page = Instance.new("Frame", ContentFrame)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ZIndex = 2
    return page
end

local PageESP = createPage()
local PageAim = createPage()
local PageSpeed = createPage()
local PageHack = createPage()
local PageMap = createPage()
local PageSet = createPage()

PageESP.Visible = true

local function switchTab(activePage, activeBtn)
    PageESP.Visible = false PageAim.Visible = false PageSpeed.Visible = false PageHack.Visible = false PageMap.Visible = false PageSet.Visible = false
    TabBtnESP.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtnAim.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtnSpeed.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtnHack.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtnMap.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtnSet.TextColor3 = Color3.fromRGB(150, 150, 150)
    activePage.Visible = true
    activeBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
end

TabBtnESP.MouseButton1Click:Connect(function() switchTab(PageESP, TabBtnESP) end)
TabBtnAim.MouseButton1Click:Connect(function() switchTab(PageAim, TabBtnAim) end)
TabBtnSpeed.MouseButton1Click:Connect(function() switchTab(PageSpeed, TabBtnSpeed) end)
TabBtnHack.MouseButton1Click:Connect(function() switchTab(PageHack, TabBtnHack) end)
TabBtnMap.MouseButton1Click:Connect(function() switchTab(PageMap, TabBtnMap) end)
TabBtnSet.MouseButton1Click:Connect(function() switchTab(PageSet, TabBtnSet) end)

-- GERADOR DE BOTÕES COM ESTADO VERDE
local function createButton(parent, text, posY)
    local btn = Instance.new("TextButton", parent)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btn.Position = UDim2.new(0, 5, 0, posY)
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.ZIndex = 3

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(50, 50, 75)
    return btn
end

local function applyButtonState(btn, state)
    if state then
        btn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    else
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    end
end

-- ABA 1: ESP
local ESPHoloBtn = createButton(PageESP, "", 0)
local ESPNameBtn = createButton(PageESP, "", 36)
local ESPBoxBtn = createButton(PageESP, "", 72)
local ESPLineBtn = createButton(PageESP, "", 108)
local ESPLinePosBtn = createButton(PageESP, "", 144)
local ESPDistBtn = createButton(PageESP, "", 180)
local ESPRainbowBtn = createButton(PageESP, "", 216)
local ColorPickerBtn = createButton(PageESP, "", 252)

-- ABA 2: AIMBOT
local FOVToggleBtn = createButton(PageAim, "", 0)
local AimbotBtn = createButton(PageAim, "", 36)
local AutoShootBtn = createButton(PageAim, "", 72)

local FOVLabel = Instance.new("TextLabel", PageAim)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Position = UDim2.new(0, 5, 0, 114)
FOVLabel.Size = UDim2.new(1, -10, 0, 18)
FOVLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVLabel.TextSize = 10
FOVLabel.Font = Enum.Font.GothamMedium
FOVLabel.ZIndex = 3

local FOVSliderBg = Instance.new("Frame", PageAim)
FOVSliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
FOVSliderBg.Position = UDim2.new(0, 10, 0, 136)
FOVSliderBg.Size = UDim2.new(1, -20, 0, 18)
FOVSliderBg.ZIndex = 3
Instance.new("UICorner", FOVSliderBg).CornerRadius = UDim.new(1, 0)

local FOVSliderFill = Instance.new("Frame", FOVSliderBg)
FOVSliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
FOVSliderFill.Size = UDim2.new(0.5, 0, 1, 0)
FOVSliderFill.ZIndex = 3
Instance.new("UICorner", FOVSliderFill).CornerRadius = UDim.new(1, 0)

local FOVSliderBtn = Instance.new("TextButton", FOVSliderBg)
FOVSliderBtn.BackgroundTransparency = 1
FOVSliderBtn.Size = UDim2.new(1, 0, 1, 0)
FOVSliderBtn.Text = ""
FOVSliderBtn.ZIndex = 4

-- ABA 3: VELOCIDADE
local SpeedLabel = Instance.new("TextLabel", PageSpeed)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Position = UDim2.new(0, 5, 0, 10)
SpeedLabel.Size = UDim2.new(1, -10, 0, 20)
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 11
SpeedLabel.Font = Enum.Font.GothamMedium
SpeedLabel.ZIndex = 3

local SpeedSliderBg = Instance.new("Frame", PageSpeed)
SpeedSliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
SpeedSliderBg.Position = UDim2.new(0, 10, 0, 38)
SpeedSliderBg.Size = UDim2.new(1, -20, 0, 18)
SpeedSliderBg.ZIndex = 3
Instance.new("UICorner", SpeedSliderBg).CornerRadius = UDim.new(1, 0)

local SpeedSliderFill = Instance.new("Frame", SpeedSliderBg)
SpeedSliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SpeedSliderFill.Size = UDim2.new(0, 0, 1, 0)
SpeedSliderFill.ZIndex = 3
Instance.new("UICorner", SpeedSliderFill).CornerRadius = UDim.new(1, 0)

local SpeedSliderBtn = Instance.new("TextButton", SpeedSliderBg)
SpeedSliderBtn.BackgroundTransparency = 1
SpeedSliderBtn.Size = UDim2.new(1, 0, 1, 0)
SpeedSliderBtn.Text = ""
SpeedSliderBtn.ZIndex = 4

-- ABA 4: HACKS
local NoclipBtn = createButton(PageHack, "", 0)
local FlyBtn = createButton(PageHack, "", 36)

local FlyLabel = Instance.new("TextLabel", PageHack)
FlyLabel.BackgroundTransparency = 1
FlyLabel.Position = UDim2.new(0, 5, 0, 74)
FlyLabel.Size = UDim2.new(1, -10, 0, 18)
FlyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyLabel.TextSize = 10
FlyLabel.Font = Enum.Font.GothamMedium
FlyLabel.ZIndex = 3

local FlySliderBg = Instance.new("Frame", PageHack)
FlySliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
FlySliderBg.Position = UDim2.new(0, 10, 0, 94)
FlySliderBg.Size = UDim2.new(1, -20, 0, 18)
FlySliderBg.ZIndex = 3
Instance.new("UICorner", FlySliderBg).CornerRadius = UDim.new(1, 0)

local FlySliderFill = Instance.new("Frame", FlySliderBg)
FlySliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
FlySliderFill.Size = UDim2.new(0.3, 0, 1, 0)
FlySliderFill.ZIndex = 3
Instance.new("UICorner", FlySliderFill).CornerRadius = UDim.new(1, 0)

local FlySliderBtn = Instance.new("TextButton", FlySliderBg)
FlySliderBtn.BackgroundTransparency = 1
FlySliderBtn.Size = UDim2.new(1, 0, 1, 0)
FlySliderBtn.Text = ""
FlySliderBtn.ZIndex = 4

local SpinBtn = createButton(PageHack, "", 120)

local SpinLabel = Instance.new("TextLabel", PageHack)
SpinLabel.BackgroundTransparency = 1
SpinLabel.Position = UDim2.new(0, 5, 0, 158)
SpinLabel.Size = UDim2.new(1, -10, 0, 18)
SpinLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpinLabel.TextSize = 10
SpinLabel.Font = Enum.Font.GothamMedium
SpinLabel.ZIndex = 3

local SpinSliderBg = Instance.new("Frame", PageHack)
SpinSliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
SpinSliderBg.Position = UDim2.new(0, 10, 0, 178)
SpinSliderBg.Size = UDim2.new(1, -20, 0, 18)
SpinSliderBg.ZIndex = 3
Instance.new("UICorner", SpinSliderBg).CornerRadius = UDim.new(1, 0)

local SpinSliderFill = Instance.new("Frame", SpinSliderBg)
SpinSliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SpinSliderFill.Size = UDim2.new(0.3, 0, 1, 0)
SpinSliderFill.ZIndex = 3
Instance.new("UICorner", SpinSliderFill).CornerRadius = UDim.new(1, 0)

local SpinSliderBtn = Instance.new("TextButton", SpinSliderBg)
SpinSliderBtn.BackgroundTransparency = 1
SpinSliderBtn.Size = UDim2.new(1, 0, 1, 0)
SpinSliderBtn.Text = ""
SpinSliderBtn.ZIndex = 4

-- ABA 5: MAPA
local MapHeader = Instance.new("TextLabel", PageMap)
MapHeader.BackgroundTransparency = 1
MapHeader.Position = UDim2.new(0, 5, 0, 0)
MapHeader.Size = UDim2.new(1, -10, 0, 20)
MapHeader.TextColor3 = Color3.fromRGB(0, 170, 255)
MapHeader.TextSize = 11
MapHeader.Font = Enum.Font.GothamBold
MapHeader.ZIndex = 3

local PlayerScroll = Instance.new("ScrollingFrame", PageMap)
PlayerScroll.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
PlayerScroll.Position = UDim2.new(0, 5, 0, 24)
PlayerScroll.Size = UDim2.new(1, -10, 1, -28)
PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScroll.ScrollBarThickness = 4
PlayerScroll.ZIndex = 3
Instance.new("UICorner", PlayerScroll).CornerRadius = UDim.new(0, 8)

local UIListLayout = Instance.new("UIListLayout", PlayerScroll)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

local function refreshPlayerList()
    for _, child in pairs(PlayerScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local allTargets = getAllTargets()
    MapHeader.Text = L("Targets") .. #allTargets

    for _, target in pairs(allTargets) do
        local char = target.Character
        local nameStr = target.Player and target.Player.DisplayName or char.Name
        local rootPart = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")

        if rootPart then
            local card = Instance.new("Frame", PlayerScroll)
            card.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            card.Size = UDim2.new(1, -8, 0, 36)
            card.ZIndex = 3
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

            local pName = Instance.new("TextLabel", card)
            pName.BackgroundTransparency = 1
            pName.Position = UDim2.new(0, 8, 0, 0)
            pName.Size = UDim2.new(0.5, 0, 1, 0)
            pName.Text = nameStr
            pName.TextColor3 = Color3.fromRGB(255, 255, 255)
            pName.TextSize = 10
            pName.Font = Enum.Font.GothamBold
            pName.TextXAlignment = Enum.TextXAlignment.Left
            pName.ZIndex = 3

            local tpToBtn = Instance.new("TextButton", card)
            tpToBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            tpToBtn.Position = UDim2.new(0.52, 0, 0.15, 0)
            tpToBtn.Size = UDim2.new(0.22, 0, 0.7, 0)
            tpToBtn.Text = L("Go")
            tpToBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            tpToBtn.TextSize = 9
            tpToBtn.Font = Enum.Font.GothamBold
            tpToBtn.ZIndex = 4
            Instance.new("UICorner", tpToBtn).CornerRadius = UDim.new(0, 4)

            tpToBtn.MouseButton1Click:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = rootPart.CFrame * CFrame.new(0, 0, -3)
                end
            end)

            local bringBtn = Instance.new("TextButton", card)
            bringBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
            bringBtn.Position = UDim2.new(0.76, 0, 0.15, 0)
            bringBtn.Size = UDim2.new(0.22, 0, 0.7, 0)
            bringBtn.Text = L("Bring")
            bringBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            bringBtn.TextSize = 9
            bringBtn.Font = Enum.Font.GothamBold
            bringBtn.ZIndex = 4
            Instance.new("UICorner", bringBtn).CornerRadius = UDim.new(0, 4)

            bringBtn.MouseButton1Click:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    rootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                end
            end)
        end
    end
    PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)
TabBtnMap.MouseButton1Click:Connect(refreshPlayerList)

-- ABA 6: CONFIGS
local ThemeBtn = createButton(PageSet, "", 0)
local LangBtn = createButton(PageSet, "", 38)

local function updateUIStrings()
    TitleLabel.Text = L("Title")
    TabBtnESP.Text = L("TabESP")
    TabBtnAim.Text = L("TabAim")
    TabBtnSpeed.Text = L("TabSpeed")
    TabBtnHack.Text = L("TabHack")
    TabBtnMap.Text = L("TabMap")
    TabBtnSet.Text = L("TabSet")

    ESPHoloBtn.Text = L("Holo") .. (ESPHoloActive and L("On") or L("Off"))
    applyButtonState(ESPHoloBtn, ESPHoloActive)

    ESPNameBtn.Text = L("Name") .. (ESPNamesActive and L("On") or L("Off"))
    applyButtonState(ESPNameBtn, ESPNamesActive)

    ESPBoxBtn.Text = L("Box") .. (ESPBoxActive and L("On") or L("Off"))
    applyButtonState(ESPBoxBtn, ESPBoxActive)

    ESPLineBtn.Text = L("Line") .. (ESPLinesActive and L("On") or L("Off"))
    applyButtonState(ESPLineBtn, ESPLinesActive)

    ESPLinePosBtn.Text = L("LinePos") .. (LineOriginTop and L("Top") or L("Bottom"))

    ESPDistBtn.Text = L("Dist") .. (ESPDistanceActive and L("On") or L("Off"))
    applyButtonState(ESPDistBtn, ESPDistanceActive)

    ESPRainbowBtn.Text = L("Rainbow") .. (ESPRainbowActive and L("On") or L("Off"))
    applyButtonState(ESPRainbowBtn, ESPRainbowActive)

    ColorPickerBtn.Text = L("Color")
    ColorPickerBtn.BackgroundColor3 = ESPColor

    FOVToggleBtn.Text = L("FOV") .. (FOVVisible and L("On") or L("Off"))
    applyButtonState(FOVToggleBtn, FOVVisible)

    AimbotBtn.Text = L("Aim") .. (AimbotActive and L("On") or L("Off"))
    applyButtonState(AimbotBtn, AimbotActive)

    AutoShootBtn.Text = L("Shoot") .. (AutoShootActive and L("On") or L("Off"))
    applyButtonState(AutoShootBtn, AutoShootActive)

    FOVLabel.Text = L("FOVSize") .. math.floor(FOVRadiusPercent * 100) .. "%"
    SpeedLabel.Text = L("WalkSpd") .. math.floor(CharacterSpeedPercent * 100) .. "%"

    NoclipBtn.Text = L("Noclip") .. (NoclipActive and L("On") or L("Off"))
    applyButtonState(NoclipBtn, NoclipActive)

    FlyBtn.Text = L("Fly") .. (FlyActive and L("On") or L("Off"))
    applyButtonState(FlyBtn, FlyActive)

    FlyLabel.Text = L("FlySpd") .. math.floor(FlySpeedPercent * 100) .. "%"

    SpinBtn.Text = L("Spin") .. (SpinActive and L("On") or L("Off"))
    applyButtonState(SpinBtn, SpinActive)

    SpinLabel.Text = L("SpinSpd") .. math.floor(SpinSpeedPercent * 100) .. "%"

    ThemeBtn.Text = L("Theme") .. (CurrentTheme == "Dark" and "Escuro / Oscuro" or "Preto / Negro")
    LangBtn.Text = L("Lang") .. (CurrentLang == "PT" and "Português 🇧🇷" or "Español 🇪🇸")

    refreshPlayerList()
end

ThemeBtn.MouseButton1Click:Connect(function()
    CurrentTheme = (CurrentTheme == "Dark") and "Black" or "Dark"
    if CurrentTheme == "Black" then
        MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        TitleLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        TabBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    else
        MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
        TitleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
        TabBar.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    end
    updateUIStrings()
end)

LangBtn.MouseButton1Click:Connect(function()
    CurrentLang = (CurrentLang == "PT") and "ES" or "PT"
    updateUIStrings()
end)

-- SISTEMA DE SLIDERS
local function setupSlider(sliderBtn, sliderBg, sliderFill, percentVarSetter)
    local dragging = false
    local function update(input)
        local mouseX = input.Position.X
        local sliderX = sliderBg.AbsolutePosition.X
        local sliderWidth = sliderBg.AbsoluteSize.X
        local pct = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
        sliderFill.Size = UDim2.new(pct, 0, 1, 0)
        percentVarSetter(pct)
        updateUIStrings()
    end

    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

setupSlider(FOVSliderBtn, FOVSliderBg, FOVSliderFill, function(p) FOVRadiusPercent = p end)
setupSlider(SpeedSliderBtn, SpeedSliderBg, SpeedSliderFill, function(p)
    CharacterSpeedPercent = p
    local minSpd, maxSpd = 16, 300
    local finalSpeed = minSpd + ((maxSpd - minSpd) * p)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = finalSpeed
    end
end)
setupSlider(FlySliderBtn, FlySliderBg, FlySliderFill, function(p) FlySpeedPercent = p end)
setupSlider(SpinSliderBtn, SpinSliderBg, SpinSliderFill, function(p) SpinSpeedPercent = p end)

-- ESP & HIGHLIGHTS CORRIGIDO
local Boxes, Lines, Names, espHighlights = {}, {}, {}, {}

local function clearESP()
    for _, b in pairs(Boxes) do b.Visible = false end
    for _, l in pairs(Lines) do l.Visible = false end
    for _, n in pairs(Names) do n.Visible = false end
    for _, hl in pairs(espHighlights) do pcall(function() hl:Destroy() end) end
    espHighlights = {}
end

local colorList = {Color3.fromRGB(0, 255, 150), Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 170, 255), Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 0, 255)}
local currentColorIdx = 1

ColorPickerBtn.MouseButton1Click:Connect(function()
    currentColorIdx = (currentColorIdx % #colorList) + 1
    ESPColor = colorList[currentColorIdx]
    updateUIStrings()
end)

ESPHoloBtn.MouseButton1Click:Connect(function() ESPHoloActive = not ESPHoloActive updateUIStrings() if not ESPHoloActive then clearESP() end end)
ESPNameBtn.MouseButton1Click:Connect(function() ESPNamesActive = not ESPNamesActive updateUIStrings() if not ESPNamesActive then clearESP() end end)
ESPBoxBtn.MouseButton1Click:Connect(function() ESPBoxActive = not ESPBoxActive updateUIStrings() if not ESPBoxActive then clearESP() end end)
ESPLineBtn.MouseButton1Click:Connect(function() ESPLinesActive = not ESPLinesActive updateUIStrings() if not ESPLinesActive then clearESP() end end)
ESPDistBtn.MouseButton1Click:Connect(function() ESPDistanceActive = not ESPDistanceActive updateUIStrings() if not ESPDistanceActive then clearESP() end end)
ESPRainbowBtn.MouseButton1Click:Connect(function() ESPRainbowActive = not ESPRainbowActive updateUIStrings() end)
ESPLinePosBtn.MouseButton1Click:Connect(function() LineOriginTop = not LineOriginTop updateUIStrings() end)

FOVToggleBtn.MouseButton1Click:Connect(function() FOVVisible = not FOVVisible FOVCircle.Visible = FOVVisible updateUIStrings() end)
AimbotBtn.MouseButton1Click:Connect(function() AimbotActive = not AimbotActive updateUIStrings() end)
AutoShootBtn.MouseButton1Click:Connect(function() AutoShootActive = not AutoShootActive updateUIStrings() end)

NoclipBtn.MouseButton1Click:Connect(function() NoclipActive = not NoclipActive updateUIStrings() end)
RunService.Stepped:Connect(function()
    if NoclipActive and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

local BodyVelocity, BodyGyro
FlyBtn.MouseButton1Click:Connect(function()
    FlyActive = not FlyActive
    updateUIStrings()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        if FlyActive then
            BodyGyro = Instance.new("BodyGyro", char.HumanoidRootPart)
            BodyGyro.P = 9e4
            BodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            BodyVelocity = Instance.new("BodyVelocity", char.HumanoidRootPart)
            BodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
            char.Humanoid.PlatformStand = true
        else
            if BodyGyro then BodyGyro:Destroy() end
            if BodyVelocity then BodyVelocity:Destroy() end
            char.Humanoid.PlatformStand = false
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if FlyActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local currentFlySpeed = 20 + (FlySpeedPercent * 180)
        BodyGyro.cframe = Camera.CFrame
        BodyVelocity.velocity = Camera.CFrame.LookVector * currentFlySpeed
    end
end)

SpinBtn.MouseButton1Click:Connect(function() SpinActive = not SpinActive updateUIStrings() end)
RunService.RenderStepped:Connect(function()
    if SpinActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local speedMultiplier = 5 + (SpinSpeedPercent * 45)
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(speedMultiplier), 0)
    end
end)

RunService.RenderStepped:Connect(function()
    local allTargets = getAllTargets()
    local activeColor = ESPColor

    if ESPRainbowActive then
        local hue = (tick() % 2) / 2
        activeColor = Color3.fromHSV(hue, 1, 1)
    end

    -- PROCESSAR HOLOGRAMA (HIGHLIGHT)
    for _, t in pairs(allTargets) do
        local char = t.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if ESPHoloActive and char and hum and hum.Health > 0 then
            if not espHighlights[char] or not espHighlights[char].Parent then
                pcall(function()
                    local hl = Instance.new("Highlight")
                    hl.Name = "CrisHolo"
                    hl.FillColor = activeColor
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.3
                    hl.Adornee = char
                    hl.Parent = char
                    espHighlights[char] = hl
                end)
            elseif espHighlights[char] then
                espHighlights[char].FillColor = activeColor
            end
        elseif not ESPHoloActive and espHighlights[char] then
            pcall(function() espHighlights[char]:Destroy() end)
            espHighlights[char] = nil
        end
    end

    -- PROCESSAR OUTROS ESPS (BOX, LINHA, NOME, DISTANCIA)
    for _, t in pairs(allTargets) do
        local char = t.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        local rootPart = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        local headPart = getTargetHead(char)

        if rootPart then
            local isDead = (hum and hum.Health <= 0)
            local currentLineColor = isDead and Color3.fromRGB(255, 0, 0) or activeColor
            local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local dist = myHRP and math.floor((myHRP.Position - rootPart.Position).Magnitude) or 0
            local nameToShow = t.Player and t.Player.DisplayName or char.Name

            if not Boxes[char] then Boxes[char] = Drawing.new("Square") Boxes[char].Thickness = 1.5 Boxes[char].Filled = false end
            if ESPBoxActive and onScreen and headPart and not isDead then
                local headPos = Camera:WorldToViewportPoint(headPart.Position + Vector3.new(0, 0.5, 0))
                local legPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                local boxHeight = math.abs(headPos.Y - legPos.Y)
                local boxWidth = boxHeight / 1.5
                Boxes[char].Size = Vector2.new(boxWidth, boxHeight)
                Boxes[char].Position = Vector2.new(screenPos.X - (boxWidth / 2), headPos.Y)
                Boxes[char].Color = activeColor
                Boxes[char].Visible = true
            else Boxes[char].Visible = false end

            if not Lines[char] then Lines[char] = Drawing.new("Line") Lines[char].Thickness = 1.5 end
            if ESPLinesActive and onScreen then
                local startY = LineOriginTop and 0 or Camera.ViewportSize.Y
                Lines[char].From = Vector2.new(Camera.ViewportSize.X / 2, startY)
                Lines[char].To = Vector2.new(screenPos.X, screenPos.Y)
                Lines[char].Color = currentLineColor
                Lines[char].Visible = true
            else Lines[char].Visible = false end

            if not Names[char] then Names[char] = Drawing.new("Text") Names[char].Size = 13 Names[char].Center = true Names[char].Outline = true end
            if (ESPNamesActive or ESPDistanceActive) and onScreen and not isDead then
                local textStr = ""
                if ESPNamesActive then textStr = textStr .. nameToShow end
                if ESPDistanceActive then textStr = textStr .. " [" .. dist .. "m]" end
                Names[char].Text = textStr
                Names[char].Position = Vector2.new(screenPos.X, screenPos.Y - 22)
                Names[char].Color = activeColor
                Names[char].Visible = true
            else Names[char].Visible = false end
        else
            if Boxes[char] then Boxes[char].Visible = false end
            if Lines[char] then Lines[char].Visible = false end
            if Names[char] then Names[char].Visible = false end
        end
    end
end)

ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
updateUIStrings()
