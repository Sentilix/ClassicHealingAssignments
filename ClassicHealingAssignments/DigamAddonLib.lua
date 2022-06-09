
local DIGAM_COLOR_BEGIN						= "|c80";
local DIGAM_CHAT_END						= "|r";
local DIGAM_DEFAULT_ColorNormal				= "40A0F8"
local DIGAM_DEFAULT_ColorHot				= "B0F0F0"

DigamAddonLib = CreateFrame("Frame"); 

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
print(addonSettings.AddonName);

	DigamAddonLib.Properties.AddonName = addonSettings["ADDONNAME"] or "Unnamed";
	DigamAddonLib.Properties.ShortName = addonSettings["SHORTNAME"] or DigamAddonLib.Properties.AddonName;
	DigamAddonLib.Properties.Prefix = addonSettings["PREFIX"] or DigamAddonLib.Properties.ShortName;
	DigamAddonLib.Chat.ChatColorNormal = DIGAM_COLOR_BEGIN .. (addonSettings["NORMALCHATCOLOR"] or DIGAM_DEFAULT_ColorNormal);
	DigamAddonLib.Chat.ChatColorHot = DIGAM_COLOR_BEGIN..(addonSettings["HOTCHATCOLOR"] or DIGAM_DEFAULT_ColorHot);

	DigamAddonLib.Properties.Version = GetAddOnMetadata(DigamAddonLib.Properties.AddonName, "Version");
	DigamAddonLib.Properties.Author = GetAddOnMetadata(DigamAddonLib.Properties.AddonName, "Author");
	DigamAddonLib.Properties.ExpansionLevel = tonumber(GetAddOnMetadata(DigamAddonLib.Properties.AddonName, "X-Expansion-Level"));
	
	DigamAddonLib.Echo(string.format("Version %s by %s", DigamAddonLib.Properties.Version or "nil", DigamAddonLib.Properties.Author or "nil"));

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
function DigamAddonLib.RefreshChannelList()
	local channels = { };

	if IsInRaid() then
		tinsert(channels, { ["id"]="r", ["name"]="Raid" });
		tinsert(channels, { ["id"]="rw", ["name"]="RaidWarning" });
	elseif GetNumGroupMembers() > 0 then
		tinsert(channels, { ["id"]="p", ["name"]="Party" });
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
				tinsert(channels, { ["id"]=tostring(channelID), ["name"]=channelName });
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


