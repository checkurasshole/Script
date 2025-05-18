local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function findPlayerFarm()
    local farms = workspace:WaitForChild("Farm", 9e9)
    for _, farm in ipairs(farms:GetChildren()) do
        local important = farm:FindFirstChild("Important")
        local data = important and important:FindFirstChild("Data")
        local owner = data and data:FindFirstChild("Owner")
        if owner and owner.Value == LocalPlayer.Name then
            return farm
        end
    end
end

local function isTargetColor(part)
    if not part:IsA("BasePart") then return false end
    local targetColors = {
        Color3.fromRGB(62, 56, 86), -- Moonlit
        Color3.fromRGB(143, 1, 3)   -- Bloodlit
    }
    for _, color in ipairs(targetColors) do
        if part.Color == color then
            return true
        end
    end
    return false
end

local function teleportTo(part)
    local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if HRP and part then
        HRP.CFrame = part.CFrame + Vector3.new(0, 3, 0)
    end
end

return function()
    local Character = LocalPlayer.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local farm = findPlayerFarm()
    if not farm then
        return
    end

    local plantsFolder = farm:FindFirstChild("Important") and farm.Important:FindFirstChild("Plants_Physical")
    if not plantsFolder then
        return
    end

    for _, plant in ipairs(plantsFolder:GetChildren()) do
        local fruits = plant:FindFirstChild("Fruits")
        if fruits then
            for _, fruitGroup in ipairs(fruits:GetChildren()) do
                if isTargetColor(fruitGroup) then
                    teleportTo(fruitGroup)
                    task.wait(0.5)
                    return
                end
                for k = 1, 5 do
                    local numberedChild = fruitGroup:FindFirstChild(tostring(k))
                    if numberedChild and isTargetColor(numberedChild) then
                        teleportTo(numberedChild)
                        task.wait(0.5)
                        return
                    end
                end
                for _, deepFruit in ipairs(fruitGroup:GetChildren()) do
                    if isTargetColor(deepFruit) then
                        teleportTo(deepFruit)
                        task.wait(0.5)
                        return
                    end
                end
            end
        end
    end

    task.wait(1)
end
