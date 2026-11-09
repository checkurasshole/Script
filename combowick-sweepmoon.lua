-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/33d8a2f743ab42f6b26031b65708f9f8",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/92b4753f258c347c117fc3d947c10d2a",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b5fa893e1de1a553e62731ba4761cc8d",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f52f0c06a77ac2c14c0b5edaef0896b7",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7d8e873e3c8f12c2e311251d7d51d4de",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/57ff2098d984d3f5ce929669af47278d",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e9e4700d6bd2bea6059ca7770df4931c",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/66ae3c713ffe64a8fa21cdb890768185",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8a2c3975bb6d16240b3c38ba0237c661",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/99d6caf640fdfc067fa0b9b12f9d8d18",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ea944da6cc862188d55255022243d37c",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/07091e1ef00d058b436357bbdf9904dd"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
