-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

-- Script links for each language
local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/58a96dca1984a8acda2793cc7abc7c74",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/cfc747e45bf786c9500eaf3dba7ea691",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f5f1e64539fec4e2dfb2c45c2f33ba8b",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d96c69abaa7865ee9707d93ed9360e48",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5e1c73b8dbcb2777eaecb5d38faaa756",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/95eb424f7aa8f21a3a8a030ed7359ee2",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bd051c07c53a085cba542a1247c93f59",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/81ee10c21551f5bb41f04ac61717a8b9",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3d53aef1781ec8c1e8e8347fbf6263df",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/cabe44e455b32fe49882cc7f4c9b5c88",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/634dcd0fe06975755e20b2d80e94bb7a",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8f348d2d7642ea3844e0ffaadaa0745a"
}

-- Initialize the language selector
local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)

-- If no language was auto-loaded, show the GUI
if not autoLoaded then
    selector:CreateGUI()
end
