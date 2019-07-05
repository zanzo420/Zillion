local parent = CreateFrame("frame", "Recount", UIParent)
parent:SetSize(0, 0);  -- Width, Height
parent:SetPoint("TOPLEFT", 0, 0)
parent:RegisterEvent("ADDON_LOADED")
parent.t = parent:CreateTexture()
parent.t:SetColorTexture(0, 1, 0, 1)
parent.t:SetAllPoints(parent)

local button = CreateFrame("Button", nil, UIParent)
button:SetPoint("TOP", UIParent, "TOP", 0, 0)
button:SetWidth(150)
button:SetHeight(25)

button:SetText("Reload for FireHack")
button:SetNormalFontObject("GameFontNormal")

local ntex = button:CreateTexture()
ntex:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
ntex:SetTexCoord(0, 0.625, 0, 0.6875)
ntex:SetAllPoints()	
button:SetNormalTexture(ntex)

local htex = button:CreateTexture()
htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
htex:SetTexCoord(0, 0.625, 0, 0.6875)
htex:SetAllPoints()
button:SetHighlightTexture(htex)

local ptex = button:CreateTexture()
ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
ptex:SetTexCoord(0, 0.625, 0, 0.6875)
ptex:SetAllPoints()
button:SetPushedTexture(ptex)

local WoW = LibStub("WoW")

function LoadFile(FilePath,LoadMsg)
	local WowAddon = GetWoWDirectory() .. "\\" .. "Interface" .. "\\" ..  "Addons" .. "\\"
	local AddonName = "Zillion"
	local Root =  WowAddon .. AddonName .. "\\"

	lua = ReadFile(Root .. FilePath)

	if lua == "" then 
		WoW.Log("Class file [" .. FilePath .. "] is not coded yet.")
	end
	
	if not lua then
		WoW.Log(Root .. FilePath .. " Does not exist")
	end
	local func,err = loadstring(lua, Root .. "\\" .. FilePath)
	if err then
		error(err,0)
	end
	pcall(func)
	if LoadMsg then
		WoW.Log(LoadMsg)
	else
		WoW.Log('Successfully loaded ['.. FilePath .. ']')
	end
end

function start()
	if not IsHackEnabled then 		
		return; 
	end;
	
	button:Hide()
				
	WoW.Log('Zillion Loaded.')
	
	if not IsHackEnabled("NoAutoAway") then				
		SetHackEnabled("NoAutoAway", true)		
	end
	
	if not IsHackEnabled("AlwaysFacing") then				
		SetHackEnabled("AlwaysFacing", true)		
	end
	
	local PlayerClass, englishClass, classIndex = UnitClass("Player");
	local currentSpec = GetSpecialization()
		
	c = WoW.ClassColors[classIndex]	
	WoW.Log('Player Class ' .. c.hex .. englishClass .. '|r spec = ' .. currentSpec)
	if englishClass == "MAGE" and currentSpec == 3 then
		LoadFile("UI.lua")
		LoadFile("Classes\\Mage\\Frost.lua")
	end
	if englishClass == "PALADIN" and currentSpec == 3 then
		LoadFile("UI.lua")
		LoadFile("Classes\\Paladin\\Retribution.lua")
	end	
	if englishClass == "PRIEST" and currentSpec == 1 then
		LoadFile("Classes\\Priest\\Disc.lua")
	end	
end

local function eventHandler(self, event, ...)
	local arg1 = ...
	if event == "ADDON_LOADED" then
		if (arg1 == "Zillion") then
			start()            
		end
	end
end	
parent:SetScript("OnEvent", eventHandler)
parent:SetScript("OnUpdate", update)


button:RegisterForClicks("AnyDown")

function down()			
	ReloadUI()
end

button:SetScript("OnClick", down)
