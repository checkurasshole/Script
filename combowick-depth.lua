-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a0d2687fb3abc5b71229ca5eecb8fb98",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ef8a21f2843ffcf0ac1f548ae4284c38",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3751fe789c9806ae8538cf15e37b266a",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/28aaf58e1d3e00951ecab6d47d0000ea",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/aeaa77a419a3c138a16a2eb300f5de01",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/49ec87af2e1d6641e8501644ba958430",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7a1ecd3d7565a4da4c8fd12606176449",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b777332d6e9e91c997eab6394936ff03",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e94a2ec4768b3065410f89bf600fbfe5",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/153928d128a829b6910504fc0fbb8e3d",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a2d17880929c3ef563c81ebdbc4b489e",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b3daefe2abf4d8f6ceb40d5bc582abd7"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
