local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = 'ComboChronicle Vault UPDATES',
    LoadingTitle = 'Chargement de ComboChronique Vault',
    LoadingSubtitle = 'Par COMBO_WICK',
})

-- Services
local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local Studios = workspace:WaitForChild('Studios')
local RunService = game:GetService('RunService')

-- Variables
local autoMode = false
local autoLockMode = false
local autoSpeed = 3
local currentNPCIndex = 1
local npcList = {}
local autoConnection
local lockConnection
local myStudioHitbox

-- Create Tabs
local MainTab = Window:CreateTab('Principales', 4483362458)
local AutoStealTab = Window:CreateTab('Vol automatique', 4483362458)

-- Main Tab Elements
local RemoveWallsButton = MainTab:CreateButton({
    Name = 'Supprimer tous les murs',
    Callback = function()
        removeWalls()
        Rayfield:Notify({
            Title = 'Murs enlevés',
            Content = 'Tous les murs, fenêtres et plafonds ont été enlevés',
            Duration = 3,
            Image = 4483362458,
        })
    end,
})

local AutoLockToggle = MainTab:CreateToggle({
    Name = 'Base de verrouillage automa...',
    CurrentValue = false,
    Flag = 'AutoLockToggle',
    Callback = function(Value)
        autoLockMode = Value
        if autoLockMode then
            startAutoLock()
        else
            stopAutoLock()
        end
    end,
})

-- Auto Steal Tab Elements
local AutoToggle = AutoStealTab:CreateToggle({
    Name = 'Mode automatique',
    CurrentValue = false,
    Flag = 'AutoNPCToggle',
    Callback = function(Value)
        autoMode = Value
        if autoMode then
            startAutoMode()
        else
            stopAutoMode()
        end
    end,
})

local SpeedSlider = AutoStealTab:CreateSlider({
    Name = 'Vitesse (secondes)',
    Range = { 1, 10 },
    Increment = 1,
    CurrentValue = 3,
    Flag = 'SpeedSlider',
    Callback = function(Value)
        autoSpeed = Value
    end,
})

-- NPC Functions
local function findMyBaseCompletePurchaseZone()
    for _, studio in ipairs(Studios:GetChildren()) do
        local sign = studio:FindFirstChild('Sign', true)
        if sign then
            local billboard = sign:FindFirstChildWhichIsA('TextLabel', true)
                or (
                    sign:FindFirstChild('BillboardGui', true)
                    and sign.BillboardGui:FindFirstChildWhichIsA(
                        'TextLabel',
                        true
                    )
                )
            if
                billboard
                and billboard.Text:lower():find(LocalPlayer.Name:lower())
            then
                return studio:FindFirstChild('CompletePurchaseZone', true)
            end
        end
    end
    return nil
end

local function fireClosestPromptAtPosition(position)
    local closestPrompt
    local shortestDist = math.huge
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if
            prompt:IsA('ProximityPrompt')
            and prompt.Parent:IsA('BasePart')
            and prompt.Enabled
            and prompt.HoldDuration == 0
        then
            local dist = (prompt.Parent.Position - position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closestPrompt = prompt
            end
        end
    end
    if closestPrompt then
        fireproximityprompt(closestPrompt)
        return true
    end
    return false
end

local function teleportToNPCAndFire(npcModel)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = character:WaitForChild('HumanoidRootPart')
    local npcHRP = npcModel:FindFirstChild('HumanoidRootPart')
        or npcModel:FindFirstChild('Torso')
    if not npcHRP then
        return false
    end

    local myBaseZone = findMyBaseCompletePurchaseZone()
    if not myBaseZone then
        return false
    end

    local originalCFrame = hrp.CFrame

    -- Teleport to NPC
    hrp.CFrame = npcHRP.CFrame * CFrame.new(0, 3, 0)
    task.wait(0.3)

    -- Fire proximity prompt
    local success = fireClosestPromptAtPosition(hrp.Position)
    task.wait(0.3)

    -- Return to base
    if myBaseZone and myBaseZone:IsA('BasePart') then
        hrp.CFrame = myBaseZone.CFrame * CFrame.new(0, 3, 0)
    else
        hrp.CFrame = originalCFrame
    end

    return success
end

local function updateNPCList()
    npcList = {}

    for _, studio in ipairs(Studios:GetChildren()) do
        local platforms = studio:FindFirstChild('Platforms')
        if platforms then
            for _, platform in pairs(platforms:GetChildren()) do
                for _, obj in pairs(platform:GetDescendants()) do
                    if obj:IsA('Humanoid') then
                        local model = obj.Parent
                        table.insert(
                            npcList,
                            { model = model, studio = studio }
                        )
                    end
                end
            end
        end
    end

    -- Create buttons for each NPC
    for i, npcData in ipairs(npcList) do
        local npcButton = AutoStealTab:CreateButton({
            Name = string.format(
                '[%s] %s',
                npcData.studio.Name,
                npcData.model.Name
            ),
            Callback = function()
                if not autoMode then
                    teleportToNPCAndFire(npcData.model)
                end
            end,
        })
    end
end

function startAutoMode()
    if #npcList == 0 then
        updateNPCList()
    end

    if #npcList == 0 then
        return
    end

    currentNPCIndex = 1

    autoConnection = task.spawn(function()
        while autoMode do
            if currentNPCIndex > #npcList then
                currentNPCIndex = 1
            end

            local npcData = npcList[currentNPCIndex]
            if npcData and npcData.model and npcData.model.Parent then
                teleportToNPCAndFire(npcData.model)
            end

            currentNPCIndex = currentNPCIndex + 1
            task.wait(autoSpeed)
        end
    end)
end

function stopAutoMode()
    if autoConnection then
        task.cancel(autoConnection)
        autoConnection = nil
    end
end

-- Auto Lock Base Functions
local function findPlayerStudio()
    for _, studio in ipairs(Studios:GetChildren()) do
        local sign = studio:FindFirstChild('Sign', true)
        if sign then
            local billboard = sign:FindFirstChild('BillboardGui', true)
            if billboard then
                local frame = billboard:FindFirstChild('Frame')
                local info = frame and frame:FindFirstChild('Info')
                if info and info:IsA('TextLabel') then
                    if info.Text:lower():find(LocalPlayer.Name:lower()) then
                        return studio
                    end
                end
            end

            local surface = sign:FindFirstChild('SurfaceGui', true)
            local label = surface and surface:FindFirstChildOfClass('TextLabel')
            if label and label.Text:lower():find(LocalPlayer.Name:lower()) then
                return studio
            end
        end
    end

    return nil
end

local function fireIfTouchInterestAvailable(part)
    if not part or not part:IsA('BasePart') then
        return
    end
    if not part:FindFirstChildWhichIsA('TouchTransmitter') then
        return
    end

    local bought = part:FindFirstChild('Bought')
    if bought and bought:IsA('BoolValue') and bought.Value == true then
        return
    end

    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = character:WaitForChild('HumanoidRootPart')

    firetouchinterest(hrp, part, 0)
    firetouchinterest(hrp, part, 1)
end

local function findAndStoreMyHitbox()
    local myStudio = findPlayerStudio()
    if myStudio then
        local lockPurchase = myStudio:FindFirstChild('LockPurchase', true)
        if lockPurchase then
            local hitbox = lockPurchase:FindFirstChild('Hitbox')
            if hitbox then
                myStudioHitbox = hitbox
                return true
            end
        end
    end
    myStudioHitbox = nil
    return false
end

function startAutoLock()
    lockConnection = task.spawn(function()
        while autoLockMode do
            if not myStudioHitbox or not myStudioHitbox.Parent then
                findAndStoreMyHitbox()
            end

            if myStudioHitbox then
                fireIfTouchInterestAvailable(myStudioHitbox)
            end

            task.wait(1)
        end
    end)
end

function stopAutoLock()
    if lockConnection then
        task.cancel(lockConnection)
        lockConnection = nil
    end
end

-- Remove Walls Function
function removeWalls()
    local function deleteNamedObjects(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if
                child.Name == 'Wall'
                or child.Name == 'Window'
                or child.Name == 'Ceiling'
            then
                child:Destroy()
            else
                deleteNamedObjects(child)
            end
        end
    end

    local studios = workspace:FindFirstChild('Studios')
    if studios then
        deleteNamedObjects(studios)
    end

    local blockers = workspace:FindFirstChild('Blockers')
    if blockers then
        blockers:Destroy()
    end
end

-- Initial setup
updateNPCList()

-- Auto-refresh NPC list every 30 seconds
task.spawn(function()
    while true do
        task.wait(30)
        if not autoMode then
            updateNPCList()
        end
    end
end)

-- Auto-activate ProximityPrompt
game:GetService('ProximityPromptService').PromptShown:Connect(function(prompt)
    prompt.HoldDuration = 0
end)