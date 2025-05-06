local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Http = game:GetService("HttpService")
local TPS = game:GetService("TeleportService")

local Api = "https://games.roblox.com/v1/games/"

local place = game.PlaceId

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character.HumanoidRootPart

-- OTHER
local function getChunk()
	for _, obj in pairs(game.Workspace:GetChildren()) do
		if string.find(string.lower(obj.Name), "chunk") then
			return obj
		end
	end
end

local function items()
	local chunk = getChunk()

	for _, item in pairs(chunk:GetChildren()) do
		if string.find(string.lower(item.Name), "item") then
			if item.PrimaryPart then
				item.Top.CFrame = hrp.CFrame
				wait(1)
			end
		end
	end
end

local function mints()
	local chunk = getChunk()

	for _, bush in pairs(chunk:GetChildren()) do
		if string.find(string.lower(bush.Name), "mint") and bush:FindFirstChild("MintType") and not bush:FindFirstChild("Visited") then
			hrp.CFrame = bush.Main.CFrame

			local visited = Instance.new("BoolValue", bush)
			visited.Name = "Visited"

			return
		else
			Rayfield:Notify({
   					Title = "No special mint bush found!",
   					Content = "Head to your next location!",
   					Duration = 4,
   					Image = 4483362458,
			})
			return
		end
	end
end

local function deleteTrainers()
	local chunk = getChunk()

	for _, trainer in pairs(chunk:GetChildren()) do
		if trainer:FindFirstChild("#Battle") then
			trainer:Destroy()
		end
	end
end

local function deletePokeSpawns() -- to be upgraded
	local chunk = getChunk()

	for _, Spawn in pairs(chunk:GetChildren()) do
		if Spawn.Name == "Grass" or Spawn.Name == "Sand" or Spawn.Name == "MGrass" or Spawn.Name == "MiscGrass" then
			Spawn:Destroy()
		end
	end
end

local function deleteObstacles() -- to be checked
	local chunk = getChunk()

	for _, obj in pairs(chunk:GetChildren()) do
		if string.find(string.lower(obj.Name), "hackable") or string.find(string.lower(obj.Name), "smash") then
			obj:Destroy()
		end
	end
end

local function waterWalk(value)
	local chunk = getChunk()

	for _, part in pairs(chunk:GetChildren()) do
		if part.Name == "SurfWall" then
			part.CanCollide = not value
			part.CanQuery = not value
			part.CanTouch = not value
		end

		if part.Name == "Water" then
			part.CanCollide = value
		end
	end
end

-- Server
local function ListServers(cursor, servers)
  	local Raw = game:HttpGet(servers .. ((cursor and "&cursor="..cursor) or ""))
  	return Http:JSONDecode(Raw)
end

local function joinLowest()
	local servers = Api..place.."/servers/Public?sortOrder=Asc&limit=100"

	local Server, Next
	
	repeat
  		local Servers = ListServers(Next, servers)
  		Server = Servers.data[1]
  		Next = Servers.nextPageCursor
	until Server

	TPS:TeleportToPlaceInstance(place, Server.id, player)
end

local function serverHop()
	local servers = Api..place.."/servers/Public?sortOrder=Asc&limit=100"

   	local Servers = ListServers(nil, servers)
   	local Server = Servers.data[math.random(1,#Servers.data)]
   	TPS:TeleportToPlaceInstance(place, Server.id, player)
end

-- AUTO-CATCH
local autoCatching = false
local autoCatchThread = nil

local function autoEncounter(value)
	autoCatching = value

	if autoCatching and not autoCatchThread then
		autoCatchThread = task.spawn(function()
			while autoCatching do
				local chunk = getChunk()
				for _, area in pairs(chunk:GetChildren()) do
					if not autoCatching then break end

					if area.Name == "Grass" then
						for _, grass in pairs(area:GetChildren()) do
							if not autoCatching then break end

							hrp.CFrame = grass.CFrame
							task.wait(0.2)

							if player.PlayerGui.MainGui:FindFirstChild("BattleGui") then
								repeat
									task.wait(0.2)
								until not player.PlayerGui.MainGui:FindFirstChild("BattleGui") or not autoCatching
							end
						end
					end
				end
				task.wait(0.5) -- slight delay before restarting the loop
			end
			autoCatchThread = nil -- reset thread when finished
		end)
	end
end


local function interface()
	local Window = Rayfield:CreateWindow({
   		Name = "Stone Hub: PBF",
   		Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   		LoadingTitle = "Project Bronze Forever",
   		LoadingSubtitle = "by Stone Hub",
   		Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   		DisableRayfieldPrompts = true,
   		DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   		ConfigurationSaving = {
      		Enabled = true,
      		FolderName = "PBF HUB", -- Create a custom folder for your hub/game
      		FileName = "Config"
   		},

   		Discord = {
      		Enabled = true, -- Prompt the user to join your Discord server if their executor supports it
      		Invite = "jz3vFPxr", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      		RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   		},

   		KeySystem = false, -- Set this to true to use our key system
    	KeySettings = {
      		Title = "Stone Hub: PBF Key",
      		Subtitle = "Key System",
      		Note = "Join Discord Server for key", -- Use this to tell the user how to get a key
      		FileName = "StoneHubKey", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      		SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      		GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      		Key = {"SH_KEY_PBF_21783"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   		}
	})

	local Main = Window:CreateTab("Main")
	local Encounter = Main:CreateToggle({
   		Name = "Auto Encounter",
   		CurrentValue = false,
  		Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   		Callback = function(Value)
			  autoEncounter(Value)
   		end,
	})

	local Player = Window:CreateTab("Player", "person-standing")
	local Speed = Player:CreateSlider({
   		Name = "Player Speed",
   		Range = {0, 30},
   		Increment = 2,
   		Suffix = "Speed",
   		CurrentValue = 16,
   		Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   		Callback = function(Value)
			  character.Humanoid.WalkSpeed = Value
   		end,
	})
	local WaterWalk = Player:CreateToggle({
   		Name = "Water Walk",
   		CurrentValue = false,
  		Flag = "Toggle2", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   		Callback = function(Value)
			  waterWalk(Value)
   		end,
	})

	local Other = Window:CreateTab("Other", "globe")
	local Items = Other:CreateButton({
   		Name = "TP Items to Player",
   		Callback = function()
			  items()
   		end,
	})
	local Mints = Other:CreateButton({
   		Name = "TP To Special Mints",
   		Callback = function()
			  mints()
   		end,
	})
	local Trainers = Other:CreateButton({
   		Name = "Delete Trainers",
   		Callback = function()
			  deleteTrainers()
   		end,
	})
	local spawns = Other:CreateButton({
   		Name = "Delete Pokemon Spawn Areas",
   		Callback = function()
			  deletePokeSpawns()
   		end,
	})
	local Obstacles = Other:CreateButton({
   		Name = "Delete Obstacles",
   		Callback = function()
			  deleteObstacles()
   		end,
	})

	local Server = Window:CreateTab("Server", "globe")
	local Lowest = Server:CreateButton({
   		Name = "Join almost empty server",
   		Callback = function()
			  joinLowest()
   		end,
	}) 
	local RandomS = Server:CreateButton({
   		Name = "Join a random server",
   		Callback = function()
			  serverHop()
   		end,
	}) 
end
interface()
