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
local CHA_COLOR_RAIDICON					= { 128, 128,  80 };
local CHA_COLOR_DIRECTION					= {  80, 128, 128 };
local CHA_COLOR_CUSTOM						= { 128,  80, 128 };
local CHA_COLOR_GROUP						= {  80, 128,  80 };

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

local CHA_RESOURCE_PLAYERS					= 0x00ffff;		--	Bitmask for all player types (room for 16 classes, only 10 used so far)
local CHA_RESOURCE_SYMBOLS					= 0x0f0000;		--	Bitmask for all non-player types

local CHA_ROLE_NONE							= 0x0000;
local CHA_ROLE_TANK							= 0x0001;
local CHA_ROLE_HEALER						= 0x0002;

--	{ "name"=<unique name>, "mask"=<mask>, "text"=<display name>, "icon"=<icon> }
--	Note: npc types are all encapsulated in"{...}" to ensure uniqueness amongst ordinary player names.
local CHA_ResourceMatrix =  {
	{ 
		["name"] = "{Unassigned}",
		["mask"] = CHA_RESOURCE_UNASSIGNED,
		["text"] = "(Unassigned)",
		["icon"] = "Interface\\PaperDoll\\UI-Backpack-EmptySlot",
		["color"] = { 128, 128, 128 },
	}, {
		["name"] = "{Skull}",
		["mask"] = CHA_RESOURCE_RAIDICON,
		["text"] = "Skull",
		["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8",
		["color"] = CHA_COLOR_RAIDICON,
	}, {
		["name"] = "{Cross}",
		["mask"] = CHA_RESOURCE_RAIDICON,
		["text"] = "Cross",
		["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7",
		["color"] = CHA_COLOR_RAIDICON,
	}, {
		["name"] = "{Square}",
		["mask"] = CHA_RESOURCE_RAIDICON,
		["text"] = "Square",
		["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6",
		["color"] = CHA_COLOR_RAIDICON,
	}, {
		["name"] = "{Moon}",
		["mask"] = CHA_RESOURCE_RAIDICON,
		["text"] = "Moon",
		["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_5",
		["color"] = CHA_COLOR_RAIDICON,
	}, {
		["name"] = "{Triangle}",
		["mask"] = CHA_RESOURCE_RAIDICON,
		["text"] = "Triangle",
		["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
		["color"] = CHA_COLOR_RAIDICON,
	}, {
		["name"] = "{Diamond}",
		["mask"] = CHA_RESOURCE_RAIDICON,
		["text"] = "Diamond",		
		["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
		["color"] = CHA_COLOR_RAIDICON,
	}, {
		["name"] = "{Circle}",
		["mask"] = CHA_RESOURCE_RAIDICON,
		["text"] = "Circle",
		["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2",
		["color"] = CHA_COLOR_RAIDICON,
	}, {
		["name"] = "{Star}",
		["mask"] = CHA_RESOURCE_RAIDICON,
		["text"] = "Star",
		["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1",
		["color"] = CHA_COLOR_RAIDICON,
	}, {
		["name"] = "{Left}",
		["mask"] = CHA_RESOURCE_DIRECTION,
		["text"] = "<== Left",
		["icon"] = "Interface\\Icons\\spell_chargenegative",
		["color"] = CHA_COLOR_DIRECTION,
	}, {
		["name"] = "{Right}",
		["mask"] = CHA_RESOURCE_DIRECTION,
		["text"] = "Right ==>",
		["icon"] = "Interface\\Icons\\spell_chargepositive",
		["color"] = CHA_COLOR_DIRECTION,
	}, {
		["name"] = "{North}",
		["mask"] = CHA_RESOURCE_DIRECTION,
		["text"] = "North",
		["icon"] = 132181,
		["color"] = CHA_COLOR_DIRECTION,
	}, {
		["name"] = "{East}",
		["mask"] = CHA_RESOURCE_DIRECTION,
		["text"] = "East",
		["icon"] = 132181,
		["color"] = CHA_COLOR_DIRECTION,
	}, {
		["name"] = "{South}",
		["mask"] = CHA_RESOURCE_DIRECTION,
		["text"] = "South",
		["icon"] = 132181,
		["color"] = CHA_COLOR_DIRECTION,
	}, {
		["name"] = "{West}",
		["mask"] = CHA_RESOURCE_DIRECTION,
		["text"] = "West",
		["icon"] = 132181,
		["color"] = CHA_COLOR_DIRECTION,
	}, {
		["name"] = "{Custom1}",
		["mask"] = CHA_RESOURCE_CUSTOM,
		["text"] = "(Custom 1)",
		["icon"] = 134466,
		["color"] = CHA_COLOR_CUSTOM,
	}, {
		["name"] = "{Custom2}",
		["mask"] = CHA_RESOURCE_CUSTOM,
		["text"] = "(Custom 2)",
		["icon"] = 134467,
		["color"] = CHA_COLOR_CUSTOM,
	}, {
		["name"] = "{Custom3}",
		["mask"] = CHA_RESOURCE_CUSTOM,
		["text"] = "(Custom 3)",
		["icon"] = 134468,
		["color"] = CHA_COLOR_CUSTOM,
	}, {
		["name"] = "{Custom4}",
		["mask"] = CHA_RESOURCE_CUSTOM,
		["text"] = "(Custom 4)",
		["icon"] = 134469,
		["color"] = CHA_COLOR_CUSTOM,
	}, {
		["name"] = "{Group1}",
		["mask"] = CHA_RESOURCE_GROUP,
		["text"] = "Group 1",
		["icon"] = "Interface\\AddOns\\ClassicHealingAssignments\\Media\\logo-square",
		["color"] = CHA_COLOR_GROUP,
	}, {
		["name"] = "{Group2}",
		["mask"] = CHA_RESOURCE_GROUP,
		["text"] = "Group 2",
		["icon"] = "Interface\\AddOns\\ClassicHealingAssignments\\Media\\logo-square",
		["color"] = CHA_COLOR_GROUP,
	}, {
		["name"] = "{Group3}",
		["mask"] = CHA_RESOURCE_GROUP,
		["text"] = "Group 3",
		["icon"] = "Interface\\AddOns\\ClassicHealingAssignments\\Media\\logo-square",
		["color"] = CHA_COLOR_GROUP,
	}, {
		["name"] = "{Group4}",
		["mask"] = CHA_RESOURCE_GROUP,
		["text"] = "Group 4",
		["icon"] = "Interface\\AddOns\\ClassicHealingAssignments\\Media\\logo-square",
		["color"] = CHA_COLOR_GROUP,
	}, {
		["name"] = "{Group5}",
		["mask"] = CHA_RESOURCE_GROUP,
		["text"] = "Group 5",
		["icon"] = "Interface\\AddOns\\ClassicHealingAssignments\\Media\\logo-square",
		["color"] = CHA_COLOR_GROUP,
	}, {
		["name"] = "{Group6}",
		["mask"] = CHA_RESOURCE_GROUP,
		["text"] = "Group 6",
		["icon"] = "Interface\\AddOns\\ClassicHealingAssignments\\Media\\logo-square",
		["color"] = CHA_COLOR_GROUP,
	}, {
		["name"] = "{Group7}",
		["mask"] = CHA_RESOURCE_GROUP,
		["text"] = "Group 7",
		["icon"] = "Interface\\AddOns\\ClassicHealingAssignments\\Media\\logo-square",
		["color"] = CHA_COLOR_GROUP,
	}, {
		["name"] = "{Group8}",
		["mask"] = CHA_RESOURCE_GROUP,
		["text"] = "Group 8",
		["icon"] = "Interface\\AddOns\\ClassicHealingAssignments\\Media\\logo-square",
		["color"] = CHA_COLOR_GROUP,
	},
};


local CHA_FRAME_MAXTARGET					= 8;
local CHA_FRAME_MAXPLAYERS					= 8;	-- Would like at least 10, but there isn't room in the ui :(
	
local CHA_ICON_NONE							= "Interface\\AddOns\\ClassicHealingAssignments\\Media\\logo-square";
local CHA_ICON_READY						= "Interface\\AddOns\\ClassicHealingAssignments\\Media\\logo-square";

--	Used for defaults on role config page
local CHA_MASK_TARGET_DEFAULT				= CHA_CLASS_DRUID + CHA_CLASS_WARRIOR + CHA_RESOURCE_DIRECTION + CHA_RESOURCE_RAIDICON;
local CHA_MASK_HEALER_DEFAULT				= CHA_CLASS_DRUID + CHA_CLASS_PALADIN + CHA_CLASS_PRIEST + CHA_CLASS_SHAMAN;

--	Local variables:
local CHA_CurrentVersion					= 0;
local CHA_UpdateMessageShown				= false;
local CHA_IconMoving						= false;
local CHA_CurrentTemplateIndex				= 0;
local CHA_CurrentTemplateOperation			= "";
local CHA_CurrentTargetIndex				= 0;
local CHA_CurrentHealerIndex				= 0;
local CHA_LocalPlayerName					= "";

--	Persisted options:
CHA_PersistedData							= { };

local CHA_KEY_ActiveTemplate				= "ActiveTemplate";
local CHA_KEY_AnnounceButtonPosX			= "AnnounceButton.X";
local CHA_KEY_AnnounceButtonPosY			= "AnnounceButton.Y";
local CHA_KEY_AnnounceButtonSize			= "AnnounceButton.Size";
local CHA_KEY_AnnounceButtonVisible			= "AnnounceButton.Visible";
local CHA_KEY_AnnouncementChannel			= "Announcement.Channel";
local CHA_KEY_Templates						= "Templates";

local CHA_DEFAULT_ActiveTemplate			= nil;
local CHA_DEFAULT_AnnounceButtonSize		= 32;
local CHA_DEFAULT_AnnounceButtonVisible		= true;

local CHA_ActiveTemplate					= CHA_DEFAULT_ActiveTemplate;
local CHA_AnnounceButtonSize				= CHA_DEFAULT_AnnounceButtonSize;
local CHA_AnnounceButtonVisible				= CHA_DEFAULT_AnnounceButtonVisible;
local CHA_AnnouncementChannel				= "";
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
		["targetmask"] = 0,
		["healermask"] = 0,
		["headlinetext"] = "### Healer assignments:",
		["contenttext"] = "### {TARGET} <== {ASSIGNMENTS}",
		["bottomtext"] = "### All other healers: Heal the raid.",
		["whispertext"] = "### Whisper me Repeat (TODO)",
		["showwhispertext"] = false,
		["targets"] = 
		{
			{
				["name"] = "{Skull}",
				["mask"] = 65536,
				["text"] = "Skull",
				["icon"] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8",
				["healers"] =
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
--]]

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
CHA_BACKDROP_HEALER = {
	bgFile = "Interface\\TalentFrame\\PriestHoly-Topleft",
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

StaticPopupDialogs["CHA_DIALOG_RENAME_RESOURCE"] = {
	text = "New name:",
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
		CHA_RenameResource_OK(self.text.text_arg1, self.editBox:GetText())
	end,
	EditBoxOnTextChanged = function(self, data)
		if self:GetText() == "" then
			self:GetParent().button1:Disable()
		else
			self:GetParent().button1:Enable();
		end;
	end,
}

--	Dropdown menu for Target selection:
CHA_TargetDropdownMenu = CreateFrame("FRAME", "CHA_TargetDropdownMenuFrame", UIParent, "UIDropDownMenuTemplate");
CHA_TargetDropdownMenu:SetPoint("CENTER");
CHA_TargetDropdownMenu:Hide();
UIDropDownMenu_SetWidth(CHA_TargetDropdownMenu, 1);
UIDropDownMenu_SetText(CHA_TargetDropdownMenu, "");

UIDropDownMenu_Initialize(CHA_TargetDropdownMenu, function(self, level, menuList)
	if CHA_TargetDropdown_Initialize then
		CHA_TargetDropdown_Initialize(self, level, menuList); 
	end;
end);

--	Dropdown menu for Healer (add/replace healer) selection:
CHA_HealerDropdownMenu = CreateFrame("FRAME", "CHA_HealerDropdownMenuFrame", UIParent, "UIDropDownMenuTemplate");
CHA_HealerDropdownMenu:SetPoint("CENTER");
CHA_HealerDropdownMenu:Hide();
UIDropDownMenu_SetWidth(CHA_HealerDropdownMenu, 1);
UIDropDownMenu_SetText(CHA_HealerDropdownMenu, "");

UIDropDownMenu_Initialize(CHA_HealerDropdownMenu, function(self, level, menuList)
	if CHA_HealerDropdown_Initialize then
		CHA_HealerDropdown_Initialize(self, level, menuList); 
	end;
end);

--	Options for Templates:
local CHA_TemplateOptionsMenu = CreateFrame("FRAME", "CHA_TemplateOptionsMenuFrame", UIParent, "UIDropDownMenuTemplate");
CHA_TemplateOptionsMenu:SetPoint("CENTER");
CHA_TemplateOptionsMenu:Hide();
UIDropDownMenu_SetWidth(CHA_TemplateOptionsMenu, 1);
UIDropDownMenu_SetText(CHA_TemplateOptionsMenu, "");

UIDropDownMenu_Initialize(CHA_TemplateOptionsMenu, function(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	info.text = "Move up";
	info.func = CHA_TemplateOptionsMenu_MoveUp;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Move down";
	info.func = CHA_TemplateOptionsMenu_MoveDown;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Copy template";
	info.func = CHA_TemplateOptionsMenu_Clone;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Rename template";
	info.func = CHA_TemplateOptionsMenu_Rename;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Delete template";
	info.func = CHA_TemplateOptionsMenu_Delete;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)
end);

--	Options for a Target (a tank):
local CHA_TargetOptionsMenu = CreateFrame("FRAME", "CHA_TargetOptionsMenuFrame", UIParent, "UIDropDownMenuTemplate");
CHA_TargetOptionsMenu:SetPoint("CENTER");
CHA_TargetOptionsMenu:Hide();
UIDropDownMenu_SetWidth(CHA_TargetOptionsMenu, 1);
UIDropDownMenu_SetText(CHA_TargetOptionsMenu, "");

UIDropDownMenu_Initialize(CHA_TargetOptionsMenu, function(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	info.text = "Move up";
	info.func = CHA_TargetOptionsMenu_MoveUp;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Move down";
	info.func = CHA_TargetOptionsMenu_MoveDown;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Rename tank";
	info.func = CHA_TargetOptionsMenu_Rename;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Unassign tank";
	info.func = CHA_TargetOptionsMenu_Unassign;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Remove tank";
	info.func = CHA_TargetOptionsMenu_Delete;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)
end);

--	Options for Healer (assignee):
local CHA_HealerOptionsMenu = CreateFrame("FRAME", "CHA_HealerOptionsMenuFrame", UIParent, "UIDropDownMenuTemplate");
CHA_HealerOptionsMenu:SetPoint("CENTER");
CHA_HealerOptionsMenu:Hide();
UIDropDownMenu_SetWidth(CHA_HealerOptionsMenu, 1);
UIDropDownMenu_SetText(CHA_HealerOptionsMenu, "");

UIDropDownMenu_Initialize(CHA_HealerOptionsMenu, function(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	info.text = "Move up";
	info.func = CHA_HealerOptionsMenu_MoveUp;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Move down";
	info.func = CHA_HealerOptionsMenu_MoveDown;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Rename healer";
	info.func = CHA_HealerOptionsMenu_Rename;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Unassign healer";
	info.func = CHA_HealerOptionsMenu_Unassign;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Remove healer";
	info.func = CHA_HealerOptionsMenu_Delete;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info)
end);

--	Classes setup:
local CHA_CLASS_MATRIX_MASTER = {
	["DRUID"] = {
		["mask"] = CHA_CLASS_DRUID,
		["icon"] = 625999,
		["role"] = CHA_ROLE_TANK + CHA_ROLE_HEALER,
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
		["role"] = CHA_ROLE_NONE,
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
		["role"] = CHA_ROLE_HEALER,
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
		["role"] = CHA_ROLE_HEALER,
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
		A.Echo(string.format("%s is using ClassicHealingAssignments version %s", CHA_LocalPlayerName, A.Properties.Version));
	end
end

--	Show HELP options
--	Syntax: /chahelp
--	Alternative: /cha help
--	Added in: 2.0.0
--
SLASH_CHA_HELP1 = "/chahelp"
SlashCmdList["CHA_HELP"] = function(msg)
	A.Echo(string.format("ClassicHealingAssignments version %s options:", A.Properties.Version));
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
	if A.Properties.ExpansionLevel > 1 then
		--	TBC: Add Paladin as tank (I don't care what you guys say, paladins cannot tank in classic.)
		CHA_MASK_TARGET_DEFAULT = bit.bor(CHA_MASK_TARGET_DEFAULT, CHA_CLASS_PALADIN);

		if A.Properties.ExpansionLevel > 2 then
			--	WotLK: Add Deathknight as tank
			CHA_MASK_TARGET_DEFAULT = bit.bor(CHA_MASK_TARGET_DEFAULT, CHA_CLASS_DEATHKNIGHT);
		end;
	end;

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

	local paladinRole = CHA_ROLE_HEALER;
	if A.Properties.ExpansionLevel > 1 then
		paladinRole = bit.bor(paladinRole, CHA_ROLE_TANK);
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

--	Return resource (a player or symbol) with the current mask value.
function CHA_GetResourceByMask(mask)
	for _, resource in next, CHA_ResourceMatrix do
		if resource["mask"] == mask then
			return resource;
		end;
	end;
	return nil;
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

	--	TODO: Add WotLK raids ... no hurry!

	CHA_CreateTemplate("Other");
end;



--[[
	UI Functions
--]]

--	Main UI update functionality
function CHA_UpdateUI()
	CHA_UpdateHealerCounter();
	CHA_UpdateAnnounceButton();
	CHA_UpdateTemplates();
	CHA_UpdateResourceFrames();
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
	CHA_UpdateAnnounceButton();

	CHA_SetOption(CHA_KEY_Templates, CHA_Templates);
end;

--	Close all popups. Used to avoid open popups with data for
--	a window which was later changed.
function CHA_ForceClosePopups()
	StaticPopup_Hide("CHA_DIALOG_ADDTEMPLATE");
	StaticPopup_Hide("CHA_DIALOG_RENAME_RESOURCE");
	StaticPopup_Hide("DIGAM_DIALOG_CONFIRMATION");
	StaticPopup_Hide("DIGAM_DIALOG_ERROR");

	HideDropDownMenu(1, nil, CHA_TargetDropdownMenu, "cursor", 3, -3);
	HideDropDownMenu(1, nil, CHA_HealerDropdownMenu, "cursor", 3, -3);
	HideDropDownMenu(1, nil, CHA_TemplateOptionsMenu, "cursor", 3, -3);
	HideDropDownMenu(1, nil, CHA_TargetOptionsMenu, "cursor", 3, -3);
	HideDropDownMenu(1, nil, CHA_HealerOptionsMenu, "cursor", 3, -3);
end;

function CHA_OpenTextConfigDialogue()
	CHA_UpdateAnnouncementTexts();
	CHA_ForceClosePopups();
	CHATextFrame:Show();
end;

function CHA_CloseTextConfigDialogue()
	CHATextFrame:Hide();

	local template = CHA_GetActiveTemplate();
	if template then
		template["headlinetext"] = CHATextFrameHeadline:GetText();
		template["contenttext"] = CHATextFrameContentLine:GetText();
		template["bottomtext"] = CHATextFrameBottomLine:GetText();
		template["whispertext"] = CHATextFrameWhisperLine:GetText();
	end;
end;

--	Change to Target (tank) configuration page
function CHA_ShowTargetConfiguration()
	CHA_ForceClosePopups();

	local sourceMask = CHA_ROLE_NONE;
	local template = CHA_GetActiveTemplate();
	if template then
		sourceMask = template["targetmask"];
	end;

	CHA_OpenSourceConfigDialogue(sourceMask, CHA_UpdateTargetMask);
end;

function CHA_UpdateTargetMask(sourceMask)
	local template = CHA_GetActiveTemplate();
	if template then
		template["targetmask"] = sourceMask;
	end;

	CHA_UpdateUI();
	CHA_SetOption(CHA_KEY_Templates, CHA_Templates);
end;

--	Change to Healer configuration page
function CHA_ShowHealerConfiguration()
	CHA_ForceClosePopups();

	local sourceMask = CHA_ROLE_NONE;
	local template = CHA_GetActiveTemplate();
	if template then
		sourceMask = template["healermask"];
	end;

	CHA_OpenSourceConfigDialogue(sourceMask, CHA_UpdateHealerMask);
end;

function CHA_UpdateHealerMask(sourceMask)
	local template = CHA_GetActiveTemplate();
	if template then
		template["healermask"] = sourceMask;
	end;

	CHA_UpdateUI();
	CHA_SetOption(CHA_KEY_Templates, CHA_Templates);
end;

--	Update the announce button, main entry
function CHA_UpdateAnnounceButton()
	CHA_RepositionateButton();

	local icon = CHA_ICON_NONE;
	local alpha = CHA_ALPHA_DIMMED;
	if CHA_AnnounceButtonVisible then
		local template = CHA_GetActiveTemplate();
		if template and table.getn(template["targets"]) > 0 then
			icon = CHA_ICON_READY;
			alpha = CHA_ALPHA_ENABLED;
		end;
	end;

	CHAAnnounceButton:SetNormalTexture(icon);
	CHAAnnounceButton:SetPushedTexture(icon);
	CHAAnnounceButton:SetAlpha(alpha);

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

--	Return the configured color for a resource.
function CHA_GetResourceColor(resource)
	local classInfo = CHA_ClassMatrix[resource["class"]];
	if classInfo then
		--	Resource is a player: fetch color directly:
		return classInfo["color"];
	end;

	for _, resInfo in next, CHA_ResourceMatrix do
		if resInfo["mask"] == resource["mask"] then
			return resInfo["color"];
		end;
	end;
	
	return {0, 0, 0 };
end;

--	Update resource frames (targets + healers).
function CHA_UpdateResourceFrames()
	local template = CHA_GetActiveTemplate();

	local targets = { };
	if template then
		targets = template["targets"];
	end;

	for index = 1, CHA_FRAME_MAXTARGET, 1 do
		local fTarget = _G[string.format("targetframe_%d", index)];
		local fTargetIcon = _G[string.format("targeticon_%d", index)];
		local fTargetCaption = _G[string.format("targetcaption_%d", index)];

		local target = targets[index];
		if target then
			--	TARGET frames:
			fTargetIcon:SetNormalTexture(target["icon"]);
			fTargetIcon:SetPushedTexture(target["icon"]);
			if bit.band(target["mask"], CHA_RESOURCE_PLAYERS) > 0 then
				fTargetCaption:SetText(CHA_FormatPlayerName(target["text"]));
			else
				fTargetCaption:SetText(target["text"]);
			end;

			--	HEALER frames: 
			--	Each frame can have up to CHA_FRAME_MAXPLAYERS healers assigned.
			local posX = playerOffset;
			local posY = 0;
			for healerIndex = 1, CHA_FRAME_MAXPLAYERS, 1 do
				local healer = target["healers"] and target["healers"][healerIndex];
				if healer then
					local alpha = CHA_ALPHA_ENABLED;
					local color = CHA_GetResourceColor(healer);
					local fHealerButtonName = string.format("healerbutton_%d_%d", index, healerIndex);
					local fHealerButton = _G[fHealerButtonName];
					if bit.band(healer["mask"], CHA_RESOURCE_PLAYERS) > 0 then
						_G[fHealerButtonName.."Caption"]:SetText(CHA_FormatPlayerName(healer["text"]));
						local unitid = A.GetUnitidFromName(healer["name"]);
						if not (unitid and UnitIsConnected(unitid)) then
							alpha = CHA_ALPHA_DISABLED;
						end;
					else
						_G[fHealerButtonName.."Caption"]:SetText(healer["text"]);
					end;

					_G[fHealerButtonName.."BG"]:SetVertexColor( color[1]/255, color[2]/255, color[3]/255 );

					fHealerButton:SetAlpha(alpha);
					fHealerButton:Show();
				else
					local fHealerButtonName = string.format("healerbutton_%d_%d", index, healerIndex);
					local fHealerButton = _G[fHealerButtonName];
					_G[fHealerButtonName.."Caption"]:SetText("");
					_G[fHealerButtonName.."Caption"]:SetTextColor(1, 1, 1);
					fHealerButton:Hide();
				end;
			end;

			fTarget:Show();
		else
			fTarget:Hide();
		end;
	end;
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

	--	Support up to <CHA_TEMPLATES_MAX> templates.
	--	Disable button if limit is exceeded.
	if templateCount < CHA_TEMPLATES_MAX then
		CHAMainFrameAddTemplateButton:Enable();
	else
		CHAMainFrameAddTemplateButton:Disable();
	end;
end;

--	Update announcement texts in the UI, based on the current template.
function CHA_UpdateAnnouncementTexts()
	local headline = "";
	local content = "";
	local bottom = "";
	local whisper = "";
	local showWhisper = false;

	local template = CHA_GetActiveTemplate();
	if template then
		headline = template["headlinetext"] or "";
		content = template["contenttext"] or "";
		bottom = template["bottomtext"] or "";
		whisper = template["whispertext"] or "";

		showWhisper = template["showwhispertext"];
	end;

	CHATextFrameHeadline:SetText(headline);
	CHATextFrameContentLine:SetText(content);
	CHATextFrameBottomLine:SetText(bottom);
	CHATextFrameWhisperLine:SetText(whisper);

	if showWhisper then
		CHATextFrameCBWhisper:SetChecked(1);
	else
		CHATextFrameCBWhisper:SetChecked();
	end;
end;



--[[
	UI events
--]]
local CHA_TargetDropdownMenu_Operation = nil;

--	Called when "Add Target" button is clicked.
--	A popup with available targets must be shown/hidden.
function CHA_AddTargetOnClick()
	CHA_TargetDropdownMenu_Operation = "ADD";
	ToggleDropDownMenu(1, nil, CHA_TargetDropdownMenu, "cursor", 3, -3);
end;

--	Called when a target was selected in the TargetSymbol dropdown.
--	A new target must be added to the list of existing targets.
function CHA_TargetDropdownClick(self, resource)
	if CHA_TargetDropdownMenu_Operation == "REPLACE" then
		local template = CHA_GetActiveTemplate();
		if template then
			local target = template["targets"][CHA_CurrentTargetIndex];
			if target then
				target["name"] = resource["name"];
				target["mask"] = resource["mask"];
				target["text"] = resource["text"];
				target["icon"] = resource["icon"];
				target["color"] = resource["color"];
			end;
		end;
	elseif CHA_TargetDropdownMenu_Operation == "ADD" then
		CHA_CreateTarget(resource);
	end;	

	CHA_UpdateResourceFrames();
	CHA_UpdateAnnounceButton();
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
			ToggleDropDownMenu(1, nil, CHA_TemplateOptionsMenu, "cursor", 3, -3);
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
function CHA_TemplateOptionsMenu_MoveUp()
	if CHA_CurrentTemplateIndex > 1 then
		CHA_SwapTemplates(CHA_CurrentTemplateIndex - 1);
		CHA_UpdateUI();
	end;
end;

--	Called when the Template:MoveDown is selected.
--	Template is switching position with the next template.
function CHA_TemplateOptionsMenu_MoveDown(...)
	if CHA_CurrentTemplateIndex < table.getn(CHA_Templates) then
		CHA_SwapTemplates(CHA_CurrentTemplateIndex);
		CHA_UpdateUI();
	end;
end;

--	Called when the Template:Clone is selected.
--	A popup is shown, letting the user enter a name for the new template.
--	CHA_CurrentTemplateOperation is set so we know what to do when popup close.
function CHA_TemplateOptionsMenu_Clone()
	local template = CHA_GetTemplateById(CHA_CurrentTemplateIndex);
	CHA_CurrentTemplateOperation = "CLONE";

	StaticPopup_Show("CHA_DIALOG_ADDTEMPLATE", template["templatename"]);
end;

--	Called when the Template:Rename is selected.
--	A popup is shown, letting the user enter a new name for the template.
--	CHA_CurrentTemplateOperation is set so we know what to do when popup close.
function CHA_TemplateOptionsMenu_Rename()
	local template = CHA_GetTemplateById(CHA_CurrentTemplateIndex);
	CHA_CurrentTemplateOperation = "RENAME";

	StaticPopup_Show("CHA_DIALOG_ADDTEMPLATE", template["templatename"]);
end;

--	Called when the Template:Delete is selected.
--	A popup is shown, asking if user really wants to do this!
function CHA_TemplateOptionsMenu_Delete()
	local template = CHA_GetTemplateById(CHA_CurrentTemplateIndex);

	A.ShowConfirmation(string.format("Really delete the template '%s'?", template["templatename"]), CHA_TemplateOptionsMenu_Delete_OK);
end;

--	Called when the OK button on the Template:Delete popup was clicked.
--	Template is deleted, and if it was the active template, the active template is reset.
function CHA_TemplateOptionsMenu_Delete_OK()
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
local CHA_HealerDropdownMenu_Operation = nil;
function CHA_AddHealerButtonOnClick(sender)
	local buttonName = sender:GetName();
	local _, _, index, _ = string.find(buttonName, "addhealerbutton_(%d*)");

	CHA_CurrentTargetIndex = tonumber(index);
	CHA_HealerDropdownMenu_Operation = "ADD";
	ToggleDropDownMenu(1, nil, CHA_HealerDropdownMenu, "cursor", 3, -3);
end;

--	Called when an assigned Healer is clicked.
--	A popup menu lets the user select healer options.
function CHA_HealerButtonOnClick(sender)
	local buttonName = sender:GetName();
	local buttonType = GetMouseButtonClicked();

	local _, _, targetIndex, healerIndex = string.find(buttonName, "healerbutton_(%d*)_(%d*)");
	CHA_CurrentTargetIndex = tonumber(targetIndex);
	CHA_CurrentHealerIndex = tonumber(healerIndex);

	if buttonType == "RightButton" then
		--	Right button: Options (move up, down, rename, unassign(delete))
		ToggleDropDownMenu(1, nil, CHA_HealerOptionsMenu, "cursor", 3, -3);
	else
		--	Left button: Change target
		CHA_HealerDropdownMenu_Operation = "REPLACE";
		ToggleDropDownMenu(1, nil, CHA_HealerDropdownMenu, "cursor", 3, -3);
	end;

end;

--	Called when the (add/Replace) Healer dropdown is selected.
function CHA_HealerDropdownClick(sender, playerInfo)
	local template = CHA_GetActiveTemplate();
	if not template then return; end;

	local target = template["targets"][CHA_CurrentTargetIndex];
	if not target then
		--	This is unset if no target is made (this can't really happen I guess)
		target = { };
	end;

	if not target["healers"] then
		--	This is unset if Player is the first assigned. (This can happen!)
		target["healers"] = { };
	end;
	
	if CHA_HealerDropdownMenu_Operation == "REPLACE" then
		target["healers"][CHA_CurrentHealerIndex] = playerInfo;
	elseif CHA_HealerDropdownMenu_Operation == "ADD" then
		tinsert(target["healers"], playerInfo);
	end;	

	CHA_UpdateResourceFrames();
	CHA_UpdateHealerCounter();
end;

--	Called when Assigned Player:MoveUp is clicked:
--	Player is moved "up" to the previous target.
function CHA_HealerOptionsMenu_MoveUp()
	if CHA_CurrentTargetIndex > 1 then
		CHA_MoveAssignedPlayer(CHA_CurrentHealerIndex, CHA_CurrentTargetIndex, CHA_CurrentTargetIndex - 1);
		CHA_UpdateResourceFrames();
	end;
end;

--	Called when Assigned Player:MoveDown is clicked:
--	Player is moved "down" to the next target.
function CHA_HealerOptionsMenu_MoveDown()
	local template = CHA_GetActiveTemplate();
	if not template then return; end;

	if CHA_CurrentTargetIndex < table.getn(template["targets"]) then
		CHA_MoveAssignedPlayer(CHA_CurrentHealerIndex, CHA_CurrentTargetIndex, CHA_CurrentTargetIndex + 1);
		CHA_UpdateResourceFrames();
	end;
end;

--	Rename a healer (player/symbol)
local CHA_ResourceType = nil;
function CHA_HealerOptionsMenu_Rename()
	local template = CHA_GetActiveTemplate();
	if not template then return; end;

	local target = template["targets"][CHA_CurrentTargetIndex];
	if not target then return; end;

	local healer = target["healers"][CHA_CurrentHealerIndex];
	if not healer then return; end;

	CHA_ResourceType = CHA_ROLE_HEALER;

	StaticPopup_Show("CHA_DIALOG_RENAME_RESOURCE", healer["text"]);
end;

function CHA_RenameResource_OK(oldName, newName)
	local template = CHA_GetActiveTemplate();
	if not template then return; end;

	local target = template["targets"][CHA_CurrentTargetIndex];
	if not target then return; end;

	if CHA_ResourceType == CHA_ROLE_HEALER then
		local healer = target["healers"][CHA_CurrentHealerIndex];
		if not healer then return; end;

		healer["text"] = newName;
	elseif CHA_ResourceType == CHA_ROLE_TANK then
		target["text"] = newName;
	end;
	
	CHA_UpdateResourceFrames();
end;


--	Called when Assigned Player:unassign is clicked:
--	Player is unassigned(removed), but spot is preserved.
function CHA_HealerOptionsMenu_Unassign()
	local template = CHA_GetActiveTemplate();
	if not template then return; end;

	local target = template["targets"][CHA_CurrentTargetIndex];
	if not target or not target["healers"] then return; end;

	local healer = target["healers"][CHA_CurrentHealerIndex];
	if healer then
		for _, resource in next, CHA_ResourceMatrix do
			if resource["mask"] == CHA_RESOURCE_UNASSIGNED then
				healer["name"] = resource["name"];
				healer["mask"] = resource["mask"];
				healer["text"] = resource["text"];
				healer["icon"] = resource["icon"];
				healer["color"] = resource["color"];
				break;
			end;
		end;

	end;

	CHA_UpdateResourceFrames();
	CHA_UpdateHealerCounter();
	CHA_UpdateAnnounceButton();
end;

--	Called when Assigned Player:Delete is clicked:
--	Player is deleted(removed).
--	This does NOT trigger a popup, thats intentional to keep # of popups a little down!
function CHA_HealerOptionsMenu_Delete()
	local template = CHA_GetActiveTemplate();
	if not template then return; end;

	local target = template["targets"][CHA_CurrentTargetIndex];
	if not target or not target["healers"] then return; end;

	if target["healers"][CHA_CurrentHealerIndex] then
		target["healers"][CHA_CurrentHealerIndex] = nil;
		target["healers"] = A.RenumberTable(target["healers"]);
	end;

	CHA_UpdateResourceFrames();
	CHA_UpdateHealerCounter();
	CHA_UpdateAnnounceButton();
end;

--	Called when Target:MoveUp dropdown option is seleted:
--	Exchange position with previous target.
function CHA_TargetOptionsMenu_MoveUp()
	if CHA_CurrentTargetIndex > 1 then
		CHA_SwapTargets(CHA_CurrentTargetIndex - 1, CHA_CurrentTargetIndex);
		CHA_UpdateResourceFrames();
	end;
end;

--	Called when Target:MoveDown dropdown option is seleted:
--	Exchange position with next target.
function CHA_TargetOptionsMenu_MoveDown()
	local template = CHA_GetActiveTemplate();
	if template then
		if CHA_CurrentTargetIndex < table.getn(template["targets"]) then
			CHA_SwapTargets(CHA_CurrentTargetIndex, CHA_CurrentTargetIndex + 1);
			CHA_UpdateResourceFrames();
		end;
	end;
end;

--	Called when Target:Rename dropdown option is seleted:
--	Shop popup with name editbox.
function CHA_TargetOptionsMenu_Rename()
	local template = CHA_GetActiveTemplate();
	if template and template["targets"][CHA_CurrentTargetIndex] then
		local target = template["targets"][CHA_CurrentTargetIndex];
		CHA_ResourceType = CHA_ROLE_TANK;

		StaticPopup_Show("CHA_DIALOG_RENAME_RESOURCE", target["text"]);
	end;
end;

--	Called when Target:Rename edit dialog closes successfully.
--	Do the name change.
--	Note: we only change the "text" property; the internal name remains untouched.
function CHA_RenameTarget_OK(oldTargetName, newTargetName)
	local template = CHA_GetActiveTemplate();
	if template and template["targets"][CHA_CurrentTargetIndex] then
		template["targets"][CHA_CurrentTargetIndex]["text"] = newTargetName;
		CHA_UpdateResourceFrames();
	end;
end;

--	Called when Target:Unassign dropdown option is seleted.
--	Unassign vs Delete: 
--		Unassign sets the spot as "Unassigned".
--		Delete removes the tank and the "spot".
--	Shop popup for confirmation.
function CHA_TargetOptionsMenu_Unassign()
	local template = CHA_GetActiveTemplate();
	if template and template["targets"][CHA_CurrentTargetIndex] then
		local target = template["targets"][CHA_CurrentTargetIndex];

		A.ShowConfirmation(string.format("Really unassign the tank '%s'?", target["text"] or ""), CHA_TargetOptionsMenu_Unassign_OK);
	end;
end;

--	Called when Target:Unassign dropdown option closes with OK:
--	Unassign the target.
function CHA_TargetOptionsMenu_Unassign_OK()
	local template = CHA_GetActiveTemplate();
	if template and template["targets"][CHA_CurrentTargetIndex] then
		local target = template["targets"][CHA_CurrentTargetIndex];

		for _, resource in next, CHA_ResourceMatrix do
			if resource["mask"] == CHA_RESOURCE_UNASSIGNED then
				target["name"] = resource["name"];
				target["mask"] = resource["mask"];
				target["text"] = resource["text"];
				target["icon"] = resource["icon"];
				target["color"] = resource["color"];
				break;
			end;
		end;

		CHA_UpdateResourceFrames();
		CHA_UpdateHealerCounter();
		CHA_UpdateAnnounceButton();
	end;
end;

--	Called when Target:Delete dropdown option is seleted:
--	Shop popup for confirmation.
function CHA_TargetOptionsMenu_Delete()
	local template = CHA_GetActiveTemplate();
	if template and template["targets"][CHA_CurrentTargetIndex] then
		local target = template["targets"][CHA_CurrentTargetIndex];

		A.ShowConfirmation(string.format("Really remove the target '%s'?", target["text"] or ""), CHA_TargetOptionsMenu_Delete_OK);
	end;
end;

--	Called when Target:Delete dropdown option closes with OK:
--	Delete the target.
function CHA_TargetOptionsMenu_Delete_OK()
	local template = CHA_GetActiveTemplate();
	if template and template["targets"][CHA_CurrentTargetIndex] then
		template["targets"][CHA_CurrentTargetIndex] = nil;
		template["targets"] = A.RenumberTable(template["targets"]);

		CHA_UpdateResourceFrames();
		CHA_UpdateHealerCounter();
		CHA_UpdateAnnounceButton();
	end;
end;

--	Called when a Target is clicked.
--	Left-click: ... unsure what to do really! Show right-click popup for now.
--	Right-click: Open options popup
function CHA_TargetButtonOnClick(sender)
	local buttonName = sender:GetName();
	local buttonType = GetMouseButtonClicked();
	local _, _, index, _ = string.find(buttonName, "targeticon_(%d*)");

	if index then
		CHA_CurrentTargetIndex = tonumber(index);

		if buttonType == "RightButton" then
			ToggleDropDownMenu(1, nil, CHA_TargetOptionsMenu, "cursor", 3, -3);
		else
			--	What happens when clicking on a Target? Swap target!
			CHA_TargetDropdownMenu_Operation = "REPLACE";
			ToggleDropDownMenu(1, nil, CHA_TargetDropdownMenu, "cursor", 3, -3);
		end;
	end;
end;

--	Called when user clicks the CLEAN UP button:
function CHA_KickDisconnectsOnClick()
	A.ShowConfirmation("Do you want to kick all disconnected characters and characters not in the raid?", CHA_KickDisconnects_OK);
end;

function CHA_ResetAllOnClick()
	A.ShowConfirmation("Do you want to reset (delete) all targets and healers for this template?", CHA_ResetAll_OK);
end;

--	Cleanup the assignments by removing all characters not in the raid or disconnected characters.
function CHA_KickDisconnects_OK()
	local template = CHA_GetActiveTemplate();
	if not template or not template["targets"] then return; end;

	--	Iterate over all targets, then players in each target:
	local unitid;
	for targetIndex, target in next, template["targets"] do
		if target["healers"] then
			for healerIndex, healer in next, target["healers"] do
				if bit.band(healer["mask"], CHA_RESOURCE_PLAYERS) > 0 then
					unitid = A.GetUnitidFromName(healer["name"]);
		
					if not unitid or not UnitIsConnected(unitid) then
						target["healers"][healerIndex] = nil;
						target["healers"] = A.RenumberTable(target["healers"]);
					end;
				end;
			end;
		end;

		if bit.band(target["mask"], CHA_RESOURCE_PLAYERS) > 0 then
			--	This is a player: kick unless online and in raid!
			unitid = A.GetUnitidFromName(target["name"]);
		
			if not unitid or not UnitIsConnected(unitid) then
				template["targets"][targetIndex] = nil;
				template["targets"] = A.RenumberTable(template["targets"]);
			end;
		end;
	end;

	CHA_UpdateUI();
end;

--	Reset current template: all targets and healers are wiped!
function CHA_ResetAll_OK()
	local template = CHA_GetActiveTemplate();
	if template then
		template["targets"] = { };
	end;

	CHA_UpdateUI();
end;

--	Called when user clicks the ChangeText button:
--	The text configuration window opens.
function CHA_ChangeTextsOnClick()
	CHA_OpenTextConfigDialogue();
end;

--	Called when user clicks the Include Whisper checkbox.
function CHA_WhisperCheckboxOnClick()
	local template = CHA_GetActiveTemplate();
	if template then
		template["showwhispertext"] = CHATextFrameCBWhisper:GetChecked();

		--	TODO: Implement!
		if CHATextFrameCBWhisper:GetChecked() then
			A.Echo("Note! Whisper handling has not yet been implemented.");
		end;
	end;
end;




--[[
	Template functions
--]]

--	Swap template with the next template in the list.
--	The entire template (including healers) is swapped.
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

	if not CHA_GetTemplateByName(oldTemplateName) then
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

--	Initialize the Target dropdown menu.
function CHA_TargetDropdown_Initialize(frame, level, menuList)
	local template = CHA_GetActiveTemplate();
	if not template then 
		return; 
	end;

	local targets = CHA_GetResourcesByMask(template["targetmask"]);

	for targetIndex = 1, table.getn(targets), 1 do
		local info = UIDropDownMenu_CreateInfo();
		info.notCheckable = true;
		info.text       = targets[targetIndex]["text"];
		info.icon		= targets[targetIndex]["icon"];
		info.func       = function() CHA_TargetDropdownClick(this, targets[targetIndex]) end;
		UIDropDownMenu_AddButton(info);
	end
end;

--	Create a new Target and add to the bottom of the list of current targets.
function CHA_CreateTarget(target)
	local template = CHA_GetActiveTemplate();
	if not template then return; end;

	tinsert(template["targets"], target);

	CHA_UpdateResourceFrames();
end;



--[[
	UI Initialization functions
--]]

--	UI Initlialization entry
function CHA_InitializeUI()
	CHA_SourceCreateClassIcons();
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
		local fTargetButtonName = string.format("addhealerbutton_%d", index);
		local fTargetButton = CreateFrame("Button", fTargetButtonName, fTarget, "UIPanelButtonTemplate");
		fTargetButton:SetPoint("LEFT", 120, 0);
		fTargetButton:SetHeight(12);
		fTargetButton:SetWidth(12);
		fTargetButton:SetText("+");
		fTargetButton:SetScript("OnClick", CHA_AddHealerButtonOnClick);

		fTarget:Show();
		frameY = frameY - fInnerHeight;


		--	HEALER frame: Each frame can have up to CHA_FRAME_MAXPLAYERS healers assigned.
		local posX = playerOffset;
		local posY = 0;
		for healerIndex = 1, CHA_FRAME_MAXPLAYERS, 1 do
			--	And an ability to ADD a new Player for that specific target:
			local fHealerButtonName = string.format("healerbutton_%d_%d", index, healerIndex);
			local fHealerButton = CreateFrame("Button", fHealerButtonName, fTarget, "CHAPlayerButtonTemplate");
			fHealerButton:SetPoint("LEFT", posX, posY);
			fHealerButton:SetHeight(playerHeight-1);
			fHealerButton:SetWidth(playerWidth-1);
			_G[fHealerButton:GetName().."Caption"]:SetText("");

			posX = posX + playerWidth;
			if healerIndex == playersPerRow then
				posX = playerOffset;
				posY = posY - playerHeight;
			end;
		end;
	end;
end;

--	Initialize the Player dropdown by populating it with players
--	eligible for assignment for the particular role.
function CHA_HealerDropdown_Initialize()
	local template = CHA_GetActiveTemplate();
	if not template then return; end;

	local healers = CHA_GetResourcesByMask(template["healermask"]);

	for healerIndex = 1, table.getn(healers), 1 do
		local info = UIDropDownMenu_CreateInfo();
		info.notCheckable = true;
		info.text       = healers[healerIndex]["text"];
		info.icon		= healers[healerIndex]["icon"];
		info.func       = function() CHA_HealerDropdownClick(this, healers[healerIndex]) end;
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
		UIDropDownMenu_SetText(CHATextFrameChannelDropDown, caption);
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

--	Check the configured channel and use that if set.
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
	local template = CHA_GetActiveTemplate();
	if not template then return; end;

	playerIndex = tonumber(playerIndex);
	startTargetIndex = tonumber(startTargetIndex);
	endTargetIndex = tonumber(endTargetIndex);

	local sourceTarget = template["targets"][startTargetIndex];
	local destTarget = template["targets"][endTargetIndex];
	if not sourceTarget or not destTarget then return; end;

	if not destTarget["healers"] then 
		destTarget["healers"] = { }; 
	end;

	if sourceTarget["healers"][playerIndex] then
		tinsert(destTarget["healers"], sourceTarget["healers"][playerIndex]);

		sourceTarget["healers"][playerIndex] = nil;
		sourceTarget["healers"] = A.RenumberTable(sourceTarget["healers"]);

		CHA_UpdateResourceFrames();
	end;
end;

--	Fetch all available resources (healers/targets) by the current mask.
function CHA_GetResourcesByMask(resourceMask)
	local selected = { };

	--	CHA_RESOURCE_UNASSIGNED is "mandatory":
	--	For obvious reason there is no duplicate check on this!
	for _, symbol in next, CHA_ResourceMatrix do
		if symbol["mask"] == CHA_RESOURCE_UNASSIGNED then
			tinsert(selected, {
				["name"] = symbol["name"],
				["mask"] = symbol["mask"],
				["text"] = symbol["text"],
				["icon"] = symbol["icon"],
				["color"] = symbol["color"],
			});
			break;
		end;
	end;

	local players = CHA_GetPlayersInRoster();
	for _, player in next, players do
		if bit.band(player["mask"], resourceMask) > 0 then
			if not CHA_IsResourceAssigned(player["name"]) then
				tinsert(selected, player);
			end;
		end;
	end;

	if bit.band(CHA_RESOURCE_SYMBOLS, resourceMask) > 0 then
		--	Add SYMBOLS:
		for symbolIndex, symbol in next, CHA_ResourceMatrix do
			if not CHA_IsResourceAssigned(symbol["name"]) then
				if bit.band(resourceMask, symbol["mask"]) > 0 then
					tinsert(selected, CHA_ResourceMatrix[symbolIndex]);
				end;
			end;
		end;
	end;

	return selected;
end;

--	Check if a healer (either a player or an icon) is already used in
--	other assignments. That includes "as target" and "as healer".
function CHA_IsResourceAssigned(resourceName)
	local template = CHA_GetActiveTemplate();
	if template then
		for _, target in next, template["targets"] do
			if target["name"] == resourceName then
				return true;
			end;

			if target["healers"] then
				for _, healer in next, target["healers"] do
					if healer["name"] == resourceName then
						return true;
					end;
				end;
			end;
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

--	Swap targets (Healers are swapped with them!)
function CHA_SwapTargets(firstIndex)
	local template = CHA_GetActiveTemplate();
	if template then
		local targetA = template["targets"][firstIndex];
		template["targets"][firstIndex] = template["targets"][firstIndex + 1];
		template["targets"][firstIndex + 1] = targetA;
	end;
end;




--[[
	CHA business logic
--]]

--	TODO: This counter needs some re-thinking! :-<
function CHA_UpdateHealerCounter()
	local numPlayers = 0;
	local numAssigned = 0;

	local template = CHA_GetActiveTemplate();
	if template then
		local healerMask = bit.band(template["healermask"], CHA_RESOURCE_PLAYERS);

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
				if bit.band(classInfo["mask"], healerMask) > 0 then
					numPlayers = numPlayers + 1;
				end;
			end
		else
			local classInfo = CHA_ClassMatrix[A.UnitClass("player")];
			if bit.band(classInfo["mask"], healerMask) > 0 then
				numPlayers = 1;
			end;
		end;

		--	Assigned targets:
		for _, target in next, template["targets"] do
			if target["healers"] then
				for _, healer in next, target["healers"] do
					if bit.band(healer["mask"], healerMask) > 0 then
						numAssigned = numAssigned + 1;
					end;
				end;
			end;
		end;
	end;

	CHAHealerCountCaption:SetText(string.format("Healers: %s/%s", numAssigned, numPlayers));
end



--[[
	Template logic
--]]

--	As name says: returns the current active template / nil for none.
--	Path: //templates/
function CHA_GetActiveTemplate()
	return CHA_GetTemplateByName(CHA_ActiveTemplate);
end;

--	Add a new Template to the template array
function CHA_CreateTemplate(templateName)
	local templateCount = table.getn(CHA_Templates);

	if templateCount < CHA_TEMPLATES_MAX then
		templateCount = templateCount + 1;

		CHA_Templates[templateCount] = {
			["templatename"]	= templateName,
			["headlinetext"]	= "__/\\___/\\__ HEALER Assignments :",
			["contenttext"]		= " * {TARGET} -==- {ASSIGNMENTS}",
			["bottomtext"]		= "All other healers: Heal the raid.",
			["whispertext"]		= "Whisper me Repeat to re-send assignments.",
			["showwhispertext"] = false,
			["targetmask"]		= CHA_MASK_TARGET_DEFAULT,
			["healermask"]		= CHA_MASK_HEALER_DEFAULT,
			["targets"]			= { },
		};
	end;
	return templateCount;
end;

--	Return template by name, nil if none was found.
function CHA_GetTemplateByName(templateName)
	for _, template in next, CHA_Templates do
		if template["templatename"] == templateName then
			return template;
		end;
	end;

	return nil;
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

--	Import a Template:
function CHA_ImportTemplateData(template)
	local templateName = template["templatename"];
	if not templateName then return; end;

	--	This creates the template with default setup data:
	local tpl = CHA_Templates[CHA_CreateTemplate(templateName)];

	if template["headlinetext"] and type(template["headlinetext"]) == "string" then
		tpl["headlinetext"] = template["headlinetext"];
	end;

	if template["contenttext"] and type(template["contenttext"]) == "string" then
		tpl["contenttext"] = template["contenttext"];
	end;

	if template["bottomtext"] and type(template["bottomtext"]) == "string" then
		tpl["bottomtext"] = template["bottomtext"];
	end;

	if template["whispertext"] and type(template["whispertext"]) == "string" then
		tpl["whispertext"] = template["whispertext"];
	end;

	if template["showwhispertext"] and type(template["showwhispertext"]) == "boolean" then
		tpl["showwhispertext"] = template["showwhispertext"];
	end;

	if template["targetmask"] and type(template["targetmask"]) == "number" then
		tpl["targetmask"] = template["targetmask"];
	end;

	if template["healermask"] and type(template["healermask"]) == "number" then
		tpl["healermask"] = template["healermask"];
	end;


	--	This will import last used targets.
	--	Players might even not be in the raid anymore. We will handle that later!
	if template["targets"] then
		if type(template["targets"]) == "table" and table.getn(template["targets"]) > 0 then
			--//Templates/targets/<targetIndex>
			for _, target in next, template["targets"] do
				local tName = target["name"];
				local tMask = target["mask"];
				local tText = target["text"];
				local tIcon = target["icon"];

				if tMask and tName and tIcon and tText then
					local tHealers = { };
					local healers = target["healers"];

					if type(healers) == "table" and table.getn(healers) > 0 then
						--//Templates/targets/<targetIndex>/healers/<playerIndex>
						for _, healer in next, healers do
							local pName = healer["name"];
							local pMask = healer["mask"];
							local pText = healer["text"];
							local pIcon = healer["icon"];
							local pClass = healer["class"];

							if pName and pMask and pText and pIcon then
								tinsert(tHealers, { 
									["name"] = pName, 
									["mask"] = pMask, 
									["text"] = pText, 
									["icon"] = pIcon, 
									["class"] = pClass, 
								});
							end;
						end;
					end;

					tinsert(tpl["targets"], { 
						["name"] = tName, 
						["mask"] = tMask, 
						["text"] = tText, 
						["icon"] = tIcon, 
						["healers"] = tHealers,
					});
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

--	Shout, shoud, shout it all out! (test your announcement locally!)
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

	local template = CHA_GetActiveTemplate();
	if not template then return; end;

	local targetCount = table.getn(template["targets"] or { });
	if targetCount == 0 then
		return;
	end;

	local headline = CHATextFrameHeadline:GetText();
	local content = CHATextFrameContentLine:GetText();
	local bottom = CHATextFrameBottomLine:GetText();
	local whisper = CHATextFrameWhisperLine:GetText();
	local showWhisper = CHATextFrameCBWhisper:GetChecked();

	if headline ~= "" then
		tinsert(announcements, headline);
	end;

	local targetName, resourceName;
	--	Iterate over targets ("tanks")
	for tIndex, target in next, template["targets"] do
		local targetName = target["text"];
		if bit.band(target["mask"], CHA_RESOURCE_RAIDICON) > 0 then
			--	Raid icons must be rendered using their icon, which is stored as the "name" property.
			--	Internal note: this does not work locally, only in channels!
			targetName = target["name"];
		end;

		--	Each "tank" can have up to 8 healers:
		local assigned = "";
		for pIndex, healer in next, target["healers"] do
			if bit.band(healer["mask"], CHA_RESOURCE_UNASSIGNED) == 0 then
				if assigned ~= "" then
					assigned = assigned ..", ";
				end;

				resourceName = healer["text"];
				if bit.band(healer["mask"], CHA_RESOURCE_RAIDICON) > 0 then
					resourceName = healer["name"];
				end;

				assigned = assigned .. resourceName;
			end;
		end;

		local assignments = content;
		assignments = string.gsub(assignments, "{TARGET}", targetName);
		assignments = string.gsub(assignments, "{ASSIGNMENTS}", assigned);

		tinsert(announcements, assignments);
	end;

	if bottom ~= "" then
		tinsert(announcements, bottom);
	end;

	if showWhisper and whisper ~= "" then
		tinsert(announcements, whisper);
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
		CHA_UpdateResourceFrames();

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


