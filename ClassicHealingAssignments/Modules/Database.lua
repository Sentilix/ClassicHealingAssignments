
local GlobalHealerDropDownID -- use global variable to get ID into populate function
local GlobalTankDropDownID -- use global variable to get ID into populate function
HealingAsssignments.Raiddatabase = {} -- Database of raidmembers -> all 40


local CHA_LEFT_DBOX = "<< Left side";
local CHA_RIGHT_DBOX = "Right side >>";

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



function HealingAsssignments:GetDropdownString(name)
	if name == CHA_SKULL_ICON then 
		name = CHA_SKULL_DBOX
	elseif name == CHA_CROSS_ICON then 
		name = CHA_CROSS_DBOX
	elseif name == CHA_CIRCLE_ICON then 
		name = CHA_CIRCLE_DBOX
	elseif name == CHA_STAR_ICON then 
		name = CHA_STAR_DBOX
	elseif name == CHA_SQUARE_ICON then 
		name = CHA_SQUARE_DBOX
	elseif name == CHA_TRIANGLE_ICON then 
		name = CHA_TRIANGLE_DBOX
	elseif name == CHA_DIAMOND_ICON then 
		name = CHA_DIAMOND_DBOX
	elseif name == CHA_MOON_ICON then 
		name = CHA_MOON_DBOX
	end;

	return name;
end

function HealingAsssignments:GetIconString(name)
	if name == CHA_SKULL_DBOX then 
		name = CHA_SKULL_ICON
	elseif name == CHA_CROSS_DBOX then 
		name = CHA_CROSS_ICON
	elseif name == CHA_CIRCLE_DBOX then 
		name = CHA_CIRCLE_ICON
	elseif name == CHA_STAR_DBOX then 
		name = CHA_STAR_ICON
	elseif name == CHA_SQUARE_DBOX then 
		name = CHA_SQUARE_ICON
	elseif name == CHA_TRIANGLE_DBOX then 
		name = CHA_TRIANGLE_ICON
	elseif name == CHA_DIAMOND_DBOX then 
		name = CHA_DIAMOND_ICON
	elseif name == CHA_MOON_DBOX then 
		name = CHA_MOON_ICON
	end;

	return name;
end

function HealingAsssignments:GetTextUIString(name)
	local newName = HealingAsssignments:GetIconString(name);

	if(name == newName) then
		newName = "["..name.."]";
	end;

	return newName;
end;



-- populate a specific tank dropdown
function HealingAsssignments.Mainframe:PopulateTankDropdown()

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
			info.text = HealingAsssignments.Raiddatabase[i].Name
			if HealingAsssignments.Raiddatabase[i].Class == "WARRIOR" then info.textR = 0.78; info.textG = 0.61; info.textB = 0.43;
			elseif HealingAsssignments.Raiddatabase[i].Class == "DRUID" then info.textR = 1.00; info.textG = 0.49; info.textB = 0.04;
			elseif HealingAsssignments.Raiddatabase[i].Class == "HUNTER" then info.textR = 0.67; info.textG = 0.83; info.textB = 0.45;
			elseif HealingAsssignments.Raiddatabase[i].Class == "MAGE" then info.textR = 0.41; info.textG = 0.80; info.textB = 0.94;
			elseif HealingAsssignments.Raiddatabase[i].Class == "ROGUE" then info.textR = 1.00; info.textG = 0.96; info.textB = 0.41;
			elseif HealingAsssignments.Raiddatabase[i].Class == "WARLOCK" then info.textR = 0.58; info.textG = 0.51; info.textB = 0.79;
			elseif HealingAsssignments.Raiddatabase[i].Class == "SHAMAN" then info.textR = 0.96; info.textG = 0.55; info.textB = 0.73;
			elseif HealingAsssignments.Raiddatabase[i].Class == "PRIEST" then info.textR = 1.00; info.textG = 1.00; info.textB = 1.00;
			elseif HealingAsssignments.Raiddatabase[i].Class == "PALADIN" then info.textR = 0.96; info.textG = 0.55; info.textB = 0.73;
			end	
			info.checked = false
			info.notCheckable = true
			info.func = function(self)
				--UIDropDownMenu_SetSelectedID(GlobalTankDropDownID, self:GetID(), 0);
				UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())

				HealingAsssignments:UpdateRaidDataBase()
			end
			UIDropDownMenu_AddButton(info);
		end
	end

	if LeftsideCheck then 
		-- create emtpy field to deleting
		info.text = CHA_LEFT_DBOX;
		info.textR = 1; info.textG = 0; info.textB = 0;
		info.checked = false
		info.notCheckable = true
		info.func = function(self)
			--UIDropDownMenu_SetSelectedID(GlobalTankDropDownID, self:GetID(), 0);
			UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
	end
	
	if RightsideCheck then 
		-- create emtpy field to deleting
		info.text = CHA_RIGHT_DBOX;
		info.textR = 0; info.textG = 0; info.textB = 1;
		info.checked = false
		info.notCheckable = true
		info.func = function(self)
			--UIDropDownMenu_SetSelectedID(GlobalTankDropDownID, self:GetID(), 0);
			UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
	end
	
	if CustomCheckbox then 
		-- create emtpy field to deleting
		info.text = HealingAsssignments.Mainframe.Foreground.Profile[1].Template[OptionsFrame].Assigments.Content.CustomCheckboxText:GetText()
		info.textR = 0; info.textG = 1; info.textB = 0;
		info.checked = false
		info.notCheckable = true
		info.func = function(self)
			--UIDropDownMenu_SetSelectedID(GlobalTankDropDownID, self:GetID(), 0);
			UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
	end	

	-- Raid Marks for Tanks:
	if HealingAsssignments.Mainframe.Foreground.Profile[1].Template[16].Assigments.Content.TankRaidMarkCheckbox:GetChecked() then 
		-- {Skull}
		info = UIDropDownMenu_CreateInfo();
		info.text = CHA_SKULL_DBOX;
		info.textR = 1; 
		info.textG = 1; 
		info.textB = 1;
		info.checked = false;
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- {Cross}
		info = UIDropDownMenu_CreateInfo();
		info.text = CHA_CROSS_DBOX;
		info.textR = 1; 
		info.textG = 0; 
		info.textB = 0;
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- {Circle}
		info = UIDropDownMenu_CreateInfo();
		info.text = CHA_CIRCLE_DBOX;
		info.textR = 1; 
		info.textG = 0.647; 
		info.textB = 0;
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- {Star}
		info = UIDropDownMenu_CreateInfo();
		info.text = CHA_STAR_DBOX;
		info.textR = 1; 
		info.textG = 1; 
		info.textB = 0;
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- 	{Square}
		info = UIDropDownMenu_CreateInfo();
		info.text = CHA_SQUARE_DBOX;
		info.textR = 0.255; 
		info.textG = 0.412; 
		info.textB = 0.882;
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- {Triangle}
		info = UIDropDownMenu_CreateInfo();
		info.text = CHA_TRIANGLE_DBOX;
		info.textR = 0; 
		info.textG = 1; 
		info.textB = 0;
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		--{Diamond}
		info = UIDropDownMenu_CreateInfo();
		info.text = CHA_DIAMOND_DBOX;
		info.textR = 1; 
		info.textG = 0; 
		info.textB = 1;
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- {Moon}
		info = UIDropDownMenu_CreateInfo();
		info.text = CHA_MOON_DBOX;
		info.textR = 0.878; 
		info.textG = 1; 
		info.textB = 1;
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
	info.func = function(self)
		--UIDropDownMenu_SetSelectedID(GlobalTankDropDownID, self:GetID(), 0);
		UIDropDownMenu_SetText(GlobalTankDropDownID, self:GetText())
		HealingAsssignments:UpdateRaidDataBase()
	end
	UIDropDownMenu_AddButton(info);
end

-- populate a specific healer dropdown
function HealingAsssignments.Mainframe:PopulateHealerDropdown()
	local info;

	for i=1,table.getn(HealingAsssignments.Raiddatabase) do

		if HealingAsssignments.Raiddatabase[i].Class == "DRUID" or 
		   HealingAsssignments.Raiddatabase[i].Class == "SHAMAN" or 
		   HealingAsssignments.Raiddatabase[i].Class == "PRIEST" or 
		   HealingAsssignments.Raiddatabase[i].Class == "PALADIN" then

			info = UIDropDownMenu_CreateInfo();

			info.text = HealingAsssignments.Raiddatabase[i].Name
			if HealingAsssignments.Raiddatabase[i].Class == "WARRIOR" then 
				info.textR = 0.78; info.textG = 0.61; info.textB = 0.43;
			elseif HealingAsssignments.Raiddatabase[i].Class == "DRUID" then 
				info.textR = 1.00; info.textG = 0.49; info.textB = 0.04;
			elseif HealingAsssignments.Raiddatabase[i].Class == "HUNTER" then 
				info.textR = 0.67; info.textG = 0.83; info.textB = 0.45;
			elseif HealingAsssignments.Raiddatabase[i].Class == "MAGE" then 
				info.textR = 0.41; info.textG = 0.80; info.textB = 0.94;
			elseif HealingAsssignments.Raiddatabase[i].Class == "ROGUE" then 
				info.textR = 1.00; info.textG = 0.96; info.textB = 0.41;
			elseif HealingAsssignments.Raiddatabase[i].Class == "WARLOCK" then 
				info.textR = 0.58; info.textG = 0.51; info.textB = 0.79;
			elseif HealingAsssignments.Raiddatabase[i].Class == "SHAMAN" then 
				info.textR = 0.96; info.textG = 0.55; info.textB = 0.73;
			elseif HealingAsssignments.Raiddatabase[i].Class == "PRIEST" then 
				info.textR = 1.00; info.textG = 1.00; info.textB = 1.00;
			elseif HealingAsssignments.Raiddatabase[i].Class == "PALADIN" then 
				info.textR = 0.96; info.textG = 0.55; info.textB = 0.73;
			end	
			info.checked = false;
			info.notCheckable = true;
			info.func = function(self)
				--UIDropDownMenu_SetSelectedID(GlobalHealerDropDownID, self:GetID(), 0);
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
		info.text = CHA_SKULL_DBOX;
		info.textR = 1; 
		info.textG = 1; 
		info.textB = 1;
		info.checked = false;
		info.notCheckable = true;
		info.func = function(self)
			--UIDropDownMenu_SetSelectedID(GlobalHealerDropDownID, self:GetID(), 0);
			UIDropDownMenu_SetText(GlobalHealerDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- {Cross}
		info = UIDropDownMenu_CreateInfo();
		info.text = CHA_CROSS_DBOX;
		info.textR = 1; 
		info.textG = 0; 
		info.textB = 0;
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			--UIDropDownMenu_SetSelectedID(GlobalHealerDropDownID, self:GetID(), 0);
			UIDropDownMenu_SetText(GlobalHealerDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- {Circle}
		info = UIDropDownMenu_CreateInfo();
		info.text = CHA_CIRCLE_DBOX;
		info.textR = 1; 
		info.textG = 0.647; 
		info.textB = 0;
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			--UIDropDownMenu_SetSelectedID(GlobalHealerDropDownID, self:GetID(), 0);
			UIDropDownMenu_SetText(GlobalHealerDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- {Star}
		info = UIDropDownMenu_CreateInfo();
		info.text = CHA_STAR_DBOX;
		info.textR = 1; 
		info.textG = 1; 
		info.textB = 0;
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			--UIDropDownMenu_SetSelectedID(GlobalHealerDropDownID, self:GetID(), 0);
			UIDropDownMenu_SetText(GlobalHealerDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- 	{Square}
		info = UIDropDownMenu_CreateInfo();
		info.text = CHA_SQUARE_DBOX;
		info.textR = 0.255; 
		info.textG = 0.412; 
		info.textB = 0.882;
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			--UIDropDownMenu_SetSelectedID(GlobalHealerDropDownID, self:GetID(), 0);
			UIDropDownMenu_SetText(GlobalHealerDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- {Triangle}
		info = UIDropDownMenu_CreateInfo();
		info.text = CHA_TRIANGLE_DBOX;
		info.textR = 0; 
		info.textG = 1; 
		info.textB = 0;
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			--UIDropDownMenu_SetSelectedID(GlobalHealerDropDownID, self:GetID(), 0);
			UIDropDownMenu_SetText(GlobalHealerDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		--{Diamond}
		info = UIDropDownMenu_CreateInfo();
		info.text = CHA_DIAMOND_DBOX;
		info.textR = 1; 
		info.textG = 0; 
		info.textB = 1;
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			--UIDropDownMenu_SetSelectedID(GlobalHealerDropDownID, self:GetID(), 0);
			UIDropDownMenu_SetText(GlobalHealerDropDownID, self:GetText())
			HealingAsssignments:UpdateRaidDataBase()
		end
		UIDropDownMenu_AddButton(info);
		
		-- {Moon}
		info = UIDropDownMenu_CreateInfo();
		info.text = CHA_MOON_DBOX;
		info.textR = 0.878; 
		info.textG = 1; 
		info.textB = 1;
		info.checked = false
		info.notCheckable = true;
		info.func = function(self)
			--UIDropDownMenu_SetSelectedID(GlobalHealerDropDownID, self:GetID(), 0);
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
		--UIDropDownMenu_SetSelectedID(GlobalHealerDropDownID, self:GetID(), 0);
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
					--getglobal(HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Tank[i]:GetName().."Text"):SetTextColor(color[2],color[3],color[4],1)
					_G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Tank[i]:GetName().."Text"]:SetTextColor(color[2],color[3],color[4],1)
					foundName = 1;
				end	
			end
			-- check for additional tanks
			if TankName == CHA_LEFT_DBOX then 
				--getglobal(HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Tank[i]:GetName().."Text"):SetTextColor(1,0,0,1) 
				_G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Tank[i]:GetName().."Text"]:SetTextColor(1,0,0,1);
			elseif TankName == CHA_RIGHT_DBOX then 
				--getglobal(HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Tank[i]:GetName().."Text"):SetTextColor(0,0,1,1)
				_G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Tank[i]:GetName().."Text"]:SetTextColor(0,0,1,1);
			elseif foundName == 0 then 
				--getglobal(HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Tank[i]:GetName().."Text"):SetTextColor(0,1,0,1) 
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
				--getglobal(HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"):SetTextColor(1,0,0,1)
				_G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"]:SetTextColor(1,0,0,1);
				for w=1,GetNumGroupMembers() do
					if UnitName("raid"..w) == HealerName then 
						local color = self:GetClassColors(w)
						--getglobal(HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"):SetTextColor(color[2],color[3],color[4],1)
						_G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"]:SetTextColor(color[2],color[3],color[4],1);
					end
				end
								
				if HealerName == CHA_SKULL_DBOX then 
					--getglobal(HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"):SetTextColor(1,1,1,1)
					_G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"]:SetTextColor(1,1,1,1);
				elseif HealerName == CHA_CROSS_DBOX then 
					--getglobal(HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"):SetTextColor(1,0,0,1)
					_G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"]:SetTextColor(1,0,0,1);
				elseif HealerName == CHA_CIRCLE_DBOX then 
					--getglobal(HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"):SetTextColor(1,0.647,0,1)
					_G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"]:SetTextColor(1,0.647,0,1);
				elseif HealerName == CHA_STAR_DBOX then 
					--getglobal(HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"):SetTextColor(1,1,0,1)
					_G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"]:SetTextColor(1,1,0,1);
				elseif HealerName == CHA_SQUARE_DBOX then 
					--getglobal(HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"):SetTextColor(0.255,0.412,0.882,1)
					_G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"]:SetTextColor(0.255,0.412,0.882,1);
				elseif HealerName == CHA_TRIANGLE_DBOX then 
					--getglobal(HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"):SetTextColor(0,1,0,1)
					_G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"]:SetTextColor(0,1,0,1);
				elseif HealerName == CHA_DIAMOND_DBOX then 
					--getglobal(HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"):SetTextColor(1,0,1,1)
					_G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"]:SetTextColor(1,0,1,1);
				elseif HealerName == CHA_MOON_DBOX then 
					--getglobal(HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"):SetTextColor(1,1,1,1)
					_G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[activeFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"]:SetTextColor(1,1,1,1);
				end
			end
		end
	end
end

-- delivers class and color from raid ID
function HealingAsssignments:GetClassColors(RaidID)
	
	local classColors = {}
	_,classColors[1] = UnitClass("raid"..RaidID)
	if UnitIsConnected("raid"..RaidID) == nil then classColors[2] = 0.7; classColors[3] = 0.7; classColors[4] = 0.7; classColors[5] = "BABABA"; return classColors
    elseif classColors[1] == "WARRIOR" then classColors[2] = 0.78; classColors[3] = 0.61; classColors[4] = 0.43; classColors[5] = "C79C6E"; return classColors
	elseif classColors[1] == "HUNTER" then classColors[2] = 0.67; classColors[3] = 0.83; classColors[4] = 0.45; classColors[5] = "ABD473"; return classColors
	elseif classColors[1] == "MAGE" then classColors[2] = 0.41; classColors[3] = 0.80; classColors[4] = 0.94; classColors[5] = "69CCF0"; return classColors
	elseif classColors[1] == "ROGUE" then classColors[2] = 1.00; classColors[3] = 0.96; classColors[4] = 0.41; classColors[5] = "FFF569"; return classColors
	elseif classColors[1] == "WARLOCK" then classColors[2] = 0.58; classColors[3] = 0.51; classColors[4] = 0.79; classColors[5] = "9482C9"; return classColors
    elseif classColors[1] == "DRUID" then classColors[2] = 1.00; classColors[3] = 0.49; classColors[4] = 0.04; classColors[5] = "FF7D0A"; return classColors
    elseif classColors[1] == "SHAMAN" then classColors[2] = 0.96; classColors[3] = 0.55; classColors[4] = 0.73; classColors[5] = "F58CBA"; return classColors
    elseif classColors[1] == "PRIEST" then classColors[2] = 1.00; classColors[3] = 1.00; classColors[4] = 1.00; classColors[5] = "FFFFFF"; return classColors
    elseif classColors[1] == "PALADIN" then classColors[2] = 0.96; classColors[3] = 0.55; classColors[4] = 0.73; classColors[5] = "FF0000" return classColors
    else classColors[1] = " "; classColors[2] = 1.00; classColors[3] = 0.00; classColors[4] = 0.00; classColors[5] = "FF0000"; return classColors
    end
    
end

