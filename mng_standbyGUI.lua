local gs=LibStub("GuiSkin-1.0");
local A=LibStub("AceAddon-3.0"):GetAddon("DKP Manager");
local B=LibStub("AceAddon-3.0"):GetAddon("DKP Bidder");

function A:CreateStandbyGUI()
	local v=B.view
	v.standbyFrame=gs.CreateFrame(f,B.mainFrame:GetName().."_StandbyFrame","Standby List", "BASIC", 380, 215, 'TOPRIGHT',UIParent,'TOPRIGHT',-150 ,-100)
	local f=v.standbyFrame
	local name=f:GetName();
	if not B.mainFrame:IsVisible() then
		f:Hide()
	end
	
	v.inputBox=gs:CreateEditBox(name.."_inputBox", 150, 21, "TOPLEFT", f, "TOPLEFT", 17, -25)
	v.addmainButton=gs:CreateButton(name.."_addmainButton", "Add", 30, "LEFT", v.inputBox,"RIGHT", 2, 0)
	v.addAltButton=gs:CreateButton(name.."_addAltButton", "Alt", 30, "LEFT", v.addmainButton,"RIGHT", 1, 0)
	v.removeButton=gs:CreateButton(name.."_removeButton", "Del", 30, "LEFT", v.addAltButton,"RIGHT", 1, 0)
	v.printaltButton=gs:CreateButton(name.."_printaltButton", "Print", 42, "LEFT", v.removeButton,"RIGHT", 1, 0)
	v.statusButton=gs:CreateButton(name.."_statsuButton", "Status", 45, "LEFT", v.printaltButton,"RIGHT", 1, 0)
	
	v.resetdkpButton=gs.CreateTextureButton("resetdkpButton", name.."_resetdkpButton", f, "OVERLAY", 17, 17, "TOPLEFT", f,"TOPLEFT", 126, 4, [[Interface\COMMON\VOICECHAT-MUTED]])
	v.resetdkpButton:Show()
	
	v.testFunctionButton=gs:CreateButton(name.."_testFunctionButton", "TEST", 45, "LEFT", v.printaltButton,"RIGHT", 1, 25)
	v.testFunctionButton:Hide()
	
	
	v.inputBox:SetScript("OnEnterPressed", function(self)
		if v.inputBox:GetText() == nil or v.inputBox:GetText() == "" then
			A:Print("No name entered.")
		else
			local onlist, main = f:CheckOnList(v.inputBox:GetText());
			if not onlist then
				A.DB.standby[v.inputBox:GetText()]={}
				table.insert(A.DB.standby[v.inputBox:GetText()], v.inputBox:GetText())
				A.DB.standby.dkp[v.inputBox:GetText()]=0
				f:UpdateList()
			elseif main then
				A:Print(v.inputBox:GetText().." is already in the list as an alt of "..main)
			else
				A:Print(v.inputBox:GetText().." is already in the list.")
			end
		end
		v.inputBox:SetText("")
		v.inputBox:ClearFocus()
	end)
	
	v.addmainButton:SetScript("OnClick",function(self)
		if v.inputBox:GetText() == nil or v.inputBox:GetText() == "" then
			A:Print("No name entered.")
		else
			local onlist, main = f:CheckOnList(v.inputBox:GetText());
			if not onlist then
				A.DB.standby[v.inputBox:GetText()]={}
				table.insert(A.DB.standby[v.inputBox:GetText()], v.inputBox:GetText())
				A.DB.standby.dkp[v.inputBox:GetText()]=0
				f:UpdateList()
			elseif main then
				A:Print(v.inputBox:GetText().." is already in the list as an alt of "..main)
			else
				A:Print(v.inputBox:GetText().." is already in the list.")
			end
		end
		v.inputBox:SetText("")
		v.inputBox:ClearFocus()
	end)
	v.addmainButton:SetScript("OnEnter", function(self) A:OnEnter(self,"addmain") end)
	v.addmainButton:SetScript("OnLeave", function(self) A:OnLeave(self) end)
	
	v.addAltButton:SetScript("OnClick",function(self)
		local retData=v.standbyList:GetSelected()
		if v.inputBox:GetText() == nil or v.inputBox:GetText() == "" then
			A:Print("No name entered.")
			v.inputBox:ClearFocus()
		elseif not retData then
			A:Print("Select a player from the list to add an alt to.")			
		else
			local onlist, main, i = f:CheckOnList(v.inputBox:GetText());
			if not onlist then
				table.insert(A.DB.standby[retData[1][1].name], v.inputBox:GetText())
				A:Print("Added "..v.inputBox:GetText().." as an alt of "..retData[1][1].name)
			elseif main and main==retData[1][1].name then
				table.remove(A.DB.standby[retData[1][1].name], i)
				A:Print("Removed "..v.inputBox:GetText().." as an alt of "..retData[1][1].name)
			elseif main then
				A:Print(v.inputBox:GetText().." is already in the list as an alt of "..main)
			else
				A:Print(v.inputBox:GetText().." is already in the list.")
			end
			f:UpdateList()
			v.inputBox:SetText("")
			v.inputBox:ClearFocus()
		end
	end)
	v.addAltButton:SetScript("OnEnter", function(self) A:OnEnter(self,"addalt") end)
	v.addAltButton:SetScript("OnLeave", function(self) A:OnLeave(self) end)
	
	v.removeButton:SetScript("OnClick",function(self)
		local retData=v.standbyList:GetSelected()
		if retData then
			A.DB.standby.dkp[retData[1][1].name]=nil
			if A.DB.standby.disabled[retData[1][1].name] then
				A.DB.standby.disabled[retData[1][1].name]=nil
			end
			A.DB.standby[retData[1][1].name]=nil
			f:UpdateList()
		else
			A:Print("Select a player from the list to remove.")
		end
	end)
	v.removeButton:SetScript("OnEnter", function(self) A:OnEnter(self,"delmain") end)
	v.removeButton:SetScript("OnLeave", function(self) A:OnLeave(self) end)
	
	v.printaltButton:SetScript("OnClick",function(self)
		local retData=v.standbyList:GetSelected()
		local output=""
		if retData then
			output="Alts of "..retData[1][1].name..": ";
			for i=2, #A.DB.standby[retData[1][1].name] do
				output=output..A.DB.standby[retData[1][1].name][i]..", ";
			end
			A:Print(output)
			f:UpdateList()
		end
	end)
	v.printaltButton:SetScript("OnEnter", function(self) A:OnEnter(self,"print") end)
	v.printaltButton:SetScript("OnLeave", function(self) A:OnLeave(self) end)
	
	v.statusButton:SetScript("OnClick",function(self)
		local retData=v.standbyList:GetSelected()
		if retData then
			if A.DB.standby.disabled[retData[1][1].name] then
				A.DB.standby.disabled[retData[1][1].name]=nil
				A:Print("Enabled standby player "..retData[1][1].name)
			else
				A.DB.standby.disabled[retData[1][1].name]=true
				A:Print("Disabled standby player "..retData[1][1].name)
			end
			f:UpdateList()
		end
	end)
	v.statusButton:SetScript("OnEnter", function(self) A:OnEnter(self,"status") end)
	v.statusButton:SetScript("OnLeave", function(self) A:OnLeave(self) end)
	
	v.resetdkpButton:SetScript("OnClick",function(self)
		for name, namestable in pairs(A.DB.standby) do
			if tostring(name)~="dkp" and tostring(name)~="disabled" then
				A.DB.standby.dkp[name]=0
			end
		end
		f:UpdateList()
	end)
	v.resetdkpButton:SetScript("OnEnter", function(self) A:OnEnter(self,"resetdkp") end)
	v.resetdkpButton:SetScript("OnLeave", function(self) A:OnLeave(self) end)
	
	v.testFunctionButton:SetScript("OnClick",function(self)
		A:queryStandbyList(100,"Horridon")
	end)
	
	local data={
		columns={"Name","DKP Awarded","Standby Status"},
		columnsWidth={140,100,100},
		rows=10,
		height=140
	};
	v.standbyList=LibStub("WowList-1.0"):CreateNew(name.."_standbyList",data,f);
	v.standbyList:SetPoint('TOPLEFT', f,'TOPLEFT', 16,-51);
	v.standbyList:SetColumnSortFunction(1,function(a,b) return a.name<b.name end)
	v.standbyList:SetColumnSortFunction(2,function(a,b) return a.name>b.name end)
	v.standbyList:SetColumnSortFunction(3,function(a,b) return a.name>b.name end)
	v.standbyList:SetMultiSelection(false);
	
	data={}
	function f:UpdateList()
		v.standbyList:RemoveAll()
		for name, namestable in pairs(A.DB.standby) do
			if tostring(name)~="dkp" and tostring(name)~="disabled" then
				if A.DB.standby.disabled[name] then
					data[1]={name=name, color={0.77,0.12,0.23,1.00,}}
					data[2]={name=A.DB.standby.dkp[name], color={0.77,0.12,0.23,1.00,}}
					data[3]={name="Disabled", color={0.77,0.12,0.23,1.00,}}
				else
					data[1]={name=name}
					data[2]={name=A.DB.standby.dkp[name]}
					data[3]={name="Active"}
				end
				
				v.standbyList:AddData(data, name)
				data={}
				-- for i=2, #namestable do
					-- data[1]=name.."("..namestable[i]..")"
					-- data[2]=A.DB.standby.dkp[name]
					-- data[3]="Active"
					-- v.standbyList:AddData(data, namestable[i]) --K=Key of this data.
					-- data={}
				-- end
			end
		end
		v.standbyList:UpdateView()
	end;
	
	function f:CheckOnList(name)
		if name and A.DB.standby[name] then
			return true;
		elseif name then
			for main, alts in pairs(A.DB.standby) do
				if tostring(main)~="dkp" and tostring(main)~="disabled" then
					for i=2, #alts do
						if alts[i]==tostring(name) then
							return true, main, i;
						end
					end
				end
			end
		else
			return false
		end
	end
	
	f:UpdateList()
	
end