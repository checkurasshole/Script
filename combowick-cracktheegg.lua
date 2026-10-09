-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/325a1559e7f4a0809f38afcafec60bae",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1c9e0c6b7d3f3cbba34c7d87b5ab9005",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f36b085619ed44f2a36b74fc4c6c7283",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/93f10bddb4bf2be81fd49e1c216b324f",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/648184a980ac6f4376ca4b118eed1e1e",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e492e10dd54ada009e90e3e901571305",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/52fbebe259f462c1ce82cba539ba1c34",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9f2cd31a171660bed1fa90d901502f5a",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2cd374156c8920d0d8b355c8f9941371",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/fad300b3f838899de1036bab5e03f6d0",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/fdd28381b3fc74e67bfe68cb8cd33877",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/17de1fd4c796715701c0d86ba25da137"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
