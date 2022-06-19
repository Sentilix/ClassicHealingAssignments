--[[
--	ClassicHealingAssignments addon
--	-------------------------------
--	Author: Mimma
--	File:   SourceConfig.lua
--	Desc:	Handles assignment of resources (tanks/healers/symbols).
--]]

local CHA_SourceMask = 0x0000;
local CHA_SourceOnOKClick = nil;
function CHA_OpenSourceConfigDialogue(sourceMask, onOkClick)
	CHA_SourceMask = sourceMask;
	CHA_SourceOnOKClick = onOkClick;

	CHA_SourceUpdateClassIcons();

	local parent = _G["CHAMainFrame"];
	local pLeft, pTop = parent:GetLeft(), parent:GetTop();
	local pWidth = parent:GetWidth();
	local cWidth, cHeight = CHASourceFrame:GetWidth(), CHASourceFrame:GetHeight();

	local height = pTop - cHeight - 100;
	local left = pLeft + ((pWidth - cWidth) / 2);
	
	CHASourceFrame:SetPoint("BOTTOMLEFT", left, height);
	CHASourceFrame:Show();
end;

function CHA_CloseSourceConfigDialogue(sender, persistData)
	CHASourceFrame:Hide();

	if persistData then
		CHA_SourceOnOKClick(CHA_SourceMask);
	end;
end;

--	Called when a source ClassIcon is clicked.
--	This should toggle the status of the clicked class, so a click on 
--	an icon will assign/unassign the class mask.
function CHA_SourceClassIconOnClick(sender)
	local buttonName = sender:GetName();
	local _, _, className, _ = string.find(buttonName, "classicon_(%S*)");

	local classInfo = CHA_ClassMatrix[className];
	if classInfo then
		CHA_SourceMask = bit.bxor(CHA_SourceMask, classInfo["mask"]);

		CHA_SourceUpdateClassIcons();
	end;
end;

--	Called when one of the four resource checkboxes are clicked.
function CHA_SourceCheckboxOnClick(sender)
	local checkboxName = sender:GetName();

	local mask = 0;
	
	if checkboxName == "CHASourceFrameCBRaidicons" then
		mask = CHA_RESOURCE_RAIDICON;
	elseif checkboxName == "CHASourceFrameCBDirections" then
		mask = CHA_RESOURCE_DIRECTION;
	elseif checkboxName == "CHASourceFrameCBGroups" then
		mask = CHA_RESOURCE_GROUP;
	elseif checkboxName == "CHASourceFrameCBCustom" then
		mask = CHA_RESOURCE_CUSTOM;
	else
		return;
	end;

	if _G[checkboxName]:GetChecked() then
		CHA_SourceMask = bit.bor(CHA_SourceMask, mask);
	else
		CHA_SourceMask = bit.band(CHA_SourceMask, (-1) - mask);
	end;	
end;

--	Initlialize the Class icons in the bottom of the role screen.
function CHA_SourceCreateClassIcons()
	local offsetX = 100;
	local offsetY = -2;
	local width = 24;
	local posX = offsetX;

	--	Initialize Healer class icons:
	for className, classInfo in next, CHA_ClassMatrix do
		local buttonName = string.format("sourceclassicon_%s", className);

		local entry = CreateFrame("Button", buttonName, CHASourceFrameClasses, "CHAClassButtonTemplate");
		entry:SetAlpha(CHA_ALPHA_DISABLED);
		entry:SetPoint("TOPLEFT", posX, offsetY);
		entry:SetNormalTexture(classInfo["icon"]);
		entry:SetPushedTexture(classInfo["icon"]);

		posX = posX + width;
	end;
end;

--	Update healer class icons based on the current template:
function CHA_SourceUpdateClassIcons()

	for className, classInfo in next, CHA_ClassMatrix do
		local buttonName = string.format("sourceclassicon_%s", className);

		if bit.band(CHA_SourceMask, classInfo["mask"]) > 0 then
			_G[buttonName]:SetAlpha(CHA_ALPHA_ENABLED);
		else
			_G[buttonName]:SetAlpha(CHA_ALPHA_DISABLED);
		end;
	end;

	if bit.band(CHA_SourceMask, CHA_RESOURCE_RAIDICON) > 0 then
		CHASourceFrameCBRaidicons:SetChecked(1);
	else
		CHASourceFrameCBRaidicons:SetChecked();
	end;

	if bit.band(CHA_SourceMask, CHA_RESOURCE_DIRECTION) > 0 then
		CHASourceFrameCBDirections:SetChecked(1);
	else
		CHASourceFrameCBDirections:SetChecked();
	end;

	if bit.band(CHA_SourceMask, CHA_RESOURCE_GROUP) > 0 then
		CHASourceFrameCBGroups:SetChecked(1);
	else
		CHASourceFrameCBGroups:SetChecked();
	end;

	if bit.band(CHA_SourceMask, CHA_RESOURCE_CUSTOM) > 0 then
		CHASourceFrameCBCustom:SetChecked(1);
	else
		CHASourceFrameCBCustom:SetChecked();
	end;
end;

