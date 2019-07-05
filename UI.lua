local parent = CreateFrame("frame", "Recount", UIParent)

local UI = LibStub:NewLibrary("UI", 1)
local WoW = LibStub("WoW")

local button = CreateFrame("Button", nil, UIParent)
button:SetPoint("TOP", UIParent, "TOP", -90, 0)
button:SetWidth(185)
button:SetHeight(25)
button:SetText("5 Minute DPS Test")
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
local dtex = button:CreateTexture()
dtex:SetTexture("Interface/Buttons/UI-Panel-Button-Disabled")
dtex:SetTexCoord(0, 0.625, 0, 0.6875)
dtex:SetAllPoints()	
button:SetDisabledTexture(dtex)
local ptex = button:CreateTexture()
ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
ptex:SetTexCoord(0, 0.625, 0, 0.6875)
ptex:SetAllPoints()
button:SetPushedTexture(ptex)
button:RegisterForClicks("AnyDown")

local button2 = CreateFrame("Button", nil, UIParent)
button2:SetPoint("TOP", UIParent, "TOP", 90, 0)
button2:SetWidth(185)
button2:SetHeight(25)
button2:SetText("Target Tanks Target")
button2:SetNormalFontObject("GameFontNormal")
local ntex = button2:CreateTexture()
ntex:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
ntex:SetTexCoord(0, 0.625, 0, 0.6875)
ntex:SetAllPoints()	
button2:SetNormalTexture(ntex)
local dtex = button2:CreateTexture()
dtex:SetTexture("Interface/Buttons/UI-Panel-Button-Disabled")
dtex:SetTexCoord(0, 0.625, 0, 0.6875)
dtex:SetAllPoints()	
button2:SetDisabledTexture(dtex)
local htex = button2:CreateTexture()
htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
htex:SetTexCoord(0, 0.625, 0, 0.6875)
htex:SetAllPoints()
button2:SetHighlightTexture(htex)
local ptex = button2:CreateTexture()
ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
ptex:SetTexCoord(0, 0.625, 0, 0.6875)
ptex:SetAllPoints()
button2:SetPushedTexture(ptex)
button2:RegisterForClicks("AnyDown")

function start()
	if not WoW.IsInArena() then
		if not WoW.GetTank() then
			button2:Disable()
		else
			button2:Enable()
		end
	end
end

function Click()
	clicked = true;
	WoW.Log('DPS Test Started...');
	TargetNearestEnemy()
	WoW.CastSpell("Ice Lance");
end

function Click2()
	local tar = WoW.GetTanksTarget() 
	if tar ~= nil then	
		TargetUnit(tar)				
	else
		WoW.Log('Tank does not currently have any targets')
	end
end

button:SetScript("OnClick", Click)
button2:SetScript("OnClick", Click2)

function UI.UpdateText(text)
	button:SetText(text)
end

function eventHandler(self, event, ...)
	if event == "LFG_PROPOSAL_SHOW" then 
		WoW.Log("LFG Triggered")
		if GetLFGProposal() then
			AcceptProposal()
		end
	end
	if event == "GROUP_ROSTER_UPDATE" or event == "GROUP_JOINED" then	
		if not WoW.IsInArena() then
			if not WoW.GetTank() then
				button2:Disable()
			else
				button2:Enable()
			end
		end
	end	
end

parent:RegisterEvent("LFG_PROPOSAL_SHOW")
parent:RegisterEvent("GROUP_ROSTER_UPDATE")
parent:RegisterEvent("GROUP_JOINED")
parent:SetScript("OnEvent", eventHandler)

start()

