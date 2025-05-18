local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local LocalPlayer = Players.LocalPlayer
local CollectBatchSize = 10
local CollectBatchPause = 2

return function()
    local Character = LocalPlayer.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    local HRP = Character.HumanoidRootPart

    local collected = 0
    local prompts = {}

    -- Find farm folder
    local farmFolder = workspace:FindFirstChild("Farm")
    if farmFolder then
        for _, child in ipairs(farmFolder:GetChildren()) do
            local importantFolder = child:FindFirstChild("Important")
            if importantFolder then
                local plantsPhysical = importantFolder:FindFirstChild("Plants_Physical")
                if plantsPhysical then
                    for _, plant in ipairs(plantsPhysical:GetChildren()) do
                        local fruits = plant:FindFirstChild("Fruits")
                        if fruits then
                            for _, fruit in ipairs(fruits:GetChildren()) do
                                local prompt = fruit:FindFirstChildOfClass("ProximityPrompt")
                                if prompt and prompt.Enabled then
                                    local success, pos = pcall(function()
                                        return fruit.Position
                                    end)
                                    if success and pos and (pos - HRP.Position).Magnitude <= 20 then
                                        table.insert(prompts, prompt)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Find other prompts in workspace
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local success, pos = pcall(function()
                return obj.Parent.Position
            end)
            if success and pos and (pos - HRP.Position).Magnitude <= 20 then
                table.insert(prompts, obj)
            end
        end
    end

    -- Fire prompts in batches
    for i, prompt in ipairs(prompts) do
        if i > CollectBatchSize then
            break
        end
        pcall(function()
            fireproximityprompt(prompt)
        end)
        collected = collected + 1
        task.wait(0.1)
    end

    task.wait(CollectBatchPause)
end
