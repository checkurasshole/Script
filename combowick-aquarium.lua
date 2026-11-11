-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/db9d09cdfde9573ecc93b2ee6d1e0c5b",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ef2b29e1af6a22d0bd693f63ee2f41c2",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a117e164317c90028fed338d9b15828e",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1c1f20225922a9a48fc35ffc423454b3",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/23983a3208efd2633879b913ff9ad0a6",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/48460fbb05fb82f54c16ff5e820900c4",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0778b5fb5d4d4deb8f16a908f31badc2",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c08bf5923de550d8624444e2316b7fff",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/af752a8aca43a8b5c30efe83f67439b8",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b34b072f9abefc289bd5b414ff66334c",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bcb4ce68f35335efd74fb0aae38cfffd",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6ef70663a2e8e8b827d12bfd5255dd18"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
