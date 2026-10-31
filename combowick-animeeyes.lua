-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1bdd0f4ea55a9fc688a70ba775e69e12",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5a96a962ed332fb066ac107a1a48b121",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/22c560d37b11e5c2a7e683d4628e4f85",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e61c7e809c422534a7f57b405924bade",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8b49caae16e40db54cd8cf2b1e1c038f",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8aa04e9d5ccbdc2f37d2ad11ecc2903a",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4fba492a2a00a8dc534ce75f5d9874c6",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b94a3b5d307f3e5ecbfdf3c746b00b58",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/09bed2c0f5f85203752a937a10de9a3c",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0f581430b92ac06c1db88bc96f9bb2cd",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a1ec0472e5d30e0136ae3883e72a9701",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f3d9c59a44250ed8b3acab33ad225199"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
