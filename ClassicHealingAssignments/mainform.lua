-- Author      : sentilix
-- Create Date : 8/2/2024 6:44:26 PM

CHA3 = select(2, ...)
CHA3.events = { };
CHA3.frames = { };

local addonMetadata = {
	["ADDONNAME"]		= "ClassicHealingAssignments",
	["SHORTNAME"]		= "CHA",
	["PREFIX"]			= "CHAv3",
	["NORMALCHATCOLOR"]	= "40A0F8",
	["HOTCHATCOLOR"]	= "B0F0F0",
};

CHA3.lib = DigamAddonLib:new(addonMetadata);



function CHA3.events.OnLoad()

	CHA3.frames.eventFrame = CHA3EventFrame;

	CHA3.lib:echo(string.format("Welcome to Classic Healing Assignments. Type %s/cha%s to configure the addon.", CHA3.lib.chatColorHot, CHA3.lib.chatColorNormal));

	CHA3.frames.eventFrame:RegisterEvent("ADDON_LOADED");
    CHA3.frames.eventFrame:RegisterEvent("CHAT_MSG_ADDON");
    CHA3.frames.eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE");

	C_ChatInfo.RegisterAddonMessagePrefix(CHA3.lib.addonPrefix);
end;

