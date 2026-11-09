-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6768963ad75d46f04396a1ccdf95f403",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b13d79db1c3c335dae88f94175c8459f",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/578a0bd2f62003b99223e6adbf1c0ab8",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ac620d8aed8fc1231ea17df0c4174029",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4f6ebb33a3cfff498cd08b60fb5bef07",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b1d865f1d94f25a55689f28d71d3ae5b",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6de533794a221bea5559cbf95e072b04",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/81307704d7a047da1c91e0ef7078aae6",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6b468b6e021b247b1afdd39dd6e6a6f0",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/47e131a439135d2a012128a7567a8386",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/47da2aaf1f9b048b1c429aced73755dd",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2a7caa1247e7ffa696243899ed9c351f"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
