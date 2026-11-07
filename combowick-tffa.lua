-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/eacf4fa32735afd0c77eadb8ac0cd93e",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b7acfb34053d12acf4caf46ab2ba4c12",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/53515fd8464c2dbdd13fe63d71dbfa62",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f9d44ddd2ce6811035e7f526cccdf972",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/349f59aaf62d7c51f9559faf2baded3b",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/de72d4530c24f0e93937da39171900ee",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2b292a2f57cd8fd2508407ab177a1579",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/71b3eba35f865fae9add84694e875193",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/562126f7064fb7e9c9c51a5fa2a73703",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4e32a2dfd75835c48fe55681fe13263a",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/320975688b3d8b45166bbe67901b87b2",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a4c4e4e027479d98b02065bf8c97d75d"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
