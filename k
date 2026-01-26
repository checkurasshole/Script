-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/uyh505-eng/published-content-jycoui/refs/heads/main/yeshhhh"))()

-- Script links for each language
local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6523fc5488fc4ce45b7c3ffb8d03b850",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f768d7bd0f021d568c9295dd962d96db",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0672bba1518ec4defd4c03cb13023028",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ece3d6980fb1e02d53245afdfc526636",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/302d7c9fb5fdd6ca37a9d8e701aaab1d",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/95ef03bda5b52de7ce52dd77a6648dee",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/985f84442258962e52709c93373283a6",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/82d94ffa63a74d6ff6cf72b283280b3f",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/82a13b6bd97a1f14efc5b743b3e9a19a",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/eb415e051bbd61f3f2260191f2f3431a",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7435c46eefb355cba7d0fdb12da523b1"
}

-- Initialize the language selector
local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)

-- If no language was auto-loaded, show the GUI
if not autoLoaded then
    selector:CreateGUI()
end