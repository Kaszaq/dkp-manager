DKPmanager = LibStub("AceAddon-3.0"):NewAddon("DKP Manager","AceComm-3.0","AceTimer-3.0","AceEvent-3.0","AceHook-3.0","AceSerializer-3.0");
local Log=LibStub("DKPlog-1.0");
local B=LibStub("AceAddon-3.0"):GetAddon("DKP Bidder");
local GRI=LibStub("GuildRosterInfo-1.0");

DKPmanagerDB={};
local A=DKPmanager;
local DB=DKPmanagerDB;
A.log=Log;
A.prefix="dkp_manager";
DB.log={};
A.bidTable={};
DB.biddingType="sh";
DB.minBid=0;
DB.zeroSum=true;
DB.broadcastBidderUpdate=false;
DB.silenceBidding=true;
DB.allowbidremove=true;

A.ver="530 101";
A.isInRaidGroup=false;
A.standby={}
A.standby={allowreceive=false,receivedDKP={}}

function A:GROUP_ROSTER_UPDATE()

	if not UnitInRaid("player") then
		if A.biddingInProgress then
			self:Print("Ending bidding because you left the raid group");
			self:StopBids();
		end;
		self.isInRaidGroup=false;
		B.view.adminFrame.view.startStopButton:Disable();
	elseif not self.isInRaidGroup then
		self.isInRaidGroup=true;

		B.view.adminFrame.view.startStopButton:Enable();
	end


end

function A:OnInitialize()
	self:CreateGUI();
	self:RegisterEvent("LOOT_OPENED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	A.log:RegisterCallback("ActionComplete",self.SendChanges,self);
	A.log:RegisterCallback("ActionFailed",self.SendFailed,self);
	self:RegisterComm(B.prefix);
	self:RegisterComm(A.prefix);


	self:SecureHook("LootFrame_Update");
	self:SecureHook("ChatEdit_InsertLink");
	table.insert(B.dropDownMenuTable,(#B.dropDownMenuTable-1),{
		notCheckable = 1,
		disabled=1,
		text="",
	});
	table.insert(B.dropDownMenuTable,(#B.dropDownMenuTable-1),{
		text = "DKP Manager",
		isTitle = 1,
		notCheckable = 1,
	});
	table.insert(B.dropDownMenuTable,(#B.dropDownMenuTable-1),{
		text = "Add/Remove DKP",
		func = function()
			local v=B.view.rosterFrame.view;
			local point=v.bidderList:GetSelected();
			if point~=nil then
				local text="Type the change amount for following players: "
				local onlyMains={};
				local sep="";
				local mains={};
				for i=1,#point do
						text=text..sep..point[i][1].data.name;
						table.insert(mains,point[i][1].data.name);
						sep=",";
				end
				text=text..".";

				if StaticPopupDialogs["DKPBidder_TitleDropDownMenu_ChangeDKPStaticPopup"]~=nil then table.wipe(StaticPopupDialogs["DKPBidder_TitleDropDownMenu_ChangeDKPStaticPopup"]); end;
				StaticPopupDialogs["DKPBidder_TitleDropDownMenu_ChangeDKPStaticPopup"] = {
					text = text,
					whileDead = true,
					enterClicksFirstButton=1,
					hideOnEscape = 1,
					hasEditBox=true,
					button1 = "Change amounts",
					button2 = "Cancel",
					EditBoxOnTextChanged = function (self, data)
						-- careful! 'self' here points to the editbox, not the dialog
						self:GetParent().button1:Enable()          -- self:GetParent() is the dialog
					end,
					EditBoxOnEnterPressed = function(self) StaticPopup_OnClick(self:GetParent(), 1) end,
					EditBoxOnEscapePressed = function(self) StaticPopup_OnClick(self:GetParent(), 2) end,
					OnShow = function (self, data)
						self.button1:Disable();
					end,
					OnAccept = function(self, data, data2)
						local number=self.editBox:GetNumber();
						if number then

							A:ChangeAmounts(number,mains);--/script for i=1,20 do LibStub("AceAddon-3.0"):GetAddon("DKP Bidder"):Transfer(10,{"Mogrhana"}); end
						end
					end,
					timeout = 0,

				}
				StaticPopup_Show("DKPBidder_TitleDropDownMenu_ChangeDKPStaticPopup");
			end
		end,
		notCheckable = 1,
	});
	table.insert(B.dropDownMenuTable,(#B.dropDownMenuTable-1),{
		text = "Add/Remove Overall DKP(No net change)",
		func = function()
			local v=B.view.rosterFrame.view;
			local point=v.bidderList:GetSelected();
			if point~=nil then
				local text="Type the change amount for following players: "
				local onlyMains={};
				local sep="";
				local mains={};
				for i=1,#point do
						text=text..sep..point[i][1].data.name;
						table.insert(mains,point[i][1].data.name);
						sep=",";
				end
				text=text..".";

				if StaticPopupDialogs["DKPBidder_TitleDropDownMenu_ChangeDKPStaticPopup"]~=nil then table.wipe(StaticPopupDialogs["DKPBidder_TitleDropDownMenu_ChangeDKPStaticPopup"]); end;
				StaticPopupDialogs["DKPBidder_TitleDropDownMenu_ChangeDKPStaticPopup"] = {
					text = text,
					whileDead = true,
					enterClicksFirstButton=1,
					hideOnEscape = 1,
					hasEditBox=true,
					button1 = "Change amounts",
					button2 = "Cancel",
					EditBoxOnTextChanged = function (self, data)
						-- careful! 'self' here points to the editbox, not the dialog
						self:GetParent().button1:Enable()          -- self:GetParent() is the dialog
					end,
					EditBoxOnEnterPressed = function(self) StaticPopup_OnClick(self:GetParent(), 1) end,
					EditBoxOnEscapePressed = function(self) StaticPopup_OnClick(self:GetParent(), 2) end,
					OnShow = function (self, data)
						self.button1:Disable();
					end,
					OnAccept = function(self, data, data2)
						local number=self.editBox:GetNumber();
						if number then

							A:ChangeTotAmounts(number,mains);--/script for i=1,20 do LibStub("AceAddon-3.0"):GetAddon("DKP Bidder"):Transfer(10,{"Mogrhana"}); end
						end
					end,
					timeout = 0,

				}
				StaticPopup_Show("DKPBidder_TitleDropDownMenu_ChangeDKPStaticPopup");
			end
		end,
		notCheckable = 1,
	});
	table.insert(B.dropDownMenuTable,(#B.dropDownMenuTable-1),{
		text = "Set alts",
		func = function()
			local v=B.view.rosterFrame.view;
			local point=v.bidderList:GetSelected();
			local main=v.bidderList:GetLastSelected()[1].data.name;
			if point~=nil then
				local text="Following players will be marked as alts of "..main..": ";
				local sep="";
				local mains={};
				for i=1,#point do
					if main~=point[i][1].data.name then
						text=text..sep..point[i][1].data.name;
						table.insert(mains,point[i][1].data.name);
						sep=",";
					end
				end
				text=text..".";

				if StaticPopupDialogs["DKPBidder_TitleDropDownMenu_ChangeDKPStaticPopup"]~=nil then table.wipe(StaticPopupDialogs["DKPBidder_TitleDropDownMenu_ChangeDKPStaticPopup"]); end;
				StaticPopupDialogs["DKPBidder_TitleDropDownMenu_ChangeDKPStaticPopup"] = {
					text = text,
					whileDead = true,
					enterClicksFirstButton=1,
					hideOnEscape = 1,
					hasEditBox=false,
					button1 = "Accept",
					button2 = "Cancel",
					OnAccept = function(self, data, data2)
						A:Print("This operation may take a few second to update data and notes, please wait.");
						for i=1,#mains do
							A.log:SetAlt(main,mains[i]);
						end

					end,
					timeout = 0,

				}
				StaticPopup_Show("DKPBidder_TitleDropDownMenu_ChangeDKPStaticPopup");
			end
		end,
		notCheckable = 1,
	});

	table.insert(B.dropDownMenuTable,(#B.dropDownMenuTable-1),{
		text = "Set as main",
		func = function()
			local v=B.view.rosterFrame.view;
			local point=v.bidderList:GetSelected();
			if point~=nil then
				local text="Following players will be marked as mains: ";
				local sep="";
				local mains={};
				for i=1,#point do
					text=text..sep..point[i][1].data.name;
					table.insert(mains,point[i][1].data.name);
					sep=",";
				end
				text=text..".";

				if StaticPopupDialogs["DKPBidder_TitleDropDownMenu_ChangeDKPStaticPopup"]~=nil then table.wipe(StaticPopupDialogs["DKPBidder_TitleDropDownMenu_ChangeDKPStaticPopup"]); end;
				StaticPopupDialogs["DKPBidder_TitleDropDownMenu_ChangeDKPStaticPopup"] = {
					text = text,
					whileDead = true,
					enterClicksFirstButton=1,
					hideOnEscape = 1,
					hasEditBox=false,
					button1 = "Accept",
					button2 = "Cancel",
					OnAccept = function(self, data, data2)
						A:Print("This operation may take a few second to update data and notes, please wait.");
						for i=1,#mains do
							A.log:SetAlt(mains[i],mains[i]);
						end

					end,
					timeout = 0,

				}
				StaticPopup_Show("DKPBidder_TitleDropDownMenu_ChangeDKPStaticPopup");
			end
		end,
		notCheckable = 1,
	});
	table.insert(B.dropDownMenuTable,(#B.dropDownMenuTable-1),{
		text = "Show log",
		func = function() B.view.logFrame:Show(); B.view.logFrame:UpdateList() end,
		notCheckable = 1,
	});

end

function A:ChangeAmounts(number,mains)
	if StaticPopupDialogs["DKPBidder_TitleDropDownMenu_ChangeDKPReason"]~=nil then table.wipe(StaticPopupDialogs["DKPBidder_TitleDropDownMenu_ChangeDKPReason"]); end;
	StaticPopupDialogs["DKPBidder_TitleDropDownMenu_ChangeDKPReason"] = {
		text = "What reason?",
		hasEditBox=true,
		button1 = "Change amounts",
		button2 = "Cancel",
		EditBoxOnTextChanged = function (self, data)
			self:GetParent().button1:Enable()
		end,
		EditBoxOnEnterPressed = function(self) StaticPopup_OnClick(self:GetParent(), 1) end,
		EditBoxOnEscapePressed = function(self) StaticPopup_OnClick(self:GetParent(), 2) end,
		OnShow = function (self, data)
			self.mains=mains;
			self.button1:Disable();

		end,
		OnAccept = function(self, data, data2)
			local reason=self.editBox:GetText();

			for i=1,#mains do
				--print(mains[i],number,reason);
				A:AddAction(mains[i],number,reason);
			end
		end,
		timeout = 0,
		whileDead = true,
		enterClicksFirstButton=true,
		hideOnEscape = true,
	}
	StaticPopup_Show("DKPBidder_TitleDropDownMenu_ChangeDKPReason");
end

function A:ChangeTotAmounts(number,mains)
	if StaticPopupDialogs["DKPBidder_TitleDropDownMenu_ChangeDKPReason"]~=nil then table.wipe(StaticPopupDialogs["DKPBidder_TitleDropDownMenu_ChangeDKPReason"]); end;
	StaticPopupDialogs["DKPBidder_TitleDropDownMenu_ChangeDKPReason"] = {
		text = "What reason?",
		hasEditBox=true,
		button1 = "Change amounts",
		button2 = "Cancel",
		EditBoxOnTextChanged = function (self, data)
			self:GetParent().button1:Enable()
		end,
		EditBoxOnEnterPressed = function(self) StaticPopup_OnClick(self:GetParent(), 1) end,
		EditBoxOnEscapePressed = function(self) StaticPopup_OnClick(self:GetParent(), 2) end,
		OnShow = function (self, data)
			self.mains=mains;
			self.button1:Disable();

		end,
		OnAccept = function(self, data, data2)
			local reason=self.editBox:GetText();

			for i=1,#mains do
				--print(mains[i],number,reason);
				A:AddTotAction(mains[i],number,reason);
			end
		end,
		timeout = 0,
		whileDead = true,
		enterClicksFirstButton=true,
		hideOnEscape = true,
	}
	StaticPopup_Show("DKPBidder_TitleDropDownMenu_ChangeDKPReason");
end

function A:SetBiddingState(bidMaster)
	local v=B.view.adminFrame.view;

	if bidMaster then
		v.disenchantButton:Disable();
		v.startStopButton:SetText("Stop bidding");
		A.biddingInProgress=true
	else
		v.awardButton:Disable();
		v.disenchantButton:Enable();
		v.startStopButton:SetText("Start bidding");
		A.biddingInProgress=false
	end
end

function A:ChatEdit_InsertLink(link)
	if B.view.adminFrame:IsVisible() and link:find("|Hitem") then  B.view.adminFrame.view.itemLinkEditBox:SetText(link); end;
end

A.printedItems={};

function A:LOOT_OPENED()
	local method, partyMaster, raidMaster = GetLootMethod()
	local guid=UnitGUID("target")
	local target=UnitName("target");
	if raidMaster~=nil and GetRaidRosterInfo(raidMaster)==UnitName("player") and UnitInRaid("player") then
		if not A.printedItems[guid] then
			if guid then A.printedItems[guid]=true;
			else
				target="container";
				if GetRealZoneText()=="Firelands" then
					target="Ragnaros"
				end;
			end;
			local n=0;
			for i=1,GetNumLootItems() do
				if LootSlotHasItem(i) then
					local texture, item, quantity, quality, locked = GetLootSlotInfo(i)
					if quality>=GetLootThreshold() then
						n=n+1;
					end;
				end;
			end;

			if n>0 then
				SendChatMessage("<DKP-Manager> ".."Items dropped by "..target..":","RAID");
				for i=1,GetNumLootItems() do
					if LootSlotHasItem(i) then
						local texture, item, quantity, quality, locked = GetLootSlotInfo(i)
						if quality>=GetLootThreshold() then
							--print("getlootslotinfo",texture, item, quantity, quality, locked );
							SendChatMessage("<DKP-Manager> ".."* "..GetLootSlotLink(i),"RAID");
						end;
					end;
					--print("loot threshold",GetLootThreshold());
				end;
			end;
		end;
		self:LootFrame_Update()
	else
		--TODO does this have to be called everytimne on loot opened? :/
		for i=1,GetNumLootItems() do
			if _G["LootButton"..tostring(i)] then
				--self:Print("Hide, out of raid, lootButton"..i)
				B.view["lootButton"..i]:Hide();
			end
		end
	end;

end

function A:LootFrame_Update()
	for i=1,GetNumLootItems() do
		if _G["LootButton"..tostring(i)] then
			local lootB=_G["LootButton"..tostring(i)]
			--print(lootB.quality);
			if lootB.quality and LootSlotHasItem(i) and lootB.quality>=GetLootThreshold() then
				--self:Print("Show lootButton"..i)
				B.view["lootButton"..i]:Show()
			else
				--self:Print("Hide lootButton"..i)
				B.view["lootButton"..i]:Hide()
			end
		end
	end
end

function A:Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage(B.colors["grey"].."DKP - |r|CFF2459FFManager"..B.colors["grey"].."> "..B.colors["close"]..msg);
end

local function awardDKPtoRaid(amount,boss)
	local method, partyMaster, raidMaster = GetLootMethod()
	if method=="master"and GetRaidRosterInfo(raidMaster)==UnitName("player") then
		for i=1, MAX_RAID_MEMBERS do
			name=GetRaidRosterInfo(i);
			if name and GRI:IsOnList(name) then
				A:AddAction(name,tonumber(amount),"Award for killing "..boss);
			end;
		end;
	else
		if StaticPopupDialogs["DKPBidder_AwardDKPAfterBossKill"]~=nil then table.wipe(StaticPopupDialogs["DKPBidder_AwardDKPAfterBossKill"]); end;
		StaticPopupDialogs["DKPBidder_AwardDKPAfterBossKill"] = {
			text = "Award raid members with "..amount.." dkp for killing "..boss.."?",
			whileDead = true,
			enterClicksFirstButton=1,
			hideOnEscape = 1,
			hasEditBox=false,
			button1 = "Accept",
			button2 = "Cancel",
			OnAccept = function(self, data, data2)
				for i=1, MAX_RAID_MEMBERS do
					name=GetRaidRosterInfo(i);
					if name and GRI:IsOnList(name) then
						A:AddAction(name,tonumber(amount),"Award for killing "..boss);
					end;
				end;

			end,
			timeout = 0,

		}
		StaticPopup_Show("DKPBidder_AwardDKPAfterBossKill");
	end;
end

--REMINDER
--make it a local functiona and remove the commented out raid check.
local function queryStandbyList(amount,boss)
	local method, partyMaster, raidMaster = GetLootMethod()
	if method=="master"and GetRaidRosterInfo(raidMaster)==UnitName("player") and A.DB.standby then
		A.allowstandbyreceive=true
		A:ScheduleTimer(function()
			A.allowstandbyreceive=false
			A:Print("Auto-Award Standby DKP window has ended.")
		end, 75)
		for name, namestable in pairs(A.DB.standby) do
			if name and tostring(name)~="dkp" and tostring(name)~="disabled" and not A.DB.standby.disabled[name] and GRI:IsOnList(name) then
				for i=1, #namestable do
					A:Send("querystandby",{amount=amount,boss=boss},"WHISPER", namestable[i]);
					--SendChatMessage("<DKP-Manager> "..boss.." has been slain! Popup window will display in ~10 seconds, click 'Yes' to receive DKP", "WHISPER", nil, namestable[i]);
					SendChatMessage("<(Standby)DKP-Manager> "..boss.." has been slain! Popup window will display in ~10 seconds, click 'Yes' to receive DKP", "WHISPER", nil, namestable[i]);
				end
			end
		end;
	end
end

function A.BossKill(event,mod) --/script DKPmanager.BossKill("kill",{combatInfo={name="Ultraxion"}})
	local boss=mod.combatInfo.name;

	if DB.bossesDKP.enabled and DB.bossesDKP.bosses[boss]then

		local difficulties={[3]="10-man normal",[4]="25-man normal",[5]="10-man heroic",[6]="25-man heroic"};

		local difficulty=difficulties[GetRaidDifficultyID()]
		local amount=-1;
		A.Print(A,"Boss killed! "..boss);

		if DB.bossesDKP.bosses[boss].patch.perpatch then --per patch!

			amount= DB.bossesDKP.bosses[boss].patch[difficulty].dkp;
			--A.Print(A,"setting per patch! "..amount);
		else -- per instance?
			if DB.bossesDKP.bosses[boss].instance[difficulty].perinstance then
				amount =DB.bossesDKP.bosses[boss].instance[difficulty].dkp;
				--A.Print(A,"setting per instance! "..amount);
			else
				amount=DB.bossesDKP.bosses[boss].instance[difficulty].dkpPerBoss[boss];
				--A.Print(A,"setting per boss! "..amount);
			end

		end
		awardDKPtoRaid(amount,boss);
		queryStandbyList(amount,boss);
	end
	--printTable(mod.combatInfo);
end
local function addBossEncounter(patch,instance,bosses)

	if DB.bossesDKP.enabled==nil then DB.bossesDKP.enabled=false; end;

	local bossEncOptions={
		name="Award dkp points per boss kill",
		type="toggle",
		order=0,
		desc="Turn this feature on to set the dkp amounts given for boss kills.",
		set = function(info,val)
			DB.bossesDKP.enabled = val;
			A.optionsTable.args.autoBossAwards=val and DB.bossesDKP.optEnabled or DB.bossesDKP.optDisabled;
			--insTypes[name] = val and DB.bossesDKP.instance[instance][name].optPerInstance or DB.bossesDKP.instance[instance][name].optPerBoss;

		end,
		get = function(info) return DB.bossesDKP.enabled end,
	}
	if DB.bossesDKP.optEnabled==nil then
		DB.bossesDKP.optEnabled= {
			name="Auto boss award",
			type="group",
			order=100,
			args={
				bossEncOptions=bossEncOptions,
			},
		};
		DB.bossesDKP.optDisabled= {
			name="Auto boss award",
			type="group",
			order=100,
			args={
				bossEncOptions=bossEncOptions,
			},
		};
	else
		DB.bossesDKP.optDisabled.args.bossEncOptions=bossEncOptions;
		DB.bossesDKP.optEnabled.args.bossEncOptions=bossEncOptions;
	end



	A.optionsTable.args.autoBossAwards=DB.bossesDKP.enabled and DB.bossesDKP.optEnabled or DB.bossesDKP.optDisabled;

	--A.optionsTable.args.autoBossAwards=DB.bossesDKP.optEnabled;

	DB.bossesDKP.instance[instance]=DB.bossesDKP.instance[instance] or {};

	DB.bossesDKP.patch=DB.bossesDKP.patch or {};
	DB.bossesDKP.patch[patch]=DB.bossesDKP.patch[patch] or {};

	if nil==DB.bossesDKP.patch[patch].perpatch then DB.bossesDKP.patch[patch].perpatch=true; end;
	DB.bossesDKP.patch[patch].dkp=DB.bossesDKP.patch[patch].dkp or 0;
	if not DB.bossesDKP.optEnabled.args[patch] then
		DB.bossesDKP.optEnabled.args[patch]={
				name=patch,
				type="group",
				args={
				},
			}
	end;




	local patchOptions={
		name="Award equally in "..patch,
		type="toggle",
		order=0,
		desc="Award all bosses same amount among all bosses in "..patch..".",
		set = function(info,val)
			DB.bossesDKP.patch[patch].perpatch = val;
			DB.bossesDKP.optEnabled.args[patch].args=val and DB.bossesDKP.patch[patch].optPerPatch or DB.bossesDKP.patch[patch].optPerInstance;
			--insTypes[name] = val and DB.bossesDKP.instance[instance][name].optPerInstance or DB.bossesDKP.instance[instance][name].optPerBoss;

		end,
		get = function(info) return DB.bossesDKP.patch[patch].perpatch end,
	}
	DB.bossesDKP.patch[patch].optPerInstance=DB.bossesDKP.patch[patch].optPerInstance or {};
	DB.bossesDKP.patch[patch].optPerInstance.patchOptions=patchOptions;
	--=A.optionsTable.args.autoBossAwards.args[patch].args;
	local perPatch={}
	perPatch.patchOptions=patchOptions;
	DB.bossesDKP.patch[patch].optPerPatch=perPatch;


	--print (patch,instance,bosses);
	if not DB.bossesDKP.patch[patch].optPerInstance[instance] then
		DB.bossesDKP.patch[patch].optPerInstance[instance]={
						name=instance,
						type="group",
						childGroups="tab",
						args={
						},
					}
	end;





	DB.bossesDKP.optEnabled.args[patch].args=DB.bossesDKP.patch[patch].perpatch and DB.bossesDKP.patch[patch].optPerPatch or DB.bossesDKP.patch[patch].optPerInstance;
	local insTypes=DB.bossesDKP.patch[patch].optPerInstance[instance].args;
	--agrgs instance args

	--print(insTypes);
	local typCounter=0;
	local function addType(name)
		DB.bossesDKP.instance[instance][name]=DB.bossesDKP.instance[instance][name] or {};
		DB.bossesDKP.instance[instance][name].dkp=DB.bossesDKP.instance[instance][name].dkp or 0;
		if nil==DB.bossesDKP.instance[instance][name].perinstance then DB.bossesDKP.instance[instance][name].perinstance=true; end;

		typCounter=typCounter+1;
		DB.bossesDKP.patch[patch][name]=DB.bossesDKP.patch[patch][name] or {};
		DB.bossesDKP.patch[patch][name].dkp=DB.bossesDKP.patch[patch][name].dkp or 0;
		DB.bossesDKP.patch[patch].optPerPatch[name]={
			name="Dkp per boss kill on "..name,
			desc="Amount of dkp everyone in the raid will get once a boss is killed in "..patch.." on "..name.." difficulty.",
			type = "input",
			order=2*typCounter,
			pattern="%d+";
			usage="Must be a number.";
			set = function(info,val) local a=tonumber(val);if a~=nil then DB.bossesDKP.patch[patch][name].dkp=a;end; end,
			get = function(info) return tostring(DB.bossesDKP.patch[patch][name].dkp);  end,

		}
		DB.bossesDKP.patch[patch].optPerPatch[name.."_nl"]={
			order=2*typCounter,
			type = "description",
			name = "",
		}

		DB.bossesDKP.instance[instance][name].optPerInstance={
				name=name,
				type="group",
				order=typCounter,
				args={

					instanceDKPonly={
						name="Award per instance",
						type="toggle",
						desc = "Turn this off to set dkp points awarded per boss.",
						set = function(info,val)
							DB.bossesDKP.instance[instance][name].perinstance = val;
							insTypes[name] = val and DB.bossesDKP.instance[instance][name].optPerInstance or DB.bossesDKP.instance[instance][name].optPerBoss;
							--if val then
						end,
						get = function(info) return DB.bossesDKP.instance[instance][name].perinstance end,
						order=0,
					},
					instanceAmount_nl = {
						order = 1,
						type = "description",
						name = "",
					},
					instanceAmount={
						name="Dkp per boss kill",
						desc="Amount of dkp everyone in the raid will get once a boss is killed in "..instance.." on "..name.." difficulty.",
						type = "input",
						order=2,
						pattern="%d+";
						usage="Must be a number.";
						set = function(info,val) local a=tonumber(val);if a~=nil then DB.bossesDKP.instance[instance][name].dkp=a;end; end,
						get = function(info) return tostring(DB.bossesDKP.instance[instance][name].dkp);  end,
					},
				}
			}
		DB.bossesDKP.instance[instance][name].optPerBoss={
				name=name,
				type="group",
				order=typCounter,
				args={
					instanceDKPonly={
						name="Award per instance",
						type="toggle",
						desc = "Turn this on to award for every boss same amount.",
						set = function(info,val)
							DB.bossesDKP.instance[instance][name].perinstance = val;
							insTypes[name] = val and DB.bossesDKP.instance[instance][name].optPerInstance or DB.bossesDKP.instance[instance][name].optPerBoss;
						end,
						get = function(info) return DB.bossesDKP.instance[instance][name].perinstance end,
						order=0,
					},
					instanceAmount_nl = {
						order = 1,
						type = "description",
						name = "",
					},
				}
			}

		for i,v in pairs(bosses) do
			DB.bossesDKP.instance[instance][name].dkpPerBoss=DB.bossesDKP.instance[instance][name].dkpPerBoss or {};
			DB.bossesDKP.instance[instance][name].dkpPerBoss[v]=DB.bossesDKP.instance[instance][name].dkpPerBoss[v] or 0;
			DB.bossesDKP.instance[instance][name].optPerBoss.args[v]={
				name="Dkp per "..v.." kill",
				desc="Amount of dkp everyone in the raid will get once a "..v.." is killed in "..instance.." on "..name.." difficulty.",
				type = "input",
				order=2*i+2,
				pattern="%d+";
				usage="Must be a number.";
				set = function(info,val) local a=tonumber(val);if a~=nil then DB.bossesDKP.instance[instance][name].dkpPerBoss[v]=a;end; end,
				get = function(info) return tostring(DB.bossesDKP.instance[instance][name].dkpPerBoss[v]);  end,
			}
			DB.bossesDKP.instance[instance][name].optPerBoss.args[v.."_nl"]={
				order = 2*i+3,
				type = "description",
				name = "",
			}


		end
		insTypes[name]=DB.bossesDKP.instance[instance][name].perinstance and DB.bossesDKP.instance[instance][name].optPerInstance or DB.bossesDKP.instance[instance][name].optPerBoss;
		--print("called with",name);


	end


	addType("10-man normal");
	addType("10-man heroic");
	addType("25-man normal");
	addType("25-man heroic");

	DB.bossesDKP.bosses=DB.bossesDKP.bosses or {};
	for i,v in pairs(bosses) do
		DB.bossesDKP.bosses[v]={};
		DB.bossesDKP.bosses[v].instance=DB.bossesDKP.instance[instance];
		DB.bossesDKP.bosses[v].patch=DB.bossesDKP.patch[patch];
	end

end
function A:OnEnable()
	DB=DKPmanagerDB;
	A.DB=DB;
	A.log:SetDB(DB.log);
	

	if DB.timerAmount==nil then DB.timerAmount=30; end;
	if DB.awardIfStopBidsOnTimeOut==nil then DB.awardIfStopBidsOnTimeOut=false; end;
	if DB.stopBidsOnTimeOut==nil then DB.stopBidsOnTimeOut=false; end;
	if DB.autoStartTimer==nil then DB.autoStartTimer=false; end;
	if DB.autoRestartTimer==nil then DB.autoRestartTimer=false; end;
	if DB.tunnelPlayer==nil then DB.tunnelPlayer={}; end;
	if DB.dkpCap==nil then DB.dkpCap=0; end;
	A.log:SetCap(DB.dkpCap);
	if DB.standby==nil then DB.standby={}; DB.standby={dkp={},disabled={}}; end;
	if DB.disenchantPlayer==nil then DB.disenchantPlayer=""; end;

	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DKP Manager", "DKP Manager")
	--LibStub("AceConfigDialog-3.0"):SetDefaultSize("DKP Manager", 400, 250)
	self:Print(B.colors["red"]..A.ver..B.colors["close"].." version Loaded");
	if DBM then --this can be changed to UNIT_DIED	event from major event: COMBAT_LOG_EVENT_UNFILTERED or COMBAT_LOG_EVENT
		DBM:RegisterCallback("kill",self.BossKill);
		self:Print("DBM found, enabling Boss Auto Award");
		DB.bossesDKP= DB.bossesDKP or{};
		DB.bossesDKP.instance=DB.bossesDKP.instance or {};
		addBossEncounter("Cataclysm","Firelands",{"Beth'tilac","Lord Rhyolith", "Alysarazor", "Shannox", "Baleroc, the Gatekeeper", "Majordomo Staghelm","Ragnaros"});

		addBossEncounter("Cataclysm","Dragon Soul",{"Morchok","Warlord Zon'ozz","Yor'sahj the Unsleeping","Hagara the Stormbinder","Ultraxion", "Warmaster Blackhorn","Spine of Deathwing","Madness of Deathwing"});
		addBossEncounter("MoP","Heart of Fear",{"Imperial Vizier Zor'lok","Blade Lord Ta'yak","Garalon","Wind Lord Mel'jarak", "Amber-Shaper Un'sok","Grand Empress Shek'zeer"});
		addBossEncounter("MoP","Mogu'shan Vaults",{"The Stone Guard","Feng the Accursed","Gara'jal the Spiritbinder","The Spirit Kings","Elegon", "Will of the Emperor"});

		addBossEncounter("MoP","Pandaria",{"Sha of Anger", "Salyis's Warband"});
		addBossEncounter("MoP","Terrace of Endless Spring",{"Protectors of the Endless", "Tsulong", "Lei Shi", "Sha of Fear"});
		addBossEncounter("MoP","Throne of Thunder",{"Jin'rokh the Breaker", "Horridon", "Council of Elders", "Tortos", "Megaera", "Ji-Kun", "Durumu the Forgotten", "Primordius", "Dark Animus", "Iron Qon", "Twin Consorts", "Lei Shen", "Ra-den"});
		--NOTE: when u remove one line of the above, those will still stay in users DB, so they should either be removed or code should be adjusted to nor print those that are not added in here.
	else
		self:Print("DBM not found, Boss Auto Award disabled.");
	end





	LibStub("AceConfig-3.0"):RegisterOptionsTable("DKP Manager", A.optionsTable, {"dkpmanager", "dkpm"});
end

function A:OnDisable()

    -- Called when the addon is disabled
end

A.optionsTable = {
  type = "group",
  childGroups="tree",
  args = {
	biddingOptions={
		name="Dkp options",
		type="group",
		order=10,
		args={
			minBid={
				name="Minimum bid",
				type = "input",
				order=50,
				pattern="%d+";
				usage="Minimum bid must be a number.";
				set = function(info,val) local a=tonumber(val);if a~=nil then DB.minBid=a;end; end,
				get = function(info) return tostring(DB.minBid);  end,
			},
			minBid_nl = {
				order = 51,
				type = "description",
				name = "",
			},
			dkpCap={
				name="Auto Cap DKP: ",
				type = "input",
				order=60,
				pattern="%d+";
				usage="Set a static cap to all players' DKP, must be a number. Enter "..B.colors.green.."'0'|r to disable.";
				set = function(info,val) local a=tonumber(val);if a~=nil then DB.dkpCap=a; A.log:SetCap(DB.dkpCap); end; end,
				get = function(info) return tostring(DB.dkpCap);  end,
			},
			dkpCap_nl = {
				order = 61,
				type = "description",
				name = "",
			},
			
			biddingType={
				name="Method",
				type="select",
				values={sh="Second Highest",norm="Normal"},
				desc = "Set's the way winner is going to be charged. If "..B.colors.green.."'Normal'|r, player will pay the highest value that they bid. "..B.colors.green.."'Second highest'|r, player will pay the second highest amount that was bid by another person or minimum bid if no other bids",
				set = function(info,val) DB.biddingType=val; end,
				get = function(info) return DB.biddingType;  end,
				order=120,
			},
			biddingType_nl = {
				order = 121,
				type = "description",
				name = "",
			},
			zeroSum={
				name="Zero Sum Bidding",
				type="toggle",
				desc = "Enables / Disables Zero Sum DKP Award",
				set = function(info,val) DB.zeroSum = val end,
				get = function(info) return DB.zeroSum end,
				order=140,
			},
			silenceBid={
				name="Silent Bidding",
				type="toggle",
				desc = "Enables / Disables Silent Bidding",
				set = function(info,val) DB.silenceBidding = val end,
				get = function(info) return DB.silenceBidding end,
				order=150,
			},
			silenceBid_nl = {
				order = 151,
				type = "description",
				name = "",
			},
			transferDkp={
				name="Transfer DKP",
				type="toggle",
				desc = "Enables / Disables your Manager the ability to allow players to transfer DKP",
				set = function(info,val) DB.canTransferDKP = val end,
				get = function(info) return DB.canTransferDKP end,
				order=160,
			},
			removeBid={
				name="Allow Bid Removal",
				type="toggle",
				desc = "Allows / Disallows players to remove their bid by bidding '0' "..B.colors.green.."[Silent Bidding Only]|r",
				set = function(info,val) DB.allowbidremove = val end,
				get = function(info) return DB.allowbidremove end,
				order=170,
			},

			h7={
				name="Timer settings",
				type="header",
				order=230,
			},
			autoStartTimer={
				name="Auto-start",
				type="toggle",
				desc = "Start timer automatically when bidding was started.",
				set = function(info,val) DB.autoStartTimer = val end,
				get = function(info) return DB.autoStartTimer end,
				order=240,
			},
			autoRestartTimer={
				name="Restart on bid",
				type="toggle",
				desc = "Restarts the timer for each new bid received.",
				set = function(info,val) DB.autoRestartTimer= val end,
				get = function(info) return DB.autoRestartTimer end,
				order=250,
			},
			autoRestartTimer_nl = {
				order = 251,
				type = "description",
				name = "",
			},
			stopBidsOnTimeOut={
				name="Auto-stop",
				type="toggle",
				desc = "Stop bidding when the timer has run out.",
				set = function(info,val) DB.stopBidsOnTimeOut = val end,
				get = function(info) return DB.stopBidsOnTimeOut end,
				order=260,
			},
			awardIfStopBidsOnTimeOut={
				name="Auto-award",
				type="toggle",
				desc = "Award player automatically when the bidding was stoped by the timer.",
				set = function(info,val) DB.awardIfStopBidsOnTimeOut= val end,
				get = function(info) return DB.awardIfStopBidsOnTimeOut end,
				order=270,
			},
			awardIfStopBidsOnTimeOut_nl = {
				order = 271,
				type = "description",
				name = "",
			},
			timerAmount={
				name="Time for bidding:",
				type = "input",
				order=280,
				pattern="%d+";
				usage="Time must be a number.";
				set = function(info,val) local a=tonumber(val);if a~=nil then DB.timerAmount=a;end; end,
				get = function(info) return tostring(DB.timerAmount);  end,
			},
			disenchantPlayer={
				name="Disenchant Player:",
				type = "input",
				order=290,
				usage="Must be a player name in your raid group.";
				set = function(info,val) local a=val;if a~=nil then DB.disenchantPlayer=a;end; end,
				get = function(info) return tostring(DB.disenchantPlayer);  end,
			},
		}
	},
	guildCommands={
		name="Guild commands",
		type="group",
		order=20,
		args={
			h3={
				name="Dkp backup",
				type="header",
				order=170,
			},
			dkpBackup={
				name="Backup",
				type="execute",
				desc = "Backup dkp points.",
				func = function()
						DB.backupOfficerNotes={};
						for i,v in pairs(GRI:GetData()) do
							DB.backupOfficerNotes[i]=v["officerNote"];
						end;
						DB.backupTime=date("%c", time());
						A:Print("Officer notes with points have been saved at "..DB.backupTime..".");
					end,
				order=180,
			},
			dkpRestore={
				name="Restore",
				type="execute",
				desc = "Restore dkp points.",
				func = function()
						local total= GetNumGuildMembers();
						if StaticPopupDialogs["DKPBidder_TitleDropDownMenu_RestoreDKPStaticPopup"]~=nil then table.wipe(StaticPopupDialogs["DKPBidder_TitleDropDownMenu_RestoreDKPStaticPopup"]); end;
						StaticPopupDialogs["DKPBidder_TitleDropDownMenu_RestoreDKPStaticPopup"] = {
							text = "Are you sure you want to restore dkp points from "..DB.backupTime.."?",
							whileDead = true,
							enterClicksFirstButton=1,
							hideOnEscape = 1,
							hasEditBox=false,
							button1 = "Restore",
							button2 = "Cancel",
							OnAccept = function(self, data, data2)
								for i=1,total do
									local name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, achievementPoints, achievementRank, isMobile = GetGuildRosterInfo(i)
									if DB.backupOfficerNotes[name] then
										GuildRosterSetOfficerNote(i,DB.backupOfficerNotes[name]);
									end
								end;

								A:Print("Officer notes with points have been restored from "..DB.backupTime.." backup.");
							end,
							timeout = 0,

						}
						StaticPopup_Show("DKPBidder_TitleDropDownMenu_RestoreDKPStaticPopup");
					end,
				order=190,
			},
			h4={
				name="Dkp decays",
				type="header",
				order=200,
			},
			decay={
				name="Decay by perc",
				type="execute",
				desc = "Decay players dkp by % of their points that you will choose in the pop up. Helps prevent inflation.",
				func = function()
						if StaticPopupDialogs["DKPBidder_Popupwindow"]~=nil then table.wipe(StaticPopupDialogs["DKPBidder_Popupwindow"]); end;
						StaticPopupDialogs["DKPBidder_Popupwindow"] = {
							text = "What perc of players points should decay?",
							hasEditBox=true,
							button1 = "Decay",
							button2 = "Cancel",
							EditBoxOnTextChanged = function (self, data)
								self:GetParent().button1:Enable()
							end,
							EditBoxOnEnterPressed = function(self) StaticPopup_OnClick(self:GetParent(), 1) end,
							EditBoxOnEscapePressed = function(self) StaticPopup_OnClick(self:GetParent(), 2) end,
							OnShow = function (self, data)
								self.button1:Disable();

							end,
							OnAccept = function(self, data, data2)
								local perc=self.editBox:GetNumber();
								A:LaunchDecay(perc);
							end,
							timeout = 0,
							whileDead = true,
							enterClicksFirstButton=true,
							hideOnEscape = true,
						}
						StaticPopup_Show("DKPBidder_Popupwindow");
					end,
				order=220,
			},
			cap={
				name="Decay by cap",
				type="execute",
				desc = "Cap all players dkp to amount of points that you will choose in the pop up. Helps prevent inflation.",
				func = function()
						if StaticPopupDialogs["DKPBidder_Popupwindow"]~=nil then table.wipe(StaticPopupDialogs["DKPBidder_Popupwindow"]); end;
						StaticPopupDialogs["DKPBidder_Popupwindow"] = {
							text = "At how many points you want to cap players?",
							hasEditBox=true,
							button1 = "Accept",
							button2 = "Cancel",
							EditBoxOnTextChanged = function (self, data)
								self:GetParent().button1:Enable()
							end,
							EditBoxOnEnterPressed = function(self) StaticPopup_OnClick(self:GetParent(), 1) end,
							EditBoxOnEscapePressed = function(self) StaticPopup_OnClick(self:GetParent(), 2) end,
							OnShow = function (self, data)
								self.button1:Disable();

							end,
							OnAccept = function(self, data, data2)
								local perc=self.editBox:GetNumber();
								A:LaunchCap(perc);
							end,
							timeout = 0,
							whileDead = true,
							enterClicksFirstButton=true,
							hideOnEscape = true,
						}
						StaticPopup_Show("DKPBidder_Popupwindow");
					end,
				order=230,
			},
		}
	},
	raidCommands={
		name="Raid commands",
		type="group",
		order=30,
		args={
			h5={
				name="List players addon version",
				type="header",
				order=200,
			},
			verGuildCheck={
				name="Guild",
				type="execute",
				desc = "Check guild.",
				func = function()
						A:AskForVersion("guild");
					end,
				order=210,
			},
			verRaidCheck={
				name="Raid",
				type="execute",
				desc = "Check raid.",
				func = function()
						A:AskForVersion("raid");
					end,
				order=220,
			},

		}
	},
}}







--/script DKPmanager:LaunchDecay(5)
function A:LaunchDecay(perc)

	local players=GRI:GetMainPlayers();
	for i=1,#players do

		local name=players[i];
		local net= GRI:GetNet(name);

		if net > 0 then
			local change=math.floor(net*perc/100);
			if (change > 0) then
				A:AddAction(name,-change,"Decay by "..perc.."%.");
			end
		end
	end;
	self:Print("Decay function run.");
end

--/script DKPmanager:LaunchCap(1000)
function A:LaunchCap(cap)

	local players=GRI:GetMainPlayers();
	for i=1,#players do

		local name=players[i];
		local net= GRI:GetNet(name);

		if net > cap then
			local change = net-cap;
			A:AddAction(name,-change,"Capping to "..cap..".");
		end
	end;
	self:Print("Cap function run.");
end

--/script DKPmanager:LaunchOnTime(25)
function A:LaunchOnTime(amount)

	if GetNumGroupMembers() > 1 then
		for i=1,40 do
			local inraidname = GetRaidRosterInfo(i);
			if inraidname then
				A:AddAction(inraidname,amount,"OnTime bonus: "..amount..".");
			end
		end;
	end;
	self:Print("OnTime function run.");
end

--/script DKPmanager:TotalDKPChange(-100, "Feja")
function A:TotalDKPChange(amount, player)
	--A:AddAction(player,amount,"TESTING");
	A:AddTotAction(player,amount,"Fix Overall DKP by "..amount);
	self:Print("Reducing "..player.."'s Overall DKP by "..amount);
end

function A:ClearDKP()
	local players=GRI:GetMainPlayers();
	for i=1,#players do

		local name=players[i];
		local net= GRI:GetNet(name);
		local tot= GRI:GetTot(name);
		A:AddAction(name,-net,"Clearing DKP!!!");
		A:AddTotAction(name, -tot, "Clearing Total Field")
	end;
end