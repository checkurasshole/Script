-- Inventory and Farm Value Checker for Rayfield
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ItemModule = require(ReplicatedStorage:WaitForChild("Item_Module"))
local MutationHandler = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("MutationHandler"))

local PlantChecker = {}

-- Value calculator function
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

-- Get inventory items
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

-- Find the LocalPlayer's farm
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

-- Get all plants from your farm only
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

-- Get inventory value and count
function PlantChecker.GetInventoryValue()
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

-- Get farm value and count
function PlantChecker.GetFarmValue()
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

return PlantChecker