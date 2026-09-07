-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

-- Script links for each language
local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e80f181933df1a7765bcf356f345d008",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/65ad7edec769235a2650f955c8f6ec66",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b03eaef0a9a3e35f5b1ca19bc3b52683",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/784b7a9dfdc9744e8e4b094d426e19eb",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d0a1fa9dc91e14bc2c9fa419e95f8e6f",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/62c7ae24041422842787c704ffb7f067",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e054e2e04aba8cb15f607213fa764301",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/97b5feeb7be62b13076aecef9e0a8538",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7970e4d872612466b0bf8543d86ffbda",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b6f650c44a18105be613705b43f28e20",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ca9188c7bd10306928aa08e92614d57d",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/eab44add3e841ff8d5c70489f5b2b52d"
}

-- Initialize the language selector
local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)

-- If no language was auto-loaded, show the GUI
if not autoLoaded then
    selector:CreateGUI()
end