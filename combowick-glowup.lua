-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c38df40abcecc94b558a211fd4805ee3",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6801a24302b18abc2d1599e379441b9e",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/654e22868aa38c8e4677b85a91b18653",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/2997f02c16cf19783f958ac2e90104f1",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6e27421b253162b7d7e08351f87d7cc7",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/77af507eaddbe91527ade96a3674a996",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/c74a638e40d2a9360b5f4ac9062a1f04",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/388091dfc049a938f0da1f4eca9ef22b",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f2633f7d0cfb7b7676a6931e770f041d",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/6591cc835749fc140c95d1b3486ff4a4",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/28bd77e1d7f89d58016fc34d5e62e05d",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/a2292f6fffd7a32e673df4947fe12e24"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
