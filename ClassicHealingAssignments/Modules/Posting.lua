
function HealingAsssignments:PostAssignments()
	local ActiveFrame = HealingAsssignments.Mainframe.ActiveFrame;
	if ActiveFrame ~= nil and ActiveFrame ~= 16 then
		local chanText = HealingAsssignments.Mainframe.HealerChannelEditBox:GetText()
		local  id, chatnamename = GetChannelName(chanText);
		if chanText == nil or chanText == "" then 
			DEFAULT_CHAT_FRAME:AddMessage("no Channel selected",1,1,1)
		elseif chatnamename == "world" or chatnamename == "World" or chanText == "1" or chanText == "2" or chanText == "3" then 
			DEFAULT_CHAT_FRAME:AddMessage("You are trying to post in a public channel!",1,0,0);
		else
			local chan,chanNum = HealingAsssignments:GetSendChannel(chanText)
			if not chan and not chanNum then return end
			local PostString = ""
			local TankNameTemp
			local TankName = {}
			local HealerName = {}
			local HealerNameTemp
			local TankNum = HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[ActiveFrame].TankNum
			local HealerNum = 0
			local m = 0
			local n = 0

			for i=1,TankNum do
				HealerNum = HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[ActiveFrame].TankHealer[i]
				TankNameTemp = _G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[i].Tank[i]:GetName().."Text"]:GetText(" ");

				if TankNameTemp ~= nil and TankNameTemp ~= " " and TankNameTemp ~= "" and HealerNum ~= 0 and HealerNum ~= nil then 
					n = n + 1; 
					TankName[n] = {}; 
					TankName[n] = TankNameTemp

					if HealerNum == nil then 
						HealerNum = 0 
					end
					m = 0
					HealerName[n] = {}
					for j=1,HealerNum do
						HealerNameTemp = _G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"]:GetText(" ");
						if HealerNameTemp ~= nil and HealerNameTemp ~= " " and HealerNameTemp ~= "" then 
							m = m + 1; 
							HealerName[n][m] = HealerNameTemp 
						end
					end
				end
			end
			if table.getn(TankName) == 0 then 
				DEFAULT_CHAT_FRAME:AddMessage("No Tank Selected.",1,1,1)
			else
				SendChatMessage("° ° ° Healing Assignments ° ° °",chan,nil,chanNum) 
				-- here you find the action!
				for v=1,table.getn(TankName) do
					TankName[v] = HealingAsssignments:GetTextUIString(TankName[v])
					PostString = ""
					PostString = PostString..TankName[v]..": --> "
					for w=1,table.getn(HealerName[v]) do
						PostString = PostString..HealingAsssignments:GetTextUIString(HealerName[v][w]);

						if w~= table.getn(HealerName[v]) then 
							PostString = PostString..", "
						else 
							PostString = PostString.."." 
						end
					end

					SendChatMessage(PostString,chan,nil,chanNum)
				end

				SendChatMessage(HealingAsssignments.Mainframe.Foreground.Profile[1].Template[16].Assigments.Content.BottomText:GetText(),chan,nil,chanNum) -- 16 = optionsframe
				HealingAsssignments:PostLastLine(chan,chanNum) 
			end	
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("No Template selected.",1,1,1)
	end
end

function HealingAsssignments:PostLastLine(chan,chanNum)
	local repost = HealingAsssignments.Mainframe.Foreground.Profile[1].Template[16].Assigments.Content.WhisperRepostCheckbox:GetChecked()
	local heal = HealingAsssignments.Mainframe.Foreground.Profile[1].Template[16].Assigments.Content.WhisperHealCheckbox:GetChecked()
	if repost and heal then
		SendChatMessage("Whisper me: heal (whisper) or repost (repost)!",chan,nil,chanNum)
	elseif repost and not heal then
		SendChatMessage("Whisper me: repost (repost Assignments)!",chan,nil,chanNum)
	elseif not repost and heal then
		SendChatMessage("Whisper me: heal (re-whisper Assignments)!",chan,nil,chanNum)
	else
	
	end
end

function HealingAsssignments:AnswerAssignments(PlayerName)
	if not HealingAsssignments.Mainframe.Foreground.Profile[1].Template[16].Assigments.Content.WhisperHealCheckbox:GetChecked() then
		return;
	end;

	local found = 0
	for n=1,GetNumGroupMembers() do
		if UnitName("raid"..n) == PlayerName then
			found = 1;
			break; 
		end
	end

	local ActiveFrame = HealingAsssignments.Mainframe.ActiveFrame;
	if ActiveFrame ~= nil and ActiveFrame ~= 16 and found == 1 then
		local WhisperString = "You are not assigned."
		local TankNameTemp
		local HealerNameTemp
		local TankNum = HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[ActiveFrame].TankNum
		local HealerNum = 0
		for i=1,TankNum do
			HealerNum = HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[ActiveFrame].TankHealer[i]
			if HealerNum == nil 
				then HealerNum = 0 
			end

			TankNameTemp = _G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[i].Tank[i]:GetName().."Text"]:GetText(" ");
			if TankNameTemp == PlayerName then 
				WhisperString = "Your Healers are: "
				for j=1,HealerNum do
					HealerNameTemp = _G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"]:GetText(" ");
					if HealerNameTemp == nil then 
						HealerNameTemp = " " 
					end
					WhisperString = WhisperString..HealerNameTemp.." "
				end
				break; 
			else 
				for j=1,HealerNum do
					HealerNameTemp = _G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"]:GetText(" ");
					if HealerNameTemp == PlayerName then 
						WhisperString = "You are assigned to: "..TankNameTemp; 
						break; 
					end
				end
			end
		end
		SendChatMessage(WhisperString,"WHISPER",nil,PlayerName)
	end
end


function HealingAsssignments:RepostAssignments(PlayerName)
	if not HealingAsssignments.Mainframe.Foreground.Profile[1].Template[16].Assigments.Content.WhisperRepostCheckbox:GetChecked() then
		return;
	end;
	
	for i=1,GetNumGroupMembers() do
		if UnitName("raid"..i) == PlayerName then  
			HealingAsssignments:PostAssignments();
			break; 
		end
	end
end

function HealingAsssignments:PostDeathWarning(PlayerName)
	if PlayerName == "Yo" then PlayerName = UnitName("player"); end
	local OptionsFrame = 16;
	local ActiveFrame = HealingAsssignments.Mainframe.ActiveFrame;
	if ActiveFrame ~= nil and ActiveFrame ~= 16 then
		local chanText = HealingAsssignments.Mainframe.Foreground.Profile[1].Template[OptionsFrame].Assigments.Content.DeathWarningChannelTextbox:GetText()
		local id, chatnamename = GetChannelName(chanText);
		if chanText == nil or chanText == "" then 
			return
		elseif chatnamename == "world" or chatnamename == "World" or chanText == "1" or chanText == "2" or chanText == "3" then 
			return
		else
			local chan,chanNum = HealingAsssignments:GetSendChannel(chanText)
			if not chan and not chanNum then 
				return 
			end
			
			local TankNameTemp
			local HealerNameTemp
			local TankNum = HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[ActiveFrame].TankNum
			local HealerNum = 0
			
			for i=1,TankNum do			
				HealerNum = HealingAssignmentsTemplates.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[ActiveFrame].TankHealer[i]
				if HealerNum == nil then 
					HealerNum = 0 
				end

				TankNameTemp = _G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[i].Tank[i]:GetName().."Text"]:GetText(" ");
				for j=1,HealerNum do
					HealerNameTemp = _G[HealingAsssignments.Mainframe.Foreground.Profile[HealingAsssignments.Mainframe.ActiveProfile].Template[ActiveFrame].Assigments.Content.Frame[i].Healer[j]:GetName().."Text"]:GetText(" ");
					if HealerNameTemp == PlayerName then 
						HealerNameTemp = HealingAsssignments:GetTextUIString(HealerNameTemp,1)
						TankNameTemp = HealingAsssignments:GetTextUIString(TankNameTemp,1)
						SendChatMessage(HealerNameTemp.." died - Tank was "..TankNameTemp..".",chan,nil,chanNum) 
						break; 
					end
				end
			end
		end	
	end	
end

local ChanTable = {
	["s"] = "SAY",
	["y"] = "YELL",
	["e"] = "EMOTE",
	["g"] = "GUILD",
	["p"] = "PARTY",
	["r"] = "RAID",
	["1"] = {"CHANNEL", "1"},
	["2"] = {"CHANNEL", "2"},
	["3"] = {"CHANNEL", "3"},
	["4"] = {"CHANNEL", "4"},
	["5"] = {"CHANNEL", "5"},
	["6"] = {"CHANNEL", "6"},
	["7"] = {"CHANNEL", "7"},
	["8"] = {"CHANNEL", "8"},
	["9"] = {"CHANNEL", "9"},
}

-- from epicfail addon
function HealingAsssignments:GetSendChannel(chanName)
	if not chanName or chanName == "" or chanName == " " then
		return nil,nil
	end
	chanName = string.lower(chanName)
	if ChanTable[chanName] then
		if type(ChanTable[chanName])=="table" then
			local chan = ChanTable[chanName][1]
			local bla = ChanTable[chanName][2]
			return chan,bla
		else
			local chan = ChanTable[chanName]
			return chan,chanName
		end
	else
		return "WHISPER",chanName
	end
end


function HealingAsssignments:CheckProgramVersion()
	if IsInRaid() then
		HealingAsssignments:CheckProgramVersionPublic();
	else
		echo(string.format("%s is using Classic Healing Assignments version %s", UnitName("player"), GetAddOnMetadata("ClassicHealingAssignments", "Version")));
	end
end;

function HealingAsssignments:CheckProgramVersionPublic()
	C_ChatInfo.SendAddonMessage(HealingAsssignments:GetMessagePrefix(), "TX_VERSION##", "RAID");
end;


function HealingAsssignmentsTextMenu(arg)
	if arg == nil or arg == "" then
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00 Classic Healing Assignments:|r This is help topic for |cFFFFFF00 /cha|r",1,1,1);
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00 CHA:|r |cFFFFFF00 /cha post|r - post opened Assignments.",1,1,1);
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00 CHA:|r |cFFFFFF00 /cha menu|r - show/hide the GUI Menu.",1,1,1);
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00 CHA:|r |cFFFFFF00 /cha color|r - enable/disable colored Postings.",1,1,1);
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00 CHA:|r |cFFFFFF00 /cha icon|r - hide/show Minimap Icon.",1,1,1);
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00 CHA:|r |cFFFFFF00 /cha sync|r - sync all Assignments.",1,1,1);
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00 CHA:|r |cFFFFFF00 /cha warnings|r - enable/disable Death warnings.",1,1,1);
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00 CHA:|r |cFFFFFF00 /cha delete|r - delete Database |cFFFF0000 (use only if error - it deletes everything! - instantly relog after!)|r.",1,1,1);
	else
		if arg == "version" then
			HealingAsssignments:CheckProgramVersion()
		elseif arg == "post" then
			HealingAsssignments:PostAssignments()
		elseif arg == "menu" then
			if HealingAsssignments.Mainframe:IsVisible() then HealingAsssignments.Mainframe:Hide()
			else HealingAsssignments.Mainframe:Show() end
		elseif arg == "sync" then
			HealingAsssignments.Syncframe:TriggerSync()
		elseif arg == "icon" then
			if HealingAsssignments.Minimap:IsVisible() then HealingAsssignments.Minimap:Hide()
			else HealingAsssignments.Minimap:Show() end
		elseif arg == "warnings" then
			if HealingAsssignments.Mainframe.DeathWarningCheckbox:GetChecked() == nil then HealingAsssignments.Mainframe.DeathWarningCheckbox:SetChecked(1); DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00CHA|r: Death Warnings enabled",1,1,1)
			else HealingAsssignments.Mainframe.DeathWarningCheckbox:SetChecked(nil) DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00CHA|r: Death Warnings disabled",1,1,1) end
			if HealingAsssignments.Mainframe.DeathWarningCheckbox:GetChecked() == nil then HealingAssignmentsTemplates.Options.Deathwarnings = nil
			elseif HealingAsssignments.Mainframe.DeathWarningCheckbox:GetChecked() == 1 then HealingAssignmentsTemplates.Options.Deathwarnings = 1 end
		elseif arg == "delete" then
			HealingAssignmentsTemplates ={}
		else
			DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00CHA:|r unknown command",1,0.3,0.3);
		end
	end
end


-- binding list
BINDING_HEADER_HEAD = "Classic Healing Assignments"

-- slashcommands
SlashCmdList['CLASSIC_HEALING_ASSIGNMENTS'] = HealingAsssignmentsTextMenu
SLASH_CLASSIC_HEALING_ASSIGNMENTS1 = '/cha'
SLASH_CLASSIC_HEALING_ASSIGNMENTS2 = '/CHA'


function HealingAsssignments:SendChatMessage(messageID, message, extra ,channel)
	local data = {};
	data["messageID"] = messageID;
	data["message"] = message;
	data["extra"] = extra;
	data["channel"] = channel;
	table.insert(HealingAsssignments.MessageBuffer, data);
end

function HealingAsssignments:TableLength(t)
	i = 0;
	for k,v in pairs(t)
	do
		i = i + 1;
	end
	
	return i;
end
