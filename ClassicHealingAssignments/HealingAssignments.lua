--[[
--	ClassicHealingAssignments addon
--	-------------------------------
--	Author: Mimma
--	File:   HealingAssignments.lua
--	Desc:	Core functionality: addon framework, event handling etc.
--
--	Version 1.x by Renew, Mimma.
--	Version 2.x coded from scratch by Mimma
--]]

--	Addon constants:
local CHA_ADDON_NAME						= "ClassicHealingAssignments";
local CHAT_END								= "|r";
local COLOUR_BEGINMARK						= "|c80";
local COLOUR_CHAT							= COLOUR_BEGINMARK.."40A0F8";
local COLOUR_INTRO							= COLOUR_BEGINMARK.."B040F0";
local CHA_MESSAGE_PREFIX					= "CHAv2";
local CHA_TEMPLATES_MAX						= 15;	-- room for max 15 templates. This is a limitation in the UI design.
local CHA_COLOR_SELECTED					= {1.0, 1.0, 1.0};
local CHA_COLOR_UNSELECTED					= {1.0, 0.8, 0.0};
local CHA_ALPHA_ENABLED						= 1.0;
local CHA_ALPHA_DISABLED					= 0.3;

local CHA_CLASS_DRUID						= 0x0001;
local CHA_CLASS_HUNTER						= 0x0002;
local CHA_CLASS_MAGE						= 0x0004;
local CHA_CLASS_PALADIN						= 0x0008;
local CHA_CLASS_PRIEST						= 0x0010;
local CHA_CLASS_ROGUE						= 0x0020;
local CHA_CLASS_SHAMAN						= 0x0040;
local CHA_CLASS_WARLOCK						= 0x0080;
local CHA_CLASS_WARRIOR						= 0x0100;
local CHA_CLASS_DEATHKNIGHT					= 0x0200;

local CHA_TARGET_LEFT						= 0x00000400;	-- "<<====" (Left)
local CHA_TARGET_RIGHT						= 0x00000800;	-- "====>>" (Right)

local CHA_TARGET_NORTH						= 0x00001000;	-- North
local CHA_TARGET_EAST						= 0x00002000;	-- East
local CHA_TARGET_SOUTH						= 0x00004000;	-- South
local CHA_TARGET_WEST						= 0x00008000;	-- West

local CHA_TARGET_SKULL						= 0x00010000;
local CHA_TARGET_CROSS						= 0x00020000;
local CHA_TARGET_SQUARE						= 0x00040000;
local CHA_TARGET_MOON						= 0x00080000;
local CHA_TARGET_TRIANGLE					= 0x00100000;
local CHA_TARGET_DIAMOND					= 0x00200000;
local CHA_TARGET_CIRCLE						= 0x00400000;
local CHA_TARGET_STAR						= 0x00800000;

local CHA_TARGET_CUSTOM1					= 0x01000000;	-- ?
local CHA_TARGET_CUSTOM2					= 0x02000000;	-- ?
local CHA_TARGET_CUSTOM3					= 0x04000000;	-- ?
local CHA_TARGET_CUSTOM4					= 0x08000000;	-- ?

local CHA_TARGET_PLAYERS					= 0x000003ff;	--	Bitmask for all player types
local CHA_TARGET_DIRECTIONS					= 0x0000fc00;	--	Bitmask for all symbol types
local CHA_TARGET_RAIDICONS					= 0x00ff0000;	--	Bitmask for all raid icons
local CHA_TARGET_CUSTOM						= 0x0f000000;	--	Bitmask for all custom types
local CHA_TARGET_SYMBOLS					= CHA_TARGET_DIRECTIONS + CHA_TARGET_RAIDICONS + CHA_TARGET_CUSTOM;

local CHA_CUSTOM_CAPTION = "(Custom)";
local CHA_TargetMatrix =  {
		[1] = { CHA_TARGET_SKULL,		"Skull",			"Interface\\TargetingFrame\\UI-RaidTargetingIcon_8" },
		[2] = { CHA_TARGET_CROSS,		"Cross",			"Interface\\TargetingFrame\\UI-RaidTargetingIcon_7" },
		[3] = { CHA_TARGET_SQUARE,		"Square",			"Interface\\TargetingFrame\\UI-RaidTargetingIcon_6" },
		[4] = { CHA_TARGET_MOON,		"Moon",				"Interface\\TargetingFrame\\UI-RaidTargetingIcon_5" },
		[5] = { CHA_TARGET_TRIANGLE,	"Triangle",			"Interface\\TargetingFrame\\UI-RaidTargetingIcon_4" },
		[6] = { CHA_TARGET_DIAMOND,		"Diamond",			"Interface\\TargetingFrame\\UI-RaidTargetingIcon_3" },
		[7] = { CHA_TARGET_CIRCLE,		"Circle",			"Interface\\TargetingFrame\\UI-RaidTargetingIcon_2" },
		[8] = { CHA_TARGET_STAR,		"Star",				"Interface\\TargetingFrame\\UI-RaidTargetingIcon_1" },
		[9] = { CHA_TARGET_LEFT,		"<== Left",			"Interface\\Icons\\spell_chargenegative" },
		[10] = { CHA_TARGET_RIGHT,		"Right ==>",		"Interface\\Icons\\spell_chargepositive" },
		[11] = { CHA_TARGET_NORTH,		"North",			132181 },
		[12] = { CHA_TARGET_EAST,		"East",				132181 },
		[13] = { CHA_TARGET_SOUTH,		"South",			132181 },
		[14] = { CHA_TARGET_WEST,		"West",				132181 },
		[15] = { CHA_TARGET_CUSTOM1,	CHA_CUSTOM_CAPTION, 134466 },
		[16] = { CHA_TARGET_CUSTOM2,	CHA_CUSTOM_CAPTION, 134467 },
		[17] = { CHA_TARGET_CUSTOM3,	CHA_CUSTOM_CAPTION, 134468 },
		[18] = { CHA_TARGET_CUSTOM4,	CHA_CUSTOM_CAPTION, 134469 },
	};


local CHA_FRAME_MAXTARGET	= 8;
local CHA_FRAME_MAXPLAYERS	= 8;	-- Would like at least 10, but there isn't room :(
	
	
local _icon_tank = 132341;			-- Defensive stance
local _icon_heal = 135907;			-- Flash of Light
local _icon_decurse = 135952;		-- remove Curse


local CHA_ROLE_NONE							= 0x00;
local CHA_ROLE_TANK							= 0x01;
local CHA_ROLE_HEAL							= 0x02;
local CHA_ROLE_DECURSE						= 0x04;

local CHA_RoleMatrix = {
	[CHA_ROLE_TANK] = "Tanks", 
	[CHA_ROLE_HEAL] = "Heals", 
	[CHA_ROLE_DECURSE] = "Decurses"
};

local CHA_ROLE_DEFAULT_TANK					= CHA_CLASS_DRUID + CHA_CLASS_WARRIOR + CHA_CLASS_DEATHKNIGHT;
local CHA_ROLE_DEFAULT_HEAL					= CHA_CLASS_DRUID + CHA_CLASS_PALADIN + CHA_CLASS_PRIEST + CHA_CLASS_SHAMAN;
local CHA_ROLE_DEFAULT_DECURSE				= CHA_CLASS_DRUID + CHA_CLASS_MAGE;



--	Local variables:
local CHA_CurrentVersion					= 0;
local CHA_Expansionlevel					= 0;
local CHA_UpdateMessageShown				= false;
local CHA_IconMoving						= false;
local CHA_CurrentTemplateIndex				= 0;
local CHA_CurrentTemplateOperation			= "";
local CHA_CurrentTargetIndex				= 0;
local CHA_CurrentPlayerIndex				= 0;

--	Persisted options:
CHA_PersistedData							= { };

local CHA_KEY_ActiveTemplate				= "ActiveTemplate";
local CHA_KEY_ActiveRole					= "ActiveRole";
local CHA_KEY_Templates						= "Templates";

local CHA_DEFAULT_ActiveTemplate			= nil;
local CHA_DEFAULT_ActiveRole				= CHA_ROLE_TANK;

local CHA_ActiveTemplate					= CHA_DEFAULT_ActiveTemplate;
local CHA_ActiveRole						= CHA_DEFAULT_ActiveRole;
local CHA_MinimapX							= 0;
local CHA_MinimapY							= 0;
local CHA_Templates							= { };
--[[
	Template: a table of template objects with:
		"NAME": Unique name of the template
		"Tanks/Heals/Decurses" = {
			"ROLEMASK": bitmask for classes assigned for Tanking/healing/decursing
		}
--]]
local CHA_WhisperHeal						= true;
local CHA_WhisperRepost						= true;


--	Backdrops:
CHA_BACKDROP_ICON = {
	bgFile = "Interface\\AddOns\\ClassicHealingAssignments\\Media\\icon",
	edgeSize = 0,
	tileEdge = true,
};
CHA_BACKDROP_LOGO = {
	bgFile = "Interface\\AddOns\\ClassicHealingAssignments\\Media\\iconmouseover",
	edgeSize = 0,
	tileEdge = true,
};
CHA_BACKDROP_TOPLEFT = {
	bgFile = "Interface\\auctionframe\\ui-auctionframe-browse-topleft",
	edgeSize = 0,
	tileEdge = true,
};
CHA_BACKDROP_TOPMID = {
	bgFile = "Interface\\auctionframe\\ui-auctionframe-browse-top",
	edgeSize = 0,
	tileEdge = true,
};
CHA_BACKDROP_TOPRIGHT = {
	bgFile = "Interface\\auctionframe\\ui-auctionframe-browse-topright",
	edgeSize = 0,
	tileEdge = true,
};
CHA_BACKDROP_BOTTOMLEFT = {
	bgFile = "Interface\\auctionframe\\ui-auctionframe-browse-botleft",
	edgeSize = 0,
	tileEdge = true,
};
CHA_BACKDROP_BOTTOMMID = {
	bgFile = "Interface\\auctionframe\\ui-auctionframe-browse-bot",
	edgeSize = 0,
	tileEdge = true,
};
CHA_BACKDROP_BOTTOMRIGHT = {
	bgFile = "Interface\\auctionframe\\ui-auctionframe-browse-botright",
	edgeSize = 0,
	tileEdge = true,
};
CHA_BACKDROP_TEMPLATE = {
	bgFile = "Interface\\TalentFrame\\DruidBalance-Topleft",
	edgeSize = 0,
	tileEdge = true,
}

StaticPopupDialogs["CHA_DIALOG_ADDTEMPLATE"] = {
	text = "Name of template:",
	button1 = "OK",
	button2 = "Cancel",
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
	hasEditBox = true,
	OnShow = function(self, data)
		self.editBox:SetText(self.text.text_arg1 or ""); 
		self.editBox:SetWidth(140); 
		self.editBox:SetScript("OnEnterPressed", function(self)
			self:GetParent().button1:Click();
		end);
	end,
	OnAccept = function(self, data, data2)
		if self.text.text_arg1 then
			CHA_RenameTemplate_OK(self.text.text_arg1, self.editBox:GetText())
		else
			CHA_AddTemplate_OK(self.editBox:GetText()); 
		end;
	end,
	EditBoxOnTextChanged = function(self, data)
		if self:GetText() == "" then
			self:GetParent().button1:Disable()
		else
			self:GetParent().button1:Enable();
		end;
	end,
}

StaticPopupDialogs["CHA_DIALOG_RENAMETARGET"] = {
	text = "New target name:",
	button1 = "OK",
	button2 = "Cancel",
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
	hasEditBox = true,
	OnShow = function(self, data)
		self.editBox:SetText(self.text.text_arg1 or ""); 
		self.editBox:SetWidth(140); 
		self.editBox:SetScript("OnEnterPressed", function(self)
			self:GetParent().button1:Click();
		end);
	end,
	OnAccept = function(self, data, data2)
		CHA_RenameTarget_OK(self.text.text_arg1, self.editBox:GetText())
	end,
	EditBoxOnTextChanged = function(self, data)
		if self:GetText() == "" then
			self:GetParent().button1:Disable()
		else
			self:GetParent().button1:Enable();
		end;
	end,
}


--	DropDown menu for Template options:
local CHA_TemplateDropdownMenu = CreateFrame("FRAME", "CHA_TemplateDropdownMenuFrame", UIParent, "UIDropDownMenuTemplate");
CHA_TemplateDropdownMenu:SetPoint("CENTER");
CHA_TemplateDropdownMenu:Hide();
UIDropDownMenu_SetWidth(CHA_TemplateDropdownMenu, 1);
UIDropDownMenu_SetText(CHA_TemplateDropdownMenu, "");

UIDropDownMenu_Initialize(CHA_TemplateDropdownMenu, function(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	info.text = "Move up";
	info.func = CHA_TemplateDropdownMenu_MoveUp;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Move down";
	info.func = CHA_TemplateDropdownMenu_MoveDown;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Copy template";
	info.func = CHA_TemplateDropdownMenu_Clone;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Rename template";
	info.func = CHA_TemplateDropdownMenu_Rename;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Delete template";
	info.func = CHA_TemplateDropdownMenu_Delete;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)
end);

--	DropDown menu for Target options:
local CHA_TargetDropdownMenu = CreateFrame("FRAME", "CHA_TargetDropdownMenuFrame", UIParent, "UIDropDownMenuTemplate");
CHA_TargetDropdownMenu:SetPoint("CENTER");
CHA_TargetDropdownMenu:Hide();
UIDropDownMenu_SetWidth(CHA_TargetDropdownMenu, 1);
UIDropDownMenu_SetText(CHA_TargetDropdownMenu, "");

UIDropDownMenu_Initialize(CHA_TargetDropdownMenu, function(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	info.text = "Move up";
	info.func = CHA_TargetDropdownMenu_MoveUp;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Move down";
	info.func = CHA_TargetDropdownMenu_MoveDown;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Rename target";
	info.func = CHA_TargetDropdownMenu_Rename;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Delete target";
	info.func = CHA_TargetDropdownMenu_Delete;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)
end);

--	Dropdown menu for Symbol(target) selection:
CHA_SymbolTargetDropdownMenu = CreateFrame("FRAME", "CHA_SymbolTargetDropdownMenuFrame", UIParent, "UIDropDownMenuTemplate");
CHA_SymbolTargetDropdownMenu:SetPoint("CENTER");
CHA_SymbolTargetDropdownMenu:Hide();
UIDropDownMenu_SetWidth(CHA_SymbolTargetDropdownMenu, 1);
UIDropDownMenu_SetText(CHA_SymbolTargetDropdownMenu, "");

UIDropDownMenu_Initialize(CHA_SymbolTargetDropdownMenu, function(self, level, menuList)
	if CHA_SymbolTargetDropdown_Initialize then
		CHA_SymbolTargetDropdown_Initialize(self, level, menuList); 
	end;
end);

--	Dropdown menu for Player selection:
CHA_PlayerDropdownMenu = CreateFrame("FRAME", "CHA_PlayerDropdownMenuFrame", UIParent, "UIDropDownMenuTemplate");
CHA_PlayerDropdownMenu:SetPoint("CENTER");
CHA_PlayerDropdownMenu:Hide();
UIDropDownMenu_SetWidth(CHA_PlayerDropdownMenu, 1);
UIDropDownMenu_SetText(CHA_PlayerDropdownMenu, "");

UIDropDownMenu_Initialize(CHA_PlayerDropdownMenu, function(self, level, menuList)
	if CHA_PlayerDropdown_Initialize then
		CHA_PlayerDropdown_Initialize(self, level, menuList); 
	end;
end);

--	DropDown menu for Assigned(Player) options:
local CHA_AssignedDropdownMenu = CreateFrame("FRAME", "CHA_AssignedDropdownMenuFrame", UIParent, "UIDropDownMenuTemplate");
CHA_AssignedDropdownMenu:SetPoint("CENTER");
CHA_AssignedDropdownMenu:Hide();
UIDropDownMenu_SetWidth(CHA_AssignedDropdownMenu, 1);
UIDropDownMenu_SetText(CHA_AssignedDropdownMenu, "");

UIDropDownMenu_Initialize(CHA_AssignedDropdownMenu, function(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	info.text = "Move up";
	info.func = CHA_AssignedDropdownMenu_MoveUp;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Move down";
	info.func = CHA_AssignedDropdownMenu_MoveDown;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Delete target";
	info.func = CHA_AssignedDropdownMenu_Delete;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)
end);



--	Classes setup:
local CHA_ClassMatrix = { };
local CHA_CLASS_MATRIX_MASTER = {
	["DRUID"] = {
		["MASK"] = CHA_CLASS_DRUID,
		["ICON"] = 625999,
		["ROLE"] = CHA_ROLE_TANK + CHA_ROLE_HEAL + CHA_ROLE_DECURSE,
		["COLOR"] = { 255, 125, 10 },
	},
	["HUNTER"] = {
		["MASK"] = CHA_CLASS_HUNTER,
		["ICON"] = 626000,
		["ROLE"] = CHA_ROLE_NONE,
		["COLOR"] = { 171, 212, 115 },
	},
	["MAGE"] = {
		["MASK"] = CHA_CLASS_MAGE,
		["ICON"] = 626001,
		["ROLE"] = CHA_ROLE_DECURSE,
		["COLOR"] = { 105, 204, 240 },
	},
	["PALADIN"] = {
		["MASK"] = CHA_CLASS_PALADIN,
		["ICON"] = 626003,
		["ALLIANCE-EXPAC"] = 1,
		["HORDE-EXPAC"] = 2,
		["ROLE"] = CHA_ROLE_NONE,	-- Paladin role is set during initialization since it depends on expac.
		["COLOR"] = { 245, 140, 186 },
	},
	["PRIEST"] = {
		["MASK"] = CHA_CLASS_PRIEST,
		["ICON"] = 626004,
		["ROLE"] = CHA_ROLE_HEAL,
		["COLOR"] = { 255, 255, 255 },
	},
	["ROGUE"] = {
		["MASK"] = CHA_CLASS_ROGUE,
		["ICON"] = 626005,
		["ROLE"] = CHA_ROLE_NONE,
		["COLOR"] = { 255, 245, 105 },
	},
	["SHAMAN"] = {
		["MASK"] = CHA_CLASS_SHAMAN,
		["ICON"] = 626006,
		["ALLIANCE-EXPAC"] = 2,
		["HORDE-EXPAC"] = 1,
		["ROLE"] = CHA_ROLE_HEAL,
		["COLOR"] = { 0, 112, 221 },
	},
	["WARLOCK"] = {
		["MASK"] = CHA_CLASS_WARLOCK,
		["ICON"] = 626007,
		["ROLE"] = CHA_ROLE_NONE,
		["COLOR"] = { 148, 130, 201 },
	},
	["WARRIOR"] = {
		["MASK"] = CHA_CLASS_WARRIOR,
		["ICON"] = 626008,
		["ROLE"] = CHA_ROLE_TANK,
		["COLOR"] = { 199, 156, 110 },
	},
	["DEATHKNIGHT"] = {
		["MASK"] = CHA_CLASS_DEATHKNIGHT,
		["ICON"] = 135771,
		["ALLIANCE-EXPAC"] = 3,
		["HORDE-EXPAC"] = 3,
		["ROLE"] = CHA_ROLE_TANK,
		["COLOR"] = { 196, 30, 58 },
	},
};




--[[
	Slash commands

	Main entry for CHA "slash" commands.
	This will send the request to one of the sub slash commands.
	Syntax: /cha [option, defaulting to "cfg"]
	Added in: 2.0.0
]]
SLASH_CHA_CHA1 = "/cha"
SlashCmdList["CHA_CHA"] = function(msg)
	local _, _, option, params = string.find(msg, "(%S*).?(%S*)")

	if not option or option == "" then
		option = "CFG";
	end;

	option = string.upper(option);
		
	if (option == "CFG" or option == "CONFIG") then
		SlashCmdList["CHA_CONFIG"]();
	elseif option == "HELP" then
		SlashCmdList["CHA_HELP"]();
	elseif option == "VERSION" then
		SlashCmdList["CHA_VERSION"]();
	else
		CHA_Echo(string.format("Unknown command: %s", option));
	end
end

--[[
	Show the configuration dialogue
	Syntax: /chaconfig, /chacfg
	Alternative: /cha config, /cha cfg
	Added in: 2.0.0
]]
SLASH_CHA_CONFIG1 = "/chaconfig"
SLASH_CHA_CONFIG2 = "/chacfg"
SlashCmdList["CHA_CONFIG"] = function(msg)
	CHA_OpenConfigurationDialogue();
end

--[[
	Request client version information
	Syntax: /chaversion
	Alternative: /cha version
	Added in: 2.0.0
]]
SLASH_CHA_VERSION1 = "/chaversion"
SlashCmdList["CHA_VERSION"] = function(msg)
	if IsInRaid() or DIGAM_IsInParty() then
		CHA_SendAddonMessage("TX_VERSION##");
	else
		CHA_Echo(string.format("%s is using ClassicHealingAssignments version %s", GetUnitName("player", true), GetAddOnMetadata(CHA_ADDON_NAME, "Version")));
	end
end

--[[
	Show HELP options
	Syntax: /chahelp
	Alternative: /cha help
	Added in: 2.0.0
]]
SLASH_CHA_HELP1 = "/chahelp"
SlashCmdList["CHA_HELP"] = function(msg)
	CHA_Echo(string.format("ClassicHealingAssignments version %s options:", GetAddOnMetadata(CHA_ADDON_NAME, "Version")));
	CHA_Echo("Syntax:");
	CHA_Echo("    /cha [command]");
	CHA_Echo("Where commands can be:");
	CHA_Echo("    Config       (default) Open the configuration dialogue.");
	CHA_Echo("    Version      Request version info from all clients.");
	CHA_Echo("    Help         This help.");
end




--[[
	Helper functions
--]]
function CHA_Echo(msg)
	if msg then
		DEFAULT_CHAT_FRAME:AddMessage(COLOUR_CHAT .. msg .. CHAT_END)
	end
end

local function CHA_CalculateVersion(versionString)
	local _, _, major, minor, patch = string.find(versionString, "([^\.]*)\.([^\.]*)\.([^\.]*)");
	local version = 0;

	if (tonumber(major) and tonumber(minor) and tonumber(patch)) then
		version = major * 100 + minor;
	end
	
	return version;
end

local function CHA_CheckIsNewVersion(versionstring)
	local incomingVersion = CHA_CalculateVersion( versionstring );

	if (CHA_CurrentVersion > 0 and incomingVersion > 0) then
		if incomingVersion > CHA_CurrentVersion then
			if not CHA_UpdateMessageShown then
				CHA_UpdateMessageShown = true;
				CHA_Echo(string.format("NOTE: A newer version of ".. COLOUR_INTRO .."ClassicHealingAssignments"..COLOUR_CHAT.."! is available (version %s)!", versionstring));
				CHA_Echo("You can download latest version from https://www.curseforge.com/ or https://github.com/Sentilix/ClassicHealingAssignments.");
			end
		end	
	end
end



--[[
	Initialization functions
--]]
local function CHA_PreInitialization()
	CHA_Templates = { };

	CHA_InitializeClassMatrix();

	CHA_InitializeUI();
end;

local function CHA_PostInitialization()
	CHA_ReadConfigurationSettings();
	CHA_UpdateUI();
end;

--	Read all configuration options, and fill in with defaults if not present.
--	Therefore value is written back immediately:
function CHA_ReadConfigurationSettings()
	--	Current active template:
	CHA_ActiveTemplate = CHA_GetOption(CHA_KEY_ActiveTemplate, CHA_DEFAULT_ActiveTemplate);
	CHA_SetOption(CHA_KEY_ActiveTemplate, CHA_ActiveTemplate);

	--	Current active role:
	CHA_ActiveRole = CHA_GetOption(CHA_KEY_ActiveRole, CHA_DEFAULT_ActiveRole);
	CHA_SetOption(CHA_KEY_ActiveRole, CHA_ActiveRole);

	--	Templates: These are processed in the Template code:
	CHA_ProcessConfiguredTemplateData(CHA_GetOption(CHA_KEY_Templates, nil));
	CHA_SetOption(CHA_KEY_Templates, CHA_Templates);

end;

function CHA_GetOption(parameter, defaultValue)
	local realmname = GetRealmName();
	local playername = UnitName("player");

	-- Character level
	if CHA_PersistedData[realmname] then
		if CHA_PersistedData[realmname][playername] then
			if CHA_PersistedData[realmname][playername][parameter] then
				local value = CHA_PersistedData[realmname][playername][parameter];
				if (type(value) == "table") or value ~= "" then
					return value;
				end
			end		
		end
	end
	return defaultValue;
end

function CHA_SetOption(parameter, value)
	local realmname = GetRealmName();
	local playername = UnitName("player");

	-- Character level:
	if not CHA_PersistedData[realmname] then
		CHA_PersistedData[realmname] = { };
	end
		
	if not CHA_PersistedData[realmname][playername] then
		CHA_PersistedData[realmname][playername] = { };
	end
		
	CHA_PersistedData[realmname][playername][parameter] = value;
end



--[[
	UI Functions
--]]
function CHA_OpenConfigurationDialogue()
	CHA_UpdateUI();
	CHAMainFrame:Show();
end;

function CHA_CloseConfigurationDialogue()
	CHAMainFrame:Hide();
	CHA_SetOption(CHA_KEY_Templates, CHA_Templates);
end;

function CHA_ShowTankConfiguration()
	CHA_ActiveRole = CHA_ROLE_TANK;
	CHA_SetOption(CHA_KEY_ActiveRole, CHA_ActiveRole);
	CHA_UpdateUI();
end;

function CHA_ShowHealerConfiguration()
	CHA_ActiveRole = CHA_ROLE_HEAL;
	CHA_SetOption(CHA_KEY_ActiveRole, CHA_ActiveRole);
	CHA_UpdateUI();
end;

function CHA_ShowDecurseConfiguration()
	CHA_ActiveRole = CHA_ROLE_DECURSE;
	CHA_SetOption(CHA_KEY_ActiveRole, CHA_ActiveRole);
	CHA_UpdateUI();
end;

function CHA_ToggleConfigurationDialogue()
	if CHAMainFrame:IsVisible() then
		CHA_CloseConfigurationDialogue();
	else
		CHA_OpenConfigurationDialogue();
	end
end;

function CHA_ClassIconOnClick(sender)
	local buttonName = sender:GetName();
	local _, _, className, _ = string.find(buttonName, "classicon_(%S*)");

	local roleTemplate = CHA_GetActiveRoleTemplate();
	if not roleTemplate then return; end;

	local classInfo = CHA_ClassMatrix[className];
	if not classInfo then return; end;

	roleTemplate["Mask"] = bit.bxor(roleTemplate["Mask"], classInfo["MASK"]);

	CHA_UpdateClassIcons();
end;

function CHA_AddSymbolTargetOnClick()
	ToggleDropDownMenu(1, nil, CHA_SymbolTargetDropdownMenu, "cursor", 3, -3);
end;

function CHA_SymbolTargetDropdown_Initialize(frame, level, menuList)
	local targetMask = CHA_TARGET_DIRECTIONS + CHA_TARGET_RAIDICONS + CHA_TARGET_CUSTOM;

	if CHA_ActiveRole ~= CHA_ROLE_TANK then
		--	For healer and decursers: Add TANKS to list:
		local template = CHA_GetActiveTemplate();
		if template then
			targetMask = bit.bor(targetMask, template["Roles"]["Tanks"]["Mask"]);
		end;
	end;

	local targets = CHA_GetTargetsByMask(targetMask);

	for n=1, table.getn(targets), 1 do
		local info = UIDropDownMenu_CreateInfo();
		info.notCheckable = true;
		info.text       = targets[n][5] or targets[n][2];
		info.icon		= targets[n][3];
		info.func       = function() CHA_SymbolTargetDropdownClick(this, targets[n]) end;
		UIDropDownMenu_AddButton(info);
	end
end;


function CHA_SymbolTargetDropdownClick(self, target)
	CHA_CreateTarget(target);
end;

function CHA_TemplateOnClick(sender)
	local buttonName = sender:GetName();
	local buttonType = GetMouseButtonClicked();
	local _, _, index, _ = string.find(buttonName, "template_(%d*)");

	if index then
		CHA_CurrentTemplateIndex = 1 * index;

		if buttonType == "RightButton" then
			ToggleDropDownMenu(1, nil, CHA_TemplateDropdownMenu, "cursor", 3, -3);
		else
			local template = CHA_GetTemplateById(CHA_CurrentTemplateIndex);
			if template then
				CHA_ActiveTemplate = template["TemplateName"];
				CHA_SetOption(CHA_KEY_ActiveTemplate, CHA_ActiveTemplate);
			end;
			CHA_UpdateUI();
		end;
	end;
end;

function CHA_TemplateDropdownMenu_MoveUp()
	if CHA_CurrentTemplateIndex > 1 then
		CHA_SwapTemplates(CHA_CurrentTemplateIndex - 1);
		CHA_UpdateUI();
	end;
end;

function CHA_TemplateDropdownMenu_MoveDown(...)
	if CHA_CurrentTemplateIndex < table.getn(CHA_Templates) then
		CHA_SwapTemplates(CHA_CurrentTemplateIndex);
		CHA_UpdateUI();
	end;
end;

function CHA_TemplateDropdownMenu_Clone()
	local template = CHA_GetTemplateById(CHA_CurrentTemplateIndex);
	local templateName = template["TemplateName"];
	CHA_CurrentTemplateOperation = "CLONE";

	StaticPopup_Show("CHA_DIALOG_ADDTEMPLATE", templateName);
end;

function CHA_TemplateDropdownMenu_Rename()
	local template = CHA_GetTemplateById(CHA_CurrentTemplateIndex);
	local templateName = template["TemplateName"];
	CHA_CurrentTemplateOperation = "RENAME";

	StaticPopup_Show("CHA_DIALOG_ADDTEMPLATE", templateName);
end;

function CHA_TemplateDropdownMenu_Delete()
	local template = CHA_GetTemplateById(CHA_CurrentTemplateIndex);
	local templateName = template["TemplateName"];

	DIGAM_ShowConfirmation(string.format("Really delete the template '%s'?", templateName), CHA_TemplateDropdownMenu_Delete_OK);
end;

function CHA_TemplateDropdownMenu_Delete_OK()
	local template = CHA_GetTemplateById(CHA_CurrentTemplateIndex);
	local templateName = template["TemplateName"];
	if CHA_ActiveTemplate == templateName then
		CHA_ActiveTemplate = nil;
		CHA_SetOption(CHA_KEY_ActiveTemplate, CHA_ActiveTemplate);
	end;

	CHA_Templates[CHA_CurrentTemplateIndex] = nil;
	CHA_Templates = DIGAM_RenumberTable(CHA_Templates);

	CHA_UpdateUI();
end;

function CHA_SwapTemplates(firstIndex)
	local templateA = CHA_Templates[firstIndex];
	CHA_Templates[firstIndex] = CHA_Templates[firstIndex + 1];
	CHA_Templates[firstIndex + 1] = templateA;
end;

function CHA_AddTemplateOnClick()
	StaticPopup_Show("CHA_DIALOG_ADDTEMPLATE");
end;

function CHA_AddTemplate_OK(templateName)
	if not CHA_GetTemplateByName(templateName) then
		CHA_CreateTemplate(templateName);
	else
		DIGAM_ShowError("A template with that name already exists.");
	end;

	CHA_UpdateUI();
end;

function CHA_RenameTemplate_OK(oldTemplateName, newTemplateName)
	if CHA_GetTemplateByName(newTemplateName) then
		DIGAM_ShowError("A template with that name already exists.");
		return;
	end;

	local index, template = CHA_GetTemplateByName(oldTemplateName);
	if not index then
		DIGAM_ShowError(string.format("The template '%s' was not found.", oldTemplateName));
		return;
	end;

	if CHA_CurrentTemplateOperation == "RENAME" then
		--	Rename existing template:
		CHA_Templates[index]["TemplateName"] = newTemplateName;

		if CHA_ActiveTemplate == oldTemplateName then
			CHA_ActiveTemplate = newTemplateName;
			CHA_SetOption(CHA_KEY_ActiveTemplate, CHA_ActiveTemplate);
		end;
	elseif CHA_CurrentTemplateOperation == "CLONE" then
		--	Clone template to new (keep existing)
		local newIndex = CHA_CreateTemplate(newTemplateName);

		local template = DIGAM_CloneTable(CHA_Templates[index]);
		template["TemplateName"] = newTemplateName;
		CHA_Templates[newIndex] = template;

		--	Move copy up below original table:
		for n = newIndex-1, index+1, -1 do
			CHA_SwapTemplates(n);
		end;
	end;

	CHA_UpdateUI();
end;
 
function CHA_UpdateRoleButtons()
 	CHA_UpdateRoleCounter();

	if CHA_ActiveRole == CHA_ROLE_TANK then
		CHAMainFrameTankButton:Disable();
		CHAMainFrameHealButton:Enable();
		CHAMainFrameDecurseButton:Enable();
	elseif CHA_ActiveRole == CHA_ROLE_HEAL then
		CHAMainFrameTankButton:Enable();
		CHAMainFrameHealButton:Disable();
		CHAMainFrameDecurseButton:Enable();
	elseif CHA_ActiveRole == CHA_ROLE_DECURSE then
		CHAMainFrameTankButton:Enable();
		CHAMainFrameHealButton:Enable();
		CHAMainFrameDecurseButton:Disable();
	end;
end;


--[[
	Target functions
--]]
function CHA_CreateTarget(target)
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if not roleTemplate then return; end;

	if target[1] == 0 then return; end;

	local targetInfo = { ["Mask"] = target[1], ["Name"] = target[2], ["Icon"] = target[3] };

	tinsert(roleTemplate["Targets"], targetInfo);

	CHA_UpdateTargetFrames();
end;

function CHA_GetTargetMask()
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if not roleTemplate then return; end;

	--	Find TARGET whivh tanks/healers/decursers will be assigned to.
	local targetMask = CHA_TARGET_DIRECTIONS + CHA_TARGET_RAIDICONS + CHA_TARGET_CUSTOM;

	--	Add all classes configured for the active template+role:
	if roleTemplate["Mask"] then
		targetMask = bit.bor(targetMask, roleTemplate["Mask"]);
	end;

	return targetMask;
end;

--	Fetch all Target marks.
--	If includeUsedTargets is set, result will include both used and unused targets.
function CHA_GetTargetsByMask(mask, includeUsedTargets)
	local targets = { };

	if not mask then mask = 0; end;
	
	if bit.band(mask, CHA_TARGET_PLAYERS) > 0 then
		--	Players:
		local players = CHA_GetPlayersInRoster();

		for n = 1, table.getn(players), 1 do
			local player = players[n];
			if bit.band(mask, player["MASK"]) > 0 then
				if includeUsedPlayers or not CHA_IsPlayerUsedInTemplates(player["FULLNAME"], true) then
					tinsert(targets, { player["MASK"], player["FULLNAME"], player["ICON"], player["CLASS"], player["DISPNAME"] } );
				end;
			end;
		end;
	end;

	if bit.band(mask, CHA_TARGET_SYMBOLS) > 0 then
		--	Add SYMBOLS:
		for n = 1, table.getn(CHA_TargetMatrix), 1 do
			if includeUsedTargets or not CHA_IsTargetInUse(CHA_TargetMatrix[n][1], CHA_ActiveRole) then
				if bit.band(mask, CHA_TargetMatrix[n][1]) > 0 then
					tinsert(targets, CHA_TargetMatrix[n]);
				end;
			end;
		end;
	end;

	return targets;
end;

function CHA_IsTargetInUse(targetMask, targetRole)
	local template = CHA_GetActiveTemplate();

	if template then
		if bit.band(targetRole, CHA_ROLE_TANK) > 0 then
			if template["Roles"]["Tanks"] and template["Roles"]["Tanks"]["Targets"] then
				for k, v in next, template["Roles"]["Tanks"]["Targets"] do
					if v["Mask"] == targetMask then
						return true;
					end;
				end;
			end;
		end;

		if bit.band(targetRole, CHA_ROLE_HEAL) > 0 then
			if template["Roles"]["Heals"] and template["Roles"]["Heals"]["Targets"] then
				for k, v in next, template["Roles"]["Heals"]["Targets"] do
					if v["Mask"] == targetMask then
						return true;
					end;
				end;
			end;
		end;

		if bit.band(targetRole, CHA_ROLE_DECURSE) > 0 then
			if template["Roles"]["Decurses"] and template["Roles"]["Decurses"]["Targets"] then
				for k, v in next, template["Roles"]["Decurses"]["Targets"] do
					if v["MASK"] == targetMask then
						return true;
					end;
				end;
			end;
		end;
	end;

	return false;
end;

function CHA_CreateTargetFrames()
	local fOuterWidth	= 560;
	local fOuterHeight	= 280;
	local fInnerWidth	= 560;
	local fInnerHeight	= fOuterHeight / CHA_FRAME_MAXTARGET;

	local playerHeight = fInnerHeight / 2;
	local playerWidth = 107;
	local playerOffset = 137;
	local playersPerRow = CHA_FRAME_MAXPLAYERS / 2;

	local frameY = 0;
	for index = 1, CHA_FRAME_MAXTARGET, 1 do
		local fTargetName = string.format("targetframe_%d", index);
		local fTarget = CreateFrame("Frame", fTargetName, CHAMainFrameTargets, "FrameBackgroundTemplate");
		fTarget:SetWidth(fInnerWidth);
		fTarget:SetHeight(fInnerHeight);
		fTarget:SetFrameStrata("HIGH");
		fTarget:SetPoint("TOPLEFT", 0, frameY);

		--	Each target has an ICON:
		local fTargetIconName = string.format("targeticon_%d", index);
		local fTargetIcon = CreateFrame("Button", fTargetIconName, fTarget, "CHATargetButtonTemplate");
		fTargetIcon:SetAlpha(CHA_ALPHA_ENABLED);
		fTargetIcon:SetPoint("LEFT", 0, 0);
		fTargetIcon:SetNormalTexture(string.format("Interface\\TargetingFrame\\UI-RaidTargetingIcon_%d", index));
		fTargetIcon:SetPushedTexture(string.format("Interface\\TargetingFrame\\UI-RaidTargetingIcon_%d", index));
		--	... with a Caption:
		local fTargetCaptionName = string.format("targetcaption_%d", index);
		local fTargetCaption = fTarget:CreateFontString(fTargetCaptionName, "OVERLAY", "GameTooltipText");
		fTargetCaption:SetPoint("LEFT", 20, 0);
		fTargetCaption:SetText("Target");

		--	And an ability to ADD a new Tank for that specific target:
		local fTargetButtonName = string.format("targetbutton_%d", index);
		local fTargetButton = CreateFrame("Button", fTargetButtonName, fTarget, "UIPanelButtonTemplate");
		fTargetButton:SetPoint("LEFT", 120, 0);
		fTargetButton:SetHeight(12);
		fTargetButton:SetWidth(12);
		fTargetButton:SetText("+");
		fTargetButton:SetScript("OnClick", CHA_TargetButtonOnClick);

		fTarget:Show();
		frameY = frameY - fInnerHeight;


		--	PLAYER FRAME: Each frame can have up to CHA_FRAME_MAXPLAYERS tanks assigned.
		local posX = playerOffset;
		local posY = 0;
		for playerIndex = 1, CHA_FRAME_MAXPLAYERS, 1 do
			--	And an ability to ADD a new Player for that specific target:
			local fPlayerButtonName = string.format("playerbutton_%d_%d", index, playerIndex);
			local fPlayerButton = CreateFrame("Button", fPlayerButtonName, fTarget, "CHAPlayerButtonTemplate");
			fPlayerButton:SetPoint("LEFT", posX, posY);
			fPlayerButton:SetHeight(playerHeight-1);
			fPlayerButton:SetWidth(playerWidth-1);
			_G[fPlayerButton:GetName().."Caption"]:SetText("");

			posX = posX + playerWidth;
			if playerIndex == playersPerRow then
				posX = playerOffset;
				posY = posY - playerHeight;
			end;
		end;
	end;
end;

function CHA_PlayerDropdown_Initialize()
	if CHA_CurrentPlayerIndex == 0 then return; end;

	local roleTemplate = CHA_GetActiveRoleTemplate();
	if not roleTemplate then return; end;
	local target = roleTemplate["Targets"][CHA_CurrentPlayerIndex];
	local players = CHA_GetPlayersByMask(roleTemplate["Mask"]);

	for n=1, table.getn(players), 1 do
		local info = UIDropDownMenu_CreateInfo();
		info.notCheckable = true;
		info.text       = players[n][2];
		info.icon		= players[n][3];
		info.func       = function() CHA_PlayerDropdownClick(this, players[n]) end;
		UIDropDownMenu_AddButton(info);
	end
end;

function CHA_PlayerDropdownClick(sender, playerInfo)
	--	Now ASSIGN this player to the current ROLE:
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if not roleTemplate then return; end;

	local roleTarget = roleTemplate["Targets"][CHA_CurrentPlayerIndex];
	if not roleTarget then
		roleTarget = { };
	end;

	if not roleTarget["Players"] then
		roleTarget["Players"] = { };
	end;
	
	tinsert(roleTarget["Players"], { 
		["Mask"] = playerInfo[1], 
		["Name"] = playerInfo[2], 
		["Icon"] = playerInfo[3], 
		["Class"] = playerInfo[4],
	});

	--	Good news: Player is added.
	--	Bad news: We have no link from a Player assignment to a Target.
	--	Furthermore there are no checks to see if a player is double-assignet.
	--	I need to implement same check as on Symbols.

	CHA_UpdateTargetFrames();
end;

function CHA_TargetButtonOnClick(sender)
	local buttonName = sender:GetName();
	local _, _, index, _ = string.find(buttonName, "targetbutton_(%d*)");

	CHA_CurrentPlayerIndex = 1 * index;
	ToggleDropDownMenu(1, nil, CHA_PlayerDropdownMenu, "cursor", 3, -3);
end;

function CHA_PlayerButtonOnClick(sender)
	local buttonName = sender:GetName();
	local _, _, targetIndex, playerIndex = string.find(buttonName, "playerbutton_(%d*)_(%d*)");

	CHA_CurrentTargetIndex = 1 * targetIndex;
	CHA_CurrentPlayerIndex = 1 * playerIndex;
	ToggleDropDownMenu(1, nil, CHA_AssignedDropdownMenu, "cursor", 3, -3);
end;

function CHA_AssignedDropdownMenu_MoveUp()
	if CHA_CurrentTargetIndex > 1 then
		CHA_MoveAssignedPlayer(CHA_CurrentPlayerIndex, CHA_CurrentTargetIndex, CHA_CurrentTargetIndex - 1);
		CHA_UpdateTargetFrames();
	end;
end;

function CHA_AssignedDropdownMenu_MoveDown()
	local roleTarget = CHA_GetActiveTargetTemplate();
	if not roleTarget then return; end;

	if CHA_CurrentTargetIndex < table.getn(roleTarget) then
		CHA_MoveAssignedPlayer(CHA_CurrentPlayerIndex, CHA_CurrentTargetIndex, CHA_CurrentTargetIndex + 1);
		CHA_UpdateTargetFrames();
	end;
end;

function CHA_MoveAssignedPlayer(playerIndex, startTargetIndex, endTargetIndex)
	local roleTarget = CHA_GetActiveTargetTemplate();
	if not roleTarget then return; end;

	playerIndex = tonumber(playerIndex);
	startTargetIndex = tonumber(startTargetIndex);
	endTargetIndex = tonumber(endTargetIndex);

	local sourceTarget = roleTarget[startTargetIndex];
	local destTarget = roleTarget[endTargetIndex];
	if not sourceTarget or not destTarget then return; end;

	if not destTarget["Players"] then destTarget["Players"] = { }; end;

	if sourceTarget["Players"][playerIndex] then
		tinsert(destTarget["Players"], sourceTarget["Players"][playerIndex]);

		sourceTarget["Players"][playerIndex] = nil;
		sourceTarget["Players"] = DIGAM_RenumberTable(sourceTarget["Players"]);

		CHA_UpdateTargetFrames();
	end;
end;


--	Delete (remove) assigned player.
--	This does NOT trigger a popup, thats intentiona to keep # of popups a little down!
function CHA_AssignedDropdownMenu_Delete()
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if not roleTemplate then return; end;

	local roleTarget = roleTemplate["Targets"][CHA_CurrentTargetIndex];
	if not roleTarget or not roleTarget["Players"] then return; end;

	if roleTarget["Players"][CHA_CurrentPlayerIndex] then
		roleTarget["Players"][CHA_CurrentPlayerIndex] = nil;
		roleTarget["Players"] = DIGAM_RenumberTable(roleTarget["Players"]);
	end;

	CHA_UpdateTargetFrames();
end;


function CHA_GetPlayersByMask(roleMask, includeUsedPlayers)
	local targets = { };
	local players = CHA_GetPlayersInRoster();

	for n = 1, table.getn(players), 1 do
		local player = players[n];
		if bit.band(player["MASK"], roleMask) > 0 then

			if includeUsedPlayers or not CHA_IsPlayerUsedInTemplates(player["FULLNAME"]) then
				tinsert(targets, { player["MASK"], player["FULLNAME"], player["ICON"], player["CLASS"], player["DISPNAME"] } );
			end;
		end;
	end;

	return targets;
end; 


function CHA_IsPlayerInTemplate(roleTemplate, playerName, checkTarget, checkAssignment)
	--	Check if player is assigned as role in //Template/Roles/<role>/Targets/<targetIndex>/Players/<playerIndex>/:
	for targetIndex = 1, table.getn(roleTemplate["Targets"]), 1 do
		local targetTpl = roleTemplate["Targets"][targetIndex];
		if targetTpl then
			if checkTarget and targetTpl["Name"] == playerName then
				return true;
			end;

			if checkAssignment and targetTpl["Players"] then
				for playerIndex = 1, table.getn(targetTpl["Players"]), 1 do
					local playerTpl = targetTpl["Players"][playerIndex];
					if playerTpl["Name"] == playerName then
						return true;
					end; 
				end;
			end;
		end;
	end;
end;

--	isTargetDropdown: True if called from TARGET dropdown, False if from Assignments.
--	Those have different rules when checking for player assignments.
function CHA_IsPlayerUsedInTemplates(playerName, isTargetDropdown)
	local template = CHA_GetActiveTemplate();
	if not template then return false; end;

	--	TANK ROLE: A player cannot be assigned as tank if already assigned as tank or healer.
	if CHA_ActiveRole == CHA_ROLE_TANK then
		if CHA_IsPlayerInTemplate(template["Roles"]["Tanks"], playerName, false, true) then
			return true;
		end;
		if CHA_IsPlayerInTemplate(template["Roles"]["Heals"], playerName, false, true) then
			return true;
		end;
	end;

	--	HEAL ROLE: A player cannot be assigned as healer if already assigned as tank or healer.
	if CHA_ActiveRole == CHA_ROLE_HEAL then
		if CHA_IsPlayerInTemplate(template["Roles"]["Heals"], playerName, true, true) then
			return true;
		end;

		if not isTargetDropdown then
			if CHA_IsPlayerInTemplate(template["Roles"]["Tanks"], playerName, false, true) then
				return true;
			end;
		end;
	end;

	--	DECURSOR ROLE: Any player can be ASSIGNED. Targets follows usual rules.
	if CHA_ActiveRole == CHA_ROLE_DECURSE then
		if isTargetDropdown then
			if CHA_IsPlayerInTemplate(template["Roles"]["Decurses"], playerName, true, false) then
				return true;
			end;
		end;

		if CHA_IsPlayerInTemplate(template["Roles"]["Decurses"], playerName, false, true) then
			return true;
		end;
	end;

	return false;
end;


function CHA_GetPlayersInRoster()
	local unitid, playerName, className, classInfo;

	local players = { };		-- List of { "NAME", "FULLNAME", "DISPNAME", "CLASS", "MASK", "ICON" }

	if IsInRaid() then
		for n = 1, 40, 1 do
			unitid = "raid"..n;

			playerName = DIGAM_GetPlayer(unitid);
			if not playerName then break; end;
			
			fullName = DIGAM_GetPlayerAndRealm(unitid);
			className = DIGAM_UnitClass(unitid);		
			classInfo = CHA_ClassMatrix[className];

			tinsert(players, { ["NAME"] = playerName, ["FULLNAME"] = fullName, ["DISPNAME"] = CHA_FormatPlayerName(fullName), ["CLASS"] = className, ["MASK"] = classInfo["MASK"], ["ICON"] = classInfo["ICON"] });
		end;

	elseif DIGAM_IsInParty() then
		for n = 1, GetNumGroupMembers(), 1 do
			unitid = "party"..n;
			playerName = DIGAM_GetPlayer(unitid);
			if not playerName then
				unitid = "player";
				playerName = DIGAM_GetPlayer(unitid);
			end;
			className = DIGAM_UnitClass(unitid);		
			classInfo = CHA_ClassMatrix[className];

			tinsert(players, { ["NAME"] = playerName, ["FULLNAME"] = DIGAM_GetPlayerAndRealm(unitid), ["CLASS"] = className, ["MASK"] = classInfo["MASK"], ["ICON"] = classInfo["ICON"] });
		end;
	else
		--	SOLO play, somewhat usefull when testing
		unitid = "player";
		className = DIGAM_UnitClass(unitid);
		classInfo = CHA_ClassMatrix[className];

		tinsert(players, { ["NAME"] = DIGAM_GetPlayer(unitid), ["FULLNAME"] = DIGAM_GetPlayerAndRealm(unitid), ["CLASS"] = className, ["MASK"] = classInfo["MASK"], ["ICON"] = classInfo["ICON"] });
	end;

	return players;
end;


--	Update TARGET icons, captions etc for the selected Frame.
function CHA_UpdateTargetFrames()
	local roleTemplate = CHA_GetActiveRoleTemplate();

	local roleTargets = { };
	if roleTemplate and roleTemplate["Targets"] then
		roleTargets = roleTemplate["Targets"];
	end;

	local playerMask = roleTargets["Mask"];

	for index = 1, CHA_FRAME_MAXTARGET, 1 do
		local fTarget = _G[string.format("targetframe_%d", index)];
		local fTargetIcon = _G[string.format("targeticon_%d", index)];
		local fTargetCaption = _G[string.format("targetcaption_%d", index)];
		local fTargetButton = _G[string.format("targetbutton_%d", index)];

		local target = roleTargets[index];
		if target then
			fTargetIcon:SetNormalTexture(target["Icon"]);
			fTargetIcon:SetPushedTexture(target["Icon"]);
			fTargetCaption:SetText(CHA_FormatPlayerName(target["Name"]));


			--	PLAYER FRAME: Each frame can have up to CHA_FRAME_MAXPLAYERS tanks assigned.
			--	Same player frames are used by both Tanks, Healers and Decursers
			local roleTarget = roleTemplate["Targets"][index];

			local posX = playerOffset;
			local posY = 0;
			for playerIndex = 1, CHA_FRAME_MAXPLAYERS, 1 do
				local player = roleTarget["Players"] and roleTarget["Players"][playerIndex];
				if player then
					local color = CHA_ClassMatrix[player["Class"]]["COLOR"];
					local fPlayerButtonName = string.format("playerbutton_%d_%d", index, playerIndex);
					local fPlayerButton = _G[fPlayerButtonName];
					_G[fPlayerButtonName.."Caption"]:SetText(CHA_FormatPlayerName(player["Name"]));
					_G[fPlayerButtonName.."BG"]:SetVertexColor( color[1]/255, color[2]/255, color[3]/255 );
					fPlayerButton:Show();
				else
					local fPlayerButtonName = string.format("playerbutton_%d_%d", index, playerIndex);
					local fPlayerButton = _G[fPlayerButtonName];
					_G[fPlayerButtonName.."Caption"]:SetText("");
					_G[fPlayerButtonName.."Caption"]:SetTextColor(1, 1, 1);
					fPlayerButton:Hide();
				end;
			end;

			fTarget:Show();
		else
			fTarget:Hide();
		end;
	end;
end;

function CHA_FormatPlayerName(playerName)
	--local _, _, name = string.find(playerName, "([%S]*-%S)%S*");
	local _, _, name, realm = string.find(playerName, "([%S]*)-(%S)%S*");
	if not name then
		return playerName; 
	end;

	name = string.format("%s:%s", realm, name);

	return name;
end;

function CHA_TargetDropdownMenu_MoveUp()
	if CHA_CurrentTargetIndex > 1 then
		CHA_SwapTargets(CHA_CurrentTargetIndex - 1, CHA_CurrentTargetIndex);
		CHA_UpdateTargetFrames();
	end;
end;

function CHA_TargetDropdownMenu_MoveDown()
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if roleTemplate and roleTemplate["Targets"] then
		if CHA_CurrentTargetIndex < table.getn(roleTemplate["Targets"]) then
			CHA_SwapTargets(CHA_CurrentTargetIndex, CHA_CurrentTargetIndex + 1);
			CHA_UpdateTargetFrames();
		end;
	end;
end;

function CHA_TargetDropdownMenu_Rename()
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if roleTemplate and roleTemplate["Targets"] and roleTemplate["Targets"][CHA_CurrentTargetIndex] then
		local targetName = roleTemplate["Targets"][CHA_CurrentTargetIndex]["Name"];
		StaticPopup_Show("CHA_DIALOG_RENAMETARGET", targetName);
	end;
end;

function CHA_RenameTarget_OK(oldTargetName, newTargetName)
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if roleTemplate and roleTemplate["Targets"] and roleTemplate["Targets"][CHA_CurrentTargetIndex] then
		roleTemplate["Targets"][CHA_CurrentTargetIndex]["Name"] = newTargetName;
		CHA_UpdateTargetFrames();
	end;
end;

function CHA_TargetDropdownMenu_Delete()
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if roleTemplate and roleTemplate["Targets"] and roleTemplate["Targets"][CHA_CurrentTargetIndex] then
		local targetName = roleTemplate["Targets"][CHA_CurrentTargetIndex]["Name"];

		DIGAM_ShowConfirmation(string.format("Really remove the target '%s'?", targetName), CHA_TargetDropdownMenu_Delete_OK);
	end;
end;

function CHA_TargetDropdownMenu_Delete_OK()
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if roleTemplate and roleTemplate["Targets"] and roleTemplate["Targets"][CHA_CurrentTargetIndex] then
		roleTemplate["Targets"][CHA_CurrentTargetIndex] = nil;
		roleTemplate["Targets"] = DIGAM_RenumberTable(roleTemplate["Targets"]);

		CHA_UpdateTargetFrames();
	end;
end;


--	Swap targets (Tanks are not swapped with them!)
function CHA_SwapTargets(firstIndex)
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if roleTemplate and roleTemplate["Targets"] then
		local targetA = roleTemplate["Targets"][firstIndex];
		roleTemplate["Targets"][firstIndex] = roleTemplate["Targets"][firstIndex + 1];
		roleTemplate["Targets"][firstIndex + 1] = targetA;
	end;
end;

function CHA_TargetOnClick(sender)
	local buttonName = sender:GetName();
	local buttonType = GetMouseButtonClicked();
	local _, _, index, _ = string.find(buttonName, "targeticon_(%d*)");

	if index then
		if buttonType == "RightButton" then
			CHA_CurrentTargetIndex = 1 * index;
			ToggleDropDownMenu(1, nil, CHA_TargetDropdownMenu, "cursor", 3, -3);
		else
			--	What happens when clicking on a Target? Currently same as Right clicking.
			CHA_CurrentTargetIndex = 1 * index;
			ToggleDropDownMenu(1, nil, CHA_TargetDropdownMenu, "cursor", 3, -3);
		end;
	end;
end;




function CHA_InitializeUI()
	CHA_CreateClassIcons();
	CHA_CreateTemplateButtons();
	CHA_CreateTargetFrames();

	CHA_UpdateUI();
end;

function CHA_UpdateUI()
	CHA_UpdateClassIcons();
	CHA_UpdateRoleButtons();
	CHA_UpdateTemplates();
	CHA_UpdateTargetFrames();
end;


--[[
	Communication functions
--]]
function CHA_SendAddonMessage(message)
	local memberCount = GetNumGroupMembers();
	if memberCount > 0 then
		local channel = nil;
		if IsInRaid() then
			channel = "RAID";
		elseif Thaliz_IsInParty() then
			channel = "PARTY";
		end;
		C_ChatInfo.SendAddonMessage(CHA_MESSAGE_PREFIX, message, channel);
	end;
end



--[[
	CHA business logic
--]]
function CHA_UpdateRoleCounter()
	local numTanks = 0;
	local numHealers = 0;
	local numDecursers = 0;

	local Class = ""
	for i = 1, GetNumGroupMembers() do
		class = DIGAM_UnitClass("raid"..i)
		--	TODO: Count using Class Matrix instead!
		if Class == "WARRIOR" or Class == "DRUID" then 
			numTanks = numTanks + 1;
		end

		if Class == "PRIEST" or Class == "DRUID" or Class == "SHAMAN" or Class == "PALADIN" then 
			numHealers = numHealers + 1;
		end

		if Class == "MAGE" or Class == "DRUID" then 
			numDecursers = numDecursers + 1;
		end
	end

	if CHA_ActiveRole == CHA_ROLE_TANK then
		CHAHealerCountCaption:SetText(string.format("Tanks: %s", numTanks or "?"));
	elseif CHA_ActiveRole == CHA_ROLE_HEAL then
		CHAHealerCountCaption:SetText(string.format("Healers: %s", numHealers or "?"));
	else -- Decurser:
		CHAHealerCountCaption:SetText(string.format("Decursers: %s", numDecursers or "?"));
	end;
end

--[[
	Class functions
--]]
function CHA_CreateClassIcons()

	local offsetX = 80;
	local offsetY = -2;
	local width = 24;
	local posX = offsetX;
	for className, classInfo in next, CHA_ClassMatrix do		
		local buttonName = string.format("classicon_%s", className);

		local entry = CreateFrame("Button", buttonName, CHAMainFrameClasses, "CHAClassButtonTemplate");
		entry:SetAlpha(CHA_ALPHA_DISABLED);
		entry:SetPoint("TOPLEFT", posX, offsetY);
		entry:SetNormalTexture(classInfo["ICON"]);
		entry:SetPushedTexture(classInfo["ICON"]);

		posX = posX + width;
	end;
end;

--	Update class icons based on the current template + role:
function CHA_UpdateClassIcons()
	local roleTemplate = CHA_GetActiveRoleTemplate();

	local templateMask = CHA_ROLE_NONE;
	if roleTemplate then
		templateMask = roleTemplate["Mask"];
	end;

	for className, classInfo in next, CHA_ClassMatrix do
		local buttonName = string.format("classicon_%s", className);

		if bit.band(templateMask, classInfo["MASK"]) > 0 then
			_G[buttonName]:SetAlpha(CHA_ALPHA_ENABLED);
		else
			_G[buttonName]:SetAlpha(CHA_ALPHA_DISABLED);
		end;
	end;

	
	local roleName = CHA_RoleMatrix[CHA_ActiveRole];

	CHARoleCaption:SetText(roleName);
end;



function CHA_InitializeClassMatrix()
	CHA_ClassMatrix = { };

	local factionEN = UnitFactionGroup("player");
	local expacKey = "ALLIANCE-EXPAC";
	if factionEN == "Horde" then
		expacKey = "HORDE-EXPAC";
	end;

	local paladinRole = CHA_ROLE_TANK + CHA_ROLE_HEAL;
	if CHA_Expansionlevel == 1 then
		--	Sorry, paladins cannot tank in Classic!
		paladinRole = CHA_ROLE_HEAL;
	end;

	for className, classInfo in next, CHA_CLASS_MATRIX_MASTER do
		if not classInfo[expacKey] or classInfo[expacKey] <= CHA_Expansionlevel then
			if className == "PALADIN" then
				classInfo["ROLE"] = paladinRole;
			end;
			CHA_ClassMatrix[className] = classInfo;
		end;
	end;
end;


--[[
	Template logic
--]]
function CHA_GetActiveTemplate()
	local _, template = CHA_GetTemplateByName(CHA_ActiveTemplate);
	return template;
end;

function CHA_GetActiveRoleTemplate()
	local roleName = CHA_RoleMatrix[CHA_ActiveRole];
	if not roleName then return nil; end;

	local template = CHA_GetActiveTemplate();
	if not template then return nil; end;

	return template["Roles"][roleName];
end;

function CHA_GetActiveTargetTemplate()
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if not roleTemplate then return nil; end;
	
	return roleTemplate["Targets"]
end;

--	Add a new Template to the template array
function CHA_CreateTemplate(templateName)
	local templateCount = table.getn(CHA_Templates);
	if templateCount < CHA_TEMPLATES_MAX then
		templateCount = templateCount + 1;
		CHA_Templates[templateCount] = {
			["TemplateName"] = templateName,
			["Roles"] = {
				["Tanks"] = { 
					["Caption"] = "Tanks", 
					["Mask"] = CHA_ROLE_DEFAULT_TANK,
					["Targets"] = {	},
				},
				["Heals"] = { 
					["Caption"] = "Heals", 
					["Mask"] = CHA_ROLE_DEFAULT_HEAL,
					["Targets"] = { },
				},
				["Decurses"] = { 
					["Caption"] = "Decurses", 
					["Mask"] = CHA_ROLE_DEFAULT_DECURSE,
					["Targets"] = { },
				},
			},
		};
	end;
	return templateCount;
end;

--	initialize profile names.
function CHA_CreateDefaultTemplates()
	CHA_Templates = { };

	CHA_CreateTemplate("Default");

	if CHA_Expansionlevel == 1 then
		CHA_CreateTemplate("Molten Core");
		CHA_CreateTemplate("Onyxia's Lair");
		CHA_CreateTemplate("Blackwing Lair");
		CHA_CreateTemplate("Temple of Ahn'Qiraj");
		CHA_CreateTemplate("Naxxramas");
		CHA_CreateTemplate("20 man");
	end;

	if CHA_Expansionlevel == 2 then
		CHA_CreateTemplate("Karazhan");
		CHA_CreateTemplate("Serpentshrine Cavern");
		CHA_CreateTemplate("The Eye");
		CHA_CreateTemplate("Magtheridon");
		CHA_CreateTemplate("Gruuls Lair");
		CHA_CreateTemplate("Black Temple");
		CHA_CreateTemplate("Mount Hyjal");
		CHA_CreateTemplate("Sunwell");
	end;

	CHA_CreateTemplate("Other");
end;

--	Create (initialize) the template buttons. 
--	All buttons are disabled to start with.
function CHA_CreateTemplateButtons()
	local frame = CHAMainFrameTemplates;

	local lineHeight = 20;
	local offsetX = 5;
	local offsetY = -5;
	local buttonX = offsetX;
	local buttonY = offsetY;

	local buttonName;

	for n = 1, CHA_TEMPLATES_MAX, 1 do
		local button = CreateFrame("Button", string.format("template_%d", n), CHAMainFrameTemplates, "TemplateButtonTemplate");
		button:SetPoint("TOPLEFT", buttonX, buttonY);
		button:Hide();
		buttonY = buttonY - lineHeight;
	end;
end;

--	UI update:
--	Template buttons are activated.
function CHA_UpdateTemplates()
	local frame = CHAMainFrameTemplates;

	local lineHeight = 20;
	local offsetX = 25;
	local offsetY = -108;
	local buttonX = offsetX;
	local buttonY = offsetY;

	local templateCount = table.getn(CHA_Templates);
	local buttonName, textColor;

	for n = 1, CHA_TEMPLATES_MAX, 1 do
		local button = _G[string.format("template_%d", n)];
		local caption = _G[string.format("template_%dText", n)];

		if n <= templateCount then
			if CHA_Templates[n]["TemplateName"] == CHA_ActiveTemplate then
				textColor = CHA_COLOR_SELECTED;
			else
				textColor = CHA_COLOR_UNSELECTED;
			end;
			
			caption:SetTextColor(textColor[1], textColor[2], textColor[3]);
			caption:SetText(CHA_Templates[n]["TemplateName"]);
			button:Show();
		else
			button:Hide();
		end;

		buttonY = buttonY - lineHeight;
	end;

	--	Support up to <CHA_TEMPLATES_MAX> templates, after that button is disabled:
	if templateCount < CHA_TEMPLATES_MAX then
		CHAMainFrameAddTemplateButton:Enable();
	else
		CHAMainFrameAddTemplateButton:Disable();
	end;
end;


--	Return (index, template) by name, nil if none was found.
function CHA_GetTemplateByName(templateName)
	for n=1, table.getn(CHA_Templates), 1 do
		if CHA_Templates[n]["TemplateName"] == templateName then
			return n, CHA_Templates[n];
		end;
	end;

	return nil, nil;
end;

--	Return template by ID, nil if none was found.
function CHA_GetTemplateById(templateId)
	if templateId <= table.getn(CHA_Templates) then
		return CHA_Templates[templateId];
	end;
	return nil;
end;


function CHA_ProcessConfiguredTemplateData(workTemplates)
	CHA_Templates = { };

	--[[
	The array containing the template setup is a huge table.
	We are reading data into a work table and then creating data in.the-fly to make
	sure data is consistent.

	CHA_Templates = {
		["TemplateName"] = "Molten Core",
		["Roles"] = {
			["Tanks/Heals/Decurses"] = {
				["Caption"] = "Tanks/Heals/Decurses",
				["Mask"] = 769,
				["Targets"] = 
				{
					{
						["Mask"] = 65536,
						["Name"] = "Skull",
						["Icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8",
						["Players"] = 
						{
							{
								["Class"] = "WARRIOR",
								["Mask"] = 256,
								["Name"] = "Donald-Firemaw",
								["Icon"] = 626008,
							},
						},
					},
				},
			},
		},
	},
	--]]

	--	//Templates
	if type(workTemplates) == "table" then
		for key, template in next, workTemplates do
			CHA_ImportTemplateData(template);
		end;
	end;

	if table.getn(CHA_Templates) == 0 then
		CHA_CreateDefaultTemplates();
	end;
end;

function CHA_ImportTemplateData(template)
	local templateName = template["TemplateName"];
	if not templateName then return; end;

	if not template["Roles"] then return; end;
	
	--	This creates the template with default setup data:
	local tpl = CHA_Templates[CHA_CreateTemplate(templateName)];

	--	Read tank/healer/decursers from template and overwrite defaults if available.
	for roleMask, roleName in next, CHA_RoleMatrix do
		local roleTemplate = template["Roles"][roleName];

		if roleTemplate then
			if roleTemplate["Mask"] and type(roleTemplate["Mask"]) == "string" then
				tpl["Roles"][roleName]["Mask"] = roleTemplate["Mask"];
			end;

			--	This will import last used targets.
			--	Players might even not be in the raid anymore. We will handle that later!
			local roleTargets = roleTemplate["Targets"]; 
			if roleTargets then
				if type(roleTargets) == "table" and table.getn(roleTargets) > 0 then

					--//Templates/Roles/<role>/Targets/<targetIndex>
					for targetIndex, roleTarget in next, roleTargets do
						local tMask = roleTarget["Mask"];
						local tName = roleTarget["Name"];
						local tIcon = roleTarget["Icon"];
						if tMask and tName and tIcon then
							--CHA_Echo(string.format("Importing target: %s,%s,%s", tMask or "nil", tName or "nil", tIcon or "nil"));

							local tPlayers = { };
							local rolePlayers = roleTarget["Players"];

							if type(rolePlayers) == "table" and table.getn(rolePlayers) > 0 then
								--//Templates/Roles/<role>/Targets/<targetIndex>/Players/<playerIndex>
								for playerIndex, rolePlayer in next, rolePlayers do
									local pClass = rolePlayer["Class"];
									local pMask = rolePlayer["Mask"];
									local pName = rolePlayer["Name"];
									local pIcon = rolePlayer["Icon"];

									if pClass and pMask and pName and pIcon then
										tinsert(tPlayers, { ["Class"] = pClass, ["Mask"] = pMask, ["Name"] = pName, ["Icon"] = pIcon });
									end;
								end;
							end;

							tinsert(tpl["Roles"][roleName]["Targets"], { ["Mask"] = tMask, ["Name"] = tName, ["Icon"] = tIcon, ["Players"] = tPlayers });
						end;
					end;
				end;
			end;
		end;
	end;
end;



--[[
	Event handlers
--]]
function CHA_OnEvent(self, event, ...)

	if event == "ADDON_LOADED" then
		local addonname = ...;
		if addonname == CHA_ADDON_NAME then
			CHA_PostInitialization();
		end;

	elseif event == "CHAT_MSG_ADDON" then
		local prefix, msg, channel, sender = ...;
		if prefix ~= CHA_MESSAGE_PREFIX then	
			return;
		end;

		local _, _, cmd, message, recipient = string.find(msg, "([^#]*)#([^#]*)#([^#]*)");	
		
		if not (recipient == "") then
			if not (recipient == DIGAM_GetPlayerName(UnitName("player"))) then
				return
			end
		end

		sender = DIGAM_GetPlayerName(sender);

		if cmd == "TX_VERSION" then
			CHA_HandleTXVersion(message,sender);
		elseif cmd == "RX_VERSION" then
			CHA_HandleRXVersion(message,sender);
		end;
			
		--local arg1, arg2, _, arg4 = ...;
		--if HealingAsssignments.Mainframe.SyncCheckbox:GetChecked() == 1 and string.sub(arg1, 1, 3) == prefix and arg4 ~= UnitName("player") then
		--	print("SYNC")
		--	local TemplateNum = tonumber(string.sub(arg1, 5,6))
		--	local TemplateName = string.sub(arg1, 8)
		--	local NameArray = CHAstrsplit(arg2,"#")
		--	HealingAsssignments.Syncframe:Receive(arg4,TemplateNum,TemplateName,NameArray)
		--elseif HealingAsssignments.Mainframe.SyncCheckbox:GetChecked() == 1 and arg1 == "CHTrigger" and arg2 == "trigger" then 
		--	HealingAsssignments.Syncframe:Send()
		--end
	
	elseif event == "GROUP_ROSTER_UPDATE" then
		--HealingAsssignments:SetNumberOfHealers()
		--HealingAsssignments:UpdateRaidDataBase()

	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		--local timestamp, type, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2 = CombatLogGetCurrentEventInfo()
		--if not (UnitInRaid(destName) or UnitInParty(destName)) then 
		--	return 
		--end
		--if type == "UNIT_DIED" and not AuraUtil.FindAuraByName("Feign Death", destName) then
		--	if HealingAsssignments.Mainframe.DeathWarningCheckbox:GetChecked() then
		--		HealingAsssignments:PostDeathWarning(destName) -- Name dies.
		--	end
		--end

	elseif event == "CHAT_MSG_WHISPER" then
		local arg1, arg2 = ...;
		local sender = DIGAM_GetPlayerName(arg2);

		--if arg1 == "!heal" or arg1 == "heal" then
		--	HealingAsssignments:AnswerAssignments(sender)
		--end
	end;
end

function CHA_OnTimer(elapsed)
end;

function CHA_HandleTXVersion(message, sender)
	local version = GetAddOnMetadata(CHA_ADDON_NAME, "Version")	
	C_ChatInfo.SendAddonMessage(CHA_MESSAGE_PREFIX, "RX_VERSION#"..version.."#"..sender, "RAID");
end;

function CHA_HandleRXVersion(message, sender)
	CHA_Echo(string.format("%s is using Classic Healing Assignments version %s", sender, message))
end;


function CHA_OnLoad()
	CHA_Expansionlevel = 1 * GetAddOnMetadata(CHA_ADDON_NAME, "X-Expansion-Level");
	CHA_CurrentVersion = CHA_CalculateVersion(GetAddOnMetadata(CHA_ADDON_NAME, "Version") );

	CHA_Echo(string.format("Version %s by %s", GetAddOnMetadata(CHA_ADDON_NAME, "Version"), GetAddOnMetadata(CHA_ADDON_NAME, "Author")));
	CHA_Echo(string.format("Type %s/cha%s to configure the addon.", COLOUR_INTRO, COLOUR_CHAT));

	CHAHeadlineCaption:SetText(string.format("Classic Healing Assignments - version %s", GetAddOnMetadata(CHA_ADDON_NAME, "Version")));
--	CHAVersionCaption:SetText(string.format("Classic Healing Assignments version %s by %s", GetAddOnMetadata(CHA_ADDON_NAME, "Version"), GetAddOnMetadata(CHA_ADDON_NAME, "Author")));

	CHA_PreInitialization();

	CHAEventFrame:RegisterEvent("ADDON_LOADED")
	--CHAEventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
	--CHAEventFrame:RegisterEvent("CHAT_MSG_WHISPER")
	--CHAEventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	--CHAEventFrame:RegisterEvent("CHAT_MSG_ADDON")

	C_ChatInfo.RegisterAddonMessagePrefix(CHA_MESSAGE_PREFIX);
end;

