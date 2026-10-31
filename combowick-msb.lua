-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/95ae451fdfbfc3a7470e97c204bb521a",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f758c69f24347eca809f5b5b8b7249a2",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/10e157991178f8a5a44cff712576a9b2",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7df6a1f39c4ed13241fc2bd7f8319f24",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/805ba459003cf1eadb80094d29c169f5",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a392294ca5472fb942d98a7ca0d4a9a3",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/486c66cc35300fa6846a033d651f6de2",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2b44ceb0022e9dc3156c11e62e94aac6",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/75fd12da9316f09272e84eccdcba8a6a",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/35c1644cb834715d3965dadb1fc6a262",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/30ccd180058d04297fd709a5f27ecd05",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b9ffc94cb601a3f4dae35af40d5c8956"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
