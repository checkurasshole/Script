-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7278a55bfb78906757b61703c1c08654",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c311be8a3ea505de1e6bab47dd4acb54",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d9e5144026f311e712fe0856e81f6a72",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bc0dd83aede36ac25a0719459cd0bf3e",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8da7eb51ceaebe06f412c8342d10d528",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7537c6d7b2c78c3f2e2cc77daf65a7ac",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5a99df5ed8136fac414754f4144c5880",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6258faca73808bc228e5b64d399a03df",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3ecd2b7b18c7f5a04d7326f856cc97e8",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7993858dc3da73dcdda79485585db18f",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/fa6125df24c7d9ce5884886999e9f16c",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/65e020125d9c0edc97d07c321a8b3894"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
