-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3a83a8ca88702c32bb0670fa1ef0d15a",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1fd4182e2c7846eac3eb1a68b18bab23",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8296ca2cf125869541889553c9b6b276",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e025b422ec50c791b95b7c6612bdd725",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3d49d5489b3731e952a0b65e55295349",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2e8ae7032c4b78ddbb7ca8c68791cd5f",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/69007bfe70658ed434f6dba0e3ddcc45",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/85790b2a90002698830dede823f0b084",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4980e89449c8ddc75032e01a2572df7e",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/cdd30bfba0ceb0e8d0c943c40ef8ae08",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/314293d5ab9b098629343592b514c237",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/81bc25068d4556ece123fcdd7cc0f368"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
