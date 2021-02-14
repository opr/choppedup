SLASH_CHOPPEDUP1, SLASH_CHOPPEDUP2 = "/cu", "/choppedup";

local ADDON_NAME = "ChoppedUp";
local ADDON_VERSION = "1.2";
local ADDON_COLOUR = "|cff386dff";

local defaults = {
	enabled = true,
	npc_enabled = false, -- if this is true, when NPCs are chopped up it will report in chat
	message = "just chopped up <target> into <overkill> pieces!"
};

local function copyDefaults(src, dst)
	if not src then return { } end
	if not dst then dst = { } end
	for k, v in pairs(src) do
		if type(v) == "table" then
			dst[k] = copyDefaults(v, dst[k])
		elseif type(v) ~= type(dst[k]) then
			dst[k] = v
		end
	end
	return dst
end

if not ChoppedUpDB then
	ChoppedUpDB = { }
end

local function brand_text( msg )
	return ADDON_COLOUR .. msg .. "|r";
end

local function brand_print( msg )
	print( brand_text( ADDON_NAME ) .. " " .. msg );
	return
end

function SlashCmdList.CHOPPEDUP(msg, editbox)
	local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")

  if cmd == "disable" then
		ChoppedUpDB.enabled = false;
	 brand_print("disabled.");
	 return;
  end

  if cmd == "enable" then
		ChoppedUpDB.enabled = true;
	 brand_print("enabled.");
  end

  if cmd == "toggle" then
		ChoppedUpDB.enabled = not ChoppedUpDB.enabled
		if( ChoppedUpDB.enabled) then
			brand_print("enabled.")
			return
		end
		brand_print("disabled.")
  end

  if cmd == "message" then
		if args == "" then
			brand_print( "Current message is: " .. ChoppedUpDB.message );
			return
		end

		if not string.find( args, "<target>" ) or not string.find( args, "<overkill>" ) then
			brand_print("Your message MUST contain the strings <target> and <overkill>. For example: just crushed <target> down into <overkill> particles of scrub dust.")
		end

		brand_print( "Message set successfully! Example below." )
		print( "|cfffa6666" .. UnitName("player") .. " " .. string.gsub( string.gsub( args, "<target>", "Scrubmage", 1), "<overkill>", 5000, 1 ) .. "|r" )

		ChoppedUpDB.message = args;

  end

	if cmd == "npc" then
		if args == "off" then
			brand_print("disabled for NPC targets.")
			ChoppedUpDB.npc_enabled = false
			return
		end
		if args == "on" then
			brand_print("enabled for NPC targets.")
			ChoppedUpDB.npc_enabled = true
			return
		end
		brand_print( "Reporting of NPC destruction is currently " .. ( ChoppedUpDB.npc_enabled == true and "enabled" or "disabled" ) .. ". To change it type /cu npc " .. (ChoppedUpDB.npc_enabled == true and "off" or "on") )
	end

  if msg == "" then
		 print( brand_text( ADDON_NAME ) .. " " .. ADDON_VERSION .. " configuration" );
		 print( "  /cu message <custom_message>");
		 print( "  /cu enable");
		 print( "  /cu disable");
		 print( "  /cu toggle");
		 print( "  /cu npc on|off - if on then a message will show when you chop up an NPC");
	end;
end

local ChoppedUp_EventFrame = CreateFrame("Frame")
playerGUID = nil
ChoppedUp_EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
ChoppedUp_EventFrame:RegisterEvent("PLAYER_LOGIN")
ChoppedUp_EventFrame:SetScript( "OnEvent", function ( self, event, ... )

	if( event == "PLAYER_LOGIN") then
		ChoppedUpDB = copyDefaults( defaults, ChoppedUpDB );
	 	 print( brand_text( "Welcome to " .. ADDON_NAME .. " " .. ADDON_VERSION ) .. " - type " .. SLASH_CHOPPEDUP1 .. " or " .. SLASH_CHOPPEDUP2 .. " to configure the addon.");
	end

	if( ChoppedUpDB.enabled == false ) then return end

	if( event == "COMBAT_LOG_EVENT_UNFILTERED" ) then
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
				if( unitType == "Player" or ChoppedUpDB.npc_enabled == true ) then
					SendChatMessage( string.gsub( string.gsub( ChoppedUpDB.message, "<target>", destName, 1), "<overkill>", overkill, 1), "EMOTE", "language", "channel");
				end
			end
		end

		--(math.ceil( overkill / 1000 ) * 1000)+

	end
end)
