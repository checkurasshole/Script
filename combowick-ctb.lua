-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d95afc9422bf63156bebdb05f5a464fa",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/eb561986492b4d987615e826bfe04dee",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/78d59ba8f352e62159dead216d7bff88",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b2f01af50ff5ad172ed7203ecc87ab38",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e52079b936beb1403ff96b845b17037d",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/509be4be7313837c3101740035423c8e",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b397310286434d7749aa023ae4beb2fe",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4416b2c55d5a6d56e5c791594811b928",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b855701c5f5be38bfd280e23a926f679",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/428aceb72fa9ba89845608444637c5ac",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4ee7e870332f7149e527399ba10d8e62",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b3bee8a2826efc5b26e3cabb9d223ac8"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
