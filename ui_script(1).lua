local lp = game:GetService("Players").LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

local sg = Instance.new("ScreenGui")
sg.Name = "TestGui"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.Parent = pg

local f = Instance.new("Frame", sg)
f.Size = UDim2.fromOffset(300, 200)
f.Position = UDim2.new(0.5, -150, 0.5, -100)
f.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
f.BorderSizePixel = 0

local t = Instance.new("TextLabel", f)
t.Size = UDim2.new(1, 0, 1, 0)
t.BackgroundTransparency = 1
t.TextColor3 = Color3.fromRGB(255, 255, 255)
t.TextSize = 20
t.Font = Enum.Font.GothamBold
t.Text = "GUI IS WORKING"
