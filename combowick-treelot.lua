-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/de3763b1eaa0c044e0b07ea7f98501b1",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0a8adff8f81488cf0a2d0ed5d3eba894",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8284625f64601d79a83e1dc812192270",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d54e8a5ff4dc6ca5efc740d3565549e3",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9f7bfc91c7fa914d5189e5ba5e5c5a98",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/888fc2f71995d5db174f65e45fe746ac",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e2bb0b9b84f8981dd7d85e000e3a9ad1",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ec5fb47473cdcccb1dcef89a98f59158",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d725ae345d9a08d5c376a2a4c1f80bfd",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c4b38eee164b0caa36790644da762096",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/98b0f0eee8fbb745b1e67ee1c4b3e196",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9102a56220441bdd32c810868ec0fc0f"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
