-- ============================================
-- PAINEL DO CRIS - ULTIMATE VIP (AIMBOT + SPINBOT SPEED + AIMKILL)
-- ============================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Limpar versão antiga se existir
if CoreGui:FindFirstChild("CrisTabHub") then
    CoreGui.CrisTabHub:Destroy()
end

-- Variáveis de Estado
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

local NoclipActive = false
local FlyActive = false
local FlySpeed = 50
local SpinActive = false
local SpinSpeedPercent = 0.3 -- 0 a 1 (Velocidade do Giro)
local AimKillActive = false

-- ScreenGui Principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CrisTabHub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- ============================================
-- 1. CÍRCULO FOV & AIMBOT
-- ============================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Radius = 100
FOVCircle.Filled = false
FOVCircle.Visible = false

local function getClosestPlayerToCursor()
    local target = nil
    local shortestDist = math.huge
    local screenSize = Camera.ViewportSize
    local center = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
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
                    target = head
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if Camera then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = 10 + (FOVRadiusPercent * 240)
    end

    if AimbotActive and FOVVisible then
        local targetHead = getClosestPlayerToCursor()
        if targetHead then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
        end
    end
end)

-- ============================================
-- 2. BOLINHA FLUTUANTE
-- ============================================
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
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
-- 3. PAINEL PRINCIPAL
-- ============================================
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
MainFrame.Position = UDim2.new(0.5, -140, 0.1, 0)
MainFrame.Size = UDim2.new(0, 280, 0, 440)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 2.5

-- Borda RGB Animada
RunService.RenderStepped:Connect(function()
    local hue = (tick() % 5) / 5
    local rgbColor = Color3.fromHSV(hue, 1, 1)
    MainStroke.Color = rgbColor
    ToggleStroke.Color = rgbColor
end)

-- Título (Cris)
local TitleLabel = Instance.new("TextLabel", MainFrame)
TitleLabel.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.Text = "PAINEL DO CRIS"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
Instance.new("UICorner", TitleLabel).CornerRadius = UDim.new(0, 10)

-- Contêiner das Abas
local TabBar = Instance.new("Frame", MainFrame)
TabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TabBar.Position = UDim2.new(0, 5, 0, 40)
TabBar.Size = UDim2.new(1, -10, 0, 30)
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 6)

local function createTabBtn(text, posX, width)
    local btn = Instance.new("TextButton", TabBar)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    btn.Position = UDim2.new(0, posX, 0, 2)
    btn.Size = UDim2.new(0, width, 1, -4)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 9
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    return btn
end

local TabBtnESP = createTabBtn("ESP", 2, 48)
local TabBtnAim = createTabBtn("AIMBOT", 52, 52)
local TabBtnSpeed = createTabBtn("VELOCIDADE", 106, 68)
local TabBtnHack = createTabBtn("HACKS", 176, 48)
local TabBtnMap = createTabBtn("🗺️ MAPA", 226, 42)

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 10, 0, 75)
ContentFrame.Size = UDim2.new(1, -20, 1, -85)

local function createPage()
    local page = Instance.new("Frame", ContentFrame)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
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

local function createButton(parent, text, posY)
    local btn = Instance.new("TextButton", parent)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    btn.Position = UDim2.new(0, 5, 0, posY)
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

-- ============================================
-- ABA 1: ESP
-- ============================================
local ESPHoloBtn = createButton(PageESP, "👁️ ESP Holograma: DESLIGADO", 0)
local ESPNameBtn = createButton(PageESP, "🏷️ ESP Name: DESLIGADO", 35)
local ESPBoxBtn = createButton(PageESP, "📦 ESP Box: DESLIGADO", 70)
local ESPLineBtn = createButton(PageESP, "📏 ESP Linha: DESLIGADO", 105)
local ESPLinePosBtn = createButton(PageESP, "📐 Linha: BAIXO", 140)
local ESPDistBtn = createButton(PageESP, "📍 ESP Distância: DESLIGADO", 175)

local ColorPickerBtn = Instance.new("TextButton", PageESP)
ColorPickerBtn.BackgroundColor3 = ESPColor
ColorPickerBtn.Position = UDim2.new(0, 5, 0, 215)
ColorPickerBtn.Size = UDim2.new(1, -10, 0, 30)
ColorPickerBtn.Text = "🎨 Cor do ESP (RGB)"
ColorPickerBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
ColorPickerBtn.TextSize = 11
ColorPickerBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ColorPickerBtn).CornerRadius = UDim.new(0, 6)

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
local AimbotBtn = createButton(PageAim, "🎯 Aimbot Cabeça: DESLIGADO", 35)

local FOVLabel = Instance.new("TextLabel", PageAim)
FOVLabel.BackgroundTransparency = 1
FOVLabel.Position = UDim2.new(0, 5, 0, 75)
FOVLabel.Size = UDim2.new(1, -10, 0, 20)
FOVLabel.Text = "Tamanho da Bolinha: 50%"
FOVLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVLabel.TextSize = 12
FOVLabel.Font = Enum.Font.GothamMedium

local FOVSliderBg = Instance.new("Frame", PageAim)
FOVSliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
FOVSliderBg.Position = UDim2.new(0, 10, 0, 100)
FOVSliderBg.Size = UDim2.new(1, -20, 0, 18)
Instance.new("UICorner", FOVSliderBg).CornerRadius = UDim.new(1, 0)

local FOVSliderFill = Instance.new("Frame", FOVSliderBg)
FOVSliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
FOVSliderFill.Size = UDim2.new(0.5, 0, 1, 0)
Instance.new("UICorner", FOVSliderFill).CornerRadius = UDim.new(1, 0)

local FOVSliderBtn = Instance.new("TextButton", FOVSliderBg)
FOVSliderBtn.BackgroundTransparency = 1
FOVSliderBtn.Size = UDim2.new(1, 0, 1, 0)
FOVSliderBtn.Text = ""

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

local SpeedSliderBg = Instance.new("Frame", PageSpeed)
SpeedSliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
SpeedSliderBg.Position = UDim2.new(0, 10, 0, 40)
SpeedSliderBg.Size = UDim2.new(1, -20, 0, 20)
Instance.new("UICorner", SpeedSliderBg).CornerRadius = UDim.new(1, 0)

local SpeedSliderFill = Instance.new("Frame", SpeedSliderBg)
SpeedSliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SpeedSliderFill.Size = UDim2.new(0, 0, 1, 0)
Instance.new("UICorner", SpeedSliderFill).CornerRadius = UDim.new(1, 0)

local SpeedSliderBtn = Instance.new("TextButton", SpeedSliderBg)
SpeedSliderBtn.BackgroundTransparency = 1
SpeedSliderBtn.Size = UDim2.new(1, 0, 1, 0)
SpeedSliderBtn.Text = ""

-- ============================================
-- ABA 4: HACKS (NOCLIP, FLY, SPINBOT + SLIDER, AIMKILL)
-- ============================================
local NoclipBtn = createButton(PageHack, "🧱 Atravessar Parede: DESLIGADO", 0)
local FlyBtn = createButton(PageHack, "🕊️ Voar (Fly): DESLIGADO", 40)
local SpinBtn = createButton(PageHack, "🌀 Girar Personagem (Spin): DESLIGADO", 80)

local SpinLabel = Instance.new("TextLabel", PageHack)
SpinLabel.BackgroundTransparency = 1
SpinLabel.Position = UDim2.new(0, 5, 0, 115)
SpinLabel.Size = UDim2.new(1, -10, 0, 20)
SpinLabel.Text = "Velocidade do Giro: 30%"
SpinLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpinLabel.TextSize = 11
SpinLabel.Font = Enum.Font.GothamMedium

local SpinSliderBg = Instance.new("Frame", PageHack)
SpinSliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
SpinSliderBg.Position = UDim2.new(0, 10, 0, 138)
SpinSliderBg.Size = UDim2.new(1, -20, 0, 16)
Instance.new("UICorner", SpinSliderBg).CornerRadius = UDim.new(1, 0)

local SpinSliderFill = Instance.new("Frame", SpinSliderBg)
SpinSliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SpinSliderFill.Size = UDim2.new(0.3, 0, 1, 0)
Instance.new("UICorner", SpinSliderFill).CornerRadius = UDim.new(1, 0)

local SpinSliderBtn = Instance.new("TextButton", SpinSliderBg)
SpinSliderBtn.BackgroundTransparency = 1
SpinSliderBtn.Size = UDim2.new(1, 0, 1, 0)
SpinSliderBtn.Text = ""

local AimKillBtn = createButton(PageHack, "💥 Aimkill (Kill Proximidade): DESLIGADO", 165)

-- ============================================
-- ABA 5: MAPA / JOGADORES (LISTA + TELEPORTE)
-- ============================================
local MapHeader = Instance.new("TextLabel", PageMap)
MapHeader.BackgroundTransparency = 1
MapHeader.Position = UDim2.new(0, 5, 0, 0)
MapHeader.Size = UDim2.new(1, -10, 0, 20)
MapHeader.Text = "Jogadores no Jogo: 0"
MapHeader.TextColor3 = Color3.fromRGB(0, 170, 255)
MapHeader.TextSize = 13
MapHeader.Font = Enum.Font.GothamBold

local PlayerScroll = Instance.new("ScrollingFrame", PageMap)
PlayerScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
PlayerScroll.Position = UDim2.new(0, 5, 0, 25)
PlayerScroll.Size = UDim2.new(1, -10, 1, -30)
PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScroll.ScrollBarThickness = 4
Instance.new("UICorner", PlayerScroll).CornerRadius = UDim.new(0, 6)

local UIListLayout = Instance.new("UIListLayout", PlayerScroll)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

local function refreshPlayerList()
    for _, child in pairs(PlayerScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local playerList = Players:GetPlayers()
    MapHeader.Text = "Jogadores no Jogo: " .. #playerList

    for _, targetPlayer in pairs(playerList) do
        if targetPlayer ~= LocalPlayer then
            local pBtn = Instance.new("TextButton", PlayerScroll)
            pBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            pBtn.Size = UDim2.new(1, -8, 0, 30)
            pBtn.Text = "⚡ " .. targetPlayer.DisplayName .. " (@" .. targetPlayer.Name .. ")"
            pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            pBtn.TextSize = 11
            pBtn.Font = Enum.Font.GothamMedium
            Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)

            pBtn.MouseButton1Click:Connect(function()
                if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                        pBtn.Text = "✅ Teleportado!"
                        task.wait(1)
                        pBtn.Text = "⚡ " .. targetPlayer.DisplayName .. " (@" .. targetPlayer.Name .. ")"
                    end
                else
                    pBtn.Text = "❌ Personagem Ausente"
                    task.wait(1)
                    pBtn.Text = "⚡ " .. targetPlayer.DisplayName .. " (@" .. targetPlayer.Name .. ")"
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
-- LÓGICA DE SPINBOT & AIMKILL
-- ============================================
SpinBtn.MouseButton1Click:Connect(function()
    SpinActive = not SpinActive
    SpinBtn.Text = "🌀 Girar Personagem (Spin): " .. (SpinActive and "LIGADO" or "DESLIGADO")
    SpinBtn.BackgroundColor3 = SpinActive and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(40, 40, 55)
end)

-- Slider de Velocidade do Giro (Até 5% / Ajustável)
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

RunService.RenderStepped:Connect(function()
    if SpinActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local speedMultiplier = 5 + (SpinSpeedPercent * 45) -- Varia a velocidade de rotação
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(speedMultiplier), 0)
    end
end)

-- Aimkill (Kill Automático por Proximidade)
AimKillBtn.MouseButton1Click:Connect(function()
    AimKillActive = not AimKillActive
    AimKillBtn.Text = "💥 Aimkill (Kill Proximidade): " .. (AimKillActive and "LIGADO" or "DESLIGADO")
    AimKillBtn.BackgroundColor3 = AimKillActive and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(40, 40, 55)
end)

RunService.Heartbeat:Connect(function()
    if AimKillActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myHRP = LocalPlayer.Character.HumanoidRootPart
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
                local enemyHRP = p.Character.HumanoidRootPart
                local dist = (myHRP.Position - enemyHRP.Position).Magnitude
                if dist <= 12 then -- Se chegar a 12 studs de proximidade
                    pcall(function()
                        p.Character.Humanoid.Health = 0 -- Mata automaticamente
                    end)
                end
            end
        end
    end
end)

-- ============================================
-- LÓGICA DOS OUTROS SISTEMAS
-- ============================================

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

ESPLinePosBtn.MouseButton1Click:Connect(function()
    LineOriginTop = not LineOriginTop
    ESPLinePosBtn.Text = "📐 Linha: " .. (LineOriginTop and "CIMA" or "BAIXO")
end)

local espHighlights = {}
ESPHoloBtn.MouseButton1Click:Connect(function()
    ESPHoloActive = not ESPHoloActive
    ESPHoloBtn.Text = "👁️ ESP Holograma: " .. (ESPHoloActive and "LIGADO" or "DESLIGADO")
    ESPHoloBtn.BackgroundColor3 = ESPHoloActive and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(40, 40, 55)
    if not ESPHoloActive then
        for _, hl in pairs(espHighlights) do pcall(function() hl:Destroy() end) end
        espHighlights = {}
    end
end)

ESPNameBtn.MouseButton1Click:Connect(function()
    ESPNamesActive = not ESPNamesActive
    ESPNameBtn.Text = "🏷️ ESP Name: " .. (ESPNamesActive and "LIGADO" or "DESLIGADO")
    ESPNameBtn.BackgroundColor3 = ESPNamesActive and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(40, 40, 55)
end)

ESPBoxBtn.MouseButton1Click:Connect(function()
    ESPBoxActive = not ESPBoxActive
    ESPBoxBtn.Text = "📦 ESP Box: " .. (ESPBoxActive and "LIGADO" or "DESLIGADO")
    ESPBoxBtn.BackgroundColor3 = ESPBoxActive and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(40, 40, 55)
end)

ESPLineBtn.MouseButton1Click:Connect(function()
    ESPLinesActive = not ESPLinesActive
    ESPLineBtn.Text = "📏 ESP Linha: " .. (ESPLinesActive and "LIGADO" or "DESLIGADO")
    ESPLineBtn.BackgroundColor3 = ESPLinesActive and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(40, 40, 55)
end)

ESPDistBtn.MouseButton1Click:Connect(function()
    ESPDistanceActive = not ESPDistanceActive
    ESPDistBtn.Text = "📍 ESP Distância: " .. (ESPDistanceActive and "LIGADO" or "DESLIGADO")
    ESPDistBtn.BackgroundColor3 = ESPDistanceActive and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(40, 40, 55)
end)

-- RENDERIZADOR ESP
local Boxes, Lines, Names = {}, {}, {}

RunService.RenderStepped:Connect(function()
    if ESPHoloActive then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                if not espHighlights[p] or not espHighlights[p].Parent then
                    pcall(function()
                        local hl = Instance.new("Highlight")
                        hl.Name = "CrisHolo"
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
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

-- FOV & Aimbot Buttons
FOVToggleBtn.MouseButton1Click:Connect(function()
    FOVVisible = not FOVVisible
    FOVCircle.Visible = FOVVisible
    FOVToggleBtn.Text = "⚪ Bolinha da Tela (FOV): " .. (FOVVisible and "LIGADO" or "DESLIGADO")
    FOVToggleBtn.BackgroundColor3 = FOVVisible and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(40, 40, 55)
end)

AimbotBtn.MouseButton1Click:Connect(function()
    AimbotActive = not AimbotActive
    AimbotBtn.Text = "🎯 Aimbot Cabeça: " .. (AimbotActive and "LIGADO" or "DESLIGADO")
    AimbotBtn.BackgroundColor3 = AimbotActive and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(40, 40, 55)
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

-- Velocidade
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

-- Noclip & Fly
NoclipBtn.MouseButton1Click:Connect(function()
    NoclipActive = not NoclipActive
    NoclipBtn.Text = "🧱 Atravessar Parede: " .. (NoclipActive and "LIGADO" or "DESLIGADO")
    NoclipBtn.BackgroundColor3 = NoclipActive and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(40, 40, 55)
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
    FlyBtn.BackgroundColor3 = FlyActive and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(40, 40, 55)
    
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
        BodyGyro.cframe = Camera.CFrame
        BodyVelocity.velocity = Camera.CFrame.LookVector * FlySpeed
    end
end)
