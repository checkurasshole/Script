-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/15fb7a6e27b6d729b1e447144ce069bc",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/71a2cd553859e366a9a2ed8c23902dad",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/93a85787a0352b45ff9a0973255c1566",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e58beb400fa271b2c4a6974b5c7bf1f7",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/cea6cef46ce78ea511b5e83b2791b2e4",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/35680ee730a98bbf6329408eadb6e0eb",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/326c47748f9f68b0f1e71171afefd8ae",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3d76f1a98917bc82684efb45e2f7abf3",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/71fbae3bb8857f1d88c6b8f4a4fba039",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3e0817d2da82996b59a84db55cfc7e9b",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8ac544d9b1eda67653115d5866c396f0",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/654ff5799b9926a896793ba314274b0f"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
