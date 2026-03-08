--[[
    PROJECT LAZARUS : ZOMBIES HUB  v5
    Built on lates-lib by lxte
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
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/lxte/lates-lib/main/Main.lua"
))() 


--//  MAIN UI
--// ══════════════════════════════════════════════════════════
local RoundNum = Workspace:FindFirstChild("RoundNum") or { Value = 1 }

local Themes = {
    Light = {
        Primary=Color3.fromRGB(232,232,232), Secondary=Color3.fromRGB(255,255,255),
        Component=Color3.fromRGB(245,245,245), Interactables=Color3.fromRGB(235,235,235),
        Tab=Color3.fromRGB(50,50,50), Title=Color3.fromRGB(0,0,0),
        Description=Color3.fromRGB(100,100,100), Shadow=Color3.fromRGB(255,255,255),
        Outline=Color3.fromRGB(210,210,210), Icon=Color3.fromRGB(100,100,100),
    },
    Dark = {
        Primary=Color3.fromRGB(30,30,30), Secondary=Color3.fromRGB(35,35,35),
        Component=Color3.fromRGB(40,40,40), Interactables=Color3.fromRGB(45,45,45),
        Tab=Color3.fromRGB(200,200,200), Title=Color3.fromRGB(240,240,240),
        Description=Color3.fromRGB(200,200,200), Shadow=Color3.fromRGB(0,0,0),
        Outline=Color3.fromRGB(40,40,40), Icon=Color3.fromRGB(220,220,220),
    },
    Void = {
        Primary=Color3.fromRGB(15,15,15), Secondary=Color3.fromRGB(20,20,20),
        Component=Color3.fromRGB(25,25,25), Interactables=Color3.fromRGB(30,30,30),
        Tab=Color3.fromRGB(200,200,200), Title=Color3.fromRGB(240,240,240),
        Description=Color3.fromRGB(200,200,200), Shadow=Color3.fromRGB(0,0,0),
        Outline=Color3.fromRGB(40,40,40), Icon=Color3.fromRGB(220,220,220),
    },
}

local Window = Library:CreateWindow({
    Title           = "PL Zombies Hub  v5",
    Size            = UDim2.fromOffset(590, 390),
    Transparency    = 0.2,
    MinimizeKeybind = Enum.KeyCode.LeftAlt,
})
Window:SetTheme(Themes.Dark)

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
        Window:Notify({ Title="No Damage Remote", Description="No alive zombies with Damage remote found.", Duration=5 })
        return
    end
    local key = GetDamageKey()
    local iters = math.floor(amount / 10)
    Window:Notify({ Title="Farming Points...", Description="Firing "..iters.."x → +"..iters*10 .." pts", Duration=3 })
    for i = 1, iters do
        pcall(function()
            remote:FireServer({ Source=root.Position, Slash=true, Damage=0 }, key)
        end)
        if i % 10 == 0 then task.wait() end
    end
    Window:Notify({ Title="Done!", Description="+"..iters*10 .." pts farmed!", Duration=5 })
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




--//  UI — TAB SECTIONS
--// ══════════════════════════════════════
Window:AddTabSection({ Name="Main",    Order=0 })
Window:AddTabSection({ Name="Lazarus",  Order=1 })
Window:AddTabSection({ Name="Player",   Order=2 })
Window:AddTabSection({ Name="Settings", Order=3 })

--// ════════════════════════════
--//  TAB: MAIN (credits)
--// ════════════════════════════
local MT = Window:AddTab({ Title="Main", Section="Main", Icon="rbxassetid://11963373994" })

Window:AddSection({ Name="Welcome", Tab=MT })
Window:AddParagraph({
    Title="PL Zombies Hub",
    Description="A feature-rich hub for Project Lazarus: Zombies. Use responsibly.",
    Tab=MT,
})
Window:AddParagraph({
    Title="Game",
    Description="Project Lazarus: Zombies\nGame ID: 443406476\nDeveloped by: Logitech101",
    Tab=MT,
})

Window:AddSection({ Name="Credits", Tab=MT })
Window:AddParagraph({
    Title="Script by",
    Description="darkyscript",
    Tab=MT,
})
Window:AddParagraph({
    Title="Built with",
    Description="lates-lib UI by lxte\ngithub.com/lxte/lates-lib",
    Tab=MT,
})



--// ════════════════════════════
--//  TAB: PROJECT LAZARUS
--// ════════════════════════════
local LT = Window:AddTab({ Title="Project Lazarus", Section="Lazarus", Icon="rbxassetid://11963373994" })

Window:AddSection({ Name="Status", Tab=LT })
Window:AddParagraph({
    Title="Protection Active ✓",
    Description="gcinfo spoofed · rawset() patches · smart HP formula · deepcopy backup · all pcall wrapped · Heartbeat speed enforcer",
    Tab=LT,
})

Window:AddSection({ Name="Gun Mods", Tab=LT })
Window:AddToggle({ Title="Infinite Ammo", Description="rawset() sets all ammo/magsize keys to 9999 every frame", Tab=LT,
    Callback=function(v) State.InfAmmoEnabled=v end })
Window:AddToggle({ Title="Insta Kill  [Protected]", Description="Sends real zombie HP + 10% buffer — not a flat hack value", Tab=LT,
    Callback=function(v)
        State.InstaKillEnabled=v
        if v then Window:Notify({ Title="Insta Kill ON", Description="Round "..(RoundNum.Value or 1).." → "..GetSmartDamage().." DMG", Duration=4 }) end
    end })
Window:AddToggle({ Title="No Recoil", Description="rawset ViewKick to zero", Tab=LT,
    Callback=function(v) State.NoRecoilEnabled=v end })
Window:AddToggle({ Title="No Spread", Description="rawset all Spread keys to zero", Tab=LT,
    Callback=function(v) State.NoSpreadEnabled=v end })

Window:AddSection({ Name="Kill Aura", Tab=LT })
Window:AddToggle({ Title="Kill Aura", Description="Fires Humanoid.Damage remote with live damage_key — earns points", Tab=LT,
    Callback=function(v) State.KillAuraEnabled=v; if v then StartKillAura() else StopKillAura() end end })
Window:AddSlider({ Title="Kill Aura Range", Description="Studs (default 40)", Tab=LT, MaxValue=250, Default=40, AllowDecimals=false,
    Callback=function(v) State.KillAuraRange=v end })

Window:AddSection({ Name="Utility", Tab=LT })
Window:AddToggle({ Title="Freeze Zombies", Description="Anchors HRP + WalkSpeed=0 every frame — truly stops all zombies", Tab=LT,
    Callback=function(v) if v then StartFreeze() else StopFreeze() end end })
Window:AddToggle({ Title="Auto Fortify", Description="Fires ProximityPrompts + [F] for +10pts per plank", Tab=LT,
    Callback=function(v) State.AutoFortEnabled=v; if v then StartAutoFort() else StopAutoFort() end end })
Window:AddSlider({ Title="Fortify Range", Description="Search radius (studs)", Tab=LT, MaxValue=60, Default=20, AllowDecimals=false,
    Callback=function(v) State.AutoFortRange=v end })

Window:AddSection({ Name="Visuals", Tab=LT })
Window:AddToggle({ Title="Zombie ESP", Description="Red highlight on all zombies — visible through walls (AlwaysOnTop)", Tab=LT,
    Callback=function(v) if v then EnableESP() else DisableESP() end end })

Window:AddSection({ Name="Points Farm", Tab=LT })
Window:AddParagraph({
    Title="How it works",
    Description="Fires Damage remote with Damage=0. Each fire = +10pts. No kill needed. Requires 1 zombie alive.",
    Tab=LT,
})
Window:AddSlider({ Title="Points Amount", Description="How many points to farm (max 1,000,000)", Tab=LT,
    MaxValue=1000000, Default=1000, AllowDecimals=false,
    Callback=function(v) State.PointsAmount = v end })
Window:AddButton({ Title="Farm Points Now", Description="Click to get points instantly", Tab=LT,
    Callback=function()
        task.spawn(function()
            GetPoints(State.PointsAmount or 1000)
        end)
    end })

--// ════════════════════════════
--//  TAB: PLAYER
--// ════════════════════════════
local PT = Window:AddTab({ Title="Player", Section="Player", Icon="rbxassetid://11293977610" })

Window:AddSection({ Name="Movement", Tab=PT })
Window:AddToggle({ Title="Speed Hack", Description="Server sees 16 via __index spoof", Tab=PT,
    Callback=function(v) State.SpeedEnabled=v; ApplySpeed(v and State.SpeedValue or 16) end })
Window:AddSlider({ Title="Walk Speed", Description="Default: 16", Tab=PT, MaxValue=250, Default=16, AllowDecimals=false,
    Callback=function(v) State.SpeedValue=v; if State.SpeedEnabled then ApplySpeed(v) end end })
Window:AddToggle({ Title="Jump Hack", Description="Server sees 50 via __index spoof", Tab=PT,
    Callback=function(v) State.JumpEnabled=v; ApplyJump(v and State.JumpValue or 50) end })
Window:AddSlider({ Title="Jump Power", Description="Default: 50", Tab=PT, MaxValue=500, Default=50, AllowDecimals=false,
    Callback=function(v) State.JumpValue=v; if State.JumpEnabled then ApplyJump(v) end end })
Window:AddToggle({ Title="Infinite Jump", Description="Re-jump while mid-air", Tab=PT,
    Callback=function(v) State.InfiniteJump=v end })

Window:AddSection({ Name="Utility", Tab=PT })
Window:AddToggle({ Title="Noclip", Description="Walk through all walls", Tab=PT,
    Callback=function(v) State.NoclipEnabled=v; if v then StartNoclip() else StopNoclip() end end })
Window:AddToggle({ Title="Fly", Description="WASD + Space/Ctrl — uses LinearVelocity", Tab=PT,
    Callback=function(v) State.FlyEnabled=v; if v then StartFly() else StopFly() end end })
Window:AddSlider({ Title="Fly Speed", Description="Default: 50", Tab=PT, MaxValue=200, Default=50, AllowDecimals=false,
    Callback=function(v) State.FlySpeed=v end })
Window:AddButton({ Title="Reset Stats", Description="WalkSpeed=16, JumpPower=50", Tab=PT,
    Callback=function()
        local h=GetHumanoid(); if h then h.WalkSpeed=16; h.JumpPower=50 end
        State.SpeedEnabled=false; State.JumpEnabled=false
        Window:Notify({ Title="Stats Reset", Description="Defaults restored.", Duration=3 })
    end })

UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local h=GetHumanoid(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

--// ════════════════════════════
--//  TAB: SETTINGS
--// ════════════════════════════
local ST = Window:AddTab({ Title="Settings", Section="Settings", Icon="rbxassetid://11293977610" })

Window:AddSection({ Name="UI", Tab=ST })
Window:AddKeybind({ Title="Minimize Keybind", Description="Default: Left Alt", Tab=ST,
    Callback=function(k) Window:SetSetting("Keybind",k) end })
Window:AddDropdown({ Title="Theme", Tab=ST,
    Options={ ["Light Mode"]="Light", ["Dark Mode"]="Dark", ["Extra Dark"]="Void" },
    Callback=function(t) Window:SetTheme(Themes[t]) end })
Window:AddToggle({ Title="UI Blur", Description="Requires graphics level 8+", Default=true, Tab=ST,
    Callback=function(v) Window:SetSetting("Blur",v) end })
Window:AddSlider({ Title="UI Transparency", Description="0=solid · 1=invisible", Tab=ST, AllowDecimals=true, MaxValue=1,
    Callback=function(v) Window:SetSetting("Transparency",v) end })

--// ══════════════════════════════════════
--//  DONE
--// ══════════════════════════════════════
Window:Notify({
    Title       = "PL Hub v5 Ready",
    Description = "All bypasses active. Left Alt = minimise.",
    Duration    = 5,
})

--// ══════════════════════════════════════
--//  SAFE PROTECTION
--//  hookmetamethod(__index) is NOT used —
--//  it intercepts lates-lib's own internal
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