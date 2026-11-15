-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5106e230cf534e39ea0506da2be1e9a1",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e9362feb91444d0e29e5b3780c993434",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c1821daaa1fe87d888b5c00d522649a6",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e929b89abf5eea53ba63523c0bb1ebca",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/adfc210663d372a0e2a921ba3dd52406",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/828daa1b75a8e81533b6e45f332c2271",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c1c85b9aa6ea0f67e62c8c5c06696781",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9881182848e45a0d0f82ca7a215e52e8",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2073ca777e497b8df1c25ba520ec4983",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/949c2bc3ff9756c620839c5d28daaadf",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2a98a83a613b9cc142a384499c264edd",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6f57db6c9cadde13b1774a8bc5454098"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
