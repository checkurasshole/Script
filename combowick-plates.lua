-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/06ba31cf7e205ce845a239050180c45a",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d5b01c9383005e888572c71df5aa0a3e",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6fc08816ea18ddb278e717c435964721",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/dc11eb7d5ddda7e3817ea657d433f183",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f746c842623767441891e84e20b9eef8",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/85ae1a9c52f973d645b60b05640a4850",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/bb15567151abb66bee756f1832ccd5f7",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/205a2476d655d8d626507ceffac03de5",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1e5e75fe6ea253723022eb7eb60e5b3f",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2efe224422b9cae5fa0f3113f4445523",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c8c333aae67581d3ea2fa79683f686d3",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/cbb52d9d2e3129d3604828dabab664dd"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
