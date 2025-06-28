-- Speed Override Script (GitHub Version)
-- This script should be uploaded to GitHub and accessed via raw link

local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local LocalPlayer = Players.LocalPlayer

-- Configuration
local CONFIG = {
	enabled = false, -- Start disabled by default
	walkSpeed = 50,
	jumpPower = 100,
	debugMode = false,
}

-- Connection storage
local connections = {}
local heartbeatConnection = nil

-- Get current character and humanoid
local function getCharacterAndHumanoid()
	local character = LocalPlayer.Character
	if not character then
		return nil, nil
	end

	local humanoid = character:FindFirstChild('Humanoid')
	return character, humanoid
end

-- Safely apply speed settings
local function applySpeedSettings()
	if not CONFIG.enabled then
		return
	end

	local character, humanoid = getCharacterAndHumanoid()
	if not character or not humanoid then
		return
	end

	-- Only update if values are different to prevent constant updates
	if humanoid.WalkSpeed ~= CONFIG.walkSpeed then
		humanoid.WalkSpeed = CONFIG.walkSpeed
	end

	if humanoid.JumpPower ~= CONFIG.jumpPower then
		humanoid.JumpPower = CONFIG.jumpPower
	end
end

-- Clean up all connections
local function cleanup()
	for _, connection in pairs(connections) do
		if connection then
			connection:Disconnect()
		end
	end
	connections = {}
	
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

-- Handle character spawning
local function onCharacterAdded(character)
	if not CONFIG.enabled then return end
	
	-- Clean up old connections first
	cleanup()
	
	-- Wait for humanoid to load
	local humanoid = character:WaitForChild('Humanoid')

	-- Apply initial settings
	task.wait(0.1)
	applySpeedSettings()

	-- Monitor for external changes and reapply our settings
	connections.walkSpeedChanged = humanoid:GetPropertyChangedSignal('WalkSpeed'):Connect(function()
		if CONFIG.enabled and humanoid.WalkSpeed ~= CONFIG.walkSpeed then
			humanoid.WalkSpeed = CONFIG.walkSpeed
		end
	end)

	connections.jumpPowerChanged = humanoid:GetPropertyChangedSignal('JumpPower'):Connect(function()
		if CONFIG.enabled and humanoid.JumpPower ~= CONFIG.jumpPower then
			humanoid.JumpPower = CONFIG.jumpPower
		end
	end)
end

-- Start the speed override system
local function startSpeedOverride()
	CONFIG.enabled = true
	
	-- Connect to current and future characters
	if LocalPlayer.Character then
		onCharacterAdded(LocalPlayer.Character)
	end
	connections.characterAdded = LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

	-- Backup loop to ensure settings stay applied
	local lastUpdate = 0
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if not CONFIG.enabled then return end
		
		local currentTime = tick()
		if currentTime - lastUpdate >= 1 then
			lastUpdate = currentTime
			applySpeedSettings()
		end
	end)
end

-- Stop the speed override system
local function stopSpeedOverride()
	CONFIG.enabled = false
	cleanup()
	
	-- Reset to default values
	local character, humanoid = getCharacterAndHumanoid()
	if character and humanoid then
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
	end
end

-- Global control functions
_G.SPEED_OVERRIDE = {
	enable = function()
		startSpeedOverride()
	end,

	disable = function()
		stopSpeedOverride()
	end,

	setWalkSpeed = function(speed)
		CONFIG.walkSpeed = speed
		if CONFIG.enabled then
			applySpeedSettings()
		end
	end,

	setJumpPower = function(power)
		CONFIG.jumpPower = power
		if CONFIG.enabled then
			applySpeedSettings()
		end
	end,

	setSpeed = function(walkSpeed, jumpPower)
		CONFIG.walkSpeed = walkSpeed or CONFIG.walkSpeed
		CONFIG.jumpPower = jumpPower or CONFIG.jumpPower
		if CONFIG.enabled then
			applySpeedSettings()
		end
	end,

	isEnabled = function()
		return CONFIG.enabled
	end,

	getConfig = function()
		return CONFIG
	end,

	reset = function()
		CONFIG.walkSpeed = 16
		CONFIG.jumpPower = 50
		if CONFIG.enabled then
			applySpeedSettings()
		end
	end,
}

return _G.SPEED_OVERRIDE