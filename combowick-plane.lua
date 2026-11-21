-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/895edb61c9cefdd828dff7695ba129c1",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/fe2306225f9fd843be0686f4df86f6c1",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/995acb7697b74c138ffce6b25e243bdb",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c9a9f6a804e60e7a94e85c27629f3a1d",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/96ec1929ab8f402b3d457ac56fe06cf7",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8d69ba3c23f116417fba18d59a3c3c0d",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c84b126e1fbf516fa4c4a3b05742a090",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/11a787444f95f7e90371fe37b9cca9d7",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3ab106f6feb139b91c5f07ab895725e5",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/16b48c91cb5b98743763c515933efb34",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/eb3cce3c283037e2fbd2af6135d96967",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7aa919f521e35c4738b6b602b35ab061"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
