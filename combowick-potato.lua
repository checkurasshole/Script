-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8c4ca39576df895821b339e5a9be7b47",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a2a1b4b6d6be4829dc08af99fe8dd9c2",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c5d8b13be0ec4848fa01fabaeb098d71",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/751196fb8d90c08a8b03eb430cfd6d3c",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7511e9c6ec3205290353921c9ac69014",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/512a6f9b1789acd4f55b3bbb84ff213d",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9153b56a8e21e97fbd480a0982496d82",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/670b3e6016d6e2387515413f38865b34",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b1c7e7ed39e98d3864a2f6818f9ab47f",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/21538daf9cc2cd735794acfc1b80e1be",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/52cf8c5785b0ca52e06c23b8e66b504c",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c70abdfdb7372853161c3db800564780"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
