--[[
    PROJECT LAZARUS : ZOMBIES HUB  v5
    Built on Rayfield UI by Sirius
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
local Rayfield = loadstring(game:HttpGet(
    "https://sirius.menu/rayfield"
))()


--//  MAIN UI
--// ══════════════════════════════════════════════════════════
local RoundNum = Workspace:FindFirstChild("RoundNum") or { Value = 1 }



local Window = Rayfield:CreateWindow({
    Name             = "PL Zombies Hub  v5",
    LoadingTitle     = "PL Zombies Hub",
    LoadingSubtitle  = "by darkyscript",
    ConfigurationSaving = { Enabled = false },
    KeySystem        = false,
})

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
        Rayfield:Notify({ Title="No Damage Remote", Description="No alive zombies with Damage remote found.", Duration=5 })
        return
    end
    local key = GetDamageKey()
    local iters = math.floor(amount / 10)
    Rayfield:Notify({ Title="Farming Points...", Description="Firing "..iters.."x → +"..iters*10 .." pts", Duration=3 })
    for i = 1, iters do
        pcall(function()
            remote:FireServer({ Source=root.Position, Slash=true, Damage=0 }, key)
        end)
        if i % 10 == 0 then task.wait() end
    end
    Rayfield:Notify({ Title="Done!", Description="+"..iters*10 .." pts farmed!", Duration=5 })
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




--//  UI — RAYFIELD TABS
--// ══════════════════════════════════════

-- ── MAIN TAB ────────────────────────────
local MT = Window:CreateTab("Main", 4483362458)
local CredSec = MT:CreateSection("Credits")
MT:CreateParagraph({
    Title   = "PL Zombies Hub v5",
    Content = "Script by darkyscript\nGame: Project Lazarus: Zombies (ID 443406476)\nDev: Logitech101",
})
MT:CreateParagraph({
    Title   = "Built with",
    Content = "Rayfield UI by Sirius",
})

-- ── PROJECT LAZARUS TAB ─────────────────
local LT = Window:CreateTab("Project Lazarus", 4483362458)

LT:CreateSection("Status")
LT:CreateParagraph({
    Title   = "Protection Active",
    Content = "gcinfo spoofed · rawset() patches · smart HP formula · deepcopy backup · all pcall wrapped",
})

LT:CreateSection("Gun Mods")
LT:CreateToggle({
    Name        = "Infinite Ammo",
    CurrentValue= false,
    Flag        = "InfAmmo",
    Callback    = function(v) State.InfAmmoEnabled = v end,
})
LT:CreateToggle({
    Name        = "Insta Kill  [Protected]",
    CurrentValue= false,
    Flag        = "InstaKill",
    Callback    = function(v)
        State.InstaKillEnabled = v
        if v then
            Rayfield:Notify({ Title="Insta Kill ON", Description="Round "..(RoundNum.Value or 1).." → "..GetSmartDamage().." DMG", Duration=4 })
        end
    end,
})
LT:CreateToggle({
    Name        = "No Recoil",
    CurrentValue= false,
    Flag        = "NoRecoil",
    Callback    = function(v) State.NoRecoilEnabled = v end,
})
LT:CreateToggle({
    Name        = "No Spread",
    CurrentValue= false,
    Flag        = "NoSpread",
    Callback    = function(v) State.NoSpreadEnabled = v end,
})

LT:CreateSection("Kill Aura")
LT:CreateToggle({
    Name        = "Kill Aura",
    CurrentValue= false,
    Flag        = "KillAura",
    Callback    = function(v)
        State.KillAuraEnabled = v
        if v then StartKillAura() else StopKillAura() end
    end,
})
LT:CreateSlider({
    Name        = "Kill Aura Range",
    Range       = {10, 250},
    Increment   = 1,
    Suffix      = " studs",
    CurrentValue= 40,
    Flag        = "KillAuraRange",
    Callback    = function(v) State.KillAuraRange = v end,
})

LT:CreateSection("Utility")
LT:CreateToggle({
    Name        = "Freeze Zombies",
    CurrentValue= false,
    Flag        = "FreezeZombies",
    Callback    = function(v)
        if v then StartFreeze() else StopFreeze() end
    end,
})
LT:CreateToggle({
    Name        = "Auto Fortify",
    CurrentValue= false,
    Flag        = "AutoFortify",
    Callback    = function(v)
        State.AutoFortEnabled = v
        if v then StartAutoFort() else StopAutoFort() end
    end,
})
LT:CreateSlider({
    Name        = "Fortify Range",
    Range       = {5, 60},
    Increment   = 1,
    Suffix      = " studs",
    CurrentValue= 20,
    Flag        = "FortifyRange",
    Callback    = function(v) State.AutoFortRange = v end,
})

LT:CreateSection("Visuals")
LT:CreateToggle({
    Name        = "Zombie ESP",
    CurrentValue= false,
    Flag        = "ZombieESP",
    Callback    = function(v)
        if v then EnableESP() else DisableESP() end
    end,
})

LT:CreateSection("Points Farm")
LT:CreateParagraph({
    Title   = "How it works",
    Content = "Fires Damage remote with Damage=0. Each fire = +10pts. Requires 1 zombie alive.",
})
LT:CreateSlider({
    Name        = "Points Amount",
    Range       = {10, 1000000},
    Increment   = 10,
    Suffix      = " pts",
    CurrentValue= 1000,
    Flag        = "PointsAmount",
    Callback    = function(v) State.PointsAmount = v end,
})
LT:CreateButton({
    Name     = "Farm Points Now",
    Callback = function()
        task.spawn(FarmPoints)
    end,
})

-- ── PLAYER TAB ──────────────────────────
local PT = Window:CreateTab("Player", 4483362458)

PT:CreateSection("Movement")
PT:CreateToggle({
    Name        = "Speed Hack",
    CurrentValue= false,
    Flag        = "SpeedHack",
    Callback    = function(v)
        State.SpeedEnabled = v
        ApplySpeed(v and State.SpeedValue or 16)
    end,
})
PT:CreateSlider({
    Name        = "Walk Speed",
    Range       = {16, 250},
    Increment   = 1,
    CurrentValue= 16,
    Flag        = "WalkSpeed",
    Callback    = function(v)
        State.SpeedValue = v
        if State.SpeedEnabled then ApplySpeed(v) end
    end,
})
PT:CreateToggle({
    Name        = "Jump Hack",
    CurrentValue= false,
    Flag        = "JumpHack",
    Callback    = function(v)
        State.JumpEnabled = v
        ApplyJump(v and State.JumpValue or 50)
    end,
})
PT:CreateSlider({
    Name        = "Jump Power",
    Range       = {50, 500},
    Increment   = 1,
    CurrentValue= 50,
    Flag        = "JumpPower",
    Callback    = function(v)
        State.JumpValue = v
        if State.JumpEnabled then ApplyJump(v) end
    end,
})
PT:CreateToggle({
    Name        = "Infinite Jump",
    CurrentValue= false,
    Flag        = "InfiniteJump",
    Callback    = function(v) State.InfiniteJump = v end,
})

PT:CreateSection("Utility")
PT:CreateToggle({
    Name        = "Noclip",
    CurrentValue= false,
    Flag        = "Noclip",
    Callback    = function(v)
        State.NoclipEnabled = v
        if v then StartNoclip() else StopNoclip() end
    end,
})
PT:CreateToggle({
    Name        = "Fly  [WASD + Space/Ctrl]",
    CurrentValue= false,
    Flag        = "Fly",
    Callback    = function(v)
        State.FlyEnabled = v
        if v then StartFly() else StopFly() end
    end,
})
PT:CreateSlider({
    Name        = "Fly Speed",
    Range       = {10, 200},
    Increment   = 1,
    CurrentValue= 50,
    Flag        = "FlySpeed",
    Callback    = function(v) State.FlySpeed = v end,
})
PT:CreateButton({
    Name     = "Reset Stats",
    Callback = function()
        local h = GetHumanoid()
        if h then
            pcall(function() rawset(h,"WalkSpeed",16); rawset(h,"JumpPower",50) end)
        end
        State.SpeedEnabled = false; State.JumpEnabled = false
    end,
})

-- ── SETTINGS TAB ────────────────────────
local ST = Window:CreateTab("Settings", 4483362458)

ST:CreateSection("Keybind")
ST:CreateKeybind({
    Name         = "Minimize Keybind",
    CurrentKeybind = "LeftAlt",
    HoldToInteract = false,
    Flag         = "MinimizeKey",
    Callback     = function(k) end,
})

--//  DONE
--// ══════════════════════════════════════
Rayfield:Notify({
    Title       = "PL Hub v5 Ready",
    Description = "All bypasses active. Left Alt = minimise.",
    Duration    = 5,
})

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
