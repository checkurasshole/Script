-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a658b9489c25ecace10b0c80dc379cb7",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/91a50fcc4af168815cae3da28f792724",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/464f342e8bac085f00062db0083c6fc4",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ba8e378d77863f865d56c82a258ea766",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/751cce62bc94b0c5b4bb9c1c2c6f863c",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/258523909aa9020b95c411ad4a9fc3cf",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/dae25b064cf3618cd254fdaae49ebc52",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/668b2b0189577f104257f2551fa9030b",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0668600abdec8f1e3014ed14f68fbc40",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3136850de2551bd51b14126b1173f224",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c2fff300f0accf641ef4f1f7fa1c7210",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a71f88fdd4b1fa2b78bbaafc0e0ee047"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
