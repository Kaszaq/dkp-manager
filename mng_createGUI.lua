local gs=LibStub("GuiSkin-1.0");
local A=LibStub("AceAddon-3.0"):GetAddon("DKP Manager");
local B=LibStub("AceAddon-3.0"):GetAddon("DKP Bidder");
local DKPlog=A.log;
local tooltips={
	["addmain"]={[1]=B.color["LIGHTRED"] .. "Add|r a new player to the list",},
	["addalt"]={[1]=B.color["LIGHTRED"] .. "Add/Remove|r an alt from the selected player",},
	["delmain"]={[1]=B.color["LIGHTRED"] .. "Remove|r the selected player",},
	["print"]={[1]=B.color["LIGHTRED"] .. "Print|r the selected players' alt's to the chat frame",},
	["status"]={[1]=B.color["LIGHTRED"] .. "Toggle|r the selected players' standby status",},
	["resetdkp"]={[1]=B.color["LIGHTRED"] .. "Clear|r 'DKP Awarded' field",},
}
function A:CreateGUI()
	local v=B.view;
	v.logFrame=B:CreateLogFrame();
	v.adminFrame=CreateFrame("Frame",B.mainFrame:GetName().."_adminFrame",UIParent);
	local f=v.adminFrame;
	f:SetWidth(B.mainFrame:GetWidth()-40);
	f:SetHeight(300);

	if B.mainFrame:IsVisible() then
		f:Show()
	else
		f:Hide()
	end
	--B.mainFrame:SetParent(f);
	local func = B.mainFrame:GetScript("OnHide")
	B.mainFrame:SetScript("OnHide",function(self) func(self); f:Hide() end)
	local func = B.mainFrame:GetScript("OnShow")
	B.mainFrame:SetScript("OnShow",function(self) func(self); f:Show() end)


	B.mainFrame:SetFrameLevel(f:GetFrameLevel()+1);
	f:SetBackdrop( {
		  bgFile =[[Interface\FrameGeneral\UI-Background-Rock]],
		  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		  tile = false,
		  atileSize = 32,
		  edgeSize =32,
		  insets = { left=11,right=11, top=12, bottom=10}
		})

	f.view={};
	local v=f.view;
	local name=f:GetName();


	--titleframe and text
	v.titleFrame = CreateFrame("Frame",name.."_titleFrame",f)

	v.titleString=v.titleFrame:CreateFontString(name.."_title","ARTWORK","GameFontNormal");
	v.titleString:SetPoint("TOP",v.titleFrame,"TOP",18,-14);
	v.titleString:SetText("DKP Admin");

	v.titleString:SetFont([[Fonts\MORPHEUS.ttf]],14);
	v.titleString:SetTextColor(1,1,1,1);--shadow??
	v.titleFrame:SetScript("OnEnter",function()
		v.titleString:SetTextColor(1,1,0.3,1);


	end)
	v.titleFrame:SetScript("OnLeave",function()
		v.titleString:SetTextColor(1,1,1,1);


	end)

	v.optionsButton = CreateFrame("Button", nil, f)
	v.optionsButton:SetFrameLevel(10)
	--v.optionsButton:ClearAllPoints()
	v.optionsButton:SetHeight(20)
	v.optionsButton:SetWidth(20)
	v.optionsButton:SetNormalTexture("Interface\\Addons\\DKP-Manager\\arts\\icon-config")
	v.optionsButton:SetHighlightTexture("Interface\\Addons\\DKP-Manager\\arts\\icon-config", 0.2)
	v.optionsButton:SetAlpha(0.8)
	v.optionsButton:SetPoint("TOPLEFT", v.titleString, "TOPRIGHT", 5, 2);
	v.optionsButton:Show()
	v.optionsButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	v.optionsButton:SetScript("OnClick", function()
		LibStub("AceConfigDialog-3.0"):Open("DKP Manager");
	end)
	
	v.titleFrame:SetHeight(40)
	v.titleFrame:SetWidth(f:GetWidth()/3);
	v.titleString:SetPoint("TOP", f, "BOTTOM", 0,10);
	v.titleFrame:SetPoint("TOP",v.titleString, "TOP", 0, 12);
	v.titleFrame:SetMovable(true)
	v.titleFrame:EnableMouse(true)
	f.hidden=true;
	f:SetPoint('BOTTOM', B.mainFrame,'BOTTOM', 0,-20);
	v.titleFrame:SetScript("OnMouseDown",function()
		if not f.hidden then
			f:ClearAllPoints()
			f:SetPoint('BOTTOM', B.mainFrame,'BOTTOM', 0, -20);

			f.hidden=true
			--print("1");
		else
			--print("2");
			f:ClearAllPoints()
			--setpoint changes the height of the DKP Admin window
			f:SetPoint('bottom', B.mainFrame,'BOTTOM', 0,-120);  --f:SetPoint('bottom', B.mainFrame,'BOTTOM', 0,-100);
			--print("3");
			f.hidden=false
		end

	end)

	v.titleFrame:SetScript("OnMouseUp",function()
		--f:StopMovingOrSizing()
	end)
	v.titleFrame.texture=gs.CreateTexture(v.titleFrame,name.."_titleFrameTexture","ARTWORK",300,68,"TOP", v.titleFrame, "TOP", 0,2,[[Interface\DialogFrame\UI-DialogBox-Header]]);
 --- end of title frame


	v.itemLinkString=gs.CreateFontString(f,name.."_itemLinkString","ARTWORK","Item: ","BOTTOMLEFT",f,"BOTTOMLEFT",20,34);

	v.itemLinkEditBox = CreateFrame("EditBox", name.."_itemLinkEditBox", f, "InputBoxTemplate")

	v.itemLinkEditBox:SetPoint('LEFT', v.itemLinkString,'RIGHT',10 ,0)
	v.itemLinkEditBox:SetFont([[Fonts\ARIALN.ttf]],14);
	v.itemLinkEditBox:Show();
	v.itemLinkEditBox:Disable();
	v.itemLinkEditBox:SetAutoFocus(false);

	v.itemLinkEditBox:SetWidth(140);
	v.itemLinkEditBox:SetHeight(20);
	v.tooltipFrameHelp = CreateFrame("Frame",nil,f)
	v.itemLinkEditBox:SetScript("OnEnter", function(self)
		v.tooltipFrameHelp:SetScript("OnUpdate", 	function()
				A:ShowGameTooltip();
			end)
	end)
	v.itemLinkEditBox:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
		v.tooltipFrameHelp:SetScript("OnUpdate", 	function()
				-- Dont do anything
			end)
	end)


	--Award bid Button
	v.awardButton = CreateFrame("Button", name.."_awardButton", f, "UIPanelButtonTemplate")
	local b=v.awardButton;
	b:SetText("Award player");
	b:SetPoint('bottom', f,"bottom", 0,55)
	b:SetScript("OnClick",function(self)
		--A:StopBids();
		A:AwardPlayer();
	  end)
	b:SetHeight(20);
	b:SetWidth(150);
	b:Disable();
	--//Bid Button


	--Start/stop bid Button
	v.startStopButton = CreateFrame("Button", name.."_startStopBidButton", f, "UIPanelButtonTemplate")
	v.startStopButton:SetText("Start bidding");
	v.startStopButton:SetPoint('bottom', v.awardButton,"top", 0,3)
	v.startStopButton:SetScript("OnClick",function(self)
		--B:Bid(v.bidEditBox:GetNumber());\
		if not A.biddingInProgress then
			A:StartBids(v.itemLinkEditBox:GetText());
		else
			A:StopBids();
		end;

	  end)
	v.startStopButton:SetHeight(20);
	v.startStopButton:SetWidth(150);
	v.startStopButton:Disable();
	--//Bid Button
	
	--Send to Disenchant Button
	v.disenchantButton = CreateFrame("Button", name.."_disenchantButton", f, "UIPanelButtonTemplate")
	v.disenchantButton:SetText("Disenchant");
	v.disenchantButton:SetPoint('bottom', v.startStopButton,"top", 0,3)
	v.disenchantButton:SetScript("OnClick",function(self)
		--Send current item to Disenchanter
		A:AwardDisenchanter();
	  end)
	v.disenchantButton:SetHeight(20);
	v.disenchantButton:SetWidth(150);
	v.disenchantButton:Disable();
	--//Disenchant Button
	
	
	--==============ADD HERE TO CREATE BUTTON TO POP OPEN THE STANDBY LIST===============--
	v.standbyButton = CreateFrame("Button", nil, f)
	v.standbyButton:SetFrameLevel(10)
	--v.standbyButton:ClearAllPoints()
	v.standbyButton:SetHeight(25)
	v.standbyButton:SetWidth(25)
	v.standbyButton:SetNormalTexture("Interface\\HELPFRAME\\ReportLagIcon-Chat")
	v.standbyButton:SetHighlightTexture("Interface\\HELPFRAME\\ReportLagIcon-Chat", 0.2)
	v.standbyButton:SetAlpha(0.8)
	v.standbyButton:SetPoint("RIGHT", v.titleString, "LEFT", -5, -1);
	v.standbyButton:Show()
	v.standbyButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	v.standbyButton:SetScript("OnClick", function()
		if B.view.standbyFrame then
			if B.view.standbyFrame:IsShown() then
				B.view.standbyFrame:Hide()
			else
				B.view.standbyFrame:Show()
			end
		else
			A:CreateStandbyGUI()
		end
	end)
	--====================================================================================--
	
	
	
	self:CreateBidButtons()
end

function A:CreateBidButtons()
	for i=1,4 do
		B.view["lootButton"..i]= CreateFrame("Button", "DKPLootButton"..i, _G["LootButton"..i], "UIPanelButtonTemplate")
		local b =B.view["lootButton"..i];
		b:SetText("Bid");
		b:SetPoint('top', "LootButton"..i,"top", 0,0);
		b:SetPoint('bottom', "LootButton"..i,"bottom", 0,0);
		b:SetPoint('right', "LootButton"..i,"left", 0,0);
		b:SetWidth(34);
		b.id=i;
		b:SetScript("OnClick",function(self)
			--B:Bid(v.bidEditBox:GetNumber());\
			--if not A.biddingInProgress then

			A:StartBids(GetLootSlotLink(_G["LootButton"..tostring(i)].slot));
			--else
			--	A:StopBids();
			--end;

		  end)
		b:Hide();
	end;
end

function A:ShowGameTooltip()
	local v=B.view.adminFrame.view;
	GameTooltip_SetDefaultAnchor( GameTooltip, UIParent )
	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("bottom",v.itemLinkEditBox, "top", 0, 0)
	GameTooltip:ClearLines()

	if v.itemLinkEditBox:GetText()~="" then
		GameTooltip:SetHyperlink(v.itemLinkEditBox:GetText())
	end
end

function B:CreateLogFrame()
	--if GetNumGuildMembers()>0 then
		local f=gs:CreateFrame(self.ver.."_LogFrame","DKP Log","BASIC",705,305,'TOPLEFT',self.view.rosterFrame,'BOTTOMLEFT',0 ,-50);
		f:Hide();
		f:SetScript("OnShow",
				function(self)
					PlaySound("igCharacterInfoOpen");
				end)
		f:SetScript("OnHide",
				function(self)
					PlaySound("igCharacterInfoClose");
				end)

		local v=f.view;

		local data={columns={"Date","Name","Change","Amount","Reason","Zone","Logger name"},columnsWidth={105,70,55,55,220,100,70},rows=20,height=220};

		v.logList=LibStub("WowList-1.0"):CreateNew(self:GetName().."_logList",data,f);
		v.logList:SetPoint('TOPLEFT', f,'TOPLEFT', 16,-30);
		v.logList:SetColumnSortFunction(1,function(a,b) return a>b end)
		v.logList:SetColumnDisplayFunction(1,function(t)
			local total=math.floor(t/86400)%26+1;
			local r=total%3
			local gt=(total-total%3)/3
			local g=gt%3
			local b=(gt-gt%3)/3%3;
			return date("%d.%m.%y %H:%M:%S",t),{r/2,g/2,b/2,1}
		end)

		v.logList:SetColumnSortFunction(2,function(a,b) return a>b end)
		v.logList:SetColumnSortFunction(3,function(a,b) return a>b end)
		v.logList:SetColumnSortFunction(4,function(a,b) return a>b end)
		v.logList:SetColumnSortFunction(5,function(a,b) return a>b end)
		v.logList:SetColumnSortFunction(6,function(a,b) return a>b end)
		v.logList:SetColumnSortFunction(7,function(a,b) return a>b end)
		v.logList:SetMultiSelection(false);
		function f:SelectionChanged(arg1,arg2)
			if f:IsVisible() then
				self:UpdateList();
			end;
		end


		B.view.rosterFrame.view.bidderList.RegisterCallback(f, "SelectionChanged");


		function f:UpdateList()

			if B.view.rosterFrame.view.bidderList:GetLastSelected()~=nil then
				local main=B.view.rosterFrame.view.bidderList:GetLastSelected()[1].data.main;

				self.view.titleString:SetText("DKP Log: "..main);
				if DKPlog:GetLog(main)~=nil then
					for i,v in pairs(DKPlog:GetLog(main)) do
						v.isSelected=nil
					end


					local lookup_table = {}
					local function _copy(object)
						if type(object) ~= "table" then
							return object
						elseif lookup_table[object] then
							return lookup_table[object]
						end
						local new_table = {}
						lookup_table[object] = new_table
						for index, value in pairs(object) do
							new_table[_copy(index)] = _copy(value)
						end
						return setmetatable(new_table, getmetatable(object))
					end
					self.view.logList:SetData(_copy(DKPlog:GetLog(main)));

					self.view.logList:UpdateView();
				else

					self.view.logList:SetData({});
					self.view.logList:UpdateView();
				end;
			end
		end;
		--f:UpdateList()
		return f;
	--end;

end;

function A:OnEnter(self,arg)
	--if pDB.enable.tooltips then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		for i=1,#tooltips[arg] do
			GameTooltip:AddLine(tooltips[arg][i],1,1,1,1)
		end
		GameTooltip:Show()
	--end
end

function A:OnLeave(self)
	--if pDB.enable.tooltips then
		GameTooltip:Hide()
		GameTooltip:ClearLines()
	--end
end