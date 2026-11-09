-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/af35ddeb75508d8202a4458382247522",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/84b8cd48fe819ef49aa11b2e0d8b7c20",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/63518bb1d677265c11484e1dce08edcd",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/fe86227b1541de07d677efe1b0b8bb1e",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0f4c0f0f504b9b1924a50f4f567eb5fb",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/7ad1b677d99ecfccd427a3f89b548b90",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a6a8c2fc663c64a6e366ff67b2102ee1",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6b83e27cd23633f507dce200cafb27ec",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f289199a153ab8e46ea81ead479b5c5d",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/320b10c6169d0d20b45f38fc3024fdb2",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/87eb3feb877fd7def92be0542a045d93",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a7309cad3521df6aad7b05f67152998c"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
