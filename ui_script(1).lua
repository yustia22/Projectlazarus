--[[
    PROJECT LAZARUS : ZOMBIES HUB  v5
    Pure Roblox GUI — no external libraries
    Works on Velocity and all executors
]]

-- ════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local LocalPlayer      = Players.LocalPlayer

local function GetCharacter() return LocalPlayer.Character end
local function GetHumanoid()  local c=GetCharacter(); return c and c:FindFirstChildOfClass("Humanoid") end
local function GetRootPart()  local c=GetCharacter(); return c and c:FindFirstChild("HumanoidRootPart") end

-- ════════════════════════════════════════
--  DESTROY OLD GUI  (safe re-execute)
-- ════════════════════════════════════════
pcall(function()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        local old = pg:FindFirstChild("PLZombiesHub")
        if old then old:Destroy() end
    end
end)

-- ════════════════════════════════════════
--  CREATE SCREENGUI  (PlayerGui — safest)
-- ════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "PLZombiesHub"
ScreenGui.ResetOnSpawn   = false
ScreenGui.DisplayOrder   = 999
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent         = LocalPlayer:WaitForChild("PlayerGui")

-- ════════════════════════════════════════
--  COLOURS
-- ════════════════════════════════════════
local C_BG     = Color3.fromRGB(18,  18,  24)
local C_SIDE   = Color3.fromRGB(22,  22,  30)
local C_PANEL  = Color3.fromRGB(26,  26,  34)
local C_ITEM   = Color3.fromRGB(32,  32,  42)
local C_ACCENT = Color3.fromRGB(210, 50,  50)
local C_TEXT   = Color3.fromRGB(235, 235, 235)
local C_SUB    = Color3.fromRGB(150, 150, 162)
local C_ON     = Color3.fromRGB(70,  200, 90)
local C_OFF    = Color3.fromRGB(70,  70,  85)

-- ════════════════════════════════════════
--  MAIN WINDOW
-- ════════════════════════════════════════
local WIN_W, WIN_H = 540, 380

local Win = Instance.new("Frame", ScreenGui)
Win.Name             = "Win"
Win.Size             = UDim2.fromOffset(WIN_W, WIN_H)
Win.Position         = UDim2.new(0.5,-WIN_W/2, 0.5,-WIN_H/2)
Win.BackgroundColor3 = C_BG
Win.BorderSizePixel  = 0
Win.Active           = true
Win.Draggable        = true
Instance.new("UICorner", Win).CornerRadius = UDim.new(0,10)

-- Title bar
local TBar = Instance.new("Frame", Win)
TBar.Size             = UDim2.new(1,0,0,36)
TBar.BackgroundColor3 = C_SIDE
TBar.BorderSizePixel  = 0
Instance.new("UICorner", TBar).CornerRadius = UDim.new(0,10)
local TBarSq = Instance.new("Frame", TBar)
TBarSq.Size             = UDim2.new(1,0,0.5,0)
TBarSq.Position         = UDim2.new(0,0,0.5,0)
TBarSq.BackgroundColor3 = C_SIDE
TBarSq.BorderSizePixel  = 0

local TitleLbl = Instance.new("TextLabel", TBar)
TitleLbl.Size                  = UDim2.new(1,-80,1,0)
TitleLbl.Position              = UDim2.new(0,12,0,0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.TextColor3            = C_TEXT
TitleLbl.Font                  = Enum.Font.GothamBold
TitleLbl.TextSize              = 14
TitleLbl.Text                  = "PL Zombies Hub  v5"
TitleLbl.TextXAlignment        = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TBar)
CloseBtn.Size             = UDim2.fromOffset(24,24)
CloseBtn.Position         = UDim2.new(1,-30,0.5,-12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180,45,45)
CloseBtn.TextColor3       = C_TEXT
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.TextSize         = 14
CloseBtn.Text             = "×"
CloseBtn.BorderSizePixel  = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,5)
CloseBtn.MouseButton1Click:Connect(function()
    Win.Visible = not Win.Visible
end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.LeftAlt then
        Win.Visible = not Win.Visible
    end
end)

-- ════════════════════════════════════════
--  SIDEBAR
-- ════════════════════════════════════════
local SIDE_W = 112

local Sidebar = Instance.new("Frame", Win)
Sidebar.Size             = UDim2.new(0,SIDE_W,1,-36)
Sidebar.Position         = UDim2.new(0,0,0,36)
Sidebar.BackgroundColor3 = C_SIDE
Sidebar.BorderSizePixel  = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0,10)
local SideSqT = Instance.new("Frame", Sidebar)
SideSqT.Size             = UDim2.new(1,0,0,10)
SideSqT.BackgroundColor3 = C_SIDE
SideSqT.BorderSizePixel  = 0
local SideSqR = Instance.new("Frame", Sidebar)
SideSqR.Size             = UDim2.new(0,10,1,0)
SideSqR.Position         = UDim2.new(1,-10,0,0)
SideSqR.BackgroundColor3 = C_SIDE
SideSqR.BorderSizePixel  = 0

local TabListF = Instance.new("Frame", Sidebar)
TabListF.Size                   = UDim2.new(1,-8,1,-8)
TabListF.Position               = UDim2.new(0,4,0,6)
TabListF.BackgroundTransparency = 1
local TabLayout = Instance.new("UIListLayout", TabListF)
TabLayout.SortOrder             = Enum.SortOrder.LayoutOrder
TabLayout.Padding               = UDim.new(0,3)

-- ════════════════════════════════════════
--  CONTENT AREA
-- ════════════════════════════════════════
local ContentArea = Instance.new("Frame", Win)
ContentArea.Size             = UDim2.new(1,-SIDE_W-8,1,-42)
ContentArea.Position         = UDim2.new(0,SIDE_W+5,0,39)
ContentArea.BackgroundColor3 = C_PANEL
ContentArea.BorderSizePixel  = 0
Instance.new("UICorner", ContentArea).CornerRadius = UDim.new(0,8)

-- ════════════════════════════════════════
--  TAB SYSTEM
-- ════════════════════════════════════════
local Tabs    = {}
local TabBtns = {}
local TabOrd  = 0

local function SelectTab(name)
    for n, data in pairs(Tabs) do
        data.scroll.Visible = (n == name)
        local b = TabBtns[n]
        if b then
            b.BackgroundColor3 = (n == name) and Color3.fromRGB(38,38,52) or C_ITEM
            b.TextColor3       = (n == name) and C_TEXT or C_SUB
        end
    end
end

local function NewTab(name)
    TabOrd = TabOrd + 1
    local btn = Instance.new("TextButton", TabListF)
    btn.Size             = UDim2.new(1,0,0,30)
    btn.BackgroundColor3 = C_ITEM
    btn.TextColor3       = C_SUB
    btn.Font             = Enum.Font.Gotham
    btn.TextSize         = 12
    btn.Text             = name
    btn.BorderSizePixel  = 0
    btn.LayoutOrder      = TabOrd
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,5)
    TabBtns[name] = btn

    local scroll = Instance.new("ScrollingFrame", ContentArea)
    scroll.Size                   = UDim2.new(1,0,1,0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel        = 0
    scroll.ScrollBarThickness     = 3
    scroll.ScrollBarImageColor3   = C_ACCENT
    scroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    scroll.CanvasSize             = UDim2.new(0,0,0,0)
    scroll.Visible                = false
    local lay = Instance.new("UIListLayout", scroll)
    lay.SortOrder                 = Enum.SortOrder.LayoutOrder
    lay.Padding                   = UDim.new(0,4)
    local pad = Instance.new("UIPadding", scroll)
    pad.PaddingLeft               = UDim.new(0,6)
    pad.PaddingRight              = UDim.new(0,6)
    pad.PaddingTop                = UDim.new(0,6)
    pad.PaddingBottom             = UDim.new(0,6)

    local tab = { scroll=scroll, order=0 }
    Tabs[name] = tab
    btn.MouseButton1Click:Connect(function() SelectTab(name) end)
    return tab
end

-- ════════════════════════════════════════
--  WIDGET BUILDERS
-- ════════════════════════════════════════
local function MkItem(tab, h)
    tab.order = tab.order + 1
    local f = Instance.new("Frame", tab.scroll)
    f.Size             = UDim2.new(1,0,0,h or 36)
    f.BackgroundColor3 = C_ITEM
    f.BorderSizePixel  = 0
    f.LayoutOrder      = tab.order
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
    return f
end

local function MkSection(tab, name)
    tab.order = tab.order + 1
    local f = Instance.new("Frame", tab.scroll)
    f.Size                   = UDim2.new(1,0,0,20)
    f.BackgroundTransparency = 1
    f.LayoutOrder            = tab.order
    local l = Instance.new("TextLabel", f)
    l.Size                   = UDim2.new(1,0,1,0)
    l.BackgroundTransparency = 1
    l.TextColor3             = C_ACCENT
    l.Font                   = Enum.Font.GothamBold
    l.TextSize               = 11
    l.Text                   = "— "..name:upper()
    l.TextXAlignment         = Enum.TextXAlignment.Left
end

local function MkToggle(tab, name, cb)
    local f = MkItem(tab, 36)
    local lbl = Instance.new("TextLabel", f)
    lbl.Size                   = UDim2.new(1,-54,1,0)
    lbl.Position               = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3             = C_TEXT
    lbl.Font                   = Enum.Font.Gotham
    lbl.TextSize               = 13
    lbl.Text                   = name
    lbl.TextXAlignment         = Enum.TextXAlignment.Left

    local pill = Instance.new("Frame", f)
    pill.Size             = UDim2.fromOffset(36,18)
    pill.Position         = UDim2.new(1,-46,0.5,-9)
    pill.BackgroundColor3 = C_OFF
    pill.BorderSizePixel  = 0
    Instance.new("UICorner", pill).CornerRadius = UDim.new(0,9)

    local knob = Instance.new("Frame", pill)
    knob.Size             = UDim2.fromOffset(14,14)
    knob.Position         = UDim2.new(0,2,0.5,-7)
    knob.BackgroundColor3 = Color3.fromRGB(220,220,220)
    knob.BorderSizePixel  = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0,7)

    local state = false
    local hit = Instance.new("TextButton", f)
    hit.Size                   = UDim2.new(1,0,1,0)
    hit.BackgroundTransparency = 1
    hit.Text                   = ""
    hit.MouseButton1Click:Connect(function()
        state = not state
        pill.BackgroundColor3 = state and C_ON or C_OFF
        knob.Position = state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
        pcall(cb, state)
    end)
end

local function MkSlider(tab, name, mn, mx, def, suf, cb)
    local f = MkItem(tab, 50)
    local topL = Instance.new("TextLabel", f)
    topL.Size                   = UDim2.new(0.65,0,0,18)
    topL.Position               = UDim2.new(0,10,0,5)
    topL.BackgroundTransparency = 1
    topL.TextColor3             = C_TEXT
    topL.Font                   = Enum.Font.Gotham
    topL.TextSize               = 12
    topL.Text                   = name
    topL.TextXAlignment         = Enum.TextXAlignment.Left

    local valL = Instance.new("TextLabel", f)
    valL.Size                   = UDim2.new(0.3,0,0,18)
    valL.Position               = UDim2.new(0.68,-8,0,5)
    valL.BackgroundTransparency = 1
    valL.TextColor3             = C_ACCENT
    valL.Font                   = Enum.Font.GothamBold
    valL.TextSize               = 12
    valL.Text                   = tostring(def)..(suf or "")
    valL.TextXAlignment         = Enum.TextXAlignment.Right

    local track = Instance.new("Frame", f)
    track.Size             = UDim2.new(1,-20,0,5)
    track.Position         = UDim2.new(0,10,0,33)
    track.BackgroundColor3 = Color3.fromRGB(45,45,58)
    track.BorderSizePixel  = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(0,3)

    local pct0 = (def-mn)/(mx-mn)
    local fill = Instance.new("Frame", track)
    fill.Size             = UDim2.new(pct0,0,1,0)
    fill.BackgroundColor3 = C_ACCENT
    fill.BorderSizePixel  = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0,3)

    local knob = Instance.new("Frame", track)
    knob.Size             = UDim2.fromOffset(11,11)
    knob.AnchorPoint      = Vector2.new(0.5,0.5)
    knob.Position         = UDim2.new(pct0,0,0.5,0)
    knob.BackgroundColor3 = Color3.fromRGB(230,230,230)
    knob.BorderSizePixel  = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0,6)

    local drag = false
    local function upd(x)
        local p = math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local v = math.floor(mn+(mx-mn)*p)
        fill.Size     = UDim2.new(p,0,1,0)
        knob.Position = UDim2.new(p,0,0.5,0)
        valL.Text     = tostring(v)..(suf or "")
        pcall(cb, v)
    end
    local ib = Instance.new("TextButton", track)
    ib.Size = UDim2.new(1,0,4,0); ib.Position = UDim2.new(0,0,-1.5,0)
    ib.BackgroundTransparency = 1; ib.Text = ""
    ib.MouseButton1Down:Connect(function() drag=true end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)
    ib.MouseButton1Click:Connect(function() upd(UserInputService:GetMouseLocation().X) end)
end

local function MkButton(tab, name, cb)
    local f = MkItem(tab, 34)
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency=1
    btn.TextColor3=C_TEXT; btn.Font=Enum.Font.Gotham; btn.TextSize=13
    btn.Text=name; btn.BorderSizePixel=0
    btn.MouseButton1Click:Connect(function() pcall(cb) end)
    btn.MouseEnter:Connect(function() f.BackgroundColor3=Color3.fromRGB(42,42,56) end)
    btn.MouseLeave:Connect(function() f.BackgroundColor3=C_ITEM end)
    local arr = Instance.new("TextLabel", f)
    arr.Size=UDim2.fromOffset(20,34); arr.Position=UDim2.new(1,-24,0,0)
    arr.BackgroundTransparency=1; arr.TextColor3=C_ACCENT
    arr.Font=Enum.Font.GothamBold; arr.TextSize=16; arr.Text="›"
end

local function MkParagraph(tab, title, body)
    local lines = math.max(1, math.ceil(#body/52))
    local f = MkItem(tab, 24+lines*14)
    f.BackgroundColor3 = Color3.fromRGB(22,22,30)
    local t = Instance.new("TextLabel", f)
    t.Size=UDim2.new(1,-16,0,16); t.Position=UDim2.new(0,8,0,5)
    t.BackgroundTransparency=1; t.TextColor3=C_TEXT
    t.Font=Enum.Font.GothamBold; t.TextSize=12
    t.Text=title; t.TextXAlignment=Enum.TextXAlignment.Left
    local d = Instance.new("TextLabel", f)
    d.Size=UDim2.new(1,-16,0,lines*14); d.Position=UDim2.new(0,8,0,20)
    d.BackgroundTransparency=1; d.TextColor3=C_SUB
    d.Font=Enum.Font.Gotham; d.TextSize=11; d.TextWrapped=true
    d.Text=body; d.TextXAlignment=Enum.TextXAlignment.Left
end

-- ════════════════════════════════════════
--  NOTIFICATION
-- ════════════════════════════════════════
local function Notify(title, desc, dur)
    dur = dur or 4
    pcall(function()
        local ng = Instance.new("ScreenGui")
        ng.Name="PLNotif"; ng.ResetOnSpawn=false
        ng.DisplayOrder=1000; ng.IgnoreGuiInset=true
        ng.Parent=LocalPlayer.PlayerGui
        local f=Instance.new("Frame",ng)
        f.Size=UDim2.fromOffset(270,56); f.Position=UDim2.new(1,-282,0,10)
        f.BackgroundColor3=Color3.fromRGB(22,22,30); f.BorderSizePixel=0
        Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)
        local a=Instance.new("Frame",f)
        a.Size=UDim2.new(0,3,1,0); a.BackgroundColor3=C_ACCENT; a.BorderSizePixel=0
        Instance.new("UICorner",a).CornerRadius=UDim.new(0,3)
        local t=Instance.new("TextLabel",f)
        t.Size=UDim2.new(1,-14,0,20); t.Position=UDim2.new(0,9,0,5)
        t.BackgroundTransparency=1; t.TextColor3=C_TEXT
        t.Font=Enum.Font.GothamBold; t.TextSize=12; t.Text=title
        t.TextXAlignment=Enum.TextXAlignment.Left
        local d=Instance.new("TextLabel",f)
        d.Size=UDim2.new(1,-14,0,18); d.Position=UDim2.new(0,9,0,26)
        d.BackgroundTransparency=1; d.TextColor3=C_SUB
        d.Font=Enum.Font.Gotham; d.TextSize=11; d.TextWrapped=true
        d.Text=desc; d.TextXAlignment=Enum.TextXAlignment.Left
        task.delay(dur, function() if ng and ng.Parent then ng:Destroy() end end)
    end)
end

-- ════════════════════════════════════════
--  GAME STATE
-- ════════════════════════════════════════
local RoundNum = Workspace:FindFirstChild("RoundNum") or {Value=1}

local State = {
    InfAmmoEnabled=false, InstaKillEnabled=false,
    NoRecoilEnabled=false, NoSpreadEnabled=false,
    KillAuraEnabled=false, KillAuraRange=40,
    FreezeEnabled=false,
    AutoFortEnabled=false, AutoFortRange=20,
    ESPEnabled=false, ESPBoxes={},
    PointsAmount=1000,
    SpeedEnabled=false, SpeedValue=16,
    JumpEnabled=false,  JumpValue=50,
    InfiniteJump=false,
    NoclipEnabled=false,
    FlyEnabled=false, FlySpeed=50,
    FlyBody=nil, FlyAtt=nil,
    damage_key=nil, Connections={},
}

-- ════════════════════════════════════════
--  DAMAGE KEY
-- ════════════════════════════════════════
local function GetDamageKey()
    if type(getgc)=="function" and type(getinfo)=="function" and type(getupvalues)=="function" then
        local ok,gc=pcall(getgc)
        if ok and gc then
            for _,fn in next,gc do
                if type(fn)=="function" then
                    local ok2,info=pcall(getinfo,fn)
                    if ok2 and info and info.name=="Knife" then
                        local ok3,ups=pcall(getupvalues,fn)
                        if ok3 and ups then
                            for _,val in next,ups do
                                if type(val)=="number" then
                                    State.damage_key=val; return val
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return State.damage_key
end
task.spawn(function() while task.wait(2) do pcall(GetDamageKey) end end)

-- ════════════════════════════════════════
--  SMART DAMAGE
-- ════════════════════════════════════════
local function GetSmartDamage()
    local r=math.max(1, RoundNum.Value or 1)
    local hp=r<10 and (50+100*r) or (950*(1.1^(r-9)))
    return math.ceil(hp*1.10)
end

-- ════════════════════════════════════════
--  GUN PATCHERS
-- ════════════════════════════════════════
local GunBackups={}
local function deepcopy(t,seen)
    seen=seen or {}
    if type(t)~="table" then return t end
    if seen[t] then return seen[t] end
    local c={}; seen[t]=c
    for k,v in next,t do c[deepcopy(k,seen)]=deepcopy(v,seen) end
    setmetatable(c,deepcopy(getmetatable(t),seen))
    return c
end
local function BackupGun(m) if not rawget(GunBackups,m) then rawset(GunBackups,m,deepcopy(m)) end end
local function RestoreGun(m) local b=rawget(GunBackups,m); if not b then return end; for k,v in next,b do pcall(rawset,m,k,v) end end
local function ZeroTable(t)
    if type(t)~="table" then return end
    for k,v in next,t do
        if type(v)=="number" then rawset(t,k,0) elseif type(v)=="table" then ZeroTable(v) end
    end
end
local function PatchAmmo(m)
    BackupGun(m)
    local keys={ammo=true,storedammo=true,maxammo=true,magsize=true,
        bulletcount=true,clipsize=true,magazinesize=true,reserveammo=true}
    for k in next,m do if type(k)=="string" and keys[k:lower()] then rawset(m,k,99) end end
end
local function PatchDamage(m)
    BackupGun(m); local dmg=GetSmartDamage()
    for k,v in next,m do
        if type(k)=="string" then
            local kl=k:lower()
            if kl:find("headshot") or kl:find("torsoshot") or kl:find("limbshot") then rawset(m,k,dmg)
            elseif kl=="damage" and type(v)=="table" then rawset(m,k,{Max=dmg,Min=math.floor(dmg*0.95)}) end
        end
    end
end
local function PatchRecoil(m)
    BackupGun(m)
    for k,v in next,m do
        if type(k)=="string" then
            local kl=k:lower()
            if kl:find("viewkick") or kl:find("recoil") or kl:find("kick") or kl:find("sway") then
                if type(v)=="table" then ZeroTable(v) else rawset(m,k,0) end
            end
        end
    end
end
local function PatchSpread(m)
    BackupGun(m)
    for k,v in next,m do
        if type(k)=="string" then
            local kl=k:lower()
            if kl:find("spread") or kl:find("bloom") then
                if type(v)=="table" then rawset(v,"Min",0); rawset(v,"Max",0); ZeroTable(v)
                else rawset(m,k,0) end
            end
        end
    end
end
local function RunPatch(m)
    if State.InfAmmoEnabled   then pcall(PatchAmmo,  m) end
    if State.InstaKillEnabled then pcall(PatchDamage, m) end
    if State.NoRecoilEnabled  then pcall(PatchRecoil, m) end
    if State.NoSpreadEnabled  then pcall(PatchSpread, m) end
    if not(State.InfAmmoEnabled or State.InstaKillEnabled or State.NoRecoilEnabled or State.NoSpreadEnabled) then
        pcall(RestoreGun,m)
    end
end

-- ════════════════════════════════════════
--  WEAPON ATTACHMENT
-- ════════════════════════════════════════
local function AttachWeapon(child)
    local slot=child.Name
    if slot~="Weapon1" and slot~="Weapon2" and slot~="Weapon3" then return end
    if State.Connections[slot] then State.Connections[slot]:Disconnect() end
    local ok,m=pcall(require,child)
    if not ok or type(m)~="table" then return end
    State.Connections[slot]=RunService.RenderStepped:Connect(function() pcall(RunPatch,m) end)
end
local function SetupBackpack()
    local bp=LocalPlayer:WaitForChild("Backpack",10); if not bp then return end
    for _,c in ipairs(bp:GetChildren()) do pcall(AttachWeapon,c) end
    if State.Connections.Backpack then State.Connections.Backpack:Disconnect() end
    State.Connections.Backpack=bp.ChildAdded:Connect(function(c) pcall(AttachWeapon,c) end)
end

-- ════════════════════════════════════════
--  ZOMBIE HELPERS
-- ════════════════════════════════════════
local function GetZombies()
    local out,chars={},{}
    for _,p in ipairs(Players:GetPlayers()) do if p.Character then chars[p.Character]=true end end
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Health>0 then
            local model=obj.Parent
            if model and model:IsA("Model") and not chars[model] then
                local hrp=model:FindFirstChild("HumanoidRootPart")
                if hrp then table.insert(out,{model=model,hum=obj,hrp=hrp}) end
            end
        end
    end
    return out
end
local function FindDamageRemote()
    for _,z in ipairs(GetZombies()) do
        local r=z.hum:FindFirstChild("Damage")
        if r and r:IsA("RemoteEvent") then return r,z.hrp end
    end
end

-- ════════════════════════════════════════
--  FEATURES
-- ════════════════════════════════════════
local function StartKillAura()
    if State.Connections.KillAura then State.Connections.KillAura:Disconnect() end
    local rate=0
    State.Connections.KillAura=RunService.Heartbeat:Connect(function(dt)
        if not State.KillAuraEnabled then return end
        rate=rate+dt; if rate<0.15 then return end; rate=0
        local rp=GetRootPart(); if not rp then return end
        local key=GetDamageKey()
        for _,z in ipairs(GetZombies()) do
            if (z.hrp.Position-rp.Position).Magnitude<=State.KillAuraRange then
                local r=z.hum:FindFirstChild("Damage")
                if r and r:IsA("RemoteEvent") then
                    pcall(function() r:FireServer({Source=rp.Position,Slash=true,Damage=GetSmartDamage()},key) end)
                end
            end
        end
    end)
end
local function StopKillAura()
    if State.Connections.KillAura then State.Connections.KillAura:Disconnect(); State.Connections.KillAura=nil end
end

local function StartFreeze()
    if State.Connections.Freeze then State.Connections.Freeze:Disconnect() end
    State.Connections.Freeze=RunService.Heartbeat:Connect(function()
        if not State.FreezeEnabled then return end
        for _,z in ipairs(GetZombies()) do pcall(function() z.hrp.Anchored=true; rawset(z.hum,"WalkSpeed",0) end) end
    end)
end
local function StopFreeze()
    if State.Connections.Freeze then State.Connections.Freeze:Disconnect(); State.Connections.Freeze=nil end
    for _,z in ipairs(GetZombies()) do pcall(function() z.hrp.Anchored=false; rawset(z.hum,"WalkSpeed",12) end) end
end

local function StartAutoFort()
    if State.Connections.AutoFort then State.Connections.AutoFort:Disconnect() end
    local t=0
    State.Connections.AutoFort=RunService.Heartbeat:Connect(function(dt)
        if not State.AutoFortEnabled then return end
        t=t+dt; if t<0.5 then return end; t=0
        local rp=GetRootPart(); if not rp then return end
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local part=obj.Parent
                if part and part:IsA("BasePart") and (part.Position-rp.Position).Magnitude<=State.AutoFortRange then
                    pcall(function() fireproximityprompt(obj) end)
                end
            end
        end
        if keypress then pcall(function() keypress(0x46); keyrelease(0x46) end) end
    end)
end
local function StopAutoFort()
    if State.Connections.AutoFort then State.Connections.AutoFort:Disconnect(); State.Connections.AutoFort=nil end
end

local function FarmPoints()
    local remote,root=FindDamageRemote()
    if not remote then Notify("No Zombies","Need at least 1 alive zombie.",4); return end
    local iters=math.floor(State.PointsAmount/10)
    Notify("Farming...","+"..State.PointsAmount.." pts incoming",3)
    local key=GetDamageKey()
    for i=1,iters do
        pcall(function() remote:FireServer({Source=root.Position,Slash=true,Damage=0},key) end)
        if i%10==0 then task.wait() end
    end
    Notify("Done!","+"..State.PointsAmount.." pts farmed!",5)
end

local espTimer=0
local function EnableESP()
    if State.Connections.ESP then State.Connections.ESP:Disconnect() end
    State.Connections.ESP=RunService.Heartbeat:Connect(function(dt)
        if not State.ESPEnabled then return end
        espTimer=espTimer+dt; if espTimer<0.5 then return end; espTimer=0
        for _,z in ipairs(GetZombies()) do
            if not State.ESPBoxes[z.model] then
                local hl=Instance.new("Highlight")
                hl.Adornee=z.model; hl.OutlineColor=Color3.fromRGB(255,50,50)
                hl.FillColor=Color3.fromRGB(255,50,50); hl.OutlineTransparency=0
                hl.FillTransparency=0.75; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent=z.model; State.ESPBoxes[z.model]=hl
            end
        end
        for model,hl in pairs(State.ESPBoxes) do
            local hum=model and model:FindFirstChildOfClass("Humanoid")
            if not model or not model.Parent or (hum and hum.Health<=0) then
                pcall(function() hl:Destroy() end); State.ESPBoxes[model]=nil
            end
        end
    end)
end
local function DisableESP()
    if State.Connections.ESP then State.Connections.ESP:Disconnect(); State.Connections.ESP=nil end
    for _,hl in pairs(State.ESPBoxes) do pcall(function() hl:Destroy() end) end
    State.ESPBoxes={}
end

local function ApplySpeed(v) local h=GetHumanoid(); if h then pcall(function() rawset(h,"WalkSpeed",v) end) end end
local function ApplyJump(v)  local h=GetHumanoid(); if h then pcall(function() rawset(h,"JumpPower",v) end) end end

local function StartNoclip()
    if State.Connections.Noclip then State.Connections.Noclip:Disconnect() end
    State.Connections.Noclip=RunService.Stepped:Connect(function()
        if not State.NoclipEnabled then return end
        local c=GetCharacter(); if not c then return end
        for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then pcall(function() p.CanCollide=false end) end end
    end)
end
local function StopNoclip()
    if State.Connections.Noclip then State.Connections.Noclip:Disconnect(); State.Connections.Noclip=nil end
end

local function StartFly()
    local root=GetRootPart(); if not root then return end
    local h=GetHumanoid(); if h then h.PlatformStand=true end
    local att=Instance.new("Attachment"); att.Name="PLFlyAtt"; att.Parent=root
    local lv=Instance.new("LinearVelocity")
    lv.Attachment0=att; lv.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector
    lv.MaxForce=1e5; lv.RelativeTo=Enum.ActuatorRelativeTo.World
    lv.VectorVelocity=Vector3.new(0,0,0); lv.Parent=root
    State.FlyBody=lv; State.FlyAtt=att
    local conn; conn=RunService.RenderStepped:Connect(function()
        if not State.FlyEnabled then conn:Disconnect(); return end
        local cam=Workspace.CurrentCamera
        local vel=Vector3.new(0,0,0); local s=State.FlySpeed
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel=vel+cam.CFrame.LookVector*s end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel=vel-cam.CFrame.LookVector*s end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel=vel-cam.CFrame.RightVector*s end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel=vel+cam.CFrame.RightVector*s end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then vel=vel+Vector3.new(0,s,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel=vel-Vector3.new(0,s,0) end
        pcall(function() lv.VectorVelocity=vel end)
    end)
end
local function StopFly()
    State.FlyEnabled=false
    if State.FlyBody and State.FlyBody.Parent then State.FlyBody:Destroy() end
    if State.FlyAtt  and State.FlyAtt.Parent  then State.FlyAtt:Destroy()  end
    State.FlyBody=nil; State.FlyAtt=nil
    local h=GetHumanoid(); if h then h.PlatformStand=false end
end

UserInputService.JumpRequest:Connect(function()
    if not State.InfiniteJump then return end
    local h=GetHumanoid()
    if h then pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end) end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1); char:WaitForChild("Humanoid")
    SetupBackpack()
    if State.SpeedEnabled  then ApplySpeed(State.SpeedValue) end
    if State.JumpEnabled   then ApplyJump(State.JumpValue)   end
    if State.NoclipEnabled then StartNoclip()                end
end)
SetupBackpack()

-- ════════════════════════════════════════
--  PROTECTION
-- ════════════════════════════════════════
pcall(function()
    if type(hookfunction)=="function" and type(newcclosure)=="function" then
        local _g=gcinfo()
        hookfunction(gcinfo,newcclosure(function() return _g end))
    end
end)

RunService.Heartbeat:Connect(function()
    local h=GetHumanoid(); if not h then return end
    local isAiming=false; local char=GetCharacter()
    if char then
        local tool=char:FindFirstChildOfClass("Tool")
        if tool then
            local cam=Workspace.CurrentCamera
            if cam and cam.CameraType==Enum.CameraType.Scriptable then isAiming=true end
        end
    end
    if isAiming then rawset(h,"WalkSpeed",16)
    elseif State.SpeedEnabled then rawset(h,"WalkSpeed",State.SpeedValue) end
    if State.JumpEnabled then rawset(h,"JumpPower",State.JumpValue) end
end)

-- ════════════════════════════════════════
--  BUILD TABS
-- ════════════════════════════════════════
local MT=NewTab("Main")
MkSection(MT,"Credits")
MkParagraph(MT,"PL Zombies Hub v5","by darkyscript")
MkParagraph(MT,"Game","Project Lazarus: Zombies  |  ID: 443406476")
MkParagraph(MT,"Controls","Left Alt = show/hide   ×  = close")

local LT=NewTab("PL Zombies")
MkSection(LT,"Gun Mods")
MkToggle(LT,"Infinite Ammo",          function(v) State.InfAmmoEnabled=v end)
MkToggle(LT,"Insta Kill [Protected]", function(v)
    State.InstaKillEnabled=v
    if v then Notify("Insta Kill ON","Round "..(RoundNum.Value or 1).." → "..GetSmartDamage().." DMG") end
end)
MkToggle(LT,"No Recoil", function(v) State.NoRecoilEnabled=v end)
MkToggle(LT,"No Spread", function(v) State.NoSpreadEnabled=v end)
MkSection(LT,"Kill Aura")
MkToggle(LT,"Kill Aura", function(v) State.KillAuraEnabled=v; if v then StartKillAura() else StopKillAura() end end)
MkSlider(LT,"Aura Range",10,250,40," studs",function(v) State.KillAuraRange=v end)
MkSection(LT,"Utility")
MkToggle(LT,"Freeze Zombies", function(v) State.FreezeEnabled=v; if v then StartFreeze() else StopFreeze() end end)
MkToggle(LT,"Auto Fortify",   function(v) State.AutoFortEnabled=v; if v then StartAutoFort() else StopAutoFort() end end)
MkSlider(LT,"Fortify Range",5,60,20," studs",function(v) State.AutoFortRange=v end)
MkSection(LT,"Visuals")
MkToggle(LT,"Zombie ESP", function(v) State.ESPEnabled=v; if v then EnableESP() else DisableESP() end end)
MkSection(LT,"Points Farm")
MkSlider(LT,"Points Amount",10,1000000,1000," pts",function(v) State.PointsAmount=v end)
MkButton(LT,"Farm Points Now",function() task.spawn(FarmPoints) end)

local PT=NewTab("Player")
MkSection(PT,"Movement")
MkToggle(PT,"Speed Hack", function(v) State.SpeedEnabled=v; ApplySpeed(v and State.SpeedValue or 16) end)
MkSlider(PT,"Walk Speed",16,250,16," stud/s",function(v) State.SpeedValue=v; if State.SpeedEnabled then ApplySpeed(v) end end)
MkToggle(PT,"Jump Hack", function(v) State.JumpEnabled=v; ApplyJump(v and State.JumpValue or 50) end)
MkSlider(PT,"Jump Power",50,500,50,"",function(v) State.JumpValue=v; if State.JumpEnabled then ApplyJump(v) end end)
MkToggle(PT,"Infinite Jump", function(v) State.InfiniteJump=v end)
MkSection(PT,"Utility")
MkToggle(PT,"Noclip", function(v) State.NoclipEnabled=v; if v then StartNoclip() else StopNoclip() end end)
MkToggle(PT,"Fly  [WASD+Space/Ctrl]", function(v) State.FlyEnabled=v; if v then StartFly() else StopFly() end end)
MkSlider(PT,"Fly Speed",10,200,50," stud/s",function(v) State.FlySpeed=v end)
MkButton(PT,"Reset Stats",function()
    local h=GetHumanoid()
    if h then pcall(function() rawset(h,"WalkSpeed",16); rawset(h,"JumpPower",50) end) end
    State.SpeedEnabled=false; State.JumpEnabled=false
end)

SelectTab("Main")
Notify("PL Hub v5 Ready","Left Alt = show/hide",4)
