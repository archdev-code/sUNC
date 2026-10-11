local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local Results = {}
local PassCount = 0
local FailCount = 0
local WarnCount = 0

local function AddResult(Category, Name, Status, Detail)
    Results[#Results + 1] = {
        Category = Category,
        Name = Name,
        Status = Status,
        Detail = Detail or "",
    }
    if Status == "Pass" then PassCount += 1
    elseif Status == "Fail" then FailCount += 1
    else WarnCount += 1 end
end

local function SafeCall(Fn)
    local Ok, Result = pcall(Fn)
    if Ok then return true, Result end
    return false, tostring(Result)
end

local function DetectExecutor()
    if syn and syn.request then return "Synapse X" end
    if securecall and request and http and not syn then return "Script-Ware" end
    if KRNL_LOADED or (getgenv and getgenv().KRNL_LOADED) then return "KRNL" end
    if fluxus and fluxus.request then return "Fluxus" end
    if Delta and Delta.Executor then return "Delta" end
    if is_sirhurt_closure and syn and syn.protect_gui then return "SirHurt" end
    if PROTOSMASHER_LOADED then return "ProtoSmasher" end
    if getexecutorname then
        local Ok, Name = pcall(getexecutorname)
        if Ok and Name then return tostring(Name) end
    end
    if identifyexecutor then
        local Ok, Name = pcall(identifyexecutor)
        if Ok and Name then return tostring(Name) end
    end
    if getscriptbytecode and not KRNL_LOADED then return "Synapse" end
    if getrawmetatable and hookfunction and not is_sirhurt_closure then return "Unknown (Modern)" end
    if getrawmetatable then return "Unknown (Legacy)" end
    if firetouchinterest then return "Unknown (Basic)" end
    return "Vanilla"
end

local function RunTests()
    Results = {}
    PassCount = 0
    FailCount = 0
    WarnCount = 0

    local ExecutorName = DetectExecutor()
    AddResult("Identity", "Executor Name", "Pass", ExecutorName)

    local Ok, Identity = SafeCall(function() return game:GetService("Players").LocalPlayer.UserId end)
    AddResult("Identity", "LocalPlayer UserId", Ok and "Pass" or "Fail", tostring(Identity))

    if identifyexecutor then
        local S, N = SafeCall(function() return identifyexecutor() end)
        AddResult("Identity", "identifyexecutor()", S and "Pass" or "Fail", tostring(N))
    else
        AddResult("Identity", "identifyexecutor()", "Fail", "Not present")
    end

    if getexecutorname then
        local S, N = SafeCall(function() return getexecutorname() end)
        AddResult("Identity", "getexecutorname()", S and "Pass" or "Fail", tostring(N))
    else
        AddResult("Identity", "getexecutorname()", "Fail", "Not present")
    end

    -- File system
    if writefile then
        local S = SafeCall(function() writefile("sunсtest.txt", "test") end)
        AddResult("Filesystem", "writefile", S and "Pass" or "Fail", "")
        if S then
            local R, Content = SafeCall(function() return readfile("sunсtest.txt") end)
            AddResult("Filesystem", "readfile", R and "Pass" or "Fail", tostring(Content))
            if delfile then
                local D = SafeCall(function() delfile("sunсtest.txt") end)
                AddResult("Filesystem", "delfile", D and "Pass" or "Fail", "")
            else
                AddResult("Filesystem", "delfile", "Fail", "Not present")
            end
        end
    else
        AddResult("Filesystem", "writefile", "Fail", "Not present")
    end

    if isfile then
        local S = SafeCall(function() return isfile("__nonexistent__.txt") end)
        AddResult("Filesystem", "isfile", S and "Pass" or "Fail", "")
    else
        AddResult("Filesystem", "isfile", "Fail", "Not present")
    end

    if listfiles then
        local S, L = SafeCall(function() return listfiles(".") end)
        AddResult("Filesystem", "listfiles", S and "Pass" or "Fail", S and (#L .. " entries") or tostring(L))
    else
        AddResult("Filesystem", "listfiles", "Fail", "Not present")
    end

    if makefolder then
        local S = SafeCall(function() makefolder("sunсtestfolder") end)
        AddResult("Filesystem", "makefolder", S and "Pass" or "Fail", "")
        if S and delfolder then
            local D = SafeCall(function() delfolder("sunсtestfolder") end)
            AddResult("Filesystem", "delfolder", D and "Pass" or "Fail", "")
        end
    else
        AddResult("Filesystem", "makefolder", "Fail", "Not present")
    end

    -- HTTP
    if request then
        AddResult("HTTP", "request", "Pass", "Present")
    elseif http and http.request then
        AddResult("HTTP", "http.request", "Pass", "Present")
    elseif syn and syn.request then
        AddResult("HTTP", "syn.request", "Pass", "Present")
    else
        AddResult("HTTP", "HTTP Request", "Fail", "No HTTP API")
    end

    if game.HttpGet then
        local S = SafeCall(function() game:HttpGet("https://httpbin.org/get") end)
        AddResult("HTTP", "game:HttpGet", S and "Pass" or "Warn", S and "" or "May be rate limited")
    else
        AddResult("HTTP", "game:HttpGet", "Fail", "Not present")
    end

    -- Metatable
    if getrawmetatable then
        local S, M = SafeCall(function() return getrawmetatable(game) end)
        AddResult("Metatable", "getrawmetatable", S and "Pass" or "Fail", "")
    else
        AddResult("Metatable", "getrawmetatable", "Fail", "Not present")
    end

    if setreadonly then
        AddResult("Metatable", "setreadonly", "Pass", "")
    else
        AddResult("Metatable", "setreadonly", "Fail", "Not present")
    end

    if hookfunction then
        AddResult("Metatable", "hookfunction", "Pass", "")
    else
        AddResult("Metatable", "hookfunction", "Fail", "Not present")
    end

    if hookmetamethod then
        AddResult("Metatable", "hookmetamethod", "Pass", "")
    else
        AddResult("Metatable", "hookmetamethod", "Fail", "Not present")
    end

    if newcclosure then
        AddResult("Metatable", "newcclosure", "Pass", "")
    else
        AddResult("Metatable", "newcclosure", "Fail", "Not present")
    end

    if getnamecallmethod then
        AddResult("Metatable", "getnamecallmethod", "Pass", "")
    else
        AddResult("Metatable", "getnamecallmethod", "Fail", "Not present")
    end

    if getconnections then
        local S, C = SafeCall(function() return getconnections(game:GetService("Players").LocalPlayer.CharacterAdded) end)
        AddResult("Metatable", "getconnections", S and "Pass" or "Fail", S and (#C .. " connections") or tostring(C))
    else
        AddResult("Metatable", "getconnections", "Fail", "Not present")
    end

    if firesignal then
        AddResult("Metatable", "firesignal", "Pass", "")
    else
        AddResult("Metatable", "firesignal", "Fail", "Not present")
    end

    if getgc then
        local S, G = SafeCall(function() return getgc(true) end)
        AddResult("Memory", "getgc", S and "Pass" or "Fail", S and (#G .. " objects") or tostring(G))
    else
        AddResult("Memory", "getgc", "Fail", "Not present")
    end

    if getinstances then
        local S, I = SafeCall(function() return getinstances() end)
        AddResult("Memory", "getinstances", S and "Pass" or "Fail", S and (#I .. " instances") or tostring(I))
    else
        AddResult("Memory", "getinstances", "Fail", "Not present")
    end

    if getnilinstances then
        local S, I = SafeCall(function() return getnilinstances() end)
        AddResult("Memory", "getnilinstances", S and "Pass" or "Fail", S and (#I .. " instances") or tostring(I))
    else
        AddResult("Memory", "getnilinstances", "Fail", "Not present")
    end

    if getreg then
        AddResult("Memory", "getreg", "Pass", "")
    else
        AddResult("Memory", "getreg", "Fail", "Not present")
    end

    if getupvalue then
        AddResult("Memory", "getupvalue", "Pass", "")
    else
        AddResult("Memory", "getupvalue", "Fail", "Not present")
    end

    if setupvalue then
        AddResult("Memory", "setupvalue", "Pass", "")
    else
        AddResult("Memory", "setupvalue", "Fail", "Not present")
    end

    if getupvalues then
        AddResult("Memory", "getupvalues", "Pass", "")
    else
        AddResult("Memory", "getupvalues", "Fail", "Not present")
    end

    if getconstants then
        AddResult("Memory", "getconstants", "Pass", "")
    else
        AddResult("Memory", "getconstants", "Fail", "Not present")
    end

    if getprotos then
        AddResult("Memory", "getprotos", "Pass", "")
    else
        AddResult("Memory", "getprotos", "Fail", "Not present")
    end

    if checkcaller then
        AddResult("Memory", "checkcaller", "Pass", "")
    else
        AddResult("Memory", "checkcaller", "Fail", "Not present")
    end

    if setidentity then
        AddResult("Identity", "setidentity", "Pass", "")
    else
        AddResult("Identity", "setidentity", "Fail", "Not present")
    end

    if getthreadidentity then
        local S, I = SafeCall(function() return getthreadidentity() end)
        AddResult("Identity", "getthreadidentity", S and "Pass" or "Fail", tostring(I))
    elseif getidentity then
        local S, I = SafeCall(function() return getidentity() end)
        AddResult("Identity", "getidentity", S and "Pass" or "Fail", tostring(I))
    else
        AddResult("Identity", "getthreadidentity", "Fail", "Not present")
    end

    -- GUI
    if syn and syn.protect_gui then
        AddResult("GUI", "syn.protect_gui", "Pass", "")
    else
        AddResult("GUI", "syn.protect_gui", "Fail", "Not present")
    end

    if protect_gui then
        AddResult("GUI", "protect_gui", "Pass", "")
    else
        AddResult("GUI", "protect_gui", "Fail", "Not present")
    end

    if gethui then
        local S, H = SafeCall(function() return gethui() end)
        AddResult("GUI", "gethui", S and "Pass" or "Fail", S and tostring(H.Name or H.ClassName) or tostring(H))
    else
        AddResult("GUI", "gethui", "Fail", "Not present")
    end

    if getcustomasset then
        AddResult("GUI", "getcustomasset", "Pass", "")
    else
        AddResult("GUI", "getcustomasset", "Fail", "Not present")
    end

    -- Instance manipulation
    if firetouchinterest then
        AddResult("Instance", "firetouchinterest", "Pass", "")
    else
        AddResult("Instance", "firetouchinterest", "Fail", "Not present")
    end

    if fireclickdetector then
        AddResult("Instance", "fireclickdetector", "Pass", "")
    else
        AddResult("Instance", "fireclickdetector", "Fail", "Not present")
    end

    if fireproximityprompt then
        AddResult("Instance", "fireproximityprompt", "Pass", "")
    else
        AddResult("Instance", "fireproximityprompt", "Fail", "Not present")
    end

    if sethiddenproperty then
        AddResult("Instance", "sethiddenproperty", "Pass", "")
    else
        AddResult("Instance", "sethiddenproperty", "Fail", "Not present")
    end

    if gethiddenproperty then
        AddResult("Instance", "gethiddenproperty", "Pass", "")
    else
        AddResult("Instance", "gethiddenproperty", "Fail", "Not present")
    end

    if setscriptable then
        AddResult("Instance", "setscriptable", "Pass", "")
    else
        AddResult("Instance", "setscriptable", "Fail", "Not present")
    end

    if getscriptable then
        AddResult("Instance", "getscriptable", "Pass", "")
    else
        AddResult("Instance", "getscriptable", "Fail", "Not present")
    end

    if isscriptable then
        AddResult("Instance", "isscriptable", "Pass", "")
    else
        AddResult("Instance", "isscriptable", "Fail", "Not present")
    end

    if getcallbackvalue then
        AddResult("Instance", "getcallbackvalue", "Pass", "")
    else
        AddResult("Instance", "getcallbackvalue", "Fail", "Not present")
    end

    if setcallbackvalue then
        AddResult("Instance", "setcallbackvalue", "Pass", "")
    else
        AddResult("Instance", "setcallbackvalue", "Fail", "Not present")
    end

    -- Closures
    if clonefunction then
        AddResult("Closure", "clonefunction", "Pass", "")
    else
        AddResult("Closure", "clonefunction", "Fail", "Not present")
    end

    if getscriptclosure then
        AddResult("Closure", "getscriptclosure", "Pass", "")
    else
        AddResult("Closure", "getscriptclosure", "Fail", "Not present")
    end

    if getscriptbytecode then
        AddResult("Closure", "getscriptbytecode", "Pass", "")
    else
        AddResult("Closure", "getscriptbytecode", "Fail", "Not present")
    end

    if decompile then
        AddResult("Closure", "decompile", "Pass", "")
    else
        AddResult("Closure", "decompile", "Fail", "Not present")
    end

    if getloadedmodules then
        AddResult("Closure", "getloadedmodules", "Pass", "")
    else
        AddResult("Closure", "getloadedmodules", "Fail", "Not present")
    end

    if iscclosure then
        AddResult("Closure", "iscclosure", "Pass", "")
    else
        AddResult("Closure", "iscclosure", "Fail", "Not present")
    end

    if islclosure then
        AddResult("Closure", "islclosure", "Pass", "")
    else
        AddResult("Closure", "islclosure", "Fail", "Not present")
    end

    -- Environment
    if getgenv then
        AddResult("Environment", "getgenv", "Pass", "")
    else
        AddResult("Environment", "getgenv", "Fail", "Not present")
    end

    if getrenv then
        AddResult("Environment", "getrenv", "Pass", "")
    else
        AddResult("Environment", "getrenv", "Fail", "Not present")
    end

    if getmenv then
        AddResult("Environment", "getmenv", "Pass", "")
    else
        AddResult("Environment", "getmenv", "Fail", "Not present")
    end

    if getsenv then
        AddResult("Environment", "getsenv", "Pass", "")
    else
        AddResult("Environment", "getsenv", "Fail", "Not present")
    end

    if getfenv then
        AddResult("Environment", "getfenv", "Pass", "")
    else
        AddResult("Environment", "getfenv", "Fail", "Not present")
    end

    if setfenv then
        AddResult("Environment", "setfenv", "Pass", "")
    else
        AddResult("Environment", "setfenv", "Fail", "Not present")
    end

    -- Thread / script
    if getscriptthreads then
        local S, T = SafeCall(function() return getscriptthreads() end)
        AddResult("Thread", "getscriptthreads", S and "Pass" or "Fail", S and (#T .. " threads") or tostring(T))
    else
        AddResult("Thread", "getscriptthreads", "Fail", "Not present")
    end

    if coroutine and coroutine.close then
        AddResult("Thread", "coroutine.close", "Pass", "")
    else
        AddResult("Thread", "coroutine.close", "Fail", "Not present")
    end

    if wait then
        AddResult("Thread", "wait", "Pass", "")
    else
        AddResult("Thread", "wait", "Fail", "Not present")
    end

    if spawn then
        AddResult("Thread", "spawn", "Pass", "")
    else
        AddResult("Thread", "spawn", "Fail", "Not present")
    end

    if tick then
        AddResult("Thread", "tick", "Pass", "")
    else
        AddResult("Thread", "tick", "Fail", "Not present")
    end

    -- Cryptography
    if crypt and crypt.base64 then
        AddResult("Crypto", "crypt.base64", "Pass", "")
        if crypt.hash then
            AddResult("Crypto", "crypt.hash", "Pass", "")
        end
        if crypt.encrypt then
            AddResult("Crypto", "crypt.encrypt", "Pass", "")
        end
    else
        AddResult("Crypto", "crypt", "Fail", "Not present")
    end

    if base64_encode then
        AddResult("Crypto", "base64_encode", "Pass", "")
    else
        AddResult("Crypto", "base64_encode", "Fail", "Not present")
    end

    if base64_decode then
        AddResult("Crypto", "base64_decode", "Pass", "")
    else
        AddResult("Crypto", "base64_decode", "Fail", "Not present")
    end

    if base64 and base64.encode then
        AddResult("Crypto", "base64.encode", "Pass", "")
    else
        AddResult("Crypto", "base64.encode", "Fail", "Not present")
    end

    if lz4compress then
        AddResult("Crypto", "lz4compress", "Pass", "")
    else
        AddResult("Crypto", "lz4compress", "Fail", "Not present")
    end

    -- Loadstring
    local LSOk, LSResult = SafeCall(function()
        local f = loadstring("return 1 + 1")
        return f and f() or nil
    end)
    AddResult("Loader", "loadstring", LSOk and LSResult == 2 and "Pass" or "Fail", tostring(LSResult))

    if loadstring_closure then
        AddResult("Loader", "loadstring_closure", "Pass", "")
    else
        AddResult("Loader", "loadstring_closure", "Fail", "Not present")
    end

    if is_synapse_function then
        AddResult("Loader", "is_synapse_function", "Pass", "")
    else
        AddResult("Loader", "is_synapse_function", "Fail", "Not present")
    end

    -- Teleport / misc
    if queue_on_teleport then
        AddResult("Misc", "queue_on_teleport", "Pass", "")
    else
        AddResult("Misc", "queue_on_teleport", "Fail", "Not present")
    end

    if setclipboard then
        AddResult("Misc", "setclipboard", "Pass", "")
    else
        AddResult("Misc", "setclipboard", "Fail", "Not present")
    end

    if toclipboard then
        AddResult("Misc", "toclipboard", "Pass", "")
    else
        AddResult("Misc", "toclipboard", "Fail", "Not present")
    end

    if messagebox then
        AddResult("Misc", "messagebox", "Pass", "")
    else
        AddResult("Misc", "messagebox", "Fail", "Not present")
    end

    if setfpscap then
        AddResult("Misc", "setfpscap", "Pass", "")
    else
        AddResult("Misc", "setfpscap", "Fail", "Not present")
    end

    if getfpscap then
        local S, F = SafeCall(function() return getfpscap() end)
        AddResult("Misc", "getfpscap", S and "Pass" or "Fail", tostring(F))
    else
        AddResult("Misc", "getfpscap", "Fail", "Not present")
    end

    if islclosed then
        AddResult("Misc", "islclosed", "Pass", "")
    else
        AddResult("Misc", "islclosed", "Fail", "Not present")
    end

    if getcallingscript then
        AddResult("Misc", "getcallingscript", "Pass", "")
    else
        AddResult("Misc", "getcallingscript", "Fail", "Not present")
    end
end

local function BuildUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SuncTest"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 500, 0, 540)
    Main.Position = UDim2.new(0.5, -250, 0.5, -270)
    Main.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(30, 30, 36)
    MainStroke.Thickness = 1
    MainStroke.Parent = Main

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 56)
    Header.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    Header.BorderSizePixel = 0
    Header.Parent = Main

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 10)
    HeaderCorner.Parent = Header

    local HeaderMask = Instance.new("Frame")
    HeaderMask.Size = UDim2.new(1, 0, 0, 12)
    HeaderMask.Position = UDim2.new(0, 0, 1, -12)
    HeaderMask.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    HeaderMask.BorderSizePixel = 0
    HeaderMask.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -70, 0, 22)
    Title.Position = UDim2.new(0, 18, 0, 8)
    Title.BackgroundTransparency = 1
    Title.Text = "Sunc Test"
    Title.TextColor3 = Color3.fromRGB(240, 240, 245)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size = UDim2.new(1, -70, 0, 16)
    SubLabel.Position = UDim2.new(0, 18, 0, 32)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text = "Executor Test"
    SubLabel.TextColor3 = Color3.fromRGB(110, 140, 200)
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.TextSize = 11
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.Parent = Header

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 24, 0, 24)
    CloseButton.Position = UDim2.new(1, -34, 0.5, -12)
    CloseButton.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(200, 200, 210)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 15
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = Header

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = false
    end)

    local SummaryBar = Instance.new("Frame")
    SummaryBar.Size = UDim2.new(1, -36, 0, 40)
    SummaryBar.Position = UDim2.new(0, 18, 0, 68)
    SummaryBar.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    SummaryBar.BorderSizePixel = 0
    SummaryBar.Parent = Main

    local SummaryCorner = Instance.new("UICorner")
    SummaryCorner.CornerRadius = UDim.new(0, 8)
    SummaryCorner.Parent = SummaryBar

    local SummaryStroke = Instance.new("UIStroke")
    SummaryStroke.Color = Color3.fromRGB(30, 30, 36)
    SummaryStroke.Thickness = 1
    SummaryStroke.Parent = SummaryBar

    local SummaryText = Instance.new("TextLabel")
    SummaryText.Name = "SummaryText"
    SummaryText.Size = UDim2.new(1, -20, 1, 0)
    SummaryText.Position = UDim2.new(0, 10, 0, 0)
    SummaryText.BackgroundTransparency = 1
    SummaryText.Text = "Running tests..."
    SummaryText.TextColor3 = Color3.fromRGB(220, 220, 230)
    SummaryText.Font = Enum.Font.Gotham
    SummaryText.TextSize = 12
    SummaryText.TextXAlignment = Enum.TextXAlignment.Left
    SummaryText.RichText = true
    SummaryText.Parent = SummaryBar

    local ListFrame = Instance.new("ScrollingFrame")
    ListFrame.Size = UDim2.new(1, -36, 1, -188)
    ListFrame.Position = UDim2.new(0, 18, 0, 118)
    ListFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    ListFrame.BorderSizePixel = 0
    ListFrame.ScrollBarThickness = 4
    ListFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ListFrame.Parent = Main

    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 8)
    ListCorner.Parent = ListFrame

    local ListPadding = Instance.new("UIPadding")
    ListPadding.PaddingTop = UDim.new(0, 6)
    ListPadding.PaddingBottom = UDim.new(0, 6)
    ListPadding.PaddingLeft = UDim.new(0, 8)
    ListPadding.PaddingRight = UDim.new(0, 8)
    ListPadding.Parent = ListFrame

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 3)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = ListFrame

    local ButtonBar = Instance.new("Frame")
    ButtonBar.Size = UDim2.new(1, -36, 0, 44)
    ButtonBar.Position = UDim2.new(0, 18, 1, -58)
    ButtonBar.BackgroundTransparency = 1
    ButtonBar.Parent = Main

    local ButtonLayout = Instance.new("UIListLayout")
    ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    ButtonLayout.Padding = UDim.new(0, 8)
    ButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ButtonLayout.Parent = ButtonBar

    local function MakeButton(Text, Order, Callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0.5, -4, 0, 40)
        Button.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
        Button.BorderSizePixel = 0
        Button.Text = Text
        Button.TextColor3 = Color3.fromRGB(240, 240, 245)
        Button.Font = Enum.Font.GothamBold
        Button.TextSize = 13
        Button.LayoutOrder = Order
        Button.Parent = ButtonBar

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Button

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Color3.fromRGB(38, 38, 44)
        Stroke.Thickness = 1
        Stroke.Parent = Button

        Button.MouseEnter:Connect(function()
            Button.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
        end)
        Button.MouseLeave:Connect(function()
            Button.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
        end)
        Button.MouseButton1Click:Connect(Callback)
        return Button
    end

    local function RenderResults()
        for _, Child in ipairs(ListFrame:GetChildren()) do
            if Child:IsA("TextLabel") then Child:Destroy() end
        end

        local CurrentCategory = ""
        local Order = 0

        for _, Result in ipairs(Results) do
            if Result.Category ~= CurrentCategory then
                CurrentCategory = Result.Category
                local CategoryLabel = Instance.new("TextLabel")
                CategoryLabel.Size = UDim2.new(1, 0, 0, 20)
                CategoryLabel.BackgroundTransparency = 1
                CategoryLabel.Text = CurrentCategory:upper()
                CategoryLabel.TextColor3 = Color3.fromRGB(120, 120, 135)
                CategoryLabel.Font = Enum.Font.GothamBold
                CategoryLabel.TextSize = 10
                CategoryLabel.TextXAlignment = Enum.TextXAlignment.Left
                CategoryLabel.LayoutOrder = Order
                CategoryLabel.Parent = ListFrame
                Order += 1
            end

            local Row = Instance.new("Frame")
            Row.Size = UDim2.new(1, 0, 0, 22)
            Row.BackgroundTransparency = 1
            Row.LayoutOrder = Order
            Row.Parent = ListFrame
            Order += 1

            local StatusColor
            local StatusSymbol
            if Result.Status == "Pass" then
                StatusColor = Color3.fromRGB(80, 200, 120)
                StatusSymbol = "✓"
            elseif Result.Status == "Warn" then
                StatusColor = Color3.fromRGB(220, 180, 80)
                StatusSymbol = "!"
            else
                StatusColor = Color3.fromRGB(220, 80, 80)
                StatusSymbol = "✕"
            end

            local Dot = Instance.new("Frame")
            Dot.Size = UDim2.new(0, 8, 0, 8)
            Dot.Position = UDim2.new(0, 2, 0.5, -4)
            Dot.BackgroundColor3 = StatusColor
            Dot.BorderSizePixel = 0
            Dot.Parent = Row

            local DotCorner = Instance.new("UICorner")
            DotCorner.CornerRadius = UDim.new(1, 0)
            DotCorner.Parent = Dot

            local Name = Instance.new("TextLabel")
            Name.Size = UDim2.new(0.5, -20, 1, 0)
            Name.Position = UDim2.new(0, 20, 0, 0)
            Name.BackgroundTransparency = 1
            Name.Text = Result.Name
            Name.TextColor3 = Color3.fromRGB(220, 220, 230)
            Name.Font = Enum.Font.Gotham
            Name.TextSize = 12
            Name.TextXAlignment = Enum.TextXAlignment.Left
            Name.Parent = Row

            local Detail = Instance.new("TextLabel")
            Detail.Size = UDim2.new(0.5, -10, 1, 0)
            Detail.Position = UDim2.new(0.5, 0, 0, 0)
            Detail.BackgroundTransparency = 1
            Detail.Text = Result.Detail
            Detail.TextColor3 = StatusColor
            Detail.Font = Enum.Font.Gotham
            Detail.TextSize = 11
            Detail.TextXAlignment = Enum.TextXAlignment.Right
            Detail.TextTruncate = Enum.TextTruncate.AtEnd
            Detail.Parent = Row
        end

        SummaryText.Text = string.format(
            "<font color='#50C878'>%d pass</font>  ·  <font color='#DCB450'>%d warn</font>  ·  <font color='#DC5050'>%d fail</font>  ·  Executor  ·  %s",
            PassCount, WarnCount, FailCount, DetectExecutor()
        )
    end

    local function RunAndRender()
        SummaryText.Text = "Running tests..."
        task.wait(0.1)
        RunTests()
        RenderResults()
    end

    MakeButton("Run Tests", 1, RunAndRender)

    MakeButton("Copy Report", 2, function()
        local Lines = {}
        Lines[#Lines + 1] = "Sunc Test Report"
        Lines[#Lines + 1] = "Executor: " .. DetectExecutor()
        Lines[#Lines + 1] = string.format("Pass: %d  Warn: %d  Fail: %d", PassCount, WarnCount, FailCount)
        Lines[#Lines + 1] = ""
        local CurrentCategory = ""
        for _, Result in ipairs(Results) do
            if Result.Category ~= CurrentCategory then
                CurrentCategory = Result.Category
                Lines[#Lines + 1] = "[" .. CurrentCategory .. "]"
            end
            Lines[#Lines + 1] = string.format("  [%s] %s — %s", Result.Status, Result.Name, Result.Detail)
        end
        local Report = table.concat(Lines, "\n")
        if setclipboard then
            setclipboard(Report)
        elseif toclipboard then
            toclipboard(Report)
        end
        StarterGui:SetCore("SendNotification", {
            Title = "Sunc Test",
            Text = "Report copied to clipboard.",
            Duration = 3,
        })
    end)

    return ScreenGui, RunAndRender
end

local UI, RunAndRender = BuildUI()
RunAndRender()
