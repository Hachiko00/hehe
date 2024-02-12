getgenv().Config = {}

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Umi Pet99 Hub", HidePremium = false, SaveConfig = false, ConfigFolder = "OrionTest"})

local Tab =
    Window:MakeTab(
    {
        Name = "Main",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    }
)

local Tele =
    Window:MakeTab(
    {
        Name = "Teleport",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    }
)

Tele:AddButton(
    {
        Name = "TP Fishing Area",
        Callback = function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
                CFrame.new(-180.852783203125, 117.92350006103516, 5175.45703125)
        end
    }
)
Tab:AddToggle(
    {
        Name = "Auto Map",
        Default = false,
        Callback = function(m)
            Config.automap = m
            spawn(automap)
        end
    }
)

Tab:AddToggle(
    {
        Name = "Auto Fish (Advanced)",
        Default = false,
        Callback = function(v)
            Config.autoFishA = v
            spawn(autoFishA)
        end
    }
)

Tab:AddToggle(
    {
        Name = "Auto Mail (Huge, Shard, Gems)",
        Default = false,
        Callback = function(v)
            Config.autoMail = v
            spawn(autoMail)
        end
    }
)

Tab:AddTextbox(
    {
        Name = "Username",
        Default = "",
        TextDisappear = false,
        Callback = function(user)
            username = user
        end
    }
)

Tab:AddTextbox(
    {
        Name = "Shard Amount",
        Default = "",
        TextDisappear = false,
        Callback = function(shards)
            shardAmount = tonumber(shards)
        end
    }
)

Tab:AddTextbox(
    {
        Name = "Gem Amount",
        Default = "",
        TextDisappear = false,
        Callback = function(gems)
            gemAmount = tonumber(gems)
        end
    }
)

Tab:AddButton(
    {
        Name = "AntiAFK Jump",
        Callback = function()
            antiAFK()
        end
    }
)

Tab:AddButton(
    {
        Name = "AntiAFK Normal",
        Callback = function()
            antiAFKN()
        end
    }
)

Tab:AddButton(
    {
        Name = "Disable 3D Render",
        Callback = function()
            game:GetService("RunService"):Set3dRenderingEnabled(false)
        end
    }
)

Tab:AddButton(
    {
        Name = "Enable 3D Render",
        Callback = function()
            game:GetService("RunService"):Set3dRenderingEnabled(true)
        end
    }
)

OrionLib:Init()

function antiAFK()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    while task.wait() do
        VirtualInputManager:SendKeyEvent(true, "Space", false, game)
        task.wait(.2)
        VirtualInputManager:SendKeyEvent(false, "Space", false, game)
        task.wait(300)
    end
end

function antiAFKN()
    local vu = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:connect(
        function()
            vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            wait(1)
            vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
end

function autoFishA()
    while task.wait() and Config.autoFishA do
        local x = math.random(10, 20)
        local z = math.random(10, 20)

        local argsCast = {
            [1] = "AdvancedFishing",
            [2] = "RequestCast",
            [3] = Vector3.new(1470.6005859375, 61.6249885559082, -4448.0107421875) + Vector3.new(x, 0, z)
        }

        game:GetService("ReplicatedStorage").Network.Instancing_FireCustomFromClient:FireServer(unpack(argsCast))
        task.wait(3.5)

        local argsReel = {
            [1] = "AdvancedFishing",
            [2] = "RequestReel"
        }

        game:GetService("ReplicatedStorage").Network.Instancing_FireCustomFromClient:FireServer(unpack(argsReel))
        repeat
            task.wait()

            local hasFishingLine = false
            for _, descendant in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if descendant.Name == "FishingLine" then
                    hasFishingLine = true
                    break
                end
            end

            if not hasFishingLine then
                break
            end

            local argsClicked = {
                [1] = "AdvancedFishing",
                [2] = "Clicked"
            }

            game:GetService("ReplicatedStorage").Network.Instancing_InvokeCustomFromClient:InvokeServer(
                unpack(argsClicked)
            )
        until not hasFishingLine
        task.wait()
    end
end

function autoMail()
    while task.wait() and Config.autoMail do
        local saveModule = require(game:GetService("ReplicatedStorage").Library.Client.Save)
        local result = saveModule.Get()

        local ms = result.Inventory.Misc
        for i, v in pairs(ms) do
            if v.id == "Magic Shard" then
                if v._am >= shardAmount then
                    local args = {
                        [1] = username,
                        [2] = "Magic Shard",
                        [3] = "Misc",
                        [4] = i,
                        [5] = v._am or 1
                    }
                    game:GetService("ReplicatedStorage").Network:FindFirstChild("Mailbox: Send"):InvokeServer(
                        unpack(args)
                    )
                end
            end
        end

        task.wait(2)

        local pet = result.Inventory.Pet
        for i, v in pairs(pet) do
            if v.id == "Huge Poseidon Corgi" then
                local args = {
                    [1] = username,
                    [2] = "Huge Poseidon Corgi",
                    [3] = "Pet",
                    [4] = i,
                    [5] = v._am or 1
                }
                game:GetService("ReplicatedStorage").Network:FindFirstChild("Mailbox: Send"):InvokeServer(unpack(args))
            end
        end

        task.wait(2)

        local GetSave = function()
            return require(game.ReplicatedStorage.Library.Client.Save).Get()
        end
        for i, v in pairs(GetSave().Inventory.Currency) do
            if v.id == "Diamonds" then
                if v._am >= gemAmount then
                    local args = {
                        [1] = username,
                        [2] = v.id,
                        [3] = "Currency",
                        [4] = i,
                        [5] = gemAmount - 10000
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Mailbox: Send"):InvokeServer(unpack(args))
                end
            end
            task.wait(1)
        end
    end
end

function Automap()
      while task.wait() and Config.automap 
do 

Options.Automap:SetValue(false)

game:GetService("VirtualInputManager"):SendKeyEvent(true, "Space", false, game)
      wait(.1)
       game:GetService("VirtualInputManager"):SendKeyEvent(false, "Space", false, game)
      end
    end
  end
wait(.1)
getgenv().Start = a

local Library = require(game:GetService("ReplicatedStorage").Library)

local Network = Library.Network
local Balancing = Library.Balancing
local Zones = Library.Directory.Zones

Library.PlayerPet.CalculateSpeedMultiplier = function(...)
    return 999999999
end

while getgenv().Start do wait()
    pcall(function()
        local Zone, Zone_Info = Library["ZoneCmds"].GetMaxOwnedZone()
        local zone, info = Library["ZoneCmds"].GetNextZone()
        if zone and info then
            if Balancing.CalcGatePrice(info) <= Library["CurrencyCmds"].Get("Coins") then
                Network.Invoke("Zones_RequestPurchase", info.ZoneName)
            end
        end
        if Library["MapCmds"].GetCurrentZone() ~= Zone_Info._id or not Library["MapCmds"].IsInDottedBox() then
            if Zone_Info.ZoneFolder:FindFirstChild("INTERACT") then
                local Max, BreakZone;
                for i,v in pairs(Zone_Info.ZoneFolder.INTERACT.BREAK_ZONES:GetChildren()) do
                    if not Max then Max = v.Size.X * v.Size.Y * v.Size.Z; end
                    if not BreakZone then BreakZone = v end
                
                    if Max < v.Size.X * v.Size.Y * v.Size.Z then
                        BreakZone = v
                    end
                end

                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = BreakZone.CFrame * CFrame.new(0, 10, 0)
            else
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Zone_Info.ZoneFolder.PERSISTENT.Teleport.CFrame
            end
        end
    end)
end

local GetNearestBreakable = getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.GUIs["Auto Tapper"]).GetNearestBreakable

while wait() do
    pcall(function()
        local Breakable = GetNearestBreakable()
        if Breakable then
            Network.Fire("Breakables_PlayerDealDamage", Breakable.Name)
        end
    end)
end
