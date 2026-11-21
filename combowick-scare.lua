-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/aac4ec23e8302f77f0759611c2784952",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/31b9c252b9077c7f743afac5b92dbe40",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/324ba47e8db889267aa4b882c0d7c774",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/769354aa3e2ff73c4dc8e35f0595294c",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b1b4a48adb4b75b88e354ad01e7e9094",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2d4c302f3fbe33992b4ea0debfed58be",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/232164c8327d17cbea2d166f9369f567",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/16dbd344c018b5235af846be48bb57f7",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5b4d2762287e60cdcc3421cc3f685c22",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/44b3578ed70710317492fc45c4e60157",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b548ff93fb6ad73d36b12166edb7eed4",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c3e4da35f0e4d9bbf3dc3908d4a50aa3"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
