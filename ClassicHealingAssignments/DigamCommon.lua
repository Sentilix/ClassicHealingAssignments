

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
	OnAccept = function(self, data, data2) DIGAM_ShowConfirmation_Ok(); end,
	OnCancel = function(self, data, data2) DIGAM_ShowConfirmation_Cancel(); end,
}


function DIGAM_PrintAll(object, name, level)
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
			DIGAM_PrintAll(value, key, level + 1);
		end;

		print(string.format("%s}", indent));
	end;
end;


--
--	UI helpers
--
function DIGAM_ShowError(errorMessage)
	StaticPopup_Show("DIGAM_DIALOG_ERROR", errorMessage);
end;

local DIGAM_FunctionOk = nil;
local DIGAM_FunctionCancel = nil;
function DIGAM_ShowConfirmation(confirmationMessage, functionOk, functionCancel)
	DIGAM_FunctionOk = functionOk;
	DIGAM_FunctionCancel = functionCancel;
	StaticPopup_Show("DIGAM_DIALOG_CONFIRMATION", confirmationMessage);
end;

function DIGAM_ShowConfirmation_Ok()
	if DIGAM_FunctionOk then 
		DIGAM_FunctionOk(); 
	end;
end;

function DIGAM_ShowConfirmation_Cancel()
	if DIGAM_FunctionCancel then 
		DIGAM_FunctionCancel(); 
	end;
end;



--
--	WoW helpers
--
function DIGAM_StripRealmName(nameAndRealm)
	local _, _, name = string.find(nameAndRealm, "([^-]*)-%s*");
	if not name then
		name = nameAndRealm;
	end;

	return name;
end;

function DIGAM_GetPlayer(unitid)
	return UnitName(unitid);
end;

function DIGAM_GetPlayerAndRealm(unitid)
	local playername, realmname = UnitName(unitid);
	if not playername then return nil; end;

	if not realmname or realmname == "" then
		realmname = DIGAM_GetMyRealm();
	end;

	return playername.."-".. realmname;
end;

function DIGAM_GetMyRealm()
	local realmname = GetRealmName();
	
	if string.find(realmname, " ") then
		local _, _, name1, name2 = string.find(realmname, "([a-zA-Z]*) ([a-zA-Z]*)");
		realmname = name1 .. name2; 
	end;

	return realmname;
end;

function DIGAM_IsInParty()
	if not IsInRaid() then
		return ( GetNumGroupMembers() > 0 );
	end
	return false
end

function DIGAM_UnitClass(unitid)
	local _, classname = UnitClass(unitid);
	return classname;
end;

--[[
	Table functions
--]]
function DIGAM_RenumberTable(table)
	local newTable = { };
	local index = 1;

	for key, value in pairs(table) do
		newTable[index] = value;
		index = index + 1;
	end;
	
	return newTable;
end;

function DIGAM_CloneTable(sourceTable)
	if type(sourceTable) ~= "table" then return sourceTable; end;

	local t = { };
	for k, v in pairs(sourceTable) do
		t[k] = DIGAM_CloneTable(v);
	end;

	return setmetatable(t, DIGAM_CloneTable(getmetatable(sourceTable)));
end;


