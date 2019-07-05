local WoW = LibStub:NewLibrary("WoW", 1)

local latencyTolerance = 0 
local LastSpell = "";

function WoW.CastSpell(spellName)
	latencyTolerance = select(4,GetNetStats()) / 1000 

    if UnitExists("Target") and not IsHackEnabled("AlwaysFacing") then				
		FaceDirection(GetAnglesBetweenObjects("Player", "Target"), true);	
	end;	
	c = WoW.ClassColors[select(3,UnitClass("player"))]	
	WoW.Log(c.hex .. 'Casting: |r' .. spellName .. ' [latency]: ' .. (latencyTolerance * 1000) .. 'ms');
	if UnitExists("Target") then 
		CastSpellByName(spellName, "Target");
	else
		CastSpellByName(spellName, "");
	end;	
	LastSpell = spellName;
end

WoW.ClassColors = {
	[1]				= {class = "Warrior", 		B=0.43,	G=0.61,	R=0.78,	hex="|cffc79c6e"},
	[2]				= {class = "Paladin", 		B=0.73,	G=0.55,	R=0.96,	hex="|cfff58cba"},
	[3]				= {class = "Hunter",		B=0.45,	G=0.83,	R=0.67,	hex="|cffabd473"},
	[4]				= {class = "Rogue",			B=0.41,	G=0.96,	R=1,	hex="|cfffff569"},
	[5]				= {class = "Priest",		B=1,	G=1,	R=1,	hex="|cffffffff"},
	[6]				= {class = "Deathknight",	B=0.23,	G=0.12,	R=0.77,	hex="|cffc41f3b"},
	[7]				= {class = "Shaman",		B=0.87,	G=0.44,	R=0,	hex="|cff0070de"},
	[8]				= {class = "Mage",			B=0.94,	G=0.8,	R=0.41,	hex="|cff69ccf0"},
	[9]				= {class = "Warlock", 		B=0.79,	G=0.51,	R=0.58,	hex="|cff9482c9"},
	[10]			= {class = "Monk",			B=0.59,	G=1,	R=0,	hex="|cff00ff96"},
	[11]			= {class = "Druid", 		B=0.04,	G=0.49,	R=1,	hex="|cffff7d0a"},
	[12] 			= {class = "Demonhunter", 	B=0.79, G=0.19, R=0.64, hex="|cffa330c9"},
}

function WoW.CanCast(spellName, range, requiresTarget)
	if requiresTarget then	
		if not UnitExists("Target") and target ~= player then 
			return false; 
		end;
		if not WoW.LOS("Target") then
			if not IsInInstance() then -- ignore LOS checking in Instances / Dungeons						
				return false;
			end
		end;
		if WoW.GetDistanceTo("Target") > range then 
			return false; 
		end;	
		if UnitIsDeadOrGhost("Target") then 
			return false;
		end;
	end;
	if UnitCastingInfo("Player") then 
		return false;
	end;
	if UnitChannelInfo("Player") then 
		return false;	
	end;		
	if spellName == "Water Jet" then
		if UnitChannelInfo("Pet") then 
			return false;	
		end;		
	end
	if UnitIsDeadOrGhost("Player") then 
		return false;
	end;
	if not IsHackEnabled("MovingCast") or not WoW.PlayerHasBuff("Ice Floes") then
		if UnitMovementFlags("Player") ~= 0 and select(4, GetSpellInfo(spellName)) ~= 0 then -- If the player is moving and not trying to cast an instant cast spell
			return false;
		end;		
	end;	
	if not IsUsableSpell(spellName) then
		return false;
	end;
	start, duration, enabled = GetSpellCooldown(spellName)
	local getTime = GetTime()
	cooldownLeft = start + duration - getTime
	local remainingTime = cooldownLeft - (latencyTolerance)
	if remainingTime < 0 then remainingTime = 0 end	
	
	if remainingTime ~= 0 then 
		return false;
	end;
	
	return true;
end

function WoW.LOS(unit)
	if not UnitExists(unit) then	
		return true;
	end
	local sX, sY, sZ = ObjectPosition("Player");
	local oX, oY, oZ = ObjectPosition(unit);
	local losFlags =  bit.bor(0x10, 0x100, 0x1)
	return TraceLine(sX, sY, sZ + 2.25, oX, oY, oZ + 2.25, losFlags) == nil;
end

function WoW.GetDistanceTo(unit)
	if not UnitExists(unit) then	
		return 999
	end
  local X1, Y1, Z1 = ObjectPosition(unit)
  local X2, Y2, Z2 = ObjectPosition("Player")
  return math.sqrt(((X1 - X2)^2) + ((Y1 - Y2)^2) + ((Z1 - Z2)^2))
end

function WoW.UnitsInRangeXofTarget(rangeX)
	if not UnitExists("Target") then 
		return 0
	end;

	local noUnits = 0;
	local count = GetObjectCount();		
	for i = 1, count do
		currentObj = GetObjectWithIndex(i);		
		if ObjectIsType(currentObj, ObjectTypes.Unit) then
			if GetDistanceBetweenObjects(currentObj, "target") < rangeX then			
				noUnits = noUnits + 1;
			end
		end
	end
	
	return noUnits
end

function WoW.EnemyUnitsInRangeXofTarget(rangeX)
	if not UnitExists("Target") then 
		return 0
	end;

	local noUnits = 0;
	local count = GetObjectCount();		
	for i = 1, count do
		currentObj = GetObjectWithIndex(i);		
		if ObjectIsType(currentObj, ObjectTypes.Unit) and currentObj ~= target then
			if GetDistanceBetweenObjects(currentObj, "target") < rangeX and UnitCanAttack("Player", currentObj) then			
				noUnits = noUnits + 1;
			end
		end
	end
	
	return noUnits
end

function WoW.TargetNextUnitInCombat()
	local count = GetObjectCount();		
	for i = 1, count do
		currentObj = GetObjectWithIndex(i);		
		if ObjectIsType(currentObj, ObjectTypes.Unit) then
			if UnitCanAttack("Player", currentObj) and not UnitIsDeadOrGhost(currentObj) and not WoW.LOS(unit) then							
				TargetUnit(currentObj);
				break;
			end
		end		
	end
end

function WoW.ShowGroupInfo()
	local groupType = IsInRaid() and "raid" or "party";
	for i=1, GetNumGroupMembers() do
		if groupType == "party" then      
			Unit = (groupType .. i)    
			Role=UnitGroupRolesAssigned(Unit)
			WoW.Log('Group Type: ' .. groupType)
			WoW.Log('Role: ' .. Role)
			if Role == "TANK" then
			
			end
		end
	end
end

function WoW.GetTank()
	local groupType = IsInRaid() and "raid" or "party";
	for i=1, GetNumGroupMembers() do		
		Unit = (groupType .. i)    
		Role=UnitGroupRolesAssigned(Unit)			
		if Role == "TANK" then
			return Unit
		end		
	end
end

function WoW.GetTanksTarget()
	--WoW.Log('Tank Details...')
	local groupType = IsInRaid() and "raid" or "party";
	for i=1, GetNumGroupMembers() do
		if groupType == "party" then      
			Unit = (groupType .. i)    			
			if UnitGroupRolesAssigned(Unit) == "TANK" then
				--WoW.Log('Tank Name: ' .. ObjectName(Unit))
				tar = UnitTarget(Unit);
				if tar ~= nil then
					tarName = ObjectName(tar)
					--WoW.Log('Tanks Target : ' ..tarName)
				else
					--WoW.Log('Tanks Target : None')
				end				
				return tar;
			end
			
			return nil;
		end
	end
end

function WoW.GetArenaDPSsTarget()	
	for i=1, GetNumGroupMembers() do		
		local groupType = "arena"
		Unit = (groupType .. i)    
		Role=UnitGroupRolesAssigned(Unit)
		WoW.Log('Role: ' .. Role)
		local tar = UnitTarget(Unit);
		if Role ~= "HEALER" then
			if tar ~= nil and UnitExists("Target") and not UnitIsDeadOrGhost("Target") then
				return tar
			end
		end
		return nil;
	end
end

function WoW.IsInArena()
	return select(2,IsInInstance()) == "arena"
end

function WoW.GetArenaDPSsTarget()	
	local groupType = "arena"
	for i=1, GetNumGroupMembers() do		
		Unit = (groupType .. i)    			
		if UnitGroupRolesAssigned(Unit) == "DAMAGER" then			
			tar = UnitTarget(Unit);
			if tar ~= nil then
				tarName = ObjectName(tar)				
			end			
			return tar;
		end
		return nil;		
	end
end

function WoW.SpellCharges(spell)
	charges = select(1, GetSpellCharges(spell))
	if charges ~= nil then
		return charges
	end;
		
	return 0;		
end

function WoW.LastSpell()
	return LastSpell;
end

function WoW.CastAtUnit(unit, spellName)
	CastSpellByName(spellName)
	local oX, oY, oZ = ObjectPosition(unit);
	ClickPosition(oX,oY,oZ)
end

function WoW.PlayerBuffCount(buffName)
	name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitAura("player", buffName)
	if count == nil then
		return 0;
	end
	return count;
end

function WoW.PlayerHasBuff(buffName)
	local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitBuff("Player", buffName)
	local getTime = GetTime()
    local remainingTime = 0
	if expirationTime == nil then 
		expirationTime = 0 
	end;		
    if expirationTime ~=0 then
		remainingTime = math.floor(expirationTime - getTime + 0.5)
    end
	if remainingTime == 0 then
		return false;	
	end;
	return true;
end

function WoW.PlayerTalentAtTier(talentTier)
	local available, selected = GetTalentTierInfo(talentTier, 1);
	return selected;
end

function WoW.TargetHasDebuff(debuffName)
	local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId, canApplyAura, isBossDebuff, value1, value2, value3 = UnitDebuff("target", debuffName, nil, "PLAYER|HARMFUL")
	local getTime = GetTime()
    local remainingTime = 0	
	if expirationTime == nil then 
		expirationTime = 0 
	end;	
	if expirationTime ~=0 then
		remainingTime = math.floor(expirationTime - getTime + 0.5)
    end
	if remainingTime == 0 then
		return false;	
	end;
	return true;
end

function WoW.SpellCooldownRemainingTime(spellName)
	start, duration, enabled = GetSpellCooldown(spellName)
	local getTime = GetTime()
	cooldownLeft = start + duration - getTime
	local remainingTime = cooldownLeft - (latencyTolerance)
	if remainingTime < 0 then remainingTime = 0 end	
	return math.floor(remainingTime + 0.5)
end

function WoW.PlayerBuffRemainingTime(buffName)
	local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitBuff("Player", buffName)
	local getTime = GetTime()
    local remainingTime = 0
	if expirationTime == nil then 
		expirationTime = 0 
	end;		
    if expirationTime ~=0 then
		remainingTime = math.floor(expirationTime - getTime + 0.5)
    end
	
	return remainingTime
end

function WoW.InCombat()
	return UnitAffectingCombat("player");
end 

function WoW.GetHealth(unit)
  currentHealth = UnitHealth(unit) / UnitHealthMax(unit) * 100
  return currentHealth
end

local LogFile = ""
if IsHackEnabled then
	LogFile = GetWoWDirectory() .. "\\" .. "Interface" .. "\\" ..  "Addons" .. "\\" .. "Zillion" .. "\\Logs\\log.txt"	
	WriteFile(LogFile, "Log\n", false)
end
	
function WoW.Log(message, color)
	if color == nil then 
		color = "|cffFFFFFF"
	end;
	local dt = date("%H:%M:%S");			
	print('[|cFFC00000'.. dt ..'|r] ' .. color .. message)
	if IsHackEnabled then
		WriteFile(LogFile, "[".. dt .."] " .. message .. "\n", true)
	end	
end