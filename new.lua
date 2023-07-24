--wait until game loads
repeat
    task.wait()
until game.PlaceId ~= nil
if not game:IsLoaded() then
    game.Loaded:Wait()
end
repeat task.wait() until not game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("__INTRO")

--ANTI AFK
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
   vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
   wait(1)
   vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)


--VARIABLES/LOCALS
local platform = nil
local teleportingEnabled = true
local oldJob = game.JobId
local v1 = require(game.ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Library"));
while not v1.Loaded do
    game:GetService("RunService").Heartbeat:Wait();
end;
local Network = require(game:GetService("ReplicatedStorage").Library.Client.Network)
local Fire, Invoke = Network.Fire, Network.Invoke
local old
old = hookfunction(getupvalue(Fire, 1), function(...)
   return true
end)
local TimeElapsed = 0
local GemsEarned = 0
local TotalGemsEarned = 0
local Library = require(game:GetService("ReplicatedStorage").Library)
local StartingGems = Library.Save.Get().Diamonds
local timer = coroutine.create(function()
    while 1 do
        TimeElapsed = TimeElapsed + 1
        wait(1)
    end
end)
coroutine.resume(timer)


--disable orbs render
game:GetService("Workspace")["__THINGS"].Orbs.ChildAdded:Connect(function(v)
	pcall(function()
		v.Orb.Enabled = false
	end)
end)

--disable lootbag render
game:GetService("Workspace")["__THINGS"].Lootbags.ChildAdded:Connect(function(v)
	pcall(function()
		v.Transparency = 1
		v.ParticleEmitter:Destroy()
	end)
end)

--collect orbs
game.Workspace['__THINGS'].Orbs.ChildAdded:Connect(function(v)
    Fire("Claim Orbs", {v.Name})
end)

--collect lootbags
game.Workspace['__THINGS'].Lootbags.ChildAdded:Connect(function(v)
    Fire("Collect Lootbag", v.Name, v.Position)
end)

--instant coin fall
local WorldCoins = Library.Things:WaitForChild("Coins")
WorldCoins.ChildAdded:Connect(function(ch) 
    ch:SetAttribute("HasLanded", true)
    ch:SetAttribute("IsFalling", false)
        
    local coin = ch:WaitForChild("Coin")
    coin:SetAttribute("InstantLand", true)
end)

wait(8)

--FUNCTIONS
function attack_coin(id, equip)
    local v86 = Invoke("Join Coin", id, equip)
    for v88, v89 in pairs(v86) do
        Fire("Farm Coin", id, v88);
    end
end

function wait_until_broken(id)
    while 1 do
        wait(0.01)
        for i,v in pairs(Invoke("Get Coins")) do
            found = false
            if i == id then
                if #v.petsFarming ~= 0 then
                    found = true
                end
            end
        end
        if not found then break end
    end
end

function GetOranges()
    local FruitLib = require(game.ReplicatedStorage.Library.Client.FruitCmds)

    local Fruit = FruitLib.Directory.Orange
    return math.floor(FruitLib.Get(game.Players.LocalPlayer, Fruit))
end

function create_platform(x, y, z)
	local p = Instance.new("Part")
	p.Anchored = true
	p.Name = "plat"
	p.Position = Vector3.new(x, y, z)
	p.Size = Vector3.new(100, 1, 100)
	p.Parent = game.Workspace
end

function serverHop()
    repeat
        local data = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/6284583030/servers/Public?sortOrder=Dsc&excludeFullGames=true&limit=100"))
        local bestserver
        for i,v in pairs(data.data) do
           if v.playing == 11 then
            bestserver = v.id
          end
        end
        
        game:GetService("TeleportService"):TeleportToPlaceInstance(6284583030, bestserver, game.Players.LocalPlayer)
        task.wait(2)
    until oldJob ~= game.JobId
end

local function formatNumber(number)
    return tostring(number):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

function add_suffix(inte)
    local gems = inte
    local gems_formatted

    if gems >= 1000000000000 then  -- if gems are greater than or equal to 1 trillion
        gems_formatted = string.format("%.1ft", gems / 1000000000000)  -- display gems in trillions with one decimal point
    elseif gems >= 1000000000 then  -- if gems are greater than or equal to 1 billion
        gems_formatted = string.format("%.1fb", gems / 1000000000)  -- display gems in billions with one decimal point
    elseif gems >= 1000000 then  -- if gems are greater than or equal to 1 million
        gems_formatted = string.format("%.1fm", gems / 1000000)  -- display gems in millions with one decimal point
    elseif gems >= 1000 then  -- if gems are greater than or equal to 1 thousand
        gems_formatted = string.format("%.1fk", gems / 1000)  -- display gems in thousands with one decimal point
    else  -- if gems are less than 1 thousand
        gems_formatted = tostring(gems)  -- display gems as is
    end

    return gems_formatted
end


function sendUpdate()
	request({
		Url = getgenv().Settings["Webhooks"]["Webhook"],
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = game:GetService("HttpService"):JSONEncode{
            ["content"] = "",
            ["embeds"] = {
			    {
			      ["title"] = "Server Hop Stat Update",
			      ["description"] = "Successfully Broke Everything In Server. Hopping To New Server!",
			      ["color"] = 5814783,
			      ["fields"] = {
			        {
			          ["name"] = "Stats: ",
			          ["value"] = ":clock1: **Took:** ``"..TimeElapsed.."s``\n:gem: **Earned:** ``"..formatNumber(GemsEarned).."``\n:gem: **Total Gems:** ``"..formatNumber(Library.Save.Get().Diamonds).."``\n:clock1: **Time:** <t:"..os.time()..":F>"
			        }
			      },
			      ["author"] = {
			        ["name"] = "Mystic Farmer - Stats"
			      }
			    }
			  }
			  }
	})
end

function Teleport(x, y, z)
    local character = game:GetService("Players").LocalPlayer.Character or game:GetService("Players").LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    CurrentPosition = character:WaitForChild("HumanoidRootPart").CFrame
    task.wait()

    humanoidRootPart.CFrame = CFrame.new(x, y, z)
end

function get_coins_in_area(area)
    local allCoins = Invoke("Get Coins") -- this gets every coin in the world you are in
    local coinsInArea = {} -- Make a blank list that will store all the ids of the coins in the area
    
    for coinid,coindata in pairs(allCoins) do -- Loop through every coin in the world
        if coindata.a == area and not string.find(coindata.n, "Chest") then -- if the area the coin is in is in the area you specify then...
            table.insert(coinsInArea, coinid) -- add the coin id to the coinsinarea table
        end
    end
    return coinsInArea
end

function FrTeleportToWorld(world, area)
    local Library = require(game:GetService("ReplicatedStorage").Library)
    Library.WorldCmds.Load(world)
    wait(0.25)
    local areaTeleport = Library.WorldCmds.GetMap().Teleports:FindFirstChild(area)
    Library.Signal.Fire("Teleporting")
    task.wait(0.25)
    local Character = game.Players.LocalPlayer.Character
    local Humanoid = Character.Humanoid
    local HumanoidRootPart = Character.HumanoidRootPart
    Character:PivotTo(areaTeleport.CFrame + areaTeleport.CFrame.UpVector * (Humanoid.HipHeight + HumanoidRootPart.Size.Y / 2))
    Library.Network.Fire("Performed Teleport", area)
    task.wait(0.25)
end

function FrTeleportToArea(world, area)
local areaTeleport = Library.WorldCmds.GetMap().Teleports:FindFirstChild(area)
    local Character = game.Players.LocalPlayer.Character
    local Humanoid = Character.Humanoid
    local HumanoidRootPart = Character.HumanoidRootPart
    Character:PivotTo(areaTeleport.CFrame + areaTeleport.CFrame.UpVector * (Humanoid.HipHeight + HumanoidRootPart.Size.Y / 2))
    Library.Network.Fire("Performed Teleport", area)

end

function fruitFarm()
    FrTeleportToWorld("Pixel", "Pixel Vault")
    wait(0.3)
    Fire("Performed Teleport")
    create_platform(3587.14, -38, 2456.29)
    wait(0.1)
    Teleport(3587.14, -35, 2456.29)
    wait(2)
    while 1 do
        wait(1)
        PETS = Library.Save.Get().PetsEquipped
        newP = {}
        for i, v in pairs(PETS) do
            table.insert(newP, i)
        end

        local pixel_coins = get_coins_in_area("Pixel Vault")
        for i, v in pairs(pixel_coins) do
            attack_coin(v, newP)
            wait(0.05)
            wait_until_broken(i)
        end
        if GetOranges() >= 180 then
            break
        end
    end
end
------------------------------------------------------------------------------------------------------------------------
--claim gifts
local redeemgift = coroutine.create(function()
    while 1 do
        wait(1)
        for _,v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.FreeGifts.Frame.Container.Gifts:GetDescendants()) do
            if v.ClassName == "TextLabel" and v.Text == "Redeem!" then
                local giftName = v.Parent.Name
                local number = string.match(giftName, "%d+")
                Invoke("Redeem Free Gift", tonumber(number))
            end
        end
    end
end)
coroutine.resume(redeemgift)
--x3 damage
boostco = coroutine.create(function()
    while 1 do
        wait(2)
        if getgenv().Settings["Boosts"]["Self Boost"] then
            boostName = "Triple Damage"
            local activeBoosts = Library.Save.Get().Boosts
            found = false
            for i, v in pairs(activeBoosts) do
                if i == boostName then
                    found = true
                end
            end
            if not found then
                Fire("Activate Boost", boostName)
            end
        end
        if getgenv().Settings["Boosts"]["Server Boost"] then
            boostName = "Triple Damage"
            found = false
            for i, v in pairs(Library.ServerBoosts.GetActiveBoosts()) do
                if i == boostName then
                    found = true
                end
            end
            if not found then
                Fire("Activate Server Boost", boostName)
            end
        end
    end
end)
coroutine.resume(boostco)
------------------------------------------------------------------------------------------------------------------------
--check fruits
if GetOranges() <= 120 then
    fruitFarm()
end

--check if mine collapsed
local isInDiamondMine = Library.WorldCmds.Get()
if isInDiamondMine == "Diamond Mine" then
    print('in diamond mine!')
else
    local success, failed = pcall(FrTeleportToWorld, 'Diamond Mine', 'Mystic Mine') --tries to tp in mine, if not allowed, serverhop
    if success then
        print('Successful tp')
        wait(1)
    end
    if not success then
        -- pcall(serverHop)
        pcall(FrTeleportToWorld, 'Spawn', 'Shop')
    end
end

create_platform(9043.19, -32, 2424.63)
wait(0.1)
create_platform(8658.12, -32, 3020.79)

--start
--get pets
PETS = Library.Save.Get().PetsEquipped
newP = {}
for i,v in pairs(PETS) do 
    table.insert(newP, i) 
end

Fire("Performed Teleport")
wait(0.5)
local farm = coroutine.create(function()
    while true do
        wait(0.1)
        Teleport(9043.19, -30, 2424.63)
        --get coins in mystic mine
        AllC = Invoke("Get Coins")
        AllNeededCoinsChest = {}
        for i, v in pairs(AllC) do
            if v.a == "Mystic Mine" then
                -- if string.find(v.n, "Giant Chest") then
                    AllNeededCoinsChest[i] = v
                    print(tostring(v.n))
                -- end
                if string.find(v.n, "Giant Chest") then
                    AllNeededCoinsChest[i] = v
                    print(tostring(v.n))
                end
            end
        end

        --break Chest in mystic mine
        for i, v in pairs(AllNeededCoinsChest) do
            local v86 = Invoke("Join Coin", i, newP)
            for v88, v89 in pairs(v86) do
                Fire("Farm Coin", i, v88);
                -- print(i, v88)
                -- print(newP)
            end
            while 1 do
                wait(0.04)
                AllC = Invoke("Get Coins")
                f = false
                for i2,v2 in pairs(AllC) do
                    if i2 == i then f = true end
                end
                if not f then break end
            end
        end

        --break coins in mystic mine
        AllC = Invoke("Get Coins")
        AllNeededCoins = {}
        for i, v in pairs(AllC) do
            if v.a == "Mystic Mine" then
                AllNeededCoins[i] = v
                print(tostring(v.n))
            end
        end

        for i, v in pairs(AllNeededCoins) do
            attack_coin(i, newP)
            task.wait(0.04)
        end

        wait(0.1)
        Teleport(8658.12, -30, 3020.79)

        Fire("Performed Teleport")
        wait(0.5)
        AllC = Invoke("Get Coins")
        AllNeededCoinsCyber = {} --only destroy chest in Cyber Cavern
        for i, v in pairs(AllC) do
            if v.a == "Cyber Cavern" then
                AllNeededCoinsCyber[i] = v
                print(tostring(v.n))
            end
        end
        --break coins in cyber cavern
        for i, v in pairs(AllNeededCoinsCyber) do
            attack_coin(i, newP)
            task.wait(0.04)
        end
    end

    wait(5)
end)
coroutine.resume(farm)

--end
wait(2)
while true do
    local EndingGems = Library.Save.Get().Diamonds
    GemsEarned = EndingGems - StartingGems
    pcall(sendUpdate)
    wait(600)
end
