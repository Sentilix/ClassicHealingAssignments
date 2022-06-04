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
local CHA_TEMPLATES_MAX						= 15;	-- room for max 15 templates. This is a limitation on the frame UI.
local CHA_COLOR_SELECTED					= {1.0, 1.0, 1.0};
local CHA_COLOR_UNSELECTED					= {1.0, 0.8, 0.0};
local CHA_ALPHA_ENABLED						= 1.0;
local CHA_ALPHA_DISABLED					= 0.3;

local CHA_CLASS_DRUID			= 0x0001;
local CHA_CLASS_HUNTER			= 0x0002;
local CHA_CLASS_MAGE			= 0x0004;
local CHA_CLASS_PALADIN			= 0x0008;
local CHA_CLASS_PRIEST			= 0x0010;
local CHA_CLASS_ROGUE			= 0x0020;
local CHA_CLASS_SHAMAN			= 0x0040;
local CHA_CLASS_WARLOCK			= 0x0080;
local CHA_CLASS_WARRIOR			= 0x0100;
local CHA_CLASS_DEATHKNIGHT		= 0x0200;

local CHA_ROLE_NONE				= 0x00;
local CHA_ROLE_TANK				= 0x01;
local CHA_ROLE_HEAL				= 0x02;
local CHA_ROLE_DECURSE			= 0x04;

local CHA_ROLE_DEFAULT_TANK		= CHA_CLASS_DRUID + CHA_CLASS_WARRIOR;
local CHA_ROLE_DEFAULT_HEAL		= CHA_CLASS_DRUID + CHA_CLASS_PALADIN + CHA_CLASS_PRIEST + CHA_CLASS_SHAMAN;
local CHA_ROLE_DEFAULT_DECURSE	= CHA_CLASS_DRUID + CHA_CLASS_MAGE;



--	Local variables:
local CHA_CurrentVersion					= 0;
local CHA_Expansionlevel					= 0;
local CHA_UpdateMessageShown				= false;
local CHA_IconMoving						= false;
local CHA_CurrentTemplateIndex				= 0;
local CHA_CurrentTemplateOperation			= "";

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
local CHA_TankAsDruid						= true;		-- Druids are viable tanks in vanilla: add to tank list as default
local CHA_Templates							= { };
--[[
	Template: a table of template objects with:
		"NAME": Unique name of the template
		"TANKMASK": bitmask for classes assigned for Tanking
		"HEALMASK": bitmask for classes assigned for Healing
		"DECURSEMASK": bitmask for classes assigned for Decursing
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

local CHA_TemplateDropdownMenu = CreateFrame("FRAME", "CHA_TemplateDropdownMenuFrame", UIParent, "UIDropDownMenuTemplate");
CHA_TemplateDropdownMenu:SetPoint("CENTER");
CHA_TemplateDropdownMenu:Hide();
UIDropDownMenu_SetWidth(CHA_TemplateDropdownMenu, 1);
UIDropDownMenu_SetText(CHA_TemplateDropdownMenu, "");

UIDropDownMenu_Initialize(CHA_TemplateDropdownMenu, function(self, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	info.text = "Move up";
	info.func = CHA_TemplateDropdownMenu_MoveUp;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Move down";
	info.func = CHA_TemplateDropdownMenu_MoveDown;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Copy template";
	info.func = CHA_TemplateDropdownMenu_Clone;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Rename template";
	info.func = CHA_TemplateDropdownMenu_Rename;
	UIDropDownMenu_AddButton(info)

	info = UIDropDownMenu_CreateInfo()
	info.text = "Delete template";
	info.func = CHA_TemplateDropdownMenu_Delete;
	UIDropDownMenu_AddButton(info)
end);

--	Classes setup:
local CHA_ClassMatrix = { };
local CHA_CLASS_MATRIX_MASTER = {
	["DRUID"] = {
		["MASK"] = CHA_CLASS_DRUID,
		["ICONID"] = 625999,
		["ROLE"] = CHA_ROLE_TANK + CHA_ROLE_HEAL + CHA_ROLE_DECURSE,
	},
	["HUNTER"] = {
		["MASK"] = CHA_CLASS_HUNTER,
		["ICONID"] = 626000,
		["ROLE"] = CHA_ROLE_NONE,
	},
	["MAGE"] = {
		["MASK"] = CHA_CLASS_MAGE,
		["ICONID"] = 626001,
		["ROLE"] = CHA_ROLE_DECURSE,
	},
	["PALADIN"] = {
		["MASK"] = CHA_CLASS_PALADIN,
		["ICONID"] = 626003,
		["ALLIANCE-EXPAC"] = 1,
		["HORDE-EXPAC"] = 2,
		["ROLE"] = CHA_ROLE_NONE,	-- Paladin role is set during initialization since it depends on expac.
	},
	["PRIEST"] = {
		["MASK"] = CHA_CLASS_PRIEST,
		["ICONID"] = 626004,
		["ROLE"] = CHA_ROLE_HEAL,
	},
	["ROGUE"] = {
		["MASK"] = CHA_CLASS_ROGUE,
		["ICONID"] = 626005,
		["ROLE"] = CHA_ROLE_NONE,
	},
	["SHAMAN"] = {
		["MASK"] = CHA_CLASS_SHAMAN,
		["ICONID"] = 626006,
		["ALLIANCE-EXPAC"] = 2,
		["HORDE-EXPAC"] = 1,
		["ROLE"] = CHA_ROLE_HEAL,
	},
	["WARLOCK"] = {
		["MASK"] = CHA_CLASS_WARLOCK,
		["ICONID"] = 626007,
		["ROLE"] = CHA_ROLE_NONE,
	},
	["WARRIOR"] = {
		["MASK"] = CHA_CLASS_WARRIOR,
		["ICONID"] = 626008,
		["ROLE"] = CHA_ROLE_TANK,
	},
	["DEATHKNIGHT"] = {
		["MASK"] = CHA_CLASS_DEATHKNIGHT,
		["ICONID"] = 135771,
		["ALLIANCE-EXPAC"] = 3,
		["HORDE-EXPAC"] = 3,
		["ROLE"] = CHA_ROLE_TANK,
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

	local template = CHA_GetActiveTemplate();
	if not template then
		return;
	end;

	local classInfo = CHA_ClassMatrix[className];

	if CHA_ActiveRole == CHA_ROLE_TANK then
		template["TANKMASK"] = bit.bxor(template["TANKMASK"], classInfo["MASK"]);
	elseif CHA_ActiveRole == CHA_ROLE_HEAL then
		template["HEALMASK"] = bit.bxor(template["HEALMASK"], classInfo["MASK"]);
	elseif CHA_ActiveRole == CHA_ROLE_DECURSE then
		template["DECURSEMASK"] = bit.bxor(template["DECURSEMASK"], classInfo["MASK"]);
	end;

	CHA_UpdateClassIcons();
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
				CHA_ActiveTemplate = template["NAME"];
			end;
			CHA_UpdateUI();
		end;
	end;
end;

function CHA_TemplateDropdownMenu_MoveUp()
	if CHA_CurrentTemplateIndex > 1 then
		CHA_SwapTemplates(CHA_CurrentTemplateIndex - 1, CHA_CurrentTemplateIndex);
		CHA_UpdateUI();
	end;
end;

function CHA_TemplateDropdownMenu_MoveDown(...)
	if CHA_CurrentTemplateIndex < table.getn(CHA_Templates) then
		CHA_SwapTemplates(CHA_CurrentTemplateIndex, CHA_CurrentTemplateIndex + 1);
		CHA_UpdateUI();
	end;
end;

function CHA_TemplateDropdownMenu_Clone()
	local template = CHA_GetTemplateById(CHA_CurrentTemplateIndex);
	local templateName = template["NAME"];
	CHA_CurrentTemplateOperation = "CLONE";

	StaticPopup_Show("CHA_DIALOG_ADDTEMPLATE", templateName);
end;

function CHA_TemplateDropdownMenu_Rename()
	local template = CHA_GetTemplateById(CHA_CurrentTemplateIndex);
	local templateName = template["NAME"];
	CHA_CurrentTemplateOperation = "RENAME";

	StaticPopup_Show("CHA_DIALOG_ADDTEMPLATE", templateName);
end;

function CHA_TemplateDropdownMenu_Delete()
	local template = CHA_GetTemplateById(CHA_CurrentTemplateIndex);
	local templateName = template["NAME"];

	DIGAM_ShowConfirmation(string.format("Really delete the template '%s'?", templateName), CHA_TemplateDropdownMenu_Delete_OK);
end;

function CHA_TemplateDropdownMenu_Delete_OK()
	local template = CHA_GetTemplateById(CHA_CurrentTemplateIndex);
	local templateName = template["NAME"];
	if CHA_ActiveTemplate == templateName then
		CHA_ActiveTemplate = nil;
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
		CHA_AddTemplate(templateName);
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
		CHA_Templates[index]["NAME"] = newTemplateName;

		if CHA_ActiveTemplate == oldTemplateName then
			CHA_ActiveTemplate = newTemplateName;
		end;
	elseif CHA_CurrentTemplateOperation == "CLONE" then
		--	Clone template to new (keep existing)
		local newIndex = CHA_AddTemplate(newTemplateName);

		local template = DIGAM_CloneTable(CHA_Templates[index]);
		template["NAME"] = newTemplateName;
		CHA_Templates[newIndex] = template;

		--	Move copy up below original table:
		for n = newIndex-1, index+1, -1 do
			CHA_SwapTemplates(n);
		end;
	end;

	CHA_UpdateUI();
end;
 
function CHA_IconMouseDown(...)
	local arg1 = ...;

	PlaySound(882, "Master")
	--CHA_IconMoving = false;

	if (arg1 == "LeftButton") then
		CHA_ToggleConfigurationDialogue();

	elseif (arg1 == "RightButton") then
		--HealingAsssignments:PostAssignments()

	else
		CHA_IconMoving = true;
	end
end

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

function CHA_InitializeUI()
	CHA_CreateClassIcons();
	CHA_CreateTemplateButtons();

	CHA_UpdateUI();
end;

function CHA_UpdateUI()
	CHA_UpdateClassIcons();
	CHA_UpdateRoleButtons();
	CHA_UpdateTemplates();
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
		entry:SetNormalTexture(classInfo["ICONID"]);
		entry:SetPushedTexture(classInfo["ICONID"]);

		posX = posX + width;
	end;
end;

--	Update class icons based on the current template + role:
function CHA_UpdateClassIcons()
	local template = CHA_GetActiveTemplate();
	local templateMask = 0x0000;

	if template then
		if CHA_ActiveRole == CHA_ROLE_TANK then
			templateMask = template["TANKMASK"];
		elseif CHA_ActiveRole == CHA_ROLE_HEAL then
			templateMask = template["HEALMASK"];
		elseif CHA_ActiveRole == CHA_ROLE_DECURSE then
			templateMask = template["DECURSEMASK"];
		end;
	end;

	for className, classInfo in next, CHA_ClassMatrix do
		local buttonName = string.format("classicon_%s", className);
		local entry = _G[buttonName];

		if bit.band(classInfo["MASK"], templateMask) > 0 then
			entry:SetAlpha(CHA_ALPHA_ENABLED);
		else
			entry:SetAlpha(CHA_ALPHA_DISABLED);
		end;
	end;
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

--	Add a new Template to the template array
function CHA_AddTemplate(templateName)
	local templateCount = table.getn(CHA_Templates);
	if templateCount < CHA_TEMPLATES_MAX then
		templateCount = templateCount + 1;
		CHA_Templates[templateCount] = {
			["NAME"] = templateName ,
			["TANKMASK"] = CHA_ROLE_DEFAULT_TANK,
			["HEALMASK"] = CHA_ROLE_DEFAULT_HEAL,
			["DECURSEMASK"] = CHA_ROLE_DEFAULT_DECURSE,
		};
	end;
	return templateCount;
end;

--	initialize profile names.
function CHA_CreateDefaultTemplates()
	CHA_Templates = { };

	CHA_AddTemplate("Default");

	if CHA_Expansionlevel == 1 then
		CHA_AddTemplate("Molten Core");
		CHA_AddTemplate("Onyxia's Lair");
		CHA_AddTemplate("Blackwing Lair");
		CHA_AddTemplate("Temple of Ahn'Qiraj");
		CHA_AddTemplate("Naxxramas");
		CHA_AddTemplate("20 man");
	end;

	if CHA_Expansionlevel == 2 then
		CHA_AddTemplate("Karazhan");
		CHA_AddTemplate("Serpentshrine Cavern");
		CHA_AddTemplate("The Eye");
		CHA_AddTemplate("Magtheridon");
		CHA_AddTemplate("Gruuls Lair");
		CHA_AddTemplate("Black Temple");
		CHA_AddTemplate("Mount Hyjal");
		CHA_AddTemplate("Sunwell");
	end;

	CHA_AddTemplate("Other");
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
			if CHA_Templates[n]["NAME"] == CHA_ActiveTemplate then
				textColor = CHA_COLOR_SELECTED;
			else
				textColor = CHA_COLOR_UNSELECTED;
			end;
			
			caption:SetTextColor(textColor[1], textColor[2], textColor[3]);
			caption:SetText(CHA_Templates[n]["NAME"]);
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
		if CHA_Templates[n]["NAME"] == templateName then
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

	if type(workTemplates) == "table" then
		--DIGAM_PrintAll(workTemplates);
		for key, template in next, workTemplates do
			local templateName = template["NAME"];
			if templateName then
				--	This creates the template with default setup data:
				local tpl = CHA_Templates[CHA_AddTemplate(templateName)];

				--	Read tank/healer/decursers from template and overwrite defaults if available:
				tpl["TANKMASK"] = template["TANKMASK"] or tpl["TANKMASK"];
				tpl["HEALMASK"] = template["HEALMASK"] or tpl["HEALMASK"];
				tpl["DECURSEMASK"] = template["DECURSEMASK"] or tpl["DECURSEMASK"];
			end;
		end;
	end;

	if table.getn(CHA_Templates) == 0 then
		CHA_CreateDefaultTemplates();
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
