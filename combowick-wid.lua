-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/52077be63889b42711ee2d4cab1aa0bc",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d9dd49181c56cf6b3e07a4bc40cdfa4d",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1f31c432a37118ce0e41dcb6231b96b2",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2c26f32c08523dcb477a703afdb89c54",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/85827f62d86ff42b37a2b4e07ab4e71a",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a62eb05363315b8fe0e9afe0dd1380fa",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bdffaf9e15081a11a36b64820af53a87",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/73f76d9ab5b85288b60516facc7a0b2b",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0acd0cfef56ae9ef49bf94b573e7ad82",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/72c001858fb63705927d6808fd94a02a",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/93e913cad106f008020ceab5109ccdec",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/76dc387ad5fa58db9ea295695998ac9f"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
