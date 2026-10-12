-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d4813e59680987068b9a6b7b065fce1b",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4b8ce9d3416f9a56a92d26e171cd15ae",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/69b1df579ebb0dc4cb88cd9c6841eda7",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3128e4ba8a53feee3f1f12d5695594d3",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/94c8489ee474c7bc4fa0d9c5329420fe",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6109ef2cd72d2745c6b093720aee2545",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3e8f2c78c9bdf549dd902149694b1d34",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ea5e2ac11962240cdbd19b27c299a202",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8215525ee516426a076735fe5cc808f1",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d8e87c22fcc40e5ea88cf8627dc7ce1c",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/96a83b6bd61c6d85c9027eabdeb91d32",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/add229575db1cdc9c1a04f4d4e125cc9"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
