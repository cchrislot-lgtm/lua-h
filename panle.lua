-- ============================================
-- PAINEL DO CRIS - ULTIMATE VIP (PLEXUS + CLEAN ESP + FLY SPEED + BRING)
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
local ESPHoloActive = false
local ESPNamesActive = false
local ESPBoxActive = false
local ESPLinesActive = false
local ESPDistanceActive = false
local LineOriginTop = false
local ESPColor = Color3.fromRGB(0, 255, 150)

local FOVVisible = false
local FOVRadiusPercent = 0.5
local AimbotActive = false
local AutoShootActive = false

local NoclipActive = false
local FlyActive = false
local FlySpeedPercent = 0.3 -- 0 a 1 (Velocidade do Voo)
local SpinActive = false
local SpinSpeedPercent = 0.3

-- ScreenGui Principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CrisTabHub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- ============================================
-- 1. CÍRCULO FOV
-- ============================================
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

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local head = p.Character.Head
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
                    task.wait(0.05)
                    VirtualUser:Button1Up(Vector2.new(0, 0))
                end
            end
        end)
    end
end)

-- ============================================
-- 2. BOLINHA FLUTUANTE
-- ============================================
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
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

-- ============================================
-- 3. PAINEL PRINCIPAL COM EFEITO PLEXUS
-- ============================================
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.Position = UDim2.new(0.5, -145, 0.1, 0)
MainFrame.Size = UDim2.new(0, 290, 0, 460)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 2.5

-- Fundo Plexus (Animação de Nós e Linhas)
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
        pos = Vector2.new(math.random(10, 280), math.random(10, 450)),
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
        if node.pos.X < 5 or node.pos.X > 285 then node.vel = Vector2.new(-node.vel.X, node.vel.Y) end
        if node.pos.Y < 5 or node.pos.Y > 455 then node.vel = Vector2.new(node.vel.X, -node.vel.Y) end
        node.gui.Position = UDim2.new(0, node.pos.X, 0, node.pos.Y)
    end
end)

-- Título
local TitleLabel = Instance.new("TextLabel", MainFrame)
TitleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
TitleLabel.Size = UDim2.new(1, 0, 0, 38)
TitleLabel.Text = "PAINEL DO CRIS - ULTIMATE"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.ZIndex = 2
Instance.new("UICorner", TitleLabel).CornerRadius = UDim.new(0, 12)

-- Contêiner das Abas
local TabBar = Instance.new("Frame", MainFrame)
TabBar.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
TabBar.Position = UDim2.new(0, 8, 0, 44)
TabBar.Size = UDim2.new(1, -16, 0, 32)
TabBar.ZIndex = 2
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 8)

local function createTabBtn(text, posX, width)
    local btn = Instance.new("TextButton", TabBar)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 48)
    btn.Position = UDim2.new(0, posX, 0, 3)
    btn.Size = UDim2.new(0, width, 1, -6)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextSize = 9
    btn.Font = Enum.Font.GothamBold
    btn.ZIndex = 3
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local TabBtnESP = createTabBtn("ESP", 2, 50)
local TabBtnAim = createTabBtn("AIMBOT", 54, 54)
local TabBtnSpeed = createTabBtn("VELOCIDADE", 110, 70)
local TabBtnHack = createTabBtn("HACKS", 182, 48)
local TabBtnMap = createTabBtn("🗺️ MAPA", 232, 42)

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 10, 0, 82)
ContentFrame.Size = UDim2.new(1, -20, 1, -92)
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

PageESP.Visible = true

local function switchTab(activePage, activeBtn)
    PageESP.Visible = false PageAim.Visible = false PageSpeed.Visible = false PageHack.Visible = false PageMap.Visible = false
    TabBtnESP.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtnAim.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtnSpeed.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtnHack.TextColor3 = Color3.fromRGB(150, 150, 150)
    TabBtnMap.TextColor3 = Color3.fromRGB(150, 150, 150)
    activePage.Visible = true
    activeBtn.TextColor3 = Color3.fromRGB(0, 170, 255)
end

TabBtnESP.MouseButton1Click:Connect(function() switchTab(PageESP, TabBtnESP) end)
TabBtnAim.MouseButton1Click:Connect(function() switchTab(PageAim, TabBtnAim) end)
TabBtnSpeed.MouseButton1Click:Connect(function() switchTab(PageSpeed, TabBtnSpeed) end)
TabBtnHack.MouseButton1Click:Connect(function() switchTab(PageHack, TabBtnHack) end)
TabBtnMap.MouseButton1Click:Connect(function() switchTab(PageMap, TabBtnMap) end)

-- Gerador de Botões Estilizados
local function createButton(parent, text, posY)
    local btn = Instance.new("TextButton", parent)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btn.Position = UDim2.new(0, 5, 0, posY)
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.ZIndex = 3

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(50, 50, 75)
    return btn
end

-- ============================================
-- ABA 1: ESP
-- ============================================
local ESPHoloBtn = createButton(PageESP, "👁️ ESP Holograma: DESLIGADO", 0)
local ESPNameBtn = createButton(PageESP, "🏷️ ESP Name: DESLIGADO", 38)
local ESPBoxBtn = createButton(PageESP, "📦 ESP Box: DESLIGADO", 76)
local ESPLineBtn = createButton(PageESP, "📏 ESP Linha: DESLIGADO", 114)
local ESPLinePosBtn = createButton(PageESP, "📐 Linha: BAIXO", 152)
local ESPDistBtn = createButton(PageESP, "📍 ESP Distância: DESLIGADO", 190)

local ColorPickerBtn = createButton(PageESP, "🎨 Cor do ESP (RGB)", 228)
ColorPickerBtn.BackgroundColor3 = ESPColor
ColorPickerBtn.TextColor3 = Color3.fromRGB(0, 0, 0)

local colorList = {Color3.fromRGB(0, 255, 150), Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 170, 255), Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 0, 255)}
local currentColorIdx = 1

ColorPickerBtn.MouseButton1Click:Connect(function()
    currentColorIdx = (currentColorIdx % #colorList) + 1
    ESPColor = colorList[currentColorIdx]
    ColorPickerBtn.BackgroundColor3 = ESPColor
end)

-- ============================================
-- ABA 2: AIMBOT
-- ============================================
local FOVToggleBtn = createButton(PageAim, "⚪ Bolinha da Tela (FOV): DESLIGADO", 0)
local AimbotBtn = createButton(PageAim, "🎯 Aimbot Cabeça (Lock): DESLIGADO", 38)
local AutoShootBtn = createButton(PageAim, "🔫 Atirar Automático: DESLIGADO", 76)

local FOVLabel = Instance.new("TextLabel", PageAim)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Position = UDim2.new(0, 5, 0, 118)
FOVLabel.Size = UDim2.new(1, -10, 0, 20)
FOVLabel.Text = "Tamanho da Bolinha: 50%"
FOVLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVLabel.TextSize = 11
FOVLabel.Font = Enum.Font.GothamMedium
FOVLabel.ZIndex = 3

local FOVSliderBg = Instance.new("Frame", PageAim)
FOVSliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
FOVSliderBg.Position = UDim2.new(0, 10, 0, 142)
FOVSliderBg.Size = UDim2.new(1, -20, 0, 16)
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

-- ============================================
-- ABA 3: VELOCIDADE
-- ============================================
local SpeedLabel = Instance.new("TextLabel", PageSpeed)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Position = UDim2.new(0, 5, 0, 10)
SpeedLabel.Size = UDim2.new(1, -10, 0, 20)
SpeedLabel.Text = "Velocidade do Personagem: 0%"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.GothamMedium
SpeedLabel.ZIndex = 3

local SpeedSliderBg = Instance.new("Frame", PageSpeed)
SpeedSliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
SpeedSliderBg.Position = UDim2.new(0, 10, 0, 40)
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

-- ============================================
-- ABA 4: HACKS (NOCLIP, FLY + SPEED SLIDER, SPIN)
-- ============================================
local NoclipBtn = createButton(PageHack, "🧱 Atravessar Parede: DESLIGADO", 0)
local FlyBtn = createButton(PageHack, "🕊️ Voar (Fly): DESLIGADO", 38)

-- Slider de Velocidade de Voo (Até 100%)
local FlyLabel = Instance.new("TextLabel", PageHack)
FlyLabel.BackgroundTransparency = 1
FlyLabel.Position = UDim2.new(0, 5, 0, 74)
FlyLabel.Size = UDim2.new(1, -10, 0, 18)
FlyLabel.Text = "Velocidade do Voo: 30%"
FlyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyLabel.TextSize = 11
FlyLabel.Font = Enum.Font.GothamMedium
FlyLabel.ZIndex = 3

local FlySliderBg = Instance.new("Frame", PageHack)
FlySliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
FlySliderBg.Position = UDim2.new(0, 10, 0, 94)
FlySliderBg.Size = UDim2.new(1, -20, 0, 14)
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

local SpinBtn = createButton(PageHack, "🌀 Girar Personagem (Spin): DESLIGADO", 118)

local SpinLabel = Instance.new("TextLabel", PageHack)
SpinLabel.BackgroundTransparency = 1
SpinLabel.Position = UDim2.new(0, 5, 0, 154)
SpinLabel.Size = UDim2.new(1, -10, 0, 18)
SpinLabel.Text = "Velocidade do Giro: 30%"
SpinLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpinLabel.TextSize = 11
SpinLabel.Font = Enum.Font.GothamMedium
SpinLabel.ZIndex = 3

local SpinSliderBg = Instance.new("Frame", PageHack)
SpinSliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
SpinSliderBg.Position = UDim2.new(0, 10, 0, 174)
SpinSliderBg.Size = UDim2.new(1, -20, 0, 14)
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

-- ============================================
-- ABA 5: MAPA (IR ATÉ / TRAZER JOGADOR)
-- ============================================
local MapHeader = Instance.new("TextLabel", PageMap)
MapHeader.BackgroundTransparency = 1
MapHeader.Position = UDim2.new(0, 5, 0, 0)
MapHeader.Size = UDim2.new(1, -10, 0, 20)
MapHeader.Text = "Jogadores no Jogo: 0"
MapHeader.TextColor3 = Color3.fromRGB(0, 170, 255)
MapHeader.TextSize = 12
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
UIListLayout.Padding = UDim.new(0, 6)

local function refreshPlayerList()
    for _, child in pairs(PlayerScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local playerList = Players:GetPlayers()
    MapHeader.Text = "Jogadores no Jogo: " .. #playerList

    for _, targetPlayer in pairs(playerList) do
        if targetPlayer ~= LocalPlayer then
            local card = Instance.new("Frame", PlayerScroll)
            card.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            card.Size = UDim2.new(1, -8, 0, 36)
            card.ZIndex = 3
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

            local pName = Instance.new("TextLabel", card)
            pName.BackgroundTransparency = 1
            pName.Position = UDim2.new(0, 8, 0, 0)
            pName.Size = UDim2.new(0.5, 0, 1, 0)
            pName.Text = targetPlayer.DisplayName
            pName.TextColor3 = Color3.fromRGB(255, 255, 255)
            pName.TextSize = 10
            pName.Font = Enum.Font.GothamBold
            pName.TextXAlignment = Enum.TextXAlignment.Left
            pName.ZIndex = 3

            -- Botão: Ir Até
            local tpToBtn = Instance.new("TextButton", card)
            tpToBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            tpToBtn.Position = UDim2.new(0.52, 0, 0.15, 0)
            tpToBtn.Size = UDim2.new(0.22, 0, 0.7, 0)
            tpToBtn.Text = "Ir até"
            tpToBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            tpToBtn.TextSize = 9
            tpToBtn.Font = Enum.Font.GothamBold
            tpToBtn.ZIndex = 4
            Instance.new("UICorner", tpToBtn).CornerRadius = UDim.new(0, 4)

            tpToBtn.MouseButton1Click:Connect(function()
                if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                end
            end)

            -- Botão: Trazer
            local bringBtn = Instance.new("TextButton", card)
            bringBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
            bringBtn.Position = UDim2.new(0.76, 0, 0.15, 0)
            bringBtn.Size = UDim2.new(0.22, 0, 0.7, 0)
            bringBtn.Text = "Trazer"
            bringBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            bringBtn.TextSize = 9
            bringBtn.Font = Enum.Font.GothamBold
            bringBtn.ZIndex = 4
            Instance.new("UICorner", bringBtn).CornerRadius = UDim.new(0, 4)

            bringBtn.MouseButton1Click:Connect(function()
                if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    targetPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                end
            end)
        end
    end
    PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)
TabBtnMap.MouseButton1Click:Connect(refreshPlayerList)

-- ============================================
-- LÓGICA DE EVENTOS E LIMPEZA DE BUGS ESP
-- ============================================

local Boxes, Lines, Names, espHighlights = {}, {}, {}, {}

local function clearESP()
    for _, b in pairs(Boxes) do b.Visible = false end
    for _, l in pairs(Lines) do l.Visible = false end
    for _, n in pairs(Names) do n.Visible = false end
    for _, hl in pairs(espHighlights) do pcall(function() hl:Destroy() end) end
    espHighlights = {}
end

ESPHoloBtn.MouseButton1Click:Connect(function()
    ESPHoloActive = not ESPHoloActive
    ESPHoloBtn.Text = "👁️ ESP Holograma: " .. (ESPHoloActive and "LIGADO" or "DESLIGADO")
    ESPHoloBtn.BackgroundColor3 = ESPHoloActive and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(30, 30, 45)
    if not ESPHoloActive then clearESP() end
end)

ESPNameBtn.MouseButton1Click:Connect(function()
    ESPNamesActive = not ESPNamesActive
    ESPNameBtn.Text = "🏷️ ESP Name: " .. (ESPNamesActive and "LIGADO" or "DESLIGADO")
    ESPNameBtn.BackgroundColor3 = ESPNamesActive and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(30, 30, 45)
    if not ESPNamesActive then clearESP() end
end)

ESPBoxBtn.MouseButton1Click:Connect(function()
    ESPBoxActive = not ESPBoxActive
    ESPBoxBtn.Text = "📦 ESP Box: " .. (ESPBoxActive and "LIGADO" or "DESLIGADO")
    ESPBoxBtn.BackgroundColor3 = ESPBoxActive and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(30, 30, 45)
    if not ESPBoxActive then clearESP() end
end)

ESPLineBtn.MouseButton1Click:Connect(function()
    ESPLinesActive = not ESPLinesActive
    ESPLineBtn.Text = "📏 ESP Linha: " .. (ESPLinesActive and "LIGADO" or "DESLIGADO")
    ESPLineBtn.BackgroundColor3 = ESPLinesActive and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(30, 30, 45)
    if not ESPLinesActive then clearESP() end
end)

ESPDistBtn.MouseButton1Click:Connect(function()
    ESPDistanceActive = not ESPDistanceActive
    ESPDistBtn.Text = "📍 ESP Distância: " .. (ESPDistanceActive and "LIGADO" or "DESLIGADO")
    ESPDistBtn.BackgroundColor3 = ESPDistanceActive and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(30, 30, 45)
    if not ESPDistanceActive then clearESP() end
end)

ESPLinePosBtn.MouseButton1Click:Connect(function()
    LineOriginTop = not LineOriginTop
    ESPLinePosBtn.Text = "📐 Linha: " .. (LineOriginTop and "CIMA" or "BAIXO")
end)

-- RENDERIZADOR ESP
RunService.RenderStepped:Connect(function()
    if ESPHoloActive then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                if not espHighlights[p] or not espHighlights[p].Parent then
                    pcall(function()
                        local hl = Instance.new("Highlight")
                        hl.Name = "CrisHolo"
                        hl.FillColor = ESPColor
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.3
                        hl.Adornee = p.Character
                        hl.Parent = p.Character
                        espHighlights[p] = hl
                    end)
                end
            end
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local hrp = p.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local dist = myHRP and math.floor((myHRP.Position - hrp.Position).Magnitude) or 0

            if not Boxes[p] then Boxes[p] = Drawing.new("Square") Boxes[p].Thickness = 1.5 Boxes[p].Filled = false end
            if ESPBoxActive and onScreen then
                local headPart = p.Character:FindFirstChild("Head")
                if headPart then
                    local headPos = Camera:WorldToViewportPoint(headPart.Position + Vector3.new(0, 0.5, 0))
                    local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    local boxHeight = math.abs(headPos.Y - legPos.Y)
                    local boxWidth = boxHeight / 1.5
                    Boxes[p].Size = Vector2.new(boxWidth, boxHeight)
                    Boxes[p].Position = Vector2.new(screenPos.X - (boxWidth / 2), headPos.Y)
                    Boxes[p].Color = ESPColor
                    Boxes[p].Visible = true
                else Boxes[p].Visible = false end
            else Boxes[p].Visible = false end

            if not Lines[p] then Lines[p] = Drawing.new("Line") Lines[p].Thickness = 1.5 end
            if ESPLinesActive and onScreen then
                local startY = LineOriginTop and 0 or Camera.ViewportSize.Y
                Lines[p].From = Vector2.new(Camera.ViewportSize.X / 2, startY)
                Lines[p].To = Vector2.new(screenPos.X, screenPos.Y)
                Lines[p].Color = ESPColor
                Lines[p].Visible = true
            else Lines[p].Visible = false end

            if not Names[p] then Names[p] = Drawing.new("Text") Names[p].Size = 13 Names[p].Center = true Names[p].Outline = true end
            if (ESPNamesActive or ESPDistanceActive) and onScreen then
                local textStr = ""
                if ESPNamesActive then textStr = textStr .. p.DisplayName end
                if ESPDistanceActive then textStr = textStr .. " [" .. dist .. "m]" end
                Names[p].Text = textStr
                Names[p].Position = Vector2.new(screenPos.X, screenPos.Y - 22)
                Names[p].Color = ESPColor
                Names[p].Visible = true
            else Names[p].Visible = false end
        else
            if Boxes[p] then Boxes[p].Visible = false end
            if Lines[p] then Lines[p].Visible = false end
            if Names[p] then Names[p].Visible = false end
        end
    end
end)

-- SLIDERS (FLY SPEED & SPIN SPEED)
local draggingFly = false
FlySliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingFly = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingFly = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingFly and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mouseX = input.Position.X
        local sliderX = FlySliderBg.AbsolutePosition.X
        local sliderWidth = FlySliderBg.AbsoluteSize.X
        FlySpeedPercent = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
        FlySliderFill.Size = UDim2.new(FlySpeedPercent, 0, 1, 0)
        FlyLabel.Text = "Velocidade do Voo: " .. math.floor(FlySpeedPercent * 100) .. "%"
    end
end)

local draggingSpin = false
SpinSliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSpin = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSpin = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingSpin and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mouseX = input.Position.X
        local sliderX = SpinSliderBg.AbsolutePosition.X
        local sliderWidth = SpinSliderBg.AbsoluteSize.X
        SpinSpeedPercent = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
        SpinSliderFill.Size = UDim2.new(SpinSpeedPercent, 0, 1, 0)
        SpinLabel.Text = "Velocidade do Giro: " .. math.floor(SpinSpeedPercent * 100) .. "%"
    end
end)

SpinBtn.MouseButton1Click:Connect(function()
    SpinActive = not SpinActive
    SpinBtn.Text = "🌀 Girar Personagem (Spin): " .. (SpinActive and "LIGADO" or "DESLIGADO")
    SpinBtn.BackgroundColor3 = SpinActive and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(30, 30, 45)
end)

RunService.RenderStepped:Connect(function()
    if SpinActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local speedMultiplier = 5 + (SpinSpeedPercent * 45)
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(speedMultiplier), 0)
    end
end)

-- NOCLIP & FLY CONTROLS
NoclipBtn.MouseButton1Click:Connect(function()
    NoclipActive = not NoclipActive
    NoclipBtn.Text = "🧱 Atravessar Parede: " .. (NoclipActive and "LIGADO" or "DESLIGADO")
    NoclipBtn.BackgroundColor3 = NoclipActive and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(30, 30, 45)
end)

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
    FlyBtn.Text = "🕊️ Voar (Fly): " .. (FlyActive and "LIGADO" or "DESLIGADO")
    FlyBtn.BackgroundColor3 = FlyActive and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(30, 30, 45)
    
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
        local currentFlySpeed = 20 + (FlySpeedPercent * 180) -- Ajusta de 20 até 200 de velocidade
        BodyGyro.cframe = Camera.CFrame
        BodyVelocity.velocity = Camera.CFrame.LookVector * currentFlySpeed
    end
end)

-- TOGGLE PAINEL & DEMAIS
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

FOVToggleBtn.MouseButton1Click:Connect(function()
    FOVVisible = not FOVVisible
    FOVCircle.Visible = FOVVisible
    FOVToggleBtn.Text = "⚪ Bolinha da Tela (FOV): " .. (FOVVisible and "LIGADO" or "DESLIGADO")
    FOVToggleBtn.BackgroundColor3 = FOVVisible and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(30, 30, 45)
end)

AimbotBtn.MouseButton1Click:Connect(function()
    AimbotActive = not AimbotActive
    AimbotBtn.Text = "🎯 Aimbot Cabeça (Lock): " .. (AimbotActive and "LIGADO" or "DESLIGADO")
    AimbotBtn.BackgroundColor3 = AimbotActive and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(30, 30, 45)
end)

AutoShootBtn.MouseButton1Click:Connect(function()
    AutoShootActive = not AutoShootActive
    AutoShootBtn.Text = "🔫 Atirar Automático: " .. (AutoShootActive and "LIGADO" or "DESLIGADO")
    AutoShootBtn.BackgroundColor3 = AutoShootActive and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(30, 30, 45)
end)

local draggingFOV = false
FOVSliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingFOV = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingFOV = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingFOV and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mouseX = input.Position.X
        local sliderX = FOVSliderBg.AbsolutePosition.X
        local sliderWidth = FOVSliderBg.AbsoluteSize.X
        FOVRadiusPercent = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
        FOVSliderFill.Size = UDim2.new(FOVRadiusPercent, 0, 1, 0)
        FOVLabel.Text = "Tamanho da Bolinha: " .. math.floor(FOVRadiusPercent * 100) .. "%"
    end
end)

local draggingSpeed = false
local function updateSpeed(percentage)
    local minSpd, maxSpd = 16, 300
    local finalSpeed = minSpd + ((maxSpd - minSpd) * percentage)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = finalSpeed
    end
    SpeedLabel.Text = "Velocidade do Personagem: " .. math.floor(percentage * 100) .. "%"
end

SpeedSliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSpeed = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSpeed = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingSpeed and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mouseX = input.Position.X
        local sliderX = SpeedSliderBg.AbsolutePosition.X
        local sliderWidth = SpeedSliderBg.AbsoluteSize.X
        local pct = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
        SpeedSliderFill.Size = UDim2.new(pct, 0, 1, 0)
        updateSpeed(pct)
    end
end)
