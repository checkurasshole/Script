-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8cf88542393d06e8f1cc3c134d0cc894",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8c4e540031569f41d0457124ab1b9efc",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/66a3ef6db327a0046435036d5d290529",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/31cf83e7229e3f8c30b78d0fea650e7a",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1b490075391a1f250fe9759aef0d168f",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bf3470621f76d6c7fcbd23a5010cb7e5",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/98aa90f81f6d865f709cf215beced2c4",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a4e85597604ada816de05f452a70050d",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3c2c2c5c370d8d7d3e13fd8247390b61",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a44b18f17e37616e1302131fdd6c86b6",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8739ece18c54732db1ea79efc222aefc",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e7ea9c4b426e4c5b9b3e3c395c08a2b6"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
