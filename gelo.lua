-- ================================================================
-- BYPASS (UNCHANGED)
-- ================================================================
local MemoryStoreService = game:GetService("MemoryStoreService")
local lp = game.Players.LocalPlayer
local Bypass = { Hooks = {}, Stealth = {}, Patterns = {}, KillFakeHandshake = {} }
local function killFakeHandshake()
    local fake = MemoryStoreService:FindFirstChild("Hyphon_Check")
    if fake and fake:IsA("RemoteEvent") then pcall(function() fake:Destroy() end) end
end
killFakeHandshake()
Bypass.Hooks = {
    Trampoline = function(target, hook)
        local mt = getmetatable(target)
        if mt and mt.__index then local orig = mt.__index; mt.__index = function(self,k) if k=="FindPartOnRay" or k=="FireServer" then return hook end; return orig(self,k) end; return hook end
    end,
    Environment = function()
        local env = getfenv(2)
        setfenv(2, setmetatable({},{__index=function(t,k) if k=="debug" or k=="shared" then return nil end; return env[k] end, __newindex=function(t,k,v) if k~="LoadLibrary" then env[k]=v end end}))
    end,
    LightBypass = function()
        local mt = getmetatable(game:GetService("Lighting"))
        if mt and mt.__newindex then mt.__newindex = newcclosure(function(self,k,v) if k=="Brightness" or k=="GlobalShadows" or k=="FogEnd" then return rawset(self,k,v) end; return mt.__newindex(self,k,v) end) end
    end
}
Bypass.Stealth = {
    Memory = function()
        local mt = getmetatable(game)
        if mt and mt.__index then mt.__index = newcclosure(function(self,k) if k=="Players" or k=="Workspace" then return rawget(self,k) end; return mt.__index(self,k) end) end
    end,
    Terrain = function()
        local terrain = workspace:FindFirstChild("Terrain")
        if terrain then local mt=getmetatable(terrain); if mt and mt.__index then mt.__index=newcclosure(function(self,k) if k=="WaterWaveSize" or k=="WaterWaveSpeed" then return function() return 0 end end; return mt.__index(self,k) end) end end
    end
}
Bypass.Patterns = {
    Randomize = function()
        local mt = getmetatable(workspace)
        if mt and mt.__index then mt.__index=newcclosure(function(self,k) if k=="GetChildren" or k=="FindFirstChild" then return function(...) local r=mt.__index(self,k)(...); if type(r)=="table" then table.sort(r,function() return math.random()>.5 end) end; return r end end; return mt.__index(self,k) end) end
    end,
    Obfuscate = function()
        local mt = getmetatable(game:GetService("Players"))
        if mt and mt.__index then mt.__index=newcclosure(function(self,k) if k=="LocalPlayer" then return nil end; return mt.__index(self,k) end) end
    end,
}
Bypass.Executor = function()
    while true do
        pcall(Bypass.Hooks.Environment)
        pcall(Bypass.Stealth.Memory)
        pcall(Bypass.Patterns.Randomize)
        pcall(Bypass.Patterns.Obfuscate)
        pcall(Bypass.Hooks.LightBypass)
        pcall(Bypass.Stealth.Terrain)
        wait(math.random(2, 5))  -- Jeda lebih lama
    end
end
spawn(function()
    Bypass.Executor()
    Bypass.Hooks.Trampoline(workspace, function(...) return nil end)
    Bypass.Hooks.Trampoline(game:GetService("ReplicatedStorage"), function(...) return nil end)
end)

-- ========== LAYER 1: HIDE EXPLOIT TRACES (AMAN) ==========
pcall(function()
    local fenv = getfenv()
    local hideList = {
        "syn", "KRNL_LOADED", "EXECUTOR_NAME", "getexecutorname",
        "identifyexecutor", "queue_on_teleport", "rconsoleprint",
        "rconsoleerr", "rconsoleclear", "setclipboard", "getclipboard",
        "syn_request", "http_request", "request", "loadstring",
        "getgenv", "getrenv", "getfenv", "getgc", "getreg", "getcallingscript"
    }
    for _, name in ipairs(hideList) do
        if fenv[name] then fenv[name] = nil end
    end
end)

-- ========== LAYER 2: FAKE LAG MINIMAL (TIDAK MENCURIGAKAN) ==========
if not getgenv()._fakeLag then
    getgenv()._fakeLag = true
    task.spawn(function()
        while task.wait(0.3) do
            if math.random(1, 100) == 1 then
                task.wait(math.random(1, 5) / 1000)
            end
        end
    end)
end

-- ========== LAYER 3: KICK PROTECTION (TANPA HOOK) ==========
-- Hanya override fungsi Kick langsung
pcall(function()
    if LocalPlayer and type(LocalPlayer.Kick) == "function" then
        LocalPlayer.Kick = function() end
    end
end)

-- ========== LAYER 4: OVERRIDE GETCALLINGSCRIPT (SPOOF) ==========
pcall(function()
    local old = getcallingscript
    getcallingscript = function()
        local result = old()
        if result == nil then
            return game:GetService("StarterPlayer").StarterPlayerScripts
        end
        return result
    end
end)

-- ========== LAYER 5: SEMBUNYIKAN SCRIPT INI DARI GETGC ==========
-- Pindahin semua variabel ke local biar ga keliatan di GC
local _hiddenVars = {}

-- ========== LAYER 6: ERROR HANDLER (CEGAH LOG ERROR) ==========
pcall(function()
    local oldError = error
    error = function(msg, level)
        if type(msg) == "string" and (
            msg:lower():find("kick") or 
            msg:lower():find("ban") or
            msg:lower():find("exploit") or
            msg:lower():find("cheat")
        ) then
            return nil
        end
        return oldError(msg, level)
    end
end)

-- ========== LAYER 7: PROTECT GETRENV VARS ==========
pcall(function()
    local env = getrenv()
    if env then
        env.script = nil
    end
end)

-- ========== LAYER 8: GETREG (HIDE TABLES) ==========
pcall(function()
    for i, v in next, getreg() do
if type(v) == "thread" then
if string.find(debug.traceback(v), "<", 1, true) then
coroutine.close(v)
end
end
end
end)

-- ========= LAYER 9: PROTECT GETGC (HIDE FUNCTIONS) ==========
pcall(function()
    local oldGetGC = getgc
    getgc = function(...)
        local result = oldGetGC(...)
        local filtered = {}
        for i, v in next, result do
            if type(v) == "function" then
                local info = debug.getinfo(v)
                if info and info.what ~= "C" then
                    table.insert(filtered, v)
                end
            end
        end
        return filtered
    end
end)

-- ========= Getthread ================ ---
pcall(function()
    for i,v in next, getallthreads() do
local s = getscriptfromthread(v)
if string.find(tostring(s), "<", 1, true) then
coroutine.close(v)
end
end end)

-- ================================================================
-- ========== BYPASS DARI URL (METAMETHOD, HANDSHAKE, DLL) ==========
-- ================================================================

local function bypassMetaMethods()
    local checks = {
        "checkcaller", "getcallingscript", "getfenv", "setfenv",
        "getreg", "getgc", "getconnections", "hookfunction", "newcclosure"
    }
    local foundChecks = {}
    for _, check in ipairs(checks) do
        if getgenv()[check] or _G[check] then
            table.insert(foundChecks, check)
        end
    end
    if hookfunction then
        local originalHook = hookfunction
        hookfunction = function(func, replacement)
            return originalHook(func, function(...)
                return replacement(...)
            end)
        end
    end
    if setreadonly then setreadonly(getrenv(), false) end
    if make_writeable then make_writeable(getreg()) end
end

local function bypassHandshakes()
    local remotes = game:GetService("ReplicatedStorage"):GetDescendants()
    local bypassed = 0
    for _, remote in ipairs(remotes) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local name = remote.Name:lower()
            if name:find("handshake") or name:find("validate") or name:find("verify") then
                bypassed = bypassed + 1
                if remote:IsA("RemoteEvent") then
                    remote.FireServer = function() return true end
                elseif remote:IsA("RemoteFunction") then
                    remote.InvokeServer = function() return true end
                end
            end
        end
    end
end

local function bypassHookChecks()
    local hooksBypassed = 0
    if detour_function then
        detour_function = function() return true end
        hooksBypassed = hooksBypassed + 1
    end
    if getconnections then
        for _, conn in ipairs(getconnections(game:GetService("ScriptContext").Error)) do
            conn:Disable()
            hooksBypassed = hooksBypassed + 1
        end
    end
end

local function bypassDetours()
    local detoursBypassed = 0
    local criticalFunctions = {
        "Instance.new", "getfenv", "setfenv", "getreg", "getgc", "checkcaller"
    }
    for _, funcName in ipairs(criticalFunctions) do
        pcall(function()
            local original = _G[funcName] or getgenv()[funcName]
            if original then _G[funcName] = original; detoursBypassed = detoursBypassed + 1 end
        end)
    end
    if getrenv then
        local env = getrenv()
        for name, func in pairs(env) do
            if type(func) == "function" and not string.find(name, "__") then
                pcall(function() env[name] = func end)
                detoursBypassed = detoursBypassed + 1
            end
        end
    end
end

local function bypassMemoryChecks()
    local memoryPatches = 0
    if setreadonly then
        pcall(function() setreadonly(getrenv(), false) end)
        pcall(function() setreadonly(getreg(), false) end)
        pcall(function() setreadonly(getgc(), false) end)
        memoryPatches = memoryPatches + 3
    end
    if getgc then
        for _, obj in ipairs(getgc()) do
            if type(obj) == "table" and rawget(obj, "__acsignature") then
                rawset(obj, "__acsignature", nil)
                memoryPatches = memoryPatches + 1
            end
        end
    end
end

local function bypassVMChecks()
    local vmBypasses = 0
    if debug then
        debug.info = function() return "C" end
        debug.traceback = function() return "" end
        vmBypasses = vmBypasses + 2
    end
    if getcallingscript then
        getcallingscript = function() return nil end
        vmBypasses = vmBypasses + 1
    end
end

local function bypassSignatures()
    local signaturesBypassed = 0
    local signatureTables = {"_G", "shared", "getgenv", "getrenv"}
    for _, tableName in ipairs(signatureTables) do
        local target = _G[tableName] or getgenv()[tableName]
        if target and type(target) == "table" then
            for key, _ in pairs(target) do
                local keyStr = tostring(key):lower()
                if keyStr:find("signature") or keyStr:find("checksum") or keyStr:find("hash") then
                    target[key] = nil
                    signaturesBypassed = signaturesBypassed + 1
                end
            end
        end
    end
end

local function bypassIntegrityChecks()
    local integrityBypasses = 0
    if getconnections then
        for _, conn in ipairs(getconnections(game:GetService("ScriptContext").ScriptAdded)) do
            conn:Disable()
            integrityBypasses = integrityBypasses + 1
        end
        for _, conn in ipairs(getconnections(game:GetService("ScriptContext").ScriptRemoved)) do
            conn:Disable()
            integrityBypasses = integrityBypasses + 1
        end
    end
    local modules = game:GetService("ReplicatedStorage"):GetDescendants()
    for _, module in ipairs(modules) do
        if module:IsA("ModuleScript") and 
           (module.Name:lower():find("integrity") or 
            module.Name:lower():find("security") or
            module.Name:lower():find("anti")) then
            pcall(function() module:Destroy() end)
            integrityBypasses = integrityBypasses + 1
        end
    end
end

-- ========== PANGGIL SEMUA BYPASS ==========
spawn(function()
    -- BYPASS YANG DARI URL
    pcall(bypassMetaMethods)
    pcall(bypassHandshakes)
    pcall(bypassHookChecks)
    pcall(bypassDetours)
    pcall(bypassMemoryChecks)
    pcall(bypassVMChecks)
    pcall(bypassSignatures)
    pcall(bypassIntegrityChecks)
end)

pcall(function()
    local mt = getrawmetatable(game)
    if mt then
        setreadonly(mt, false)
        local old_nc = mt.__namecall
        mt.__namecall = function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" then
                local str = tostring(self)
                if str:find("Anti") or str:find("Detect") or str:find("Check") or str:find("Report") then
                    return nil
                end
            end
            if method == "Kick" or method == "Ban" then
                return nil
            end
            return old_nc(self, ...)
        end
        setreadonly(mt, true)
    end

    local forbid = {"getexecutorname", "identifyexecutor", "checkexecutor", "is_synapse", "is_krnl"}
    for _, f in ipairs(forbid) do
        if _G[f] then _G[f] = function() return "Unknown" end end
    end

    pcall(function() game:GetService("LogService"):SetLogLevel(Enum.LogLevel.None) end)
end)

-- ================================================================
-- REMOVE HEX-NAMED REMOTEFUNCTIONS FROM REPLICATEDSTORAGE
-- ================================================================
task.wait(2) -- wait for game to fully load before removing

for _, v in ipairs(game.ReplicatedStorage:GetChildren()) do
    if string.match(v.Name, "^[0-9a-fA-F]+$") then
        for _, child in ipairs(v:GetChildren()) do
            if child:IsA("RemoteFunction") then
                child.Parent = nil
                print("Removed RemoteFunction:", child.Name, "from", v.Name)
            end
        end
    end
end

print("bypass loaded")

-- ================================================================
-- SERVICES
-- ================================================================
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local VIM = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

-- ================================================================
-- STATE TABLE
-- ================================================================
local S = {}

-- ================================================================
-- DRAWING AVAILABILITY CHECK (prevents crashes on unsupported executors)
-- ================================================================
local DrawingAvailable = false
pcall(function()
    local test = Drawing.new("Line")
    if test then
        test:Remove()
        DrawingAvailable = true
    end
end)

-- ================================================================
-- ESP SYSTEM
-- ================================================================
do
    S.ESP_BOX = false
    S.ESP_HPBAR = false
    S.ESP_DISTANCE = false
    S.ESP_SKELETON = false
    S.ESP_NAME = false
    S.ESP_ITEM = false
    S.ESP_MAX_DIST = 500
    S.ESP_BOX_COLOR = Color3.fromRGB(0, 255, 255)
    S._espPrev = false

    local ESP_OBJ = {}
    local BONES = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftHand"}, {"UpperTorso", "RightHand"},
        {"LowerTorso", "LeftFoot"}, {"LowerTorso", "RightFoot"},
    }
    local R6FB = {
        UpperTorso = "Torso", LowerTorso = "Torso",
        LeftHand = "Left Arm", RightHand = "Right Arm",
        LeftFoot = "Left Leg", RightFoot = "Right Leg",
    }

    local function hide(d)
        if not d or not d._vis then return end
        if d.Box then
            for i = 1, 4 do
                if d.Box[i] then
                    if d.Box[i][1] then d.Box[i][1].Visible = false end
                    if d.Box[i][2] then d.Box[i][2].Visible = false end
                end
            end
        end
        if d.Name then d.Name.Visible = false end
        if d.Dist then d.Dist.Visible = false end
        if d.Item then d.Item.Visible = false end
        if d.HPBg then d.HPBg.Visible = false end
        if d.HPFill then d.HPFill.Visible = false end
        if d.Bones then
            for i = 1, #d.Bones do
                if d.Bones[i] then d.Bones[i].Visible = false end
            end
        end
        d._vis = false
    end

    local function removeESP(plr)
        local d = ESP_OBJ[plr]
        if not d then return end
        pcall(function()
            if d.Box then
                for i = 1, 4 do
                    if d.Box[i] then
                        if d.Box[i][1] then d.Box[i][1]:Remove() end
                        if d.Box[i][2] then d.Box[i][2]:Remove() end
                    end
                end
            end
            if d.Name then d.Name:Remove() end
            if d.Dist then d.Dist:Remove() end
            if d.Item then d.Item:Remove() end
            if d.HPBg then d.HPBg:Remove() end
            if d.HPFill then d.HPFill:Remove() end
            if d.Bones then
                for i = 1, #d.Bones do
                    if d.Bones[i] then d.Bones[i]:Remove() end
                end
            end
        end)
        ESP_OBJ[plr] = nil
    end

    local function createESP(plr)
        if plr == LocalPlayer then return end
        if ESP_OBJ[plr] then return end
        local d = {}
        if not d.Box then d.Box = {} end
        for _ = 1, 4 do
            local h = Drawing.new("Line")
            h.Visible = false
            h.Color = S.ESP_BOX_COLOR
            h.Thickness = 1.5
            local v = Drawing.new("Line")
            v.Visible = false
            v.Color = S.ESP_BOX_COLOR
            v.Thickness = 1.5
            table.insert(d.Box, {h, v})
        end
        local function mkTxt(sz, col)
            local t = Drawing.new("Text")
            t.Visible = false
            t.Center = true
            t.Outline = true
            t.OutlineColor = Color3.new(0, 0, 0)
            t.Color = col
            t.Size = sz
            t.Font = 2
            return t
        end
        d.Name = mkTxt(13, Color3.new(1, 1, 1))
        d.Dist = mkTxt(11, Color3.fromRGB(200, 200, 200))
        d.Item = mkTxt(11, Color3.fromRGB(255, 220, 50))
        d.HPBg = Drawing.new("Square")
        d.HPBg.Visible = false
        d.HPBg.Color = Color3.fromRGB(20, 20, 20)
        d.HPBg.Filled = true
        d.HPBg.Thickness = 1
        d.HPFill = Drawing.new("Square")
        d.HPFill.Visible = false
        d.HPFill.Filled = true
        d.HPFill.Thickness = 1
        d.Bones = {}
        for _ = 1, #BONES do
            local l = Drawing.new("Line")
            l.Visible = false
            l.Color = Color3.new(1, 1, 1)
            l.Thickness = 1
            table.insert(d.Bones, l)
        end
        d._char = nil
        d._hum = nil
        d._hrp = nil
        d._vis = false
        ESP_OBJ[plr] = d
    end

    local function getPart(char, name)
        for _, c in ipairs(char:GetChildren()) do
            if c:IsA("BasePart") and c.Name == name then
                return c
            end
        end
        return nil
    end

    local function getPartFB(char, name)
        local p = getPart(char, name)
        if p then return p end
        local fb = R6FB[name]
        return fb and getPart(char, fb)
    end

    local function updateESP(plr, cam, myHRP)
        local anyToggle = S.ESP_BOX or S.ESP_HPBAR or S.ESP_DISTANCE or S.ESP_SKELETON or S.ESP_NAME or S.ESP_ITEM
        if not anyToggle then return end

        local d = ESP_OBJ[plr]
        if not d then return end
        local char = plr.Character
        if not char or not char.Parent then
            hide(d)
            return
        end

        if d._char ~= char then
            d._char = char
            d._hum = char:FindFirstChildOfClass("Humanoid")
            d._hrp = getPart(char, "HumanoidRootPart")
            hide(d)
        end
        local hum = d._hum
        local hrp = d._hrp
        if not hum or not hum.Parent then
            d._hum = char:FindFirstChildOfClass("Humanoid")
            hum = d._hum
        end
        if not hrp or not hrp.Parent then
            d._hrp = getPart(char, "HumanoidRootPart")
            hrp = d._hrp
        end

        if not hum or hum.Health <= 0 or not hrp then
            hide(d)
            return
        end
        if S.whitelist[plr.Name] then
            hide(d)
            return
        end

        local dist3D = (hrp.Position - myHRP.Position).Magnitude
        if S.ESP_MAX_DIST > 0 and dist3D > S.ESP_MAX_DIST then
            hide(d)
            return
        end

        local head = getPart(char, "Head")
        if not head then
            hide(d)
            return
        end
        local headPos = head.Position + Vector3.new(0, 0.5, 0)
        local rootPos = hrp.Position - Vector3.new(0, 3, 0)
        local headSP, onSc1 = cam:WorldToViewportPoint(headPos)
        local rootSP, onSc2 = cam:WorldToViewportPoint(rootPos)
        if not (onSc1 or onSc2) then
            hide(d)
            return
        end

        local topY = math.min(headSP.Y, rootSP.Y)
        local bottomY = math.max(headSP.Y, rootSP.Y)
        local h = bottomY - topY
        if h < 4 then
            hide(d)
            return
        end

        local centerX = (headSP.X + rootSP.X) * 0.5
        local w = h * 0.6
        local bx = centerX - w * 0.5
        local by = topY
        local vs = cam.ViewportSize
        if bx + w < -300 or bx > vs.X + 300 or by + h < -300 or by > vs.Y + 300 then
            hide(d)
            return
        end

        local col = plr.Team and plr.Team.TeamColor.Color or S.ESP_BOX_COLOR
        local cl = math.min(w, h) * 0.25

        if S.ESP_BOX and d.Box then
            d.Box[1][1].From = Vector2.new(bx, by)
            d.Box[1][1].To = Vector2.new(bx + cl, by)
            d.Box[1][1].Color = col
            d.Box[1][1].Visible = true
            d.Box[1][2].From = Vector2.new(bx, by)
            d.Box[1][2].To = Vector2.new(bx, by + cl)
            d.Box[1][2].Color = col
            d.Box[1][2].Visible = true
            d.Box[2][1].From = Vector2.new(bx + w, by)
            d.Box[2][1].To = Vector2.new(bx + w - cl, by)
            d.Box[2][1].Color = col
            d.Box[2][1].Visible = true
            d.Box[2][2].From = Vector2.new(bx + w, by)
            d.Box[2][2].To = Vector2.new(bx + w, by + cl)
            d.Box[2][2].Color = col
            d.Box[2][2].Visible = true
            d.Box[3][1].From = Vector2.new(bx, by + h)
            d.Box[3][1].To = Vector2.new(bx + cl, by + h)
            d.Box[3][1].Color = col
            d.Box[3][1].Visible = true
            d.Box[3][2].From = Vector2.new(bx, by + h)
            d.Box[3][2].To = Vector2.new(bx, by + h - cl)
            d.Box[3][2].Color = col
            d.Box[3][2].Visible = true
            d.Box[4][1].From = Vector2.new(bx + w, by + h)
            d.Box[4][1].To = Vector2.new(bx + w - cl, by + h)
            d.Box[4][1].Color = col
            d.Box[4][1].Visible = true
            d.Box[4][2].From = Vector2.new(bx + w, by + h)
            d.Box[4][2].To = Vector2.new(bx + w, by + h - cl)
            d.Box[4][2].Color = col
            d.Box[4][2].Visible = true
        end

        if S.ESP_NAME then
            d.Name.Text = plr.Name
            d.Name.Position = Vector2.new(centerX, by - 16)
            d.Name.Visible = true
        else
            if d.Name.Visible then d.Name.Visible = false end
        end

        if S.ESP_DISTANCE then
            d.Dist.Text = string.format("[%.0fm]", dist3D)
            d.Dist.Position = Vector2.new(centerX, by + h + 4)
            d.Dist.Visible = true
        else
            if d.Dist.Visible then d.Dist.Visible = false end
        end

        if S.ESP_ITEM then
            local toolName = nil
            for _, obj in ipairs(char:GetChildren()) do
                if obj:IsA("Tool") then
                    toolName = obj.Name
                    break
                end
            end
            if toolName then
                d.Item.Text = "[" .. toolName .. "]"
                d.Item.Position = Vector2.new(centerX, by + h + 16)
                d.Item.Visible = true
            else
                if d.Item.Visible then d.Item.Visible = false end
            end
        else
            if d.Item.Visible then d.Item.Visible = false end
        end

        if S.ESP_HPBAR then
            local r = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
            local hh = math.max(2, h * r)
            local hx = bx - 5
            d.HPBg.Size = Vector2.new(2, h)
            d.HPBg.Position = Vector2.new(hx, by)
            d.HPBg.Visible = true
            d.HPFill.Size = Vector2.new(2, hh)
            d.HPFill.Position = Vector2.new(hx, by + h - hh)
            if r > 0.6 then
                d.HPFill.Color = Color3.fromRGB(0, 255, 80)
            elseif r > 0.3 then
                d.HPFill.Color = Color3.fromRGB(255, 200, 0)
            else
                d.HPFill.Color = Color3.fromRGB(255, 50, 50)
            end
            d.HPFill.Visible = true
        else
            if d.HPBg.Visible then d.HPBg.Visible = false end
            if d.HPFill.Visible then d.HPFill.Visible = false end
        end

        if S.ESP_SKELETON then
            for i = 1, #BONES do
                local b = d.Bones[i]
                local p1 = getPartFB(char, BONES[i][1])
                local p2 = getPartFB(char, BONES[i][2])
                if p1 and p2 then
                    local s1, v1 = cam:WorldToViewportPoint(p1.Position)
                    local s2, v2 = cam:WorldToViewportPoint(p2.Position)
                    if v1 and v2 then
                        b.From = Vector2.new(s1.X, s1.Y)
                        b.To = Vector2.new(s2.X, s2.Y)
                        b.Visible = true
                    else
                        if b.Visible then b.Visible = false end
                    end
                else
                    if b.Visible then b.Visible = false end
                end
            end
        else
            for i = 1, #d.Bones do
                if d.Bones[i].Visible then d.Bones[i].Visible = false end
            end
        end
        d._vis = true
    end

    S.updateESPColor = function(col)
        for _, d in pairs(ESP_OBJ) do
            if d.Box then
                for i = 1, 4 do
                    if d.Box[i] then
                        if d.Box[i][1] then d.Box[i][1].Color = col end
                        if d.Box[i][2] then d.Box[i][2].Color = col end
                    end
                end
            end
        end
    end

    local _ea = 0
    RunService.Heartbeat:Connect(function(dt)
        _ea = _ea + dt
        local anyToggle = S.ESP_BOX or S.ESP_HPBAR or S.ESP_DISTANCE or S.ESP_SKELETON or S.ESP_NAME or S.ESP_ITEM
        if not anyToggle then
            if S._espPrev then
                for _, d in pairs(ESP_OBJ) do
                    hide(d)
                end
                S._espPrev = false
            end
            return
        end
        S._espPrev = true
        if _ea < 1 / 30 then return end
        _ea = 0
        local cam = workspace.CurrentCamera
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        for plr in pairs(ESP_OBJ) do
            if plr.Character then
                pcall(updateESP, plr, cam, myHRP)
            end
        end
    end)

    for _, plr in pairs(Players:GetPlayers()) do
        task.defer(createESP, plr)
    end
    Players.PlayerAdded:Connect(function(plr)
        task.defer(createESP, plr)
    end)
    Players.PlayerRemoving:Connect(removeESP)
end

---- instant interact ------
S.instantInteractEnabled = false
local function patchPrompt(prompt)
    pcall(function()
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        if prompt.ButtonHoldEnabled then
            prompt.ButtonHoldEnabled = false
        end
        prompt.ClickablePrompt = true
    end)
end

local function applyInstantInteract()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            patchPrompt(obj)
        end
    end
end

local function startInstantInteract()
    S.instantInteractEnabled = true
    applyInstantInteract()
    -- Auto-patch prompt baru
    S.instantInteractConnection = workspace.DescendantAdded:Connect(function(obj)
        if S.instantInteractEnabled and obj:IsA("ProximityPrompt") then
            patchPrompt(obj)
        end
    end)
end

local function stopInstantInteract()
    S.instantInteractEnabled = false
    if S.instantInteractConnection then
        S.instantInteractConnection:Disconnect()
        S.instantInteractConnection = nil
    end
end

-- ================================================================
-- VEHICLE FLY
-- ================================================================

do
    S.vFlyOn = false
    S.vFlySpd = 60
    local conn = nil
    local up = false
    local dn = false

    UserInputService.InputBegan:Connect(function(inp, gpe)
        if not S.vFlyOn or gpe then return end
        if inp.KeyCode == Enum.KeyCode.E then up = true end
        if inp.KeyCode == Enum.KeyCode.Q then dn = true end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.KeyCode == Enum.KeyCode.E then up = false end
        if inp.KeyCode == Enum.KeyCode.Q then dn = false end
    end)

    local function startFly()
        if conn then
            conn:Disconnect()
            conn = nil
        end
        local vPartsCache = {}
        local lastModel = nil
        conn = RunService.RenderStepped:Connect(function(dt)
            local ch = LocalPlayer.Character
            if not ch then return end
            local hm = ch:FindFirstChildOfClass("Humanoid")
            if not hm then return end
            local seat = hm.SeatPart
            if not seat then return end
            local mdl = seat:FindFirstAncestorOfClass("Model") or seat
            if mdl ~= lastModel then
                lastModel = mdl
                vPartsCache = {}
                if mdl then
                    for _, p in pairs(mdl:GetDescendants()) do
                        if p:IsA("BasePart") then
                            table.insert(vPartsCache, p)
                        end
                    end
                end
            end
            local root = mdl.PrimaryPart or seat
            local cf = Camera.CFrame
            local fwd = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
            if fwd.Magnitude > 0.01 then
                fwd = fwd.Unit
            else
                fwd = Vector3.new(0, 0, -1)
            end
            local rgt = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z)
            if rgt.Magnitude > 0.01 then
                rgt = rgt.Unit
            else
                rgt = Vector3.new(1, 0, 0)
            end
            local mv = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv = mv + fwd end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv = mv - fwd end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv = mv - rgt end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv = mv + rgt end
            if up then mv = mv + Vector3.new(0, 1, 0) end
            if dn then mv = mv - Vector3.new(0, 1, 0) end
            for i = 1, #vPartsCache do
                local p = vPartsCache[i]
                pcall(function()
                    p.AssemblyLinearVelocity = Vector3.zero
                    p.AssemblyAngularVelocity = Vector3.zero
                end)
            end
            if mv.Magnitude > 0 then
                mv = mv.Unit
                local np = root.Position + mv * S.vFlySpd * dt
                local ld = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
                if ld.Magnitude > 0.01 then
                    ld = ld.Unit
                else
                    ld = fwd
                end
                pcall(function()
                    local cp = mdl:GetPivot()
                    local tcf = CFrame.new(np, np + ld)
                    local off = cp:ToObjectSpace(root.CFrame)
                    mdl:PivotTo(tcf * off:Inverse())
                end)
            end
        end)
    end

    local function stopFly()
        if conn then
            conn:Disconnect()
            conn = nil
        end
        up = false
        dn = false
    end
    S.vFlyStart = startFly
    S.vFlyStop = stopFly
end

-- ================================================================
-- SILENT AIM
-- ================================================================
S.SilentAim = true
S.SilentAimPart = "HumanoidRootPart"
S.SilentAimWallbang = true
S.FovSize = 250
S.ShowFOV = true
S.FOVMode = "PC"
S.FovCircleColor = Color3.fromRGB(255, 0, 0)

-- ========== FOV CIRCLE ==========
if DrawingAvailable then
    S.FovCircle = Drawing.new("Circle")
    S.FovCircle.Radius = S.FovSize
    S.FovCircle.Thickness = 2
    S.FovCircle.Color = S.FovCircleColor or Color3.fromRGB(255, 0, 0)
    S.FovCircle.Transparency = 1
    S.FovCircle.NumSides = 64
    S.FovCircle.Filled = false
    S.FovCircle.Visible = true
    S.FovCircle.ZIndex = 999
else
    S.FovCircle = nil
end

-- UPDATE FOV
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

RunService.RenderStepped:Connect(function()
    if not S.FovCircle then return end
    if S.FOVMode == "PC" then
        S.FovCircle.Position = UIS:GetMouseLocation()
    else
        local screenSize = Camera.ViewportSize
        S.FovCircle.Position = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
    end
    S.FovCircle.Visible = S.ShowFOV
    S.FovCircle.Radius = S.FovSize
end)

-- ==================== SILENT AIM + EXCLUDE (PASTI JALAN) ====================
local function GetTarget()
    if not lp.Character then return nil, nil end

    local closestPart, closestTarget = nil, nil
    local closestDist2D = S.FovSize + 1

    local fovCenter = (S.FOVMode == "PC") and UIS:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then
            -- ==================== EXCLUDE DI CEK DISINI ====================
            local isExcluded = false
            if _G.ExcludedPlayers and type(_G.ExcludedPlayers) == "table" then
                for i = 1, #_G.ExcludedPlayers do
                    if _G.ExcludedPlayers[i] == plr.Name then
                        isExcluded = true
                        break
                    end
                end
            end
            if isExcluded then
                -- LEWATI
            else
                local char = plr.Character
                if char then
                    local targetPart = char:FindFirstChild(S.SilentAimPart)
                    local hum = char:FindFirstChild("Humanoid")
                    if targetPart and hum and hum.Health > 0 then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local dist2D = (fovCenter - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                            if dist2D < closestDist2D then
                                closestDist2D = dist2D
                                closestPart = targetPart
                                closestTarget = plr
                            end
                        end
                    end
                end
            end
        end
    end
    return closestTarget, closestPart
end

-- HOOK CastBlacklist (PAKAI GetTarget)
local hooked = false
task.spawn(function()
    while not hooked do
        pcall(function()
            local CastBL, CastWL = nil, nil
            for _, v in pairs(getgc(true)) do
                if type(v) == "function" then
                    local info = debug.getinfo(v)
                    if info then
                        if info.name == "CastBlacklist" then CastBL = v
                        elseif info.name == "CastWhitelist" then CastWL = v
                        end
                    end
                end
            end
            
            if CastBL then
                hookfunction(CastBL, function(origin, direction, blacklist)
                    if not S.SilentAim then
                        local params = RaycastParams.new()
                        params.FilterType = Enum.RaycastFilterType.Blacklist
                        params.FilterDescendantsInstances = blacklist or {}
                        return workspace:Raycast(origin, direction, params)
                    end

                    -- ==================== PAKAI GetTarget UNTUK DAPATIN TARGET ====================
                    local target, targetPart = GetTarget()
                    
                    if target and targetPart then
                        local newDir = (targetPart.Position - origin).Unit * (direction.Magnitude or 500)
                        
                        if S.SilentAimWallbang and CastWL then
                            return CastWL(origin, newDir, {target.Character})
                        elseif not S.SilentAimWallbang then
                            local params = RaycastParams.new()
                            params.FilterType = Enum.RaycastFilterType.Blacklist
                            params.FilterDescendantsInstances = blacklist or {}
                            local hit = workspace:Raycast(origin, newDir, params)
                            if hit and hit.Instance and hit.Instance:IsDescendantOf(target.Character) then
                                return hit
                            end
                        end
                    end
                    
                    -- Default
                    local params = RaycastParams.new()
                    params.FilterType = Enum.RaycastFilterType.Blacklist
                    params.FilterDescendantsInstances = blacklist or {}
                    return workspace:Raycast(origin, direction, params)
                end)
                hooked = true
            end
        end)
        task.wait(1)
    end
end)

-- ================================================================
-- NOCLIP SYSTEM (FIXED)
-- ================================================================
do
    S.NoclipEnabled = false
    S.updatemommy = false
    S.resetNoclip = false
    S.noclipConnection = nil
    S.roadsSidewalksFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Roads/Sidewalks")
    S.opp = {}
    
    local function setHiddenProperty(instance, property, value)
        pcall(function() sethiddenproperty(instance, property, value) end)
    end
    
    local function exlusionssf(part)
        return (S.roadsSidewalksFolder and part:IsDescendantOf(S.roadsSidewalksFolder)) or
            (part.Name == "default") or (part.Name == "Sidewalk") or (part.Name == "Floor") or
            (part.Name == "Collision") or (part.Name == "QuaterCylinder") or
            part:IsDescendantOf(LocalPlayer.Character) or
            (part.Parent and part.Parent:IsA("Model") and Players:GetPlayerFromCharacter(part.Parent) ~= nil) or
            (part:IsA("VehicleSeat") or part:IsA("Vehicle"))
    end
    
    S.updatemommy = function()
    local pp = Camera.CFrame.Position
    local radius = 15
    local region = Region3.new(pp - Vector3.new(radius, radius, radius), pp + Vector3.new(radius, radius, radius))
    local parts = workspace:FindPartsInRegion3(region, nil, math.huge)
    for _, part in ipairs(parts) do
        if part:IsA("BasePart") and not exlusionssf(part) then
            if not S.opp[part] then
                S.opp[part] = { CanCollide = part.CanCollide }
                setHiddenProperty(part, "CanCollide", false)
            end
        end
    end
end

S.resetNoclip = function()
    for part, props in pairs(S.opp) do
        if part:IsA("BasePart") then
            setHiddenProperty(part, "CanCollide", props.CanCollide)
        end
    end
    S.opp = {}
end

-- ================================================================
-- FARMING SYSTEM - INVENTORY TRACKER
-- ================================================================
do
    S.AutoMS_Running = false
    S.autoSell_UI = false
    S.asSelling = false
    S.safeMode = false
    S.safeModeActive = false
    S.safeModeTimer = 0
    S.isBusy = false
    S.isRunning = false
    S.lastHealth = 100
    S.fullyRunning = false
    S.fullyTarget = 10
    S.fullySavedPos = Vector3.new(1141.8, 11.041, 450.351)
    S.NPC_MS_POS = Vector3.new(510.061, 4.476, 600.548)
    S.SAFE_POS = Vector3.new(120.854, 4.297, -587.633)
    S.patStats = {small = 0, medium = 0, large = 0}
    S.totalSold = 0
    S.totalBuy = 0
    S.rpcQueue = {}
    S.buyQty = {1, 1, 1}

    local CFG = {
        WATER_WAIT = 20,
        COOK_WAIT = 46,
        ITEM_WATER = "Water",
        ITEM_SUGAR = "Sugar Block Bag",
        ITEM_GEL = "Gelatin",
        ITEM_EMPTY = "Empty Bag",
        ITEM_MS_SMALL = "Small Marshmallow Bag",
        ITEM_MS_MEDIUM = "Medium Marshmallow Bag",
        ITEM_MS_LARGE = "Large Marshmallow Bag",
        SELL_RADIUS = 10
    }
    S.CFG = CFG

    local patRemotes = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
    local storePurchaseRE = patRemotes and patRemotes:WaitForChild("StorePurchase", 10)
    local rpcRE = patRemotes and patRemotes:WaitForChild("RPC", 10)
    S.storePurchaseRE = storePurchaseRE
    

    local BUY_ITEMS = {
        {name = "Gelatin", display = "Gelatin"},
        {name = "Sugar Block Bag", display = "Sugar Block Bag"},
        {name = "Water", display = "Water"},
    }

    local _invCache = {}
    local _invDirty = true

    local function rebuildInvCache()
        local t = {}
        local bp = LocalPlayer.Backpack
        if bp then
            for _, item in ipairs(bp:GetChildren()) do
                local name = item.Name
                if name and name ~= "" then
                    t[name] = (t[name] or 0) + 1
                end
            end
        end
        local char = LocalPlayer.Character
        if char then
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Tool") then
                    local name = item.Name
                    if name and name ~= "" then
                        t[name] = (t[name] or 0) + 1
                    end
                end
            end
        end
        _invCache = t
        _invDirty = false
    end

    local function countItem(itemName)
        if _invDirty then rebuildInvCache() end
        if _invCache[itemName] then
            return _invCache[itemName]
        end
        local lowerTarget = itemName:lower()
        for name, count in pairs(_invCache) do
            if name:lower() == lowerTarget then
                return count
            end
        end
        return 0
    end

    local function hasAllIngredients()
        return countItem(CFG.ITEM_WATER) >= 1 and countItem(CFG.ITEM_SUGAR) >= 1 and countItem(CFG.ITEM_GEL) >= 1
    end

    local function countAllMS()
        return countItem(CFG.ITEM_MS_SMALL) + countItem(CFG.ITEM_MS_MEDIUM) + countItem(CFG.ITEM_MS_LARGE)
    end

    local function getEquippableMS()
        if countItem(CFG.ITEM_MS_SMALL) > 0 then return CFG.ITEM_MS_SMALL end
        if countItem(CFG.ITEM_MS_MEDIUM) > 0 then return CFG.ITEM_MS_MEDIUM end
        if countItem(CFG.ITEM_MS_LARGE) > 0 then return CFG.ITEM_MS_LARGE end
        return nil
    end

    S.countItem = countItem
    S.countAllMS = countAllMS
    S.markInvDirty = function() _invDirty = true end

    task.spawn(function()
        while true do
            task.wait(0.5)
            _invDirty = true
        end
    end)

    LocalPlayer.Backpack.ChildAdded:Connect(function() _invDirty = true end)
    LocalPlayer.Backpack.ChildRemoved:Connect(function() _invDirty = true end)
    LocalPlayer.CharacterAdded:Connect(function(char)
        _invDirty = true
        char.ChildAdded:Connect(function() _invDirty = true end)
        char.ChildRemoved:Connect(function() _invDirty = true end)
    end)
    if LocalPlayer.Character then
        LocalPlayer.Character.ChildAdded:Connect(function() _invDirty = true end)
        LocalPlayer.Character.ChildRemoved:Connect(function() _invDirty = true end)
    end

    local function equipTool(name)
        local ch = LocalPlayer.Character
        if not ch then return false end
        local hum = ch:FindFirstChildOfClass("Humanoid")
        local tool = LocalPlayer.Backpack:FindFirstChild(name)
        if hum and tool then
            hum:EquipTool(tool)
            task.wait(0.2)
            return true
        end
        return false
    end

    local function unequipAll()
        local ch = LocalPlayer.Character
        if not ch then return end
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if hum then hum:UnequipTools() end
    end
    S.unequipAll = unequipAll

    local function firePromptNearby(radius)
        local ch = LocalPlayer.Character
        local root = ch and ch:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local parts = workspace:GetPartBoundsInRadius(root.Position, radius or 8)
        for _, part in ipairs(parts) do
            if part:IsA("BasePart") then
                for _, obj in ipairs(part:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then
                        pcall(function() fireproximityprompt(obj) end)
                    end
                end
            end
        end
    end

    local function cookInteract(toolName, radius)
        if toolName then
            equipTool(toolName)
            task.wait(0.2)
        end
        firePromptNearby(radius or 8)
        task.wait(0.1)
        pcall(function()
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.15)
            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
        task.wait(0.1)
        firePromptNearby(radius or 8)
    end

    if rpcRE then
        rpcRE.OnClientEvent:Connect(function(_, tblArg)
            if type(tblArg) ~= "table" then return end
            local v1 = tblArg[1]
            local v2 = tblArg[2]
            local msg = tostring(v1 or ""):lower()
            if v2 == "TextLabel" and tonumber(v1) then
                table.insert(S.rpcQueue, {type = "timer", secs = tonumber(v1)})
                return
            end
            if msg:find("boil") or msg:find("water") then
                table.insert(S.rpcQueue, {type = "wait_boil"})
            elseif msg:find("sugar") then
                table.insert(S.rpcQueue, {type = "add_sugar"})
            elseif msg:find("gelatin") then
                table.insert(S.rpcQueue, {type = "add_gelatin"})
            elseif msg:find("cook") then
                table.insert(S.rpcQueue, {type = "wait_cook"})
            elseif msg:find("bag") then
                table.insert(S.rpcQueue, {type = "bag_result"})
            end
        end)
    end

    local function waitRPC(instrType, timeout)
        local start = tick()
        while tick() - start < timeout do
            while S.safeModeActive do
                if not S.isRunning then return nil end
                task.wait(0.5)
            end
            if not S.isRunning then return nil end
            for i = 1, #S.rpcQueue do
                local inst = S.rpcQueue[i]
                if inst and inst.type == instrType then
                    table.remove(S.rpcQueue, i)
                    return inst
                end
            end
            task.wait(0.1)
        end
        return nil
    end

    local function popTimer()
        for i = 1, #S.rpcQueue do
            local v = S.rpcQueue[i]
            if v.type == "timer" then
                table.remove(S.rpcQueue, i)
                return v.secs
            end
        end
        return nil
    end

    S._cbStatus = nil
    S._cbPhase = nil
    S._cbTimer = nil
    S._cbSafe = nil
    S._cbSellSt = nil
    S._cbSellIt = nil

    local function setLabel(lbl, text)
        if not lbl then return end
        pcall(function() lbl.Text = text end)
    end

    local function _setStatus(msg)
        if S._cbStatus then setLabel(S._cbStatus, "Status: " .. msg) end
    end
    local function _setPhase(txt)
        if S._cbPhase then setLabel(S._cbPhase, "Phase: " .. txt) end
    end
    local function _setTimer(txt)
        if S._cbTimer then setLabel(S._cbTimer, "Timer: " .. txt) end
    end

    S.setStatusDirect = _setStatus
    S.setPhaseDirect = _setPhase
    S.setTimerDirect = _setTimer
    S.setSafeDirect = function(txt)
        if S._cbSafe then setLabel(S._cbSafe, "Safe Mode: " .. txt) end
    end
    S.setSellStDirect = function(txt)
        if S._cbSellSt then setLabel(S._cbSellSt, "Status: " .. txt) end
    end
    S.setSellItDirect = function(txt)
        if S._cbSellIt then setLabel(S._cbSellIt, "Item: " .. txt) end
    end

    local function countdown(secs, phaseTxt)
        for i = secs, 1, -1 do
            if not S.isRunning then return false end
            while S.safeModeActive do
                if not S.isRunning then return false end
                task.wait(0.5)
            end
            if not S.isRunning then return false end
            _setStatus(phaseTxt)
            _setPhase(phaseTxt)
            _setTimer(i .. "s")
            task.wait(1)
        end
        return true
    end

    local function moveVehicle(vehicle, targetPos)
        local anchor = vehicle.PrimaryPart or vehicle:FindFirstChildOfClass("VehicleSeat") or vehicle:FindFirstChildOfClass("BasePart")
        if not anchor then return end
        local spawnPos = targetPos + Vector3.new(0, 0.5, 0)
        local newCF = CFrame.new(spawnPos, spawnPos + Vector3.new(0, 0, 1))
        for _, p in ipairs(vehicle:GetDescendants()) do
            if p:IsA("BasePart") then
                pcall(function()
                    p.AssemblyLinearVelocity = Vector3.zero
                    p.AssemblyAngularVelocity = Vector3.zero
                    p.Anchored = true
                end)
            end
        end
        task.wait(0.05)
        if vehicle.PrimaryPart then
            vehicle:SetPrimaryPartCFrame(newCF)
        else
            anchor.CFrame = newCF
        end
        task.wait(0.05)
        for _, p in ipairs(vehicle:GetDescendants()) do
            if p:IsA("BasePart") then
                pcall(function()
                    p.Anchored = false
                    p.AssemblyLinearVelocity = Vector3.zero
                    p.AssemblyAngularVelocity = Vector3.zero
                end)
            end
        end
    end

    local function fullyTeleport(targetPos)
        local ch = LocalPlayer.Character
        local hum = ch and ch:FindFirstChildOfClass("Humanoid")
        if not ch or not hum then
            task.wait(1)
            return
        end
        local seatPart = humeatPart
        if seatPart then
            local vehicle = seatPart:FindFirstAncestorOfClass("Model")
            if vehicle then
                moveVehicle(vehicle, targetPos)
                task.wait(0.8)
                local hrp = ch:FindFirstChild("HumanoidRootPart")
                if hrp then
                    pcall(function()
                        hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 1, 0), targetPos + Vector3.new(0, 1, 1))
                    end)
                end
            end
        else
            local hrp = ch:FindFirstChild("HumanoidRootPart")
            if hrp then
                pcall(function()
                    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 1, 0), targetPos + Vector3.new(0, 1, 1))
                end)
            end
            task.wait(0.8)
        end
    end
    S.fullyTeleport = fullyTeleport

    RunService.Heartbeat:Connect(function(dt)
        if not S.safeMode then
            S.safeModeActive = false
            S.safeModeTimer = 0
            return
        end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum.Health < S.lastHealth and S.lastHealth > 0 then
                S.safeModeActive = true
                S.safeModeTimer = 0
                S.setSafeDirect("ACTIVE")
                task.spawn(function() pcall(fullyTeleport, S.SAFE_POS) end)
            end
            S.lastHealth = hum.Health
        end
        if S.safeModeActive then
            S.safeModeTimer = S.safeModeTimer + dt
            if S.safeModeTimer > 10 then
                S.safeModeActive = false
                S.safeModeTimer = 0
                S.setSafeDirect("STANDBY")
                if S.fullySavedPos then
                    task.spawn(function() pcall(fullyTeleport, S.fullySavedPos) end)
                end
            end
        end
    end)

    local function isNearNPC(radius)
        local ch = LocalPlayer.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        return (hrp.Position - S.NPC_MS_POS).Magnitude <= (radius or CFG.SELL_RADIUS + 5)
    end

    local function waitCharStable(timeout)
        local ch = LocalPlayer.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if not hrp then
            task.wait(1)
            return
        end
        local deadline = tick() + (timeout or 2.5)
        local lastPos = hrp.Position
        repeat
            task.wait(0.25)
            local delta = (hrp.Position - lastPos).Magnitude
            lastPos = hrp.Position
            if delta < 0.5 then return end
        until tick() >= deadline
    end

    local function equipRetry(name, maxR)
        for _ = 1, (maxR or 5) do
            local ok = equipTool(name)
            if ok then
                task.wait(0.3)
                local ch = LocalPlayer.Character
                if ch then
                    for _, t in ipairs(ch:GetChildren()) do
                        if t:IsA("Tool") and t.Name == name then
                            return true
                        end
                    end
                end
            end
            task.wait(0.4)
        end
        return false
    end

    local SELL_HOLD = 1.8
    local SELL_RETRIES = 5

    local function trySellOne(msName, setSt)
        local bS = countItem(CFG.ITEM_MS_SMALL)
        local bM = countItem(CFG.ITEM_MS_MEDIUM)
        local bL = countItem(CFG.ITEM_MS_LARGE)
        setSt("Equip: " .. msName .. "...")
        if not equipRetry(msName, 4) then
            setSt("Failed to equip " .. msName)
            unequipAll()
            task.wait(0.4)
            return false
        end
        task.wait(0.5)
        local sold = false
        for attempt = 1, SELL_RETRIES do
            setSt("Selling: Hold E (" .. attempt .. "/" .. SELL_RETRIES .. ")...")
            firePromptNearby(CFG.SELL_RADIUS + 5)
            task.wait(0.1)
            pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game) end)
            local holdE = 0
            while holdE < SELL_HOLD do
                task.wait(0.1)
                holdE = holdE + 0.1
                _invDirty = true
                local diff = (bS - countItem(CFG.ITEM_MS_SMALL)) + (bM - countItem(CFG.ITEM_MS_MEDIUM)) + (bL - countItem(CFG.ITEM_MS_LARGE))
                if diff > 0 then
                    pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game) end)
                    S.totalSold = S.totalSold + diff
                    sold = true
                    break
                end
            end
            pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game) end)
            if sold then break end
            task.wait(0.3)
            _invDirty = true
            local diff2 = (bS - countItem(CFG.ITEM_MS_SMALL)) + (bM - countItem(CFG.ITEM_MS_MEDIUM)) + (bL - countItem(CFG.ITEM_MS_LARGE))
            if diff2 > 0 then
                S.totalSold = S.totalSold + diff2
                sold = true
                break
            end
            task.wait(0.4)
        end
        unequipAll()
        task.wait(0.3)
        return sold
    end

    local function doAutoSell(setSt)
        local msT = countAllMS()
        if msT == 0 then
            setSt("No MS found")
            task.wait(0.8)
            return
        end
        setSt("Detected " .. msT .. " MS...")
        task.wait(0.4)
        waitCharStable(2.5)
        if not isNearNPC(CFG.SELL_RADIUS + 8) then
            setSt("Teleporting to NPC...")
            fullyTeleport(S.NPC_MS_POS)
            task.wait(1.2)
            waitCharStable(2)
        end
        local sold = 0
        local maxFail = 6
        local fail = 0
        local tpR = 0
        while countAllMS() > 0 do
            local msN = getEquippableMS()
            if not msN then break end
            if not isNearNPC(CFG.SELL_RADIUS + 8) and tpR < 2 then
                tpR = tpR + 1
                fullyTeleport(S.NPC_MS_POS)
                task.wait(1.2)
                waitCharStable(2)
            else
                local ok = trySellOne(msN, setSt)
                if ok then
                    sold = sold + 1
                    fail = 0
                    tpR = 0
                    task.wait(0.35)
                else
                    fail = fail + 1
                    if fail >= 2 and fail % 2 == 0 then
                        unequipAll()
                        task.wait(0.3)
                        fullyTeleport(S.NPC_MS_POS)
                        task.wait(1.2)
                        waitCharStable(2)
                    end
                    if fail >= maxFail then break end
                    task.wait(0.8)
                end
            end
        end
        unequipAll()
        if sold > 0 then
            setSt("Sell complete! " .. sold .. " MS | Total: " .. S.totalSold)
        else
            setSt("No MS sold.")
        end
        task.wait(1)
    end
    S.doAutoSell = doAutoSell

    local function doAutoBuy(setSt, overrideQty)
        if not storePurchaseRE then
            pcall(function()
                local rs = ReplicatedStorage
                local re = rs:WaitForChild("RemoteEvents", 8)
                if re then
                    storePurchaseRE = re:WaitForChild("StorePurchase", 8)
                    S.storePurchaseRE = storePurchaseRE
                end
            end)
        end
        if not storePurchaseRE then
            setSt("Remote not found!")
            task.wait(1.5)
            return
        end
        local totalB = 0
        for idx, item in ipairs(BUY_ITEMS) do
            local qty = overrideQty or S.buyQty[idx] or 1
            setSt("Buying " .. item.display .. " x" .. qty .. "...")
            local before = countItem(item.name)
            for _ = 1, qty do
                pcall(function() storePurchaseRE:FireServer(item.name, 1) end)
                task.wait(0.4)
            end
            local timeout = 0
            local gained = 0
            repeat
                task.wait(0.2)
                timeout = timeout + 0.2
                _invDirty = true
                gained = countItem(item.name) - before
            until gained >= qty or timeout > 6
            totalB = totalB + gained
            S.totalBuy = S.totalBuy + gained
            setSt(item.display .. " x" .. gained .. " done!")
            task.wait(0.2)
        end
        setSt("Buy complete! " .. totalB .. " items.")
        task.wait(1)
    end
    S.doAutoBuy = doAutoBuy

    local function doOneCook()
        S.isBusy = true
        for k in pairs(S.rpcQueue) do S.rpcQueue[k] = nil end
        local snapS = countItem(CFG.ITEM_MS_SMALL)
        local snapM = countItem(CFG.ITEM_MS_MEDIUM)
        local snapL = countItem(CFG.ITEM_MS_LARGE)
        _setStatus("Adding Water...")
        _setPhase("Adding Water...")
        cookInteract(CFG.ITEM_WATER)
        local boilSecs
        for _ = 1, 30 do
            boilSecs = popTimer()
            if boilSecs then break end
            task.wait(0.1)
        end
        boilSecs = boilSecs or CFG.WATER_WAIT
        if not countdown(boilSecs, "Boiling...") then
            S.isBusy = false
            return false
        end
        _setStatus("Waiting for Sugar...")
        _setPhase("Waiting for Sugar...")
        waitRPC("add_sugar", 10)
        if not S.isRunning then
            S.isBusy = false
            return false
        end
        _setStatus("Adding Sugar...")
        _setPhase("Adding Sugar...")
        cookInteract(CFG.ITEM_SUGAR)
        task.wait(0.3)
        _setStatus("Waiting for Gelatin...")
        _setPhase("Waiting for Gelatin...")
        waitRPC("add_gelatin", 10)
        if not S.isRunning then
            S.isBusy = false
            return false
        end
        _setStatus("Adding Gelatin...")
        _setPhase("Adding Gelatin...")
        cookInteract(CFG.ITEM_GEL)
        task.wait(0.3)
        local cookSecs
        for _ = 1, 30 do
            cookSecs = popTimer()
            if cookSecs then break end
            task.wait(0.1)
        end
        cookSecs = cookSecs or CFG.COOK_WAIT
        if not countdown(cookSecs, "Cooking...") then
            S.isBusy = false
            return false
        end
        _setStatus("Waiting for Bag...")
        _setPhase("Waiting for Bag...")
        waitRPC("bag_result", 12)
        local bag
        local t2 = 0
        repeat
            bag = LocalPlayer.Backpack:FindFirstChild(CFG.ITEM_EMPTY)
            task.wait(0.3)
            t2 = t2 + 0.3
        until bag or t2 > 10
        if not bag then
            _setStatus("No Empty Bag!")
            S.isBusy = false
            return false
        end
        _setPhase("Taking MS...")
        cookInteract(CFG.ITEM_EMPTY)
        local waitMS = 0
        local newS, newM, newL
        repeat
            task.wait(0.3)
            waitMS = waitMS + 0.3
            _invDirty = true
            newS = countItem(CFG.ITEM_MS_SMALL) - snapS
            newM = countItem(CFG.ITEM_MS_MEDIUM) - snapM
            newL = countItem(CFG.ITEM_MS_LARGE) - snapL
        until (newS > 0 or newM > 0 or newL > 0) or waitMS > 8
        if newS > 0 then
            S.patStats.small = S.patStats.small + newS
        elseif newM > 0 then
            S.patStats.medium = S.patStats.medium + newM
        elseif newL > 0 then
            S.patStats.large = S.patStats.large + newL
        else
            S.patStats.small = S.patStats.small + 1
        end
        _setPhase("Complete #" .. (S.patStats.small + S.patStats.medium + S.patStats.large))
        _setTimer("Done")
        S.isBusy = false
        return true
    end

    local function autoMSLoop()
        S.isRunning = true
        while S.isRunning do
            if not hasAllIngredients() then
                _setStatus("OUT OF INGREDIENTS!")
                S.isRunning = false
                break
            end
            local ok, err = pcall(doOneCook)
            if not ok then
                _setStatus("ERROR: " .. tostring(err))
                task.wait(2)
            end
            if S.isRunning then task.wait(0.3) end
        end
        S.isRunning = false
        S.AutoMS_Running = false
        _setStatus("OFF")
        _setPhase("Water")
        _setTimer("0s")
        S.isBusy = false
    end
    S.autoMSLoop = autoMSLoop

    local function doAutoFully(setFS)
        S.fullyRunning = true
        local anchorConn = RunService.Heartbeat:Connect(function()
            if not S.fullyRunning then return end
            local ch = LocalPlayer.Character
            local hm = ch and ch:FindFirstChildOfClass("Humanoid")
            local sp = hm and hm.SeatPart
            if sp then
                local veh = sp:FindFirstAncestorOfClass("Model")
                if veh then
                    for _, p in ipairs(veh:GetDescendants()) do
                        if p:IsA("BasePart") then
                            pcall(function()
                                p.AssemblyLinearVelocity = Vector3.zero
                                p.AssemblyAngularVelocity = Vector3.zero
                            end)
                        end
                    end
                end
            end
        end)
        while S.fullyRunning do
            local target = S.fullyTarget
            setFS("Teleporting to NPC...")
            fullyTeleport(S.NPC_MS_POS)
            if not S.fullyRunning then break end
            setFS("Buying ingredients for " .. target .. " MS...")
            doAutoBuy(setFS, target)
            if not S.fullyRunning then break end
            task.wait(0.5)
            if S.fullySavedPos then
                setFS("Teleporting to Apartment...")
                fullyTeleport(S.fullySavedPos)
            end
            if not S.fullyRunning then break end
            task.wait(1.5)
            unequipAll()
            for k in pairs(S.rpcQueue) do S.rpcQueue[k] = nil end
            setFS("Cooking " .. target .. " MS...")
            S.isRunning = true
            while S.fullyRunning and hasAllIngredients() do
                doOneCook()
                if S.fullyRunning then task.wait(0.3) end
            end
            S.isRunning = false
            if not S.fullyRunning then break end
            if countAllMS() > 0 then
                unequipAll()
                task.wait(0.3)
                setFS("Teleporting to sell...")
                fullyTeleport(S.NPC_MS_POS)
                task.wait(1.8)
                if not S.fullyRunning then break end
                setFS("Selling all...")
                doAutoSell(setFS)
                if not S.fullyRunning then break end
            end
            task.wait(0.4)
        end
        S.fullyRunning = false
        S.isRunning = false
        S.AutoMS_Running = false
        anchorConn:Disconnect()
    end
    S.doAutoFully = doAutoFully

    task.spawn(function()
        while true do
            task.wait(0.4)
            if not S.autoSell_UI or S.asSelling then
                -- skip
            else
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if char and hum and hrp and hum.Health > 0 then
                    if countAllMS() == 0 then
                        S.setSellItDirect("-")
                        S.setSellStDirect("WAITING")
                    else
                        S.asSelling = true
                        S.setSellStDirect("SELLING...")
                        doAutoSell(function(msg)
                            S.setSellStDirect(msg)
                            S.setSellItDirect(msg)
                        end)
                        S.asSelling = false
                    end
                end
            end
        end
    end)
end

repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")


-- ================================================================
-- GUI SETUP
-- ================================================================
do
    local Library = nil
    local okL, errL = pcall(function()
        Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/sametexe001/sametlibs/refs/heads/main/Mentality/Library.lua"))()
    end)
    if not okL or not Library then
        warn("FAILED TO LOAD LIBRARY: " .. tostring(errL))
        return
    end

    S.KeybindList = Library:KeybindList("Phantom keybind")
    S.Window = Library:Window({Name = "Phantom.wtf", SubName = "v1.0.0", Logo = "108284603654233"})
    S.Library = Library

    local function setLabel(lbl, text)
        if not lbl then return end
        pcall(function() lbl.Text = text end)
    end

    -- ================== FARMING ==================
    S.Window:Category("Farming")
    local pageAutoMS = S.Window:Page({Name = "Auto Cook", Icon = "103180437044643"})
    local pageAutoFully = S.Window:Page({Name = "Auto Fully", Icon = "108839695397679"})

    local secStatus = pageAutoMS:Section({Name = "Cooking Status", Side = 1})
    local statusLbl = secStatus:Label("Status: OFF")
    local phaseLbl = secStatus:Label("Phase: Water")
    local timerLbl = secStatus:Label("Timer: 0s")
    S._cbStatus = statusLbl
    S._cbPhase = phaseLbl
    S._cbTimer = timerLbl

    local secCook = pageAutoMS:Section({Name = "Cooking Control", Side = 2})
    secCook:Button({Name = "START Cooking", Callback = function()
        if not S.isRunning then
            S.isRunning = true
            S.setStatusDirect("STARTING")
            task.spawn(S.autoMSLoop)
        end
    end})
    secCook:Button({Name = "STOP Cooking", Callback = function()
        S.isRunning = false
        S.AutoMS_Running = false
        S.setStatusDirect("OFF")
        S.setPhaseDirect("Water")
        S.setTimerDirect("0s")
    end})

    local secInv = pageAutoMS:Section({Name = "Inventory", Side = 1})
    local waterLbl = secInv:Label("Water: 0")
    local gelLbl = secInv:Label("Gelatin: 0")
    local sugLbl = secInv:Label("Sugar Block Bag: 0")
    local bagLbl = secInv:Label("Empty Bag: 0")
    local msSmallLbl = secInv:Label("Small Marshmallow: 0")
    local msMediumLbl = secInv:Label("Medium Marshmallow: 0")
    local msLargeLbl = secInv:Label("Large Marshmallow: 0")

    task.spawn(function()
        while true do
            task.wait(1)
            S.markInvDirty()
            pcall(function()
                setLabel(waterLbl, "Water: " .. S.countItem("Water"))
                setLabel(gelLbl, "Gelatin: " .. S.countItem("Gelatin"))
                setLabel(sugLbl, "Sugar Block Bag: " .. S.countItem("Sugar Block Bag"))
                setLabel(bagLbl, "Empty Bag: " .. S.countItem("Empty Bag"))
                setLabel(msSmallLbl, "Small Marshmallow: " .. S.countItem("Small Marshmallow Bag"))
                setLabel(msMediumLbl, "Medium Marshmallow: " .. S.countItem("Medium Marshmallow Bag"))
                setLabel(msLargeLbl, "Large Marshmallow: " .. S.countItem("Large Marshmallow Bag"))
            end)
        end
    end)

    -- ================== SELL/BUY MERGED INTO AUTO COOK ==================
    local secAutoSell = pageAutoMS:Section({Name = "Auto Sell", Side = 1})
    local sellStatLbl = secAutoSell:Label("Status: OFF")
    local sellItemEl = secAutoSell:Label("Item: -")
    S._cbSellSt = sellStatLbl
    S._cbSellIt = sellItemEl
    secAutoSell:Toggle({Name = "Auto Sell", Default = false, Flag = "AutoSellToggle",
        Callback = function(v)
            S.autoSell_UI = v
            if not v then
                S.asSelling = false
                S.setSellStDirect("OFF")
                S.setSellItDirect("-")
            else
                S.setSellStDirect("ON")
            end
        end})
    secAutoSell:Button({Name = "Sell Now", Callback = function()
        task.spawn(function()
            S.doAutoSell(function(msg)
                S.setSellStDirect(msg)
                S.setSellItDirect(msg)
            end)
        end)
    end})

    -- Buy
    local secBuy = pageAutoMS:Section({Name = "Buy Ingredients", Side = 2})
    local buyW = 1
    local buyG = 1
    local buySu = 1
    secBuy:Slider({Name = "Water", Min = 0, Max = 50, Default = 1, Suffix = " x", Callback = function(v) buyW = v end})
    secBuy:Slider({Name = "Gelatin", Min = 0, Max = 50, Default = 1, Suffix = " x", Callback = function(v) buyG = v end})
    secBuy:Slider({Name = "Sugar Block Bag", Min = 0, Max = 50, Default = 1, Suffix = " x", Callback = function(v) buySu = v end})
    secBuy:Button({Name = "Buy Now", Callback = function()
        task.spawn(function()
            S.buyQty[1] = buyG
            S.buyQty[2] = buySu
            S.buyQty[3] = buyW
            S.doAutoBuy(function(msg) setLabel(sellStatLbl, msg) end)
        end)
    end})

    -- Auto Fully
    local secFullyStat = pageAutoFully:Section({Name = "Status", Side = 1})
    local _fullyStatLbl = secFullyStat:Label("Not started")
    local secFullyCtrl = pageAutoFully:Section({Name = "Control", Side = 1})
    local afApartList = {
        {name = "Apart 1", x = 1141.8, y = 11.041, z = 450.351},
        {name = "Apart 2", x = 1142.488, y = 11.038, z = 421.638},
        {name = "Apart 3", x = 984.088, y = 11.029, z = 248.808},
        {name = "Apart 4", x = 984.094, y = 11.064, z = 220.291},
        {name = "Apart 5", x = 925.531, y = 11.016, z = 39.366},
        {name = "Apart 6", x = 896.86, y = 11.042, z = 38.65}
    }
    local apartNames = {}
    for _, a in ipairs(afApartList) do
        table.insert(apartNames, a.name)
    end
    secFullyCtrl:Dropdown({Name = "Apartment Destination", Items = apartNames, Default = "Apart 1", Flag = "FullyApart",
        Callback = function(val)
            for _, a in ipairs(afApartList) do
                if a.name == val then
                    S.fullySavedPos = Vector3.new(a.x, a.y, a.z)
                    break
                end
            end
        end})
    secFullyCtrl:Slider({Name = "Target MS/Loop", Min = 1, Max = 50, Default = 10, Flag = "FullyTarget", Suffix = " MS",
        Callback = function(v) S.fullyTarget = v end})
    secFullyCtrl:Button({Name = "START Auto Fully", Callback = function()
        if S.fullyRunning then return end
        local ch = LocalPlayer.Character
        local h = ch and ch:FindFirstChildOfClass("Humanoid")
        if h then S.lastHealth = h.Health end
        setLabel(_fullyStatLbl, "Running...")
        task.spawn(function()
            S.doAutoFully(function(msg) setLabel(_fullyStatLbl, msg) end)
            setLabel(_fullyStatLbl, "Stopped")
        end)
    end})
    secFullyCtrl:Button({Name = "STOP Auto Fully", Callback = function()
        S.fullyRunning = false
        S.isRunning = false
        S.AutoMS_Running = false
        S.safeModeActive = false
        setLabel(_fullyStatLbl, "Stopped")
    end})

    -- Safe Mode
    local secSafeMode = pageAutoFully:Section({Name = "Safe Mode", Side = 2})
    local safeLblEl = secSafeMode:Label("Safe Mode: OFF")
    S._cbSafe = safeLblEl
    secSafeMode:Toggle({Name = "Enable Safe Mode", Default = false, Flag = "SafeMode",
        Callback = function(v)
            S.safeMode = v
            if v then
                local ch = LocalPlayer.Character
                local h = ch and ch:FindFirstChildOfClass("Humanoid")
                if h then S.lastHealth = h.Health end
                S.setSafeDirect("STANDBY")
            else
                S.safeModeActive = false
                S.setSafeDirect("OFF")
            end
        end})

    -- ================== MISC CATEGORY (PLAYER + GUN MOD MERGED) ==================
    S.Window:Category("Misc")
    local pageMisc = S.Window:Page({Name = "Misc", Icon = "133097769079819"})

    -- ===== PLAYER PAGE CONTENT =====
    local secInstant = pageMisc:Section({Name = "Instant Interact", Side = 1})
    secInstant:Label("Interact NPC without holding button")
    secInstant:Toggle({Name = "Enable Instant Interact", Default = false, Flag = "InstantInteract",
        Callback = function(v)
            if v then
                startInstantInteract()
            else
                stopInstantInteract()
            end
        end
    })

    --- inf stam
    S.staminaHooked = false
    S.heartbeatConnection = nil

    local secINFSTAM = pageMisc:Section({Name = "Infinite Stamina", Side = 1})
    secINFSTAM:Toggle({Name = "Enable Infinite Stamina", Default = false, Flag = "InfiniteStamina",
    Callback = function(v)
            if v and not S.staminaHooked then
        for _, gc in pairs(getgc(true)) do
            if type(gc) == "table" then
                for k, _ in pairs(gc) do
                    if k == "Stamina" then
                        local mt = getmetatable(gc)
                        if mt then
                            pcall(function()
                                setreadonly(mt, false)
                                local oi = mt.__index
                                mt.__index = function(t, k2)
                                    if k2 == "Stamina" then return 100 end
                                    return oi and oi(t, k2)
                                end
                            end)
                            S.staminaHooked = true
                            S.heartbeatConnection = RunService.Heartbeat:Connect(function()
                                if v then pcall(function() gc.Stamina = 100 end) end
                            end)
                            break
                        end
                    end
                end
            end
            if S.staminaHooked then break end
        end
    elseif not v and S.heartbeatConnection then
        S.heartbeatConnection:Disconnect()
        S.heartbeatConnection = nil
    end
end})

    -- Blink Teleport
    local secBlink = pageMisc:Section({Name = "Blink Teleport", Side = 2})
    S.blinkEnabled = false
    S.TweenService = game:GetService("TweenService")

    secBlink:Toggle({Name = "Enable Blink Teleport (T)", Default = false, Flag = "BlinkTP",
        Callback = function(v)
            S.blinkEnabled = v
        end
    })

    UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode.T and S.blinkEnabled then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = root.CFrame + (root.CFrame.LookVector * 6)
            end
        end
    end)

    local secInvisible = pageMisc:Section({Name = "Invisible (Underground)", Side = 1})
    local invisibleActive = false
    local danceTrack = nil
    local heartbeatConn = nil
    local renderConn = nil
    local originalCF = nil
    local originalVel = nil

    local animation = Instance.new("Animation")
    animation.AnimationId = "http://www.roblox.com/asset/?id=10147821284"

    local function startInvisible()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if not hum then return end
        
        danceTrack = hum:LoadAnimation(animation)
        danceTrack.Looped = true
        danceTrack:Play()
        
        heartbeatConn = RunService.Heartbeat:Connect(function()
            if not invisibleActive then return end
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            originalCF = hrp.CFrame
            originalVel = hrp.AssemblyLinearVelocity
            
            local newCF = originalCF + Vector3.new(0, -6.5, 0)
            hrp.CFrame = newCF * CFrame.Angles(0, 0, math.pi)
            
            renderConn = RunService.RenderStepped:Connect(function()
                if not invisibleActive then return end
                if hrp and hrp.Parent then
                    hrp.CFrame = originalCF
                    hrp.AssemblyLinearVelocity = originalVel
                end
                renderConn:Disconnect()
                renderConn = nil
            end)
        end)
    end

    local function stopInvisible()
        invisibleActive = false
        
        if danceTrack then
            danceTrack:Stop()
            danceTrack:Destroy()
            danceTrack = nil
        end
        
        if heartbeatConn then
            heartbeatConn:Disconnect()
            heartbeatConn = nil
        end
        if renderConn then
            renderConn:Disconnect()
            renderConn = nil
        end
        
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and originalCF then
            hrp.CFrame = originalCF
            hrp.AssemblyLinearVelocity = originalVel or Vector3.zero
        end
    end

    secInvisible:Toggle({Name = "Enable Invisible (Underground)", Default = false,
        callback = function(state)
            if state then
                invisibleActive = true
                startInvisible()
            else
                stopInvisible()
            end
        end
    })

    local secINFZOOM = pageMisc:Section({Name = "Infinite Zoom", Side = 2})
    secINFZOOM:Toggle({Name = "Enable Infinite Zoom", Default = false, Flag = "InfZoomToggle",
        Callback = function(state)
            local player = game:GetService("Players").LocalPlayer
            if state then
                player.CameraMaxZoomDistance = math.huge
                player.CameraMinZoomDistance = 0.5
            else
                player.CameraMaxZoomDistance = 20
                player.CameraMinZoomDistance = 0.5
            end
        end
    })

    -- ==================== FLY (HOLD V) ====================
    local secFly = pageMisc:Section({Name = "Fly (Hold V)", Side = 2})
    local flyEnabled = false
    local flySpeed = 15
    local flyConnection = nil
    local isFlying = false

    local function startFly()
        isFlying = true
    end
    local function stopFly()
        isFlying = false
    end

    secFly:Toggle({Name = "Enable Fly (Hold V)", Default = false, Flag = "FlyToggle",
        Callback = function(state)
            flyEnabled = state
            if flyEnabled then
                if not flyConnection then
                    local inputBeganConn = UserInputService.InputBegan:Connect(function(input, gp)
                        if gp then return end
                        if flyEnabled and input.KeyCode == Enum.KeyCode.V then
                            startFly()
                        end
                    end)
                    local inputEndedConn = UserInputService.InputEnded:Connect(function(input)
                        if flyEnabled and input.KeyCode == Enum.KeyCode.V then
                            stopFly()
                        end
                    end)
                    flyConnection = {inputBeganConn, inputEndedConn}
                end
            else
                isFlying = false
                if flyConnection then
                    for _, conn in ipairs(flyConnection) do
                        conn:Disconnect()
                    end
                    flyConnection = nil
                end
            end
        end
    })

    secFly:Slider({Name = "Fly Speed", Min = 10, Max = 100, Default = 15, Suffix = " studs/s",
        Callback = function(v)
            flySpeed = v
        end
    })

    local renderStepConn = RunService.RenderStepped:Connect(function()
        if flyEnabled and isFlying then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, flySpeed, hrp.Velocity.Z)
            end
        end
    end)

    task.spawn(function()
        while renderStepConn and renderStepConn.Connected do
            task.wait(1)
        end
    end)

    S.walkspeedEnabled = false
    S.currentWalkspeed = 13

    local secWalk = pageMisc:Section({Name = "Walk Speed", Side = 2})
    secWalk:Toggle({Name = "Enable Walk Speed", Default = false, Flag = "WalkspeedToggle",
        def = false,
        Callback = function(state)
        S.walkspeedEnabled = state
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = state and S.currentWalkspeed or 13 end
    end})
    secWalk:Slider({Name = "Speed", Min = 13, Max = 23, Default = 13, Suffix = " Walk Speed", Flag = "WalkspeedSlider",
        callback = function(value)
        S.currentWalkspeed = value
        if S.walkspeedEnabled then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = value end
        end
    end
    })

    local secSilentAim = pageMisc:Section({Name = "Silent Aim Settings", Side = 1})
    secSilentAim:Toggle({Name = "Enable Silent Aim", Default = false, Flag = "SAEnabled",
        Callback = function(v)
            S.SilentAim = v
            print("Silent Aim: " .. (v and "ON" or "OFF"))
        end
    })
    secSilentAim:Dropdown({Name = "Target Part", Items = {"Head", "HumanoidRootPart"}, Default = "HumanoidRootPart",
        Callback = function(v)
            S.SilentAimPart = v
        end
    })
    secSilentAim:Slider({Name = "FOV Size", Min = 50, Max = 500, Default = 250, Suffix = " px",
        Callback = function(v)
            S.FovSize = v
            if S.FovCircle then
                S.FovCircle.Radius = v
            end
        end
    })
    secSilentAim:Toggle({Name = "Wallbang", Default = true, Flag = "SAWallbang",
        Callback = function(v)
            S.SilentAimWallbang = v
        end
    })
    secSilentAim:Dropdown({Name = "FOV Mode", Items = {"PC", "Mobile"}, Default = "PC",
        Callback = function(v)
            S.FOVMode = v
        end
    })
    secSilentAim:Toggle({Name = "Show FOV Circle", Default = true, Flag = "SAShowFOV",
        Callback = function(v)
            S.ShowFOV = v
        end
    })
    local fovColorLbl = secSilentAim:Label("FOV Circle Color")
    fovColorLbl:Colorpicker({Name = "Color", Default = Color3.fromRGB(255, 0, 0),
        Callback = function(v)
            if S.FovCircle then
                S.FovCircle.Color = v
            end
        end
    })

    -- noclip
    S.NoclipEnabled = false
    local noclipConnection = nil
    local secNoclip = pageMisc:Section({Name = "Noclip", Side = 2})
    secNoclip:Toggle({Name = "Enable Noclip", Default = false, Flag = "NoclipToggle",
        Callback = function(v)
            S.NoclipEnabled = v
            if v then
                if noclipConnection then noclipConnection:Disconnect() end
                noclipConnection = RunService.Heartbeat:Connect(function()
                    if S.NoclipEnabled then
                        S.updatemommy()
                    end
                end)
            else
                if noclipConnection then
                    noclipConnection:Disconnect()
                    noclipConnection = nil
                end
                S.resetNoclip()
            end
        end
    })

    -- Player Teleport
    local tpDestination = nil
    local tpPending = false

    local function onCharAdded(char)
        if not tpPending or not tpDestination then return end
        tpPending = false
        task.spawn(function()
            local hrp = char:WaitForChild("HumanoidRootPart", 10)
            if not hrp then return end
            task.wait(1)
            hrp.CFrame = CFrame.new(tpDestination.x, tpDestination.y + 3, tpDestination.z)
            tpDestination = nil
        end)
    end
    if LocalPlayer.Character then
        task.spawn(onCharAdded, LocalPlayer.Character)
    end
    LocalPlayer.CharacterAdded:Connect(onCharAdded)

    local function playerTpTo(x, y, z)
        local ch = LocalPlayer.Character
        local h = ch and ch:FindFirstChildOfClass("Humanoid")
        tpDestination = {x = x, y = y, z = z}
        tpPending = true
        if ch and h and h.Health > 0 then
            h.Health = 0
        end
    end
    S.playerTpTo = playerTpTo

    S.playerSavedCoords = nil

    local secPlayerCoords = pageMisc:Section({Name = "Saved Position (Player)", Side = 1})
    local playerCoordLbl = secPlayerCoords:Label("Saved: Not saved")

    local function updatePlayerCoordLbl()
        if S.playerSavedCoords then
            setLabel(playerCoordLbl, string.format("Saved: %.1f, %.1f, %.1f",
                S.playerSavedCoords.X, S.playerSavedCoords.Y, S.playerSavedCoords.Z))
        else
            setLabel(playerCoordLbl, "Saved: Not saved")
        end
    end

    secPlayerCoords:Button({Name = "Save Player Position", Callback = function()
        local ch = LocalPlayer.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if hrp then
            S.playerSavedCoords = hrp.Position
            updatePlayerCoordLbl()
        end
    end})
    secPlayerCoords:Button({Name = "TP to Saved Position", Callback = function()
        if not S.playerSavedCoords then return end
        playerTpTo(S.playerSavedCoords.X, S.playerSavedCoords.Y, S.playerSavedCoords.Z)
    end})
    secPlayerCoords:Button({Name = "Delete Position", Callback = function()
        S.playerSavedCoords = nil
        updatePlayerCoordLbl()
    end})

    local tpLocs = {
        {name = "Dealership", x = 732.117, y = 3.362, z = 406.08},
        {name = "Sell/Buy MS", x = 510.996, y = 3.587, z = 598.392},
        {name = "Tier", x = 1094.74, y = 3.188, z = 158.092},
        {name = "Casino", x = 1154.863, y = 4.289, z = -46.848},
        {name = "Sell Casino", x = 1017.581, y = 4.545, z = -321.792},
        {name = "GS Ujung", x = -464.548, y = 3.737, z = 335.315},
        {name = "GS Mid", x = 218.748, y = 3.729, z = -161.87},
        {name = "Apart 1", x = 1141.8, y = 11.041, z = 450.351},
        {name = "Apart 2", x = 1142.488, y = 11.038, z = 421.638},
        {name = "Apart 3", x = 984.088, y = 11.029, z = 248.808},
        {name = "Apart 4", x = 984.094, y = 11.064, z = 220.291},
        {name = "Apart 5", x = 925.531, y = 11.016, z = 39.366},
        {name = "Apart 6", x = 896.86, y = 11.042, z = 38.65}
    }
    local tpNames = {}
    for _, l in ipairs(tpLocs) do
        table.insert(tpNames, l.name)
    end
    local selTPIdx = 1
    local secTP = pageMisc:Section({Name = "Location", Side = 1})
    secTP:Dropdown({Name = "Location", Items = tpNames, Default = tpNames[1],
        Callback = function(val)
            for i, l in ipairs(tpLocs) do
                if l.name == val then
                    selTPIdx = i
                    break
                end
            end
        end})
    secTP:Button({Name = "Teleport!", Callback = function()
        local l = tpLocs[selTPIdx]
        if l then playerTpTo(l.x, l.y, l.z) end
    end})

    -- TP to Player
    local secTPP = pageMisc:Section({Name = "TP to Player", Side = 2})
    local plNames = {}
    local selTPP = nil

    local function updPl()
        plNames = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Name and p.Name ~= "" then
                table.insert(plNames, p.Name)
            end
        end
    end
    updPl()

    local plDD = secTPP:Dropdown({Name = "Player", Items = plNames, Default = plNames[1] or "-",
        Callback = function(v) selTPP = v end})

    Players.PlayerAdded:Connect(function(plr)
        task.spawn(function()
            local waited = 0
            while waited < 5 do
                task.wait(0.5)
                waited = waited + 0.5
                if plr and plr.Parent and plr.Name ~= "" then
                    updPl()
                    pcall(function() plDD.Items = plNames end)
                    return
                end
            end
        end)
    end)
    Players.PlayerRemoving:Connect(function()
        task.spawn(function()
            task.wait(0.1)
            updPl()
            pcall(function() plDD.Items = plNames end)
        end)
    end)

    secTPP:Button({Name = "Refresh", Callback = function()
        updPl()
        pcall(function() plDD.Items = plNames end)
        if #plNames > 0 then
            selTPP = plNames[1]
        else
            selTPP = nil
        end
    end})
    secTPP:Button({Name = "TP to Player", Callback = function()
        if not selTPP or selTPP == "-" then return end
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name == selTPP then
                local t = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if t then
                    playerTpTo(t.Position.X + 2, t.Position.Y, t.Position.Z)
                end
                break
            end
        end
    end})

    --- instant tp?
local charactersFolder = workspace:FindFirstChild("Characters") or workspace

local function safeClone(instance, parent)
    local oldArchivable = instance.Archivable
    instance.Archivable = true
    local clone = instance:Clone()
    clone.Parent = parent
    instance.Archivable = oldArchivable
    return clone
end

local function fixCamera(charCopy)
    pcall(function()
        local root = charCopy:FindFirstChild("HumanoidRootPart")
        local hum = charCopy:FindFirstChildOfClass("Humanoid")
        local cam = workspace.CurrentCamera
        cam.CameraSubject = hum or root
        cam.CameraType = Enum.CameraType.Custom
        if root then
            cam.CFrame = CFrame.new(root.Position + Vector3.new(0, 2, 6), root.Position)
        end
        task.wait(0.05)
        cam.CameraSubject = hum or root
    end)
end

local function reloadAnims(charCopy)
    pcall(function()
        local hum = charCopy:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                track:Stop(0)
            end
        end
        local animScript = charCopy:FindFirstChild("Animate")
        if animScript then
            animScript.Disabled = true
            task.wait(0.05)
            animScript.Disabled = false
        end
        task.wait(0.1)
        hum:ChangeState(Enum.HumanoidStateType.Landed)
        task.wait(0.05)
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end)
end

local isTeleporting = false

-- ===== BLACKOUT SCREEN =====
local blackoutGui = Instance.new("ScreenGui")
blackoutGui.Name = "PhantomBlackout"
blackoutGui.ResetOnSpawn = false
blackoutGui.IgnoreGuiInset = true
blackoutGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
blackoutGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local blackoutFrame = Instance.new("Frame")
blackoutFrame.Size = UDim2.new(1, 0, 1, 0)
blackoutFrame.Position = UDim2.new(0, 0, 0, 0)
blackoutFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blackoutFrame.BackgroundTransparency = 1
blackoutFrame.BorderSizePixel = 0
blackoutFrame.ZIndex = 999
blackoutFrame.Visible = false
blackoutFrame.Parent = blackoutGui

local blackoutLabel = Instance.new("TextLabel")
blackoutLabel.Size = UDim2.new(1, 0, 0, 60)
blackoutLabel.Position = UDim2.new(0, 0, 0.5, -30)
blackoutLabel.BackgroundTransparency = 1
blackoutLabel.Text = "phantom.wtf"
blackoutLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
blackoutLabel.TextSize = 28
blackoutLabel.Font = Enum.Font.GothamBold
blackoutLabel.ZIndex = 1000
blackoutLabel.Parent = blackoutFrame

local dotThread = nil

local function showBlackout()
    blackoutFrame.BackgroundTransparency = 1
    blackoutFrame.Visible = true

    -- Fade in
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(blackoutFrame, tweenInfo, {BackgroundTransparency = 0})
    tween:Play()
    tween.Completed:Wait()

    -- Animate dots
    local dots = 0
    dotThread = task.spawn(function()
        while blackoutFrame.Visible do
            dots = (dots % 3) + 1
            blackoutLabel.Text = "phantom.wtf" .. string.rep(".", dots)
            task.wait(0.4)
        end
    end)
end

local function hideBlackout()
    -- Stop dot animation
    if dotThread then
        task.cancel(dotThread)
        dotThread = nil
    end
    blackoutLabel.Text = "phantom.wtf"

    -- Fade out
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(blackoutFrame, tweenInfo, {BackgroundTransparency = 1})
    tween:Play()
    tween.Completed:Wait()
    blackoutFrame.Visible = false
end

local function copyPasteTeleport(pos)
    if isTeleporting then return end
    isTeleporting = true

    showBlackout() -- ADD THIS

    local char = LocalPlayer.Character
    if not char then hideBlackout() isTeleporting = false return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then hideBlackout() isTeleporting = false return end

    local charCopy = safeClone(char, charactersFolder)
    charCopy.Name = char.Name

    local rootCopy = charCopy:FindFirstChild("HumanoidRootPart")
    if rootCopy then
        rootCopy.CFrame = CFrame.new(pos.X, pos.Y + 3, pos.Z)
    end

    local newHum = charCopy:FindFirstChildOfClass("Humanoid")
    if newHum then
        newHum.Health = newHum.MaxHealth
        newHum.PlatformStand = false
        newHum.Sit = false
    end

    -- Delete old FIRST so server cleans it up
    local oldChar = char
    lp.Character = charCopy

    -- Wait for swap confirmation
    local waited = 0
    while LocalPlayer.Character ~= charCopy and waited < 2 do
        task.wait(0.05)
        waited += 0.05
    end

    destroyIfExisting(oldChar)

    -- Re-register character with server via CharacterAdded hook
    task.spawn(function()
        local hrp = charCopy:WaitForChild("HumanoidRootPart", 5)
        if hrp then
            -- applyCustomization triggers server to recognize this character
            pcall(function()
                local applyCustomization = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("CharacterCustomization"))
                if applyCustomization then
                    applyCustomization(charCopy)
                end
            end)
        end
    end)

    fixCamera(charCopy)
    task.wait(0.05)
    reloadAnims(charCopy)
    task.wait(0.15)
    fixCamera(charCopy)

    hideBlackout() -- ADD THIS
    isTeleporting = false
end

-- CharacterAdded hook so interactions work after swap
LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("HumanoidRootPart")
    pcall(function()
        local applyCustomization = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("CharacterCustomization"))
        if applyCustomization then
            applyCustomization(character)
        end
    end)
end)

local secCloneTP = pageMisc:Section({Name = "Clone Teleport", Side = 1})
secCloneTP:Label("Teleport without dying (clone method)")

local cloneTpLocs = {
    {name = "Dealer NPC",     pos = Vector3.new(770.992,  3.71,   433.75)},
    {name = "NPC Marshmallow",pos = Vector3.new(510.061,  4.476,  600.548)},
    {name = "Apart 1",        pos = Vector3.new(1137.992, 9.932,  449.753)},
    {name = "Apart 2",        pos = Vector3.new(1139.174, 9.932,  420.556)},
    {name = "Apart 3",        pos = Vector3.new(984.856,  9.932,  247.280)},
    {name = "Apart 4",        pos = Vector3.new(988.311,  9.932,  221.664)},
    {name = "Apart 5",        pos = Vector3.new(923.954,  9.932,  42.202)},
    {name = "Apart 6",        pos = Vector3.new(895.721,  9.932,  41.928)},
    {name = "Casino",         pos = Vector3.new(1166.33,  3.36,   -29.77)},
    {name = "GS UJUNG",       pos = Vector3.new(-466.525, 3.862,  357.661)},
    {name = "GS BINARY",      pos = Vector3.new(-280.351, 3.742,  248.872)},
    {name = "GS MID",         pos = Vector3.new(218.427,  3.737,  -176.975)},
}

local cloneTpNames = {}
for _, l in ipairs(cloneTpLocs) do table.insert(cloneTpNames, l.name) end

local selectedCloneIdx = 1
secCloneTP:Dropdown({Name = "Location", Items = cloneTpNames, Default = cloneTpNames[1],
    Callback = function(val)
        for i, l in ipairs(cloneTpLocs) do
            if l.name == val then selectedCloneIdx = i break end
        end
    end
})
secCloneTP:Button({Name = "Clone Teleport!", Callback = function()
    local l = cloneTpLocs[selectedCloneIdx]
    if l then copyPasteTeleport(l.pos) end
end})

    -- ================== WORLD CATEGORY ==================
    S.Window:Category("World")
    local pageVehicle = S.Window:Page({Name = "Vehicle", Icon = "138827881557940"})

    -- Vehicle Teleport
    S.cachedSeat = nil
    S.vehStatusLbl = nil
    local secVTP = pageVehicle:Section({Name = "Vehicle Teleport", Side = 1})
    secVTP:Label("Teleports the entire vehicle you're in")

    local VEHICLE_LOCATIONS = {
        {name = "Dealership",        x = 753.20,   y = 4.63, z = 437.04},
        {name = "Jual/Beli Marshmellow", x = 510.996, y = 3.587, z = 598.392},
        {name = "Tier",              x = 1094.74,  y = 3.188, z = 158.092},
        {name = "Casino",            x = 1154.86,  y = 4.289, z = -46.848},
        {name = "Jual Casino",       x = 1017.58,  y = 4.545, z = -321.792},
        {name = "GS Ujung",          x = -465.51,  y = 4.79,  z = 360.47},
        {name = "GS Mid",            x = 218.57,   y = 4.65,  z = -173.54},
        {name = "Safe",              x = 120.854,  y = 4.297, z = -587.633},
        {name = "Box",               x = -492.35,  y = 4.29,  z = -38.15},
        {name = "Apart 1 (rs 1)",    x = 1108.93,  y = 11.03, z = 455.77},
        {name = "Apart 2 (rs 2)",    x = 1109.15,  y = 11.04, z = 427.29},
        {name = "Apart 3 (gs tier 1)", x = 1017.93, y = 11.01, z = 243.27},
        {name = "Apart 4 (gs tier 2)", x = 1018.19, y = 11.03, z = 214.68},
        {name = "Apart 5 (job sampah 1)", x = 931.02, y = 11.05, z = 72.18},
        {name = "Apart 6 (job sampah 2)", x = 902.45, y = 11.01, z = 72.21},
        {name = "Pabrik Kentang",    x = -493.88,  y = 4.67, z = -437.11},
        {name = "Bank",              x = -43.01,   y = 4.66, z = -353.96},
        {name = "Cukur",             x = 67.62,    y = 4.67, z = -96.48},
        {name = "Labas",             x = -767.21,  y = 4.30, z = -13.43},
        {name = "Doa Turf",          x = -331.58,  y = 18.79, z = -462.96},
        {name = "Gedung Tinggi",     x = 3.08,     y = 5.36, z = 256.11},
        {name = "YGZ Turf",          x = 8.30,     y = 17.82, z = 288.99},
        {name = "OGZ Turf",          x = 113.04,   y = 20.32, z = -509.80},
        {name = "Donat",             x = 578.52,   y = 4.67, z = -352.95},
        {name = "GS Binary",         x = -280.05,  y = 4.68, z = 257.84},
        {name = "GS Drum",           x = 670.51,   y = 4.80, z = 244.05},
        {name = "RS",                x = 1065.33,  y = 4.29, z = 547.58},
        {name = "Jual Senjata",      x = 80.45,    y = 4.72, z = 37.38},
        {name = "Mall",              x = -748.86,  y = 4.69, z = 549.09},
    }

    local vehicleLocNames = {}
    for _, loc in ipairs(VEHICLE_LOCATIONS) do
        table.insert(vehicleLocNames, loc.name)
    end

    local selectedVehIdx = 1

    local vehDropdown = secVTP:Dropdown({
        Name = "Location",
        Items = vehicleLocNames,
        Default = vehicleLocNames[1],
        Callback = function(val)
            for i, loc in ipairs(VEHICLE_LOCATIONS) do
                if loc.name == val then
                    selectedVehIdx = i
                    break
                end
            end
        end
    })

    secVTP:Button({Name = "Teleport Vehicle!", Callback = function()
        local loc = VEHICLE_LOCATIONS[selectedVehIdx]
        if loc then
            S.TpVehicle = true
            S.TpVehicle(loc.x, loc.y, loc.z)
        end
    end})

    S.vehStatusLbl = secVTP:Label("Vehicle: Not in vehicle")

    -- ================== VISUALS ==================
    S.Window:Category("Visuals")
    local pageESP = S.Window:Page({Name = "ESP", Icon = "100050851789190"})
    local pageWL = S.Window:Page({Name = "Whitelist", Icon = "123554105934637"})

    local secESP = pageESP:Section({Name = "Player ESP", Side = 1})
    secESP:Toggle({Name = "ESP Box", Default = false, Flag = "ESPBox", Callback = function(v) S.ESP_BOX = v end})
    secESP:Toggle({Name = "Health Bar", Default = false, Flag = "ESPHealthBar", Callback = function(v) S.ESP_HPBAR = v end})
    secESP:Toggle({Name = "Distance", Default = false, Flag = "ESPDistance", Callback = function(v) S.ESP_DISTANCE = v end})
    secESP:Toggle({Name = "Skeleton", Default = false, Flag = "ESPSkeleton", Callback = function(v) S.ESP_SKELETON = v end})
    secESP:Toggle({Name = "Player Name", Default = false, Flag = "ESPName", Callback = function(v) S.ESP_NAME = v end})
    secESP:Toggle({Name = "Held Item", Default = false, Flag = "ESPItem", Callback = function(v) S.ESP_ITEM = v end})
    secESP:Slider({Name = "Max Distance", Min = 50, Max = 2000, Default = 500, Suffix = " st", Callback = function(v) S.ESP_MAX_DIST = v end})

    local secESPOpt = pageESP:Section({Name = "Options", Side = 2})
    local boxColorLbl = secESPOpt:Label("Box Color")
    boxColorLbl:Colorpicker({Name = "BoxColor", Default = Color3.fromRGB(0, 255, 255),
        Callback = function(v)
            S.ESP_BOX_COLOR = v
            if S.updateESPColor then S.updateESPColor(v) end
        end})
    secESPOpt:Label("Independent toggles for Box, Name, HP,")
    secESPOpt:Label("Distance, Item, Skeleton")

    -- Whitelist
    S.whitelist = {}
    local secWL = pageWL:Section({Name = "Whitelist", Side = 1})
    secWL:Label("Ignored by ESP & Aimbot")
    local function getWLText()
        local n = {}
        for nm in pairs(S.whitelist) do
            table.insert(n, nm)
        end
        return #n == 0 and "None" or table.concat(n, ", ")
    end
    local wlLbl = secWL:Label("Whitelisted: None")
    local wlPN = {}
    local selWL = nil
    local function updateWL()
        wlPN = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and not S.whitelist[p.Name] then
                table.insert(wlPN, p.Name)
            end
        end
    end
    updateWL()
    local wlDD = secWL:Dropdown({Name = "Player", Items = wlPN, Default = wlPN[1] or "-", Callback = function(v) selWL = v end})
    secWL:Button({Name = "Refresh List", Callback = function()
        updateWL()
        pcall(function() wlDD.Items = wlPN end)
        if #wlPN > 0 then selWL = wlPN[1] else selWL = nil end
    end})
    secWL:Button({Name = "Add", Callback = function()
        if not selWL or selWL == "-" then return end
        S.whitelist[selWL] = true
        updateWL()
        setLabel(wlLbl, "WL: " .. getWLText())
    end})
    secWL:Button({Name = "Remove", Callback = function()
        if not selWL or selWL == "-" then return end
        S.whitelist[selWL] = nil
        updateWL()
        setLabel(wlLbl, "WL: " .. getWLText())
    end})
    secWL:Button({Name = "Clear All", Callback = function()
        S.whitelist = {}
        updateWL()
        setLabel(wlLbl, "WL: None")
    end})
    Players.PlayerAdded:Connect(function(plr)
        task.spawn(function()
            local waited = 0
            while waited < 5 do
                task.wait(0.5)
                waited = waited + 0.5
                if plr and plr.Parent and plr.Name ~= "" then
                    updateWL()
                    pcall(function() wlDD.Items = wlPN end)
                    return
                end
            end
        end)
    end)
    Players.PlayerRemoving:Connect(function()
        task.wait(0.1)
        updateWL()
        pcall(function() wlDD.Items = wlPN end)
    end)

        S.Library:Notification({
            Title = "Phantom.wtf",
            Description = "loaded successfully! join our discord for more scripts and support: https://discord.gg/3c4Fv3tJJ",
            Duration = 5,
            Icon = "135215559087473"
        })
    end
end
