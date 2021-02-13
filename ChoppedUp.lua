local Chopped_EventFrame = CreateFrame("Frame")
playerGUID = nil
Chopped_EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
Chopped_EventFrame:SetScript( "OnEvent", function ( self, event, ... )
	if( event == "COMBAT_LOG_EVENT_UNFILTERED") then
	    local timestamp, type, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, arg12, arg13, arg14, amount, overkill = CombatLogGetCurrentEventInfo()
		--print(CombatLogGetCurrentEventInfo())
		if( playerGUID == nil ) then 
			playerGUID = UnitGUID("player")
		end

		if( type == "SWING_DAMAGE" and arg13 ~= nil ) then
				overkill = arg13
			end
		
		if( ( type == "SWING_DAMAGE" or type == "SPELL_DAMAGE" or type == "SPELL_PERIODIC_DAMAGE" or type == "RANGE_DAMAGE" ) and ( sourceGUID == playerGUID and overkill ~= nil and destGUID ~= nil ) ) then
			unitType = strsplit("-",destGUID)
			
			if( overkill ~= -1 and sourceGUID == playerGUID and unitType ~= nil ) then
				if( unitType == "Player" or true) then
					SendChatMessage("just chopped up " .. destName .. " into " .. overkill  .. " pieces!", "EMOTE", "language", "channel");
				end
			end
		end
		
		--(math.ceil( overkill / 1000 ) * 1000)+
		
	end
end)