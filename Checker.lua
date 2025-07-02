local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Modules
local ItemModule = require(ReplicatedStorage:WaitForChild("Item_Module"))
local MutationHandler = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("MutationHandler"))

-- Calculate plant/fruit value
local function CalculatePlantValue(obj)
	local itemStr = obj:FindFirstChild("Item_String")
	local itemName = itemStr and itemStr.Value or obj.Name
	local variant = obj:FindFirstChild("Variant")
	local weight = obj:FindFirstChild("Weight")
	if not variant or not weight then return 0 end

	local itemData = ItemModule.Return_Data(itemName)
	if not itemData or #itemData < 3 then return 0 end

	local baseValue = itemData[3]
	local weightFactor = itemData[2]
	local variantMultiplier = ItemModule.Return_Multiplier(variant.Value)
	local mutationMultiplier = MutationHandler:CalcValueMulti(obj)
	local base = baseValue * mutationMultiplier * variantMultiplier
	local ratio = weight.Value / weightFactor
	local clamped = math.clamp(ratio, 0.95, 1e8)
	return math.round(base * clamped * clamped)
end

-- Inventory checker
local function getInventoryItems()
	local items = {}
	for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
		table.insert(items, tool)
	end
	local char = LocalPlayer.Character
	if char then
		for _, tool in ipairs(char:GetChildren()) do
			if tool:IsA("Tool") then
				table.insert(items, tool)
			end
		end
	end
	return items
end

local function checkInventoryValue()
	local items = getInventoryItems()
	local totalValue = 0
	local count = 0
	for _, item in ipairs(items) do
		local value = CalculatePlantValue(item)
		if value > 0 then
			totalValue += value
			count += 1
		end
	end
	return totalValue, count
end

-- Farm value checker
local function findLocalPlayerFarm()
	local farms = workspace:WaitForChild("Farm", 9e9)
	for _, farm in ipairs(farms:GetChildren()) do
		local important = farm:FindFirstChild("Important")
		if important then
			local data = important:FindFirstChild("Data")
			if data and data:FindFirstChild("Owner") and data.Owner.Value == LocalPlayer.Name then
				return farm
			end
		end
	end
	return nil
end

local function getAllFarmPlants()
	local items = {}
	local myFarm = findLocalPlayerFarm()
	if myFarm then
		local important = myFarm:FindFirstChild("Important")
		local plants = important and important:FindFirstChild("Plants_Physical")
		if plants then
			for _, plant in ipairs(plants:GetChildren()) do
				table.insert(items, plant)
			end
		end
	end
	return items
end

local function checkFarmValue()
	local farmPlants = getAllFarmPlants()
	local totalValue = 0
	local count = 0
	for _, plant in ipairs(farmPlants) do
		local value = CalculatePlantValue(plant)
		if value > 0 then
			totalValue += value
			count += 1
		end
	end
	return totalValue, count
end

-- Most expensive fruit checker
local function findMostExpensiveFruit()
	local farmFolder = workspace:FindFirstChild("Farm")
	if not farmFolder then return nil, nil, 0 end

	local highestValue = 0
	local bestFruit = nil
	local ownerName = nil

	for _, farm in pairs(farmFolder:GetChildren()) do
		local important = farm:FindFirstChild("Important")
		if important then
			local plants = important:FindFirstChild("Plants_Physical")
			local data = important:FindFirstChild("Data")
			local owner = data and data:FindFirstChild("Owner")
			local ownerVal = owner and owner.Value or "Unknown"

			if plants and ownerVal ~= LocalPlayer.Name then
				for _, plant in pairs(plants:GetChildren()) do
					local fruitsFolder = plant:FindFirstChild("Fruits")
					if fruitsFolder then
						for _, fruit in pairs(fruitsFolder:GetChildren()) do
							local val = CalculatePlantValue(fruit)
							if val > highestValue then
								highestValue = val
								bestFruit = fruit
								ownerName = ownerVal
							end
						end
					end
				end
			end
		end
	end

	return bestFruit, ownerName, highestValue
end

local function getFruitPosition(fruit)
	if not fruit then return nil end
	for _, child in pairs(fruit:GetChildren()) do
		if child:IsA("BasePart") then
			return child.Position
		end
	end
	return nil
end

-- Data return for Rayfield
local function getData()
	local invValue, invCount = checkInventoryValue()
	local farmValue, farmCount = checkFarmValue()
	local bestFruit, owner, fruitValue = findMostExpensiveFruit()
	local fruitPosition = getFruitPosition(bestFruit)
	local distance = fruitPosition and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (fruitPosition - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or nil

	return {
		Inventory = {
			TotalValue = invValue,
			Count = invCount
		},
		Farm = {
			TotalValue = farmValue,
			Count = farmCount
		},
		MostExpensiveFruit = {
			Fruit = bestFruit,
			Owner = owner,
			Value = fruitValue,
			Distance = distance
		}
	}
end

-- Main loop to provide data periodically
local Data = {}
task.spawn(function()
	while true do
		Data = getData()
		task.wait(2) -- Update every 2 seconds
	end
end)

return {
	GetData = function() return Data end
}
