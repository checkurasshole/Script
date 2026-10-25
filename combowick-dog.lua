-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3e2e09b69d0417f2a01b8da8e52fb8b5",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a6906bdb3ce3984a5cc2a30e3d611733",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/29745c359c42f1cc8a5352a1e0add67e",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1e9f0f6662c7cd5b60d9bc3f6f1b1fe4",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3d2ab5252ae35b613e9e0a42d9e0ddbb",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b219abe19c7481c814e8ac1276156bba",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/efdb8cc8b5b3bab9be1bd7b29be96415",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4980354cb1b28a46fe5c4c2cbe2ca37d",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/696da8143ad1c09815ab1de412ac73c4",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/972743509f15641848918cd9fa40847a",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2a3ba5d3df50a33590d7271f114bcb5c",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7c3e3b792351532ab4ae6863784e8d77"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
