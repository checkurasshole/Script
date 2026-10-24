-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f13712b119cb35ba0d940ce3a1b47857",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6cd812c071b504cd5eebb59bb8742199",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c662916b6c9224f2f372f86ee436b791",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9f268ea45c36fdb6a30838f968608a88",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3cf03b5ccac327c088b8c0c859b3c07a",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5ab48f246ea83d5dfb1e554dbeafbb8b",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/330b60a0caa80cc3c02b3b68366ce5c9",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1921d4eab76558d26ae931b66d07a18b",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/10a6e6721ded266e55038d96e0496712",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f3cc870f1ff73f9cc66a3d54d1118806",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/fe30e6f131b409b9df77da49fdf2f0d3",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0f2358cc3362b92152d35f2096546021"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
