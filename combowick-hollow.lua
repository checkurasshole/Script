-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/10a6582e69a67910cc96c54a561d6b2e",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1774e93566839b6283b1f3cc01927749",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d970c99adbdfb31e15b6eac42fd4ef2c",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/52878b223c588ba9e4d63c687fd1904a",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/972a2433ea67d521ca41db8b1cc0d568",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0a82b2db03ec7e7a79fc92fc4c4e8f12",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5ee3988ff55abcefc176e556ca2a9a14",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f6452241d9d52cc4ec1350ad9c5f390f",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/be861bbea3a8052e680dd76540688631",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7393bacb8cc7b7665b1a8b04c4c2c775",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/baae3c14f8cb51e2169524994b0763d9",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/744334f67a46a311cfad1697224a77cd"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
