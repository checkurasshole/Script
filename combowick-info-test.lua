-- COMBOWICK Info Tab — TEST BUILD (run in-game, verify, THEN it ships to the module)
-- This is the exact block that will become M.buildInfoTab(Window) in the loader module.
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
if _G.__cwInfoTest then pcall(function() _G.__cwInfoTest:Unload() end) end
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
_G.__cwInfoTest = Library
Library.ShowCustomCursor = false

local Players         = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local Stats           = game:GetService("Stats")
local Marketplace     = game:GetService("MarketplaceService")
local lp              = Players.LocalPlayer

-- >>> your links <<<
local DISCORD = "https://discord.gg/YOUR_INVITE"   -- replace with your real Discord invite
local WEBSITE = "https://keys.combowick.com"

local Window = Library:CreateWindow({
    Title = "COMBO_WICK", Footer = "Info Tab Test", NotifySide = "Right",
    ShowCustomCursor = false, AutoShow = true, Size = UDim2.fromOffset(520, 400),
})
local function notify(m) pcall(function() Library:Notify({ Title = "COMBO_WICK", Description = tostring(m), Time = 4 }) end) end

-- ===================== INFO TAB (the shippable block) =====================
local InfoTab = Window:AddTab("Info", "user")

-- USER (left)
local UserBox = InfoTab:AddLeftGroupbox("User")
pcall(function()
    UserBox:AddImage("cw_avatar", {
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. lp.UserId .. "&w=150&h=150",
        Height = 96,
    })
end)
UserBox:AddLabel("User: " .. lp.DisplayName .. " (@" .. lp.Name .. ")")
UserBox:AddLabel("UserId: " .. tostring(lp.UserId))
local execName = "Unknown"
pcall(function()
    if identifyexecutor then
        local n, v = identifyexecutor()
        execName = tostring(n) .. (v and (" " .. tostring(v)) or "")
    end
end)
UserBox:AddLabel("Executor: " .. execName)
local sessLbl = UserBox:AddLabel("Session: 0s")

-- SESSION (right)
local SessBox   = InfoTab:AddRightGroupbox("Session")
local gameLbl   = SessBox:AddLabel("Game: loading…")
local playerLbl = SessBox:AddLabel("Players: -")
local pingLbl   = SessBox:AddLabel("Ping: - ms")
SessBox:AddLabel("Job ID: " .. string.sub(tostring(game.JobId), 1, 12) .. "…")
SessBox:AddDivider()
SessBox:AddButton({ Text = "Copy Job ID", Func = function() pcall(function() setclipboard(tostring(game.JobId)) end); notify("Job ID copied!") end })
SessBox:AddButton({ Text = "Rejoin Server", Func = function() pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp) end) end })

-- LINKS (left, below user)
local LinkBox = InfoTab:AddLeftGroupbox("Links")
LinkBox:AddButton({ Text = "Copy Discord", Func = function() pcall(function() setclipboard(DISCORD) end); notify("Discord copied!") end })
LinkBox:AddButton({ Text = "Copy Website", Func = function() pcall(function() setclipboard(WEBSITE) end); notify("Website copied!") end })

-- game name (async, best-effort)
task.spawn(function()
    local ok, info = pcall(function() return Marketplace:GetProductInfo(game.PlaceId) end)
    pcall(function() gameLbl:SetText("Game: " .. ((ok and info and info.Name) or "Unknown")) end)
end)

-- live updates (session timer, player count, ping) — self-stops when GUI unloads
task.spawn(function()
    local start = os.clock()
    while _G.__cwInfoTest == Library do
        local ok = pcall(function()
            local secs = math.floor(os.clock() - start)
            local mm, ss = math.floor(secs / 60), secs % 60
            sessLbl:SetText("Session: " .. (mm > 0 and (mm .. "m " .. ss .. "s") or (ss .. "s")))
            playerLbl:SetText("Players: " .. #Players:GetPlayers() .. "/" .. tostring(Players.MaxPlayers))
            local ping = "-"
            pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            pingLbl:SetText("Ping: " .. tostring(ping) .. " ms")
        end)
        if not ok then break end
        task.wait(2)
    end
end)

notify("Info tab loaded — open the Info tab to check it!")
