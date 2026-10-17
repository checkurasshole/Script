-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9199c9b57b8a5156033bffa6942e6ef8",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/605492cdca3fa8e874706fe8b84aa6c3",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1398c3cf636549e85947d289df0b7fe0",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3b5174a892b75e2e6a2c7fc2aeb41867",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f6c0ba1d101a9e9816ba708330646e89",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ef5d058c017c8307643cf44debd2d7a7",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/831841005a2aa6911ce1a67955353343",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c32ab2dfc1dafd4bda8c49b751e3462c",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8baa93e32ee6fb8eed7102885eb4b742",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9d648006ed2a3180e5f004136b80cd89",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6b8c862679b0a3a48b8e787e516071c2",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3e19077ddf3f533f61b4e7a791f9bea9"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
