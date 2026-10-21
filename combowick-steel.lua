-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/72c28ace6c2f942b2ad5830e36613ddb",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/13519fb58ad9e79b3c2efaafe19c4678",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8cb166a01c2e6d4682f33e37424dcfb6",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/662b3ba0a6b263fc6a255bd85acad204",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d2cb97072cff0c5d6cf23ca287881496",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f5f54ca65335e55b2d42f0cd280dde49",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f61e1a59503f2f71e1c41355c4afab29",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/83fb9009dc9c2d1aa29f8f4eea24eca8",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/594a8427cf1d174e4d0fb48d291bafc7",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/31265fdb06783c24ac1afc021aba1bef",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1d37d674ae5e2fbbcc7cbbfec266ce48",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0617c34b2cf5b40757139ca30dd85de1"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
