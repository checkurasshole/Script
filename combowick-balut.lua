-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7037d671d4fc1deb945be5896d0de5e1",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/86c0e1f86504bd9663fc8fa8ddfd2660",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9fb90982629fbf2e0b043f8836d8af73",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/21f5b4d4f7652a812187d01035db0b8f",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c98cb5576043e99721c996adb79450c1",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/be0374d9ed0ca9b6ad37b5b3d55e0208",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c0a73ef01493c48c077d6ca723268e08",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/40165f8e9531da0c0f6ff4654c0bdc84",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/aaae03726bfc54cba83543d401be3870",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f307228c932a11f2d27a073f539066e4",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e96530ddce12842e28ac366c9744f05a",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3acfc4910aa1d96672d664212366e581"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
