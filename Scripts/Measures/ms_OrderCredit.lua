-- ******** THANKS TO KINVER ********
function aidecide()
	SimGetWorkingPlace("", "BuildingPointer")
	BuildingGetOwner("BuildingPointer", "BankChief")

	local cash = GetMoney("BankChief")

	local DecideValue

	if not HasProperty("BuildingPointer","KreditKonto") then
		if cash > 10000 then
			DecideValue = 3
		elseif cash > 5000 then
			DecideValue = 2
		else
			DecideValue = 1
		end
	else
		local Lmoney = GetProperty("BuildingPointer","KreditKonto")
		local Random = Rand(100)
		DecideValue = "C"
		if cash > 10000 then
			if (Lmoney < 4000) and (Random > 85) then
				DecideValue = 3
			elseif (Lmoney < 4000) and (Random > 75) then
				DecideValue = 2
			elseif (Lmoney < 4000) and (Random > 65) then
				DecideValue = 1
			end
		elseif cash > 6500 then
			if (Lmoney < 2100) and (Random > 75) then
				DecideValue = 2
			elseif (Lmoney < 2100) and (Random > 65) then
				DecideValue = 1
			end
		elseif cash > 2000 then		
			if (Lmoney < 800) and (Random > 75) then
				DecideValue = 2
			elseif (Lmoney < 800) and (Random > 65) then
				DecideValue = 1
			end
		elseif cash < 1000 then
			DecideValue = 4
		end
	end
	return DecideValue
end

function Run()

	if IsAIDriven() then
		SimGetWorkingPlace("", "BuildingPointer")
		BuildingGetOwner("BuildingPointer", "BankChief")

		CopyAlias("","Actorpointer")
		if HasProperty("Actorpointer", "SpecialMeasureDestination") then
			RemoveProperty("Actorpointer", "SpecialMeasureDestination")
		end
		if HasProperty("Actorpointer", "SpecialMeasureId") then
			RemoveProperty("Actorpointer", "SpecialMeasureId")
		end

		if IsDynastySim("Actorpointer") then
			StopMeasure()			
		end

	else
		BuildingGetOwner("","BankChief")
		CopyAlias("","BuildingPointer")
	end

	local cash = GetMoney("BankChief")
	cash = math.floor(cash)
	
	if cash < 0 and not HasProperty("BuildingPointer","KreditKonto") then
		MsgQuick("","@L_MEASURE_ORDERCREDIT_FAIL_+0")
		StopMeasure()
	end

	local MinMoney
	local MedMoney
	local BigMoney

	if cash > 0 then
		MinMoney = math.max((cash / 100) * 2 , 1)
		MedMoney = math.max((cash / 100) * 5 , 1)
		BigMoney = math.max((cash / 100) * 10 , 1)	
	else
		MinMoney = 0
		MedMoney = 0
		BigMoney = 0	
	end
		
	local kreditR
	local xtra = ""
	local xtrb = ""
	local KontoStand = 0	
	
	if HasProperty("BuildingPointer","KreditKonto") then
		xtra = "@B[4,@L_MEASURE_ORDERCREDIT_STUFF_+3]@B[5,@L_MEASURE_ORDERCREDIT_STUFF_+5]"
		xtrb = "@L_MEASURE_ORDERCREDIT_BODY_+1"
		KontoStand = GetProperty("BuildingPointer","KreditKonto")
	else
		xtrb = "@L_MEASURE_ORDERCREDIT_BODY_+0"
		KontoStand = 0
	end

	local SimAlias
	local TakeLoanSimCount = 0
	local RentMoney = 0
	local BankName = GetID("")
	local TotalSimCount = ScenarioGetObjects("cl_Sim", 9999, "SimAr")
	for i=0, TotalSimCount-1 do
		SimAlias = "SimAr"..i
		local GBankName = GetProperty(SimAlias, "SchuldenGeb")
		if BankName == GBankName then
			TakeLoanSimCount = TakeLoanSimCount + 1
			local GBankMoney = GetProperty(SimAlias, "SchuldenMeng")
			RentMoney = RentMoney + GBankMoney
		end
	end
	local Comment = "@B[7,@L_MEASURE_OrderCredit_INFO_+0]"   -- this will lead to a screen with info about creditors
    local InfoSettingButton = ""
    if GetProperty("","StopInfo")==0 or not HasProperty("","StopInfo") then
        InfoSettingButton = "@B[8,@L_MEASURE_OrderCredit_INFO_+1,@L_MEASURE_OrderCredit_INFO_+3]"
    else
        InfoSettingButton = "@B[8,@L_MEASURE_OrderCredit_INFO_+2,@L_MEASURE_OrderCredit_INFO_+4]"
    end

	local layCred = ""
	layCred = layCred.."@B[1,@L_MEASURE_ORDERCREDIT_STUFF_+0]"
	layCred = layCred.."@B[2,@L_MEASURE_ORDERCREDIT_STUFF_+1]"
	layCred = layCred.."@B[3,@L_MEASURE_ORDERCREDIT_STUFF_+2]"

	kreditR = MsgNews(
		"",
		"",
		"@P"..layCred..xtra.."@B[6,@L_MEASURE_ORDERCREDIT_STUFF_+4]"..Comment..InfoSettingButton,
		ms_ordercredit_aidecide,
		"intrigue",
		1,
		"@L_MEASURE_ORDERCREDIT_HEAD_+0",
		xtrb,
		MinMoney, MedMoney, BigMoney, KontoStand, TakeLoanSimCount, RentMoney)

	if kreditR=="C" then
		StopMeasure()
	end	

	local invest = 0
	if kreditR == 1 then
	    invest = MinMoney
	elseif kreditR == 2 then
	    invest = MedMoney
	elseif kreditR == 3 then
	    invest = BigMoney
	elseif kreditR == 4 then
		invest = GetProperty("BuildingPointer","KreditKonto")
		CreditMoney("BankChief",invest,"Credit")
		SetProperty("BuildingPointer","KreditKonto",0)
		StopMeasure()
	elseif kreditR == 5 then
		invest = GetProperty("BuildingPointer","KreditKonto")
		CreditMoney("BankChief",invest,"Credit")
		RemoveProperty("BuildingPointer","KreditKonto")
		StopMeasure()
	elseif kreditR == 6 then
	    StopMeasure()
    elseif kreditR == 7 then  -- screen about creditors
	    local PanelParam = ""
        local Alias
        local bankID
        local Aliaslist = {}
        local Aliasnamelist = {}
        local number = 1
        local Kreditlist = {}
        local Zinsmore48list = {}
        local Zins48list = {}
        local StartTimeList = {}
        local GlobalSimCount = ScenarioGetObjects("cl_Sim", -1, "Sims")
        GetDynasty("","MyDyn")
        for i = 0, GlobalSimCount-1 do -- check every sim
            Alias = "Sims"..i
            if HasProperty(Alias,"SchuldenGeb") then -- if the sim is creditor in any bank
                bankID = GetProperty(Alias,"SchuldenGeb")  -- the bankID from the creditors bank
                if GetID("") == bankID then -- only check the actual selected bank 
                    Aliaslist[number] = Alias
                    number = number + 1  -- increase this number only, if we entered info
                end
            end
        end
        
        local compare = 
		function(a,b) 
            return GetProperty(a,"TimeBank")-4 <= GetProperty(b,"TimeBank")-4   -- sort for starting time of the credit
		end
        helpfuncs_QuickSort(Aliaslist, 1, helpfuncs_mytablelength(Aliaslist), compare) -- sort it
        
        for number = 1, helpfuncs_mytablelength(Aliaslist) do
            Aliasnamelist[number] = string.sub(GetName(Aliaslist[number]),0, 24)  -- shorten the hole name to a maximum of 24 characters, because otherwise we could get multiple lines
            Kreditlist[number] = GetProperty(Aliaslist[number],"SchuldenMeng")
            Zins48list[number] = string.gsub(""..helpfuncs_myround(GetProperty(Aliaslist[number],"Zins48"),2),"%.",",") -- make a string with comma, so it can be shown in overview (don't know how to show floats)
            Zinsmore48list[number] = string.gsub(""..helpfuncs_myround(GetProperty(Aliaslist[number],"Zinsmore48"),2),"%.",",") -- has to be rounded again... I put 0.07 into Property, and out comes 0.07001231 or simular -.-
            StartTimeList[number] = GetProperty(Aliaslist[number],"TimeBank")-4  -- is in total game hours, a float number.  right after start it is 6 (game starts at 6am in the round 1400)
        end
        
        local argumentsarray = {}
        local pos = 1
        for i = 1, helpfuncs_mytablelength(Aliasnamelist) do  
            if Aliasnamelist[i]~=nil then
                --PanelParam = PanelParam.."@B["..i..",@L_MEASURE_OfferCredit_ENTRY_+"..i.."]"  -- für jeden sim einen neuen Button zufügen .. (mehrere Textzeilen geht glaub ich nicht, weil ich nicht weiß, wie mehrere labels innerhalb eines strings)
                argumentsarray[pos] = Aliasnamelist[i]
                argumentsarray[pos+1] = Kreditlist[i]
                argumentsarray[pos+2] = Zins48list[i]
                argumentsarray[pos+3] = Zinsmore48list[i]
                pos = pos + 4
            end
        end
        
        -- If you would like to see german text, replace the english ones. Unfortunatley we can't use labels for multiply language support, because it would make the list very very difficult.
        
        local BODY = "Name:         Kreditsumme:       vor48Zins/h:        nach48Zins/h: \n\nFinden k\195\182nnt ihr diese Personen in Eurer Wichtige Personen Liste!\n\n" -- GERMAN -- \195\182 is the lua code for ö
        local Taler = "Taler"
        -- local BODY = "Name:         Sum:       before48Interest/h:        after48Interest/h: \n\nYou can find all your creditors in your Important Persons list!\n\n"  -- standard language is english.
        -- local Taler = "Coins"
        
        local filler = ""
        local filler2 = "    "
        local filler3 = "    "
        local filler4 = "    "
        for i = 1, helpfuncs_mytablelength(argumentsarray), 4 do
            filler2 = "    "
            filler3 = "    "
            filler4 = "    " -- 3 spaces
            while string.len(argumentsarray[i]..filler2) < 24+4 do
                filler2 = "_"..filler2
            end
            while string.len(argumentsarray[i+1]..filler3) < 4+4 do
                filler3 = "_"..filler3
            end
            while string.len(argumentsarray[i+2]..filler4) < 5+4 do
                filler4 = "_"..filler4
            end
            BODY = BODY..argumentsarray[i]..filler2..argumentsarray[i+1].." "..Taler..filler3..argumentsarray[i+2].."%"..filler4..argumentsarray[i+3].."% \n" 
        end
        local MinEntries = 14 -- how many entries at minimum (filled with -- entries)
        if helpfuncs_mytablelength(argumentsarray)/4 < MinEntries then -- if there too less creditors, the msg window is very small, so we add some empty lines
            filler = "__    "
            filler2 = "______________________    "
            filler3 = "__    "
            for i = 1, MinEntries-helpfuncs_mytablelength(argumentsarray)/4 do
                BODY = BODY.."--"..filler2.."---- "..Taler..filler.."--,--%"..filler3.."--,--% \n"
            end
        end
        
        MsgBoxNoWait("","", 
        "@L_MEASURE_ORDERCREDIT_HEAD_+0",
        BODY, 
        0 )
        
        StopMeasure()
    elseif kreditR == 8 then
        if GetProperty("","StopInfo")==0 or not HasProperty("","StopInfo") then
            SetProperty("","StopInfo",1)
        else
            SetProperty("","StopInfo",0)
        end
	else
	    StopMeasure()
	end
		
	SpendMoney("BankChief",invest,"Credit")

	if HasProperty("BuildingPointer","KreditKonto") then
		local habKonto = GetProperty("BuildingPointer","KreditKonto")
		invest = invest + habKonto
	end

	SetProperty("BuildingPointer","KreditKonto",invest)

	StopMeasure()
end


function CleanUp()
	if AliasExists("Actorpointer") then
		if HasProperty("Actorpointer", "SpecialMeasureDestination") then
			RemoveProperty("Actorpointer", "SpecialMeasureDestination")
		end
		if HasProperty("Actorpointer", "SpecialMeasureId") then
			RemoveProperty("Actorpointer", "SpecialMeasureId")
		end
		if HasProperty("Actorpointer", "AIDecideNow") then
			RemoveProperty("Actorpointer", "AIDecideNow")
		end
		RemoveAlias("Actorpointer")
	end
end
