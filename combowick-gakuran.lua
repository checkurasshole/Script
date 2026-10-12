-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a5ee0c4a7c4078b2c349272cf6b175b0",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/05915c9403214f4881a9887c75d41641",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/340f96c63eff928a7f6c55c663b552b5",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0b2a49c7f682070034313f330d490ee2",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/fc09c8f3ab0e23d08046dfbf7a7f43eb",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/64edc51622de805e2e18fd0b99f0beb7",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bf8d81aa13d2e1aa0a3b6d084f537ea6",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/51474729de1a8bf72936563ec38fd8fa",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/daac90196e375b9f790b3aa35faae59e",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/223a03d9d26f9ef32b66ab2c9dec9b98",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/327361ffc4d913e0e52d555a2131d91f",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0afa561e56eecb50207d565265c41db9"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
