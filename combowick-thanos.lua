-- Main Script - Language Selector
local LanguageSelector = loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/langselector-module.lua"))()

local scripts = {
    ["English"] = "https://v0-supabase-secure-storage.vercel.app/api/script/8cbecb42e04775e8b97795fb9e1b01b1",
    ["Chinese (Simplified)"] = "https://v0-supabase-secure-storage.vercel.app/api/script/39969b2a89d38ccdb08a25e60fb0cec7",
    ["Filipino"] = "https://v0-supabase-secure-storage.vercel.app/api/script/776f4b69f7859419cc84cdb9d30fdfb1",
    ["French"] = "https://v0-supabase-secure-storage.vercel.app/api/script/3cd9b17780cd900516aada4ef3fcc0aa",
    ["German"] = "https://v0-supabase-secure-storage.vercel.app/api/script/51e3921554eb8aae754fdbfbb2d25542",
    ["Indonesian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/ea5e1ff5ee61b9899cc925ba2b16b78b",
    ["Korean"] = "https://v0-supabase-secure-storage.vercel.app/api/script/d9df848e2e432759d87060b7cc4fd587",
    ["Portuguese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/500b2374db44dfff68e467dc1b247b66",
    ["Russian"] = "https://v0-supabase-secure-storage.vercel.app/api/script/70177ea60083d26ec6bff4e5d99da06d",
    ["Spanish"] = "https://v0-supabase-secure-storage.vercel.app/api/script/0aad2b69dc567a14c11a7156b4588968",
    ["Thai"] = "https://v0-supabase-secure-storage.vercel.app/api/script/b1f881f810b87a0230d86d006ab64a71",
    ["Vietnamese"] = "https://v0-supabase-secure-storage.vercel.app/api/script/e2d6d8f394da8691b527e0f691dc9dc3"
}

local selector = LanguageSelector.new()
local autoLoaded = selector:Init(scripts)
if not autoLoaded then
    selector:CreateGUI()
end
