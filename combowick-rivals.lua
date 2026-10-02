-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/17a2a43e06385ed75daf0da50cb313e4",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2aa3925c3c834b6c1355c66b69f6c709",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2a7c8346c02f5132f7929be6326b9d01",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9a9c7464d7abd851ee728138a31104cd",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/160bc39e373b5a6988ef6b7c1b8d4b74",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/29684a2b313752c51452837003d1a900",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5593f930431601bee605a370aecc6978",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5ec1fa8142b235bf78f06983ffaa400d",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b1f54132b33f193368eb34f034f2677b",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1c1969ae1316cc03b4c285cf0c47dd5b",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/fbcd26b056d0cfb3017ab5e12d78b026",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/257ce772bf72b6943f9b689fbc680e42"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
