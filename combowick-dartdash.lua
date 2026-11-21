-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5696c78452940eb295724cf9c5979ead",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/93ad633bdc39b72cbdaff66c80af825e",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6759c3f5432fd99849fb5c63abfefaf3",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7b543a3755412af7af3c7aa3dfdfd1f2",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/16e3c3768f4dc9fe12191cef1de2fad4",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/da0f2831d16e07dacaacb3312bf19e0e",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a69af66106a6e24ef57cb481dec658cb",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a0054e00f51c5170f12c48bc0640d925",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/08f0104ee36e47eb6d887df049f4f767",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c34d459fd04212b0dd8642c97ad9bc8d",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/abb492399da91b4ff2cb4f857ab7239f",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b5428ae519e65ed5630c92e29359e27e"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
