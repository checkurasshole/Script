-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8076308e320cc82e7a19093e07efa30e",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/be6c2e19022db61889e3856f0a34970e",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/4b6276211dd08c85c750d84930bf1272",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ea73210ccb51831f8305a79c74f04ba4",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/aa1c6836a48715e816fe888c0ac046b7",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/f258b6a13408b5dc08ce202f8bf960cf",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ede98cb9c9567000de0e03f3cbf62efa",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/991043019c8dadccb8ed486cead19132",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/79adff56ccec14b3c2793430013c663a",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/de21dc11fb30443a359b957ef689b6e0",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/71dc31d1051f5108e00acba74555c551",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e0294ba0760976799b7be6729800af92"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
