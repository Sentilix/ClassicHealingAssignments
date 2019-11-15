
local GlobalHealerDropDownID -- use global variable to get ID into populate function
local GlobalTankDropDownID -- use global variable to get ID into populate function
HealingAsssignments.Raiddatabase = {} -- Database of raidmembers -> all 40


local CHA_NAME_LEFTSIDE	= "LEFT";
local CHA_NAME_RIGHTSIDE= "RIGHT";
local CHA_NAME_CUSTOM	= "CUSTOM";
local CHA_NAME_SKULL	= "SKULL";
local CHA_NAME_CROSS	= "CROSS";
local CHA_NAME_CIRCLE	= "CIRCLE";
local CHA_NAME_STAR		= "STAR";
local CHA_NAME_SQUARE	= "SQUARE";
local CHA_NAME_TRIANGLE	= "TRIANGLE";
local CHA_NAME_DIAMOND	= "DIAMOND";
local CHA_NAME_MOON		= "MOON";
local CHA_NAME_DRUID	= "DRUID";
local CHA_NAME_HUNTER	= "HUNTER";
local CHA_NAME_MAGE		= "MAGE";
local CHA_NAME_PALADIN	= "PALADIN";
local CHA_NAME_PRIEST	= "PRIEST";
local CHA_NAME_ROGUE	= "ROGUE";
local CHA_NAME_SHAMAN	= "SHAMAN";
local CHA_NAME_WARLOCK	= "WARLOCK";
local CHA_NAME_WARRIOR	= "WARRIOR";

-- { Normal, DropDown, UI form, Color }
local CHA_Names = {
	{ CHA_NAME_LEFTSIDE,	"<< Left side",		"<< Left side",		"FF0000" },
	{ CHA_NAME_RIGHTSIDE,	"Right side >>",	"Right side >>",	"00FF00" },
	{ CHA_NAME_CUSTOM,		CHA_NAME_CUSTOM,	CHA_NAME_CUSTOM,	"00FFC0" },
	{ CHA_NAME_SKULL,		"Skull",			"{skull}",			"FFFFFF" },
	{ CHA_NAME_CROSS,		"Cross",			"{cross}",			"FF0000" },
	{ CHA_NAME_CIRCLE,		"Circle",			"{circle}",			"FFA400" },
	{ CHA_NAME_STAR,		"Star",				"{star}",			"FFFF00" },
	{ CHA_NAME_SQUARE,		"Square",			"{square}",			"00A0FF" },
	{ CHA_NAME_TRIANGLE,	"Triangle",			"{triangle}",		"00FF00" },
	{ CHA_NAME_DIAMOND,		"Diamond",			"{diamond}",		"FF00FF" },
	{ CHA_NAME_MOON,		"Moon",				"{moon}",			"A0A0A0" },
	{ CHA_NAME_DRUID,		CHA_NAME_DRUID,		CHA_NAME_DRUID,		"FF7D0A" },
	{ CHA_NAME_HUNTER,		CHA_NAME_HUNTER,	CHA_NAME_HUNTER,	"ABD473" },
	{ CHA_NAME_MAGE,		CHA_NAME_MAGE,		CHA_NAME_MAGE,		"69CCF0" },
	{ CHA_NAME_PALADIN,		CHA_NAME_PALADIN,	CHA_NAME_PALADIN,	"F58CBA" },
	{ CHA_NAME_PRIEST,		CHA_NAME_PRIEST,	CHA_NAME_PRIEST,	"FFFFFF" },
	{ CHA_NAME_ROGUE,		CHA_NAME_ROGUE,		CHA_NAME_ROGUE,		"FFF569" },
	{ CHA_NAME_SHAMAN,		CHA_NAME_SHAMAN,	CHA_NAME_SHAMAN,	"F58CBA" },
	{ CHA_NAME_WARLOCK,		CHA_NAME_WARLOCK,	CHA_NAME_WARLOCK,	"9482C9" },
	{ CHA_NAME_WARRIOR,		CHA_NAME_WARRIOR,	CHA_NAME_WARRIOR,	"C79C6E" },
};

local CHA_SKULL_ICON = "{Skull}";
local CHA_SKULL_DBOX = "SKULL";
local CHA_CROSS_ICON = "{Cross}";
local CHA_CROSS_DBOX = "CROSS";
local CHA_CIRCLE_ICON = "{Circle}";
local CHA_CIRCLE_DBOX = "CIRCLE";
local CHA_STAR_ICON = "{Star}";
local CHA_STAR_DBOX = "STAR";
local CHA_SQUARE_ICON = "{Square}";
local CHA_SQUARE_DBOX = "SQUARE";
local CHA_TRIANGLE_ICON = "{Triangle}";
local CHA_TRIANGLE_DBOX = "TRIANGLE";
local CHA_DIAMOND_ICON = "{Diamond}";
local CHA_DIAMOND_DBOX = "DIAMOND";
local CHA_MOON_ICON = "{Moon}";
local CHA_MOON_DBOX = "MOON";


-- Called when writing a string to the console:
function HealingAsssignments:GetTextUIString(name)
	if string.sub(name, 1, 1) == "|" then
		-- Player-by-name; remove color info (10 chars): "|c00FFFFFF" + 2 chars: "|r"
		local nameStr = string.sub(name, 11);
		name = string.sub(nameStr, 1, string.len(nameStr) - 2);
	end;
	
	local names = HealingAsssignments:GetNames(name);
	if names then
		name = names[3];
	else
		name = "["..name.."]";
	end;

	return name;
end;

function HealingAsssignments:HexToRGB(hex)
	local rhex, ghex, bhex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6)
	return tonumber(rhex, 16)/256, tonumber(ghex, 16)/256, tonumber(bhex, 16)/256
end

function HealingAsssignments:GetNames(nameString)
	nameString = string.upper(nameString);

	for n=1, table.getn(CHA_Names) do
		if CHA_Names[n][1] == nameString then
			return CHA_Names[n];
		end;
	end;
	return nil;
end;



-- populate a specific tank dropdown
function HealingAsssignments.Mainframe:PopulateTankDropdown()

	local names;
	local OptionsFrame = 16
	local LeftsideCheck = HealingAsssignments.Mainframe.Foreground.Profile[1].Template[OptionsFrame].Assigments.Content.LeftsideCheckbox:GetChecked();
	local RightsideCheck = HealingAsssignments.Mainframe.Foreground.Profile[1].Template[OptionsFrame].Assigments.Content.RightsideCheckbox:GetChecked()
	local CustomCheckbox = HealingAsssignments.Mainframe.Foreground.Profile[1].Template[OptionsFrame].Assigments.Content.CustomCheckbox:GetChecked()
	

	local info = {};
	for i=1,table.getn(HealingAsssignments.Raiddatabase) do
		
		if HealingAsssignments.Raiddatabase[i].Class == "WARRIOR" or 
		(HealingAsssignments.Raiddatabase[i].Class == "WARLOCK" and HealingAsssignments.Mainframe.Foreground.Profile[1].Template[OptionsFrame].Assigments.Content.WarlockCheckbox:GetChecked()) or
		(HealingAsssignments.Raiddatabase[i].Class == "DRUID" and HealingAsssignments.Mainframe.Foreground.Profile[1].Template[OptionsFrame].Assigments.Content.DruidCheckbox:GetChecked()) or
		(HealingAsssignments.Raiddatabase[i].Class == "ROGUE" and HealingAsssignments.Mainframe.Foreground.Profile[1].Template[OptionsFrame].Assigments.Content.RogueCheckbox:GetChecked()) or
		(HealingAsssignments.Raiddatabase[i].Class == "HUNTER" and HealingAsssignments.Mainframe.Foreground.Profile[1].Template[OptionsFrame].Assigments.Content.HunterCheckbox:GetChecked()) or
		(HealingAsssignments.Raiddatabase[i].Class == "MAGE" and HealingAsssignments.Mainframe.Foreground.Profile[1].Template[OptionsFrame].Assigments.Content.MageCheckbox:GetChecked()) or
		(HealingAsssignments.Raiddatabase[i].Class == "SHAMAN" and HealingAsssignments.Mainframe.Foreground.Profile[1].Template[OptionsFrame].Assigments.Content.ShamanCheckbox:GetChecked()) or
		(HealingAsssignments.Raiddatabase[i].Class == "PRIEST" and HealingAsssignments.Mainframe.Foreground.Profile[1].Template[OptionsFrame].Assigments.Content.PriestCheckbox:GetChecked()) or
		(HealingAsssignments.Raiddatabase[i].Class == "PALADIN" and HealingAsssignments.Mainframe.Foreground.Profile[1].Template[OptionsFrame].Assigments.Content.PaladinCheckbox:GetChecked())
		then
			names = HealingAsssignments:GetNames(HealingAsssignments.Raiddatabase[i].Class);
			info.text = HealingAsssignments.Raiddatabase[i].Name
			info.colorCode = "|c00".. names[4];
			info.checked = false
			info.notCheckable = true
			info.func = function(self)
				UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())

				HealingAsssignments:UpdateRaidDataBase()
			end
			UIDropDownMenu_AddButton(info);
		end
	end

	local names;
	if LeftsideCheck then 
		names = HealingAsssignments:GetNames(CHA_NAME_LEFTSIDE);
		info.text = names[2];
		info.colorCode = "|c00".. names[4];
		info.checked = false
		info.notCheckable = true
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
	end
	
	if RightsideCheck then 
		names = HealingAsssignments:GetNames(CHA_NAME_RIGHTSIDE);
		info.text = names[2];
		info.colorCode = "|c00".. names[4];
		info.checked = false
		info.notCheckable = true
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
	end
	
	if CustomCheckbox then 
		names = HealingAsssignments:GetNames(CHA_NAME_CUSTOM);
		info.text = HealingAsssignments.Mainframe.Foreground.Profile[1].Template[OptionsFrame].Assigments.Content.CustomCheckboxText:GetText()
		info.colorCode = "|c00".. names[4];
		info.checked = false
		info.notCheckable = true
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
	end	

	-- Raid Marks for Tanks:
	if HealingAsssignments.Mainframe.Foreground.Profile[1].Template[16].Assigments.Content.TankRaidMarkCheckbox:GetChecked() then 
		info = UIDropDownMenu_CreateInfo();
		names = HealingAsssignments:GetNames(CHA_NAME_SKULL);
		info.text = names[2];
		info.colorCode = "|c00".. names[4];
		info.checked = false;
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- {Cross}
		info = UIDropDownMenu_CreateInfo();
		names = HealingAsssignments:GetNames(CHA_NAME_CROSS);
		info.text = names[2];
		info.colorCode = "|c00".. names[4];
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- {Circle}
		info = UIDropDownMenu_CreateInfo();
		names = HealingAsssignments:GetNames(CHA_NAME_CIRCLE);
		info.text = names[2];
		info.colorCode = "|c00".. names[4];
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- {Star}
		info = UIDropDownMenu_CreateInfo();
		names = HealingAsssignments:GetNames(CHA_NAME_STAR);
		info.text = names[2];
		info.colorCode = "|c00".. names[4];
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- 	{Square}
		info = UIDropDownMenu_CreateInfo();
		names = HealingAsssignments:GetNames(CHA_NAME_SQUARE);
		info.text = names[2];
		info.colorCode = "|c00".. names[4];
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- {Triangle}
		info = UIDropDownMenu_CreateInfo();
		names = HealingAsssignments:GetNames(CHA_NAME_TRIANGLE);
		info.text = names[2];
		info.colorCode = "|c00".. names[4];
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		--{Diamond}
		info = UIDropDownMenu_CreateInfo();
		names = HealingAsssignments:GetNames(CHA_NAME_DIAMOND);
		info.text = names[2];
		info.colorCode = "|c00".. names[4];
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- {Moon}
		info = UIDropDownMenu_CreateInfo();
		names = HealingAsssignments:GetNames(CHA_NAME_MOON);
		info.text = names[2];
		info.colorCode = "|c00".. names[4];
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
	end



	-- create emtpy field to deleting
	info = UIDropDownMenu_CreateInfo();
	info.text = " "
	info.checked = false
	info.notCheckable = true;
	info.func = function(self)
		UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())
		HealingAsssignments:UpdateRaidDataBase()
	end
	UIDropDownMenu_AddButton(info);
end

-- populate a specific healer dropdown
function HealingAsssignments.Mainframe:PopulateHealerDropdown()
	local info;
	local names;

	for i=1,table.getn(HealingAsssignments.Raiddatabase) do

		if HealingAsssignments.Raiddatabase[i].Class == "DRUID" or 
		   HealingAsssignments.Raiddatabase[i].Class == "SHAMAN" or 
		   HealingAsssignments.Raiddatabase[i].Class == "PRIEST" or 
		   HealingAsssignments.Raiddatabase[i].Class == "PALADIN" then

			info = UIDropDownMenu_CreateInfo();
			names = HealingAsssignments:GetNames(HealingAsssignments.Raiddatabase[i].Class);
			info.colorCode = "|c00".. names[4];
			info.text = HealingAsssignments.Raiddatabase[i].Name
			info.checked = false;
			info.notCheckable = true;
			info.func = function(self)
				UIDropDownMenu_SetText(GlobalHealerDropDownID, self:GetText())

				HealingAsssignments:UpdateRaidDataBase()				
			end;

			UIDropDownMenu_AddButton(info);
		end
	end


	-- Raid Marks
	if HealingAsssignments.Mainframe.Foreground.Profile[1].Template[16].Assigments.Content.AdditionalHealersCheckbox:GetChecked() then 

		-- {Skull}
		info = UIDropDownMenu_CreateInfo();
		info = UIDropDownMenu_CreateInfo();
		names = HealingAsssignments:GetNames(CHA_NAME_SKULL);
		info.text = names[2];
		info.colorCode = "|c00".. names[4];
		info.checked = false;
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalHealerDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- {Cross}
		info = UIDropDownMenu_CreateInfo();
		names = HealingAsssignments:GetNames(CHA_NAME_CROSS);
		info.text = names[2];
		info.colorCode = "|c00".. names[4];
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalHealerDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- {Circle}
		info = UIDropDownMenu_CreateInfo();
		names = HealingAsssignments:GetNames(CHA_NAME_CIRCLE);
		info.text = names[2];
		info.colorCode = "|c00".. names[4];
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalHealerDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- {Star}
		info = UIDropDownMenu_CreateInfo();
		names = HealingAsssignments:GetNames(CHA_NAME_STAR);
		info.text = names[2];
		info.colorCode = "|c00".. names[4];
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalHealerDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- 	{Square}
		info = UIDropDownMenu_CreateInfo();
		names = HealingAsssignments:GetNames(CHA_NAME_SQUARE);
		info.text = names[2];
		info.colorCode = "|c00".. names[4];
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalHealerDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- {Triangle}
		info = UIDropDownMenu_CreateInfo();
		names = HealingAsssignments:GetNames(CHA_NAME_TRIANGLE);
		info.text = names[2];
		info.colorCode = "|c00".. names[4];
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalHealerDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		--{Diamond}
		info = UIDropDownMenu_CreateInfo();
		names = HealingAsssignments:GetNames(CHA_NAME_DIAMOND);
		info.text = names[2];
		info.colorCode = "|c00".. names[4];
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalHealerDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- {Moon}
		info = UIDropDownMenu_CreateInfo();
		names = HealingAsssignments:GetNames(CHA_NAME_MOON);
		info.text = names[2];
		info.colorCode = "|c00".. names[4];
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalHealerDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
	end
	
	-- create emtpy field to deleting
	info = UIDropDownMenu_CreateInfo();
	info.text = " "
	info.checked = false
	info.notCheckable = true;
	info.func = function(self)
		UIDropDownMenu_SetText(GlobalHealerDropDownID, self:GetText())
		HealingAsssignments:UpdateRaidDataBase()
	end
	UIDropDownMenu_AddButton(info);
end

-- Initialize a specific tank dropdown
function HealingAsssignments.Mainframe:TankDropDownOnClick(DropDownID)
	GlobalTankDropDownID = DropDownID -- feed global
	UIDropDownMenu_Initialize(DropDownID, self.PopulateTankDropdown)
end

-- Initialize a specific healer dropdown
function HealingAsssignments.Mainframe:HealerDropDownOnClick(DropDownID)
	GlobalHealerDropDownID = DropDownID -- feed global

	UIDropDownMenu_Initialize(DropDownID, self.PopulateHealerDropdown)
	UIDropDownMenu_GetText(DropDownID) 
end

-- create raiddatabase from raidata (unfiltered)
function HealingAsssignments:CreateRaidDatabase()
	HealingAsssignments.Raiddatabase = {}
	for i=1,GetNumGroupMembers() do
		HealingAsssignments.Raiddatabase[i] = {}
		HealingAsssignments.Raiddatabase[i].Name = UnitName("raid"..i)
		_,HealingAsssignments.Raiddatabase[i].Class = UnitClass("raid"..i)
		HealingAsssignments.Raiddatabase[i].Connection = UnitIsConnected("raid"..i)
	end
end	

-- Update the raiddatabase and set Colors
function HealingAsssignments:UpdateRaidDataBase()
	HealingAsssignments:CreateRaidDatabase()
	local activeFrame = HealingAsssignments.Mainframe.ActiveFrame
	
	if HealingAsssignments.Mainframe.ActiveFrame ~= nil and activeFrame <= 15 and 
	   HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile] and 
	   HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame] then

		HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Tank = {}
		HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Tankhealernames = {}

		-- TankNum is the # of tanks confured.
		local TankNum = HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].TankNum
		-- Each tank can have a number of Healers assigned ("HealerNum").
		local HealerNum = 0

		for i=1,TankNum do
			local foundName = 0;
			local numnum = i
			local TankName = UIDropDownMenu_GetText(HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Tank[i])
			
			if TankName == nil then 
				TankName = " " 
			end
			HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Tank[i] = TankName
			HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Tankhealernames[i] = {}
			
			
			for v=1,table.getn(HealingAsssignments.Raiddatabase) do
				if HealingAsssignments.Raiddatabase[v].Name == TankName then HealingAsssignments.Raiddatabase[v] = {} end
			end
			
			for w=1,GetNumGroupMembers() do
				if UnitName("raid"..w) == TankName then
					local color = self:GetClassColors(w)
					_G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Tank[i]:GetName().."Text"]:SetTextColor(color[0],color[1],color[2],1)
					foundName = 1;
				end	
			end
			-- check for additional tanks
			if TankName == CHA_NAME_LEFTSIDE then 
				_G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Tank[i]:GetName().."Text"]:SetTextColor(1,0,0,1);
			elseif TankName == CHA_NAME_RIGHTSIDE then 
				_G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Tank[i]:GetName().."Text"]:SetTextColor(0,0,1,1);
			elseif foundName == 0 then 
				_G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Tank[i]:GetName().."Text"]:SetTextColor(0,1,0,1);
			end
			
			HealerNum = HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].TankHealer[i]
			if HealerNum == nil then 
				HealerNum = 0;
			end;

			HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Tankhealernames[i].Healer = { }
			-- Each loot check one healer (and do what?)
			for j=1,HealerNum do
				local numj = j
				local HealerName = UIDropDownMenu_GetText(
					HealingAsssignments.Mainframe.Foreground
					.Profile[HealingAsssignments.Mainframe.ActiveProfile]
					.Template[activeFrame].Assigments.Content.Frame[i].Healer[j]
				)
				
				if HealerName == nil then 
					HealerName = " " 
				end
				local frame = HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j];

				HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Tankhealernames[i].Healer[j] = HealerName
				
				for v=1,table.getn(HealingAsssignments.Raiddatabase) do
					if HealingAsssignments.Raiddatabase[v].Name == HealerName then 
						HealingAsssignments.Raiddatabase[v] = {} 
					end
				end

				-- set standard color				
				_G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"]:SetTextColor(1,0,0,1);
				for w=1,GetNumGroupMembers() do
					if UnitName("raid"..w) == HealerName then 
						local color = self:GetClassColors(w)
						_G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"]:SetTextColor(color[0],color[1],color[2],1);
					end
				end

				if	HealerName == CHA_NAME_SKULL or HealerName == CHA_NAME_CROSS or
					HealerName == CHA_NAME_CIRCLE or HealerName == CHA_NAME_STAR or
					HealerName == CHA_NAME_SQUARE or HealerName == CHA_NAME_TRIANGLE or
					HealerName == CHA_NAME_DIAMOND or HealerName == CHA_NAME_MOON then

					local color = {1, 0, 0};
					local names = HealingAsssignments:GetNames(HealerName);
					if names then
						local r, g, b = HealingAsssignments:HexToRGB(names[4]);
						color = {r, g, b};
					end;

					_G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"]:SetTextColor(color[0],color[1],color[2],1);
				end;
			end
		end
	end
end

-- delivers color from raid ID
function HealingAsssignments:GetClassColors(RaidID)
	local classColors = { 0.7, 0.7, 0.7 }
	local unitId = "raid"..RaidID;

	if UnitIsConnected(unitId) then 
		local names = HealingAsssignments:GetNames(UnitClass(unitId));
		if names then
			local r, g, b = HealingAsssignments:HexToRGB(names[4]);
			classColors = {r, g, b};
		else
			classColors = {1, 0, 0};
		end;
	end;

	return classColors;
end

