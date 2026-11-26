-- COMBOWICK: this script moved into the COMBOWICK loader.
-- Opening the loader now (pick your language, then your key or free session).
local g = (getgenv and getgenv()) or _G
if not g.__cw_moved_iq then
  g.__cw_moved_iq = true
  pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/checkurasshole/Script/main/IQ"))() end)
else
  pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = "COMBOWICK", Text = "Run the COMBOWICK loader to use this script.", Duration = 6 }) end)
end
return function() end
