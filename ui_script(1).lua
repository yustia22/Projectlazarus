--[[
    PROJECT LAZARUS : ZOMBIES HUB  v5
    Pure Roblox GUI — works on every executor
]]

--// ══════════════════════════════════════
--//  GUARD: run once per session
--// ══════════════════════════════════════
if getgenv().PLHubLoaded then return end
getgenv().PLHubLoaded = true

--// ══════════════════════════════════════
--//  SERVICES
--// ══════════════════════════════════════
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local Workspace        = game:GetService("Workspace")
local CoreGui          = game:GetService("CoreGui")
local LocalPlayer      = Players.LocalPlayer

local function GetCharacter() return LocalPlayer.Character end
local function GetHumanoid()  local c=GetCharacter(); return c and c:FindFirstChildOfClass("Humanoid") end
local function GetRootPart()  local c=GetCharacter(); return c and c:FindFirstChild("HumanoidRootPart") end


--// ══════════════════════════════════════
--//  LOAD LIBRARY
--// ══════════════════════════════════════
--// ══════════════════════════════════════
--//  PURE ROBLOX GUI  (no external library)
--//  Works on every executor — zero HTTP
--// ══════════════════════════════════════

-- Tiny notification helper (top-right corner, auto-fades)
local function Notify(title, desc, duration)
    duration = duration or 4
    pcall(function()
        local sg = Instance.new("ScreenGui")
        sg.Name = "PLNotif"; sg.ResetOnSpawn = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        pcall(function() sg.Parent = CoreGui end)

        local frame = Instance.new("Frame", sg)
        frame.Size = UDim2.new(0,280,0,64)
        frame.Position = UDim2.new(1,-296,0,12)
        frame.BackgroundColor3 = Color3.fromRGB(22,22,28)
        frame.BorderSizePixel = 0
        Instance.new("UICorner",frame).CornerRadius = UDim.new(0,8)

        local accent = Instance.new("Frame", frame)
        accent.Size = UDim2.new(0,4,1,0)
        accent.BackgroundColor3 = Color3.fromRGB(200,50,50)
        accent.BorderSizePixel = 0
        Instance.new("UICorner",accent).CornerRadius = UDim.new(0,4)

        local t = Instance.new("TextLabel", frame)
        t.Size = UDim2.new(1,-14,0,22)
        t.Position = UDim2.new(0,10,0,6)
        t.BackgroundTransparency = 1
        t.TextColor3 = Color3.fromRGB(240,240,240)
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Font = Enum.Font.GothamBold
        t.TextSize = 13
        t.Text = title

        local d = Instance.new("TextLabel", frame)
        d.Size = UDim2.new(1,-14,0,20)
        d.Position = UDim2.new(0,10,0,30)
        d.BackgroundTransparency = 1
        d.TextColor3 = Color3.fromRGB(180,180,180)
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.Font = Enum.Font.Gotham
        d.TextSize = 11
        d.TextWrapped = true
        d.Text = desc

        task.delay(duration, function()
            if sg and sg.Parent then sg:Destroy() end
        end)
    end)
end






--// ══════════════════════════════════════
--//  STATE
--// ══════════════════════════════════════
local State = {
    InfAmmoEnabled   = false,
    InstaKillEnabled = false,
    NoRecoilEnabled  = false,
    NoSpreadEnabled  = false,
    KillAuraEnabled  = false,
    KillAuraRange    = 40,
    KillAuraLoop     = nil,
    ESPEnabled       = false,
    ESPBoxes         = {},
    ESPConn          = nil,
    FreezeEnabled    = false,
    FreezeMovers     = {},
    FreezeConn       = nil,
    AutoFortEnabled  = false,
    AutoFortLoop     = nil,
    AutoFortRange    = 20,
    SpeedEnabled     = false,
    SpeedValue       = 16,
    JumpEnabled      = false,
    JumpValue        = 50,
    InfiniteJump     = false,
    NoclipEnabled    = false,
    NoclipConn       = nil,
    FlyEnabled       = false,
    FlyBody          = nil,
    FlyAtt           = nil,
    FlySpeed         = 50,
    Connections      = { Weapon1=nil, Weapon2=nil, Weapon3=nil, Backpack=nil },
    damage_key       = nil,
    PointsAmount     = 1000,
    QRConn           = nil,
}

--// ══════════════════════════════════════
--//  DEEP COPY + GUN BACKUP
--// ══════════════════════════════════════
local GunBackups = {}
local function deepcopy(obj, seen)
    seen = seen or {}
    if type(obj) ~= "table" then return obj end
    if seen[obj] then return seen[obj] end
    local copy = {}; seen[obj] = copy
    for k,v in next,obj do copy[deepcopy(k,seen)] = deepcopy(v,seen) end
    setmetatable(copy, deepcopy(getmetatable(obj), seen))
    return copy
end
local function BackupGun(m)
    if not rawget(GunBackups,m) then rawset(GunBackups,m,deepcopy(m)) end
    return rawget(GunBackups,m)
end
local function RestoreGun(m)
    local b = rawget(GunBackups,m); if not b then return end
    for k,v in next,b do pcall(rawset,m,k,v) end
end

--// ══════════════════════════════════════
--//  DAMAGE KEY
--// ══════════════════════════════════════
local function GetDamageKey()
    -- Wrap all executor-specific functions so script works on any executor.
    -- If getgc/getinfo/getupvalues are unavailable, fall back to cached key.
    local hasGC  = type(getgc)         == "function"
    local hasGI  = type(getinfo)       == "function"
    local hasGU  = type(getupvalues)   == "function"
    if hasGC and hasGI and hasGU then
        local ok, gc = pcall(getgc)
        if ok and gc then
            for _,fn in next,gc do
                if type(fn)=="function" then
                    local ok2,info = pcall(getinfo,fn)
                    if ok2 and info and info.name=="Knife" then
                        local ok3,ups = pcall(getupvalues,fn)
                        if ok3 and ups then
                            for _,val in next,ups do
                                if type(val)=="number" then
                                    State.damage_key = val
                                    return val
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
task.spawn(function()
    while task.wait(2) do pcall(GetDamageKey) end
end)

--// ══════════════════════════════════════
--//  SMART DAMAGE
--// ══════════════════════════════════════
local function GetSmartDamage()
    local r = math.max(1, RoundNum.Value or 1)
    local hp = r < 10 and (50 + 100*r) or (950 * (1.1 ^ (r-9)))
    return math.ceil(hp * 1.10)
end

--// ══════════════════════════════════════
--//  GUN MODULE PATCHERS (rawset only)
--// ══════════════════════════════════════
local ZERO = { Min=0, Max=0 }

local function PatchAmmo(m)
    BackupGun(m)
    -- Set to 99 so HUD shows 99/99 — looks like a full mag, not hacked
    -- We patch every frame so when game decrements it after a shot,
    -- next frame it's back to 99 before the HUD updates again
    local isAmmo = { ammo=true, storedammo=true, maxammo=true,
        magsize=true, bulletcount=true, clipsize=true,
        magazinesize=true, reserveammo=true }
    for k in next, m do
        if type(k) == "string" and isAmmo[k:lower()] then
            rawset(m, k, 99)
        end
    end
end

local function PatchDamage(m)
    BackupGun(m)
    local dmg = GetSmartDamage()
    for k,v in next,m do
        if type(k)=="string" then
            local kl = k:lower()
            if kl:find("headshot") or kl:find("torsoshot") or kl:find("limbshot") then
                rawset(m,k,dmg)
            elseif kl=="damage" and type(v)=="table" then
                rawset(m,k,{Max=dmg, Min=math.floor(dmg*0.95)})
            elseif kl:find("penetration") then
                rawset(m,k,math.min(dmg,500))
            end
        end
    end
end

local function ZeroTable(t)
    -- Recursively zero all numeric values in a table
    if type(t) ~= "table" then return end
    for k, v in next, t do
        if type(v) == "number" then
            rawset(t, k, 0)
        elseif type(v) == "table" then
            ZeroTable(v)
        end
    end
end

local function PatchRecoil(m)
    BackupGun(m)
    for k, v in next, m do
        if type(k) == "string" then
            local kl = k:lower()
            if kl:find("viewkick") or kl:find("recoil") or kl:find("kick") or kl:find("sway") then
                if type(v) == "table" then
                    ZeroTable(v)
                else
                    rawset(m, k, 0)
                end
            end
        end
    end
end

local function PatchSpread(m)
    BackupGun(m)
    for k, v in next, m do
        if type(k) == "string" then
            local kl = k:lower()
            if kl:find("spread") or kl:find("bloom") or kl:find("accuracy") then
                if type(v) == "table" then
                    rawset(v, "Min", 0)
                    rawset(v, "Max", 0)
                    ZeroTable(v)
                else
                    rawset(m, k, 0)
                end
            end
        end
    end
end

local function RunPatch(m)
    if State.InfAmmoEnabled   then pcall(PatchAmmo,   m) end
    if State.InstaKillEnabled then pcall(PatchDamage, m) end
    if State.NoRecoilEnabled  then pcall(PatchRecoil, m) end
    if State.NoSpreadEnabled  then pcall(PatchSpread, m) end
    if not (State.InfAmmoEnabled or State.InstaKillEnabled or
            State.NoRecoilEnabled or
            State.NoSpreadEnabled) then
        pcall(RestoreGun, m)
    end
end

--// ══════════════════════════════════════
--//  WEAPON ATTACHMENT
--// ══════════════════════════════════════
local function AttachWeapon(child)
    local slot = child.Name
    if slot~="Weapon1" and slot~="Weapon2" and slot~="Weapon3" then return end
    if State.Connections[slot] then
        State.Connections[slot]:Disconnect()
        State.Connections[slot] = nil
    end
    local ok,m = pcall(require,child)
    if not ok or type(m)~="table" then return end
    State.Connections[slot] = RunService.RenderStepped:Connect(function()
        pcall(RunPatch,m)
    end)
end

local function SetupBackpack()
    local bp = LocalPlayer:WaitForChild("Backpack",10)
    if not bp then return end
    for _,c in ipairs(bp:GetChildren()) do pcall(AttachWeapon,c) end
    local char = GetCharacter()
    if char then for _,c in ipairs(char:GetChildren()) do pcall(AttachWeapon,c) end end
    if State.Connections.Backpack then State.Connections.Backpack:Disconnect() end
    State.Connections.Backpack = bp.ChildAdded:Connect(function(c) pcall(AttachWeapon,c) end)
end

--// ══════════════════════════════════════
--//  ZOMBIE HELPERS
--//  Deep scan — works regardless of what
--//  folder PL uses. Scans all Humanoids
--//  in entire Workspace:GetDescendants()
--// ══════════════════════════════════════
local function GetZombies()
    local zombies = {}
    local playerChars = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then playerChars[p.Character] = true end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Health > 0 then
            local model = obj.Parent
            if model and model:IsA("Model") and not playerChars[model] then
                table.insert(zombies, { model = model, hum = obj })
            end
        end
    end
    return zombies
end

--// ══════════════════════════════════════
--//  GET POINTS (no kill needed)
--//  Fire Humanoid.Damage with Damage=0
--//  Each fire = +10pts. No kill needed.
--// ══════════════════════════════════════
local function FindDamageRemote()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Health > 0 then
            local isPlayer = false
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChildOfClass("Humanoid") == obj then
                    isPlayer = true; break
                end
            end
            if not isPlayer then
                local remote = obj:FindFirstChild("Damage")
                if remote and remote:IsA("RemoteEvent") then
                    local model = obj.Parent
                    local root = model and (
                        model:FindFirstChild("HumanoidRootPart") or
                        model:FindFirstChild("Torso") or
                        model:FindFirstChild("Head")
                    )
                    if root then return remote, root end
                end
            end
        end
    end
    return nil, nil
end

local function GetPoints(amount)
    amount = amount or 1000
    local remote, root = FindDamageRemote()
    if not remote then
        Notify("No Damage Remote", "No alive zombies with Damage remote found.", 5)
        return
    end
    local key = GetDamageKey()
    local iters = math.floor(amount / 10)
    Notify("Farming Points...", "Firing ", 3)
    for i = 1, iters do
        pcall(function()
            remote:FireServer({ Source=root.Position, Slash=true, Damage=0 }, key)
        end)
        if i % 10 == 0 then task.wait() end
    end
    Notify("Done!", "+", 5)
end

--// ══════════════════════════════════════
--//  KILL AURA
--//  Uses deep scan so remote is always
--//  found even on freshly spawned zombies
--// ══════════════════════════════════════
local KillAuraTimer = 0
local KILL_AURA_RATE = 0.15

local function StartKillAura()
    if State.KillAuraLoop then return end
    KillAuraTimer = 0
    State.KillAuraLoop = RunService.Heartbeat:Connect(function(dt)
        KillAuraTimer = KillAuraTimer + dt
        if KillAuraTimer < KILL_AURA_RATE then return end
        KillAuraTimer = 0
        local rp = GetRootPart()
        if not rp then return end
        for _, z in ipairs(GetZombies()) do
            local zr = z.model:FindFirstChild("HumanoidRootPart") or z.model:FindFirstChild("Torso")
            if zr and (rp.Position - zr.Position).Magnitude <= State.KillAuraRange then
                pcall(function()
                    local remote = z.hum:FindFirstChild("Damage")
                    if remote and remote:IsA("RemoteEvent") then
                        remote:FireServer({
                            Source = zr.Position,
                            Slash  = true,
                            Damage = GetSmartDamage(),
                        }, GetDamageKey())
                    end
                end)
            end
        end
    end)
end
local function StopKillAura()
    if State.KillAuraLoop then State.KillAuraLoop:Disconnect(); State.KillAuraLoop = nil end
    KillAuraTimer = 0
end

--// ══════════════════════════════════════
--//  FREEZE
--//  ApplySlowdown remote doesn't exist in
--//  current PL. Working method:
--//  Anchor HRP + rawset WalkSpeed=0 every
--//  frame so zombies are truly stuck.
--// ══════════════════════════════════════
local function StartFreeze()
    State.FreezeEnabled = true
    if State.FreezeConn then State.FreezeConn:Disconnect() end
    State.FreezeConn = RunService.Heartbeat:Connect(function()
        if not State.FreezeEnabled then return end
        for _, z in ipairs(GetZombies()) do
            pcall(function()
                local zr = z.model:FindFirstChild("HumanoidRootPart")
                if zr then
                    zr.Anchored = true
                    State.FreezeMovers[z.model] = zr
                end
                rawset(z.hum, "WalkSpeed", 0)
            end)
        end
    end)
end
local function StopFreeze()
    State.FreezeEnabled = false
    if State.FreezeConn then State.FreezeConn:Disconnect(); State.FreezeConn = nil end
    for model, zr in pairs(State.FreezeMovers) do
        pcall(function()
            zr.Anchored = false
            local hum = model:FindFirstChildOfClass("Humanoid")
            if hum then rawset(hum, "WalkSpeed", 12) end
        end)
        State.FreezeMovers[model] = nil
    end
end


--// ══════════════════════════════════════
--//  ESP (through-wall via Highlight)
--//  Parent to model (not CoreGui) so it
--//  moves with zombie automatically.
--//  AlwaysOnTop = visible through walls.
--// ══════════════════════════════════════
local ESPTimer = 0
local ESP_RATE  = 0.5

local function EnableESP()
    State.ESPEnabled = true
    ESPTimer = 999
    State.ESPConn = RunService.Heartbeat:Connect(function(dt)
        if not State.ESPEnabled then return end
        ESPTimer = ESPTimer + dt
        if ESPTimer < ESP_RATE then return end
        ESPTimer = 0
        for _, z in ipairs(GetZombies()) do
            if not State.ESPBoxes[z.model] then
                local hl = Instance.new("Highlight")
                hl.Adornee             = z.model
                hl.OutlineColor        = Color3.fromRGB(255, 50, 50)
                hl.FillColor           = Color3.fromRGB(255, 50, 50)
                hl.OutlineTransparency = 0
                hl.FillTransparency    = 0.75
                hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Enabled             = true
                hl.Parent              = z.model
                State.ESPBoxes[z.model] = hl
            end
        end
        for model, hl in pairs(State.ESPBoxes) do
            local hum = model and model:FindFirstChildOfClass("Humanoid")
            if not model or not model.Parent or (hum and hum.Health <= 0) then
                pcall(function() hl:Destroy() end)
                State.ESPBoxes[model] = nil
            end
        end
    end)
end
local function DisableESP()
    State.ESPEnabled = false
    if State.ESPConn then State.ESPConn:Disconnect(); State.ESPConn = nil end
    ESPTimer = 0
    for m, hl in pairs(State.ESPBoxes) do
        pcall(function() hl:Destroy() end)
        State.ESPBoxes[m] = nil
    end
end


--// ══════════════════════════════════════
--//  AUTO FORTIFY
--// ══════════════════════════════════════
local function TryFortify()
    local rp=GetRootPart(); if not rp then return end
    for _,pp in ipairs(Workspace:GetDescendants()) do
        if pp:IsA("ProximityPrompt") then
            pcall(function()
                local pos = pp.Parent:IsA("BasePart") and pp.Parent.Position
                if pos and (rp.Position-pos).Magnitude<=State.AutoFortRange then
                    fireproximityprompt(pp)
                end
            end)
        end
    end
    pcall(function() keypress(0x46); task.wait(0.05); keyrelease(0x46) end)
end
local function StartAutoFort()
    if State.AutoFortLoop then return end
    State.AutoFortLoop = RunService.Heartbeat:Connect(TryFortify)
end
local function StopAutoFort()
    if State.AutoFortLoop then State.AutoFortLoop:Disconnect(); State.AutoFortLoop=nil end
end

--// ══════════════════════════════════════
--//  MOVEMENT
--// ══════════════════════════════════════
local function ApplySpeed(v) local h=GetHumanoid(); if h then h.WalkSpeed=v end end
local function ApplyJump(v)  local h=GetHumanoid(); if h then h.JumpPower=v  end end

local function StartNoclip()
    if State.NoclipConn then return end
    State.NoclipConn = RunService.Stepped:Connect(function()
        local c=GetCharacter(); if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    end)
end
local function StopNoclip()
    if State.NoclipConn then State.NoclipConn:Disconnect(); State.NoclipConn=nil end
    local c=GetCharacter()
    if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end
end

local function StartFly()
    local root=GetRootPart(); if not root then return end
    State.FlyEnabled=true
    local h=GetHumanoid(); if h then h.PlatformStand=true end
    local att=Instance.new("Attachment")
    att.Name="FlyAtt"
    att.Parent=root
    local lv=Instance.new("LinearVelocity")
    lv.Attachment0=att
    lv.VelocityConstraintMode=Enum.VelocityConstraintMode.Vector
    lv.MaxForce=1e5
    lv.RelativeTo=Enum.ActuatorRelativeTo.World
    lv.VectorVelocity=Vector3.new(0,0,0)
    lv.Parent=root
    State.FlyBody=lv; State.FlyAtt=att
    local conn; conn=RunService.RenderStepped:Connect(function()
        if not State.FlyEnabled then conn:Disconnect(); return end
        local cam=Workspace.CurrentCamera
        local vel=Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W)           then vel=vel+cam.CFrame.LookVector  *State.FlySpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.S)           then vel=vel-cam.CFrame.LookVector  *State.FlySpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.A)           then vel=vel-cam.CFrame.RightVector *State.FlySpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.D)           then vel=vel+cam.CFrame.RightVector *State.FlySpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then vel=vel+Vector3.new(0,State.FlySpeed,0)        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel=vel-Vector3.new(0,State.FlySpeed,0)        end
        lv.VectorVelocity=vel
    end)
end
local function StopFly()
    State.FlyEnabled=false
    if State.FlyBody and State.FlyBody.Parent then State.FlyBody:Destroy() end
    if State.FlyAtt  and State.FlyAtt.Parent  then State.FlyAtt:Destroy()  end
    State.FlyBody=nil; State.FlyAtt=nil
    local h=GetHumanoid(); if h then h.PlatformStand=false end
end

--// ══════════════════════════════════════
--//  RESPAWN HANDLER + SETUP
--// ══════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.5)
    SetupBackpack()
    if State.SpeedEnabled  then ApplySpeed(State.SpeedValue) end
    if State.JumpEnabled   then ApplyJump(State.JumpValue)   end
    if State.NoclipEnabled then StartNoclip()                end
end)
SetupBackpack()




--// ══════════════════════════════════════
--//  GUI CONSTRUCTION
--//  Pure ScreenGui — no external lib needed
--// ══════════════════════════════════════

-- Destroy old instance if re-executing
local oldGui = CoreGui:FindFirstChild("PLZombiesHub")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PLZombiesHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = CoreGui end)

-- ── COLOURS ──────────────────────────────
local COL_BG     = Color3.fromRGB(18,18,23)
local COL_SIDE   = Color3.fromRGB(24,24,30)
local COL_PANEL  = Color3.fromRGB(28,28,36)
local COL_ITEM   = Color3.fromRGB(34,34,44)
local COL_ACCENT = Color3.fromRGB(200,50,50)
local COL_TEXT   = Color3.fromRGB(235,235,235)
local COL_SUB    = Color3.fromRGB(160,160,170)
local COL_ON     = Color3.fromRGB(80,200,100)
local COL_OFF    = Color3.fromRGB(90,90,100)

-- ── HELPERS ──────────────────────────────
local function corner(parent, r)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, r or 6)
    return c
end
local function padding(parent, px)
    local p = Instance.new("UIPadding", parent)
    p.PaddingLeft   = UDim.new(0, px)
    p.PaddingRight  = UDim.new(0, px)
    p.PaddingTop    = UDim.new(0, px)
    p.PaddingBottom = UDim.new(0, px)
end
local function label(parent, text, size, col, bold, xalign)
    local l = Instance.new("TextLabel", parent)
    l.BackgroundTransparency = 1
    l.TextColor3 = col or COL_TEXT
    l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextSize = size or 13
    l.Text = text
    l.TextXAlignment = xalign or Enum.TextXAlignment.Left
    l.TextWrapped = true
    return l
end

-- ── MAIN WINDOW ──────────────────────────
local Win = Instance.new("Frame", ScreenGui)
Win.Name = "Window"
Win.Size = UDim2.new(0, 560, 0, 400)
Win.Position = UDim2.new(0.5, -280, 0.5, -200)
Win.BackgroundColor3 = COL_BG
Win.BorderSizePixel = 0
Win.Active = true
Win.Draggable = true
corner(Win, 10)

-- Drop shadow
local shadow = Instance.new("ImageLabel", Win)
shadow.Size = UDim2.new(1,30,1,30)
shadow.Position = UDim2.new(0,-15,0,-15)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5028857084"
shadow.ImageColor3 = Color3.fromRGB(0,0,0)
shadow.ImageTransparency = 0.55
shadow.ZIndex = 0
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(24,24,276,276)

-- Title bar
local TitleBar = Instance.new("Frame", Win)
TitleBar.Size = UDim2.new(1,0,0,38)
TitleBar.BackgroundColor3 = COL_SIDE
TitleBar.BorderSizePixel = 0
corner(TitleBar, 10)
-- square off bottom corners
local sq = Instance.new("Frame", TitleBar)
sq.Size = UDim2.new(1,0,0.5,0)
sq.Position = UDim2.new(0,0,0.5,0)
sq.BackgroundColor3 = COL_SIDE
sq.BorderSizePixel = 0

local titleL = label(TitleBar, "PL Zombies Hub  v5", 14, COL_TEXT, true)
titleL.Size = UDim2.new(1,-80,1,0)
titleL.Position = UDim2.new(0,14,0,0)

-- Version badge
local badge = Instance.new("TextLabel", TitleBar)
badge.Size = UDim2.new(0,60,0,20)
badge.Position = UDim2.new(1,-74,0.5,-10)
badge.BackgroundColor3 = COL_ACCENT
badge.TextColor3 = COL_TEXT
badge.Font = Enum.Font.GothamBold
badge.TextSize = 10
badge.Text = "ACTIVE"
badge.BorderSizePixel = 0
corner(badge, 4)

-- Close button
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0,26,0,26)
CloseBtn.Position = UDim2.new(1,-32,0.5,-13)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180,50,50)
CloseBtn.TextColor3 = COL_TEXT
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Text = "×"
CloseBtn.BorderSizePixel = 0
corner(CloseBtn, 5)
CloseBtn.MouseButton1Click:Connect(function()
    Win.Visible = not Win.Visible
end)

-- Minimize keybind (Left Alt)
UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.LeftAlt then
        Win.Visible = not Win.Visible
    end
end)

-- ── SIDEBAR (tabs) ────────────────────────
local Sidebar = Instance.new("Frame", Win)
Sidebar.Size = UDim2.new(0,120,1,-38)
Sidebar.Position = UDim2.new(0,0,0,38)
Sidebar.BackgroundColor3 = COL_SIDE
Sidebar.BorderSizePixel = 0
corner(Sidebar, 10)
local sideSqTop = Instance.new("Frame", Sidebar)
sideSqTop.Size = UDim2.new(1,0,0,10)
sideSqTop.BackgroundColor3 = COL_SIDE
sideSqTop.BorderSizePixel = 0
local sideSqRight = Instance.new("Frame", Sidebar)
sideSqRight.Size = UDim2.new(0,10,1,0)
sideSqRight.Position = UDim2.new(1,-10,0,0)
sideSqRight.BackgroundColor3 = COL_SIDE
sideSqRight.BorderSizePixel = 0

local TabList = Instance.new("Frame", Sidebar)
TabList.Size = UDim2.new(1,0,1,-10)
TabList.Position = UDim2.new(0,0,0,10)
TabList.BackgroundTransparency = 1
local tabLayout = Instance.new("UIListLayout", TabList)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0,2)

-- ── CONTENT AREA ─────────────────────────
local Content = Instance.new("Frame", Win)
Content.Size = UDim2.new(1,-126,1,-44)
Content.Position = UDim2.new(0,123,0,41)
Content.BackgroundColor3 = COL_PANEL
Content.BorderSizePixel = 0
corner(Content, 8)

-- ── TAB / TOGGLE / SLIDER BUILDERS ───────
local AllTabs = {}
local ActiveTab = nil

local function MakeTab(name)
    -- Sidebar button
    local btn = Instance.new("TextButton", TabList)
    btn.Size = UDim2.new(1,-8,0,32)
    btn.Position = UDim2.new(0,4,0,0)
    btn.BackgroundColor3 = COL_ITEM
    btn.TextColor3 = COL_SUB
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Text = name
    btn.BorderSizePixel = 0
    corner(btn, 5)
    local accent_bar = Instance.new("Frame", btn)
    accent_bar.Size = UDim2.new(0,3,0.6,0)
    accent_bar.Position = UDim2.new(0,0,0.2,0)
    accent_bar.BackgroundColor3 = COL_ACCENT
    accent_bar.BorderSizePixel = 0
    accent_bar.Visible = false
    corner(accent_bar, 2)

    -- Scroll frame for content
    local scroll = Instance.new("ScrollingFrame", Content)
    scroll.Size = UDim2.new(1,0,1,0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = COL_ACCENT
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.Visible = false
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local layout = Instance.new("UIListLayout", scroll)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,4)
    padding(scroll, 8)

    local tab = { btn=btn, scroll=scroll, bar=accent_bar, order=0 }

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(AllTabs) do
            t.scroll.Visible = false
            t.btn.TextColor3 = COL_SUB
            t.btn.BackgroundColor3 = COL_ITEM
            t.bar.Visible = false
        end
        scroll.Visible = true
        btn.TextColor3 = COL_TEXT
        btn.BackgroundColor3 = Color3.fromRGB(40,40,52)
        accent_bar.Visible = true
        ActiveTab = tab
    end)

    AllTabs[name] = tab
    return tab
end

local function MakeSection(tab, name)
    tab.order = tab.order + 1
    local f = Instance.new("Frame", tab.scroll)
    f.Size = UDim2.new(1,-4,0,24)
    f.BackgroundTransparency = 1
    f.LayoutOrder = tab.order
    local l = label(f, "— "..name, 11, COL_ACCENT, true)
    l.Size = UDim2.new(1,0,1,0)
    l.Position = UDim2.new(0,0,0,0)
end

local function MakeItem(tab, height)
    tab.order = tab.order + 1
    local f = Instance.new("Frame", tab.scroll)
    f.Size = UDim2.new(1,-4, 0, height or 36)
    f.BackgroundColor3 = COL_ITEM
    f.BorderSizePixel = 0
    f.LayoutOrder = tab.order
    corner(f, 6)
    return f
end

local function MakeToggle(tab, name, desc, callback)
    local f = MakeItem(tab, desc and 44 or 36)
    local n = label(f, name, 12, COL_TEXT, true)
    n.Size = UDim2.new(1,-52,0,18)
    n.Position = UDim2.new(0,10,0,desc and 6 or 9)
    if desc then
        local d = label(f, desc, 10, COL_SUB)
        d.Size = UDim2.new(1,-52,0,14)
        d.Position = UDim2.new(0,10,0,24)
    end
    -- Toggle pill
    local pill = Instance.new("Frame", f)
    pill.Size = UDim2.new(0,38,0,20)
    pill.Position = UDim2.new(1,-48,0.5,-10)
    pill.BackgroundColor3 = COL_OFF
    pill.BorderSizePixel = 0
    corner(pill, 10)
    local knob = Instance.new("Frame", pill)
    knob.Size = UDim2.new(0,16,0,16)
    knob.Position = UDim2.new(0,2,0.5,-8)
    knob.BackgroundColor3 = Color3.fromRGB(220,220,220)
    knob.BorderSizePixel = 0
    corner(knob, 8)

    local state = false
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            pill.BackgroundColor3 = COL_ON
            knob.Position = UDim2.new(1,-18,0.5,-8)
        else
            pill.BackgroundColor3 = COL_OFF
            knob.Position = UDim2.new(0,2,0.5,-8)
        end
        pcall(callback, state)
    end)
    return { SetValue = function(v)
        state = v
        if v then pill.BackgroundColor3=COL_ON; knob.Position=UDim2.new(1,-18,0.5,-8)
        else pill.BackgroundColor3=COL_OFF; knob.Position=UDim2.new(0,2,0.5,-8) end
    end }
end

local function MakeSlider(tab, name, min, max, default, suffix, callback)
    local f = MakeItem(tab, 52)
    local topL = label(f, name, 12, COL_TEXT, true)
    topL.Size = UDim2.new(0.7,0,0,18)
    topL.Position = UDim2.new(0,10,0,6)
    local valL = label(f, tostring(default)..(suffix or ""), 12, COL_ACCENT, true, Enum.TextXAlignment.Right)
    valL.Size = UDim2.new(0.28,0,0,18)
    valL.Position = UDim2.new(0.72,-10,0,6)

    local track = Instance.new("Frame", f)
    track.Size = UDim2.new(1,-20,0,6)
    track.Position = UDim2.new(0,10,0,32)
    track.BackgroundColor3 = Color3.fromRGB(50,50,62)
    track.BorderSizePixel = 0
    corner(track, 3)
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = COL_ACCENT
    fill.BorderSizePixel = 0
    corner(fill, 3)
    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0,12,0,12)
    knob.AnchorPoint = Vector2.new(0.5,0.5)
    knob.Position = UDim2.new((default-min)/(max-min),0,0.5,0)
    knob.BackgroundColor3 = Color3.fromRGB(230,230,230)
    knob.BorderSizePixel = 0
    corner(knob, 6)

    local dragging = false
    local function update(x)
        local abs = track.AbsolutePosition.X
        local w   = track.AbsoluteSize.X
        local pct = math.clamp((x - abs) / w, 0, 1)
        local val = math.floor(min + (max-min)*pct)
        fill.Size = UDim2.new(pct,0,1,0)
        knob.Position = UDim2.new(pct,0,0.5,0)
        valL.Text = tostring(val)..(suffix or "")
        pcall(callback, val)
    end

    local ib = Instance.new("TextButton", track)
    ib.Size = UDim2.new(1,0,3,0)
    ib.Position = UDim2.new(0,0,-1,0)
    ib.BackgroundTransparency = 1
    ib.Text = ""
    ib.MouseButton1Down:Connect(function() dragging=true end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            update(inp.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end
    end)
    ib.MouseButton1Click:Connect(function()
        local mouse = UserInputService:GetMouseLocation()
        update(mouse.X)
    end)
end

local function MakeButton(tab, name, desc, callback)
    local f = MakeItem(tab, 36)
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    local n = label(f, name, 12, COL_TEXT, true)
    n.Size = UDim2.new(1,-20,1,0)
    n.Position = UDim2.new(0,10,0,0)
    n.TextXAlignment = Enum.TextXAlignment.Left
    local arr = label(f, "›", 16, COL_ACCENT, true, Enum.TextXAlignment.Right)
    arr.Size = UDim2.new(0,20,1,0)
    arr.Position = UDim2.new(1,-24,0,0)
    btn.MouseButton1Click:Connect(function() pcall(callback) end)
    btn.MouseEnter:Connect(function() f.BackgroundColor3 = Color3.fromRGB(44,44,56) end)
    btn.MouseLeave:Connect(function() f.BackgroundColor3 = COL_ITEM end)
end

local function MakeParagraph(tab, title, content)
    local lines = math.ceil(#content / 55) + 1
    local h = 28 + lines * 14
    local f = MakeItem(tab, h)
    f.BackgroundColor3 = Color3.fromRGB(26,26,34)
    local t = label(f, title, 12, COL_TEXT, true)
    t.Size = UDim2.new(1,-16,0,18)
    t.Position = UDim2.new(0,8,0,6)
    local d = label(f, content, 11, COL_SUB)
    d.Size = UDim2.new(1,-16,0,lines*14)
    d.Position = UDim2.new(0,8,0,22)
end

-- ── BUILD TABS ────────────────────────────

-- MAIN
local MT = MakeTab("Main")
MakeSection(MT, "Credits")
MakeParagraph(MT, "PL Zombies Hub v5", "Script by darkyscript")
MakeParagraph(MT, "Game", "Project Lazarus: Zombies
Game ID: 443406476 | Dev: Logitech101")
MakeParagraph(MT, "UI", "Pure Roblox GUI — works on every executor")

-- PROJECT LAZARUS
local LT = MakeTab("PL Zombies")
MakeSection(LT, "Status")
MakeParagraph(LT, "Protection Active", "gcinfo spoofed · rawset patches · smart HP · deepcopy backup")

MakeSection(LT, "Gun Mods")
MakeToggle(LT, "Infinite Ammo", "Sets all ammo keys to 99 every frame", function(v) State.InfAmmoEnabled=v end)
MakeToggle(LT, "Insta Kill  [Protected]", "Real zombie HP + 10% buffer", function(v)
    State.InstaKillEnabled=v
    if v then Notify("Insta Kill ON","Round "..(RoundNum.Value or 1).." → "..GetSmartDamage().." DMG") end
end)
MakeToggle(LT, "No Recoil", "Zeros all ViewKick/Recoil tables", function(v) State.NoRecoilEnabled=v end)
MakeToggle(LT, "No Spread", "Zeros all Spread/Bloom tables", function(v) State.NoSpreadEnabled=v end)

MakeSection(LT, "Kill Aura")
MakeToggle(LT, "Kill Aura", "Fires Damage remote — earns points", function(v)
    State.KillAuraEnabled=v
    if v then StartKillAura() else StopKillAura() end
end)
MakeSlider(LT, "Kill Aura Range", 10, 250, 40, " studs", function(v) State.KillAuraRange=v end)

MakeSection(LT, "Utility")
MakeToggle(LT, "Freeze Zombies", "Anchors + WalkSpeed=0 every frame", function(v)
    if v then StartFreeze() else StopFreeze() end
end)
MakeToggle(LT, "Auto Fortify", "Fires prompts + F key for pts/plank", function(v)
    State.AutoFortEnabled=v
    if v then StartAutoFort() else StopAutoFort() end
end)
MakeSlider(LT, "Fortify Range", 5, 60, 20, " studs", function(v) State.AutoFortRange=v end)

MakeSection(LT, "Visuals")
MakeToggle(LT, "Zombie ESP", "Red highlight through walls", function(v)
    if v then EnableESP() else DisableESP() end
end)

MakeSection(LT, "Points Farm")
MakeParagraph(LT, "How it works", "Fires Damage=0 remote. Each fire = +10pts. Needs 1 zombie alive.")
MakeSlider(LT, "Points Amount", 10, 1000000, 1000, " pts", function(v) State.PointsAmount=v end)
MakeButton(LT, "Farm Points Now", nil, function() task.spawn(FarmPoints) end)

-- PLAYER
local PT = MakeTab("Player")
MakeSection(PT, "Movement")
MakeToggle(PT, "Speed Hack", "rawset WalkSpeed every frame", function(v)
    State.SpeedEnabled=v
    ApplySpeed(v and State.SpeedValue or 16)
end)
MakeSlider(PT, "Walk Speed", 16, 250, 16, " studs/s", function(v)
    State.SpeedValue=v
    if State.SpeedEnabled then ApplySpeed(v) end
end)
MakeToggle(PT, "Jump Hack", "rawset JumpPower every frame", function(v)
    State.JumpEnabled=v
    ApplyJump(v and State.JumpValue or 50)
end)
MakeSlider(PT, "Jump Power", 50, 500, 50, "", function(v)
    State.JumpValue=v
    if State.JumpEnabled then ApplyJump(v) end
end)
MakeToggle(PT, "Infinite Jump", "Re-jump while mid-air", function(v) State.InfiniteJump=v end)

MakeSection(PT, "Utility")
MakeToggle(PT, "Noclip", "Walk through all walls", function(v)
    State.NoclipEnabled=v
    if v then StartNoclip() else StopNoclip() end
end)
MakeToggle(PT, "Fly  [WASD+Space/Ctrl]", "LinearVelocity-based fly", function(v)
    State.FlyEnabled=v
    if v then StartFly() else StopFly() end
end)
MakeSlider(PT, "Fly Speed", 10, 200, 50, " studs/s", function(v) State.FlySpeed=v end)
MakeButton(PT, "Reset Stats", nil, function()
    local h=GetHumanoid()
    if h then pcall(function() rawset(h,"WalkSpeed",16); rawset(h,"JumpPower",50) end) end
    State.SpeedEnabled=false; State.JumpEnabled=false
end)

-- SETTINGS
local ST = MakeTab("Settings")
MakeSection(ST, "Keybind")
MakeParagraph(ST, "Minimize Keybind", "Press Left Alt to show/hide the window")
MakeSection(ST, "Info")
MakeParagraph(ST, "Executor Support", "Pure Roblox GUI — no external library\nWorks on Velocity, KRNL, Fluxus, Synapse X, Delta, Arceus X and all others")

-- Activate first tab
AllTabs["Main"].btn:Fire("MouseButton1Click")
-- Fallback in case Fire isn't supported
local firstTab = AllTabs["Main"]
if firstTab then
    firstTab.scroll.Visible = true
    firstTab.btn.TextColor3 = COL_TEXT
    firstTab.btn.BackgroundColor3 = Color3.fromRGB(40,40,52)
    firstTab.bar.Visible = true
end

Notify("PL Hub v5 Ready", "All bypasses active. Left Alt = show/hide", 5)

--//  DONE
--// ══════════════════════════════════════
Notify("PL Hub v5 Ready", "All bypasses active. Left Alt = minimise.", 5)

--// ══════════════════════════════════════
--//  SAFE PROTECTION
--//  hookmetamethod(__index) is NOT used —
--//  it was intercepting the old UI lib internal
--//  property reads and breaks all callbacks.
--//  Instead we use a simple Heartbeat loop
--//  to keep applying speed/jump every frame.
--// ══════════════════════════════════════

-- gcinfo spoof — only runs if executor supports hookfunction + newcclosure
pcall(function()
    if type(hookfunction) == "function" and type(newcclosure) == "function" then
        local _origGc = gcinfo()
        hookfunction(gcinfo, newcclosure(function()
            return _origGc
        end))
    end
end)

-- Speed/Jump enforcer
-- Also detects when player is aiming (PL sets tool active)
-- and forces WalkSpeed back to 16 so weapon ADS isn't broken
RunService.Heartbeat:Connect(function()
    local h = GetHumanoid()
    if not h then return end

    -- Detect if player has a weapon equipped and is aiming
    -- PL sets CurrentCamera CameraType to Scriptable while ADS
    local isAiming = false
    local char = GetCharacter()
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            -- Check if camera is in scriptable mode (ADS active in PL)
            local cam = Workspace.CurrentCamera
            if cam and cam.CameraType == Enum.CameraType.Scriptable then
                isAiming = true
            end
        end
    end

    if isAiming then
        -- Always restore default speed while aiming — never override PL's ADS
        rawset(h, "WalkSpeed", 16)
    elseif State.SpeedEnabled then
        rawset(h, "WalkSpeed", State.SpeedValue)
    end

    if State.JumpEnabled then
        rawset(h, "JumpPower", State.JumpValue)
    end
end)
