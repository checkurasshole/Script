-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2cb8d99a5bdedc2efc8f65a1a12dbef1",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/af971ac39478f4b337e2531d631a1072",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d37e09a2444476771d877db9e3e4a4ad",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0e2dd48e3471da22507fb45b93aaadf2",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/70296b0d316d1e41db8718d5c5b207c6",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/1164f66bfdd0698bc478fd5660786d41",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f485f3ebb4436a9e5b670ba257c73e14",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c103c128f2af9f58b0c4ff93edfe69a7",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6685b29089df6dbb3745a07b77e3d665",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/07d636fb63b164e7e8976e44c7efb7f8",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/90d239b4b1ef334018601e9c18959567",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8d55c8780c1a70da5cb976f0708753b2"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
