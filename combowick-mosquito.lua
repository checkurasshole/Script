-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/827ec423cfdc48a6c0581d9d4de93d02",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7bc7220940b5e730b06c592b867f7cb3",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/835b83dd0e12cfce21ec0dfa7e679403",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/065b3add477ff13f9be555ec351d07f5",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/62a34629453866447a3c871d4d909c31",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4efcdfab73da782a67295abbdde13d56",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/cde8554a5c547a92753a3bcd082d83a4",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d310275545e92ecf1f4c0189fffb8c33",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4375d269b1e9f089255793c077639af2",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a56782ea4aaee521515d699ce0e29a59",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/91039ac3ff9c33aa3663221e739aab97",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/02d95154ad792980f0d00afb064cbc33"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
