local parent = CreateFrame("frame", "Recount", UIParent)
parent:SetSize(10, 10);  -- Width, Height
parent:SetPoint("TOPLEFT", 0, 0)
parent.t = parent:CreateTexture()
parent.t:SetAllPoints(parent)

local LibDraw = LibStub("LibDraw-1.0")

local tick = 0;
local WoW = LibStub("WoW")

function start()		
	c = WoW.ClassColors[select(3,UnitClass("player"))]
	parent.t:SetColorTexture(c.R, c.G, c.B, 1)	
	LibDraw.Enable(0.005)
end

function update(self, elapsed)
	tick = tick + elapsed	
	if tick >= .50 then
		Pulse()
		tick = 0
	end
end

local lastEnemyCount = 0

LibDraw.Sync(function()
	if UnitExists("Target") then
		local pX,  pY,  pZ = ObjectPosition("player")
		local tX,  tY,  tZ = ObjectPosition("target")
		local hitbox = 8
		LibDraw.Circle(tX, tY, tZ, hitbox);
		LibDraw.Line(pX, pY, pZ, tX, tY, tZ)
	end
end)

function Pulse()	
	if UnitIsDeadOrGhost("Player") then
		return;
	end
	
	-- Do out of combat stuff
	
	if WoW.PlayerBuffRemainingTime("Power Word: Shield") < 6 then
		start, duration, enabled = GetSpellCooldown("Power Word: Shield")
		if duration ~= 0 then 
			return;
		end
		WoW.CastSpell("Power Word: Shield")
		return;
	end

	if not UnitExists("Target") then 		
		return;
	end	
	
	if not UnitCanAttack("Player", "Target") then 
		return;	
	end
	
	if not WoW.InCombat() then		
		return;		
	end
end

parent:SetScript("OnUpdate", update)
start()