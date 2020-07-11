
local CHAT_END								= "|r"
local COLOUR_BEGINMARK						= "|c80"
local COLOUR_CHAT							= COLOUR_BEGINMARK.."40A0F8"
local COLOUR_INTRO							= COLOUR_BEGINMARK.."B040F0"

local CHA_MESSAGE_PREFIX					= "CHA";


HealingAsssignments = CreateFrame("Frame"); -- Event Frame
HealingAsssignments.Minimap = CreateFrame("Frame",nil,Minimap) -- Minimap Frame
HealingAsssignments.Mainframe = CreateFrame("Frame","CHAMainFrame",UIParent) -- Main Display Frame
HealingAsssignments.Syncframe = CreateFrame("Frame",nil,HealingAsssignments.Mainframe)

tinsert(UISpecialFrames, "CHAMainFrame")

HealingAsssignments:RegisterEvent("ADDON_LOADED")
HealingAsssignments:RegisterEvent("GROUP_ROSTER_UPDATE")
HealingAsssignments:RegisterEvent("CHAT_MSG_WHISPER")
HealingAsssignments:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
HealingAsssignments:RegisterEvent("CHAT_MSG_ADDON")

C_ChatInfo.RegisterAddonMessagePrefix(CHA_MESSAGE_PREFIX);

local GetTime, wipe, type, band = GetTime, wipe, type, bit.band

local FEIGN = GetSpellInfo(5384)

function HealingAsssignments:GetMessagePrefix()
	return CHA_MESSAGE_PREFIX;
end;



--[[
	Echo a message for the local user only.
]]
local function echo(msg)
	if msg then
		DEFAULT_CHAT_FRAME:AddMessage(COLOUR_CHAT .. msg .. CHAT_END)
	end
end

function HealingAsssignments:GetPlayerName(nameAndRealm)
	local _, _, name = string.find(nameAndRealm, "([^-]*)-%s*");
	if not name then
		name = nameAndRealm;
	end;

	return name;
end;


--function HealingAsssignments:OnUpdate()
--end

-- function HealingAsssignments:COMBAT_LOG_EVENT_UNFILTERED(timestamp, event, hideCaster, srcGUID, srcName, srcFlags, srcRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
-- 	if not (UnitInRaid(destName) or UnitInParty(destName)) then 
-- 		return 
-- 	end
-- 	print(event)
-- 	if event == "UNIT_DIED" and not UnitBuff(destName, FEIGN) then
-- 		print("oh nos ", destName, " died")
-- 		if HealingAsssignments.Mainframe.DeathWarningCheckbox:GetChecked() == 1 then
-- 			HealingAsssignments:PostDeathWarning(string.sub(destName, 1, -7)) -- Name dies.
-- 		end
-- 	end
-- end


function HealingAsssignments:OnEvent(event, ...)
	
	if event == "CHAT_MSG_ADDON" then
		local prefix, msg, channel, sender = ...;
		if prefix ~= HealingAsssignments:GetMessagePrefix() then	
			return;
		end;

		local _, _, cmd, message, recipient = string.find(msg, "([^#]*)#([^#]*)#([^#]*)");	
		
		if not (recipient == "") then
			if not (recipient == HealingAsssignments:GetPlayerName(UnitName("player"))) then
				return
			end
		end

		sender = HealingAsssignments:GetPlayerName(sender);

		if cmd == "TX_VERSION" then
			HealingAsssignments:HandleTXVersion(message,sender);
		elseif cmd == "RX_VERSION" then
			HealingAsssignments:HandleRXVersion(message,sender);
		end;
			
		local arg1, arg2, _, arg4 = ...;
		if HealingAsssignments.Mainframe.SyncCheckbox:GetChecked() == 1 and string.sub(arg1, 1, 3) == prefix and arg4 ~= UnitName("player") then
			print("SYNC")
			local TemplateNum = tonumber(string.sub(arg1, 5,6))
			local TemplateName = string.sub(arg1, 8)
			local NameArray = CHAstrsplit(arg2,"#")
			HealingAsssignments.Syncframe:Receive(arg4,TemplateNum,TemplateName,NameArray)
		elseif HealingAsssignments.Mainframe.SyncCheckbox:GetChecked() == 1 and arg1 == "CHTrigger" and arg2 == "trigger" then 
			HealingAsssignments.Syncframe:Send()
		end
	
	elseif event == "GROUP_ROSTER_UPDATE" then
		HealingAsssignments:SetNumberOfHealers()
		HealingAsssignments:UpdateRaidDataBase()

	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, type, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2 = CombatLogGetCurrentEventInfo()
		if not (UnitInRaid(destName) or UnitInParty(destName)) then 
			return 
		end
		if type == "UNIT_DIED" and not AuraUtil.FindAuraByName("Feign Death", destName) then
			if HealingAsssignments.Mainframe.DeathWarningCheckbox:GetChecked() then
				HealingAsssignments:PostDeathWarning(destName) -- Name dies.
			end
		end


	elseif event == "CHAT_MSG_WHISPER" then
		local arg1, arg2 = ...;
		local sender = HealingAsssignments:GetPlayerName(arg2);

		if arg1 == "!heal" or arg1 == "heal" then
			HealingAsssignments:AnswerAssignments(sender)
		end

	elseif event == "ADDON_LOADED" then
		local addonname = ...;
		if addonname == "ClassicHealingAssignments" then
			echo(string.format("Classic Healing Assignments version ".. GetAddOnMetadata("ClassicHealingAssignments", "Version") .." - by "..GetAddOnMetadata("ClassicHealingAssignments", "Author")));

			HealingAsssignments.Mainframe:ConfigureFrame()
			HealingAsssignments.MessageBuffer = {}
			HealingAsssignments.LastAddonMessageTime = 0;
			if ChaFu then 
				HealingAsssignments.Minimap:Hide();
			end
		end;
	end
end

function HealingAsssignments:HandleTXVersion(message, sender)
	local version = GetAddOnMetadata("ClassicHealingAssignments", "Version")	
	C_ChatInfo.SendAddonMessage(HealingAsssignments:GetMessagePrefix(), "RX_VERSION#"..version.."#"..sender, "RAID");
end;

function HealingAsssignments:HandleRXVersion(message, sender)
	echo(string.format("%s is using Classic Healing Assignments version %s", sender, message))
end;




HealingAsssignments:SetScript("OnEvent", HealingAsssignments.OnEvent)
--HealingAsssignments:SetScript("OnUpdate", HealingAsssignments.OnUpdate)


-- from healCommm-1.0 addon / lua 5.1 workaround
function CHAstrsplit(pString, pPattern)
	local Table = {}
	local fpat = "(.-)" .. pPattern
	local last_end = 1
	local s, e, cap = strfind(pString, fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(Table,cap)
		end
		last_end = e+1
		s, e, cap = strfind(pString, fpat, last_end)
	end
	if last_end <= strlen(pString) then
		cap = strfind(pString, last_end)
		table.insert(Table, cap)
	end
	return Table
end


function HealingAsssignments:SetNumberOfHealers()
	local NumHealers = 0;
	local Class = ""
	for i=1,GetNumGroupMembers() do
		_,Class = UnitClass("raid"..i)
		if Class == "PRIEST" or Class == "DRUID" or Class == "SHAMAN" or Class == "PALADIN" then 
			NumHealers = NumHealers + 1;
		end
	end
	HealingAsssignments.Mainframe.BottomLeftFontString:SetText("Number of Healers: "..NumHealers)
end


-- Initial Configure and Creation after Login
function HealingAsssignments.Mainframe:ConfigureFrame()
	-- set initial settings
	HealingAsssignments.Mainframe.Options = {}
	function HealingAsssignments.Mainframe.Options:StartMoving()
		self:StartMoving()
	end
	
	function HealingAsssignments.Mainframe.Options:StopMovingOrSizing()
		self:StopMovingOrSizing()
	end

	self:SetFrameStrata("BACKGROUND")
	self:SetWidth(768) -- Set these to whatever height/width is needed 
	self:SetHeight(446) -- for your Texture
	self:SetPoint("CENTER",0,0)
	self:SetMovable(1)
	self:EnableMouse(1)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", HealingAsssignments.Mainframe.Options.StartMoving)
	self:SetScript("OnDragStop", HealingAsssignments.Mainframe.Options.StopMovingOrSizing)

	-- create static elements --
	----------------------------
	
	-- create Frames
	if HealingAssignmentsTemplates == nil then 
		HealingAssignmentsTemplates = { };
	end

	if HealingAssignmentsTemplates.Options == nil then 
		HealingAssignmentsTemplates.Options = { };
		HealingAssignmentsTemplates.Options.WhisperRepost = 1;
		HealingAssignmentsTemplates.Options.WhisperHeal = 1;
		-- Druids are viable tanks in vanilla: add to tank list as default:
		HealingAssignmentsTemplates.Options.TankAsDruid = 1;
	end

	if HealingAssignmentsTemplates.Options.Delay == nil then 
		HealingAssignmentsTemplates.Options.Delay = 500;
		HealingAssignmentsTemplates.Options.Delay = 500;
	end

	if HealingAssignmentsTemplates.Options.MinimapX == nil then 
		HealingAssignmentsTemplates.Options.MinimapX = 0;		-- initial x position
	end

	if HealingAssignmentsTemplates.Options.MinimapY == nil then
		HealingAssignmentsTemplates.Options.MinimapY = 0;		-- initial y position
	end

	if not HealingAssignmentsTemplates.Profile then
		HealingAssignmentsTemplates.Profile = { };
	end

	for i=1,11 do
		if HealingAssignmentsTemplates.Profile[i] == nil then 
			HealingAssignmentsTemplates.Profile[i] = { };
		end

		if HealingAssignmentsTemplates.Profile[i].Template == nil then 
			HealingAssignmentsTemplates.Profile[i].Template = { };
		end

		if HealingAssignmentsTemplates.Profile[i].Template.TankHealer == nil then
			HealingAssignmentsTemplates.Profile[i].Template.TankHealer = { };
		end

		if HealingAssignmentsTemplates.Profile[i].Template.Name == nil then 
			HealingAssignmentsTemplates.Profile[i].Template.Name = { };
		end

		if not HealingAssignmentsTemplates.Profile[i].Name then 
			HealingAssignmentsTemplates.Profile[i].Name = " ";
		end
	end
	HealingAssignmentsTemplates.Profile[1].Name = UnitName("player")
	HealingAssignmentsTemplates.Profile[2].Name = "Molten Core"
	HealingAssignmentsTemplates.Profile[3].Name = "BlackWing Lair"
	HealingAssignmentsTemplates.Profile[4].Name = "Ahn'Qiraj"
	HealingAssignmentsTemplates.Profile[5].Name = "Naxxramas"
	HealingAssignmentsTemplates.Profile[6].Name = "Other"
	
	
	local OptionsFrameNum = 16;		-- options frame
	self.ActiveFrame = { };			-- no active Frame at start // clear it
	self.ActiveFrame = nil
	self.ActiveFrameBuffer = nil
	self.ActiveProfile = 1
	self.DropDownCounter = { }; 
	self.DropDownCounter = 0;		-- init counter for making bug-free dropdowns
	
	self.Foreground = { };			-- Foreground Frame
	self.Foreground.Profile = { };
	for i=1, 11 do
		self.Foreground.Profile[i] = {}
		self.Foreground.Profile[i].Template = {}
	end

	self.Background = {} -- Background Frame
	self.Background.Topleft = CreateFrame("Frame",nil,self) -- Topleft Background Frame
	self.Background.Topright = CreateFrame("Frame",nil,self) -- Topright Background Frame
	self.Background.Topmid = CreateFrame("Frame",nil,self) -- Topleft Background Frame
	self.Background.Bottommid = CreateFrame("Frame",nil,self) -- Topright Background Frame
	self.Background.Bottomleft = CreateFrame("Frame",nil,self) -- Bottomleft Background Frame
	self.Background.Bottomright =  CreateFrame("Frame",nil,self) -- Bottomright Background Frame
	self.Background.Icon = CreateFrame("Frame",nil,self) -- Icon Background Frame
	self.Background.TemplateBackground = CreateFrame("Frame",nil,self) -- template class background
	self.Background.TemplateBackground2 = CreateFrame("Frame",nil,self) -- template class background
	self.Background.TemplateOption = CreateFrame("Frame",nil,self) -- Template PopUp Frame
	self.Background.TemplateDeleteOption = CreateFrame("Frame",nil,self) -- Template PopUp Frame
	
	
	-- Bottomright Background Frame
	local backdrop = {bgFile = "Interface\\AddOns\\ClassicHealingAssignments\\Media\\icon"}
	local backdropMouseOver = {bgFile = "Interface\\AddOns\\ClassicHealingAssignments\\Media\\iconmouseover"}
	self.Background.Icon:SetFrameStrata("LOW")
	self.Background.Icon:SetWidth(64) -- Set these to whatever height/width is needed 
	self.Background.Icon:SetHeight(64) -- for your Texture
	self.Background.Icon:SetBackdrop(backdrop)
	self.Background.Icon:SetPoint("TOPLEFT", self, "TOPLEFT", 6, -2)
	
	self.Background.Icon.Button = CreateFrame("Button",nil,self) -- click button on icon
	self.Background.Icon.Button:SetWidth(64)
	self.Background.Icon.Button:SetHeight(64)
	self.Background.Icon.Button:SetPoint("TOPLEFT", self, "TOPLEFT", 6, -2)
	self.Background.Icon.Button:SetScript("OnEnter",function() 
		PlaySound(882, "Master"); 
		HealingAsssignments.Mainframe.Background.Icon:SetBackdrop(backdropMouseOver) 
		GameTooltip:SetOwner(HealingAsssignments.Mainframe, "ANCHOR_TOPLEFT");
		GameTooltip:SetText("Click to Post Healing Assignments", 1, 1, 1, 1, 1);
		GameTooltip:Show()
	end)
	self.Background.Icon.Button:SetScript("OnLeave",function() HealingAsssignments.Mainframe.Background.Icon:SetBackdrop(backdrop); GameTooltip:Hide() end)
	self.Background.Icon.Button:SetScript("OnClick",function() PlaySound(882, "Master"); HealingAsssignments:PostAssignments() end)
	
	-- Topleft Background Frame
	local backdrop = {bgFile = "Interface\\auctionframe\\ui-auctionframe-browse-topleft"}  -- path to the background texture
	self.Background.Topleft:SetFrameStrata("BACKGROUND")
	self.Background.Topleft:SetWidth(256) -- Set these to whatever height/width is needed 
	self.Background.Topleft:SetHeight(256) -- for your Texture
	self.Background.Topleft:SetBackdrop(backdrop)
	self.Background.Topleft:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
	
	-- Topmid Background Frame
	local backdrop = {bgFile = "Interface\\auctionframe\\ui-auctionframe-browse-top"}  -- path to the background texture
	self.Background.Topmid:SetFrameStrata("BACKGROUND")
	self.Background.Topmid:SetWidth(256) -- Set these to whatever height/width is needed 
	self.Background.Topmid:SetHeight(256) -- for your Texture
	self.Background.Topmid:SetBackdrop(backdrop)
	self.Background.Topmid:SetPoint("TOPLEFT", self, "TOPLEFT", 256, 0)
	
	-- Topright Background Frame
	local backdrop = {bgFile = "Interface\\auctionframe\\ui-auctionframe-browse-topright"}  -- path to the background texture
	self.Background.Topright:SetFrameStrata("BACKGROUND")
	self.Background.Topright:SetWidth(256) -- Set these to whatever height/width is needed 
	self.Background.Topright:SetHeight(256) -- for your Texture
	self.Background.Topright:SetBackdrop(backdrop)
	self.Background.Topright:SetPoint("TOPLEFT", self, "TOPLEFT", 512, 0)
	
	-- Bottomleft Background Frame
	local backdrop = {bgFile = "Interface\\auctionframe\\ui-auctionframe-browse-botleft"}  -- path to the background texture
	self.Background.Bottomleft:SetFrameStrata("BACKGROUND")
	self.Background.Bottomleft:SetWidth(256) -- Set these to whatever height/width is needed 
	self.Background.Bottomleft:SetHeight(256) -- for your Texture
	self.Background.Bottomleft:SetBackdrop(backdrop)
	self.Background.Bottomleft:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -256)
	
	-- Bottommid Background Frame
	local backdrop = {bgFile = "Interface\\auctionframe\\ui-auctionframe-browse-bot"}  -- path to the background texture
	self.Background.Bottommid:SetFrameStrata("BACKGROUND")
	self.Background.Bottommid:SetWidth(256) -- Set these to whatever height/width is needed 
	self.Background.Bottommid:SetHeight(256) -- for your Texture
	self.Background.Bottommid:SetBackdrop(backdrop)
	self.Background.Bottommid:SetPoint("TOPLEFT", self, "TOPLEFT", 256, -256)
	
	-- Bottomright Background Frame
	local backdrop = {bgFile = "Interface\\auctionframe\\ui-auctionframe-browse-botright"}  -- path to the background texture
	self.Background.Bottomright:SetFrameStrata("BACKGROUND")
	self.Background.Bottomright:SetWidth(256) -- Set these to whatever height/width is needed 
	self.Background.Bottomright:SetHeight(256) -- for your Texture
	self.Background.Bottomright:SetBackdrop(backdrop)
	self.Background.Bottomright:SetPoint("TOPLEFT", self, "TOPLEFT", 512, -256)
	
	local roll = math.random(1,3)
	local backdropTemplate1 = {}
	local backdropTemplate2 = {}
	local _,Class = UnitClass("player")
	if Class == "DRUID" then
		backdropTemplate1[1] = {bgFile = "Interface\\TalentFrame\\DruidBalance-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[1] = {bgFile = "Interface\\TalentFrame\\DruidBalance-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
		backdropTemplate1[2] = {bgFile = "Interface\\TalentFrame\\DruidFeralCombat-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[2] = {bgFile = "Interface\\TalentFrame\\DruidFeralCombat-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
		backdropTemplate1[3] = {bgFile = "Interface\\TalentFrame\\DruidRestoration-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[3] = {bgFile = "Interface\\TalentFrame\\DruidRestoration-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
	elseif Class == "HUNTER" then
		backdropTemplate1[1] = {bgFile = "Interface\\TalentFrame\\HunterBeastMastery-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[1] = {bgFile = "Interface\\TalentFrame\\HunterBeastMastery-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
		backdropTemplate1[2] = {bgFile = "Interface\\TalentFrame\\HunterMarksmanship-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[2] = {bgFile = "Interface\\TalentFrame\\HunterMarksmanship-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
		backdropTemplate1[3] = {bgFile = "Interface\\TalentFrame\\HunterSurvival-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[3] = {bgFile = "Interface\\TalentFrame\\HunterSurvival-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
	elseif Class == "MAGE" then
		backdropTemplate1[1] = {bgFile = "Interface\\TalentFrame\\MageArcane-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[1] = {bgFile = "Interface\\TalentFrame\\MageArcane-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
		backdropTemplate1[2] = {bgFile = "Interface\\TalentFrame\\MageFire-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[2] = {bgFile = "Interface\\TalentFrame\\MageFire-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
		backdropTemplate1[3] = {bgFile = "Interface\\TalentFrame\\MageFrost-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[3] = {bgFile = "Interface\\TalentFrame\\MageFrost-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
	elseif Class == "PALADIN" then
		backdropTemplate1[1] = {bgFile = "Interface\\TalentFrame\\PaladinCombat-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[1] = {bgFile = "Interface\\TalentFrame\\PaladinCombat-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
		backdropTemplate1[2] = {bgFile = "Interface\\TalentFrame\\PaladinHoly-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[2] = {bgFile = "Interface\\TalentFrame\\PaladinHoly-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
		backdropTemplate1[3] = {bgFile = "Interface\\TalentFrame\\PaladinProtection-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[3] = {bgFile = "Interface\\TalentFrame\\PaladinProtection-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
	elseif Class == "PRIEST" then
		backdropTemplate1[1] = {bgFile = "Interface\\TalentFrame\\PriestDiscipline-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[1] = {bgFile = "Interface\\TalentFrame\\PriestDiscipline-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
		backdropTemplate1[2] = {bgFile = "Interface\\TalentFrame\\PriestHoly-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[2] = {bgFile = "Interface\\TalentFrame\\PriestHoly-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
		backdropTemplate1[3] = {bgFile = "Interface\\TalentFrame\\PriestShadow-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[3] = {bgFile = "Interface\\TalentFrame\\PriestShadow-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
	elseif Class == "ROGUE" then
		backdropTemplate1[1] = {bgFile = "Interface\\TalentFrame\\RogueAssassination-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[1] = {bgFile = "Interface\\TalentFrame\\RogueAssassination-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
		backdropTemplate1[2] = {bgFile = "Interface\\TalentFrame\\RogueCombat-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[2] = {bgFile = "Interface\\TalentFrame\\RogueCombat-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
		backdropTemplate1[3] = {bgFile = "Interface\\TalentFrame\\RogueSubtlety-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[3] = {bgFile = "Interface\\TalentFrame\\RogueSubtlety-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
	elseif Class == "SHAMAN" then
		backdropTemplate1[1] = {bgFile = "Interface\\TalentFrame\\ShamanElementalCombat-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[1] = {bgFile = "Interface\\TalentFrame\\ShamanElementalCombat-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
		backdropTemplate1[2] = {bgFile = "Interface\\TalentFrame\\ShamanEnhancement-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[2] = {bgFile = "Interface\\TalentFrame\\ShamanEnhancement-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
		backdropTemplate1[3] = {bgFile = "Interface\\TalentFrame\\ShamanRestoration-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[3] = {bgFile = "Interface\\TalentFrame\\ShamanRestoration-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
	elseif Class == "WARLOCK" then
		backdropTemplate1[1] = {bgFile = "Interface\\TalentFrame\\WarlockCurses-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[1] = {bgFile = "Interface\\TalentFrame\\WarlockCurses-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
		backdropTemplate1[2] = {bgFile = "Interface\\TalentFrame\\WarlockDestruction-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[2] = {bgFile = "Interface\\TalentFrame\\WarlockDestruction-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
		backdropTemplate1[3] = {bgFile = "Interface\\TalentFrame\\WarlockSummoning-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[3] = {bgFile = "Interface\\TalentFrame\\WarlockSummoning-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
	elseif Class == "WARRIOR" then
		backdropTemplate1[1] = {bgFile = "Interface\\TalentFrame\\WarriorArms-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[1] = {bgFile = "Interface\\TalentFrame\\WarriorArms-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
		backdropTemplate1[2] = {bgFile = "Interface\\TalentFrame\\WarriorFury-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[2] = {bgFile = "Interface\\TalentFrame\\WarriorFury-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
		backdropTemplate1[3] = {bgFile = "Interface\\TalentFrame\\WarriorProtection-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
		backdropTemplate2[3] = {bgFile = "Interface\\TalentFrame\\WarriorProtection-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
	end
	
	
	-- create template background
	local backdrop = {bgFile = "Interface\\TalentFrame\\DruidBalance-Topleft",insets = {left = 48,right = 48, top = 20, bottom = 0}}
	self.Background.TemplateBackground:SetFrameStrata("LOW")
	self.Background.TemplateBackground:SetWidth(256)
	self.Background.TemplateBackground:SetHeight(256)
	self.Background.TemplateBackground:SetBackdrop(backdropTemplate1[roll])
	self.Background.TemplateBackground:SetBackdropColor(1,1,1,0.8)
	self.Background.TemplateBackground:SetPoint("TOPLEFT", self, "TOPLEFT", -27, -83)
	
	local backdrop2 = {bgFile = "Interface\\TalentFrame\\DruidBalance-Bottomleft",insets = {left = 48,right = 48, top = 0, bottom = 10}}
	self.Background.TemplateBackground2:SetFrameStrata("LOW")
	self.Background.TemplateBackground2:SetWidth(256)
	self.Background.TemplateBackground2:SetHeight(128)
	self.Background.TemplateBackground2:SetBackdrop(backdropTemplate2[roll])
	self.Background.TemplateBackground2:SetBackdropColor(1,1,1,0.8)
	self.Background.TemplateBackground2:SetPoint("TOPLEFT", self, "TOPLEFT", -27, -339)
	
	-- Template Template Create Popup Frame
	
	local backdrop = {bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground", edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile = true, tileSize = 32, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }}  -- path to the background texture
	self.Background.TemplateOption:SetFrameStrata("MEDIUM")
	self.Background.TemplateOption:SetWidth(200) -- Set these to whatever height/width is needed 
	self.Background.TemplateOption:SetHeight(100) -- for your Texture
	self.Background.TemplateOption:SetBackdrop(backdrop)
	self.Background.TemplateOption:SetAlpha(1)
	self.Background.TemplateOption:SetPoint("TOPLEFT", self, "TOPLEFT", 185, -100)
	
	local TemplateOptionHeaderFontString = self.Background.TemplateOption:CreateFontString(nil, "OVERLAY")
    TemplateOptionHeaderFontString:SetPoint("TOPLEFT", self.Background.TemplateOption, "TOPLEFT", 0, -10)
	TemplateOptionHeaderFontString:SetFont("Fonts\\FRIZQT__.TTF", 9)
	TemplateOptionHeaderFontString:SetWidth(200)
	TemplateOptionHeaderFontString:SetJustifyH("CENTER")
    TemplateOptionHeaderFontString:SetText("Create Template Options")
	
	local TemplateOptionText1FontString = self.Background.TemplateOption:CreateFontString(nil, "OVERLAY")
    TemplateOptionText1FontString:SetPoint("TOPLEFT", self.Background.TemplateOption, "TOPLEFT", 10, -30)
	TemplateOptionText1FontString:SetFont("Fonts\\FRIZQT__.TTF", 9)
	TemplateOptionText1FontString:SetWidth(200)
	TemplateOptionText1FontString:SetJustifyH("LEFT")
    TemplateOptionText1FontString:SetText("Template Name:")
	
	
	self.Background.TemplateOption.Editbox = CreateFrame("EditBox", nil, self.Background.TemplateOption)
	local backdrop = {bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground", edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile = true, tileSize = 32, edgeSize = 4, insets = { left = 0, right = 0, top = 0, bottom = 0 }}
	self.Background.TemplateOption.Editbox:SetFontObject("GameFontHighlight")
	self.Background.TemplateOption.Editbox:SetBackdrop(backdrop)
	self.Background.TemplateOption.Editbox:SetFrameStrata("MEDIUM")
	self.Background.TemplateOption.Editbox:SetPoint("TOPLEFT",10,-45)
	self.Background.TemplateOption.Editbox:SetWidth(175)
	self.Background.TemplateOption.Editbox:SetHeight(15)
	self.Background.TemplateOption.Editbox:SetMaxLetters(20)
	self.Background.TemplateOption.Editbox:SetAutoFocus(true)
	self.Background.TemplateOption.Editbox:SetText("")
	
	self.Background.TemplateOption.AddButton = CreateFrame("Button",nil,self.Background.TemplateOption,"UIPanelButtonTemplate")
	self.Background.TemplateOption.AddButton:SetPoint("TOPLEFT",40,-75)
	self.Background.TemplateOption.AddButton:SetFrameStrata("MEDIUM")
	self.Background.TemplateOption.AddButton:SetWidth(120)
	self.Background.TemplateOption.AddButton:SetHeight(18)
	self.Background.TemplateOption.AddButton:SetText("Create Template")
	self.Background.TemplateOption.AddButton:SetScript("OnClick", function () PlaySound(882, "Master"); HealingAsssignments.Mainframe:AddTemplate() self.Background.TemplateOption:Hide()	end)
	
	self.Background.TemplateOption:Hide()	
	
	-- Template Template Delete Popup Frame
	local backdrop = {bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground", edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",tile = true, tileSize = 32, edgeSize = 16, insets = { left = 5, right = 5, top = 5, bottom = 5 }}  -- path to the background texture
	self.Background.TemplateDeleteOption:SetFrameStrata("MEDIUM")
	self.Background.TemplateDeleteOption:SetWidth(200) -- Set these to whatever height/width is needed 
	self.Background.TemplateDeleteOption:SetHeight(100) -- for your Texture
	self.Background.TemplateDeleteOption:SetBackdrop(backdrop)
	self.Background.TemplateDeleteOption:	SetAlpha(1)
	self.Background.TemplateDeleteOption:SetPoint("TOPLEFT", self, "TOPLEFT", 185, -100)
	
	local TemplateDeleteOptionHeaderFontString = self.Background.TemplateDeleteOption:CreateFontString(nil, "OVERLAY")
    TemplateDeleteOptionHeaderFontString:SetPoint("TOPLEFT", self.Background.TemplateDeleteOption, "TOPLEFT", 0, -10)
	TemplateDeleteOptionHeaderFontString:SetFont("Fonts\\FRIZQT__.TTF", 9)
	TemplateDeleteOptionHeaderFontString:SetWidth(200)
	TemplateDeleteOptionHeaderFontString:SetJustifyH("CENTER")
    TemplateDeleteOptionHeaderFontString:SetText("Delete Template")
	
	local TemplateDeleteOptionText1FontString = self.Background.TemplateDeleteOption:CreateFontString(nil, "OVERLAY")
    TemplateDeleteOptionText1FontString:SetPoint("TOPLEFT", self.Background.TemplateDeleteOption, "TOPLEFT", 10, -30)
	TemplateDeleteOptionText1FontString:SetFont("Fonts\\FRIZQT__.TTF", 9)
	TemplateDeleteOptionText1FontString:SetWidth(200)
	TemplateDeleteOptionText1FontString:SetJustifyH("LEFT")
    TemplateDeleteOptionText1FontString:SetText("Do you want to delete this Template?")
	
	self.TemplateDeleteOptionText2FontString = self.Background.TemplateDeleteOption:CreateFontString(nil, "OVERLAY")
    self.TemplateDeleteOptionText2FontString:SetPoint("TOPLEFT", self.Background.TemplateDeleteOption, "TOPLEFT", 70, -50)
	self.TemplateDeleteOptionText2FontString:SetFont("Fonts\\FRIZQT__.TTF", 11)
	self.TemplateDeleteOptionText2FontString:SetJustifyH("Center")

	self.Background.TemplateDeleteOption.DeleteButton = CreateFrame("Button",nil,self.Background.TemplateDeleteOption,"UIPanelButtonTemplate")
	self.Background.TemplateDeleteOption.DeleteButton:SetPoint("TOPLEFT",10,-75)
	self.Background.TemplateDeleteOption.DeleteButton:SetFrameStrata("MEDIUM")
	self.Background.TemplateDeleteOption.DeleteButton:SetWidth(80)
	self.Background.TemplateDeleteOption.DeleteButton:SetHeight(18)
	self.Background.TemplateDeleteOption.DeleteButton:SetText("Delete")
	self.Background.TemplateDeleteOption.DeleteButton:SetScript("OnClick", function() PlaySound(882, "Master") end)
	
	self.Background.TemplateDeleteOption.KeepButton = CreateFrame("Button",nil,self.Background.TemplateDeleteOption,"UIPanelButtonTemplate")
	self.Background.TemplateDeleteOption.KeepButton:SetPoint("TOPLEFT",110,-75)
	self.Background.TemplateDeleteOption.KeepButton:SetFrameStrata("MEDIUM")
	self.Background.TemplateDeleteOption.KeepButton:SetWidth(80)
	self.Background.TemplateDeleteOption.KeepButton:SetHeight(18)
	self.Background.TemplateDeleteOption.KeepButton:SetText("Keep")
	self.Background.TemplateDeleteOption.KeepButton:SetScript("OnClick", function() PlaySound(882, "Master") 
	self.Background.TemplateDeleteOption:Hide()	end)
	self.Background.TemplateDeleteOption:Hide()
	
	-- create Buttons --
	-- Close Button
	self.CloseButton = CreateFrame("Button",nil,self,"UIPanelCloseButton")
	self.CloseButton:SetPoint("TOPLEFT",self:GetWidth()-29,-8)
	self.CloseButton:SetFrameStrata("LOW")

	-- Add Tank Button
	self.AddTankButton = CreateFrame("Button",nil,self,"UIPanelButtonTemplate")
	self.AddTankButton:SetPoint("TOPLEFT",521,-412)
	self.AddTankButton:SetFrameStrata("LOW")
	self.AddTankButton:SetWidth(79)
	self.AddTankButton:SetHeight(18)
	self.AddTankButton:SetText("Add Tank")
	self.AddTankButton:SetScript("OnClick", function() PlaySound(882, "Master"); HealingAsssignments.Mainframe:AddTankDropdown()	end)
	self.AddTankButton:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(HealingAsssignments.Mainframe, "ANCHOR_TOPLEFT");
		GameTooltip:SetText("Add a Tank Dropdown.", 1, 1, 1, 1, 1);
		GameTooltip:Show()
	end)
	self.AddTankButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	-- Add Healer Button
	self.AddHealerButton = CreateFrame("Button",nil,self,"UIPanelButtonTemplate")
	self.AddHealerButton:SetPoint("TOPLEFT",601,-412)
	self.AddHealerButton:SetFrameStrata("LOW")
	self.AddHealerButton:SetWidth(79)
	self.AddHealerButton:SetHeight(18)
	self.AddHealerButton:SetText("Add Healer")
	self.AddHealerButton:SetScript("OnClick", function() 
		PlaySound(882, "Master"); 
		HealingAsssignments.Mainframe:AddHealerDropdown()	
	end);
	self.AddHealerButton:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(HealingAsssignments.Mainframe, "ANCHOR_TOPLEFT");
		GameTooltip:SetText("Add a Healer Dropdown.", 1, 1, 1, 1, 1);
		GameTooltip:Show()
	end)
	self.AddHealerButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	-- Reset Button
	self.ResetButton = CreateFrame("Button",nil,self,"UIPanelButtonTemplate")
	self.ResetButton:SetPoint("TOPLEFT",681,-412)
	self.ResetButton:SetFrameStrata("LOW")
	self.ResetButton:SetWidth(79)
	self.ResetButton:SetHeight(18)
	self.ResetButton:SetText("Reset")
	self.ResetButton:SetScript("OnClick", function() 
		PlaySound(882, "Master");
		HealingAsssignments.Mainframe:ResetDropdownText() 
	end);
	self.ResetButton:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(HealingAsssignments.Mainframe, "ANCHOR_TOPLEFT");
		GameTooltip:SetText("Reset the opened Assignments.", 1, 1, 1, 1, 1);
		GameTooltip:Show()
	end);
	self.ResetButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	-- AddTemplate Button
	self.AddTemplateButton = CreateFrame("Button",nil,self,"UIPanelButtonTemplate")
	self.AddTemplateButton:SetPoint("TOPLEFT",38,-78)
	self.AddTemplateButton:SetFrameStrata("LOW")
	self.AddTemplateButton:SetWidth(95)
	self.AddTemplateButton:SetHeight(22)
	self.AddTemplateButton:SetText("Add Template")
	self.AddTemplateButton:SetScript("OnClick", function() PlaySound(882, "Master"); HealingAsssignments.Mainframe:OpenTemplateOptions()	end)
	self.AddTemplateButton:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(HealingAsssignments.Mainframe, "ANCHOR_TOPLEFT");
		GameTooltip:SetText("Open Template Creation Window.", 1, 1, 1, 1, 1);
		GameTooltip:Show()
	end)
	self.AddTemplateButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	-- Open Options Button
	self.OpenOptionsButton = CreateFrame("Button",nil,self,"UIPanelButtonTemplate")
	self.OpenOptionsButton:SetPoint("TOPLEFT",680,-78)
	self.OpenOptionsButton:SetFrameStrata("LOW")
	self.OpenOptionsButton:SetWidth(79)
	self.OpenOptionsButton:SetHeight(18)
	self.OpenOptionsButton:SetText("Options")
	self.OpenOptionsButton:SetScript("OnClick", function() 
		PlaySound(882, "Master"); 
		if self.ActiveFrame ~= 16 then 
			HealingAsssignments.Mainframe:SelectActiveTemplate(16,1)	
		elseif self.ActiveFrame == 16 then 
			HealingAsssignments.Mainframe:SelectActiveTemplate(HealingAsssignments.Mainframe.ActiveFrameBuffer) 
		end
	end);
	self.OpenOptionsButton:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(HealingAsssignments.Mainframe, "ANCHOR_TOPLEFT");
		GameTooltip:SetText("Open Options Frame.", 1, 1, 1, 1, 1);
		GameTooltip:Show()
	end)
	self.OpenOptionsButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	
	-- Open Sync Button
	self.SyncButton = CreateFrame("Button",nil,self,"UIPanelButtonTemplate")
	self.SyncButton:SetPoint("TOPLEFT",480,-48)
	self.SyncButton:SetFrameStrata("MEDIUM")
	self.SyncButton:SetWidth(60)
	self.SyncButton:SetHeight(18)
	self.SyncButton:SetText("Sync!")
	self.SyncButton:SetScript("OnClick", function() 
		PlaySound(882, "Master");
		HealingAsssignments.Syncframe:TriggerSync()
	end);
	self.SyncButton:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(HealingAsssignments.Mainframe, "ANCHOR_TOPLEFT");
		GameTooltip:SetText("Sync your template with other addon-users in raid.", 1, 1, 1, 1, 1);
		GameTooltip:Show()
	end);
	self.SyncButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	-- create FontStrings
	-- Title String
	local TitleFontString = self.Background.Topleft:CreateFontString(nil, "OVERLAY")
    TitleFontString:SetPoint("TOPLEFT", self, "TOPLEFT", 290, -18)
    TitleFontString:SetFont("Fonts\\FRIZQT__.TTF", 14)
    TitleFontString:SetText("Classic Healing Assignments")
	
	-- Bottom String
	self.BottomLeftFontString = self.Background.Topleft:CreateFontString(nil, "OVERLAY")
    self.BottomLeftFontString:SetPoint("TOPLEFT", self, "TOPLEFT", 24, -416)
    self.BottomLeftFontString:SetFont("Fonts\\FRIZQT__.TTF", 11)
    self.BottomLeftFontString:SetText("Number of Healers: ")
	
	-- HealerChannel String
	local HealerChannelFontString = self.Background.Topleft:CreateFontString(nil, "OVERLAY")
    HealerChannelFontString:SetPoint("TOPLEFT", self, "TOPLEFT", 290, -80)
    HealerChannelFontString:SetFont("Fonts\\FRIZQT__.TTF", 11)
	HealerChannelFontString:SetWidth(150)
	HealerChannelFontString:SetJustifyH("RIGHT")
    HealerChannelFontString:SetText("Healer Channel: ")
	
	-- Sync Data String
	local SyncDataFontString = self.Background.Topleft:CreateFontString(nil, "OVERLAY")
    SyncDataFontString:SetPoint("TOPLEFT", self, "TOPLEFT", 290, -50)
    SyncDataFontString:SetFont("Fonts\\FRIZQT__.TTF", 11)
	SyncDataFontString:SetWidth(150)
	SyncDataFontString:SetJustifyH("RIGHT")
    SyncDataFontString:SetText("Sync Data: ")
	
	-- Death Warnings String
	local DeathWarningsFontString = self.Background.Topleft:CreateFontString(nil, "OVERLAY")
    DeathWarningsFontString:SetPoint("TOPLEFT", self, "TOPLEFT", 160, -50)
    DeathWarningsFontString:SetFont("Fonts\\FRIZQT__.TTF", 11)
	DeathWarningsFontString:SetWidth(100)
	DeathWarningsFontString:SetJustifyH("RIGHT")
    DeathWarningsFontString:SetText("Death Warnings: ")
	
	-- Selected Healer Channel String
	self.HealerChannelSelectedFontString = self.Background.Topleft:CreateFontString(nil, "OVERLAY")
    self.HealerChannelSelectedFontString:SetPoint("TOPLEFT", self, "TOPLEFT", 480, -80)
    self.HealerChannelSelectedFontString:SetFont("Fonts\\FRIZQT__.TTF", 11)
	self.HealerChannelSelectedFontString:SetWidth(200)
	self.HealerChannelSelectedFontString:SetJustifyH("LEFT")
    self.HealerChannelSelectedFontString:SetText("TEST")
	
	-- sync profiles string
	self.SyncProfilesString = self.Background.Topleft:CreateFontString(nil, "OVERLAY")
	self.SyncProfilesString:SetPoint("TOPLEFT", self, "TOPLEFT", 190, -416)
    self.SyncProfilesString:SetFont("Fonts\\FRIZQT__.TTF", 11)
    self.SyncProfilesString:SetText("Active Profile:     "..UnitName("player"))
	
	-- create Checkboxes
	-- Death Warning Checkbox
	self.DeathWarningCheckbox = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
	self.DeathWarningCheckbox:SetPoint("TOPLEFT",260,-42)
	self.DeathWarningCheckbox:SetFrameStrata("LOW")
	self.DeathWarningCheckbox:SetScript("OnClick", function () 
		if not self.DeathWarningCheckbox:GetChecked() then HealingAssignmentsTemplates.Options.Deathwarnings = nil
		elseif self.DeathWarningCheckbox:GetChecked() then HealingAssignmentsTemplates.Options.Deathwarnings = 1 end
		end)
	self.DeathWarningCheckbox:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(HealingAsssignments.Mainframe, "ANCHOR_TOPLEFT");
		GameTooltip:SetText("Post warning if an assigned healer dies.", 1, 1, 1, 1, 1);
		GameTooltip:Show()
	end)
	self.DeathWarningCheckbox:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.DeathWarningCheckbox:SetChecked(HealingAssignmentsTemplates.Options.Deathwarnings)

	-- Sync Checkbox
	self.SyncCheckbox = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
	self.SyncCheckbox:SetPoint("TOPLEFT",440,-42)
	self.SyncCheckbox:SetFrameStrata("LOW")
	self.SyncCheckbox:SetScript("OnClick", function () 
		PlaySound(882, "Master");
		if not self.SyncCheckbox:GetChecked() then 
			HealingAssignmentsTemplates.Options.SyncData = nil; 
			HealingAsssignments.Mainframe.SyncButton:Disable();
		elseif self.SyncCheckbox:GetChecked() then 
			HealingAssignmentsTemplates.Options.SyncData = 1; 
			HealingAsssignments.Mainframe.SyncButton:Enable(); 
		end 
		end)
	self.SyncCheckbox:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(HealingAsssignments.Mainframe, "ANCHOR_TOPLEFT");
		GameTooltip:SetText("Sync your template with other addon-users in raid.", 1, 1, 1, 1, 1);
		GameTooltip:Show()
	end)
	self.SyncCheckbox:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.SyncCheckbox:SetChecked(HealingAssignmentsTemplates.Options.SyncData)
	if HealingAssignmentsTemplates.Options.SyncData == nil then HealingAsssignments.Mainframe.SyncButton:Disable(); end
	
	
	-- create Editbox
	-- Healer Channel EditBox
	self.HealerChannelEditBox = CreateFrame("EditBox", nil, self,"InputBoxTemplate")
	self.HealerChannelEditBox:SetPoint("TOPLEFT",449,-72)
	self.HealerChannelEditBox:SetWidth(18)
	self.HealerChannelEditBox:SetHeight(30)
	self.HealerChannelEditBox:SetMaxLetters(1)
	self.HealerChannelEditBox:SetAutoFocus(false)
	self.HealerChannelEditBox:SetFrameStrata("MEDIUM")
	self.HealerChannelEditBox:SetScript("OnTextChanged", function() PlaySound(882, "Master");
		HealingAssignmentsTemplates.Options.HealerChannel = self.HealerChannelEditBox:GetText()
		HealingAsssignments.Mainframe:SetHealerChannelString()
		-- HealingAsssignments.Mainframe.Foreground.Profile[1].Template[OptionsFrameNum].Assigments.Content.DeathWarningChannelTextbox:SetText(HealingAssignmentsTemplates.Options.HealerChannel)
		end)
	if HealingAssignmentsTemplates.Options.HealerChannel then self.HealerChannelEditBox:SetText(HealingAssignmentsTemplates.Options.HealerChannel) end	
	
	-- Create sync Dropdown and select
	self.ProfileDropdown = CreateFrame("Button","HAProfileDropdown", self, "UIDropDownMenuTemplate")
	self.ProfileDropdown:SetPoint("TOPLEFT",670,-56)
	self.ProfileDropdown:SetScale(0.8)
	_G[HealingAsssignments.Mainframe.ProfileDropdown:GetName().."Text"]:SetText(UnitName("player"));
	_G[HealingAsssignments.Mainframe.ProfileDropdown:GetName().."Button"]:SetScript("OnClick", function(self, ...) 
		HealingAsssignments.Syncframe:UpdateDropdown(...)
		PlaySound(882, "Master");
		ToggleDropDownMenu(1, nil, HealingAsssignments.Mainframe.ProfileDropdown, self:GetName(), 0, 0);
	end);
	
	self.SyncDeleteButton = CreateFrame("Button",nil,self,"UIPanelButtonTemplate")
	self.SyncDeleteButton:SetPoint("TOPLEFT",665,-46)
	self.SyncDeleteButton:SetWidth(18)
	self.SyncDeleteButton:SetHeight(18)
	self.SyncDeleteButton:SetFrameStrata("MEDIUM")
	self.SyncDeleteButton:SetText("X")
	self.SyncDeleteButton:SetScript("OnClick", function() PlaySound(882, "Master")
												HealingAsssignments.Syncframe:DeleteProfile()
												end)
	self.SyncDeleteButton:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(HealingAsssignments.Mainframe, "ANCHOR_TOPLEFT");
		GameTooltip:SetText("Delete the current Sync Profile.", 1, 1, 1, 1, 1);
		GameTooltip:Show()
	end)
	self.SyncDeleteButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.SyncDeleteButton:Disable()
	
	-- Create Minimap Icon
	HealingAsssignments.Minimap:CreateMinimapIcon()
	
	-- dynamic creation --
	----------------------
	-- create Templates
	HealingAsssignments.Mainframe:LoadTemplates() -- load old templates
	HealingAsssignments.Mainframe:AddAssignmentFrame(1,OptionsFrameNum) -- create Options Frame
	HealingAsssignments.Mainframe:CreateOptions(OptionsFrameNum) -- config Frame
	HealingAsssignments.Mainframe:SetHealerChannelString() -- set channelname string
	HealingAsssignments.Syncframe:SelectProfile(1)
	HealingAsssignments.Mainframe:SelectActiveTemplate(1)

	-- show frame
	HealingAsssignments.Syncframe:UpdateDropdown()
	HealingAsssignments:SetNumberOfHealers()
	HealingAsssignments.Mainframe:Hide()
end


function HealingAsssignments.Mainframe:CreateOptions(TemplateNumber)
	-- reset scroll frame
	--self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:SetHeight(100) 
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Scrollbar:SetMinMaxValues(0, 90)

	-- create bottom text
	local String1 = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
    String1:SetPoint("TOPLEFT", -70, -20)
    String1:SetFont("Fonts\\FRIZQT__.TTF", 11)
	String1:SetWidth(200)
	String1:SetJustifyH("RIGHT")
    String1:SetText("Post Bottom Text:")
	
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.BottomText = CreateFrame("EditBox", "BottomTextEditBox", self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content,"InputBoxTemplate")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.BottomText:SetPoint("TOPLEFT",160,-10)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.BottomText:SetWidth(370)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.BottomText:SetHeight(30)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.BottomText:SetAutoFocus(0)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.BottomText:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.BottomText:SetText("Everyone else: Raid heal.")
	
	-- create additional tanks
	local String2 = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
    String2:SetPoint("TOPLEFT", -70, -50)
    String2:SetFont("Fonts\\FRIZQT__.TTF", 11)
	String2:SetWidth(200)
	String2:SetJustifyH("RIGHT")
    String2:SetText("additional Tanks:")

	-- Warlock:
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.WarlockCheckbox = CreateFrame("CheckButton", nil, self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content, "UICheckButtonTemplate")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.WarlockCheckbox:SetPoint("TOPLEFT",150,-40)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.WarlockCheckbox:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.WarlockCheckbox:SetScript("OnClick", function () 
		PlaySound(882, "Master");
		if(HealingAsssignments.Mainframe.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.WarlockCheckbox:GetChecked()) then
			HealingAssignmentsTemplates.Options.TankAsWarlock = 1 
		else
			HealingAssignmentsTemplates.Options.TankAsWarlock = nil;
		end;
	end);
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.WarlockCheckbox:SetChecked(HealingAssignmentsTemplates.Options.TankAsWarlock)
	
	local Warlock = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
    Warlock:SetPoint("TOPLEFT", 190, -50)
    Warlock:SetFont("Fonts\\FRIZQT__.TTF", 11)
	Warlock:SetJustifyH("RIGHT")
    Warlock:SetText("Warlock")
	Warlock:SetTextColor(0.58, 0.51, 0.79,1)
	
	-- Druid:
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.DruidCheckbox = CreateFrame("CheckButton", nil, self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content, "UICheckButtonTemplate")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.DruidCheckbox:SetPoint("TOPLEFT",300,-40)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.DruidCheckbox:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.DruidCheckbox:SetScript("OnClick", function () 
		PlaySound(882, "Master");
		if(HealingAsssignments.Mainframe.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.DruidCheckbox:GetChecked()) then
			HealingAssignmentsTemplates.Options.TankAsDruid = 1 
		else
			HealingAssignmentsTemplates.Options.TankAsDruid = nil;
		end;
	end);
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.DruidCheckbox:SetChecked(HealingAssignmentsTemplates.Options.TankAsDruid)
	
	local Druid = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
    Druid:SetPoint("TOPLEFT", 340, -50)
    Druid:SetFont("Fonts\\FRIZQT__.TTF", 11)
	Druid:SetJustifyH("RIGHT")
    Druid:SetText("Druid")
	Druid:SetTextColor(1.00, 0.49, 0.04,1)
	
	-- Rogue:
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.RogueCheckbox = CreateFrame("CheckButton", nil, self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content, "UICheckButtonTemplate")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.RogueCheckbox:SetPoint("TOPLEFT",450,-40)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.RogueCheckbox:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.RogueCheckbox:SetScript("OnClick", function (self) 
		PlaySound(882, "Master");
		if(HealingAsssignments.Mainframe.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.RogueCheckbox:GetChecked()) then
			HealingAssignmentsTemplates.Options.TankAsRogue = 1 
		else
			HealingAssignmentsTemplates.Options.TankAsRogue = nil;
		end;
	end);
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.RogueCheckbox:SetChecked(HealingAssignmentsTemplates.Options.TankAsRogue)
	
	local Rogue = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
    Rogue:SetPoint("TOPLEFT", 490, -50)
    Rogue:SetFont("Fonts\\FRIZQT__.TTF", 11)
	Rogue:SetJustifyH("RIGHT")
    Rogue:SetText("Rogue")
	Rogue:SetTextColor(1.00, 0.96, 0.41,1)

	-- Hunter:
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.HunterCheckbox = CreateFrame("CheckButton", nil, self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content, "UICheckButtonTemplate")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.HunterCheckbox:SetPoint("TOPLEFT",150,-70)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.HunterCheckbox:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.HunterCheckbox:SetScript("OnClick", function (self) 
		PlaySound(882, "Master");
		if(HealingAsssignments.Mainframe.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.HunterCheckbox:GetChecked()) then
			HealingAssignmentsTemplates.Options.TankAsHunter = 1 
		else
			HealingAssignmentsTemplates.Options.TankAsHunter = nil;
		end;
	end);
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.HunterCheckbox:SetChecked(HealingAssignmentsTemplates.Options.TankAsHunter)
	
	local Hunter = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
    Hunter:SetPoint("TOPLEFT", 190, -80)
    Hunter:SetFont("Fonts\\FRIZQT__.TTF", 11)
	Hunter:SetJustifyH("RIGHT")
    Hunter:SetText("Hunter")
	Hunter:SetTextColor(0.67, 0.83, 0.45,1)
	
	---	Mage:
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.MageCheckbox = CreateFrame("CheckButton", nil, self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content, "UICheckButtonTemplate")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.MageCheckbox:SetPoint("TOPLEFT",300,-70)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.MageCheckbox:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.MageCheckbox:SetScript("OnClick", function (self) 
		PlaySound(882, "Master");
		if(HealingAsssignments.Mainframe.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.MageCheckbox:GetChecked()) then
			HealingAssignmentsTemplates.Options.TankAsMage = 1 
		else
			HealingAssignmentsTemplates.Options.TankAsMage = nil;
		end;
	end);
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.MageCheckbox:SetChecked(HealingAssignmentsTemplates.Options.TankAsMage)		
	
	local Mage = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
    Mage:SetPoint("TOPLEFT", 340, -80)
    Mage:SetFont("Fonts\\FRIZQT__.TTF", 11)
	Mage:SetJustifyH("RIGHT")
    Mage:SetText("Mage")
	Mage:SetTextColor(0.41, 0.80, 0.94,1)

	--	Shaman:
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.ShamanCheckbox = CreateFrame("CheckButton", nil, self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content, "UICheckButtonTemplate")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.ShamanCheckbox:SetPoint("TOPLEFT",450,-70)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.ShamanCheckbox:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.ShamanCheckbox:SetScript("OnClick", function (self) 
		PlaySound(882, "Master");
		if(HealingAsssignments.Mainframe.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.ShamanCheckbox:GetChecked()) then
			HealingAssignmentsTemplates.Options.TankAsShaman = 1 
		else
			HealingAssignmentsTemplates.Options.TankAsShaman = nil;
		end;
	end);
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.ShamanCheckbox:SetChecked(HealingAssignmentsTemplates.Options.TankAsShaman)			
	
	local Shaman = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
    Shaman:SetPoint("TOPLEFT", 490, -80)
    Shaman:SetFont("Fonts\\FRIZQT__.TTF", 11)
	Shaman:SetJustifyH("RIGHT")
    Shaman:SetText("Shaman")
	Shaman:SetTextColor(0.96, 0.55, 0.73,1)
	
	--	Priest:
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.PriestCheckbox = CreateFrame("CheckButton", nil, self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content, "UICheckButtonTemplate")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.PriestCheckbox:SetPoint("TOPLEFT",150,-100)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.PriestCheckbox:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.PriestCheckbox:SetScript("OnClick", function (self) 
		PlaySound(882, "Master");
		if(HealingAsssignments.Mainframe.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.PriestCheckbox:GetChecked()) then
			HealingAssignmentsTemplates.Options.TankAsPriest = 1 
		else
			HealingAssignmentsTemplates.Options.TankAsPriest = nil;
		end;
	end);
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.PriestCheckbox:SetChecked(HealingAssignmentsTemplates.Options.TankAsPriest)			

	local Priest = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
    Priest:SetPoint("TOPLEFT", 190, -110)
    Priest:SetFont("Fonts\\FRIZQT__.TTF", 11)
	Priest:SetJustifyH("RIGHT")
    Priest:SetText("Priest")
	Priest:SetTextColor(1.00, 1.00, 1.00,1)

	--	Paladin:
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.PaladinCheckbox = CreateFrame("CheckButton", nil, self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content, "UICheckButtonTemplate")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.PaladinCheckbox:SetPoint("TOPLEFT",300,-100)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.PaladinCheckbox:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.PaladinCheckbox:SetScript("OnClick", function (self) 
		PlaySound(882, "Master");
		if(HealingAsssignments.Mainframe.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.PaladinCheckbox:GetChecked()) then
			HealingAssignmentsTemplates.Options.TankAsPaladin = 1 
		else
			HealingAssignmentsTemplates.Options.TankAsPaladin = nil;
		end;
	end);
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.PaladinCheckbox:SetChecked(HealingAssignmentsTemplates.Options.TankAsPaladin)			
	
	local Paladin = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
    Paladin:SetPoint("TOPLEFT", 340, -110)
    Paladin:SetFont("Fonts\\FRIZQT__.TTF", 11)
	Paladin:SetJustifyH("RIGHT")
    Paladin:SetText("Paladin")
	Paladin:SetTextColor(0.96, 0.55, 0.73,1)

	--	Raid:
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.RaidCheckbox = CreateFrame("CheckButton", nil, self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content, "UICheckButtonTemplate")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.RaidCheckbox:SetPoint("TOPLEFT",420,-100)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.RaidCheckbox:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.RaidCheckbox:SetScript("OnClick", function (self) 
		PlaySound(882, "Master");
		if(HealingAsssignments.Mainframe.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.RaidCheckbox:GetChecked()) then
			HealingAssignmentsTemplates.Options.TankRaid = 1 
		else
			HealingAssignmentsTemplates.Options.TankRaid = nil;
		end;
	end);
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.RaidCheckbox:SetChecked(HealingAssignmentsTemplates.Options.Raid)			
	
	local Raid = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
    Raid:SetPoint("TOPLEFT", 460, -110)
    Raid:SetFont("Fonts\\FRIZQT__.TTF", 11)
	Raid:SetJustifyH("RIGHT")
    Raid:SetText("Raid")
	Raid:SetTextColor(.7, .1, 1,1)

	--	Custom target:
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.CustomCheckbox = CreateFrame("CheckButton", nil, self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content, "UICheckButtonTemplate")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.CustomCheckbox:SetPoint("TOPLEFT",150,-130)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.CustomCheckbox:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.CustomCheckbox:SetScript("OnClick", function (self) 
		PlaySound(882, "Master");
		if(HealingAsssignments.Mainframe.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.CustomCheckbox:GetChecked()) then
			HealingAssignmentsTemplates.Options.TankCustomTarget = 1 
		else
			HealingAssignmentsTemplates.Options.TankCustomTarget = nil;
		end;
	end);
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.CustomCheckbox:SetChecked(HealingAssignmentsTemplates.Options.TankCustomTarget)					
	
	local Custom = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
	Custom:SetPoint("TOPLEFT", 190, -140)
	Custom:SetFont("Fonts\\FRIZQT__.TTF", 11)
	Custom:SetJustifyH("RIGHT")
	Custom:SetText("Custom Text:")
	Custom:SetTextColor(1, .3, .8,1)
		
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.CustomCheckboxText = CreateFrame("EditBox", "CustomTextEditBox", self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content,"InputBoxTemplate")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.CustomCheckboxText:SetPoint("TOPLEFT",280,-130)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.CustomCheckboxText:SetWidth(90)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.CustomCheckboxText:SetHeight(30)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.CustomCheckboxText:SetAutoFocus(0)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.CustomCheckboxText:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.CustomCheckboxText:SetMaxLetters(40)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.CustomCheckboxText:SetText(" ")
	
	--	Ranged:
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.RangedCheckbox = CreateFrame("CheckButton", nil, self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content, "UICheckButtonTemplate")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.RangedCheckbox:SetPoint("TOPLEFT",420,-130)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.RangedCheckbox:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.RangedCheckbox:SetScript("OnClick", function (self) 
		PlaySound(882, "Master");
		if(HealingAsssignments.Mainframe.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.RangedCheckbox:GetChecked()) then
			HealingAssignmentsTemplates.Options.TankRanged = 1 
		else
			HealingAssignmentsTemplates.Options.TankRanged = nil;
		end;
	end);
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.RangedCheckbox:SetChecked(HealingAssignmentsTemplates.Options.TankRanged)			
	
	local Ranged = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
    Ranged:SetPoint("TOPLEFT", 460, -140)
    Ranged:SetFont("Fonts\\FRIZQT__.TTF", 11)
	Ranged:SetJustifyH("RIGHT")
    Ranged:SetText("Ranged")
	Ranged:SetTextColor(0, .8, 1,1)
	
	--	Custom2 target:
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom2Checkbox = CreateFrame("CheckButton", nil, self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content, "UICheckButtonTemplate")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom2Checkbox:SetPoint("TOPLEFT",150,-160)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom2Checkbox:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom2Checkbox:SetScript("OnClick", function (self) 
		PlaySound(882, "Master");
		if(HealingAsssignments.Mainframe.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom2Checkbox:GetChecked()) then
			HealingAssignmentsTemplates.Options.TankCustom2Target = 1 
		else
			HealingAssignmentsTemplates.Options.TankCustom2Target = nil;
		end;
	end);
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom2Checkbox:SetChecked(HealingAssignmentsTemplates.Options.TankCustom2Target)					
	
	local Custom2 = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
    Custom2:SetPoint("TOPLEFT", 190, -170)
    Custom2:SetFont("Fonts\\FRIZQT__.TTF", 11)
	Custom2:SetJustifyH("RIGHT")
    Custom2:SetText("Custom Text:")
	Custom2:SetTextColor(.1, 1, .6,1)
		
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom2CheckboxText = CreateFrame("EditBox", "Custom2TextEditBox", self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content,"InputBoxTemplate")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom2CheckboxText:SetPoint("TOPLEFT",280,-160)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom2CheckboxText:SetWidth(90)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom2CheckboxText:SetHeight(30)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom2CheckboxText:SetAutoFocus(0)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom2CheckboxText:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom2CheckboxText:SetMaxLetters(40)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom2CheckboxText:SetText(" ")

	--	Melee:
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.MeleeCheckbox = CreateFrame("CheckButton", nil, self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content, "UICheckButtonTemplate")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.MeleeCheckbox:SetPoint("TOPLEFT",420,-160)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.MeleeCheckbox:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.MeleeCheckbox:SetScript("OnClick", function (self)
		PlaySound(882, "Master");
		if(HealingAsssignments.Mainframe.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.MeleeCheckbox:GetChecked()) then
			HealingAssignmentsTemplates.Options.TankMelee = 1 
		else
			HealingAssignmentsTemplates.Options.TankMelee = nil;
		end;
	end);
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.MeleeCheckbox:SetChecked(HealingAssignmentsTemplates.Options.TankMelee)					
	
	local Melee = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
    Melee:SetPoint("TOPLEFT", 460, -170)
    Melee:SetFont("Fonts\\FRIZQT__.TTF", 11)
	Melee:SetJustifyH("RIGHT")
    Melee:SetText("Melee")
	Melee:SetTextColor(.9, .9, .3,1)

	--	Custom3 target:
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom3Checkbox = CreateFrame("CheckButton", nil, self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content, "UICheckButtonTemplate")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom3Checkbox:SetPoint("TOPLEFT",150,-190)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom3Checkbox:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom3Checkbox:SetScript("OnClick", function (self) 
		PlaySound(882, "Master");
		if(HealingAsssignments.Mainframe.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom3Checkbox:GetChecked()) then
			HealingAssignmentsTemplates.Options.TankCustom3Target = 1 
		else
			HealingAssignmentsTemplates.Options.TankCustom3Target = nil;
		end;
	end);
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom3Checkbox:SetChecked(HealingAssignmentsTemplates.Options.TankCustom3Target)					
			
	local Custom3 = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
	Custom3:SetPoint("TOPLEFT", 190, -200)
	Custom3:SetFont("Fonts\\FRIZQT__.TTF", 11)
	Custom3:SetJustifyH("RIGHT")
	Custom3:SetText("Custom Text:")
	Custom3:SetTextColor(.17, .41, .99, 1)
				
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom3CheckboxText = CreateFrame("EditBox", "Custom3TextEditBox", self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content,"InputBoxTemplate")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom3CheckboxText:SetPoint("TOPLEFT",280,-190)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom3CheckboxText:SetWidth(90)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom3CheckboxText:SetHeight(30)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom3CheckboxText:SetAutoFocus(0)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom3CheckboxText:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom3CheckboxText:SetMaxLetters(40)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom3CheckboxText:SetText(" ")
	
	--	Tanks:
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.TanksCheckbox = CreateFrame("CheckButton", nil, self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content, "UICheckButtonTemplate")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.TanksCheckbox:SetPoint("TOPLEFT",420,-190)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.TanksCheckbox:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.TanksCheckbox:SetScript("OnClick", function (self) 
		PlaySound(882, "Master");
		if(HealingAsssignments.Mainframe.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.TanksCheckbox:GetChecked()) then
			HealingAssignmentsTemplates.Options.TankTanks = 1 
		else
			HealingAssignmentsTemplates.Options.TankTanks = nil;
		end;
	end);
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.TanksCheckbox:SetChecked(HealingAssignmentsTemplates.Options.Tanks)			
	
	local Tanks = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
    Tanks:SetPoint("TOPLEFT", 460, -200)
    Tanks:SetFont("Fonts\\FRIZQT__.TTF", 11)
	Tanks:SetJustifyH("RIGHT")
    Tanks:SetText("Tanks")
	Tanks:SetTextColor(1, .1, .1,1)

	--	Custom4 target:
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom4Checkbox = CreateFrame("CheckButton", nil, self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content, "UICheckButtonTemplate")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom4Checkbox:SetPoint("TOPLEFT",150,-220)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom4Checkbox:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom4Checkbox:SetScript("OnClick", function (self) 
		PlaySound(882, "Master");
		if(HealingAsssignments.Mainframe.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom4Checkbox:GetChecked()) then
			HealingAssignmentsTemplates.Options.TankCustom4Target = 1 
		else
			HealingAssignmentsTemplates.Options.TankCustom4Target = nil;
		end;
	end);
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom4Checkbox:SetChecked(HealingAssignmentsTemplates.Options.TankCustom4Target)					
	
	local Custom4 = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
	Custom4:SetPoint("TOPLEFT", 190, -230)
	Custom4:SetFont("Fonts\\FRIZQT__.TTF", 11)
	Custom4:SetJustifyH("RIGHT")
	Custom4:SetText("Custom Text:")
	Custom4:SetTextColor(1, .5, .4,1)
		
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom4CheckboxText = CreateFrame("EditBox", "Custom4TextEditBox", self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content,"InputBoxTemplate")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom4CheckboxText:SetPoint("TOPLEFT",280,-220)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom4CheckboxText:SetWidth(90)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom4CheckboxText:SetHeight(30)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom4CheckboxText:SetAutoFocus(0)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom4CheckboxText:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom4CheckboxText:SetMaxLetters(40)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.Custom4CheckboxText:SetText(" ")
	

	-- Enable raid markers for tanks:
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.TankRaidMarkCheckbox = CreateFrame(
		"CheckButton", 
		nil, 
		self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content, 
		"UICheckButtonTemplate"
	)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.TankRaidMarkCheckbox:SetPoint("TOPLEFT",420,-220)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.TankRaidMarkCheckbox:SetFrameStrata("LOW")
	
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.TankRaidMarkCheckbox:SetScript("OnEnter", function(self) 
		GameTooltip:SetOwner(HealingAsssignments.Mainframe, "ANCHOR_TOPLEFT");
		GameTooltip:SetText("Add Raid Markers to Tank Dropdowns.", 1,1,1);
		GameTooltip:Show()
	end);
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.TankRaidMarkCheckbox:SetScript("OnLeave", function(self) 
		GameTooltip:Hide() 
	end);
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.TankRaidMarkCheckbox:SetScript("OnClick", function (self) 
		PlaySound(882, "Master");
		if(HealingAsssignments.Mainframe.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.TankRaidMarkCheckbox:GetChecked()) then
			HealingAssignmentsTemplates.Options.TankRaidMarkers = 1 
		else
			HealingAssignmentsTemplates.Options.TankRaidMarkers = nil;
		end;
	end);
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.TankRaidMarkCheckbox:SetChecked(HealingAssignmentsTemplates.Options.TankRaidMarkers)
		
	local TankRaidMark = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
	TankRaidMark:SetPoint("TOPLEFT", 460, -230)
	TankRaidMark:SetFont("Fonts\\FRIZQT__.TTF", 11)
	TankRaidMark:SetJustifyH("RIGHT")
	TankRaidMark:SetText("Raid Markers")
	TankRaidMark:SetTextColor(1, 1, 1,1)


		-- death warning options
	local DeathWarningText = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
    DeathWarningText:SetPoint("TOPLEFT", -70, -260)
    DeathWarningText:SetFont("Fonts\\FRIZQT__.TTF", 11)
	DeathWarningText:SetWidth(200)
	DeathWarningText:SetJustifyH("RIGHT")
    DeathWarningText:SetText("Death Warn Channel")
	
	local DeathWarningChannelText = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
    DeathWarningChannelText:SetPoint("TOPLEFT", 100, -260)
    DeathWarningChannelText:SetFont("Fonts\\FRIZQT__.TTF", 11)
	DeathWarningChannelText:SetWidth(200)
	DeathWarningChannelText:SetJustifyH("RIGHT")
    DeathWarningChannelText:SetText("Posting Channel:")
	
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.DeathWarningChannelTextbox = CreateFrame("EditBox", "DeathWarningChannelTextbox", self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content,"InputBoxTemplate")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.DeathWarningChannelTextbox:SetPoint("TOPLEFT",160,-250)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.DeathWarningChannelTextbox:SetWidth(18)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.DeathWarningChannelTextbox:SetHeight(30)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.DeathWarningChannelTextbox:SetAutoFocus(0)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.DeathWarningChannelTextbox:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.DeathWarningChannelTextbox:SetMaxLetters(1)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.DeathWarningChannelTextbox:SetScript("OnTextChanged", function() 
		-- new
		HealingAssignmentsTemplates.Options.DeathChannel = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.DeathWarningChannelTextbox:GetText()
		HealingAsssignments.Mainframe:SetHealerChannelString()
	end)
	if HealingAssignmentsTemplates.Options.DeathChannel then self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.DeathWarningChannelTextbox:SetText(HealingAssignmentsTemplates.Options.DeathChannel) end	

	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.ColoredPostingChannelText = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
    self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.ColoredPostingChannelText:SetPoint("TOPLEFT", 190, -260)
    self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.ColoredPostingChannelText:SetFont("Fonts\\FRIZQT__.TTF", 11)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.ColoredPostingChannelText:SetWidth(200)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.ColoredPostingChannelText:SetJustifyH("LEFT")
    self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.ColoredPostingChannelText:SetText("TEST")
	
		
	-- whisper configs
	local WhisperConfigText = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
    DeathWarningChannelText:SetPoint("TOPLEFT", -70, -290)
    DeathWarningChannelText:SetFont("Fonts\\FRIZQT__.TTF", 11)
	DeathWarningChannelText:SetWidth(200)
	DeathWarningChannelText:SetJustifyH("RIGHT")
    DeathWarningChannelText:SetText("Whisper Mode:")
	
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.WhisperHealCheckbox = CreateFrame("CheckButton", nil, self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content, "UICheckButtonTemplate")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.WhisperHealCheckbox:SetPoint("TOPLEFT",150,-280)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.WhisperHealCheckbox:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.WhisperHealCheckbox:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(HealingAsssignments.Mainframe, "ANCHOR_TOPLEFT");
		GameTooltip:SetText("Enable/Disable Auto-Whisper Assignments by whispers.", 1,1,1);
		GameTooltip:Show()
	end)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.WhisperHealCheckbox:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.WhisperHealCheckbox:SetScript("OnClick", function (self) 
		PlaySound(882, "Master");

		if HealingAsssignments.Mainframe.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.WhisperHealCheckbox:GetChecked() then
			HealingAssignmentsTemplates.Options.WhisperHeal = 1 
		else
			HealingAssignmentsTemplates.Options.WhisperHeal = nil
		end;
	end)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.WhisperHealCheckbox:SetChecked(HealingAssignmentsTemplates.Options.WhisperHeal)
	
	-- additional healers
	local AdditionHealersText = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
    AdditionHealersText:SetPoint("TOPLEFT", -70, -320)
    AdditionHealersText:SetFont("Fonts\\FRIZQT__.TTF", 11)
	AdditionHealersText:SetWidth(200)
	AdditionHealersText:SetJustifyH("RIGHT")
    AdditionHealersText:SetText("Additional Healers:")
	
	-- Healer raidmarks:
	local AdditionHealersMarksText = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
    AdditionHealersMarksText:SetPoint("TOPLEFT", 60, -320)
    AdditionHealersMarksText:SetFont("Fonts\\FRIZQT__.TTF", 11)
	AdditionHealersMarksText:SetWidth(200)
	AdditionHealersMarksText:SetJustifyH("RIGHT")
    AdditionHealersMarksText:SetText("Raid Markers")	
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.AdditionalHealersCheckbox = CreateFrame(
		"CheckButton", 
		nil, 
		self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content, 
		"UICheckButtonTemplate"
	)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.AdditionalHealersCheckbox:SetPoint("TOPLEFT",150,-310)
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.AdditionalHealersCheckbox:SetFrameStrata("LOW")
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.AdditionalHealersCheckbox:SetScript("OnEnter", function(self) 
		GameTooltip:SetOwner(HealingAsssignments.Mainframe, "ANCHOR_TOPLEFT");
		GameTooltip:SetText("Add Raid Markers to Healer Dropdowns.", 1,1,1);
		GameTooltip:Show()
	end);
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.AdditionalHealersCheckbox:SetScript("OnLeave", function(self) 
		GameTooltip:Hide() 
	end);
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.AdditionalHealersCheckbox:SetScript("OnClick", function (self) 
		PlaySound(882, "Master");
		if(HealingAsssignments.Mainframe.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.AdditionalHealersCheckbox:GetChecked()) then
			HealingAssignmentsTemplates.Options.AdditionHealers = 1 
		else
			HealingAssignmentsTemplates.Options.AdditionHealers = nil;
		end;
	end);
	self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content.AdditionalHealersCheckbox:SetChecked(HealingAssignmentsTemplates.Options.AdditionHealers)
	

	-- bottom
	local BottomText = self.Foreground.Profile[1].Template[TemplateNumber].Assigments.Content:CreateFontString(nil, "OVERLAY")
    BottomText:SetPoint("TOPLEFT", 150, -370)
    BottomText:SetFont("Fonts\\FRIZQT__.TTF", 11)
	BottomText:SetJustifyH("CENTER")
    BottomText:SetText("Version ".. GetAddOnMetadata("ClassicHealingAssignments", "Version") .." - by "..GetAddOnMetadata("ClassicHealingAssignments", "Author"))
	BottomText:SetTextColor(1, 1, 1,0.5)
end


-- -- Using LibDBIcon for minimap --
-- local ChaLDB = LibStub("LibDataBroker-1.1"):NewDataObject("ChaLDB", {
-- 	type = "data source",
-- 	text = "ChaLDB!",
-- 	icon = "Interface\Icons\INV_Chest_Cloth_17",
-- 	OnClick = function() print("BUNNIES ARE TAKING OVER THE WORLD") end,
-- 	})
-- local icon = LibStub("LibDBIcon-1.0")
	
-- function addon:OnInitialize() -- Obviously you'll need a ## SavedVariables: BunniesDB line in your TOC, duh! 
-- 	icon:Register("ChaLDB", ChaLDB, self.db.profile.minimap);
-- end
	
-- function addon:CommandTheBunnies() 
-- 	self.db.profile.minimap.hide = not self.db.profile.minimap.hide if self.db.profile.minimap.hide then icon:Hide("Bunnies!") else icon:Show("Bunnies!") end 
-- end


-- http://www.wowinterface.com/forums/archive/index.php/t-16339.html
function HealingAsssignments.Minimap:CreateMinimapIcon()
	local Moving = false
	
	function self:OnMouseUp()
		Moving = false;
	end
	
	function self:OnMouseDown(...)
		local arg1 = ...;

		PlaySound(882, "Master")
		Moving = false;

		if (arg1 == "LeftButton") then 
			if HealingAsssignments.Mainframe:IsVisible() then 
				HealingAsssignments.Mainframe:Hide()
			else 
				HealingAsssignments.Mainframe:Show() 
			end

		elseif (arg1 == "RightButton") then
			HealingAsssignments:PostAssignments()

		else 
			Moving = true;
		end
	end
	
	function self:OnUpdate()
		if Moving == true then
			
			local xpos,ypos = GetCursorPosition();
			local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom();
			xpos = xmin-xpos/UIParent:GetScale()+70;
			ypos = ypos/UIParent:GetScale()-ymin-70;
			local CHAIconPos = math.deg(math.atan2(ypos,xpos));
			if (CHAIconPos < 0) then
				CHAIconPos = CHAIconPos + 360
			end
			HealingAssignmentsTemplates.Options.MinimapX = 54 - (78 * cos(CHAIconPos));
			HealingAssignmentsTemplates.Options.MinimapY = (78 * sin(CHAIconPos)) - 55;
			
			HealingAsssignments.Minimap:SetPoint(
				"TOPLEFT",
				"Minimap",
				"TOPLEFT",
				HealingAssignmentsTemplates.Options.MinimapX,
				HealingAssignmentsTemplates.Options.MinimapY
			);
		end
	end
	
	function self:OnEnter()
		GameTooltip:SetOwner(HealingAsssignments.Minimap, "ANCHOR_LEFT");
		GameTooltip:SetText("Classic Initiative Healing Assignments");
		GameTooltip:AddLine("Left Click to show/hide menu.",1,1,1);
		GameTooltip:AddLine("Right Click to post open assignment window.",1,1,1);
		GameTooltip:AddLine("Middle Button Click to move Icon.",1,1,1);
		GameTooltip:Show()
	end
	
	function self:OnLeave()
		GameTooltip:Hide()
	end

	self:SetFrameStrata("LOW")
	self:SetWidth(31) -- Set these to whatever height/width is needed 
	self:SetHeight(31) -- for your Texture
	self:SetPoint("CENTER", -75, -20)
	
	self.Button = CreateFrame("Button",nil,self)
	self.Button:SetPoint("CENTER",0,0)
	self.Button:SetWidth(31)
	self.Button:SetHeight(31)
	self.Button:SetFrameLevel(8)
	self.Button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	self.Button:SetScript("OnMouseUp", self.OnMouseUp)
	self.Button:SetScript("OnMouseDown", self.OnMouseDown)
	self.Button:SetScript("OnUpdate", self.OnUpdate)
	self.Button:SetScript("OnEnter", self.OnEnter)
	self.Button:SetScript("OnLeave", self.OnLeave)
	
	local overlay = self:CreateTexture(nil, 'OVERLAY',self)
	overlay:SetWidth(53)
	overlay:SetHeight(53)
	overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	overlay:SetPoint('TOPLEFT',0,0)
	
	local icon = self:CreateTexture(nil, "BACKGROUND")
	icon:SetWidth(20)
	icon:SetHeight(20)
	icon:SetTexture("Interface\\AddOns\\ClassicHealingAssignments\\Media\\icon")
	icon:SetTexCoord(0.18, 0.82, 0.18, 0.82)
	icon:SetPoint('CENTER', 0, 0)
	self.icon = icon
	
	HealingAsssignments.Minimap:SetPoint(
			"TOPLEFT",
			"Minimap",
			"TOPLEFT",
			HealingAssignmentsTemplates.Options.MinimapX,
			HealingAssignmentsTemplates.Options.MinimapY)
end


function  HealingAsssignments.Mainframe:SetHealerChannelString()

	local channelChar = self.HealerChannelEditBox:GetText();
	if channelChar == "s" or  channelChar == "S" then self.HealerChannelSelectedFontString:SetText("Say");
	elseif channelChar == "r" or  channelChar == "R" then self.HealerChannelSelectedFontString:SetText("Raid");
	elseif channelChar == "p" or  channelChar == "P" then self.HealerChannelSelectedFontString:SetText("Group");
	elseif channelChar == "g" or  channelChar == "G" then self.HealerChannelSelectedFontString:SetText("Guild");
	elseif channelChar == "e" or  channelChar == "E" then self.HealerChannelSelectedFontString:SetText("Emote");
	elseif channelChar == "rw" or  channelChar == "RW" then self.HealerChannelSelectedFontString:SetText("Raid Warning");
	else local id, name = GetChannelName(channelChar); self.HealerChannelSelectedFontString:SetText(name)
	end
	
	local OptionsFrameNum = 16;
	local channelChar = HealingAsssignments.Mainframe.Foreground.Profile[1].Template[OptionsFrameNum].Assigments.Content.DeathWarningChannelTextbox:GetText()
	if channelChar == "s" or  channelChar == "S" then HealingAsssignments.Mainframe.Foreground.Profile[1].Template[OptionsFrameNum].Assigments.Content.ColoredPostingChannelText:SetText("Say");
	elseif channelChar == "r" or  channelChar == "R" then HealingAsssignments.Mainframe.Foreground.Profile[1].Template[OptionsFrameNum].Assigments.Content.ColoredPostingChannelText:SetText("Raid");
	elseif channelChar == "p" or  channelChar == "P" then HealingAsssignments.Mainframe.Foreground.Profile[1].Template[OptionsFrameNum].Assigments.Content.ColoredPostingChannelText:SetText("Group");
	elseif channelChar == "g" or  channelChar == "G" then HealingAsssignments.Mainframe.Foreground.Profile[1].Template[OptionsFrameNum].Assigments.Content.ColoredPostingChannelText:SetText("Guild");
	elseif channelChar == "e" or  channelChar == "E" then HealingAsssignments.Mainframe.Foreground.Profile[1].Template[OptionsFrameNum].Assigments.Content.ColoredPostingChannelText:SetText("Emote");
	elseif channelChar == "rw" or  channelChar == "RW" then HealingAsssignments.Mainframe.Foreground.Profile[1].Template[OptionsFrameNum].Assigments.Content.ColoredPostingChannelText:SetText("Raid Warning");
	else local id, name = GetChannelName(channelChar); HealingAsssignments.Mainframe.Foreground.Profile[1].Template[OptionsFrameNum].Assigments.Content.ColoredPostingChannelText:SetText(name)
	end
end


-- Adds a Template to Template Frame
function HealingAsssignments.Mainframe:AddTemplate()

	local TemplateNumber = 16;
	-- check whats next free Template Space
	for i=1,15 do
		if not self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[i] then
		 TemplateNumber = i; break
		end; 
		
	end
	-- create Template Frame
	if TemplateNumber <= 15 then
		HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber] = {}
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber] = {}
		local name = self.Background.TemplateOption.Editbox:GetText()
		-- create Template
		HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Name = name -- Save this to global
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Name = name;
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu = CreateFrame("Frame", nil, self) 
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu:SetFrameStrata("MEDIUM")
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu:SetWidth(130) -- Set these to whatever height/width is needed 
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu:SetHeight(20) -- for your Texture
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu:SetPoint("TOPLEFT", self, "TOPLEFT",23, (TemplateNumber * (-20)) -85)
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.colorBg = self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu:CreateTexture(nil, "BACKGROUND") 
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.colorBg:SetAllPoints(self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu) 
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.colorBg:SetTexture(0, 0, 0, 0.3)
			
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.ScriptButton = CreateFrame("Button",nil,self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu)
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.ScriptButton:SetFrameStrata("LOW")
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.ScriptButton:SetWidth(130)
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.ScriptButton:SetHeight(20)
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.ScriptButton:SetPoint("TOPLEFT", self, "TOPLEFT",23, (TemplateNumber * (-20)) -85)
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.ScriptButton:SetScript("OnClick", function() PlaySound(882, "Master")
			HealingAsssignments.Mainframe:SelectActiveTemplate(TemplateNumber)
		end)
					
		-- String
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.FontString = self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu:CreateFontString(nil, "OVERLAY")
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.FontString:SetPoint("TOPLEFT", self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu, "TOPLEFT", 5, -3)
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.FontString:SetFont("Fonts\\FRIZQT__.TTF", 11)
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.FontString:SetWidth(200)
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.FontString:SetJustifyH("LEFT")
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.FontString:SetText(HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Name)
					
		-- Button
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.Button = CreateFrame("Button",nil,self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu,"UIPanelButtonTemplate")
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.Button:SetPoint("TOPLEFT",133,0)
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.Button:SetFrameStrata("LOW")
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.Button:SetWidth(20)
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.Button:SetHeight(20)
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.Button:SetText("X")
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.Button:SetScript("OnClick", function() PlaySound(882, "Master")
			HealingAsssignments.Mainframe:OpenTemplateDeleteOptions(TemplateNumber)
		end)
				
		-- create scrollframe!
		HealingAsssignments.Mainframe:AddAssignmentFrame(HealingAsssignments.Mainframe.ActiveProfile,TemplateNumber)
		HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].TankNum = 0;
		HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].TankHealer = {}
		
	end
end

-- Function to Create the Assignment Scrolling Frame
function HealingAsssignments.Mainframe:AddAssignmentFrame(ProfileNum,TemplateNum)

	-- create scrollframe
	-- Assignment Scrollframe 
	if TemplateNum == 16 then self.Foreground.Profile[ProfileNum].Template[TemplateNum] = {} end -- for options menu
	if TemplateNum ~= 16 then
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments = CreateFrame("Frame",nil,self) -- Assignments Frame
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments:SetFrameStrata("LOW")
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments:SetWidth(723) -- Set these to whatever height/width is needed 
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments:SetHeight(380) -- for your Texture
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments:SetPoint("TOPLEFT", self, "TOPLEFT", 237, -130)
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments:SetScale(0.8)
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments:EnableMouseWheel(1)
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments:SetScript("OnMouseWheel", function(event, ...)
			local arg1 = ...;
			local value = self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollbar:GetValue()
			self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollbar:SetValue(value-(arg1*10))
		end)
		
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollframe = CreateFrame("ScrollFrame", nil, self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments) 
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollframe:SetPoint("TOPLEFT", 0, 0) 
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollframe:SetPoint("BOTTOMRIGHT", -15, 0) 
		
		--colored background for testing
		--self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollframe.colorBg = self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollframe:CreateTexture(nil, "BACKGROUND") 
		--self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollframe.colorBg:SetAllPoints(self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollframe) 
		--self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollframe.colorBg:SetTexture(1, 1, 1, 0.5)

		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollbar = CreateFrame("Slider", nil, self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments, "UIPanelScrollBarTemplate") 
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollbar:SetOrientation('VERTICAL')
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollbar:SetWidth(16) 
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollbar:SetHeight(346)
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollbar:SetPoint("TOPLEFT",690,-17)
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollbar:SetMinMaxValues(0, 0)
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollbar:SetValueStep(1)
		
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollbar:SetScript("OnValueChanged", function(...)
			local value = self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollbar:GetValue()
			self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollframe:SetVerticalScroll(value)
		end)

		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Content = CreateFrame("Frame", nil, self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollframe) 
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Content:SetWidth(565) -- Set these to whatever height/width is needed -- 128x128 before // watch for error!
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Content:SetHeight(300) -- for your Texture
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollframe:SetScrollChild(self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Content)
		
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments:Hide()
	
	else
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments = CreateFrame("Frame",nil,self) -- Assignments Frame
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments:SetFrameStrata("LOW")
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments:SetWidth(565) -- Set these to whatever height/width is needed 
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments:SetHeight(300) -- for your Texture
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments:SetPoint("TOPLEFT", self, "TOPLEFT", 190, -105)
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments:EnableMouseWheel(1)
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments:SetScript("OnMouseWheel", function(event, ...)
			local arg1 = ...;
			local value = self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollbar:GetValue()
			self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollbar:SetValue(value-(arg1*10))
		end)
	
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollframe = CreateFrame("ScrollFrame", nil, self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments) 
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollframe:SetPoint("TOPLEFT", 0, 0) 
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollframe:SetPoint("BOTTOMRIGHT", -15, 0) 

		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollbar = CreateFrame("Slider", nil, self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments, "UIPanelScrollBarTemplate") 
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollbar:SetOrientation('VERTICAL')
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollbar:SetWidth(16) 
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollbar:SetHeight(270)
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollbar:SetPoint("TOPLEFT",550,-16)
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollbar:SetMinMaxValues(0, 0)
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollbar:SetValueStep(1)
	
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollbar:SetScript("OnValueChanged", function(...)
			local value = self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollbar:GetValue()
			self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollframe:SetVerticalScroll(value)
		end)

		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Content = CreateFrame("Frame", nil, self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollframe) 
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Content:SetWidth(565) -- Set these to whatever height/width is needed -- 128x128 before // watch for error!
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Content:SetHeight(300) -- for your Texture
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Scrollframe:SetScrollChild(self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments.Content)
	
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments:Hide()
	end	
end


-- Function to Open the Template Creation Menu
function HealingAsssignments.Mainframe:OpenTemplateOptions()

	local TemplateNumber = 16;
	for i=1,15 do
		if not self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[i] then
		 TemplateNumber = i; break
		end; 
		
	end
	if TemplateNumber <= 15 then 
		self.Background.TemplateOption.Editbox:SetText("Template "..TemplateNumber)
		self.Background.TemplateOption:Show()
	end
end

-- Function to Open the Template Delete Menu
function HealingAsssignments.Mainframe:OpenTemplateDeleteOptions(TamplateNum)
	self.TemplateDeleteOptionText2FontString:SetText(HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TamplateNum].Menu.FontString:GetText())
	HealingAsssignments.Mainframe.Background.TemplateDeleteOption:Show()
	HealingAsssignments.Mainframe.Background.TemplateDeleteOption.DeleteButton:SetScript("OnClick", function() PlaySound(882, "Master") 
	HealingAsssignments.Mainframe:DeleteTemplate(TamplateNum); HealingAsssignments.Mainframe.Background.TemplateDeleteOption:Hide() end)
end

-- Function to load and create the Dynamic Frames
function HealingAsssignments.Mainframe:LoadTemplates()
	for j=1,11 do
		for i=1,15 do
			local TemplateNumber = i
			local ProfileNumber = j
			if HealingAssignmentsTemplates.Profile[ProfileNumber].Template[TemplateNumber] ~= nil then
				
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber] = {}
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu = CreateFrame("Frame", nil, self) 
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu:SetFrameStrata("MEDIUM")
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu:SetWidth(130) -- Set these to whatever height/width is needed 
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu:SetHeight(20) -- for your Texture
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu:SetPoint("TOPLEFT", self, "TOPLEFT",23, (TemplateNumber * (-20)) -85)
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu.colorBg = self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu:CreateTexture(nil, "BACKGROUND") 
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu.colorBg:SetAllPoints(self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu) 
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu.colorBg:SetTexture(0, 0, 0, 0.3)
				
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu.ScriptButton = CreateFrame("Button",nil,self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu)
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu.ScriptButton:SetFrameStrata("LOW")
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu.ScriptButton:SetWidth(130)
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu.ScriptButton:SetHeight(20)
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu.ScriptButton:SetPoint("TOPLEFT", self, "TOPLEFT",23, (TemplateNumber * (-20)) -85)
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu.ScriptButton:SetScript("OnClick", function()
					HealingAsssignments.Mainframe:SelectActiveTemplate(TemplateNumber)
					end)
						
				-- String
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu.FontString = self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu:CreateFontString(nil, "OVERLAY")
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu.FontString:SetPoint("TOPLEFT", self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu, "TOPLEFT", 5, -3)
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu.FontString:SetFont("Fonts\\FRIZQT__.TTF", 11)
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu.FontString:SetWidth(200)
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu.FontString:SetJustifyH("LEFT")
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu.FontString:SetText(HealingAssignmentsTemplates.Profile[ProfileNumber].Template[TemplateNumber].Name)
						
				-- Button
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu.Button = CreateFrame("Button",nil,self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu,"UIPanelButtonTemplate")
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu.Button:SetPoint("TOPLEFT",133,0)
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu.Button:SetFrameStrata("LOW")
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu.Button:SetWidth(20)
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu.Button:SetHeight(20)
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu.Button:SetText("X")
				self.Foreground.Profile[ProfileNumber].Template[TemplateNumber].Menu.Button:SetScript("OnClick", function()
					HealingAsssignments.Mainframe:OpenTemplateDeleteOptions(TemplateNumber)
					end)
				-- create scrollframe!
				HealingAsssignments.Mainframe:AddAssignmentFrame(ProfileNumber,TemplateNumber)
				-- create Dropdowns!
				HealingAsssignments.Mainframe:LoadDropdown(ProfileNumber,TemplateNumber)
			end 
		end
	end
end

-- Function to determinate and set the active Template
-- TemplateNum is the clicked Number of Template
function HealingAsssignments.Mainframe:SelectActiveTemplate(TemplateNum,ProfileNumber)
	local ProfileNum = HealingAsssignments.Mainframe.ActiveProfile
	if ProfileNumber then ProfileNum = ProfileNumber end
	
	if self.Foreground.Profile[ProfileNum].Template[TemplateNum] then
		for i=1,15 do
				if self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[i] then
					local TemplateNumber = i;
					self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.colorBg:SetTexture(0, 0, 0, 0.3)
					self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Assigments:Hide()
				end
		end
		
		if TemplateNum <= 15 then 
		self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNum].Menu.colorBg:SetTexture(1, 1, 1, 0.2); self.Foreground.Profile[1].Template[16].Assigments:Hide()  
		self.ActiveFrameBuffer = TemplateNum end -- excluse if options
		
		self.ActiveFrame = TemplateNum
		self.Foreground.Profile[ProfileNum].Template[TemplateNum].Assigments:Show()
		if TemplateNum <= 15 then self:SetScrollFrameHeight(HealingAsssignments.Mainframe.ActiveProfile,TemplateNum) end
		HealingAsssignments:UpdateRaidDataBase()
		
		if TemplateNum <= 15 then
			self.AddTankButton:Enable()
			self.AddHealerButton:Enable()
			self.ResetButton:Enable()
		else
			self.AddTankButton:Disable()
			self.AddHealerButton:Disable()
			self.ResetButton:Disable()
		end

	else
		self.AddTankButton:Disable()
		self.AddHealerButton:Disable()
		self.ResetButton:Disable()
	end
end

function HealingAsssignments.Mainframe:DeleteTemplate(TemplateNumber)
	self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.ScriptButton:Hide()
	self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu.ScriptButton:SetParent(nil)
	self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu:Hide()
	self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Menu:SetParent(nil)
	self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Assigments:Hide()
	self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber].Assigments:SetParent(nil)
	self.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber] = nil
	HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[TemplateNumber] = nil
	self.ActiveFrame = nil
end

-- create Frame for Dropdown + Tank Dropdown
function HealingAsssignments.Mainframe:AddTankDropdown(ProfileNum,TemplateNumber)
	local ActiveFrame = self.ActiveFrame
	local ActiveProfile = self.ActiveProfile
	local ActiveTankFrame
	if ProfileNum then ActiveProfile = ProfileNum end
	if TemplateNumber then ActiveFrame = TemplateNumber end
	
	if ActiveFrame ~= nil and ActiveFrame ~= 16 then
	
		if not self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame then 
			self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame = {} 
		end
		
		if self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame == nil then 
			ActiveTankFrame = 1
		else 
			ActiveTankFrame = table.getn(self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame) + 1 
		end
		
		self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame] = CreateFrame("Frame", nil, self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content);
		self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame]:SetFrameStrata("LOW")
		self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame]:SetWidth(565) -- Set these to whatever height/width is needed 
		self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame]:SetHeight(60) -- for your Texture
		local height = self:GetScrollFrameHeight(ActiveProfile,ActiveFrame)
		self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame]:SetPoint("TOPLEFT", 0, -height+60)
		local colorBg = self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame]:CreateTexture(nil, "BACKGROUND") 
		colorBg:SetAllPoints(self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame]) 
		colorBg:SetTexture(0, 0, 0, 0)
		
		-- add dropdown here
		self.DropDownCounter = self.DropDownCounter +1
		local DropDownCount = self.DropDownCounter
		if not self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame].Tank then 
			self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame].Tank = {} 
		end;
		self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame].Tank[ActiveTankFrame] = CreateFrame(
			"Button",
			"HADropdown"..DropDownCount, 
			self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame], 
			"UIDropDownMenuTemplate"
		)
		self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame].Tank[ActiveTankFrame]:SetPoint("TOPLEFT", -12, -20)

		_G[self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame].Tank[ActiveTankFrame]:GetName().."Button"]:SetScript("OnClick", function()
			local DropDownID = _G[self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame].Tank[ActiveTankFrame]:GetName()];
			HealingAsssignments.Mainframe:TankDropDownOnClick(DropDownID);
			PlaySound(882, "Master");
			ToggleDropDownMenu(1, nil, DropDownID, DropDownID:GetName(), 0, 0);
		end);

		_G[self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame].Tank[ActiveTankFrame]:GetName().."Text"]:SetText(" ");

		
		-- add font string
		local TankFontString = self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame].Tank[ActiveTankFrame]:CreateFontString(nil, "OVERLAY")
		TankFontString:SetPoint("CENTER", 62, 27)
		TankFontString:SetFont("Fonts\\FRIZQT__.TTF", 11)
		TankFontString:SetJustifyH("CENTER")
		TankFontString:SetText("Tank "..ActiveTankFrame)
		
		-- reconfigure scrollslider and save TankNum
		HealingAssignmentsTemplates.Profile[ActiveProfile].Template[ActiveFrame].TankNum = table.getn(self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame);
		self:SetScrollFrameHeight(ActiveProfile,ActiveFrame)
	end
end


function HealingAsssignments.Mainframe:AddHealerDropdown(ProfileNum,TemplateNumber)
	local ActiveFrame = self.ActiveFrame
	local ActiveProfile = self.ActiveProfile
	local ActiveTankFrame
	local ActiveHealerFrame
	local x;
	local y;
	if TemplateNumber then 
		ActiveFrame = TemplateNumber 
	end
	if ProfileNum then 
		ActiveProfile = ProfileNum 
	end
	
	if ActiveFrame ~= nil and ActiveFrame ~= 16 then
		if self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame ~= nil then 
			ActiveTankFrame = table.getn(self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame) 
		end

		if ActiveTankFrame ~= nil then
			if self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame].Healer == nil then 
				ActiveHealerFrame = 1
			else 
				ActiveHealerFrame = table.getn(self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame].Healer) + 1 
			end
		
			self.DropDownCounter = self.DropDownCounter +1
			local DropDownCount = self.DropDownCounter
			if not self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame].Healer then 
				self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame].Healer = {} 
			end;

			self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame].Healer[ActiveHealerFrame] = CreateFrame(
				"Button",
				"HADropdown"..DropDownCount, 
				self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame], 
				"UIDropDownMenuTemplate"
			);

			_G[self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame].Healer[ActiveHealerFrame]:GetName().."Button"]:SetScript("OnClick", function()
				local DropDownID = _G[self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame].Healer[ActiveHealerFrame]:GetName()];

				HealingAsssignments.Mainframe:HealerDropDownOnClick(DropDownID);
				PlaySound(882, "Master");
				ToggleDropDownMenu(1, nil, DropDownID, DropDownID:GetName(), 0, 0);
			end)

			_G[HealingAsssignments.Mainframe.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame].Healer[ActiveHealerFrame]:GetName().."Text"]:SetText(" ")
			
			if math.fmod(ActiveHealerFrame,4) == 1 then 
				x = 137; 
				y = math.floor((ActiveHealerFrame/4)-(1/5))*(-60); 
				self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame]:SetHeight((math.floor((ActiveHealerFrame/3)-(1/5)))*60+60)
			elseif math.fmod(ActiveHealerFrame,4) == 2 then 
				x = 274; 
				y = math.floor((ActiveHealerFrame/4)-(1/5))*(-60)
			elseif math.fmod(ActiveHealerFrame,4) == 3 then 
				x = 411; 
				y = math.floor((ActiveHealerFrame/4)-(1/5))*(-60)
			elseif math.fmod(ActiveHealerFrame,4) == 0 then 
				x = 548; 
				y = math.floor((ActiveHealerFrame/4)-(1/5))*(-60) 
			end
			self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame].Healer[ActiveHealerFrame]:SetPoint("TOPLEFT", x-12, y-20)
			
			-- add font string
			local HealerFontString = self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[ActiveTankFrame].Healer[ActiveHealerFrame]:CreateFontString(nil, "OVERLAY")
			HealerFontString:SetPoint("CENTER", 62, 27)
			HealerFontString:SetFont("Fonts\\FRIZQT__.TTF", 11)
			HealerFontString:SetJustifyH("CENTER")
			HealerFontString:SetText("Healer "..ActiveHealerFrame)
			
			-- reconfigure Slider and Set HealerNum
			HealingAssignmentsTemplates.Profile[ActiveProfile].Template[ActiveFrame].TankHealer[ActiveTankFrame] = ActiveHealerFrame
			self:SetScrollFrameHeight(ActiveProfile,ActiveFrame)
		end
	end
end

-- Delivers the current Height of Scrollframe
function HealingAsssignments.Mainframe:GetScrollFrameHeight(ProfileNum,ActiveFrame)
	local Height = 0;
	
	if self.Foreground.Profile[ProfileNum].Template[ActiveFrame].Assigments.Content.Frame ~= nil then  
		for i=1,table.getn(self.Foreground.Profile[ProfileNum].Template[ActiveFrame].Assigments.Content.Frame) do
			Height = Height + self.Foreground.Profile[ProfileNum].Template[ActiveFrame].Assigments.Content.Frame[i]:GetHeight()
		end
	end
	return Height
end

-- Set the height of Scrollframe
function HealingAsssignments.Mainframe:SetScrollFrameHeight(ActiveProfile,ActiveFrame)
	local Height = 0;
	if self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame ~= nil then  
		for i=1,table.getn(self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame) do
			Height = Height + self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[i]:GetHeight()
		end
	end
	
	if Height > 300 then self.Foreground.Profile[ActiveProfile].Template[ActiveFrame].Assigments.Scrollbar:SetMinMaxValues(0, Height-300) end
end

-- create Dropdown Menus
function HealingAsssignments.Mainframe:LoadDropdown(ProfileNum,TemplateNumber)
	local TankNum = HealingAssignmentsTemplates.Profile[ProfileNum].Template[TemplateNumber].TankNum
	if TankNum == nil then TankNum = 0 end
	local HealerNum = 0
	for i=1,TankNum do
		HealingAsssignments.Mainframe:AddTankDropdown(ProfileNum,TemplateNumber)
		HealerNum = HealingAssignmentsTemplates.Profile[ProfileNum].Template[TemplateNumber].TankHealer[i]

		_G[HealingAsssignments.Mainframe.Foreground.Profile[ProfileNum].Template[TemplateNumber].Assigments.Content.Frame[i].Tank[i]:GetName().."Text"]:SetText(HealingAssignmentsTemplates.Profile[ProfileNum].Template[TemplateNumber].Tank[i]);

		if HealerNum == nil then 
			HealerNum = 0 
		end
		for j=1,HealerNum do
			HealingAsssignments.Mainframe:AddHealerDropdown(ProfileNum,TemplateNumber)
			if HealingAssignmentsTemplates.Profile[ProfileNum].Template[TemplateNumber].Tankhealernames[i] ~= nil then
				_G[HealingAsssignments.Mainframe.Foreground.Profile[ProfileNum].Template[TemplateNumber].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"]:SetText(HealingAssignmentsTemplates.Profile[ProfileNum].Template[TemplateNumber].Tankhealernames[i].Healer[j]);
			end
		end
	end
end

-- reset the dropdown textes
function HealingAsssignments.Mainframe:ResetDropdownText()
	local ActiveFrame = self.ActiveFrame;
	if ActiveFrame ~= nil and ActiveFrame ~= 15 and ActiveFrame ~= 16 then
		local TankNum = HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[ActiveFrame].TankNum
		local HealerNum = 0
		for i=1,TankNum do
			HealerNum = HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[ActiveFrame].TankHealer[i]

			_G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[i].Tank[i]:GetName().."Text"]:SetText(" ");

			if HealerNum == nil then HealerNum = 0 end
			for j=1,HealerNum do
				_G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"]:SetText(" ");
			end
		end
	end
	HealingAsssignments:UpdateRaidDataBase()
end
