-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/63a46999b0c3a007b75a2212308cf82d",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/73e216d1cbf85f803ec794864cfbd48b",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/322dff996d7ca6587be86a15e1bbd47b",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/fe0e051997f847dee8efa11e29f4236d",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/df889f35e93e4bab5a11180fd72f2c41",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/04491c53ab2acbe425663c004dba9d6f",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a69773e3f1f7fdf3a53750fdc11e7896",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f214b3220ba167eb5a5d87abaceae0af",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/62efdaa1b316c4c165ed72f8e64f62ec",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/62ad4ee28f9f4ef44f26eb6bc3be6ed3",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7190e4bb6deb48845e0a0d41fe16311e",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/fedf5ecd1aecefdeadadd478081af2a0"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
