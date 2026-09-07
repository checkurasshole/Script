-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

-- Script links for each language
local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/94cb8d3afa8ae7f64bca0940f6f40e7f",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/79b975caca615f76380ea8aa97570f66",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9f148db2f8d62e0953fef7c250175a03",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4e7c98e2422181210edc71f9771dfcde",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a1659bae26af5175530e7df011831d25",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ae1a488dc40d0b0f222fd5f4c02fe457",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3c46e74d61e3fdb2085c1f0de3c72dc8",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c4f4c23ed2cb9736930acc8816344538",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/99b66f96f8f7f009037464a971d3759f",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5ec5ef24b13313c797bf3cdcc70d8607",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9988f95d216130109f8e6633f9af7316",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/439271281dbbf38e629c3aa61d0a1cfb"
}

-- Free-session auto-unload: when the loader ends the free session it flips
-- _G.COMBOWICK_ACTIVE from true -> false. Watch for that and tear down the loaded
-- script's Obsidian GUI (every language sets _G.__stealLib = its Library, and
-- _G.__CW_CLEAN = its cleanup fn), so the menu doesn't linger after the timer.
-- The loader sets COMBOWICK_ACTIVE true shortly after it loads us, so wait for that
-- first; if it never turns on, this isn't a timed free session and we bail.
task.spawn(function()
    local waited = 0
    repeat task.wait(0.5); waited = waited + 0.5 until _G.COMBOWICK_ACTIVE == true or waited >= 15
    if _G.COMBOWICK_ACTIVE ~= true then return end
    repeat task.wait(1) until _G.COMBOWICK_ACTIVE == false
    pcall(function() if _G.__CW_CLEAN then _G.__CW_CLEAN() end end)
    pcall(function() if _G.__stealLib then _G.__stealLib:Unload() end end)
    pcall(function() if getgenv and getgenv().Library then getgenv().Library:Unload() end end)
end)

-- Initialize the language selector
local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)

-- If no language was auto-loaded, show the GUI
if not autoLoaded then
    selector:CreateGUI()
end
