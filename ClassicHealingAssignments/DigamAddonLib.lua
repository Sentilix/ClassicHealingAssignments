
local DIGAM_COLOR_BEGIN						= "|c80";
local DIGAM_CHAT_END						= "|r";
local DIGAM_DEFAULT_ColorNormal				= "40A0F8"
local DIGAM_DEFAULT_ColorHot				= "B0F0F0"

local RAID_CHANNEL							= "RAID"
local YELL_CHANNEL							= "YELL"
local SAY_CHANNEL							= "SAY"
local WARN_CHANNEL							= "RAID_WARNING"
local GUILD_CHANNEL							= "GUILD"


DIGAM_CHANNEL_RAID							= { ["id"] = "r", ["mask"] = 0x0001, ["name"] = "Raid", ["channel"] = "RAID", };
DIGAM_CHANNEL_RAIDWARNING					= { ["id"] ="rw", ["mask"] = 0x0002, ["name"] = "Raid warning", ["channel"] = "RAID_WARNING", };
DIGAM_CHANNEL_PARTY							= { ["id"] = "p", ["mask"] = 0x0004, ["name"] = "Party", ["channel"] = "PARTY", };
DIGAM_CHANNEL_CUSTOM						= { ["id"] = "?", ["mask"] = 0x0008, ["name"] = "(Custom)", ["channel"] = "CUSTOM", };


DigamAddonLib = CreateFrame("Frame"); 

DigamAddonLib.Debug = {
	IsDebugBuild	= false,
	BuildVersion	= 3,
};

DigamAddonLib.Properties = {
	AddonName		= "",
	ShortName		= "",
	Prefix			= "",
	Version			= "",
	Author			= "",
	ExpansionLevel	= 0,
};
DigamAddonLib.Chat = {
	ChatColorNormal	= DIGAM_DEFAULT_ColorNormal,
	ChatColorHot	= DIGAM_DEFAULT_ColorHot,
	Channels		= { },
}

function DigamAddonLib.Initialize(addonSettings)
	DigamAddonLib.Properties.AddonName = addonSettings["ADDONNAME"] or "Unnamed";
	DigamAddonLib.Properties.ShortName = addonSettings["SHORTNAME"] or DigamAddonLib.Properties.AddonName;
	DigamAddonLib.Properties.Prefix = addonSettings["PREFIX"] or DigamAddonLib.Properties.ShortName;
	DigamAddonLib.Chat.ChatColorNormal = DIGAM_COLOR_BEGIN .. (addonSettings["NORMALCHATCOLOR"] or DIGAM_DEFAULT_ColorNormal);
	DigamAddonLib.Chat.ChatColorHot = DIGAM_COLOR_BEGIN..(addonSettings["HOTCHATCOLOR"] or DIGAM_DEFAULT_ColorHot);

	DigamAddonLib.Properties.Version = GetAddOnMetadata(DigamAddonLib.Properties.AddonName, "Version");
	DigamAddonLib.Properties.Author = GetAddOnMetadata(DigamAddonLib.Properties.AddonName, "Author");
	DigamAddonLib.Properties.ExpansionLevel = tonumber(GetAddOnMetadata(DigamAddonLib.Properties.AddonName, "X-Expansion-Level"));
	
	DigamAddonLib.Echo(string.format("Version %s by %s", DigamAddonLib.Properties.Version or "nil", DigamAddonLib.Properties.Author or "nil"));
	if DigamAddonLib.Debug.IsDebugBuild then
		DigamAddonLib.Echo(string.format("Using DigamAddonLib build %s.", DigamAddonLib.Debug.BuildVersion));
	end;

	C_ChatInfo.RegisterAddonMessagePrefix(DigamAddonLib.Properties.Prefix);
end;

function DigamAddonLib.Echo(message)
	if message then
		message = string.format("%s-[%s%s%s]- %s%s", 
			DigamAddonLib.Chat.ChatColorNormal, 
			DigamAddonLib.Chat.ChatColorHot, 
			DigamAddonLib.Properties.ShortName, 
			DigamAddonLib.Chat.ChatColorNormal, 
			message, 
			DIGAM_CHAT_END
		);
		DEFAULT_CHAT_FRAME:AddMessage(message);
	end
end;

function DigamAddonLib.GetChannelInfo(channelName)
	for key, channel in next, DigamAddonLib.Chat.Channels do
		if channel["name"] == channelName then
			return channel;
		end;
	end;

	return nil;
end;

function DigamAddonLib.EchoByName(channelName, message)
	local channel = DigamAddonLib.GetChannelInfo(channelName);
	if message and channel then
		if bit.band(channel["mask"], 0x07) > 0 then
			--	r, rw, p:
			SendChatMessage(message, channel["channel"]);
		else
			--	Custom channel, like a Healer channel etc:
			SendChatMessage(message, "CHANNEL", nil, tonumber(channel["channel"]));
		end;
	end;
end;


StaticPopupDialogs["DIGAM_DIALOG_ERROR"] = {
	text = "%s",
	button1 = "OK",
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

StaticPopupDialogs["DIGAM_DIALOG_CONFIRMATION"] = {
	text = "%s",
	button1 = "OK",
	button2 = "Cancel",
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
	OnAccept = function(self, data, data2) DigamAddonLib.ShowConfirmation_Ok(); end,
	OnCancel = function(self, data, data2) DigamAddonLib.ShowConfirmation_Cancel(); end,
}

--	Convert the version number to an integer (if possible).
--	Returns 0 if not possible (like Alpha and Beta versions)
function DigamAddonLib.CalculateVersion(versionString)
	if not versionString then
		versionString = DigamAddonLib.Properties.Version;
	end;
	
	local _, _, major, minor, patch = string.find(versionString, "([^\.]*)\.([^\.]*)\.([^\.]*)");
	local version = 0;

	if (tonumber(major) and tonumber(minor) and tonumber(patch)) then
		version = major * 100 + minor;
	end
	
	return version;
end



--
--	ECHO Functions
--
function DigamAddonLib.PrintAll(object, name, level)
	if not name then name = ""; end;
	if not level then level = 0; end;

	local indent = "";
	for n= 1, level, 1 do
		indent = indent .."  ";
	end;

	if type(object) == "string" then
		print(string.format("%s%s => %s", indent, name, object));
	elseif type(object) == "number" then
		print(string.format("%s%s => %s", indent, name, object));
	elseif type(object) == "boolean" then
		if object then
			print(string.format("%s%s => %s", indent, name, "true"));
		else
			print(string.format("%s%s => %s", indent, name, "false"));
		end;
	elseif type(object) == "function" then
		print(string.format("%s%s => %s", indent, name, "FUNCTION"));
	elseif type(object) == "nil" then
		print(string.format("%s%s => %s", indent, name, "NIL"));
	elseif type(object) == "table" then
		print(string.format("%s%s => {", indent, name));

		for key, value in next, object do
			DigamAddonLib.PrintAll(value, key, level + 1);
		end;

		print(string.format("%s}", indent));
	end;
end;


--
--	UI helpers
--
function DigamAddonLib.ShowError(errorMessage)
	StaticPopup_Show("DIGAM_DIALOG_ERROR", errorMessage);
end;

DigamAddonLib.FunctionOk = nil;
DigamAddonLib.FunctionCancel = nil;
function DigamAddonLib.ShowConfirmation(confirmationMessage, functionOk, functionCancel)
	DigamAddonLib.FunctionOk = functionOk;
	DigamAddonLib.FunctionCancel = functionCancel;
	StaticPopup_Show("DIGAM_DIALOG_CONFIRMATION", confirmationMessage);
end;

function DigamAddonLib.ShowConfirmation_Ok()
	if DigamAddonLib.FunctionOk then 
		DigamAddonLib.FunctionOk(); 
	end;
end;

function DigamAddonLib.ShowConfirmation_Cancel()
	if DigamAddonLib.FunctionCancel then 
		DigamAddonLib.FunctionCancel(); 
	end;
end;




--
--	WoW helpers
--
function DigamAddonLib.StripRealmName(nameAndRealm)
	local _, _, name = string.find(nameAndRealm, "([^-]*)-%s*");
	if not name then
		name = nameAndRealm;
	end;

	return name;
end;

function DigamAddonLib.GetPlayerAndRealm(unitid)
	local playername, realmname = UnitName(unitid);
	if not playername then return nil; end;

	if not realmname or realmname == "" then
		realmname = DigamAddonLib.GetMyRealm();
	end;

	return playername.."-".. realmname;
end;

function DigamAddonLib.GetMyRealm()
	local realmname = GetRealmName();
	
	if string.find(realmname, " ") then
		local _, _, name1, name2 = string.find(realmname, "([a-zA-Z]*) ([a-zA-Z]*)");
		realmname = name1 .. name2; 
	end;

	return realmname;
end;

function DigamAddonLib.IsInParty()
	if not IsInRaid() then
		return ( GetNumGroupMembers() > 0 );
	end
	return false
end

function DigamAddonLib.UnitClass(unitid)
	local _, classname = UnitClass(unitid);
	return classname;
end;

function DigamAddonLib.GetUnitidFromName(playerName)
	local thisRealm = DigamAddonLib.GetMyRealm()

	if IsInRaid() then
		for n = 1, 40, 1 do
			local unitid = "raid"..n;
			local unitname, realm = UnitName(unitid);
			if not unitname then return nil; end;
			if not realm or realm == "" then realm = thisRealm; end;
			
			unitname = unitname.."-".. realm;
			if playerName == unitname then
				return unitid;
			end;
		end;
	elseif GetNumGroupMembers() > 0 then
		for n = 1, GetNumGroupMembers(), 1 do
			local unitid = "party"..n;
			local unitname, realm = UnitName(unitid);
			if not unitname then unitname = "player"; end;

			if not realm or realm == "" then realm = thisRealm; end;
			
			unitname = unitname.."-".. realm;
			if playerName == unitname then
				return unitid;
			end;
		end;
	else
		--	Solo:
		return "player";
	end;


	return nil;
end;



--[[
	Table functions
--]]
function DigamAddonLib.RenumberTable(table)
	local newTable = { };

	for key, value in pairs(table) do
		tinsert(newTable, value);
	end;
	
	return newTable;
end;

function DigamAddonLib.CloneTable(sourceTable)
	if type(sourceTable) ~= "table" then return sourceTable; end;

	local t = { };
	for k, v in pairs(sourceTable) do
		t[k] = DigamAddonLib.CloneTable(v);
	end;

	return setmetatable(t, DigamAddonLib.CloneTable(getmetatable(sourceTable)));
end;




--
--	Channels
--

--	Updates the channel list (excuding General, Trade, Defense, LFG etc)
--	TRUE if group type check should be ignored; i.e. allow /rw in party
function DigamAddonLib.RefreshChannelList(skipGroupTypeCheck)
	local channels = { };

	if skipGroupTypeCheck or IsInRaid() then
		tinsert(channels, DIGAM_CHANNEL_RAID);
		tinsert(channels, DIGAM_CHANNEL_RAIDWARNING); 
	end;
	
	if skipGroupTypeCheck or (not IsInRaid() and GetNumGroupMembers() > 0) then
		tinsert(channels, DIGAM_CHANNEL_PARTY);
	end;

	local publicChannels = { GetChatWindowChannels(DEFAULT_CHAT_FRAME:GetID()) };
	for n = 1, table.getn(publicChannels), 2 do
		--	0: Everywhere
		--	1: Current zone
		--	2: Major cities
		--	22: LocalDefence (!)

		--	So we want all zone 0 groups except LookingForGroup (is that translated?)
		if publicChannels[n+1] == 0 and publicChannels[n] ~= "LookingForGroup" then
			local channelID, channelName = GetChannelName(publicChannels[n]);
			if channelID then
				tinsert(channels, {
					["id"] = tostring(channelID),
					["mask"] = DIGAM_CHANNEL_CUSTOM["mask"],
					["name"] = channelName,
					["channel"] = tostring(channelID),
				});
			end;
		end;
	end;

	DigamAddonLib.Chat.Channels = channels;
end;



--
--	Addon communication
--

--	Send a message using the Addon channel.
function DigamAddonLib.SendAddonMessage(message)
	local memberCount = GetNumGroupMembers();
	if memberCount > 0 then
		local channel;
		if IsInRaid() then
			channel = "RAID";
		elseif DigamAddonLib.IsInParty() then
			channel = "PARTY";
		else 
			return;
		end;

		C_ChatInfo.SendAddonMessage(DigamAddonLib.Properties.Prefix, message, channel);
	end;
end
