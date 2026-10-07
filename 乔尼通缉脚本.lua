---关注抖音抖音号:asdyuanshen7
---Kenny脚本群1019547871（五百人群）
---sp源码分享协会727992470
-- 缝合脚本
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
WindUI.TransparencyValue = 0.2
WindUI:SetTheme("Dark")

local rainbowBorderAnimation
local currentBorderColorScheme = "彩虹颜色"
local currentFontColorScheme = "彩虹颜色"
local borderInitialized = false
local animationSpeed = 2
local borderEnabled = true
local fontColorEnabled = false
local uiScale = 1
local blurEnabled = false
local soundEnabled = true

local FONT_STYLES = {
    "SourceSansBold","SourceSansItalic","SourceSansLight","SourceSans",
    "GothamSSm","GothamSSm-Bold","GothamSSm-Medium","GothamSSm-Light",
    "GothamSSm-Black","GothamSSm-Book","GothamSSm-XLight","GothamSSm-Thin",
    "GothamSSm-Ultra","GothamSSm-SemiBold","GothamSSm-ExtraLight","GothamSSm-Heavy",
    "GothamSSm-ExtraBold","GothamSSm-Regular","Gotham","GothamBold",
    "GothamMedium","GothamBlack","GothamLight","Arial","ArialBold",
    "Code","CodeLight","CodeBold","Highway","HighwayBold","HighwayLight",
    "SciFi","SciFiBold","SciFiItalic","Cartoon","CartoonBold","Handwritten"
}
local FONT_DESCRIPTIONS = {
    ["SourceSansBold"]="标准粗体",["SourceSansItalic"]="斜体",["SourceSansLight"]="细体",
    ["SourceSans"]="标准体",["GothamSSm"]="哥特标准",["GothamSSm-Bold"]="哥特粗体",
    ["GothamSSm-Medium"]="哥特中等",["GothamSSm-Light"]="哥特细体",["GothamSSm-Black"]="哥特黑体",
    ["GothamSSm-Book"]="哥特书本体",["GothamSSm-XLight"]="哥特超细体",["GothamSSm-Thin"]="哥特极细体",
    ["GothamSSm-Ultra"]="哥特超黑体",["GothamSSm-SemiBold"]="哥特半粗体",["GothamSSm-ExtraLight"]="哥特特细体",
    ["GothamSSm-Heavy"]="哥特粗重体",["GothamSSm-ExtraBold"]="哥特特粗体",["GothamSSm-Regular"]="哥特常规体",
    ["Gotham"]="经典哥特体",["GothamBold"]="经典哥特粗体",["GothamMedium"]="经典哥特中等",
    ["GothamBlack"]="经典哥特黑体",["GothamLight"]="经典哥特细体",["Arial"]="标准Arial体",
    ["ArialBold"]="Arial粗体",["Code"]="代码字体",["CodeLight"]="代码细体",
    ["CodeBold"]="代码粗体",["Highway"]="高速公路体",["HighwayBold"]="高速公路粗体",
    ["HighwayLight"]="高速公路细体",["SciFi"]="科幻字体",["SciFiBold"]="科幻粗体",
    ["SciFiItalic"]="科幻斜体",["Cartoon"]="卡通字体",["CartoonBold"]="卡通粗体",
    ["Handwritten"]="手写体"
}
local currentFontStyle = "SourceSansBold"

local COLOR_SCHEMES = {
    ["彩虹颜色"]={ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex("FF0000")),ColorSequenceKeypoint.new(0.16,Color3.fromHex("FFA500")),ColorSequenceKeypoint.new(0.33,Color3.fromHex("FFFF00")),ColorSequenceKeypoint.new(0.5,Color3.fromHex("00FF00")),ColorSequenceKeypoint.new(0.66,Color3.fromHex("0000FF")),ColorSequenceKeypoint.new(0.83,Color3.fromHex("4B0082")),ColorSequenceKeypoint.new(1,Color3.fromHex("EE82EE"))}),"palette"},
    ["黑红颜色"]={ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex("000000")),ColorSequenceKeypoint.new(0.5,Color3.fromHex("FF0000")),ColorSequenceKeypoint.new(1,Color3.fromHex("000000"))}),"alert-triangle"},
    ["蓝白颜色"]={ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex("FFFFFF")),ColorSequenceKeypoint.new(0.5,Color3.fromHex("1E90FF")),ColorSequenceKeypoint.new(1,Color3.fromHex("FFFFFF"))}),"droplet"},
    ["紫金颜色"]={ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex("FFD700")),ColorSequenceKeypoint.new(0.5,Color3.fromHex("8A2BE2")),ColorSequenceKeypoint.new(1,Color3.fromHex("FFD700"))}),"crown"},
    ["蓝黑颜色"]={ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex("000000")),ColorSequenceKeypoint.new(0.5,Color3.fromHex("0000FF")),ColorSequenceKeypoint.new(1,Color3.fromHex("000000"))}),"moon"},
    ["绿紫颜色"]={ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex("00FF00")),ColorSequenceKeypoint.new(0.5,Color3.fromHex("800080")),ColorSequenceKeypoint.new(1,Color3.fromHex("00FF00"))}),"zap"},
    ["粉蓝颜色"]={ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex("FF69B4")),ColorSequenceKeypoint.new(0.5,Color3.fromHex("00BFFF")),ColorSequenceKeypoint.new(1,Color3.fromHex("FF69B4"))}),"heart"},
    ["橙青颜色"]={ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex("FF4500")),ColorSequenceKeypoint.new(0.5,Color3.fromHex("00CED1")),ColorSequenceKeypoint.new(1,Color3.fromHex("FF4500"))}),"sun"},
    ["红金颜色"]={ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex("FF0000")),ColorSequenceKeypoint.new(0.5,Color3.fromHex("FFD700")),ColorSequenceKeypoint.new(1,Color3.fromHex("FF0000"))}),"award"},
    ["银蓝颜色"]={ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex("C0C0C0")),ColorSequenceKeypoint.new(0.5,Color3.fromHex("4682B4")),ColorSequenceKeypoint.new(1,Color3.fromHex("C0C0C0"))}),"star"},
    ["霓虹颜色"]={ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex("FF00FF")),ColorSequenceKeypoint.new(0.25,Color3.fromHex("00FFFF")),ColorSequenceKeypoint.new(0.5,Color3.fromHex("FFFF00")),ColorSequenceKeypoint.new(0.75,Color3.fromHex("FF00FF")),ColorSequenceKeypoint.new(1,Color3.fromHex("00FFFF"))}),"sparkles"},
    ["森林颜色"]={ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex("228B22")),ColorSequenceKeypoint.new(0.5,Color3.fromHex("32CD32")),ColorSequenceKeypoint.new(1,Color3.fromHex("228B22"))}),"tree"},
    ["火焰颜色"]={ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex("FF4500")),ColorSequenceKeypoint.new(0.5,Color3.fromHex("FF0000")),ColorSequenceKeypoint.new(1,Color3.fromHex("FF8C00"))}),"flame"},
    ["海洋颜色"]={ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex("000080")),ColorSequenceKeypoint.new(0.5,Color3.fromHex("1E90FF")),ColorSequenceKeypoint.new(1,Color3.fromHex("00BFFF"))}),"waves"},
    ["日落颜色"]={ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex("FF4500")),ColorSequenceKeypoint.new(0.5,Color3.fromHex("FF8C00")),ColorSequenceKeypoint.new(1,Color3.fromHex("FFD700"))}),"sunset"},
    ["银河颜色"]={ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex("4B0082")),ColorSequenceKeypoint.new(0.5,Color3.fromHex("8A2BE2")),ColorSequenceKeypoint.new(1,Color3.fromHex("9370DB"))}),"galaxy"},
    ["糖果颜色"]={ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex("FF69B4")),ColorSequenceKeypoint.new(0.5,Color3.fromHex("FF1493")),ColorSequenceKeypoint.new(1,Color3.fromHex("FFB6C1"))}),"candy"},
    ["金属颜色"]={ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex("C0C0C0")),ColorSequenceKeypoint.new(0.5,Color3.fromHex("A9A9A9")),ColorSequenceKeypoint.new(1,Color3.fromHex("696969"))}),"shield"}
}
local fontColorAnimations = {}
local function applyFontColorGradient(textElement, colorScheme)
    if not textElement or not textElement:IsA("TextLabel") and not textElement:IsA("TextButton") and not textElement:IsA("TextBox") then return end
    local existingGradient = textElement:FindFirstChild("FontColorGradient")
    if existingGradient then existingGradient:Destroy() end
    if fontColorAnimations[textElement] then fontColorAnimations[textElement]:Disconnect() fontColorAnimations[textElement]=nil end
    if not fontColorEnabled then textElement.TextColor3 = Color3.new(1,1,1) return end
    local schemeData = COLOR_SCHEMES[colorScheme or currentFontColorScheme]
    if not schemeData then return end
    local fontGradient = Instance.new("UIGradient")
    fontGradient.Name="FontColorGradient"
    fontGradient.Color=schemeData[1]
    fontGradient.Rotation=0
    fontGradient.Parent=textElement
    textElement.TextColor3=Color3.new(1,1,1)
    local animation
    animation=game:GetService("RunService").Heartbeat:Connect(function()
        if not textElement or textElement.Parent==nil then animation:Disconnect() fontColorAnimations[textElement]=nil return end
        if not fontGradient or fontGradient.Parent==nil then animation:Disconnect() fontColorAnimations[textElement]=nil return end
        fontGradient.Rotation=(tick()*animationSpeed*30)%360
    end)
    fontColorAnimations[textElement]=animation
end
local function applyFontStyleToWindow(fontStyle)
    if not Window or not Window.UIElements then wait(0.5) if not Window or not Window.UIElements then return false end end
    local successCount,totalCount=0,0
    local function processElement(element)
        for _,child in ipairs(element:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                totalCount=totalCount+1
                pcall(function() child.Font=Enum.Font[fontStyle] successCount=successCount+1 end)
            end
        end
    end
    processElement(Window.UIElements.Main)
    return successCount,totalCount
end
local function applyFontColorsToWindow(colorScheme)
    if not Window or not Window.UIElements then return end
    local function processElement(element)
        for _,child in ipairs(element:GetDescendants()) do
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                applyFontColorGradient(child,colorScheme)
            end
        end
    end
    processElement(Window.UIElements.Main)
end
local function createRainbowBorder(window,colorScheme,speed)
    if not window or not window.UIElements then wait(1) if not window or not window.UIElements then return nil,nil end end
    local mainFrame=window.UIElements.Main
    if not mainFrame then return nil,nil end
    local existingStroke=mainFrame:FindFirstChild("RainbowStroke")
    if existingStroke then
        local glowEffect=existingStroke:FindFirstChild("GlowEffect")
        if glowEffect then
            local schemeData=COLOR_SCHEMES[colorScheme or currentBorderColorScheme]
            if schemeData then glowEffect.Color=schemeData[1] end
        end
        return existingStroke,rainbowBorderAnimation
    end
    if not mainFrame:FindFirstChildOfClass("UICorner") then
        local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,16) corner.Parent=mainFrame
    end
    local rainbowStroke=Instance.new("UIStroke")
    rainbowStroke.Name="RainbowStroke"
    rainbowStroke.Thickness=1.5
    rainbowStroke.Color=Color3.new(1,1,1)
    rainbowStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    rainbowStroke.LineJoinMode=Enum.LineJoinMode.Round
    rainbowStroke.Enabled=borderEnabled
    rainbowStroke.Parent=mainFrame
    local glowEffect=Instance.new("UIGradient")
    glowEffect.Name="GlowEffect"
    local schemeData=COLOR_SCHEMES[colorScheme or currentBorderColorScheme]
    glowEffect.Color=schemeData and schemeData[1] or COLOR_SCHEMES["彩虹颜色"][1]
    glowEffect.Rotation=0
    glowEffect.Parent=rainbowStroke
    return rainbowStroke,nil
end
local function startBorderAnimation(window,speed)
    if not window or not window.UIElements then return nil end
    local mainFrame=window.UIElements.Main
    if not mainFrame then return nil end
    local rainbowStroke=mainFrame:FindFirstChild("RainbowStroke")
    if not rainbowStroke or not rainbowStroke.Enabled then return nil end
    local glowEffect=rainbowStroke:FindFirstChild("GlowEffect")
    if not glowEffect then return nil end
    if rainbowBorderAnimation then rainbowBorderAnimation:Disconnect() rainbowBorderAnimation=nil end
    local animation
    animation=game:GetService("RunService").Heartbeat:Connect(function()
        if not rainbowStroke or rainbowStroke.Parent==nil or not rainbowStroke.Enabled then animation:Disconnect() return end
        glowEffect.Rotation=(tick()*speed*60)%360
    end)
    rainbowBorderAnimation=animation
    return animation
end
local function initializeRainbowBorder(scheme,speed)
    speed=speed or animationSpeed
    local rainbowStroke,_=createRainbowBorder(Window,scheme,speed)
    if rainbowStroke then
        if borderEnabled then startBorderAnimation(Window,speed) end
        borderInitialized=true
        return true
    end
    return false
end
local function playSound()
    if soundEnabled then
        pcall(function()
            local sound=Instance.new("Sound")
            sound.SoundId="rbxassetid://9047002353"
            sound.Volume=0.3
            sound.Parent=game:GetService("SoundService")
            sound:Play()
            game:GetService("Debris"):AddItem(sound,2)
        end)
    end
end
local function applyBlurEffect(enabled)
    if enabled then
        pcall(function()
            local blur=Instance.new("BlurEffect")
            blur.Size=8
            blur.Name="UISX HUBBlur"
            blur.Parent=game:GetService("Lighting")
        end)
    else
        pcall(function()
            local existingBlur=game:GetService("Lighting"):FindFirstChild("UISX HUBBlur")
            if existingBlur then existingBlur:Destroy() end
        end)
    end
end
local function applyUIScale(scale)
    if Window and Window.UIElements and Window.UIElements.Main then
        Window.UIElements.Main.Size=UDim2.new(0,600*scale,0,400*scale)
    end
end

local Confirmed = false
local username = game:GetService("Players").LocalPlayer.Name
local coloredUsername = ""
local gradientColors = {"#4169E1","#6A5ACD","#9370DB","#8A2BE2","#4B0082"}
local goldColor = "#FFD700"
for i=1,#username do
    local char=username:sub(i,i)
    if char:match("[A-Za-z0-9]") then
        local colorIndex=(i-1)%#gradientColors+1
        coloredUsername=coloredUsername..'<font color="'..gradientColors[colorIndex]..'">'..char..'</font>'
    else
        coloredUsername=coloredUsername..'<font color="'..goldColor..'">'..char..'</font>'
    end
end

WindUI:Popup({
    Title='SX HUB V3',
    IconThemed=true,
    Icon="crown",
    Content="欢迎尊重的用户 "..coloredUsername.." \n使用SX HUB\n你的支持是我们更新的动力\nQQ主群566257944",
    Buttons={
        {Title="取消",Callback=function() end,Variant="Secondary"},
        {Title="执行",Icon="arrow-right",Callback=function() Confirmed=true createUI() end,Variant="Primary"}
    }
})

function createUI()
    local Window = WindUI:CreateWindow({
        Title='SX HUB',
        Icon="crown",
        IconThemed=true,
        Author="v3.0.1 by 神青",
        Folder="CloudHub",
        Size=UDim2.fromOffset(300,200),
        Transparent=true,
        Theme="Dark",
        HideSearchBar=false,
        ScrollBarEnabled=true,
        Resizable=true,
        Background="https://raw.githubusercontent.com/SQ182/y/c713ef1eeed1dc6b50e547dcbfee45034c385bf9/image_download_1768053890832.jpg",
        BackgroundImageTransparency=0.5,
        User={Enabled=true,Callback=function() WindUI:Notify({Title="点击了自己",Content="没什么",Duration=1,Icon="4483362748"}) end,Anonymous=false},
        SideBarWidth=250,
        Search={Enabled=true,Placeholder="搜索...",Callback=function(searchText) print("搜索内容:",searchText) end},
        SidePanel={Enabled=true,Content={{Type="Button",Text="",Style="Subtle",Size=UDim2.new(1,-20,0,30),Callback=function() end}}}
    })

    Window:EditOpenButton({
        Title="SX HUB",
        Icon="crown",
        CornerRadius=UDim.new(0,16),
        StrokeThickness=4,
        Color=ColorSequence.new(Color3.fromHex("FF6B6B")),
        Draggable=true,
    })
    Window:Tag({Title="正在寻求",Color=Color3.fromHex("#00008B")})
    Window:Tag({Title="3.0.1",Color=Color3.fromHex("#32CD32")})
    spawn(function()
        while true do
            for hue=0,1,0.01 do
                local color=Color3.fromHSV(hue,0.8,1)
                Window:EditOpenButton({Color=ColorSequence.new(color)})
                wait(0.04)
            end
        end
    end)
    if not borderInitialized then
        spawn(function()
            wait(0.5)
            initializeRainbowBorder("彩虹颜色",animationSpeed)
            wait(1)
            applyFontStyleToWindow(currentFontStyle)
        end)
    end

    local windowOpen = true
    Window:OnClose(function()
        windowOpen=false
        if rainbowBorderAnimation then rainbowBorderAnimation:Disconnect() rainbowBorderAnimation=nil end
    end)
    local originalOpenFunction=Window.Open
    Window.Open=function(...)
        windowOpen=true
        local result=originalOpenFunction(...)
        if borderInitialized and borderEnabled and not rainbowBorderAnimation then
            wait(0.1) startBorderAnimation(Window,animationSpeed)
        end
        return result
    end

    ---------------------------------------------------------------
    -- 通知
    ---------------------------------------------------------------
    local infoTab = Window:Tab({Title="通知",Icon="layout-grid",Locked=false})
    local infoSection = infoTab:Section({Title="详情信息",Icon="info",Opened=true})
    infoSection:Divider()
    infoSection:Paragraph({Title="您当前的服务器为",Desc="正在寻求\n欢迎使用此脚本",ThumbnailSize=190})
    infoSection:Paragraph({Title="持续更新，有bug请提出来",ThumbnailSize=190})
    local infoSection2 = infoTab:Section({Title="更新",Icon="info",Opened=true})
    infoSection2:Paragraph({Title="脚本已稳定发布",ThumbnailSize=190})
    infoSection2:Paragraph({Title="已经更新了愤怒机器人",ThumbnailSize=190})
    infoSection2:Paragraph({Title="更新自动抢银行",ThumbnailSize=190})
    infoSection2:Paragraph({Title="缝合了通缉脚本的 Hitbox / 全图刷钱 / 弹道颜色",ThumbnailSize=190})

    ---------------------------------------------------------------
    -- 人物功能
    ---------------------------------------------------------------
    local FlightControl = Window:Tab({Title="人物功能",Icon="gift"})
    local FlyingEnabled=false
    local SpinningEnabled=false
    local FlightSpeed=50
    local SpinSpeed=5
    local CurrentAO,CurrentLV,CurrentMoverAttachment
    local FlightConnection
    local Control={F=0,B=0,L=0,R=0,Q=0,E=0}
    local LastControl={F=0,B=0,L=0,R=0,Q=0,E=0}
    local function getControlModule()
        local LocalPlayer=game:GetService("Players").LocalPlayer
        local PlayerModule=LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")
        return require(PlayerModule:WaitForChild("ControlModule"))
    end
    local function setupBodyMovers(character)
        local hrp=character:WaitForChild("HumanoidRootPart")
        local humanoid=character:WaitForChild("Humanoid")
        local moverParent=workspace:FindFirstChildOfClass("Terrain") or workspace
        local moverAttachment=Instance.new("Attachment",hrp)
        moverAttachment.Name="FlightAttachment"
        local alignOrientation=Instance.new('AlignOrientation')
        alignOrientation.Mode=Enum.OrientationAlignmentMode.OneAttachment
        alignOrientation.RigidityEnabled=true
        alignOrientation.MaxTorque=Vector3.new(9e9,9e9,9e9)
        alignOrientation.CFrame=hrp.CFrame
        alignOrientation.Attachment0=moverAttachment
        alignOrientation.Parent=moverParent
        local linearVelocity=Instance.new('LinearVelocity')
        linearVelocity.VectorVelocity=Vector3.new(0,0,0)
        linearVelocity.MaxForce=9e9
        linearVelocity.Attachment0=moverAttachment
        linearVelocity.Parent=moverParent
        return alignOrientation,linearVelocity,humanoid,moverAttachment
    end
    local function getFlightVector(controlModule)
        local moveVector=controlModule:GetMoveVector()
        local camera=workspace.CurrentCamera
        Control.F=-moveVector.Z;Control.B=moveVector.Z;Control.L=-moveVector.X;Control.R=moveVector.X;Control.Q=moveVector.Y;Control.E=-moveVector.Y
        local UserInputService=game:GetService("UserInputService")
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then Control.F=1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then Control.B=1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then Control.L=1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then Control.R=1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then Control.Q=1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then Control.E=1 end
        local flightVector=(camera.CFrame.LookVector*(Control.F-Control.B)+camera.CFrame.RightVector*(Control.R-Control.L)+Vector3.new(0,1,0)*(Control.Q-Control.E))
        return flightVector.Magnitude>0 and flightVector.Unit or flightVector
    end
    local function startFlying()
        if FlyingEnabled then return end
        local LocalPlayer=game:GetService("Players").LocalPlayer
        local character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        if not character then WindUI:Notify({Title="飞行失败",Content="无法获取角色",Duration=2,Icon="x"}) return end
        FlyingEnabled=true;SpinningEnabled=false
        if CurrentAO then CurrentAO:Destroy() end
        if CurrentLV then CurrentLV:Destroy() end
        if CurrentMoverAttachment then CurrentMoverAttachment:Destroy() end
        CurrentAO,CurrentLV,humanoid,CurrentMoverAttachment=setupBodyMovers(character)
        WindUI:Notify({Title="飞行开启",Content="速度: "..FlightSpeed,Duration=2,Icon="check"})
        local controlModule=getControlModule()
        FlightConnection=game:GetService("RunService").Heartbeat:Connect(function()
            if not FlyingEnabled or not CurrentLV or not CurrentAO then
                if FlightConnection then FlightConnection:Disconnect() FlightConnection=nil end return
            end
            local flightVector=getFlightVector(controlModule)
            if flightVector.Magnitude>0 then CurrentLV.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector CurrentLV.VectorVelocity=flightVector*FlightSpeed else CurrentLV.VectorVelocity=Vector3.new(0,0,0) end
            if SpinningEnabled then
                local targetPart=character.Humanoid.SeatPart or character.HumanoidRootPart
                CurrentAO.CFrame=targetPart.CFrame*CFrame.Angles(0,math.rad(SpinSpeed),0)
            else
                CurrentAO.CFrame=workspace.CurrentCamera.CFrame
            end
            if character.HumanoidRootPart then character.Humanoid.PlatformStand=true end
        end)
        character.AncestryChanged:Connect(function(_,parent) if not parent and FlyingEnabled then stopFlying() end end)
    end
    function stopFlying()
        if not FlyingEnabled then return end
        FlyingEnabled=false;SpinningEnabled=false
        Control={F=0,B=0,L=0,R=0,Q=0,E=0};LastControl={F=0,B=0,L=0,R=0,Q=0,E=0}
        if FlightConnection then FlightConnection:Disconnect() FlightConnection=nil end
        local LocalPlayer=game:GetService("Players").LocalPlayer
        local character=LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then character.Humanoid.PlatformStand=false end
        if CurrentAO then CurrentAO:Destroy() CurrentAO=nil end
        if CurrentLV then CurrentLV:Destroy() CurrentLV=nil end
        if CurrentMoverAttachment then CurrentMoverAttachment:Destroy() CurrentMoverAttachment=nil end
        WindUI:Notify({Title="飞行关闭",Content="飞行功能已禁用",Duration=2,Icon="x"})
    end
    FlightControl:Toggle({Title="飞行模式",Default=FlyingEnabled,Callback=function(v) if v then startFlying() else stopFlying() end end})
    FlightControl:Toggle({Title="旋转模式",Default=SpinningEnabled,Callback=function(v) SpinningEnabled=v end})
    FlightControl:Slider({Title="飞行速度",Value={Min=1,Max=200,Default=50},Callback=function(value) FlightSpeed=value end})
    FlightControl:Slider({Title="旋转速度",Value={Min=1,Max=50,Default=5},Callback=function(value) SpinSpeed=value end})
    game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
        if FlyingEnabled then task.wait(0.5) stopFlying() task.wait(0.1) startFlying() end
    end)
    game:GetService("CoreGui").ChildRemoved:Connect(function(child) if child.Name=="CloudHub" and FlyingEnabled then stopFlying() end end)
    FlightControl:Divider()
    local SpeedHack=false
    local SpeedValue=16
    FlightControl:Toggle({Title="速度增加",Default=SpeedHack,Callback=function(v)
        SpeedHack=v
        if v then
            task.spawn(function()
                local sudu=game:GetService("RunService").Heartbeat:Connect(function()
                    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                        local hum=game.Players.LocalPlayer.Character.Humanoid
                        if hum.MoveDirection.Magnitude>0 then game.Players.LocalPlayer.Character:TranslateBy(hum.MoveDirection*SpeedValue/10) end
                    end
                end)
                while SpeedHack do task.wait() end
                sudu:Disconnect()
            end)
        end
    end})
    FlightControl:Slider({Title="速度设置",Value={Min=1,Max=150,Default=16},Callback=function(v) SpeedValue=v end})
    local fovConnection
    FlightControl:Toggle({Title="扩大视野",Default=false,Callback=function(v)
        if v then fovConnection=game:GetService("RunService").Heartbeat:Connect(function() workspace.CurrentCamera.FieldOfView=120 end)
        elseif not v and fovConnection then fovConnection:Disconnect() fovConnection=nil end
    end})
    FlightControl:Toggle({Title="无限跳",Default=false,Callback=function(Value)
        local jumpConn
        if Value then
            jumpConn=game:GetService("UserInputService").JumpRequest:Connect(function()
                local humanoid=game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        else
            if jumpConn then jumpConn:Disconnect() jumpConn=nil end
        end
    end})

    ---------------------------------------------------------------
    -- 战斗功能 + 弹道颜色设置(来自通缉)
    ---------------------------------------------------------------
    local MainCombat = Window:Tab({Title="战斗功能",Icon="swords"})
    local ForceLoadAll=false
    MainCombat:Toggle({Title="强制加载所有数据",Default=ForceLoadAll,Callback=function(v)
        ForceLoadAll=v
        if v then
            task.spawn(function()
                local devv=require(game:GetService("ReplicatedStorage").Devv)
                local Network=devv.load("Network")
                local Players=game:GetService("Players")
                local RunService=game:GetService("RunService")
                local function loadArea(position,radius)
                    if RunService:IsClient() then
                        pcall(function() Network.InvokeServer("requestStreamAround",position,radius) end)
                        pcall(function() Network.FireServer("setReplicationFocus",position) end)
                    end
                end
                local function loadAllGizmos()
                    local White=Workspace:FindFirstChild("Local") and Workspace.Local:FindFirstChild("Gizmos") and Workspace.Local.Gizmos:FindFirstChild("White")
                    if White then
                        for _,gizmo in ipairs(White:GetChildren()) do
                            if gizmo.PrimaryPart then loadArea(gizmo.PrimaryPart.Position,50) task.wait(0.1) end
                        end
                    end
                end
                local function loadAllPlayers()
                    for _,player in ipairs(Players:GetPlayers()) do
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then loadArea(player.Character.HumanoidRootPart.Position,50) task.wait(0.1) end
                    end
                end
                while ForceLoadAll do
                    loadAllGizmos();loadAllPlayers()
                    loadArea(Vector3.new(0,0,0),1000);loadArea(Vector3.new(1000,0,1000),1000)
                    loadArea(Vector3.new(-1000,0,-1000),1000);loadArea(Vector3.new(1000,0,-1000),1000)
                    loadArea(Vector3.new(-1000,0,1000),1000)
                    task.wait(5)
                end
            end)
        end
    end})

    local AutoShoot=false
    local OriginalShoot=nil
    local ShooterModule=nil
    -- 弹道颜色（来自通缉）
    getgenv().TrailColors = getgenv().TrailColors or {
        StartColor=Color3.fromRGB(0,170,255),
        EndColor=Color3.fromRGB(255,0,0),
        MiddleColor1=Color3.fromRGB(255,0,255),
        MiddleColor2=Color3.fromRGB(255,255,0)
    }
    getgenv().TrailTransparency = getgenv().TrailTransparency or 0.3
    getgenv().ShootInterval = getgenv().ShootInterval or 0.2

    MainCombat:Toggle({Title="愤怒机器人[全枪]",Default=AutoShoot,Callback=function(v)
        AutoShoot=v
        if v then
            task.spawn(function()
                ShooterModule=require(game:GetService("ReplicatedStorage").Client.Wanted.Objects.ClientTool.Components.Guns.Shooter)
                OriginalShoot=ShooterModule._shoot
                local function createBezierCurve(p0,p1,p2,t) return (1-t)^2*p0+2*(1-t)*t*p1+t^2*p2 end
                local function createBeautifulTrail(origin,targetPos)
                    local trailContainer=Instance.new("Folder");trailContainer.Name="MagicTrail";trailContainer.Parent=Workspace
                    local midPoint=(origin+targetPos)/2
                    local direction=(targetPos-origin).Unit
                    local perpendicular=Vector3.new(-direction.Z,direction.Y,direction.X)*3
                    local controlPoint=midPoint+perpendicular+Vector3.new(0,math.random(-3,3),0)
                    local curvePoints={};local numSegments=20
                    for i=0,numSegments do
                        local t=i/numSegments
                        table.insert(curvePoints,createBezierCurve(origin,controlPoint,targetPos,t))
                    end
                    for i=1,#curvePoints-1 do
                        local startPoint=curvePoints[i];local endPoint=curvePoints[i+1]
                        local distance=(endPoint-startPoint).Magnitude
                        local beamPart=Instance.new("Part")
                        beamPart.Size=Vector3.new(0.15,0.15,distance)
                        beamPart.Anchored=true;beamPart.CanCollide=false
                        beamPart.Material=Enum.Material.Neon
                        beamPart.Transparency=getgenv().TrailTransparency
                        beamPart.CFrame=CFrame.new(startPoint,endPoint)*CFrame.new(0,0,-distance/2)
                        beamPart.Parent=trailContainer
                        local tParam=i/(#curvePoints-1)
                        local color
                        if tParam<0.3 then color=getgenv().TrailColors.StartColor
                        elseif tParam<0.6 then color=getgenv().TrailColors.MiddleColor1
                        elseif tParam<0.9 then color=getgenv().TrailColors.MiddleColor2
                        else color=getgenv().TrailColors.EndColor end
                        beamPart.Color=color
                        local pointLight=Instance.new("PointLight")
                        pointLight.Brightness=5;pointLight.Range=3;pointLight.Color=color;pointLight.Parent=beamPart
                        local particles=Instance.new("ParticleEmitter")
                        particles.Size=NumberSequence.new(0.1,0.3)
                        particles.Transparency=NumberSequence.new(0.3,0.8)
                        particles.Lifetime=NumberRange.new(0.5,1)
                        particles.Rate=50;particles.Speed=NumberRange.new(1,2)
                        particles.VelocitySpread=180
                        particles.Color=ColorSequence.new(color)
                        particles.Parent=beamPart
                    end
                    task.spawn(function() task.wait(1.5) if trailContainer and trailContainer.Parent then trailContainer:Destroy() end end)
                    return trailContainer
                end
                local function hasLineOfSight(shooterPos,targetPos)
                    local raycastParams=RaycastParams.new()
                    raycastParams.FilterType=Enum.RaycastFilterType.Blacklist
                    raycastParams.FilterDescendantsInstances={game.Players.LocalPlayer.Character}
                    raycastParams.IgnoreWater=true
                    local direction=(targetPos-shooterPos).Unit
                    local distance=(targetPos-shooterPos).Magnitude
                    local raycastResult=Workspace:Raycast(shooterPos,direction*distance,raycastParams)
                    if raycastResult then
                        local hitPart=raycastResult.Instance
                        if hitPart then
                            local hitCharacter=hitPart:FindFirstAncestorOfClass("Model")
                            if hitCharacter and hitCharacter:FindFirstChild("Humanoid") then return true else return false end
                        end
                    end
                    return true
                end
                ShooterModule._shoot=function(self)
                    if not self or not self.tool then return OriginalShoot(self) end
                    local LocalPlayer=game.Players.LocalPlayer
                    local LocalCharacter=LocalPlayer.Character
                    if not LocalCharacter then return OriginalShoot(self) end
                    local shooterPos=LocalCharacter.HumanoidRootPart and LocalCharacter.HumanoidRootPart.Position or LocalCharacter.PrimaryPart.Position
                    local nearestPlayer=nil;local nearestDistance=math.huge
                    for _,player in ipairs(game.Players:GetPlayers()) do
                        if player~=LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local targetPos=player.Character.HumanoidRootPart.Position
                            local distance=(shooterPos-targetPos).Magnitude
                            if hasLineOfSight(shooterPos,targetPos) and distance<nearestDistance then
                                nearestDistance=distance;nearestPlayer=player
                            end
                        end
                    end
                    if nearestPlayer and nearestPlayer.Character and nearestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local targetPos=nearestPlayer.Character.HumanoidRootPart.Position
                        self.aimpoint=targetPos;self.aimpoint2=targetPos
                        if self.tool.model and self.tool.model.PrimaryPart then
                            createBeautifulTrail(self.tool.model.PrimaryPart.Position,targetPos)
                        else
                            createBeautifulTrail(shooterPos,targetPos)
                        end
                        self.tool.shooting=true;self.tool.fireDebounce=0;self.tool.fireMode="auto"
                    else
                        if self.tool then self.tool.shooting=false end
                    end
                    return OriginalShoot(self)
                end
                while AutoShoot do
                    if ShooterModule and ShooterModule._shoot then
                        local tool=game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                        if tool then
                            local shooter=tool:FindFirstChild("Shooter") or {tool=tool}
                            pcall(function() ShooterModule._shoot(shooter) end)
                        end
                    end
                    task.wait(getgenv().ShootInterval or 0.2)
                end
                if OriginalShoot then ShooterModule._shoot=OriginalShoot end
            end)
        end
    end})

    MainCombat:Toggle({Title="出售物品光环",Default=false,Callback=function(v)
        AutoSell=v
        if v then
            task.spawn(function()
                while AutoSell do
                    for _,a in ipairs(game:GetService("ReplicatedStorage").Shared.Core.Network:GetChildren()) do
                        if a:IsA("RemoteFunction") or a:IsA("RemoteEvent") then
                            if not a.Name:find("moveHouse") and not a.Name:find("House") then
                                pcall(function() a:InvokeServer() end)
                            end
                        end
                        if not AutoSell then break end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end})

    local BulletSection=MainCombat:Section({Title="弹道设置 (来自通缉)"})
    local TrailColorNames={"蓝色","紫色","黄色","红色","绿色","青色","白色","橙色"}
    local TrailColorValues={
        ["蓝色"]=Color3.fromRGB(0,170,255),["紫色"]=Color3.fromRGB(255,0,255),
        ["黄色"]=Color3.fromRGB(255,255,0),["红色"]=Color3.fromRGB(255,0,0),
        ["绿色"]=Color3.fromRGB(0,255,0),["青色"]=Color3.fromRGB(0,255,255),
        ["白色"]=Color3.fromRGB(255,255,255),["橙色"]=Color3.fromRGB(255,170,0)
    }
    BulletSection:Dropdown({Title="弹道起始颜色",Values=TrailColorNames,Value="蓝色",Callback=function(v) getgenv().TrailColors.StartColor=TrailColorValues[v] end})
    BulletSection:Dropdown({Title="弹道中间颜色1",Values=TrailColorNames,Value="紫色",Callback=function(v) getgenv().TrailColors.MiddleColor1=TrailColorValues[v] end})
    BulletSection:Dropdown({Title="弹道中间颜色2",Values=TrailColorNames,Value="黄色",Callback=function(v) getgenv().TrailColors.MiddleColor2=TrailColorValues[v] end})
    BulletSection:Dropdown({Title="弹道结束颜色",Values=TrailColorNames,Value="红色",Callback=function(v) getgenv().TrailColors.EndColor=TrailColorValues[v] end})
    BulletSection:Slider({Title="弹道透明度",Value={Min=0,Max=100,Default=30},Callback=function(v) getgenv().TrailTransparency=v/100 end})
    BulletSection:Slider({Title="射击间隔",Value={Min=1,Max=10,Default=2},Callback=function(v) getgenv().ShootInterval=v/10 end})
    BulletSection:Button({Title="重置颜色设置",Callback=function()
        getgenv().TrailColors={StartColor=Color3.fromRGB(0,170,255),EndColor=Color3.fromRGB(255,0,0),MiddleColor1=Color3.fromRGB(255,0,255),MiddleColor2=Color3.fromRGB(255,255,0)}
        WindUI:Notify({Title="重置完成",Content="弹道颜色已恢复默认",Duration=3,Icon="check"})
    end})

    ---------------------------------------------------------------
    -- Hitbox 扩展器 (来自通缉)
    ---------------------------------------------------------------
    local HitboxTab=Window:Tab({Title="Hitbox",Icon="crosshair"})
    local HitboxHeadSize=20
    local HitboxDisabled=true
    local HitboxTransparency=0.7
    local HitboxColor=Color3.fromRGB(255,255,255)
    local HitboxRainbow=false
    local HitboxTargetedUser=""
    local function GenerateRainbowColor() return Color3.fromHSV(tick()%5/5,1,1) end
    local function IsTargetedUser(PlayerName)
        local TargetLower=HitboxTargetedUser:lower()
        return PlayerName:lower():find(TargetLower,1,true)~=nil
    end
    game:GetService("RunService").RenderStepped:Connect(function()
        pcall(function()
            for _,NextPlayer in pairs(game.Players:GetPlayers()) do
                if NextPlayer~=game.Players.LocalPlayer then
                    pcall(function()
                        local Character=NextPlayer.Character
                        local HRP=Character and Character:FindFirstChild("HumanoidRootPart")
                        if HRP then
                            if HitboxDisabled then
                                HRP.Size=Vector3.new(2,2,1);HRP.Transparency=1
                                HRP.BrickColor=BrickColor.new("Medium stone grey")
                                HRP.Material=Enum.Material.Plastic;HRP.CanCollide=true
                            else
                                if HitboxTargetedUser=="" or IsTargetedUser(NextPlayer.Name) then
                                    HRP.Size=Vector3.new(HitboxHeadSize,HitboxHeadSize,HitboxHeadSize)
                                    HRP.Transparency=HitboxTransparency
                                    HRP.BrickColor=HitboxRainbow and BrickColor.new(GenerateRainbowColor()) or BrickColor.new(HitboxColor)
                                    HRP.Material=Enum.Material.Neon;HRP.CanCollide=false
                                else
                                    HRP.Size=Vector3.new(2,2,1);HRP.Transparency=1
                                    HRP.BrickColor=BrickColor.new("Medium stone grey")
                                    HRP.Material=Enum.Material.Plastic;HRP.CanCollide=true
                                end
                            end
                        end
                    end)
                end
            end
        end)
    end)
    HitboxTab:Paragraph({Title="注意: 使用后要演戏，小心被举报",ThumbnailSize=190})
    HitboxTab:Toggle({Title="启用 Hitbox Extender",Default=false,Callback=function(state) HitboxDisabled=not state end})
    HitboxTab:Slider({Title="Hitbox 大小",Value={Min=5,Max=50,Default=20},Callback=function(v) HitboxHeadSize=v end})
    HitboxTab:Slider({Title="Hitbox 透明度",Value={Min=0,Max=1,Default=0.7},Step=0.1,Callback=function(v) HitboxTransparency=v end})
    HitboxTab:Toggle({Title="彩虹色 Hitbox",Default=false,Callback=function(v) HitboxRainbow=v end})
    HitboxTab:Input({Title="仅对指定玩家生效",Placeholder="留空=全部玩家",Callback=function(v) HitboxTargetedUser=v end})

    ---------------------------------------------------------------
    -- 刷钱功能 + 自动全图刷钱 (来自通缉)
    ---------------------------------------------------------------
    local MoneyFarmTab=Window:Tab({Title="刷钱功能",Icon="dollar-sign"})
    local AutoBankCash=false
    MoneyFarmTab:Toggle({Title="自动抢银行",Default=AutoBankCash,Callback=function(v)
        AutoBankCash=v
        if v then
            task.spawn(function()
                local function GetRootPart()
                    local Character=game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
                    return Character:WaitForChild("HumanoidRootPart",5)
                end
                while AutoBankCash do
                    local RootPart=GetRootPart()
                    local White=Workspace:FindFirstChild("Local") and Workspace.Local:FindFirstChild("Gizmos") and Workspace.Local.Gizmos:FindFirstChild("White")
                    if White and RootPart and White:FindFirstChild("MainBankCash") and AutoBankCash then
                        local Target=White.MainBankCash.PrimaryPart or White.MainBankCash:FindFirstChildWhichIsA("BasePart",true)
                        if Target then
                            RootPart.CFrame=Target.CFrame*CFrame.new(0,0,-2.5)
                            task.wait(0.2)
                            while AutoBankCash and White:FindFirstChild("MainBankCash") do
                                game:GetService("VirtualInputManager"):SendKeyEvent(true,Enum.KeyCode.E,false,game)
                                task.wait(0.05)
                                game:GetService("VirtualInputManager"):SendKeyEvent(false,Enum.KeyCode.E,false,game)
                                task.wait(0.5)
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end})

    local HitATMAura=false
    MoneyFarmTab:Toggle({Title="摧毁ATM光环",Default=HitATMAura,Callback=function(Value)
        HitATMAura=Value
        if Value then
            local devv=require(game:GetService("ReplicatedStorage").Devv)
            local Get=devv.GetModule("Network")
            local localPlayer=game.Players.LocalPlayer
            local character=localPlayer.Character or localPlayer.CharacterAdded:Wait()
            local gizmoColors={"White","Green","Blue","Purple","Orange","Red","Yellow"}
            local cooldown=false
            local function attackATM(gizmo)
                if not gizmo or not gizmo:FindFirstChild("Metal") then return false end
                local guid=gizmo:GetAttribute("objectId")
                if not guid then return false end
                Get.FireServer("registerMeleeHits",{{
                    normal=Vector3.new(0,0,0),direction=Vector3.new(0,0,0),source="Melee",id=guid,
                    material=Enum.Material.Metal,position=gizmo.Metal.Position,gizmoType="ATM",
                    processedPlayerId=localPlayer.UserId,hit=gizmo.Metal,speed=50,
                    collisionPoint=gizmo.Metal.Position,hitName="Metal",hitType="gizmo"
                }})
                return true
            end
            local function isATMAlive(gizmo) return gizmo and gizmo.Parent and gizmo:FindFirstChild("Metal") end
            local function findAllATMs()
                local allATMs={}
                for _,color in ipairs(gizmoColors) do
                    local cf=Workspace.Local.Gizmos:FindFirstChild(color)
                    if cf then local atm=cf:FindFirstChild("ATM") if atm then table.insert(allATMs,atm) end end
                end
                return allATMs
            end
            task.spawn(function()
                while HitATMAura do
                    if cooldown then task.wait(0.1) continue end
                    local allATMs=findAllATMs()
                    if #allATMs==0 then task.wait(1) continue end
                    for _,atm in ipairs(allATMs) do
                        if not HitATMAura then break end
                        local c=0
                        while HitATMAura and isATMAlive(atm) and c<50 do attackATM(atm) c=c+1 task.wait(0.05) end
                        if HitATMAura then task.wait(0.5) end
                    end
                    task.wait(0.1)
                end
            end)
            localPlayer.CharacterAdded:Connect(function(newChar)
                character=newChar
                local hum=newChar:WaitForChild("Humanoid")
                hum.Died:Connect(function() if HitATMAura then cooldown=true task.wait(3) cooldown=false end end)
            end)
        end
    end})

    local AutoATM=false
    MoneyFarmTab:Toggle({Title="自动ATM",Default=AutoATM,Callback=function(Value)
        AutoATM=Value
        if Value then
            local RootPart=(game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
            local GizmoFolder=Workspace.Local.Gizmos.White
            local ATMPatrolPoints={Vector3.new(-1137,78,-1953),Vector3.new(-44,63,-2083),Vector3.new(194,60,-2884),Vector3.new(-412,106,-1301),Vector3.new(-377,410,-741),Vector3.new(-985,380,-1145),Vector3.new(-854,406,-1505)}
            local function GetBasePart(inst) if inst:IsA("BasePart") then return inst end for _,d in ipairs(inst:GetDescendants()) do if d:IsA("BasePart") then return d end end end
            local function FindClosestATMTarget()
                local minDistance=math.huge local closestPart=nil
                for _,item in ipairs(GizmoFolder:GetChildren()) do
                    if item:GetAttribute("gizmoType")=="ATM" then
                        local part=GetBasePart(item)
                        if part then
                            local dist=(RootPart.Position-part.Position).Magnitude
                            if dist<minDistance then closestPart=part minDistance=dist end
                        end
                    end
                end
                return closestPart
            end
            local function TeleportTo(target)
                if typeof(target)~="Instance" then if typeof(target)=="Vector3" then RootPart.CFrame=CFrame.new(target) end
                else RootPart.CFrame=target.CFrame*CFrame.new(0,5,0) end
            end
            local function SpamInteract(duration)
                local start=tick()
                while tick()-start<duration do
                    game:GetService("VirtualInputManager"):SendKeyEvent(true,Enum.KeyCode.E,false,game)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false,Enum.KeyCode.E,false,game)
                    task.wait(0.05)
                end
            end
            task.spawn(function()
                while AutoATM do
                    local target=FindClosestATMTarget()
                    if target then TeleportTo(target) task.wait(0.3) SpamInteract(1.5)
                    else TeleportTo(ATMPatrolPoints[math.random(1,#ATMPatrolPoints)]) end
                    task.wait(0.7)
                end
            end)
        end
    end})

    local AutoRegister=false
    MoneyFarmTab:Toggle({Title="自动收银机",Default=AutoRegister,Callback=function(Value)
        AutoRegister=Value
        if Value then
            local RootPart=(game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
            local GizmoFolder=Workspace.Local.Gizmos.White
            local RegisterPatrolPoints={Vector3.new(-1000,100,-2000),Vector3.new(-500,100,-2200),Vector3.new(100,100,-2500)}
            local function GetBasePart(inst) if inst:IsA("BasePart") then return inst end for _,d in ipairs(inst:GetDescendants()) do if d:IsA("BasePart") then return d end end end
            local function FindClosestRegisterTarget()
                local minDistance=math.huge local closestPart=nil
                for _,item in ipairs(GizmoFolder:GetChildren()) do
                    if item:GetAttribute("gizmoType")=="Register" then
                        local part=GetBasePart(item)
                        if part then
                            local dist=(RootPart.Position-part.Position).Magnitude
                            if dist<minDistance then closestPart=part minDistance=dist end
                        end
                    end
                end
                return closestPart
            end
            local function TeleportTo(target)
                if typeof(target)~="Instance" then if typeof(target)=="Vector3" then RootPart.CFrame=CFrame.new(target) end
                else RootPart.CFrame=target.CFrame*CFrame.new(0,5,0) end
            end
            local function SpamInteract(duration)
                local start=tick()
                while tick()-start<duration do
                    game:GetService("VirtualInputManager"):SendKeyEvent(true,Enum.KeyCode.E,false,game)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false,Enum.KeyCode.E,false,game)
                    task.wait(0.05)
                end
            end
            task.spawn(function()
                while AutoRegister do
                    local target=FindClosestRegisterTarget()
                    if target then TeleportTo(target) task.wait(0.3) SpamInteract(1.2)
                    else TeleportTo(RegisterPatrolPoints[math.random(1,#RegisterPatrolPoints)]) end
                    task.wait(0.7)
                end
            end)
        end
    end})

    -- 自动全图刷钱 (来自通缉)
    local YGAutoFarmRunning=false
    local YGAutoFarmThread=nil
    local YGFarmRoot=game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    game.Players.LocalPlayer.CharacterAdded:Connect(function(char) YGFarmRoot=char:WaitForChild("HumanoidRootPart",5) end)
    local YGPatrolPoints={Vector3.new(-1137,78,-1953),Vector3.new(-44,63,-2083),Vector3.new(194,60,-2884),Vector3.new(-412,106,-1301),Vector3.new(-377,410,-741),Vector3.new(-985,380,-1145),Vector3.new(-854,406,-1505)}
    local function YGGetBasePart(inst)
        if not inst then return nil end
        if inst:IsA("BasePart") then return inst end
        for _,d in ipairs(inst:GetDescendants()) do if d:IsA("BasePart") then return d end end
        return nil
    end
    local function YGFindClosestTarget()
        local folder=workspace:FindFirstChild("Local") and workspace.Local:FindFirstChild("Gizmos") and workspace.Local.Gizmos:FindFirstChild("White")
        if not folder or not YGFarmRoot then return nil end
        local minDistance=math.huge local closestPart=nil
        for _,item in ipairs(folder:GetChildren()) do
            local t=item:GetAttribute("gizmoType")
            if t=="ATM" or t=="Register" then
                local part=YGGetBasePart(item)
                if part then
                    local dist=(YGFarmRoot.Position-part.Position).Magnitude
                    if dist<minDistance then closestPart=part minDistance=dist end
                end
            end
        end
        return closestPart
    end
    local function YGTeleportToTarget(target)
        if not YGFarmRoot then return end
        if typeof(target)~="Instance" then if typeof(target)=="Vector3" then YGFarmRoot.CFrame=CFrame.new(target) end
        else YGFarmRoot.CFrame=target.CFrame*CFrame.new(0,1,0) end
    end
    local function YGSpamInteract(duration)
        local start=tick()
        while tick()-start<duration do
            game:GetService("VirtualInputManager"):SendKeyEvent(true,Enum.KeyCode.E,false,game)
            game:GetService("VirtualInputManager"):SendKeyEvent(false,Enum.KeyCode.E,false,game)
            task.wait(0.01)
        end
    end
    MoneyFarmTab:Toggle({Title="自动全图刷钱 (来自通缉)",Default=false,Callback=function(state)
        YGAutoFarmRunning=state
        if state then
            if YGAutoFarmThread then task.cancel(YGAutoFarmThread) YGAutoFarmThread=nil end
            YGAutoFarmThread=task.spawn(function()
                while YGAutoFarmRunning do
                    pcall(function()
                        local target=YGFindClosestTarget()
                        if target then YGTeleportToTarget(target) YGSpamInteract(1.5)
                        else YGTeleportToTarget(YGPatrolPoints[math.random(1,#YGPatrolPoints)]) end
                        task.wait(1.5)
                    end)
                end
            end)
        else
            if YGAutoFarmThread then task.cancel(YGAutoFarmThread) YGAutoFarmThread=nil end
        end
    end})

    ---------------------------------------------------------------
    -- 自动拾取
    ---------------------------------------------------------------
    local AutoPickupTab=Window:Tab({Title="自动拾取",Icon="box"})
    local function setupPickupToggle(tab,title,itemName,stateFn)
        local state=false
        tab:Toggle({Title=title,Default=state,Callback=function(v)
            state=v;stateFn(v)
            if v then
                task.spawn(function()
                    local function GetRootPart()
                        local Character=game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
                        return Character:WaitForChild("HumanoidRootPart",5)
                    end
                    while state do
                        local RootPart=GetRootPart()
                        local White=Workspace:FindFirstChild("Local") and Workspace.Local:FindFirstChild("Gizmos") and Workspace.Local.Gizmos:FindFirstChild("White")
                        if White and RootPart then
                            for _,Item in ipairs(White:GetChildren()) do
                                if (itemName=="*" or Item.Name==itemName) and state then
                                    local Target=Item.PrimaryPart or Item:FindFirstChildWhichIsA("BasePart",true)
                                    if Target then
                                        RootPart.CFrame=Target.CFrame*CFrame.new(0,0,-2.5)
                                        task.wait(0.2)
                                        game:GetService("VirtualInputManager"):SendKeyEvent(true,Enum.KeyCode.E,false,game)
                                        task.wait(0.05)
                                        game:GetService("VirtualInputManager"):SendKeyEvent(false,Enum.KeyCode.E,false,game)
                                        repeat task.wait(0.1) until not Item.Parent or not state
                                    end
                                end
                                if not state then break end
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            end
        end})
    end
    setupPickupToggle(AutoPickupTab,"自动拾取金条","Gold Bar",function() end)
    setupPickupToggle(AutoPickupTab,"自动拾取全部礼物盒","WorldItem",function() end)
    setupPickupToggle(AutoPickupTab,"自动拾取银条","Silver Bar",function() end)
    setupPickupToggle(AutoPickupTab,"自动拾取蓝宝石","Sapphire",function() end)

    ---------------------------------------------------------------
    -- 绕过类
    ---------------------------------------------------------------
    local BypassTab=Window:Tab({Title="绕过类",Icon="wind"})
    local ImmuneTurret=false
    local oldFireServer
    BypassTab:Toggle({Title="绕过炮塔伤害",Default=ImmuneTurret,Callback=function(v)
        ImmuneTurret=v
        if v then
            oldFireServer=game:GetService("ReplicatedStorage").Shared.Core.Network.FireServer
            game:GetService("ReplicatedStorage").Shared.Core.Network.FireServer=function(self,event,...)
                if event=="registerLocalHit" and ...=="Turret" then return nil end
                return oldFireServer(self,event,...)
            end
        else
            if oldFireServer then game:GetService("ReplicatedStorage").Shared.Core.Network.FireServer=oldFireServer end
        end
    end})

    ---------------------------------------------------------------
    -- 武器修改
    ---------------------------------------------------------------
    local WeaponTab=Window:Tab({Title="武器修改",Icon="target"})
    local function hookShooter(func)
        local Shooter=require(game:GetService("ReplicatedStorage").Client.Wanted.Objects.ClientTool.Components.Guns.Shooter)
        local orig=Shooter._shoot
        Shooter._shoot=function(self)
            func(self)
            return orig(self)
        end
    end
    WeaponTab:Button({Title="无限子弹",Callback=function() hookShooter(function(self) self.ammo=9999 self.totalAmmo=9999 end) end})
    WeaponTab:Button({Title="无后坐力",Callback=function() hookShooter(function(self) self.recoil={firstShotKick=0,climb=0,spread=0} end) end})
    WeaponTab:Button({Title="无扩散",Callback=function() hookShooter(function(self) self.aim={spreadAngle=0,zeroing=1000} end) end})
    WeaponTab:Button({Title="快速射击",Callback=function() hookShooter(function(self) self.tool.fireDebounce=0 self.tool.fireMode="auto" end) end})
    WeaponTab:Button({Title="无装弹",Callback=function() hookShooter(function(self) self.ammoData={reloadTime=0,magSize=9999} end) end})

    ---------------------------------------------------------------
    -- 自瞄（来自第一个脚本，外加“通缉”的外部加载按钮）
    ---------------------------------------------------------------
    local AimTab=Window:Tab({Title="自瞄",Icon="crosshair"})
    local isAiming=false
    local isPredicting=false
    local fov=50
    local plr=game:GetService("Players").LocalPlayer
    local RunService=game:GetService("RunService")
    local Players=game:GetService("Players")
    local Cam=workspace.CurrentCamera
    local targetPart="Head"
    local teamCheck=false
    local aliveCheck=false
    local predictionDistance=1.5
    local smoothness=0.5
    local aimLock=false
    local aimStyle="平滑"
    local lockDuration=3
    local lastLockTime=0
    local lockedPlayer=nil
    local isSilentAim=false
    local silentFov=30
    local isRageMode=false
    local silentAimChance=100
    local aimbotPriority="距离"
    local isAutoShootOnAim=false
    local shootDelay=0.1
    local lastShotTime=0
    local isLagCompensation=false
    local useAdvancedPrediction=false
    local predictionType="线性"
    local advancedPredictionFactor=1.2
    local bulletSpeed=500
    local gravityFactor=9.8

    local FOVring=Drawing.new("Circle")
    FOVring.Visible=false;FOVring.Thickness=2;FOVring.Color=Color3.fromRGB(255,0,0);FOVring.Filled=false;FOVring.Radius=fov
    FOVring.Position=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)
    local SilentFOVring=Drawing.new("Circle")
    SilentFOVring.Visible=false;SilentFOVring.Thickness=1;SilentFOVring.Color=Color3.fromRGB(0,255,255);SilentFOVring.Filled=false;SilentFOVring.Radius=silentFov
    SilentFOVring.Position=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)
    local aimConnection=nil

    local AutoShootShooterModule=nil
    local AutoShootOriginalShoot=nil
    local autoShootConnection=nil

    local function initializeAutoShootModule()
        if not AutoShootShooterModule then
            local ok,m=pcall(function() return require(game:GetService("ReplicatedStorage").Client.Wanted.Objects.ClientTool.Components.Guns.Shooter) end)
            if ok and m then AutoShootShooterModule=m AutoShootOriginalShoot=m._shoot return true end
        end
        return AutoShootShooterModule~=nil
    end
    local function hasLineOfSight(shooterPos,targetPos)
        local rp=RaycastParams.new()
        rp.FilterType=Enum.RaycastFilterType.Blacklist
        rp.FilterDescendantsInstances={game.Players.LocalPlayer.Character}
        rp.IgnoreWater=true
        local dir=(targetPos-shooterPos).Unit
        local dist=(targetPos-shooterPos).Magnitude
        local res=Workspace:Raycast(shooterPos,dir*dist,rp)
        if res then
            local hp=res.Instance
            if hp then
                local hc=hp:FindFirstAncestorOfClass("Model")
                if hc and hc:FindFirstChild("Humanoid") then return true else return false end
            end
        end
        return true
    end
    local function getClosestPlayerInFOV()
        local nearest=nil
        local lastDistance=math.huge
        local lowestHealthPlayer=nil
        local lowestHealth=math.huge
        local nearestDistance=math.huge
        local playerMousePos=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)
        for _,player in ipairs(Players:GetPlayers()) do
            if player~=plr then
                if teamCheck and player.Team==plr.Team then continue end
                local character=player.Character
                if character and character:FindFirstChild(targetPart) then
                    if aliveCheck and (not character:FindFirstChildOfClass("Humanoid") or character:FindFirstChildOfClass("Humanoid").Health<=0) then continue end
                    local part=character[targetPart]
                    local ePos,isVisible=Cam:WorldToViewportPoint(part.Position)
                    local screenDistance=(Vector2.new(ePos.x,ePos.y)-playerMousePos).Magnitude
                    if screenDistance<silentFov and isVisible then
                        local distance=(plr.Character and plr.Character.PrimaryPart and (part.Position-plr.Character.PrimaryPart.Position).Magnitude) or math.huge
                        if aimbotPriority=="距离" and distance<nearestDistance then nearestDistance=distance nearest=player
                        elseif aimbotPriority=="屏幕距离" and screenDistance<lastDistance then lastDistance=screenDistance nearest=player
                        elseif aimbotPriority=="生命值" then
                            local hum=character:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health<lowestHealth then lowestHealth=hum.Health lowestHealthPlayer=player end
                        end
                    end
                end
            end
        end
        if aimbotPriority=="生命值" and lowestHealthPlayer then return lowestHealthPlayer end
        return nearest
    end
    local function getPredictedPosition(player,deltaTime)
        local character=player.Character
        if not character or not character:FindFirstChild(targetPart) then return end
        local part=character[targetPart]
        if not isPredicting then return part.Position end
        local velocity=part.Velocity
        if useAdvancedPrediction then
            local distance=(part.Position-Cam.CFrame.Position).Magnitude
            local travelTime=distance/bulletSpeed
            if predictionType=="线性" then return part.Position+velocity*travelTime
            elseif predictionType=="抛物线" then
                local predictedPos=part.Position+velocity*travelTime
                local drop=Vector3.new(0,-0.5*gravityFactor*travelTime^2,0)
                return predictedPos+drop
            elseif predictionType=="自适应" then
                local targetSpeed=velocity.Magnitude
                local adaptiveFactor=1+(targetSpeed/50)*advancedPredictionFactor
                return part.Position+velocity*travelTime*adaptiveFactor
            end
        end
        local nextPosition=part.Position+velocity*deltaTime*predictionDistance
        if isLagCompensation then nextPosition=nextPosition+velocity*0.1 end
        return nextPosition
    end
    local function smartAimAt(targetPosition)
        local currentCFrame=Cam.CFrame
        local targetDirection=(targetPosition-currentCFrame.Position).Unit
        if aimStyle=="平滑" then
            local smoothFactor=smoothness
            if isRageMode then smoothFactor=smoothness*0.3 end
            local lookVector=currentCFrame.LookVector:Lerp(targetDirection,smoothFactor)
            Cam.CFrame=CFrame.new(currentCFrame.Position,currentCFrame.Position+lookVector)
        elseif aimStyle=="直接" or isRageMode then
            Cam.CFrame=CFrame.new(currentCFrame.Position,currentCFrame.Position+targetDirection)
        elseif aimStyle=="震动" then
            local lookVector=currentCFrame.LookVector:Lerp(targetDirection,smoothness)
            local shake=Vector3.new((math.random()-0.5)*0.1,(math.random()-0.5)*0.1,0)
            Cam.CFrame=CFrame.new(currentCFrame.Position,currentCFrame.Position+lookVector+shake)
        end
    end
    local function aimLoop()
        if not isAiming then return end
        FOVring.Position=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)
        SilentFOVring.Position=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)
        local now=tick()
        if aimLock and lockedPlayer and now-lastLockTime<lockDuration then
            if lockedPlayer.Character and lockedPlayer.Character:FindFirstChild(targetPart) then
                local pos=getPredictedPosition(lockedPlayer,0.016)
                if pos then smartAimAt(pos) end
            end
        else
            local target=getClosestPlayerInFOV()
            if target and target.Character and target.Character:FindFirstChild(targetPart) then
                local pos=getPredictedPosition(target,0.016)
                if pos then
                    smartAimAt(pos)
                    if aimLock then lockedPlayer=target lastLockTime=now end
                end
            end
        end
    end
    local function hookAutoShoot()
        if not AutoShootShooterModule or not AutoShootOriginalShoot then
            if not initializeAutoShootModule() then return end
        end
        AutoShootShooterModule._shoot=function(self)
            if not self or not self.tool then return AutoShootOriginalShoot(self) end
            local LocalPlayer=game.Players.LocalPlayer
            local LocalCharacter=LocalPlayer.Character
            if not LocalCharacter then return AutoShootOriginalShoot(self) end
            if isAiming and isAutoShootOnAim then
                local target=getClosestPlayerInFOV()
                if target and target.Character and target.Character:FindFirstChild(targetPart) then
                    local targetPos=target.Character[targetPart].Position
                    self.aimpoint=targetPos self.aimpoint2=targetPos
                    self.tool.shooting=true self.tool.fireDebounce=0 self.tool.fireMode="auto"
                end
            end
            return AutoShootOriginalShoot(self)
        end
    end
    local function startAutoShootLoop()
        if autoShootConnection then autoShootConnection:Disconnect() end
        autoShootConnection=RunService.Heartbeat:Connect(function()
            if not isAiming or not isAutoShootOnAim then return end
            local now=tick()
            if now-lastShotTime<shootDelay then return end
            local tool=plr.Character and plr.Character:FindFirstChildWhichIsA("Tool")
            if not tool then return end
            local shooter=tool:FindFirstChild("Shooter") or {tool=tool}
            if AutoShootShooterModule and AutoShootShooterModule._shoot then
                pcall(function() AutoShootShooterModule._shoot(shooter) end)
            end
            lastShotTime=now
        end)
    end
    local function stopAutoShoot()
        if autoShootConnection then autoShootConnection:Disconnect() autoShootConnection=nil end
        if AutoShootShooterModule and AutoShootOriginalShoot then AutoShootShooterModule._shoot=AutoShootOriginalShoot end
    end

    AimTab:Toggle({Title="开启自瞄",Default=false,Callback=function(v)
        isAiming=v FOVring.Visible=v
        if v then
            if aimConnection then aimConnection:Disconnect() end
            aimConnection=RunService.RenderStepped:Connect(aimLoop)
        elseif aimConnection then aimConnection:Disconnect() aimConnection=nil end
    end})
    AimTab:Toggle({Title="静默瞄准",Default=false,Callback=function(v) isSilentAim=v SilentFOVring.Visible=v end})
    AimTab:Toggle({Title="瞄准时自动射击",Default=false,Callback=function(v)
        isAutoShootOnAim=v
        if v then hookAutoShoot() startAutoShootLoop() else stopAutoShoot() end
    end})
    AimTab:Toggle({Title="预判自瞄",Default=false,Callback=function(v) isPredicting=v end})
    AimTab:Toggle({Title="高级预判",Default=false,Callback=function(v) useAdvancedPrediction=v end})
    AimTab:Toggle({Title="锁定目标",Default=false,Callback=function(v) aimLock=v end})
    AimTab:Toggle({Title="狂暴模式",Default=false,Callback=function(v) isRageMode=v end})
    AimTab:Dropdown({Title="瞄准风格",Values={"平滑","直接","震动"},Default="平滑",Callback=function(v) aimStyle=v end})
    AimTab:Dropdown({Title="瞄准优先级",Values={"距离","屏幕距离","生命值"},Default="距离",Callback=function(v) aimbotPriority=v end})
    AimTab:Dropdown({Title="自瞄身体部位",Values={"头","胸","左手","右手","左腿","右腿"},Default="头",Callback=function(v)
        local map={["头"]="Head",["胸"]="UpperTorso",["左手"]="LeftHand",["右手"]="RightHand",["左腿"]="LeftFoot",["右腿"]="RightFoot"}
        targetPart=map[v]
    end})
    AimTab:Dropdown({Title="预判类型",Values={"线性","抛物线","自适应"},Default="线性",Callback=function(v) predictionType=v end})
    AimTab:Slider({Title="FOV范围",Value={Min=1,Max=500,Default=50},Callback=function(v) fov=v FOVring.Radius=v end})
    AimTab:Slider({Title="静默FOV",Value={Min=1,Max=200,Default=30},Callback=function(v) silentFov=v SilentFOVring.Radius=v end})
    AimTab:Slider({Title="平滑度",Value={Min=0.01,Max=1,Default=0.5},Callback=function(v) smoothness=v end})
    AimTab:Slider({Title="预判距离",Value={Min=0.1,Max=5,Default=1.5},Callback=function(v) predictionDistance=v end})
    AimTab:Slider({Title="射击速度",Value={Min=0.01,Max=1,Default=0.1},Callback=function(v) shootDelay=v end})
    AimTab:Slider({Title="静默命中率",Value={Min=1,Max=100,Default=100},Callback=function(v) silentAimChance=v end})
    AimTab:Slider({Title="锁定时间",Value={Min=1,Max=10,Default=3},Callback=function(v) lockDuration=v end})
    AimTab:Section({Title="其他功能"})
    AimTab:Toggle({Title="活体检测",Default=false,Callback=function(v) aliveCheck=v end})
    AimTab:Toggle({Title="团队检查",Default=false,Callback=function(v) teamCheck=v end})
    AimTab:Toggle({Title="延迟补偿",Default=false,Callback=function(v) isLagCompensation=v end})
    -- 来自通缉的外部加载按钮
    AimTab:Section({Title="扩展"})
    AimTab:Button({Title="从外部加载自瞄 (来自通缉)",Callback=function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/自瞄"))()
    end})

    ---------------------------------------------------------------
    -- 透视（保留第一个脚本的完整实现，精简版）
    ---------------------------------------------------------------
    local ESPTab=Window:Tab({Title="透视",Icon="user"})
    local ESPConfig={
        ESPEnabled=false,ShowBox=false,ShowHealth=false,ShowName=false,ShowDistance=false,
        ShowTracer=false,TeamCheck=false,ShowSkeleton=false,ShowRadar=false,ShowPlayerCount=false,
        ShowWeapon=false,ShowFOV=false,OutOfViewArrows=false,
        TracerColor=Color3.new(1,0,0),SkeletonColor=Color3.new(0.2,0.8,1),BoxColor=Color3.new(1,1,1),
        HealthBarColor=Color3.new(0,1,0),HealthTextColor=Color3.new(1,1,1),NameColor=Color3.new(1,1,1),
        DistanceColor=Color3.new(1,1,0),WeaponColor=Color3.new(1,0.5,0),ArrowColor=Color3.new(1,0,0),
        FOVColor=Color3.new(1,1,1),BoxThickness=1,TracerThickness=1,SkeletonThickness=2,FOVRadius=100,ArrowSize=15
    }
    local function getGradientColor(t) return Color3.new(math.sin(t*2)*0.5+0.5,math.sin(t*3)*0.5+0.5,math.sin(t*4)*0.5+0.5) end
    local playerCountText=Drawing.new("Text")
    playerCountText.Visible=false playerCountText.Color=Color3.new(1,1,1) playerCountText.Size=20
    playerCountText.Font=Drawing.Fonts.Monospace playerCountText.Outline=true playerCountText.OutlineColor=Color3.new(0,0,0)
    playerCountText.Position=Vector2.new(Cam.ViewportSize.X/2,10)
    local fovCircle=Drawing.new("Circle")
    fovCircle.Visible=false fovCircle.Color=ESPConfig.FOVColor fovCircle.Thickness=1 fovCircle.Filled=false
    fovCircle.Radius=ESPConfig.FOVRadius fovCircle.Position=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)
    local ESPComponents={}
    local function createESP(player)
        if player==plr then return end
        local box=Drawing.new("Square") box.Visible=false box.Color=ESPConfig.BoxColor box.Thickness=1 box.Filled=false
        local healthBar=Drawing.new("Square") healthBar.Visible=false healthBar.Color=ESPConfig.HealthBarColor healthBar.Filled=true
        local healthBarBackground=Drawing.new("Square") healthBarBackground.Visible=false healthBarBackground.Color=Color3.new(0,0,0) healthBarBackground.Transparency=0.5 healthBarBackground.Filled=true
        local healthBarBorder=Drawing.new("Square") healthBarBorder.Visible=false healthBarBorder.Color=Color3.new(1,1,1) healthBarBorder.Filled=false
        local healthText=Drawing.new("Text") healthText.Visible=false healthText.Color=ESPConfig.HealthTextColor healthText.Size=14 healthText.Font=Drawing.Fonts.Monospace healthText.Outline=true
        local nameText=Drawing.new("Text") nameText.Visible=false nameText.Color=ESPConfig.NameColor nameText.Size=16 nameText.Font=Drawing.Fonts.Monospace nameText.Outline=true
        local distanceText=Drawing.new("Text") distanceText.Visible=false distanceText.Color=ESPConfig.DistanceColor distanceText.Size=14 distanceText.Font=Drawing.Fonts.Monospace distanceText.Outline=true
        local weaponText=Drawing.new("Text") weaponText.Visible=false weaponText.Color=ESPConfig.WeaponColor weaponText.Size=14 weaponText.Font=Drawing.Fonts.Monospace weaponText.Outline=true
        local tracer=Drawing.new("Line") tracer.Visible=false tracer.Color=ESPConfig.TracerColor tracer.Thickness=1
        local arrow=Drawing.new("Triangle") arrow.Visible=false arrow.Color=ESPConfig.ArrowColor arrow.Filled=true
        local skeletonLines={} for i=1,15 do skeletonLines[i]=Drawing.new("Line") skeletonLines[i].Visible=false skeletonLines[i].Color=ESPConfig.SkeletonColor skeletonLines[i].Thickness=2 end
        local skeletonHeadPoint=Drawing.new("Circle") skeletonHeadPoint.Visible=false skeletonHeadPoint.Color=Color3.new(1,0.5,0) skeletonHeadPoint.Filled=true skeletonHeadPoint.Radius=4
        ESPComponents[player]={box=box,healthBar=healthBar,healthBarBackground=healthBarBackground,healthBarBorder=healthBarBorder,healthText=healthText,nameText=nameText,distanceText=distanceText,weaponText=weaponText,tracer=tracer,arrow=arrow,skeletonLines=skeletonLines,skeletonHeadPoint=skeletonHeadPoint}
        local lastHealth=100 local healthChangeTime=0 local smoothHealth=100
        RunService.RenderStepped:Connect(function()
            if not ESPConfig.ESPEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Humanoid") then
                box.Visible=false healthBar.Visible=false healthBarBackground.Visible=false healthBarBorder.Visible=false
                healthText.Visible=false nameText.Visible=false distanceText.Visible=false weaponText.Visible=false
                tracer.Visible=false arrow.Visible=false
                for _,l in pairs(skeletonLines) do l.Visible=false end
                skeletonHeadPoint.Visible=false
                return
            end
            if ESPConfig.TeamCheck and player.Team==plr.Team then
                box.Visible=false healthBar.Visible=false healthBarBackground.Visible=false healthBarBorder.Visible=false
                healthText.Visible=false nameText.Visible=false distanceText.Visible=false weaponText.Visible=false
                tracer.Visible=false arrow.Visible=false
                for _,l in pairs(skeletonLines) do l.Visible=false end
                skeletonHeadPoint.Visible=false
                return
            end
            local character=player.Character
            local rootPart=character:FindFirstChild("HumanoidRootPart")
            local humanoid=character:FindFirstChild("Humanoid")
            if not (rootPart and humanoid and humanoid.Health>0) then
                box.Visible=false healthBar.Visible=false healthBarBackground.Visible=false healthBarBorder.Visible=false
                healthText.Visible=false nameText.Visible=false distanceText.Visible=false weaponText.Visible=false
                tracer.Visible=false arrow.Visible=false
                for _,l in pairs(skeletonLines) do l.Visible=false end
                skeletonHeadPoint.Visible=false
                return
            end
            local rootPos,onScreen=Cam:WorldToViewportPoint(rootPart.Position)
            local headPos=Cam:WorldToViewportPoint(rootPart.Position+Vector3.new(0,3,0))
            local legPos=Cam:WorldToViewportPoint(rootPart.Position-Vector3.new(0,3,0))
            local weaponName="无武器"
            for _,tool in ipairs(character:GetChildren()) do if tool:IsA("Tool") then weaponName=tool.Name break end end
            if ESPConfig.ShowBox and onScreen then
                box.Size=Vector2.new(1000/rootPos.Z,headPos.Y-legPos.Y)
                box.Position=Vector2.new(rootPos.X-box.Size.X/2,rootPos.Y-box.Size.Y/2)
                box.Visible=true box.Color=ESPConfig.BoxColor box.Thickness=ESPConfig.BoxThickness
            else box.Visible=false end
            if ESPConfig.ShowHealth and onScreen then
                local barWidth=50 local barHeight=5 local barX=headPos.X-barWidth/2 local barY=headPos.Y-20
                healthBarBackground.Size=Vector2.new(barWidth,barHeight) healthBarBackground.Position=Vector2.new(barX,barY) healthBarBackground.Visible=true
                healthBarBorder.Size=Vector2.new(barWidth,barHeight) healthBarBorder.Position=Vector2.new(barX,barY) healthBarBorder.Visible=true
                smoothHealth=smoothHealth+(humanoid.Health-smoothHealth)*0.1
                local hp=smoothHealth/humanoid.MaxHealth
                healthBar.Size=Vector2.new(barWidth*hp,barHeight) healthBar.Position=Vector2.new(barX,barY)
                if hp>=0.8 then healthBar.Color=Color3.new(0,1,0)
                elseif hp>=0.5 then healthBar.Color=Color3.new(1,1,0)
                elseif hp>=0.2 then healthBar.Color=Color3.new(1,0.5,0)
                else healthBar.Color=Color3.new(1,0,0) end
                healthBar.Visible=true
                if humanoid.Health~=lastHealth then healthChangeTime=tick() lastHealth=humanoid.Health end
                if tick()-healthChangeTime<0.5 then healthBar.Color=Color3.new(1,0,0) end
                healthText.Position=Vector2.new(barX+barWidth+5,barY-5)
                healthText.Text=math.floor(humanoid.Health).."/"..math.floor(humanoid.MaxHealth)
                healthText.Visible=true
            else healthBar.Visible=false healthBarBackground.Visible=false healthBarBorder.Visible=false healthText.Visible=false end
            if ESPConfig.ShowName and onScreen then
                nameText.Position=Vector2.new(headPos.X,headPos.Y-35) nameText.Text=player.Name nameText.Visible=true
                if ESPConfig.ShowDistance then
                    local d=(plr.Character.HumanoidRootPart.Position-rootPart.Position).Magnitude
                    distanceText.Position=Vector2.new(headPos.X,headPos.Y+10) distanceText.Text=math.floor(d).."m" distanceText.Visible=true
                else distanceText.Visible=false end
                if ESPConfig.ShowWeapon then
                    weaponText.Position=Vector2.new(headPos.X,headPos.Y-50) weaponText.Text=weaponName weaponText.Visible=true
                else weaponText.Visible=false end
            else nameText.Visible=false distanceText.Visible=false weaponText.Visible=false end
            if ESPConfig.ShowTracer then
                local head=character:FindFirstChild("Head")
                if head then
                    local hp,os=Cam:WorldToViewportPoint(head.Position)
                    if os then
                        tracer.From=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y)
                        tracer.To=Vector2.new(hp.X,hp.Y) tracer.Visible=true
                        tracer.Color=ESPConfig.TracerColor tracer.Thickness=ESPConfig.TracerThickness
                    else tracer.Visible=false end
                else tracer.Visible=false end
            else tracer.Visible=false end
            arrow.Visible=false
        end)
    end
    for _,p in pairs(Players:GetPlayers()) do createESP(p) end
    Players.PlayerAdded:Connect(createESP)
    Players.PlayerRemoving:Connect(function(p)
        if ESPComponents[p] then
            for _,c in pairs(ESPComponents[p]) do
                if typeof(c)=="table" then for _,d in pairs(c) do d:Remove() end
                else c:Remove() end
            end
            ESPComponents[p]=nil
        end
    end)
    RunService.RenderStepped:Connect(function()
        playerCountText.Text="在线玩家: "#Players:GetPlayers()
        playerCountText.Visible=ESPConfig.ESPEnabled and ESPConfig.ShowPlayerCount
        playerCountText.Color=getGradientColor(tick())
        fovCircle.Visible=ESPConfig.ShowFOV
        fovCircle.Color=ESPConfig.FOVColor
        fovCircle.Radius=ESPConfig.FOVRadius
        fovCircle.Position=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)
    end)
    ESPTab:Toggle({Title="ESP总开关",Value=false,Callback=function(v) ESPConfig.ESPEnabled=v end})
    ESPTab:Toggle({Title="显示方框",Value=false,Callback=function(v) ESPConfig.ShowBox=v end})
    ESPTab:Toggle({Title="显示血量",Value=false,Callback=function(v) ESPConfig.ShowHealth=v end})
    ESPTab:Toggle({Title="显示名称",Value=false,Callback=function(v) ESPConfig.ShowName=v end})
    ESPTab:Toggle({Title="显示距离",Value=false,Callback=function(v) ESPConfig.ShowDistance=v end})
    ESPTab:Toggle({Title="显示射线",Value=false,Callback=function(v) ESPConfig.ShowTracer=v end})
    ESPTab:Toggle({Title="队伍检查",Value=false,Callback=function(v) ESPConfig.TeamCheck=v end})
    ESPTab:Toggle({Title="显示玩家计数",Value=false,Callback=function(v) ESPConfig.ShowPlayerCount=v end})
    ESPTab:Toggle({Title="显示武器",Value=false,Callback=function(v) ESPConfig.ShowWeapon=v end})
    ESPTab:Toggle({Title="显示FOV圈",Value=false,Callback=function(v) ESPConfig.ShowFOV=v end})
    ESPTab:Slider({Title="方框粗细",Value={Min=1,Max=5,Default=1},Callback=function(v) ESPConfig.BoxThickness=v end})
    ESPTab:Slider({Title="射线粗细",Value={Min=1,Max=5,Default=1},Callback=function(v) ESPConfig.TracerThickness=v end})
    ESPTab:Slider({Title="FOV半径",Value={Min=50,Max=500,Default=100},Callback=function(v) ESPConfig.FOVRadius=v end})

    ---------------------------------------------------------------
    -- 玩家传送
    ---------------------------------------------------------------
    local TeleportPlayerTab=Window:Tab({Title="玩家传送",Icon="user"})
    local TargetPlayerName=""
    local TeleportPosition="前方"
    TeleportPlayerTab:Input({Title="输入玩家用户名",Placeholder="输入玩家名称",Callback=function(v) TargetPlayerName=v end})
    TeleportPlayerTab:Dropdown({Title="传送部位",Values={"前方","后方","头顶","左侧","右侧"},Value=TeleportPosition,Callback=function(v) TeleportPosition=v end})
    local function doTeleportOnce()
        if not TargetPlayerName or TargetPlayerName=="" then return end
        local targetPlayer=game.Players:FindFirstChild(TargetPlayerName)
        if targetPlayer and targetPlayer~=game.Players.LocalPlayer then
            if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local p=game.Players.LocalPlayer
                local c=p.Character or p.CharacterAdded:Wait()
                local h=c:WaitForChild("HumanoidRootPart")
                local targetCFrame=targetPlayer.Character.HumanoidRootPart.CFrame
                if TeleportPosition=="前方" then h.CFrame=targetCFrame*CFrame.new(0,0,-5)
                elseif TeleportPosition=="后方" then h.CFrame=targetCFrame*CFrame.new(0,0,5)
                elseif TeleportPosition=="头顶" then h.CFrame=targetCFrame*CFrame.new(0,5,0)
                elseif TeleportPosition=="左侧" then h.CFrame=targetCFrame*CFrame.new(-5,0,0)
                elseif TeleportPosition=="右侧" then h.CFrame=targetCFrame*CFrame.new(5,0,0) end
            end
        end
    end
    TeleportPlayerTab:Button({Title="传送一次",Callback=doTeleportOnce})
    local FixedTeleport=false
    TeleportPlayerTab:Toggle({Title="固定传送",Default=FixedTeleport,Callback=function(v)
        FixedTeleport=v
        if v then
            task.spawn(function() while FixedTeleport do doTeleportOnce() task.wait(0.1) end end)
        end
    end})

    ---------------------------------------------------------------
    -- 地点传送（含通缉的额外地点）
    ---------------------------------------------------------------
    local TeleportSection=Window:Tab({Title="地点传送",Icon="map-pin"})
    local function tpTo(cf)
        local p=game.Players.LocalPlayer
        local c=p.Character or p.CharacterAdded:Wait()
        local h=c:WaitForChild("HumanoidRootPart")
        h.CFrame=cf
    end
    TeleportSection:Button({Title="传送到奥菲的价值兑换",Callback=function() tpTo(CFrame.new(-2907.68848,37.1002731,1444.74817,0.848566413,3.9380446e-8,-0.529088855,-1.774107e-8,1,4.5977092e-8,0.529088855,-2.962804e-8,0.848566413)) end})
    TeleportSection:Button({Title="传送到绿洲银行",Callback=function() tpTo(CFrame.new(-431.537354,39.6113892,-1400.08313,-0.901108384,-1.61008e-8,-0.433593899,-5.2681104e-9,1,-2.618487e-8,0.433593899,-2.1311186e-8,-0.901108384)) end})
    TeleportSection:Button({Title="传送到绿洲城警察",Callback=function() tpTo(CFrame.new(2578.02393,119.169289,-718.579773,-0.395326763,-5.9598324e-8,-0.918540537,-9.65633e-9,1,-5.232432e-8,0.918540537,7.947669e-8,-0.395326763)) end})
    TeleportSection:Button({Title="传送到金库",Callback=function() tpTo(CFrame.new(-400.492279,163.151733,-1242.72632,-0.912052214,-1.09039995e-8,-0.410074085,1.4650267e-8,1,-5.9174205e-8,0.410074085,-5.997766e-8,-0.912052214)) end})
    TeleportSection:Button({Title="传送到犯罪基地",Callback=function() tpTo(CFrame.new(-5981.50586,37.2680244,1245.22046,-0.733384013,-3.6538985e-8,-0.679814577,-1.7351333e-8,1,-3.502984e-8,0.679814577,-1.38946366e-8,-0.733384013)) end})
    TeleportSection:Button({Title="传送到烈焰要塞",Callback=function() tpTo(CFrame.new(-1494.58496,41.16481,3364.56055,0.961387396,1.07588015e-7,0.275198698,-9.5233396e-8,1,-5.8255473e-8,-0.275198698,2.97983e-8,0.961387396)) end})
    -- 来自通缉的额外地点
    TeleportSection:Button({Title="传送到枪店",Callback=function() tpTo(CFrame.new(-180.77,43.13,-2805.05)) end})
    TeleportSection:Button({Title="传送到手机店",Callback=function() tpTo(CFrame.new(-905.70,42.98,-1563.35)) end})
    TeleportSection:Button({Title="传送到黑市",Callback=function() tpTo(CFrame.new(-2907.39,37.58,1652.25)) end})
    TeleportSection:Button({Title="传送到犯罪窝点",Callback=function() tpTo(CFrame.new(-7939.26,21.74,1073.52)) end})
    TeleportSection:Button({Title="传送到小银行",Callback=function() tpTo(CFrame.new(-6852.36,42.61,965.86)) end})
    TeleportSection:Button({Title="传送到银行内部",Callback=function() tpTo(CFrame.new(-399.28,617.63,-1245.29)) end})
    TeleportSection:Button({Title="传送到警察局",Callback=function() tpTo(CFrame.new(1583.31,119.86,-716.63)) end})

    ---------------------------------------------------------------
    -- 武器传送
    ---------------------------------------------------------------
    local GunsTab=Window:Tab({Title="武器传送",Icon="target"})
    local function tpGun(cf)
        tpTo(cf)
        task.wait(0.5)
        game:GetService("VirtualInputManager"):SendKeyEvent(true,Enum.KeyCode.E,false,game)
        task.wait(0.1)
        game:GetService("VirtualInputManager"):SendKeyEvent(false,Enum.KeyCode.E,false,game)
    end
    GunsTab:Button({Title="AWP狙击枪",Callback=function() tpGun(CFrame.new(-822.97,326.09,-506.58)) end})
    GunsTab:Button({Title="自动瞄准器",Callback=function() tpGun(CFrame.new(-822.973816,179.617432,-290.576813,-0.829824746,4.1572e-8,0.558024108,-1.7091425e-8,1,-9.991484e-8,-0.558024108,-9.24494e-8,-0.829824746)) end})
    GunsTab:Button({Title="UMP 45",Callback=function() tpGun(CFrame.new(1358.20264,143.366074,-1218.008301,-0.711087286,7.777568e-9,-0.703103721,0.0004326,1,1.0624305e-8,0.703103721,7.2505e-9,-0.711087286)) end})
    GunsTab:Button({Title="贝内利M1014",Callback=function() tpGun(CFrame.new(1345.20422,141.041168,-4809.10693,-0.879722357,4.0964014e-8,-0.475487679,7.8684534e-9,1,7.159378e-8,0.475487679,5.92413e-8,-0.879722357)) end})
    GunsTab:Button({Title="M4A1",Callback=function() tpGun(CFrame.new(-6342.43115,134.380051,-1328.82861,-0.984255195,1.02914e-8,0.176753372,1.648925e-8,1,3.359626e-8,-0.176753372,3.59818e-8,-0.984255195)) end})
    GunsTab:Button({Title="AK-47",Callback=function() tpGun(CFrame.new(-4825.20752,21.3648071,1192.14551,-0.907641709,3.2050632e-8,-0.419745833,5.61627e-8,1,-4.508672e-8,0.419745833,-6.44966e-8,-0.907641709)) end})
    GunsTab:Button({Title="RPG-7",Callback=function() tpGun(CFrame.new(-1392.19739,275.933319,2199.5188,-0.999439657,-4.083614e-8,-0.0334718302,-4.136207e-8,1,1.50201e-8,0.0334718302,1.6396225e-8,-0.999439657)) end})
    GunsTab:Button({Title="乌兹",Callback=function() tpGun(CFrame.new(-1348.55493,1109.2014694,2033.73645,-0.322550327,6.191085e-8,-0.946552336,8.2431725e-8,1,3.731697e-8,0.946552336,-6.598934e-8,-0.322550327)) end})

    ---------------------------------------------------------------
    -- 娱乐（自动发言 / 天气 / 天空盒）
    ---------------------------------------------------------------
    local FunTab=Window:Tab({Title="娱乐",Icon="settings"})
    _G.AUTO_CHAT_TEXT="SX HUB ！！！"
    _G.AUTO_CHAT_ENABLED=false
    _G.AUTO_CHAT_INTERVAL=1.5
    _G.AUTO_CHAT_MODE="自定义"
    local chatSystem={
        Players=game:GetService("Players"),
        ReplicatedStorage=game:GetService("ReplicatedStorage"),
        TextChatService=game:GetService("TextChatService"),
        messageIndex=1,
        chatModes={
            ["自定义"]=function() return {_G.AUTO_CHAT_TEXT} end,
            ["7字经"]=function() return {"来老弟","你有啥实力","你活着干啥呢","臭底层","快来打压你爹","我在这等着呢","快来打压我"} end,
            ["14字经"]=function() return {"你有啥用","你活着干啥呢","赶紧跳了吧","老弟家里几位在哪里","来吧赶紧让我口吃","你爹等着你呢","你个窝囊废","孩子快来呀","怎么不敢和你爹对话了？","你有什么用处","你活着当技女吗？","一句话","来打压我","哈哈哈笑死我了"} end,
            ["糖人语言"]=function() return {"我是奶龙","奶龙是我","你是谁？？","我是谁","你干嘛啊？"} end,
            ["宣传词"]=function() return {"SX HUB牛逼","打败一切","快来购买","功能多多","支持超多服务器"} end
        },
        connections={},
        active=false
    }
    chatSystem.tryTextChatSend=function(msg)
        local ok=false
        pcall(function()
            local ch=chatSystem.TextChatService.TextChannels:FindFirstChild("RBXGeneral") or chatSystem.TextChatService.TextChannels:FindFirstChild("RBXGeneralChannel")
            if ch and ch.SendAsync then ch:SendAsync(msg) ok=true end
        end)
        return ok
    end
    chatSystem.tryOldChatSend=function(msg)
        local ok=false
        pcall(function()
            local ev=chatSystem.ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            local req=ev and ev:FindFirstChild("SayMessageRequest")
            if req then req:FireServer(msg,"All") ok=true end
        end)
        return ok
    end
    chatSystem.tryPlayerChat=function(msg)
        local ok=false
        pcall(function()
            local pl=chatSystem.Players.LocalPlayer
            if pl and pl.Chat then pl:Chat(msg) ok=true end
        end)
        return ok
    end
    chatSystem.doSend=function(msg)
        local sent=chatSystem.tryTextChatSend(msg)
        if not sent then sent=chatSystem.tryOldChatSend(msg) end
        if not sent then sent=chatSystem.tryPlayerChat(msg) end
        return sent
    end
    chatSystem.startAutoChat=function()
        if chatSystem.active then return end
        chatSystem.active=true
        chatSystem.connections.autoChat=game:GetService("RunService").Heartbeat:Connect(function()
            if _G.AUTO_CHAT_ENABLED and chatSystem.chatModes[_G.AUTO_CHAT_MODE] then
                local ct=tick()
                local lst=chatSystem.lastSendTime or 0
                local interval=tonumber(_G.AUTO_CHAT_INTERVAL) or 1.5
                if ct-lst>=interval then
                    local messages=chatSystem.chatModes[_G.AUTO_CHAT_MODE]()
                    if messages and #messages>0 then
                        chatSystem.doSend(tostring(messages[chatSystem.messageIndex]))
                        chatSystem.messageIndex=(chatSystem.messageIndex % #messages)+1
                        chatSystem.lastSendTime=ct
                    end
                end
            end
        end)
    end
    chatSystem.stopAutoChat=function()
        chatSystem.active=false
        if chatSystem.connections.autoChat then chatSystem.connections.autoChat:Disconnect() chatSystem.connections.autoChat=nil end
    end
    task.spawn(chatSystem.startAutoChat)
    FunTab:Dropdown({Title="发言模式",Values={"自定义","7字经","14字经","糖人语言","宣传词"},Value="自定义",Callback=function(value)
        _G.AUTO_CHAT_MODE=value chatSystem.messageIndex=1
    end})
    FunTab:Input({Title="自定义发言内容",Placeholder="输入要发送的消息",Value="SX HUB ！！！",Callback=function(value) _G.AUTO_CHAT_TEXT=value end})
    FunTab:Toggle({Title="开启自动发言",Value=false,Callback=function(value)
        _G.AUTO_CHAT_ENABLED=value
        if value and not chatSystem.active then chatSystem.startAutoChat()
        elseif not value then chatSystem.stopAutoChat() end
    end})
    FunTab:Slider({Title="发言间隔",Value={Min=0.5,Max=10,Default=1.5},Callback=function(value) _G.AUTO_CHAT_INTERVAL=value end})

    -- 天气 / 天空盒
    local weatherSettings={["雨天"]="Rainy",["阴天"]="Overcast",["晴天"]="Clear",["雪天"]="Snowy"}
    local selectedWeather="晴天"
    local function changeWeather(weatherType)
        local lighting=game:GetService("Lighting")
        lighting.ClockTime=14 lighting.Brightness=1 lighting.FogEnd=10000 lighting.GlobalShadows=true
        for _,obj in pairs(lighting:GetChildren()) do if obj:IsA("ParticleEmitter") or obj.Name=="WeatherEffect" then obj:Destroy() end end
        if weatherType=="Rainy" then
            lighting.Brightness=0.7 lighting.FogEnd=5000 lighting.ExposureCompensation=-0.5
            local rain=Instance.new("ParticleEmitter")
            rain.Name="WeatherEffect" rain.Parent=lighting
            rain.Texture="rbxassetid://2530913495" rain.Size=NumberSequence.new(0.5)
            rain.Transparency=NumberSequence.new(0.3) rain.Lifetime=NumberRange.new(5)
            rain.Rate=100 rain.Speed=NumberRange.new(20) rain.VelocitySpread=90
        elseif weatherType=="Overcast" then
            lighting.Brightness=0.6 lighting.FogEnd=3000 lighting.ExposureCompensation=-0.8 lighting.OutdoorAmbient=Color3.fromRGB(100,100,100)
        elseif weatherType=="Clear" then
            lighting.Brightness=2 lighting.FogEnd=20000 lighting.ExposureCompensation=0.3 lighting.OutdoorAmbient=Color3.fromRGB(255,255,255)
        elseif weatherType=="Snowy" then
            lighting.Brightness=1.2 lighting.FogEnd=8000 lighting.ExposureCompensation=0.1
            local snow=Instance.new("ParticleEmitter")
            snow.Name="WeatherEffect" snow.Parent=lighting
            snow.Texture="rbxassetid://2530914826" snow.Size=NumberSequence.new(0.3)
            snow.Transparency=NumberSequence.new(0.1) snow.Lifetime=NumberRange.new(8)
            snow.Rate=80 snow.Speed=NumberRange.new(5) snow.VelocitySpread=45
            snow.LightInfluence=0
        end
    end
    FunTab:Dropdown({Title="选择天气",Values={"雨天","阴天","晴天","雪天"},Value="晴天",Callback=function(o) selectedWeather=o end})
    FunTab:Button({Title="确认变换天气",Callback=function() changeWeather(weatherSettings[selectedWeather]) end})

    local skySettings={
        ["神青天空1"]="http://www.roblox.com/asset/?id=112666167201442",
        ["神青天空2"]="http://www.roblox.com/asset/?id=105006817202266",
        ["动漫猫羽雫天空"]="http://www.roblox.com/asset/?id=16060333448"
    }
    local selectedSky="神青天空1"
    local function changeSky(skyboxId)
        local lighting=game:GetService("Lighting")
        for _,obj in pairs(lighting:GetChildren()) do if obj:IsA("Sky") then obj:Destroy() end end
        local sky=Instance.new("Sky")
        sky.CelestialBodiesShown=false
        sky.Parent=lighting
        sky.SkyboxUp=skyboxId sky.SkyboxBk=skyboxId sky.SkyboxDn=skyboxId
        sky.SkyboxRt=skyboxId sky.SkyboxLf=skyboxId sky.SkyboxFt=skyboxId
    end
    FunTab:Dropdown({Title="选择天空盒",Values={"神青天空1","神青天空2","动漫猫羽雫天空"},Value="神青天空1",Callback=function(o) selectedSky=o end})
    FunTab:Button({Title="确认变换天空",Callback=function() changeSky(skySettings[selectedSky]) end})

    ---------------------------------------------------------------
    -- UI 设置
    ---------------------------------------------------------------
    local Settings=Window:Tab({Title="ui设置",Icon="palette"})
    Settings:Paragraph({Title="ui设置",Desc="二改wind原版ui"})
    Settings:Toggle({Title="启用边框",Value=borderEnabled,Callback=function(value)
        borderEnabled=value
        local mainFrame=Window.UIElements and Window.UIElements.Main
        if mainFrame then
            local rainbowStroke=mainFrame:FindFirstChild("RainbowStroke")
            if rainbowStroke then
                rainbowStroke.Enabled=value
                if value and windowOpen and not rainbowBorderAnimation then startBorderAnimation(Window,animationSpeed)
                elseif not value and rainbowBorderAnimation then rainbowBorderAnimation:Disconnect() rainbowBorderAnimation=nil end
            end
        end
    end})
    Settings:Toggle({Title="启用字体颜色",Value=fontColorEnabled,Callback=function(value) fontColorEnabled=value applyFontColorsToWindow(currentFontColorScheme) end})
    Settings:Toggle({Title="启用音效",Value=soundEnabled,Callback=function(value) soundEnabled=value end})
    Settings:Toggle({Title="启用背景模糊",Value=blurEnabled,Callback=function(value) blurEnabled=value applyBlurEffect(value) end})
    local colorSchemeNames={}
    for name,_ in pairs(COLOR_SCHEMES) do table.insert(colorSchemeNames,name) end
    table.sort(colorSchemeNames)
    Settings:Dropdown({Title="边框颜色方案",Values=colorSchemeNames,Value="彩虹颜色",Callback=function(value) currentBorderColorScheme=value initializeRainbowBorder(value,animationSpeed) playSound() end})
    Settings:Dropdown({Title="字体颜色方案",Values=colorSchemeNames,Value="彩虹颜色",Callback=function(value) currentFontColorScheme=value applyFontColorsToWindow(value) playSound() end})
    local fontOptions={}
    for _,fontName in ipairs(FONT_STYLES) do table.insert(fontOptions,{text=FONT_DESCRIPTIONS[fontName] or fontName,value=fontName}) end
    table.sort(fontOptions,function(a,b) return a.text<b.text end)
    local fontValues={}
    local fontValueToName={}
    for _,option in ipairs(fontOptions) do table.insert(fontValues,option.text) fontValueToName[option.text]=option.value end
    Settings:Dropdown({Title="字体样式",Values=fontValues,Value="标准粗体",Callback=function(value)
        local fontName=fontValueToName[value]
        if fontName then currentFontStyle=fontName applyFontStyleToWindow(fontName) playSound() end
    end})
    Settings:Slider({Title="边框转动速度",Value={Min=1,Max=10,Default=5},Callback=function(value)
        animationSpeed=value
        if rainbowBorderAnimation then rainbowBorderAnimation:Disconnect() rainbowBorderAnimation=nil end
        if borderEnabled then startBorderAnimation(Window,animationSpeed) end
        applyFontColorsToWindow(currentFontColorScheme)
    end})
    Settings:Slider({Title="UI整体缩放",Value={Min=0.5,Max=1.5,Default=1},Step=0.1,Callback=function(value) uiScale=value applyUIScale(value) end})
    Settings:Slider({Title="UI透明度",Value={Min=0,Max=1,Default=0.2},Step=0.1,Callback=function(value)
        Window:ToggleTransparency(tonumber(value)>0)
        WindUI.TransparencyValue=tonumber(value)
    end})
    Settings:Slider({Title="调整UI宽度",Value={Min=500,Max=800,Default=600},Callback=function(value)
        if Window.UIElements and Window.UIElements.Main then Window.UIElements.Main.Size=UDim2.fromOffset(value,400) end
    end})
    Settings:Slider({Title="调整UI高度",Value={Min=300,Max=600,Default=400},Callback=function(value)
        if Window.UIElements and Window.UIElements.Main then
            local cw=Window.UIElements.Main.Size.X.Offset
            Window.UIElements.Main.Size=UDim2.fromOffset(cw,value)
        end
    end})
    Settings:Slider({Title="边框粗细",Value={Min=1,Max=5,Default=1.5},Step=0.5,Callback=function(value)
        local mainFrame=Window.UIElements and Window.UIElements.Main
        if mainFrame then
            local rainbowStroke=mainFrame:FindFirstChild("RainbowStroke")
            if rainbowStroke then rainbowStroke.Thickness=value end
        end
    end})
    Settings:Slider({Title="圆角大小",Value={Min=0,Max=20,Default=16},Callback=function(value)
        local mainFrame=Window.UIElements and Window.UIElements.Main
        if mainFrame then
            local corner=mainFrame:FindFirstChildOfClass("UICorner")
            if not corner then corner=Instance.new("UICorner") corner.Parent=mainFrame end
            corner.CornerRadius=UDim.new(0,value)
        end
    end})
    Settings:Button({Title="恢复UI到原位",Icon="rotate-ccw",Callback=function() if Window.UIElements and Window.UIElements.Main then Window.UIElements.Main.Position=UDim2.new(0.5,0,0.5,0) end end})
    Settings:Button({Title="重置UI大小",Icon="maximize-2",Callback=function() if Window.UIElements and Window.UIElements.Main then Window.UIElements.Main.Size=UDim2.fromOffset(600,400) end end})
    Settings:Button({Title="随机字体",Icon="shuffle",Callback=function()
        local rf=FONT_STYLES[math.random(1,#FONT_STYLES)]
        currentFontStyle=rf applyFontStyleToWindow(rf)
    end})
    Settings:Button({Title="随机颜色",Icon="palette",Callback=function()
        local rc=colorSchemeNames[math.random(1,#colorSchemeNames)]
        currentBorderColorScheme=rc initializeRainbowBorder(rc,animationSpeed)
    end})

    Window:OnClose(function()
        windowOpen=false
        if rainbowBorderAnimation then rainbowBorderAnimation:Disconnect() rainbowBorderAnimation=nil end
        applyBlurEffect(false)
    end)
    Window:OnDestroy(function()
        windowOpen=false
        if rainbowBorderAnimation then rainbowBorderAnimation:Disconnect() rainbowBorderAnimation=nil end
        for _,a in pairs(fontColorAnimations) do a:Disconnect() end
        fontColorAnimations={}
        applyBlurEffect(false)
    end)
end