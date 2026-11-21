-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/489f1e79ff3c51c2e9612d4d9810604f",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/01cd01d7f9619a85d67c4c1f6f133932",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d4359e787231fa6d366d8019387c00cf",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/840109385cc4bd5b297e49ff98f1ae61",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4c1920e697ab9c410391c5d93ba01bc4",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2e0aaf5f85d3c1d524e16386c501b7c2",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9b8f5c123763711c6a88ae5f6dca46d6",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/744e458c044144c20a7db541354101c2",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ec23a7e24ad3611b806c0b11291a15f3",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5ed673811a0efc45ddd0c1f1ab1614d2",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/9f3e37718f750a13a3d397e60ab8c6c9",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/92573fca829a589171ceb6b62ac05455"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
