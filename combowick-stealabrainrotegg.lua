-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

-- Script links for each language
local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ca51ba3e4b0d83cdfd9b449cbecad095",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c77197c89d1dcad40cb777d0fa67f3f1",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4784f24f9a11617e1364dce8be7ac089",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/308c564d1baedb81ef10e762e2d9e20a",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a8f33f3cfece06e3a84e7be698a29ab7",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a37505326d3e45df32b0ec2161f526a5",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/dd9e5afc1f290f79fbf5a6730db1ac24",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d7824cd69627110e3491513baa406889",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/5393c26b68fffe3a05164a4904b7542c",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e1b4e4b94eba60f0765e2d77c6b5d7d0",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3cdc27ca90b16da91bffe2b1005031f3",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/369430afc3c8077f6dc61befacf7275d"
}

-- Initialize the language selector
local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)

-- If no language was auto-loaded, show the GUI
if not autoLoaded then
    selector:CreateGUI()
end
