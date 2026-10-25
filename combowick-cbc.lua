-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/70e94d64052c658ced3ca74390a1c454",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/829f9e7818b3f7effc592d20f47dc668",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c8d6fabfaeab8b4ae13b979c55d913f5",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4b84e677211b68289ed2a70b4fe8c2a6",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d0489fbd0a16b5c3095c0c227c7cf1b5",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1d24260eb3c85e27edb583df2c39d1f8",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9275b29ca795de42fea37f8012697106",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/fa52a3f162117d7ed147ede90ce1b26a",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/275df57476faf7f78c334efdddae4ae2",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2a86c0d3c6c8aa33c1e5d66cc9c32829",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/80e395f6258049c5f39f4fc8ea94486a",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/622b18fd665cc0d10f8ec36d83c299e1"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
