-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0956576d1ab58f0b07f32ca661564131",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/60888281356516c6b7337db111b7a855",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4ca083196c770f11ca9d275adb9c6d3d",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/da3909850b14bfeb129ba87c662732f7",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/270e289b49c271811c4936c5b92e1c32",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/88ca8ec26e70fe1d7761dd61a5b5ab75",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b62c7532992190b9a9dbb095e02bd218",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c0d33a8275642c171e643288c7d0cf42",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/90364937fd317701a4c14fcdbea4639f",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4ed85a4b5ea3b36e92657ceba61faf02",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5148cb68ad71d4ac4495a8f7d031c088",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f16dd8b588b287377883f34f2fda0980"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
