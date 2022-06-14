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


local A = DigamAddonLib;
A.Initialize({
	["ADDONNAME"]		= "ClassicHealingAssignments",
	["SHORTNAME"]		= "CHA",
	["PREFIX"]			= "CHAv2",
	["NORMALCHATCOLOR"]	= "40A0F8",
	["HOTCHATCOLOR"]	= "B0F0F0",
});


local CHA_TEMPLATES_MAX						= 15;	-- room for max 15 templates. This is a limitation in the UI design.
local CHA_COLOR_SELECTED					= {1.0, 1.0, 1.0};
local CHA_COLOR_UNSELECTED					= {1.0, 0.8, 0.0};
local CHA_ALPHA_ENABLED						= 1.0;
local CHA_ALPHA_DIMMED						= 0.7;
local CHA_ALPHA_DISABLED					= 0.3;

local CHA_CLASS_DRUID						= 0x000001;
local CHA_CLASS_HUNTER						= 0x000002;
local CHA_CLASS_MAGE						= 0x000004;
local CHA_CLASS_PALADIN						= 0x000008;
local CHA_CLASS_PRIEST						= 0x000010;
local CHA_CLASS_ROGUE						= 0x000020;
local CHA_CLASS_SHAMAN						= 0x000040;
local CHA_CLASS_WARLOCK						= 0x000080;
local CHA_CLASS_WARRIOR						= 0x000100;
local CHA_CLASS_DEATHKNIGHT					= 0x000200;

local CHA_TARGET_RAIDICON					= 0x010000;		--	Bitmask for raid icons ({star},{skull} etc.)
local CHA_TARGET_DIRECTION					= 0x020000;		--	Bitmask for directions (left, right, north, east ...)
local CHA_TARGET_GROUP						= 0x040000;		--	Bitmask for groups (1-8)
local CHA_TARGET_CUSTOM						= 0x080000;		--	Bitmask for custom types (1-4)

local CHA_TARGET_PLAYERS					= 0x00ffff;		--	Bitmask for all player types (room for 16 classes, only 10 used so far)
local CHA_TARGET_SYMBOLS					= 0x0f0000;		--	Bitmask for all non-player types

--	{ "name"=<unique name>, "mask"=<mask>, "text"=<display name>, "icon"=<icon> }
--	Note: npc types are all encapsulated in"{...}" to ensure uniqueness amongst ordinary player names.
local CHA_TargetMatrix =  {
	{ 
		["name"] = "{Skull}",
		["mask"] = CHA_TARGET_RAIDICON,
		["text"] = "Skull",
		["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8"
	}, {
		["name"] = "{Cross}",
		["mask"] = CHA_TARGET_RAIDICON,
		["text"] = "Cross",
		["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7"
	}, {
		["name"] = "{Square}",
		["mask"] = CHA_TARGET_RAIDICON,
		["text"] = "Square",
		["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6"
	}, {
		["name"] = "{Moon}",
		["mask"] = CHA_TARGET_RAIDICON,
		["text"] = "Moon",
		["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_5"
	}, {
		["name"] = "{Triangle}",
		["mask"] = CHA_TARGET_RAIDICON,
		["text"] = "Triangle",
		["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4" 
	}, {
		["name"] = "{Diamond}",
		["mask"] = CHA_TARGET_RAIDICON,
		["text"] = "Diamond",		
		["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3"
	}, {
		["name"] = "{Circle}",
		["mask"] = CHA_TARGET_RAIDICON,
		["text"] = "Circle",
		["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2"
	}, {
		["name"] = "{Star}",
		["mask"] = CHA_TARGET_RAIDICON,
		["text"] = "Star",
		["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1"
	}, {
		["name"] = "{Left}",
		["mask"] = CHA_TARGET_DIRECTION,
		["text"] = "<== Left",
		["icon"] = "Interface\\Icons\\spell_chargenegative"
	}, {
		["name"] = "{Right}",
		["mask"] = CHA_TARGET_DIRECTION,
		["text"] = "Right ==>",
		["icon"] = "Interface\\Icons\\spell_chargepositive"
	}, {
		["name"] = "{North}",
		["mask"] = CHA_TARGET_DIRECTION,
		["text"] = "North",
		["icon"] = 132181
	}, {
		["name"] = "{East}",
		["mask"] = CHA_TARGET_DIRECTION,
		["text"] = "East",
		["icon"] = 132181
	}, {
		["name"] = "{South}",
		["mask"] = CHA_TARGET_DIRECTION,
		["text"] = "South",
		["icon"] = 132181
	}, {
		["name"] = "{West}",
		["mask"] = CHA_TARGET_DIRECTION,
		["text"] = "West",
		["icon"] = 132181
	}, {
		["name"] = "{Custom1}",
		["mask"] = CHA_TARGET_CUSTOM,
		["text"] = "(Custom 1)",
		["icon"] = 134466
	}, {
		["name"] = "{Custom2}",
		["mask"] = CHA_TARGET_CUSTOM,
		["text"] = "(Custom 2)",
		["icon"] = 134467
	}, {
		["name"] = "{Custom3}",
		["mask"] = CHA_TARGET_CUSTOM,
		["text"] = "(Custom 3)",
		["icon"] = 134468
	}, {
		["name"] = "{Custom4}",
		["mask"] = CHA_TARGET_CUSTOM,
		["text"] = "(Custom 4)",
		["icon"] = 134469
	}, {
		["name"] = "{Group1}",
		["mask"] = CHA_TARGET_GROUP,
		["text"] = "Group 1",
		["icon"] = "Interface\\AddOns\\ClassicHealingAssignments\\Media\\logo-square",
	}, {
		["name"] = "{Group2}",
		["mask"] = CHA_TARGET_GROUP,
		["text"] = "Group 2",
		["icon"] = "Interface\\AddOns\\ClassicHealingAssignments\\Media\\logo-square",
	}, {
		["name"] = "{Group3}",
		["mask"] = CHA_TARGET_GROUP,
		["text"] = "Group 3",
		["icon"] = "Interface\\AddOns\\ClassicHealingAssignments\\Media\\logo-square",
	}, {
		["name"] = "{Group4}",
		["mask"] = CHA_TARGET_GROUP,
		["text"] = "Group 4",
		["icon"] = "Interface\\AddOns\\ClassicHealingAssignments\\Media\\logo-square",
	}, {
		["name"] = "{Group5}",
		["mask"] = CHA_TARGET_GROUP,
		["text"] = "Group 5",
		["icon"] = "Interface\\AddOns\\ClassicHealingAssignments\\Media\\logo-square",
	}, {
		["name"] = "{Group6}",
		["mask"] = CHA_TARGET_GROUP,
		["text"] = "Group 6",
		["icon"] = "Interface\\AddOns\\ClassicHealingAssignments\\Media\\logo-square",
	}, {
		["name"] = "{Group7}",
		["mask"] = CHA_TARGET_GROUP,
		["text"] = "Group 7",
		["icon"] = "Interface\\AddOns\\ClassicHealingAssignments\\Media\\logo-square",
	}, {
		["name"] = "{Group8}",
		["mask"] = CHA_TARGET_GROUP,
		["text"] = "Group 8",
		["icon"] = "Interface\\AddOns\\ClassicHealingAssignments\\Media\\logo-square",
	},
};


local CHA_FRAME_MAXTARGET					= 8;
local CHA_FRAME_MAXPLAYERS					= 8;	-- Would like at least 10, but there isn't room in the ui :(
	
local CHA_ICON_NONE							= "Interface\\AddOns\\ClassicHealingAssignments\\Media\\logo-square";
local CHA_ICON_TANK							= 132341;		-- Defensive stance
local CHA_ICON_HEAL							= 135907;		-- Flash of Light
local CHA_ICON_DECURSE						= 132095;		-- remove Curse

local CHA_ROLE_NONE							= 0x00;
local CHA_ROLE_TANK							= 0x01;
local CHA_ROLE_HEAL							= 0x02;
local CHA_ROLE_DECURSE						= 0x04;

local CHA_RoleMatrix = {
	[CHA_ROLE_TANK]		= "tank",
	[CHA_ROLE_HEAL]		= "heal",
	[CHA_ROLE_DECURSE]	= "decurse"
};

local CHA_ROLE_DEFAULT_TANK					= CHA_CLASS_DRUID + CHA_CLASS_WARRIOR + CHA_CLASS_DEATHKNIGHT;
local CHA_ROLE_DEFAULT_HEAL					= CHA_CLASS_DRUID + CHA_CLASS_PALADIN + CHA_CLASS_PRIEST + CHA_CLASS_SHAMAN;
local CHA_ROLE_DEFAULT_DECURSE				= CHA_CLASS_DRUID + CHA_CLASS_MAGE;



--	Local variables:
local CHA_CurrentVersion					= 0;
local CHA_UpdateMessageShown				= false;
local CHA_IconMoving						= false;
local CHA_CurrentTemplateIndex				= 0;
local CHA_CurrentTemplateOperation			= "";
local CHA_CurrentTargetIndex				= 0;
local CHA_CurrentPlayerIndex				= 0;
local CHA_LocalPlayerName					= "";

--	Persisted options:
CHA_PersistedData							= { };

local CHA_KEY_ActiveTemplate				= "ActiveTemplate";
local CHA_KEY_ActiveRole					= "ActiveRole";
local CHA_KEY_AnnounceButtonPosX			= "AnnounceButton.X";
local CHA_KEY_AnnounceButtonPosY			= "AnnounceButton.Y";
local CHA_KEY_AnnounceButtonSize			= "AnnounceButton.Size";
local CHA_KEY_AnnounceButtonVisible			= "AnnounceButton.Visible";
local CHA_KEY_AnnouncementChannel			= "Announcement.Channel";
local CHA_KEY_Templates						= "Templates";

local CHA_DEFAULT_ActiveTemplate			= nil;
local CHA_DEFAULT_ActiveRole				= CHA_ROLE_TANK;
local CHA_DEFAULT_AnnounceButtonSize		= 32;
local CHA_DEFAULT_AnnounceButtonVisible		= true;

local CHA_ActiveTemplate					= CHA_DEFAULT_ActiveTemplate;
local CHA_ActiveRole						= CHA_DEFAULT_ActiveRole;
local CHA_AnnounceButtonSize				= CHA_DEFAULT_AnnounceButtonSize;
local CHA_AnnounceButtonVisible				= CHA_DEFAULT_AnnounceButtonVisible;
local CHA_AnnouncementChannel				= "";		-- Set runtime
local CHA_MinimapX							= 0;
local CHA_MinimapY							= 0;
local CHA_Templates							= { };
--[[
	Templates:
	The array containing the template setup is a huge table.
	We are reading data into a work table and then creating data in.the-fly to make
	sure data is consistent.

	CHA_Templates = {
		["templatename"] = "Molten Core",
		["roles"] = {
			["tank|heal|decurse"] = {
				["caption"] = "Tanks/Heals/Decurses",
				["mask"] = 769,
				["headline"] = "### Tank/Healer/Decurse assignments:",
				["contentline"] = "### {TARGET} <== {ASSIGNMENTS}",
				["bottomline"] = "### All other healers: Heal the raid.",
				["targets"] = 
				{
					{
						["name"] = "{Skull}",
						["mask"] = 65536,
						["text"] = "Skull",
						["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8",
						["players"] = 
						{
							{
								["name"] = "Donald-Firemaw",
								["text"] = "F:Donald",
								["mask"] = 256,
								["icon"] = 626008,
								["class"] = "WARRIOR",
							},
						},
					},
				},
			},
		},
	},
--]]

local CHA_WhisperHeal						= true;
local CHA_WhisperRepost						= true;

--	Backdrops:
CHA_BACKDROP_LOGO = {
	bgFile = "Interface\\AddOns\\ClassicHealingAssignments\\Media\\icon",
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
CHA_BACKDROP_TANK = {
	bgFile = "Interface\\TalentFrame\\WarriorProtection-Topleft",
	edgeSize = 0,
	tileEdge = true,
}
CHA_BACKDROP_HEALER = {
	bgFile = "Interface\\TalentFrame\\PriestHoly-Topleft",
	edgeSize = 0,
	tileEdge = true,
}
CHA_BACKDROP_DECURSE = {
	bgFile = "Interface\\TalentFrame\\DruidBalance-Topleft",
	edgeSize = 0,
	tileEdge = true,
}
CHA_BACKDROP_EDITBOX = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	tileEdge = true,
};

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
	info.text = "Remove target";
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
	info.text = "Remove player";
	info.func = CHA_AssignedDropdownMenu_Delete;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)
end);

--	Classes setup:
local CHA_ClassMatrix = { };
local CHA_CLASS_MATRIX_MASTER = {
	["DRUID"] = {
		["mask"] = CHA_CLASS_DRUID,
		["icon"] = 625999,
		["role"] = CHA_ROLE_TANK + CHA_ROLE_HEAL + CHA_ROLE_DECURSE,
		["color"] = { 255, 125, 10 },
	},
	["HUNTER"] = {
		["mask"] = CHA_CLASS_HUNTER,
		["icon"] = 626000,
		["role"] = CHA_ROLE_NONE,
		["color"] = { 171, 212, 115 },
	},
	["MAGE"] = {
		["mask"] = CHA_CLASS_MAGE,
		["icon"] = 626001,
		["role"] = CHA_ROLE_DECURSE,
		["color"] = { 105, 204, 240 },
	},
	["PALADIN"] = {
		["mask"] = CHA_CLASS_PALADIN,
		["icon"] = 626003,
		["alliance-expac"] = 1,
		["horde-expac"] = 2,
		["role"] = CHA_ROLE_NONE,	-- Paladin role is set during initialization since it depends on expac.
		["color"] = { 245, 140, 186 },
	},
	["PRIEST"] = {
		["mask"] = CHA_CLASS_PRIEST,
		["icon"] = 626004,
		["role"] = CHA_ROLE_HEAL,
		["color"] = { 255, 255, 255 },
	},
	["ROGUE"] = {
		["mask"] = CHA_CLASS_ROGUE,
		["icon"] = 626005,
		["role"] = CHA_ROLE_NONE,
		["color"] = { 255, 245, 105 },
	},
	["SHAMAN"] = {
		["mask"] = CHA_CLASS_SHAMAN,
		["icon"] = 626006,
		["alliance-expac"] = 2,
		["horde-expac"] = 1,
		["role"] = CHA_ROLE_HEAL,
		["color"] = { 0, 112, 221 },
	},
	["WARLOCK"] = {
		["mask"] = CHA_CLASS_WARLOCK,
		["icon"] = 626007,
		["role"] = CHA_ROLE_NONE,
		["color"] = { 148, 130, 201 },
	},
	["WARRIOR"] = {
		["mask"] = CHA_CLASS_WARRIOR,
		["icon"] = 626008,
		["role"] = CHA_ROLE_TANK,
		["color"] = { 199, 156, 110 },
	},
	["DEATHKNIGHT"] = {
		["mask"] = CHA_CLASS_DEATHKNIGHT,
		["icon"] = 135771,
		["alliance-expac"] = 3,
		["horde-expac"] = 3,
		["role"] = CHA_ROLE_TANK,
		["color"] = { 196, 30, 58 },
	},
};




--[[
	Slash commands
--]]

--	Main entry for CHA "slash" commands.
--	This will send the request to one of the sub slash commands.
--	Syntax: /cha [option, defaulting to "cfg"]
--	Added in: 2.0.0
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
		A.Echo(string.format("Unknown command: %s", option));
	end
end

--	Show the configuration dialogue
--	Syntax: /chaconfig, /chacfg
--	Alternative: /cha config, /cha cfg
--	Added in: 2.0.0
SLASH_CHA_CONFIG1 = "/chaconfig"
SLASH_CHA_CONFIG2 = "/chacfg"
SlashCmdList["CHA_CONFIG"] = function(msg)
	CHA_OpenConfigurationDialogue();
end

--	Request client version information
--	Syntax: /chaversion
--	Alternative: /cha version
--	Added in: 2.0.0
SLASH_CHA_VERSION1 = "/chaversion"
SlashCmdList["CHA_VERSION"] = function(msg)
	if IsInRaid() or A.IsInParty() then
		A.SendAddonMessage("TX_VERSION##");
	else
		A.Echo(string.format("%s is using ClassicHealingAssignments version %s", GetUnitName("player", true), GetAddOnMetadata(CHA_ADDON_NAME, "Version")));
	end
end

--	Show HELP options
--	Syntax: /chahelp
--	Alternative: /cha help
--	Added in: 2.0.0
--
SLASH_CHA_HELP1 = "/chahelp"
SlashCmdList["CHA_HELP"] = function(msg)
	A.Echo(string.format("ClassicHealingAssignments version %s options:", GetAddOnMetadata(CHA_ADDON_NAME, "Version")));
	A.Echo("Syntax:");
	A.Echo("    /cha [command]");
	A.Echo("Where commands can be:");
	A.Echo("    Config       (default) Open the configuration dialogue.");
	A.Echo("    Version      Request version info from all clients.");
	A.Echo("    Help         This help.");
end




--[[
	Helper functions
--]]

--	Check if there is a newer version available in the raid.
local function CHA_CheckIsNewVersion(versionstring)
	local incomingVersion = A.CalculateVersion( versionstring );

	if (CHA_CurrentVersion > 0 and incomingVersion > 0) then
		if incomingVersion > CHA_CurrentVersion then
			if not CHA_UpdateMessageShown then
				CHA_UpdateMessageShown = true;
				A.Echo(string.format("NOTE: A newer version of ".. COLOUR_INTRO .."ClassicHealingAssignments"..COLOUR_CHAT.."! is available (version %s)!", versionstring));
				A.Echo("You can download latest version from https://www.curseforge.com/ or https://github.com/Sentilix/ClassicHealingAssignments.");
			end
		end	
	end
end



--[[
	Initialization functions
--]]

--	Pre-initialization:
--	Performed before WOW have finished initalizing
local function CHA_PreInitialization()
	CHA_Templates = { };
	CHA_LocalPlayerName = A.GetPlayerAndRealm("player");

	CHA_InitializeClassMatrix();
	CHA_InitializeUI();
end;

--	Post-initialization:
--	Performaned when the OnLoad event is fired.
local function CHA_PostInitialization()
	CHA_ReadConfigurationSettings();
	CHA_UpdateUI();
end;

--	Read all configuration options, and fill in with defaults if not present.
--	Therefore value is written back immediately:
function CHA_ReadConfigurationSettings()
	--	Current active role:
	CHA_ActiveRole = CHA_GetOption(CHA_KEY_ActiveRole, CHA_DEFAULT_ActiveRole);
	CHA_SetOption(CHA_KEY_ActiveRole, CHA_ActiveRole);

	--	Templates: These are processed in the Template code:
	CHA_ProcessConfiguredTemplateData(CHA_GetOption(CHA_KEY_Templates, nil));
	CHA_SetOption(CHA_KEY_Templates, CHA_Templates);

	--	Current active template:
	CHA_ActiveTemplate = CHA_GetOption(CHA_KEY_ActiveTemplate, CHA_DEFAULT_ActiveTemplate);
	if not CHA_ActiveTemplate or not CHA_GetActiveTemplate() then
		--	No active template found. Select first available:
		if table.getn(CHA_Templates) > 0 then
			CHA_ActiveTemplate = CHA_Templates[1]["templatename"];
		else
			CHA_ActiveTemplate = CHA_DEFAULT_ActiveTemplate;
		end;
	end;
	CHA_SetOption(CHA_KEY_ActiveTemplate, CHA_ActiveTemplate);

	--	Announcement channel:
	CHA_ProcessConfiguredAnnouncementChannel(CHA_GetOption(CHA_KEY_AnnouncementChannel, 0));
	CHA_SetOption(CHA_KEY_AnnouncementChannel, CHA_AnnouncementChannel);
	

end;

--	Get a configuration option by KEY, returns defaultValue if not found.
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

--	Set a configuration KEY to a value.
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

--	Initialize the Class Matrix:
--	This generates a list of valid classes per active expac.
function CHA_InitializeClassMatrix()
	CHA_ClassMatrix = { };

	local factionEN = UnitFactionGroup("player");
	local expacKey = "alliance-expac";
	if factionEN == "Horde" then
		expacKey = "horde-expac";
	end;

	local paladinRole = CHA_ROLE_TANK + CHA_ROLE_HEAL;
	if A.Properties.ExpansionLevel == 1 then
		--	Sorry, paladins cannot tank in Classic!
		paladinRole = CHA_ROLE_HEAL;
	end;

	for className, classInfo in next, CHA_CLASS_MATRIX_MASTER do
		if not classInfo[expacKey] or classInfo[expacKey] <= A.Properties.ExpansionLevel then
			if className == "PALADIN" then
				classInfo["role"] = paladinRole;
			end;
			CHA_ClassMatrix[className] = classInfo;
		end;
	end;
end;

--	initialize profile names.
function CHA_CreateDefaultTemplates()
	CHA_Templates = { };

	CHA_CreateTemplate("Default");

	if A.Properties.ExpansionLevel == 1 then
		CHA_CreateTemplate("Molten Core");
		CHA_CreateTemplate("Onyxia's Lair");
		CHA_CreateTemplate("Blackwing Lair");
		CHA_CreateTemplate("Temple of Ahn'Qiraj");
		CHA_CreateTemplate("Naxxramas");
		CHA_CreateTemplate("20 man");
	end;

	if A.Properties.ExpansionLevel == 2 then
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



--[[
	UI Functions
--]]

--	Main UI update functionality
function CHA_UpdateUI()
	CHA_UpdateAnnounceButton();
	CHA_UpdateClassIcons();
	CHA_UpdateRoleButtons();
	CHA_UpdateTemplates();
	CHA_UpdateTargetFrames();
	CHA_UpdateAnnouncementTexts();
end;

--	Open the configuration dialogue.
function CHA_OpenConfigurationDialogue()
	CHA_UpdateUI();
	CHAMainFrame:Show();
end;

--	Close the configuration dialogue.
function CHA_CloseConfigurationDialogue()
	CHA_CloseTextConfigDialogue();
	CHA_ForceClosePopups();
	CHAMainFrame:Hide();
	CHA_SetOption(CHA_KEY_Templates, CHA_Templates);

	CHA_UpdateRoleButtons();
end;

--	Close all popups. Used to avoid open popups with data for
--	a window which was later changed.
function CHA_ForceClosePopups()
	StaticPopup_Hide("CHA_DIALOG_ADDTEMPLATE");
	StaticPopup_Hide("CHA_DIALOG_RENAMETARGET");
	StaticPopup_Hide("DIGAM_DIALOG_CONFIRMATION");
	StaticPopup_Hide("DIGAM_DIALOG_ERROR");

	HideDropDownMenu(1, nil, CHA_TemplateDropdownMenu, "cursor", 3, -3);
	HideDropDownMenu(1, nil, CHA_TemplateDropdownMenu, "cursor", 3, -3);
	HideDropDownMenu(1, nil, CHA_SymbolTargetDropdownMenu, "cursor", 3, -3);
	HideDropDownMenu(1, nil, CHA_PlayerDropdownMenu, "cursor", 3, -3);
	HideDropDownMenu(1, nil, CHA_AssignedDropdownMenu, "cursor", 3, -3);
end;

function CHA_OpenTextConfigDialogue()
	CHA_UpdateAnnouncementTexts();
	CHA_ForceClosePopups();
	CHATextFrame:Show();
end;

function CHA_CloseTextConfigDialogue()
	CHATextFrame:Hide();

	local roleTemplate = CHA_GetActiveRoleTemplate();
	if roleTemplate then
		roleTemplate["headline"] = CHATextFrameHeadline:GetText();
		roleTemplate["contentline"] = CHATextFrameContentLine:GetText();
		roleTemplate["bottomline"] = CHATextFrameBottomLine:GetText();
	end;

end;

--	Change to Tank configuration page
function CHA_ShowTankConfiguration()
	CHA_ForceClosePopups();
	CHA_ActiveRole = CHA_ROLE_TANK;
	CHA_SetOption(CHA_KEY_ActiveRole, CHA_ActiveRole);
	CHA_UpdateUI();
end;

--	Change to Healer configuration page
function CHA_ShowHealerConfiguration()
	CHA_ForceClosePopups();
	CHA_ActiveRole = CHA_ROLE_HEAL;
	CHA_SetOption(CHA_KEY_ActiveRole, CHA_ActiveRole);
	CHA_UpdateUI();
end;

--	Change to Decurser configuration page
function CHA_ShowDecurseConfiguration()
	CHA_ForceClosePopups();
	CHA_ActiveRole = CHA_ROLE_DECURSE;
	CHA_SetOption(CHA_KEY_ActiveRole, CHA_ActiveRole);
	CHA_UpdateUI();
end;

--	Update the announce button, main entry
function CHA_UpdateAnnounceButton()
	CHA_UpdateRoleButtons();
	CHA_RepositionateButton();
end;

--	Update the three role buttons, so the current role is disabled.
--	Also, the backdrop on the template frame is changed.
function CHA_UpdateRoleButtons()
 	CHA_UpdateRoleCounter();

	local announceButtonIcon = CHA_ICON_NONE;
	local announceButtonActive = false;
	local targetCount = table.getn(CHA_GetActiveTargetTemplate() or {});

	if CHA_ActiveRole == CHA_ROLE_TANK then
		CHAMainFrameTankButton:Disable();
		CHAMainFrameHealButton:Enable();
		CHAMainFrameDecurseButton:Enable();
		CHAMainFrameTemplates:SetBackdrop(CHA_BACKDROP_TANK);

		if targetCount > 0 then
			announceButtonIcon = CHA_ICON_TANK;
		end;			
	elseif CHA_ActiveRole == CHA_ROLE_HEAL then
		CHAMainFrameTankButton:Enable();
		CHAMainFrameHealButton:Disable();
		CHAMainFrameDecurseButton:Enable();
		CHAMainFrameTemplates:SetBackdrop(CHA_BACKDROP_HEALER);

		if targetCount > 0 then
			announceButtonIcon = CHA_ICON_HEAL;
		end;
	elseif CHA_ActiveRole == CHA_ROLE_DECURSE then
		CHAMainFrameTankButton:Enable();
		CHAMainFrameHealButton:Enable();
		CHAMainFrameDecurseButton:Disable();
		CHAMainFrameTemplates:SetBackdrop(CHA_BACKDROP_DECURSE);

		if targetCount > 0 then
			announceButtonIcon = CHA_ICON_DECURSE;
		end;
	end;

	CHAAnnounceButton:SetNormalTexture(announceButtonIcon);
	if targetCount > 0 then
		CHAAnnounceButton:SetAlpha(CHA_ALPHA_ENABLED);
	else
		CHAAnnounceButton:SetAlpha(CHA_ALPHA_DIMMED);
	end;
end;

--	Called when button is repositionated, and persist the new set of coords.
function CHA_RepositionateButton(self)
	local x, y = CHAAnnounceButton:GetLeft(), CHAAnnounceButton:GetTop() - UIParent:GetHeight();

	CHA_SetOption(CHA_KEY_AnnounceButtonPosX, x);
	CHA_SetOption(CHA_KEY_AnnounceButtonPosY, y);
	CHAAnnounceButton:SetSize(CHA_AnnounceButtonSize, CHA_AnnounceButtonSize);

	if CHA_AnnounceButtonVisible then
		CHAAnnounceButton:Show();
	else
		CHAAnnounceButton:Hide();
	end;
end

--	Update TARGET icons, captions etc for the selected Frame.
function CHA_UpdateTargetFrames()
	local roleTemplate = CHA_GetActiveRoleTemplate();

	local roleTargets = { };
	if roleTemplate then
		roleTargets = roleTemplate["targets"];
	end;

	local playerMask = roleTargets["mask"];

	for index = 1, CHA_FRAME_MAXTARGET, 1 do
		local fTarget = _G[string.format("targetframe_%d", index)];
		local fTargetIcon = _G[string.format("targeticon_%d", index)];
		local fTargetCaption = _G[string.format("targetcaption_%d", index)];
		local fTargetButton = _G[string.format("targetbutton_%d", index)];

		local target = roleTargets[index];
		if target then
			fTargetIcon:SetNormalTexture(target["icon"]);
			fTargetIcon:SetPushedTexture(target["icon"]);
			fTargetCaption:SetText(CHA_FormatPlayerName(target["text"]));


			--	PLAYER FRAME: Each frame can have up to CHA_FRAME_MAXPLAYERS tanks assigned.
			--	Same player frames are used by both Tanks, Healers and Decursers
			local roleTarget = roleTemplate["targets"][index];
			local alpha = CHA_ALPHA_ENABLED;
			local posX = playerOffset;
			local posY = 0;
			for playerIndex = 1, CHA_FRAME_MAXPLAYERS, 1 do
				local player = roleTarget["players"] and roleTarget["players"][playerIndex];
				if player then
					local color = CHA_ClassMatrix[player["class"]]["color"];
					local fPlayerButtonName = string.format("playerbutton_%d_%d", index, playerIndex);
					local fPlayerButton = _G[fPlayerButtonName];
					_G[fPlayerButtonName.."Caption"]:SetText(CHA_FormatPlayerName(player["text"]));
					_G[fPlayerButtonName.."BG"]:SetVertexColor( color[1]/255, color[2]/255, color[3]/255 );

					local unitid = A.GetUnitidFromName(player["name"]);
					if unitid and UnitIsConnected(unitid) then
						alpha = CHA_ALPHA_ENABLED;
					else
						alpha = CHA_ALPHA_DISABLED;
					end;
					fPlayerButton:SetAlpha(alpha);
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

--	Update class icons based on the current template + role:
function CHA_UpdateClassIcons()
	local roleTemplate = CHA_GetActiveRoleTemplate();

	local templateMask = CHA_ROLE_NONE;
	if roleTemplate then
		templateMask = roleTemplate["mask"];
	end;

	for className, classInfo in next, CHA_ClassMatrix do
		local buttonName = string.format("classicon_%s", className);

		if bit.band(templateMask, classInfo["mask"]) > 0 then
			_G[buttonName]:SetAlpha(CHA_ALPHA_ENABLED);
		else
			_G[buttonName]:SetAlpha(CHA_ALPHA_DISABLED);
		end;
	end;

	local roleName = "(none)";
	if roleTemplate then 
		roleName = roleTemplate["caption"]; 
	end;
	CHARoleCaption:SetText(roleName);
end;

--	Update Template buttons:
function CHA_UpdateTemplates()
	local frame = CHAMainFrameTemplates;

	local lineHeight = 20;
	local offsetX = 25;
	local offsetY = -108;
	local buttonX = offsetX;
	local buttonY = offsetY;

	local templateCount = table.getn(CHA_Templates);
	local buttonName, textColor;

	for templateIndex = 1, CHA_TEMPLATES_MAX, 1 do
		local button = _G[string.format("template_%d", templateIndex)];
		local caption = _G[string.format("template_%dText", templateIndex)];

		if templateIndex <= templateCount then
			if CHA_Templates[templateIndex]["templatename"] == CHA_ActiveTemplate then
				textColor = CHA_COLOR_SELECTED;
			else
				textColor = CHA_COLOR_UNSELECTED;
			end;
			
			caption:SetTextColor(textColor[1], textColor[2], textColor[3]);
			caption:SetText(CHA_Templates[templateIndex]["templatename"]);
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

function CHA_UpdateAnnouncementTexts()
	local headline = "";
	local content = "";
	local bottom = "";

	local roleTemplate = CHA_GetActiveRoleTemplate();
	if roleTemplate then
		headline = roleTemplate["headline"] or "";
		content = roleTemplate["contentline"] or "";
		bottom = roleTemplate["bottomline"] or "";
	end;

	CHATextFrameHeadline:SetText(headline);
	CHATextFrameContentLine:SetText(content);
	CHATextFrameBottomLine:SetText(bottom);
end;



--[[
	UI events
--]]

--	Called when a ClassIcon (bottom icons on tank/healer/decurse screen) is clicked.
--	This should toggle the status of the clicked class, so a click on an icon
--	will assign/unassign the class to the current active role.
function CHA_ClassIconOnClick(sender)
	local buttonName = sender:GetName();
	local _, _, className, _ = string.find(buttonName, "classicon_(%S*)");

	local roleTemplate = CHA_GetActiveRoleTemplate();
	if not roleTemplate then return; end;

	local classInfo = CHA_ClassMatrix[className];
	if not classInfo then return; end;

	roleTemplate["mask"] = bit.bxor(roleTemplate["mask"], classInfo["mask"]);

	CHA_UpdateClassIcons();
	CHA_UpdateRoleCounter();
end;

--	Called when "Add Target" button on role page is clicked.
--	A popup with available targets must be shown/hidden.
function CHA_AddSymbolTargetOnClick()
	ToggleDropDownMenu(1, nil, CHA_SymbolTargetDropdownMenu, "cursor", 3, -3);
end;

--	Called when a target was selected in the TargetSymbol dropdown.
--	A new target must be added to the list of existing targets.
function CHA_SymbolTargetDropdownClick(self, target)
	CHA_CreateTarget(target);
end;

--	Called when a Template in the TemplateFrame is clicked.
--	Left-click: Switch to the selected template
--	Right-click: Open popup with template options.
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
				CHA_ActiveTemplate = template["templatename"];
				CHA_SetOption(CHA_KEY_ActiveTemplate, CHA_ActiveTemplate);
			end;
			CHA_UpdateUI();
		end;
	end;
end;

--	Called when the Template:MoveUp is selected.
--	Template is switching position with the previous template.
function CHA_TemplateDropdownMenu_MoveUp()
	if CHA_CurrentTemplateIndex > 1 then
		CHA_SwapTemplates(CHA_CurrentTemplateIndex - 1);
		CHA_UpdateUI();
	end;
end;

--	Called when the Template:MoveDown is selected.
--	Template is switching position with the next template.
function CHA_TemplateDropdownMenu_MoveDown(...)
	if CHA_CurrentTemplateIndex < table.getn(CHA_Templates) then
		CHA_SwapTemplates(CHA_CurrentTemplateIndex);
		CHA_UpdateUI();
	end;
end;

--	Called when the Template:Clone is selected.
--	A popup is shown, letting the user enter a name for the new template.
--	CHA_CurrentTemplateOperation is set so we know what to do when popup close.
function CHA_TemplateDropdownMenu_Clone()
	local template = CHA_GetTemplateById(CHA_CurrentTemplateIndex);
	CHA_CurrentTemplateOperation = "CLONE";

	StaticPopup_Show("CHA_DIALOG_ADDTEMPLATE", template["templatename"]);
end;

--	Called when the Template:Rename is selected.
--	A popup is shown, letting the user enter a new name for the template.
--	CHA_CurrentTemplateOperation is set so we know what to do when popup close.
function CHA_TemplateDropdownMenu_Rename()
	local template = CHA_GetTemplateById(CHA_CurrentTemplateIndex);
	CHA_CurrentTemplateOperation = "RENAME";

	StaticPopup_Show("CHA_DIALOG_ADDTEMPLATE", template["templatename"]);
end;

--	Called when the Template:Delete is selected.
--	A popup is shown, asking if user really wants to do this!
function CHA_TemplateDropdownMenu_Delete()
	local template = CHA_GetTemplateById(CHA_CurrentTemplateIndex);

	A.ShowConfirmation(string.format("Really delete the template '%s'?", template["templatename"]), CHA_TemplateDropdownMenu_Delete_OK);
end;

--	Called when the OK button on the Template:Delete popup was clicked.
--	Template is deleted, and if it was the active template, the active template is reset.
function CHA_TemplateDropdownMenu_Delete_OK()
	local template = CHA_GetTemplateById(CHA_CurrentTemplateIndex);
	local templateName = template["templatename"];
	if CHA_ActiveTemplate == templateName then
		CHA_ActiveTemplate = nil;
		CHA_SetOption(CHA_KEY_ActiveTemplate, CHA_ActiveTemplate);
	end;

	CHA_Templates[CHA_CurrentTemplateIndex] = nil;
	CHA_Templates = A.RenumberTable(CHA_Templates);

	CHA_UpdateUI();
end;

--	Called when "Add Template" is clicked.
--	Popup is shown, asking for a name for the template.
function CHA_AddTemplateOnClick()
	StaticPopup_Show("CHA_DIALOG_ADDTEMPLATE");
end;

--	Called when the main "announcement" button is clicked.
--	CTRL+left click: A public announcement is made.
--	CTRL+right click: A private (locally) announcement is made for testing.
--	Left/right-click: config dialogue is opened.
function CHA_AnnouncementButtonOnClick(sender)
	local buttonType = GetMouseButtonClicked();

	--	CTRL key: announce something
	if IsControlKeyDown() then
		if buttonType == "LeftButton" then
			CHA_PublicAnnouncement();
		else
			CHA_PrivateAnnouncement();
		end;
	else
		CHA_OpenConfigurationDialogue();
	end;

end;

--	Called when the Target button is clicked.
--	A popup menu lets the user select target options.
function CHA_TargetButtonOnClick(sender)
	local buttonName = sender:GetName();
	local _, _, index, _ = string.find(buttonName, "targetbutton_(%d*)");

	CHA_CurrentPlayerIndex = 1 * index;
	ToggleDropDownMenu(1, nil, CHA_PlayerDropdownMenu, "cursor", 3, -3);
end;

--	Called when an assigned Player is clicked.
--	A popup menu lets the user select player options.
function CHA_PlayerButtonOnClick(sender)
	local buttonName = sender:GetName();
	local _, _, targetIndex, playerIndex = string.find(buttonName, "playerbutton_(%d*)_(%d*)");

	CHA_CurrentTargetIndex = 1 * targetIndex;
	CHA_CurrentPlayerIndex = 1 * playerIndex;
	ToggleDropDownMenu(1, nil, CHA_AssignedDropdownMenu, "cursor", 3, -3);
end;

--	Called when the Player dropdown is selected.
--	We need to add this player to the list for that specific target.
function CHA_PlayerDropdownClick(sender, playerInfo)
	--	Assign this player to the current ROLE:
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if not roleTemplate then return; end;

	--	CHA_CurrentTargetIndex sounds more correct here, but its the PlayerIndex being set. Weird.
	local roleTarget = roleTemplate["targets"][CHA_CurrentPlayerIndex];
	if not roleTarget then
		--	This is unset if no target is made (this can't really happen I guess)
		roleTarget = { };
	end;

	if not roleTarget["players"] then
		--	This is unset if Player is the first assigned. (This can happen!)
		roleTarget["players"] = { };
	end;
	
	tinsert(roleTarget["players"], playerInfo);

	CHA_UpdateTargetFrames();
	CHA_UpdateRoleCounter();
end;

--	Called when Assigned Player:MoveUp is clicked:
--	Player is moved "up" to the previous target.
function CHA_AssignedDropdownMenu_MoveUp()
	if CHA_CurrentTargetIndex > 1 then
		CHA_MoveAssignedPlayer(CHA_CurrentPlayerIndex, CHA_CurrentTargetIndex, CHA_CurrentTargetIndex - 1);
		CHA_UpdateTargetFrames();
	end;
end;

--	Called when Assigned Player:MoveDown is clicked:
--	Player is moved "down" to the next target.
function CHA_AssignedDropdownMenu_MoveDown()
	local roleTarget = CHA_GetActiveTargetTemplate();
	if not roleTarget then return; end;

	if CHA_CurrentTargetIndex < table.getn(roleTarget) then
		CHA_MoveAssignedPlayer(CHA_CurrentPlayerIndex, CHA_CurrentTargetIndex, CHA_CurrentTargetIndex + 1);
		CHA_UpdateTargetFrames();
	end;
end;

--	Called when Assigned Player:Delete is clicked:
--	Player is deleted(removed).
--	This does NOT trigger a popup, thats intentional to keep # of popups a little down!
function CHA_AssignedDropdownMenu_Delete()
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if not roleTemplate then return; end;

	local roleTarget = roleTemplate["targets"][CHA_CurrentTargetIndex];
	if not roleTarget or not roleTarget["players"] then return; end;

	if roleTarget["players"][CHA_CurrentPlayerIndex] then
		roleTarget["players"][CHA_CurrentPlayerIndex] = nil;
		roleTarget["players"] = A.RenumberTable(roleTarget["players"]);
	end;

	CHA_UpdateTargetFrames();
	CHA_UpdateRoleCounter();
end;

--	Called when Target:MoveUp dropdown option is seleted:
--	Exchange position with previous target.
function CHA_TargetDropdownMenu_MoveUp()
	if CHA_CurrentTargetIndex > 1 then
		CHA_SwapTargets(CHA_CurrentTargetIndex - 1, CHA_CurrentTargetIndex);
		CHA_UpdateTargetFrames();
	end;
end;

--	Called when Target:MoveDown dropdown option is seleted:
--	Exchange position with next target.
function CHA_TargetDropdownMenu_MoveDown()
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if roleTemplate then
		if CHA_CurrentTargetIndex < table.getn(roleTemplate["targets"]) then
			CHA_SwapTargets(CHA_CurrentTargetIndex, CHA_CurrentTargetIndex + 1);
			CHA_UpdateTargetFrames();
		end;
	end;
end;

--	Called when Target:Rename dropdown option is seleted:
--	Shop popup with name editbox.
function CHA_TargetDropdownMenu_Rename()
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if roleTemplate and roleTemplate["targets"][CHA_CurrentTargetIndex] then
		local targetName = roleTemplate["targets"][CHA_CurrentTargetIndex]["text"];
		StaticPopup_Show("CHA_DIALOG_RENAMETARGET", targetName);
	end;
end;

--	Called when Target:Rename edit dialog closes successfully.
--	Do the name change.
--	Note: we only change the "text" property; the internal name remains untouched.
function CHA_RenameTarget_OK(oldTargetName, newTargetName)
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if roleTemplate and roleTemplate["targets"][CHA_CurrentTargetIndex] then
		roleTemplate["targets"][CHA_CurrentTargetIndex]["text"] = newTargetName;
		CHA_UpdateTargetFrames();
	end;
end;

--	Called when Target:Delete dropdown option is seleted:
--	Shop popup for confirmation.
function CHA_TargetDropdownMenu_Delete()
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if roleTemplate and roleTemplate["targets"][CHA_CurrentTargetIndex] then
		local targetName = roleTemplate["targets"][CHA_CurrentTargetIndex]["text"];

		A.ShowConfirmation(string.format("Really remove the target '%s'?", targetName or ""), CHA_TargetDropdownMenu_Delete_OK);
	end;
end;

--	Called when Target:Delete dropdown option closes with OK:
--	Delete the target.
function CHA_TargetDropdownMenu_Delete_OK()
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if roleTemplate and roleTemplate["targets"][CHA_CurrentTargetIndex] then
		roleTemplate["targets"][CHA_CurrentTargetIndex] = nil;
		roleTemplate["targets"] = A.RenumberTable(roleTemplate["targets"]);

		CHA_UpdateTargetFrames();
		CHA_UpdateRoleCounter();
	end;
end;

--	Called when a Target is clicked.
--	Left-click: ... unsure what to do really! Show right-click popup for now.
--	Right-click: Open options popup
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

--	Called when user clicks the CLEAN UP button:
function CHA_KickDisconnectsOnClick()
	A.ShowConfirmation("Do you want to kick all disconnected characters and characters not in the raid?", CHA_KickDisconnects_OK);
end;

--	Cleanup the assignments by removing all characters not in the raid or disconnected characters.
function CHA_KickDisconnects_OK()
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if not roleTemplate or not roleTemplate["targets"] then return; end;

	--	Iterate over all targets, then players in each target:
	local unitid;
	for targetIndex, target in next, roleTemplate["targets"] do
		if target["players"] then
			for playerIndex, player in next, target["players"] do
				unitid = A.GetUnitidFromName(player["name"]);
		
				if not unitid or not UnitIsConnected(unitid) then
					target["players"][playerIndex] = nil;
					target["players"] = A.RenumberTable(target["players"]);
				end;
			end;
		end;

		if bit.band(target["mask"], CHA_TARGET_PLAYERS) > 0 then
			--	This is a player: kick unless online and in raid!
			unitid = A.GetUnitidFromName(target["name"]);
		
			if not unitid or not UnitIsConnected(unitid) then
				roleTemplate["targets"][targetIndex] = nil;
				roleTemplate["targets"] = A.RenumberTable(roleTemplate["targets"]);
			end;
		end;
	end;

	CHA_UpdateUI();
end;

--	Called when user clicks the ChangeText button:
--	The text configuration window opens.
function CHA_ChangeTextsOnClick()
	CHA_OpenTextConfigDialogue();
end;



--[[
	Template functions
--]]

--	Swap template with the next template in the list.
--	The entire template (including contents such as tanks, healers etc) is swapped.
function CHA_SwapTemplates(firstIndex)
	local templateA = CHA_Templates[firstIndex];
	CHA_Templates[firstIndex] = CHA_Templates[firstIndex + 1];
	CHA_Templates[firstIndex + 1] = templateA;
end;

--	Called when "Add Template" popup is closed with OK.
--	A new template is created and added to the list.
function CHA_AddTemplate_OK(templateName)
	if not CHA_GetTemplateByName(templateName) then
		CHA_CreateTemplate(templateName);
	else
		A.ShowError("A template with that name already exists.");
	end;

	CHA_UpdateUI();
end;

--	Called when Template:Rename or Template:Clone popup is closed with OK.
--	Rename: The selected template is renamed.
--	Clone: A new template with the new name is added below the old template.
function CHA_RenameTemplate_OK(oldTemplateName, newTemplateName)
	if CHA_GetTemplateByName(newTemplateName) then
		A.ShowError("A template with that name already exists.");
		return;
	end;

	local index, template = CHA_GetTemplateByName(oldTemplateName);
	if not index then
		A.ShowError(string.format("The template '%s' was not found.", oldTemplateName));
		return;
	end;

	if CHA_CurrentTemplateOperation == "RENAME" then
		--	Rename existing template:
		CHA_Templates[index]["templatename"] = newTemplateName;

		if CHA_ActiveTemplate == oldTemplateName then
			CHA_ActiveTemplate = newTemplateName;
			CHA_SetOption(CHA_KEY_ActiveTemplate, CHA_ActiveTemplate);
		end;
	elseif CHA_CurrentTemplateOperation == "CLONE" then
		--	Clone template to new (keep existing)
		local newIndex = CHA_CreateTemplate(newTemplateName);

		local template = A.CloneTable(CHA_Templates[index]);
		template["templatename"] = newTemplateName;
		CHA_Templates[newIndex] = template;

		--	Move copy up below original table:
		for n = newIndex-1, index+1, -1 do
			CHA_SwapTemplates(n);
		end;
	end;

	CHA_UpdateUI();
end;



--[[
	Target functions
--]]

--	Initialize the Symbol Target dropdown menu.
function CHA_SymbolTargetDropdown_Initialize(frame, level, menuList)
	local targetMask = 0;
 
	if CHA_ActiveRole == CHA_ROLE_TANK then
		--	Healers: Directions, Raid Icons, Custom targets:
		targetMask = targetMask + CHA_TARGET_DIRECTION + CHA_TARGET_RAIDICON + CHA_TARGET_CUSTOM;	
	else
		--	For healer, decursers: Add tank targets:
		local template = CHA_GetActiveTemplate();
		if template then
			targetMask = bit.bor(targetMask, template["roles"]["tank"]["mask"]);
		end;		
	end;
	
	if CHA_ActiveRole == CHA_ROLE_HEAL then
		--	Healers: Directions, Raid Icons, Custom targets:
		targetMask = bit.bor(targetMask, CHA_TARGET_DIRECTION + CHA_TARGET_RAIDICON + CHA_TARGET_CUSTOM);
	elseif CHA_ActiveRole == CHA_ROLE_DECURSE then
		--	Decursers: Groups, Custom targets:
		targetMask = bit.bor(targetMask, CHA_TARGET_GROUP + CHA_TARGET_CUSTOM);
	end;

	local targets = CHA_GetTargetsByMask(targetMask);

	for targetIndex = 1, table.getn(targets), 1 do
		local info = UIDropDownMenu_CreateInfo();
		info.notCheckable = true;
		info.text       = targets[targetIndex]["text"];
		info.icon		= targets[targetIndex]["icon"];
		info.func       = function() CHA_SymbolTargetDropdownClick(this, targets[targetIndex]) end;
		UIDropDownMenu_AddButton(info);
	end
end;

--	Create a new Target and add to the bottom of the list of current targets.
function CHA_CreateTarget(target)
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if not roleTemplate then return; end;

	tinsert(roleTemplate["targets"], target);

	CHA_UpdateTargetFrames();
end;

--	Get current targetMask.
--	TODO: This doesnt look correct: is Decursers handled as they should here?
function CHA_GetTargetMask()
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if not roleTemplate then return; end;

	--	Find TARGET which tanks/healers/decursers will be assigned to.
	local targetMask = CHA_TARGET_DIRECTION + CHA_TARGET_RAIDICON + CHA_TARGET_CUSTOM;

	--	Add all classes configured for the active template+role:
	targetMask = bit.bor(targetMask, roleTemplate["mask"]);

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
			if bit.band(mask, player["mask"]) > 0 then
				if includeUsedPlayers or not CHA_IsPlayerUsedInTemplates(player["name"], true) then
					--tinsert(targets, { player["name"], player["mask"], player["icon"], player["text"], player["class"] } );
					tinsert(targets, player);
				end;
			end;
		end;
	end;

	if bit.band(mask, CHA_TARGET_SYMBOLS) > 0 then
		--	Add SYMBOLS:
		for targetIndex = 1, table.getn(CHA_TargetMatrix), 1 do
			if includeUsedTargets or not CHA_IsTargetInUse(CHA_TargetMatrix[targetIndex]["name"], CHA_ActiveRole) then
				if bit.band(mask, CHA_TargetMatrix[targetIndex]["mask"]) > 0 then
					tinsert(targets, CHA_TargetMatrix[targetIndex]);
				end;
			end;
		end;
	end;

	return targets;
end;

--	Check if the current target is in use for any of the other roles
function CHA_IsTargetInUse(targetName, targetRole)
	local template = CHA_GetActiveTemplate();

	if template then
		if bit.band(targetRole, CHA_ROLE_TANK) > 0 then
			for k, target in next, template["roles"]["tank"]["targets"] do
				if target["name"] == targetName then
					return true;
				end;
			end;
		end;

		if bit.band(targetRole, CHA_ROLE_HEAL) > 0 then
			for k, target in next, template["roles"]["heal"]["targets"] do
				if target["name"] == targetName then
					return true;
				end;
			end;
		end;

		if bit.band(targetRole, CHA_ROLE_DECURSE) > 0 then
			for k, target in next, template["roles"]["decurse"]["targets"] do
				if target["name"] == targetName then
					return true;
				end;
			end;
		end;
	end;

	return false;
end;



--[[
	UI Initialization functions
--]]

--	UI Initlialization entry
function CHA_InitializeUI()
	CHA_CreateClassIcons();
	CHA_CreateTemplateButtons();
	CHA_CreateTargetFrames();
	CHA_InitializeOptions();

	CHA_UpdateUI();
end;

--	Create target frames with Targets and assigned Players.
--	Same set of frames are used for both Tanks, Healers and Decursers.
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

--	Initlialize the Class icons in the bottom of the role screen.
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
		entry:SetNormalTexture(classInfo["icon"]);
		entry:SetPushedTexture(classInfo["icon"]);

		posX = posX + width;
	end;
end;

--	Initialize the Player dropdown by populating it with players
--	eligible for assignment for the particular role.
function CHA_PlayerDropdown_Initialize()
	--	Skip if no player was selected ("cannot happen")
	if CHA_CurrentPlayerIndex == 0 then 
		return; 
	end;

	local roleTemplate = CHA_GetActiveRoleTemplate();
	if not roleTemplate then return; end;

	local target = roleTemplate["targets"][CHA_CurrentPlayerIndex];
	local players = CHA_GetPlayersByMask(roleTemplate["mask"]);

	for playerIndex = 1, table.getn(players), 1 do
		local info = UIDropDownMenu_CreateInfo();
		info.notCheckable = true;
		info.text       = players[playerIndex]["text"];
		info.icon		= players[playerIndex]["icon"];
		info.func       = function() CHA_PlayerDropdownClick(this, players[playerIndex]) end;
		UIDropDownMenu_AddButton(info);
	end
end;

--	Initalize the announcement channel dropdown box
function CHA_ChannelDropDown_Initialize()
	A.RefreshChannelList(true);

	for channelIndex = 1, table.getn(A.Chat.Channels), 1 do
		local info = UIDropDownMenu_CreateInfo();
		info.notCheckable = true;
		info.text       = string.format("/%s - %s", A.Chat.Channels[channelIndex]["id"], A.Chat.Channels[channelIndex]["name"]);
		info.func       = function() CHA_ChannelDropDown_OnClick(this, A.Chat.Channels[channelIndex]) end;
		UIDropDownMenu_AddButton(info);
	end
end;

--	Called when a chat channel is selected.
function CHA_ChannelDropDown_OnClick(sender, channelInfo)
	local caption = string.format("/%s - %s", channelInfo["id"], channelInfo["name"]);

	CHA_AnnouncementChannel = channelInfo["name"];
	CHA_UpdateChannelDropDownText();

	CHA_SetOption(CHA_KEY_AnnouncementChannel, CHA_AnnouncementChannel);
end;

--	Update the caption on the dropdown control:
function CHA_UpdateChannelDropDownText()
	local channel = A.GetChannelInfo(CHA_AnnouncementChannel);
	if channel then
		local caption = string.format("/%s - %s", channel["id"], channel["name"]);
		UIDropDownMenu_SetText(CHAMainFrameChannelDropDown, caption);
	end;
end;

--	Initalize UI config options with some value. It might be updated later once 
--	configuration is read.
function CHA_InitializeOptions()
	CHA_ChannelDropDown_Initialize();
	CHA_ChannelDropDown_OnClick(this, A.Chat.Channels[1]);
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

--	Check the configured channel and use thatif set.
--	Defaults to RAID.
function CHA_ProcessConfiguredAnnouncementChannel(configuredChannel)
	CHA_AnnouncementChannel = DIGAM_CHANNEL_RAID["name"];

	if configuredChannel and A.GetChannelInfo(configuredChannel) then
		CHA_AnnouncementChannel = configuredChannel;
	end;

	CHA_UpdateChannelDropDownText();
end;



--[[
	Player functionality
	A "Player" here means a character assigned to some role.
--]]

--	Move player from one target to another target.
function CHA_MoveAssignedPlayer(playerIndex, startTargetIndex, endTargetIndex)
	local roleTarget = CHA_GetActiveTargetTemplate();
	if not roleTarget then return; end;

	playerIndex = tonumber(playerIndex);
	startTargetIndex = tonumber(startTargetIndex);
	endTargetIndex = tonumber(endTargetIndex);

	local sourceTarget = roleTarget[startTargetIndex];
	local destTarget = roleTarget[endTargetIndex];
	if not sourceTarget or not destTarget then return; end;

	if not destTarget["players"] then 
		destTarget["players"] = { }; 
	end;

	if sourceTarget["players"][playerIndex] then
		tinsert(destTarget["players"], sourceTarget["players"][playerIndex]);

		sourceTarget["players"][playerIndex] = nil;
		sourceTarget["players"] = A.RenumberTable(sourceTarget["players"]);

		CHA_UpdateTargetFrames();
	end;
end;

--	Fetch all eligible Players by the current role mask.
function CHA_GetPlayersByMask(roleMask, includeUsedPlayers)
	local targets = { };
	local players = CHA_GetPlayersInRoster();

	for playerIndex = 1, table.getn(players), 1 do
		local player = players[playerIndex];
		if bit.band(player["mask"], roleMask) > 0 then
			if includeUsedPlayers or not CHA_IsPlayerUsedInTemplates(player["name"]) then
				tinsert(targets, player);
			end;
		end;
	end;

	return targets;
end; 

--	Check if current player is also used in targets and/or assignments.
function CHA_IsPlayerInTemplate(roleTemplate, playerName, checkTarget, checkAssignment)
	--	Check if player is assigned as role in //Template/Roles/<role>/Targets/<targetIndex>/Players/<playerIndex>/:
	for targetIndex = 1, table.getn(roleTemplate["targets"]), 1 do
		local targetTpl = roleTemplate["targets"][targetIndex];
		if targetTpl then
			if checkTarget and targetTpl["name"] == playerName then
				return true;
			end;

			if checkAssignment and targetTpl["players"] then
				for playerIndex = 1, table.getn(targetTpl["players"]), 1 do
					local playerTpl = targetTpl["players"][playerIndex];
					if playerTpl["name"] == playerName then
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
		if CHA_IsPlayerInTemplate(template["roles"]["tank"], playerName, false, true) then
			return true;
		end;
		if CHA_IsPlayerInTemplate(template["roles"]["heal"], playerName, false, true) then
			return true;
		end;
	end;

	--	HEAL ROLE: A player cannot be assigned as healer if already assigned as tank or healer.
	if CHA_ActiveRole == CHA_ROLE_HEAL then
		if CHA_IsPlayerInTemplate(template["roles"]["heal"], playerName, true, true) then
			return true;
		end;

		if not isTargetDropdown then
			if CHA_IsPlayerInTemplate(template["roles"]["tank"], playerName, false, true) then
				return true;
			end;
		end;
	end;

	--	DECURSOR ROLE: Any player can be ASSIGNED. Targets follows usual rules.
	if CHA_ActiveRole == CHA_ROLE_DECURSE then
		if isTargetDropdown then
			if CHA_IsPlayerInTemplate(template["roles"]["decurse"], playerName, true, false) then
				return true;
			end;
		end;

		if CHA_IsPlayerInTemplate(template["roles"]["decurse"], playerName, false, true) then
			return true;
		end;
	end;

	return false;
end;

--	Fetch a list of all players in the raid roster.
--	This include disconnected, dead and dwarfs!
--	"name": unique name (which means player + realm name)
--	"mask": the class mask
--	"text": the textual representation of the name.
--	"icon": icon
--	"class": class name (UPPERCASE).
--	This works in both raid, party and solo mode.
function CHA_GetPlayersInRoster()
	local unitid, fullName, className, classInfo;

	local players = { };		-- List of { "name", "mask", "text", "icon", "class" }

	if IsInRaid() then
		for n = 1, 40, 1 do
			unitid = "raid"..n;
			if not UnitName(unitid) then break; end;
			
			fullName = A.GetPlayerAndRealm(unitid);
			className = A.UnitClass(unitid);
			classInfo = CHA_ClassMatrix[className];

			tinsert(players, { 
				["name"] = fullName,
				["mask"] = classInfo["mask"], 
				["text"] = CHA_FormatPlayerName(fullName), 
				["icon"] = classInfo["icon"],
				["class"] = className,
			});
		end;

	elseif A.IsInParty() then
		for n = 1, GetNumGroupMembers(), 1 do
			unitid = "party"..n;
			if not UnitName(unitid) then
				unitid = "player";
			end;

			fullName = A.GetPlayerAndRealm(unitid);
			className = A.UnitClass(unitid);		
			classInfo = CHA_ClassMatrix[className];

			tinsert(players, {
				["name"] = fullName, 
				["mask"] = classInfo["mask"], 
				["text"] = CHA_FormatPlayerName(fullName),
				["icon"] = classInfo["icon"],
				["class"] = className, 
			});
		end;
	else
		--	SOLO play, somewhat usefull when testing
		unitid = "player";
		fullName = A.GetPlayerAndRealm(unitid);
		className = A.UnitClass(unitid);
		classInfo = CHA_ClassMatrix[className];

		tinsert(players, {
			["name"] = fullName,
			["mask"] = classInfo["mask"],
			["text"] = CHA_FormatPlayerName(fullName),
			["icon"] = classInfo["icon"],
			["class"] = className,
		});
	end;

	return players;
end;

--	Format player name so it is shot but still unique by "compressing" the realm name.
--	TODO: We need some kind of configurable options here.
function CHA_FormatPlayerName(playerName)
	--local _, _, name = string.find(playerName, "([%S]*-%S)%S*");
	local _, _, name, realm = string.find(playerName or "", "([%S]*)-(%S)%S*");
	if not name then
		return playerName; 
	end;

	name = string.format("%s:%s", realm, name);

	return name;
end;

--	Swap targets (Tanks are swapped with them!)
function CHA_SwapTargets(firstIndex)
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if roleTemplate then
		local targetA = roleTemplate["targets"][firstIndex];
		roleTemplate["targets"][firstIndex] = roleTemplate["targets"][firstIndex + 1];
		roleTemplate["targets"][firstIndex + 1] = targetA;
	end;
end;




--[[
	CHA business logic
--]]

--	TODO: This counter needs some re-thinking! :-<
function CHA_UpdateRoleCounter()
	local numPlayers = 0;
	local numAssigned = 0;

	local roleMask = 0;
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if roleTemplate then
		roleMask = roleTemplate["mask"];
	end;

	local groupType, groupCount;
	if GetNumGroupMembers() > 0 then
		if IsInRaid() then
			groupType = "raid";
		else
			groupType = "party";
		end;

		for i = 1, GetNumGroupMembers() do
			unitid = groupType..i;
			local className = A.UnitClass(unitid);
			if not className then
				unitid = "player";
				className = A.UnitClass(unitid);
			end;

			local classInfo = CHA_ClassMatrix[className];
			if bit.band(classInfo["mask"], roleMask) > 0 then
				numPlayers = numPlayers + 1;
			end;
		end
	else
		local classInfo = CHA_ClassMatrix[A.UnitClass("player")];
		if bit.band(classInfo["mask"], roleMask) > 0 then
			numPlayers = 1;
		end;
	end;
	
	local roleTarget = CHA_GetActiveTargetTemplate();
	if roleTarget then
		for k, target in next, roleTarget do
			if target["players"] then
				numAssigned = numAssigned + table.getn(target["players"]);
			end;
		end;
	end;


	if CHA_ActiveRole == CHA_ROLE_TANK then
		CHAHealerCountCaption:SetText(string.format("Tanks: %s/%s", numAssigned, numPlayers));
	elseif CHA_ActiveRole == CHA_ROLE_HEAL then
		CHAHealerCountCaption:SetText(string.format("Healers: %s/%s", numAssigned, numPlayers));
	else -- Decurser:
		CHAHealerCountCaption:SetText(string.format("Decursers: %s/%s", numAssigned, numPlayers));
	end;
end



--[[
	Template logic
--]]

--	As name says: returns the current active template / nil for none.
--	Path: //templates/
function CHA_GetActiveTemplate()
	local _, template = CHA_GetTemplateByName(CHA_ActiveTemplate);
	return template;
end;

--	Return the current active role template / nil for none.
--	Path: //templates/roles/<role>/
function CHA_GetActiveRoleTemplate()
	local roleName = CHA_RoleMatrix[CHA_ActiveRole];
	if not roleName then return nil; end;

	local template = CHA_GetActiveTemplate();
	if not template then return nil; end;

	return template["roles"][roleName];
end;

--	Return current active target template / nil for none.
--	Path: //templates/roles/<role>/targets/
function CHA_GetActiveTargetTemplate()
	local roleTemplate = CHA_GetActiveRoleTemplate();
	if not roleTemplate then return nil; end;
	
	return roleTemplate["targets"]
end;

--	Add a new Template to the template array
function CHA_CreateTemplate(templateName)
	local templateCount = table.getn(CHA_Templates);
	if templateCount < CHA_TEMPLATES_MAX then
		templateCount = templateCount + 1;
		CHA_Templates[templateCount] = {
			["templatename"] = templateName,
			["roles"] = {
				["tank"] = { 
					["caption"] = "Tanks",
					["headline"] = "---/\\/\\--- TANK Assignments:",
					["contentline"] = "--- {TARGET} <== {ASSIGNMENTS}",
					["bottomline"] = "",
					["mask"] = CHA_ROLE_DEFAULT_TANK,
					["targets"] = {	},
				},
				["heal"] = { 
					["caption"] = "Heals", 
					["headline"] = "---\\/\\/--- HEALER Assignments:",
					["contentline"] = "--- {TARGET} <== {ASSIGNMENTS}",
					["bottomline"] = "--- All other healers: Heal the raid.",
					["mask"] = CHA_ROLE_DEFAULT_HEAL,
					["targets"] = { },
				},
				["decurse"] = { 
					["caption"] = "Decurses", 
					["headline"] = "---!!!--- DECURSE Assignments:",
					["contentline"] = "--- {TARGET} <== {ASSIGNMENTS}",
					["bottomline"] = "--- All others: decurse raid.",
					["mask"] = CHA_ROLE_DEFAULT_DECURSE,
					["targets"] = { },
				},
			},
		};
	end;
	return templateCount;
end;

--	Return (index, template) by name, nil if none was found.
function CHA_GetTemplateByName(templateName)
	for templateIndex = 1, table.getn(CHA_Templates), 1 do
		if CHA_Templates[templateIndex]["templatename"] == templateName then
			return templateIndex, CHA_Templates[templateIndex];
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

--	Consume persisted LUA data into template array.
--	Note: Array is not loaded "as is", even that could be the easy way.
--	Instead we are reading and checking values to avoid a broken array.
function CHA_ProcessConfiguredTemplateData(workTemplates)
	CHA_Templates = { };

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
	local templateName = template["templatename"];
	if not templateName then return; end;

	if not template["roles"] then return; end;
	
	--	This creates the template with default setup data:
	local tpl = CHA_Templates[CHA_CreateTemplate(templateName)];

	--	Read tank/healer/decursers from template and overwrite defaults if available.
	for roleMask, roleName in next, CHA_RoleMatrix do
		local roleTemplate = template["roles"][roleName];

		if roleTemplate then
			if roleTemplate["caption"] and type(roleTemplate["caption"]) == "string" then
				tpl["roles"][roleName]["caption"] = roleTemplate["caption"];
			end;

			if roleTemplate["headline"] and type(roleTemplate["headline"]) == "string" then
				tpl["roles"][roleName]["headline"] = roleTemplate["headline"];
			end;

			if roleTemplate["contentline"] and type(roleTemplate["contentline"]) == "string" then
				tpl["roles"][roleName]["contentline"] = roleTemplate["contentline"];
			end;

			if roleTemplate["bottomline"] and type(roleTemplate["bottomline"]) == "string" then
				tpl["roles"][roleName]["bottomline"] = roleTemplate["bottomline"];
			end;

			if roleTemplate["mask"] and type(roleTemplate["mask"]) == "string" then
				tpl["roles"][roleName]["mask"] = roleTemplate["mask"];
			end;


			--	This will import last used targets.
			--	Players might even not be in the raid anymore. We will handle that later!
			local roleTargets = roleTemplate["targets"]; 
			if roleTargets then
				if type(roleTargets) == "table" and table.getn(roleTargets) > 0 then

					--//Templates/roles/<role>/targets/<targetIndex>
					for targetIndex, roleTarget in next, roleTargets do
						local tName = roleTarget["name"];
						local tMask = roleTarget["mask"];
						local tText = roleTarget["text"];
						local tIcon = roleTarget["icon"];

						if tMask and tName and tIcon then
							local tPlayers = { };
							local rolePlayers = roleTarget["players"];

							if type(rolePlayers) == "table" and table.getn(rolePlayers) > 0 then
								--//Templates/roles/<role>/targets/<targetIndex>/players/<playerIndex>
								for playerIndex, rolePlayer in next, rolePlayers do
									local pName = rolePlayer["name"];
									local pMask = rolePlayer["mask"];
									local pText = rolePlayer["text"];
									local pIcon = rolePlayer["icon"];
									local pClass = rolePlayer["class"];

									if pClass and pMask and pName and pIcon then
										tinsert(tPlayers, { 
											["name"] = pName, 
											["mask"] = pMask, 
											["text"] = pText, 
											["icon"] = pIcon, 
											["class"] = pClass, 
										});
									end;
								end;
							end;

							tinsert(tpl["roles"][roleName]["targets"], { 
								["name"] = tName, 
								["mask"] = tMask, 
								["text"] = tText, 
								["icon"] = tIcon, 
								["players"] = tPlayers,
							});
						end;
					end;
				end;
			end;
		end;
	end;
end;



--[[
	Announce functionality
--]]

--	Shout it out in public!
function CHA_PublicAnnouncement()
	if GetNumGroupMembers() == 0 then
		--	Only works in Party and Raid mode, sorry!
		return;
	end;

	local announcements = CHA_GenerateAnnouncements();
	if not announcements then
		A.Echo("There are no announcements for this role available.");
		return;
	end;

	for n = 1, table.getn(announcements), 1 do
		A.EchoByName(CHA_AnnouncementChannel, announcements[n]);
	end;
end;

--	Shout it out locally (test your announcement!)
function CHA_PrivateAnnouncement()
	local announcements = CHA_GenerateAnnouncements();
	if not announcements then
		A.Echo("There are no announcements for this role available.");
		return;
	end;

	for n = 1, table.getn(announcements), 1 do
		A.Echo(announcements[n]);
	end;
end;

--	Generate list of announcement lines
function CHA_GenerateAnnouncements()
	local announcements = { };

	local roleTemplate = CHA_GetActiveRoleTemplate();
	if not roleTemplate then
		return;
	end;

	--local roleTargets = CHA_GetActiveTargetTemplate();
	local targetCount = table.getn(roleTemplate["targets"] or { });
	if targetCount == 0 then
		return;
	end;


	local headline = CHATextFrameHeadline:GetText();
	local content = CHATextFrameContentLine:GetText();
	local bottom = CHATextFrameBottomLine:GetText();

	if headline ~= "" then
		tinsert(announcements, headline);
	end;

	for tIndex, target in next, roleTemplate["targets"] do
		local tankName = target["text"];
		if bit.band(target["mask"], CHA_TARGET_RAIDICON) > 0 then
			--	Raid icons must be rendered using their icon, which is stored as the "name" property.
			--	Internal note: this does not work locally, only in channels!
			tankName = target["name"];
		end;

		local assigned = "";
		for pIndex, player in next, target["players"] do
			if assigned ~= "" then
				assigned = assigned ..", ";
			end;

			assigned = assigned .. player["text"];
		end;

		local assignments = content;
		assignments = string.gsub(assignments, "{TARGET}", tankName);
		assignments = string.gsub(assignments, "{ASSIGNMENTS}", assigned);

		tinsert(announcements, assignments);
	end;

	if bottom ~= "" then
		tinsert(announcements, bottom);
	end;


	return announcements;
end;


--[[
	Addon communication
--]]

function CHA_HandleTXVersion(message, sender)
	A.SendAddonMessage("RX_VERSION#".. A.Properties.Version .."#"..sender)
end;

function CHA_HandleRXVersion(message, sender)
	A.Echo(string.format("%s is using Classic Healing Assignments version %s", sender, message))
end;




--[[
	Event handlers
--]]
function CHA_OnEvent(self, event, ...)
	if event == "ADDON_LOADED" then
		local addonname = ...;
		if addonname == A.Properties.AddonName then
			CHA_PostInitialization();
		end;

	elseif event == "UNIT_CONNECTION" then
		CHA_UpdateRoleButtons();
		CHA_UpdateTargetFrames();

	elseif event == "CHAT_MSG_ADDON" then
		local prefix, msg, channel, sender = ...;
		if prefix ~= A.Properties.Prefix then	
			return;
		end;

		--	Note: sender+recipient contains both name+realm of who sended message.
		local _, _, cmd, message, recipient = string.find(msg, "([^#]*)#([^#]*)#([^#]*)");	

		if not (recipient == "") then
			if not (recipient == CHA_LocalPlayerName) then
				return
			end
		end

		if cmd == "TX_VERSION" then
			CHA_HandleTXVersion(message, sender);

		elseif cmd == "RX_VERSION" then
			CHA_HandleRXVersion(message, sender);
		end;
	end;
end



function CHA_OnLoad()
	CHA_CurrentVersion = A.CalculateVersion();

	A.Echo(string.format("Type %s/cha%s to configure the addon, or click the [+] button.", A.Chat.ChatColorHot, A.Chat.ChatColorNormal));

	CHAHeadlineCaption:SetText(string.format("Classic Healing Assignments - version %s", A.Properties.Version));
	CHABottomlineCaption:SetText(string.format("Classic Healing Assignments version %s by %s", A.Properties.Version, A.Properties.Author));

	CHA_PreInitialization();

	CHAEventFrame:RegisterEvent("ADDON_LOADED");
	CHAEventFrame:RegisterEvent("UNIT_CONNECTION");
    CHAEventFrame:RegisterEvent("CHAT_MSG_ADDON");

	C_ChatInfo.RegisterAddonMessagePrefix(A.Properties.Prefix);
end;


