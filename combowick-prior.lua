-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/29f785e3ed82888742a156ef88e8a2fd",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/78b861ab33755bcb561f976ecaa76b86",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/32a9bbc041c25ecc0b94ec48af308834",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a2a22388cfa4b1b5f428babc13f2dca1",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/edc000ae7ea0ad91ebcc72a76027f95c",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/cc1572f1a586d55cbdf230c2639b5bc0",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e5dc4c26e3ff301e4d5afc099b82d07a",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/413fd14f94ecd9b6326f6ea178d9f58a",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/774562ecdc5664db189213d57675c470",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d346162578c167167c49b27aa112c826",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/55fd82877332a957641357330554d79d",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/68deb0abd3ff965ab1fc68a8ec1c4fe2"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
