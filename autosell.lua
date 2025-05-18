local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local sellTargetPosition = Vector3.new(61.58625030517578, 2.999999761581421, -0.5732138156890869)

return function()
    local Character = LocalPlayer.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    local HRP = Character.HumanoidRootPart

    pcall(function()
        if HRP and HRP.Parent then
            local originalPosition = HRP.CFrame
            HRP.CFrame = CFrame.new(sellTargetPosition)
            task.wait(0.2)

            local success, err = pcall(function()
                ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Sell_Inventory"):FireServer()
            end)
            if not success then
                warn("Auto Sell failed: " .. tostring(err))
            end

            task.wait(0.2)
            HRP.CFrame = originalPosition
        end
    end)

    task.wait(60) -- Auto sell interval
end
