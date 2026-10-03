-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/91a59fc3cd91e180ca62577f64f220e6",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5dc07f2c0c827844ec23da9b74437740",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c7399f6d04954ef50dc2c8d85309313f",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2b85ec5c17401f74f99e5050630eb017",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1bf0861ed0a996799fa47bb79708bb3a",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2f5a42300f136b21424fdd3838c9b741",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f14299b46522bb2ebb211e7136fd1d40",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/73986f5c8a83fad317792c6e9008bd5f",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/fd5a59634ed3dad0a177bdc37d0a8a83",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0d5a51277803f8867a9547bf60e351f8",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ac99816355eff0c546eb2cf8db3d8611",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7a465f57027900edc2b3b9e26d35529f"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
