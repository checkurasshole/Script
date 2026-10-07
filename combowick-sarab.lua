-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f1598186ae6abf723b894442e6286f15",
    ["Arabic"] = "https://v0-supabase-secure-storage.vercel.app/api/script/54d98bbf030c88290449255f91ea4404",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f8b9688d923016b39188564645440b8d",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d919af9c6ccf5e82ed5804c742e34a39",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e01e7abc1492d757e4dd4d4e0baed192",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0f6b0160fd542aa35af6ce26ada19a22",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2941e4d4fdde7e2774cb889424042191",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d5d7542ca17438b8698cdc09ec119974",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a1d2435127c0e2e464bdbe447c838687",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6f02e5c6a471bf9d3b35c5464cfecc55",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6a05ae4d3d7f360bf50fec5e4eadcd4f",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/10130606c6a937bc97b3a3f560f9ccb3",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4aa0f11f0a06a3d7be281649d20667da"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
