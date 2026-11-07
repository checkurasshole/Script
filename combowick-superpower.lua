-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/acaa6925d7eff246b306ae7c5d004017",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bd7a547fa35206b2d9c53013bb2fe5e7",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a666d3e56d78e5f1b7bcbe525064162b",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/40d4446ef35bd4d82d1a4506ccc2ea25",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9401fa547f43d4e033b1d526e23050e6",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e6d373823d25b33167e98faea2eb74d9",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6944c6e4a1f0db70df2ec36228a96be3",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/362fd94e406b63f0c7fef847772bb923",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bea874968b54987a3d31a5b1fc41c23c",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f8cbd44fd12521fbb2c3c12d291f15df",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5bfbe72f89eedebb9b9da360b113bd4f",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ade58ebfd79d6b5cde04438d9a165b85"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
