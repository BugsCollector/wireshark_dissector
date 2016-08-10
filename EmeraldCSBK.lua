----------------------------------------------------------------------------------
-- Date: 2014-10-30
-- Author: Liao Ying-RQT768
-- File: EmeraldCSBK.lua
-- Description: Handle all the Emerald CSBK PDU. Call sub dissectors by opcode.
----------------------------------------------------------------------------------
do
	------------------------------------------------------------------------------
	-- Some Common String Tables.
	-- For All the CSBK PDU.
	-- The 'gt' prefix means global table.
	------------------------------------------------------------------------------
	gt_LogicChannelNum = {
		[0x0] = "Slot 1",
		[0x1] = "Slot 2"
	}
	
	gt_SlotNum = gt_LogicChannelNum

	gt_Offset = {
		[0x0] = "Aligned timing",
		[0x1] = "Not aligned timing"
	}

	gt_IG = {
		[0x0] = "Target is a SU ID",
		[0x1] = "Target is a talkgroup ID"
	}
	
	gt_Register = {
		[0x0] = "Register",
		[0x1] = "Deregister"
	}

	gt_MFID = {
		[0x00] = "Standard",
		[0x10] = "Motorola"
	}

	gt_ServiceKind = {
		[0x00] = "Individual Voice Call",	-- "(Individual, Ambient) Voice Call",
		[0x01] = "Group Voice Call",	-- "(Group, All, Broadcast, Emergency) Voice Call",
		[0x02] = "Individual Packet Data Call",
		[0x03] = "Group Packet Data Call",
		[0x04] = "UDT Short Data Individual Call",
		[0x05] = "UDT Short Data Group Call",
		[0x06] = "Not Defined",
		[0x07] = "Emergency Alarm",
		[0x08] = "Not Defined",
		[0x09] = "Answer Call Service",
		[0x0A] = "Not Defined",
		[0x0B] = "Not Defined",
		[0x0C] = "Call Alert",
		[0x0D] = "(Stun, Revive, Kill) / (User Id)",
		[0x0E] = "Registration / (Radio Check)",
		[0x0F] = "Not Defined",

		[0x1C0E] = "Radio Check",
		[0x1F0E] = "Registration",

		[0x1C0D] = "Stun, Revive, Kill",
		[0x1F0D] = "User Id",

		[0xFFFF] = "If you see this string, an error has been occured."
	}

	gt_Address = {
		[0xFFFEC5] = "SDMI - Short Data Message Identifier",
		--[0xFFFEC8] = "TSI?",
		[0xFFFECA] = "TSI - Address of Repeater",
		[0xFFFECC] = "STUNI - Stun/Revive Identifier",
		[0xFFFECD] = "AUTHI - Authentication Identifier",
		[0xFFFECF] = "KILLI - Kill Identifier",
		[0xFFFEC6] = "REGI - Registration Gateway Address",
		[0xFFFFFD] = "SITE_ALLMSID",
		[0xFFFFFE] = "ALLMSID"
	}

	--gt_Address = nil

	gt_SKF = {
		[0x0] = "Stun",
		[0x1] = "Revive"
	}

	gt_ACKDirection = {
		[0x00] = "Uplink",
		[0x01] = "Downlink"
	}

	gt_ACKType = {
		[0x00] = "NACK",
		[0x01] = "ACK",
		[0x02] = "QACK",
		[0x03] = "WACK"
	}

	gt_ACKReasonCode = {
		[0x60] = "Message_Accepted",
		[0x62] = "Reg_Accepted",
		[0x63] = "Downlink Authentication Response",		--"Reg_But_No_AffiliationAccepted",
		[0xA0] = "Queued-for-resource",
		[0xA1] = "Queued-for-busy",
		[0xE0] = "Wait",
		[0x20] = "Not_Supported",
		[0x21] = "Perm_User_Refused",
		[0x22] = "Temp_User_Refused",
		[0x23] = "Transient_Sys_Refused",
		[0x24] = "NoregMSaway_Refused",
		[0x25] = "MSaway_Refused",
		[0x27] = "SYSbusy_Refused",
		[0x28] = "SYS_NotReady",
		[0x2A] = "Reg_Refused",
		[0x2B] = "Reg_Denied",
		[0x2D] = "MS_Not_Registered",
		[0x2E] = "Called_Party_Busy",
		[0x2F] = "Called_Group_Not_Allowed",
		[0x3F] = "Refused_Reason_Unknown",
		[0x44] = "MS_Accepted",
		[0x46] = "MS_Alerting",
		[0x48] = "Uplink Authentication Response",
		[0xFF] = "ACKReasonCodeEnd",
		[0x00] = "MSNot_Supported",
		[0x13] = "EquipBusy_Refused",
		[0x14] = "Recipient_Refused",
		[0x15] = "Custom_Refused",
		[0x1F] = "Refused_Reason_Unknown",
		[0xFF] = "ReasonCodeEnd"
	}


	gt_AnnType = {
		[0x02] = "Vote_Now",
		[0x00] = "Ann-WD_TSCC",
		[0x06] = "Adjacent_site",
		[0xFF] = "AnnTypeEnd"
	}
	
	gt_MaintKind = {
		[0x00] = "Dissconnect",
		[0xFF] = "MaintKindEnd"
	}

	gt_NetworkModel = {
		[0x0] = "Tiny(9:3)",
		[0x1] = "Small(7:5)",
		[0x2] = "Large(4:8)",
		[0x3] = "Huge(2:10)"
	}

	gt_NetIDWidth = {
		[0x0] = 9,
		[0x1] = 7,
		[0x2] = 4,
		[0x3] = 2
	}

	------------------------------------------------------------------------------
	------------------------------------------------------------------------------


	------------------------------------------------------------------------------
	-- Some Common Global Var
	------------------------------------------------------------------------------
	g_MFID = nil
	g_Opcode = nil
	g_ServiceKind = nil
	g_TargetAddress = nil
	g_SourceAddress = nil
	g_IsShowSubProtocolName = false
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------

		
	local p_self = Proto("em_csbk", "Em_CSBK")		-- The name can't contains Upper Case Letter
	
	local f_dataType = ProtoField.uint8("em_csbk.DataType", "Data Type", base.HEX, ota_datatypes)

	local f_slotNum  = ProtoField.uint8("em_csbk.SlotNum", "Slot Number", base.HEX, gt_SlotNum, 0x80)	-- Mask is 1000 0000 b

	local f_frameLen = ProtoField.uint16("em_csbk.FrameLength", "Frame Length", base.HEX)

	local f_sigBits  = ProtoField.uint16("em_csbk.SigBits", "Sig Bits", base.HEX)

	local f_dataSize = ProtoField.uint16("em_csbk.DataSize", "Data Size", base.HEX)

	local f_LB = ProtoField.bool("em_csbk.LB", "LB", 8, nil, 0x80)	-- mask is 1000 0000
	local f_PF = ProtoField.bool("em_csbk.PF", "PF", 8, nil, 0x40)	-- mask is 0100 0000
	local f_Opcode = ProtoField.uint8("em_csbk.Opcode", "Opcode", base.HEX, ota_csbkOpcodes, 0x3F)	-- maks is 0x3F, means 00111111

	local f_MFID = ProtoField.uint8("em_csbk.MFID", "MFID", base.HEX, gt_MFID)

	p_self.fields = {
					f_dataType, 
					f_slotNum, 
					f_frameLen, 
					f_sigBits, 
					f_dataSize, 
					f_LB, 
					f_PF, 
					f_Opcode,
					f_MFID
					}
	
	function p_self.dissector(buf, pkt, root)

		-----------------------------------------
		--Reset the global var
		g_MFID = 0
		g_DataType = -1
		g_Opcode = -1
		g_ServiceKind = -1
		g_TargetAddress = 0
		g_SourceAddress = 0
		-----------------------------------------

		if (g_IsShowSubProtocolName) then
			pkt.cols.protocol:set(p_self.description)
		end
		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_dataType, buf(pos, 1))
		g_DataType = buf(pos, 1):uint()
		pos = pos + 1

		t:add(f_slotNum, buf(pos, 1))
		pos = pos + 1

		t:add(f_frameLen, buf(pos, 2))
		pos = pos + 2

		t:add(f_sigBits, buf(pos, 2))
		pos = pos + 2

		t:add(f_dataSize, buf(pos, 2))
		pos = pos + 2

		-- opcode
		t:add(f_LB, buf(pos, 1))
		t:add(f_PF, buf(pos, 1))
		t:add(f_Opcode, buf(pos, 1))
		g_Opcode = buf(pos, 1):uint()
		g_Opcode = clearbit(g_Opcode, bit(7))
		g_Opcode = clearbit(g_Opcode, bit(8))
		g_info = g_info .. string.format("CSBK %s[0x%X] - ", ota_csbkOpcodes[g_Opcode] or "UnknownOpcode", g_Opcode)
		pkt.cols.info:set(g_info)
		pos = pos + 1

		-- MFID
		t:add(f_MFID, buf(pos, 1))
		g_MFID = buf(pos, 1):uint()
		pos = pos + 1
		
		-- Almost all the csbk pdu contains source address, target address
		ParseServiceKindTargetSource(buf, pkt, root, pos)
		
		local sub_dissector
		local subDissectorName = ""
		if (g_Opcode == 0x19) then
			subDissectorName = "em_c_aloha"

		elseif (g_Opcode == 0x1C) then
			subDissectorName = "em_c_ahoy"

		elseif (g_Opcode == 0x1E) then
			subDissectorName = "em_c_acvit"

		elseif (g_Opcode == 0x1F) then
			subDissectorName = "em_c_rand"

		elseif (g_Opcode == 0x28) then
			subDissectorName = "em_c_bcast"

		elseif (g_Opcode == 0x2A) then
			subDissectorName = "em_p_maint"

		elseif (g_Opcode == 0x2E) then
			subDissectorName = "em_p_clear"

		elseif (g_Opcode == 0x2F) then
			subDissectorName = "em_p_protect"

		elseif (g_Opcode == 0x30 or g_Opcode == 0x31 or g_Opcode == 0x32) then	-- (P)(BT)(T)V_Grant
			subDissectorName = "em_v_grant"

		elseif (g_Opcode == 0x33 or g_Opcode == 0x34) then						-- (P)(T)D_Grant
			subDissectorName = "em_d_grant"

		elseif (g_Opcode == 0x20 or g_Opcode == 0x21) then						-- C_ACKD or C_ACKU
			subDissectorName = "em_c_ack"
			
		elseif (g_Opcode == 0x38) then						-- C_MOVE
			subDissectorName = "em_c_move"
			
		else
			subDissectorName = "data"
		end

		sub_dissector = Dissector.get(subDissectorName)
		if sub_dissector ~= nil then
			sub_dissector:call(buf(pos):tvb(), pkt, t)
		else
		end
	end

	CheckProtocolDissector("em_csbk")
end

------------------------------------------------------------------------------------
-- There are so many same fileds between C_Rand and C_Ahoy PDUs.
-- So, we abstract serveal function and global var to parse them.
------------------------------------------------------------------------------------
function ParseServiceKindTargetSource(buf, pkt, t, pos)
	g_ServiceKind = buf(pos + 1, 1):uint()
	g_ServiceKind = BitHolder:_and(g_ServiceKind, 0x0F)		-- 0000 1111

	g_TargetAddress = buf(pos + 2, 3):uint()
	g_SourceAddress = buf(pos + 5, 3):uint()
end





----------------------------------------------------------------------------------
-- Date: 2014-10-30
-- Author: Liao Ying-RQT768
-- File: EmeraldCAhoy.lua
-- Description: Handle the Emerald C_Ahoy CSBK PDU only. Called by the EmeraldCSBK.lua.
----------------------------------------------------------------------------------
do

	local p_self = Proto("em_c_ahoy", "Em_C_Ahoy")		-- The name can't contains Upper Case Letter

	local f_Emergency = ProtoField.bool("em_c_ahoy.Emergency", "Emergency", 8, nil, 0x80)				-- mask is 1000 0000
	local f_EA_IG = ProtoField.bool("em_c_ahoy.IG", "IG", 8, nil, 0x80)									-- mask is 1000 0000

	local f_Privacy = ProtoField.bool("em_c_ahoy.Privacy", "Privacy", 8, nil, 0x40)						-- mask is 0100 0000
	local f_SD = ProtoField.bool("em_c_ahoy.SupplementaryData", "Supplementary Data", 8, nil, 0x20)		-- mask is 0010 0000
	local f_EA_SD = ProtoField.bool("em_c_ahoy.SupplementaryData", "Supplementary Data", 8, nil, 0x40)	-- mask is 0100 0000
	
	local f_Broadcast = ProtoField.bool("em_c_ahoy.Broadcast", "Broadcast", 8, nil, 0x10)				-- mask is 0001 0000
	local f_HR = ProtoField.bool("em_c_ahoy.HighRate", "High Rate", 8, nil, 0x10)						-- mask is 0001 0000

	local f_OV = ProtoField.bool("em_tv_grant.OpenVoice", "Open Voice Call Mode", 8, nil, 0x08)			-- mask is 0000 1000
	local f_PL = ProtoField.uint8("em_c_ahoy.PriorityLevel", "Priority Level", base.DEC, nil, 0x06)		-- mask is 0000 0110
	local f_SOM = ProtoField.uint8("em_c_ahoy.ServiceOptionsMirror", "Service Options Mirror", base.HEX, nil, 0xFE)		-- mask is 1111 1110
	local f_StatM = ProtoField.uint8("em_c_ahoy.StatM", "Stat M(Most significant bits of status)", base.HEX, nil, 0x3E)	-- mask is 0011 1110
	local f_SKF = ProtoField.uint8("em_c_ahoy.ServiceKindFlag", "Service Kind Flag", base.HEX, gt_SKF, 0x01)			-- mask is 0000 0001

	local f_Reserved1 = ProtoField.uint8("em_c_ahoy.Reserved1", "Reserved 1", base.HEX)	-- nil, 0xFF)	-- mask is 1111 1111
	local f_Reserved2 = ProtoField.uint8("em_c_ahoy.Reserved2", "Reserved 2", base.HEX, nil, 0xF0)		-- mask is 1111 0000

	local f_AL = ProtoField.bool("em_c_ahoy.AmbientListeningService", "Ambient Listening Service", 8, nil, 0x80)		-- mask is 1000 0000
	local f_IG = ProtoField.uint8("em_c_ahoy.IG", "IG", base.HEX, gt_IG, 0x40)											-- mask is 0100 0000
	local f_ApBlock = ProtoField.uint8("em_c_ahoy.AppendedDataBlock", "Appended Data Blocks", base.DEC, nil, 0x30)	 	-- mask is 0011 0000
	local f_StatL = ProtoField.uint8("em_c_ahoy.StatL", "Stat L(Least significant bits of status)", base.HEX, nil, 0x30)-- mask is 0011 0000
	local f_ServiceKind = ProtoField.uint8("em_c_ahoy.ServiceKind", "Service Kind", base.HEX, gt_ServiceKind, 0x0F) 		-- mask is 0000 1111
	
	local f_TargetAddress = ProtoField.uint24("em_c_ahoy.TargetAddress", "Target Address", base.HEX, gt_Address)

	local f_SourceAddress = ProtoField.uint24("em_c_ahoy.SourceAddress", "Source Address", base.HEX, gt_Address)

	local f_CrcCCITT = ProtoField.uint16("em_c_ahoy.CRC", "CRC CCITT", base.HEX)

	p_self.fields = {
					f_Emergency,
					f_EA_IG,
					f_Privacy,
					f_SD,
					f_EA_SD,
					f_Broadcast,
					f_HR,
					f_OV,
					f_PL,
					f_SOM,
					f_StatM,
					f_StatL,
					f_SKF,
					f_Reserved1,
					f_Reserved2,
					f_AL,
					f_IG,
					f_ApBlock,
					f_ServiceKind,
					f_TargetAddress, 
					f_SourceAddress, 
					f_CrcCCITT
					}
		
	function p_self.dissector(buf, pkt, root)

		if (g_IsShowSubProtocolName) then
			pkt.cols.protocol:set(p_self.description)
		end
		local t = root:add(p_self, buf(0))
		local pos = 0

		if (0x0 == g_ServiceKind 				-- Individual Voice Call, Ambient Listening
			or 0x2 == g_ServiceKind 			-- Incividual Packet Data Call
			or 0x4 == g_ServiceKind) then		-- UDT Short Data Call

			ParseE_SKF(buf, pkt, t, pos)
			pos = pos + 1

			ParseAL_SK(buf, pkt, t, pos)
			pos = pos + 1

		elseif (0xD == g_ServiceKind			-- Stun/Revive, Kill Radio
			or 0xE == g_ServiceKind) then		-- Check Raido

			ParseSOM_SKF(buf, pkt, t, pos)
			pos = pos + 1

			ParseAL_SK(buf, pkt, t, pos)
			pos = pos + 1

		elseif (0xC == g_ServiceKind) then		-- Call Alert
			
			ParseCallAlert(buf, pkt, t, pos)
			pos = pos + 2

		elseif (0x7 == g_ServiceKind) then		-- Emergency Alarm

			ParseEmergencyAlarm(buf, pkt, t, pos)
			pos = pos + 2
		else
			pos = pos + 1
			t:add(f_ServiceKind, buf(pos, 1))
			pos = pos + 1
		end

		t:add(f_TargetAddress, buf(pos, 3))
		pos = pos + 3
		
		t:add(f_SourceAddress, buf(pos, 3))
		pos = pos + 3
		
		t:add(f_CrcCCITT, buf(pos, 2))
		pos = pos + 2

		g_info = g_info .. string.format("[%s] Src:0x%X Tgt:0x%X",
			gt_ServiceKind[g_ServiceKind], g_SourceAddress, g_TargetAddress)
		pkt.cols.info:set(g_info)
	end

	-- Check wheather the em_c_ahoy dissector has been created successfully.
	CheckProtocolDissector("em_c_ahoy")


	------------------------------------------------------------------------------------
	-- Parse the first byte of C_Ahoy:
	--	 1    2    3    4     5    6    7    8
	--|  E |  P | SD | B/HR | OV |    PL   | SKF |
	------------------------------------------------------------------------------------
	function ParseE_SKF(buf, pkt, t, pos)

		t:add(f_Emergency, buf(pos, 1))
		t:add(f_Privacy, buf(pos, 1))
		t:add(f_SD, buf(pos, 1))

		if (0x2 == g_ServiceKind) then
			t:add(f_HR, buf(pos, 1))
		else
			t:add(f_Broadcast, buf(pos, 1))
		end

		t:add(f_OV, buf(pos, 1))
		t:add(f_PL, buf(pos, 1))
		t:add(f_SKF, buf(pos, 1))

	end

	------------------------------------------------------------------------------------
	-- Parse the second byte of C_Ahoy:
	--	1    2    3    4    5    6    7    8
	--| AL | IG | ApBlock |   Service Kind   |
	------------------------------------------------------------------------------------
	function ParseAL_SK(buf, pkt, t, pos)

		t:add(f_AL, buf(pos, 1))
		t:add(f_IG, buf(pos, 1))
		t:add(f_ApBlock, buf(pos, 1))
		t:add(f_ServiceKind, buf(pos, 1))

	end

	------------------------------------------------------------------------------------
	-- Parse the first byte of C_Ahoy: 
	--
	-- | Service Options Mirror | SKF |
	------------------------------------------------------------------------------------
	function ParseSOM_SKF(buf, pkt, t, pos)

		t:add(f_SOM, buf(pos, 1))
		t:add(f_SKF, buf(pos, 1))

	end

	------------------------------------------------------------------------------------
	-- Parse the 2 bytes of C_Ahoy: 
	--
	-- |        Reserved 1         |
	-- | Reserved 2 | Service Kind |
	------------------------------------------------------------------------------------
	function ParseCallAlert(buf, pkt, t, pos)

		t:add(f_Reserved1, buf(pos + 0, 1))
		t:add(f_Reserved2, buf(pos + 1, 1))

	end

	------------------------------------------------------------------------------------
	-- Parse the 2 + 3 + 3 bytes of C_Ahoy: 
	--
	-- | IG | SD |   Start_M(5bit)  | SKF |	1
	-- | AL | IG | Start_L | Service Kind |	2
	-- |                                  |	3
	-- |      Emergency Group Address     |	4
	-- |                                  |	5
	-- |                                  |	6
	-- |        Source SU Address         |	7
	-- |                                  |	8
	------------------------------------------------------------------------------------
	function ParseEmergencyAlarm(buf, pkt, t, pos)

		t:add(f_EA_IG, buf(pos, 1))
		t:add(f_EA_SD, buf(pos, 1))
		t:add(f_StatM, buf(pos, 1))
		t:add(f_SKF, buf(pos, 1))
		
		t:add(f_AL, buf(pos + 1, 1))
		t:add(f_IG, buf(pos + 1, 1))
		t:add(f_StatL, buf(pos + 1, 1))
		t:add(f_ServiceKind, buf(pos + 1, 1))


	end
end



----------------------------------------------------------------------------------
-- Date: 2014-10-30
-- Author: Liao Ying-RQT768
-- File: EmeraldCAloha.lua
-- Description: Handle the Emerald Aloha CSBK PDU only. Called by the EmeraldCSBK.lua.
----------------------------------------------------------------------------------
do
	local t_serviceFunction = {
		[0x0] = "All",
		[0x1] = "Registration & Payload",
		[0x2] = "Registration & No Payload",
		[0x3] = "Registration only"
	}

	local p_self = Proto("em_c_aloha", "Em_C_Aloha")		-- The name can't contains Upper Case Letter

	--local f_FID = ProtoField.uint8("em_c_aloha.f_fid", "Feature set ID", base.HEX)

	local f_Reserved = ProtoField.uint8("em_c_aloha.Reserved", "Reserved", base.HEX, nil, 0xC0)	-- mask is 1100 0000
	local f_SlotSyn = ProtoField.uint8("em_c_aloha.SlotSyn", "SlotSyn", base.HEX, nil, 0x20)	-- mask is 0010 0000
	local f_Version = ProtoField.uint8("em_c_aloha.Version", "Version", base.HEX, nil, 0x1C)	-- mask is 0001 1100
	local f_Reserved2 = ProtoField.uint8("em_c_aloha.Reserved2", "Reserved2", base.HEX, nil, 0x02)	-- mask is 0000 0010
	local f_AC = ProtoField.bool("em_c_aloha.ActiveConnection", "Active Connection", 8, nil, 0x01)	-- mask is 0000 0001

	local f_Mask = ProtoField.uint8("em_c_aloha.Mask", "Mask", base.HEX, nil, 0xF8)	-- mask is 11111000
	local f_SF = ProtoField.uint8("em_c_aloha.ServiceFunction", "Service Function", base.HEX, t_serviceFunction, 0x06)	-- mask is 00000110
	local f_RandomWait = ProtoField.uint16("em_c_aloha.RandomWait", "Random Wait", base.DEC, nil, 0x01E0)	-- mask is 0000 0001 1110 0000

	local f_Reg = ProtoField.bool("em_c_aloha.Reg", "Require to register", 8, nil, 0x10)		-- mask is 0001 0000
	local f_BackOff = ProtoField.uint8("em_c_aloha.Backoff", "Back Off", base.DEC, nil, 0x0F)	-- mask is 0000 1111

	local f_CSysCode = ProtoField.uint16("em_c_aloha.CSyscode", "C Syscode", base.HEX)

	local f_MSAddress = ProtoField.uint24("em_c_aloha.MSAddress", "MS Address", base.HEX)
	local f_CRC = ProtoField.uint16("em_c_aloha.CRC", "CRC-CCITT", base.HEX)

	p_self.fields = {
					--f_FID, 
					f_Reserved, 
					f_SlotSyn, 
					f_Version,
					f_Reserved2,
					f_AC, 
					f_Mask, 
					f_SF, 
					f_RandomWait, 
					f_Reg, 
					f_BackOff, 
					f_CSysCode, 
					f_MSAddress,
					f_CRC
					}
		
	function p_self.dissector(buf, pkt, root)

		if (g_IsShowSubProtocolName) then
			pkt.cols.protocol:set(p_self.description)
		end
		local t = root:add(p_self, buf(0))
		local pos = 0

		--t:add(f_FID, buf(pos, 1))
		--pos = pos + 1

		t:add(f_Reserved, buf(pos, 1))
		t:add(f_SlotSyn, buf(pos, 1))
		t:add(f_Version, buf(pos, 1))
		t:add(f_Reserved2, buf(pos, 1))
		t:add(f_AC, buf(pos, 1))
		pos = pos + 1

		t:add(f_Mask, buf(pos, 1))
		t:add(f_SF, buf(pos, 1))

		--[[	-- There is no need to do these.
		local randomWait1 = buf(pos, 1):uint()
		randomWait1 = BitHolder:_and(randomWait1, 0x1)
		randomWait1 = BitHolder:_lshift(randomWait1, 3)

		local randomWait2 = buf(pos + 1, 1):uint()
		randomWait2 = BitHolder:_and(randomWait2, 0xE0)
		randomWait2 = BitHolder:_rshift(randomWait2, 5)

		local randomWait = BitHolder:_or(randomWait1, randomWait2)

		t:add(f_RandomWait, buf(pos, 2), randomWait)
		]]

		t:add(f_RandomWait, buf(pos, 2))
		local randomWait = buf(pos, 2):uint()
		randomWait = BitHolder:_and(randomWait, 0x1E0)		--0000 0001 1110 0000
		randomWait = BitHolder:_rshift(randomWait, 5)
		pos = pos + 1

		t:add(f_Reg, buf(pos, 1))
		t:add(f_BackOff, buf(pos, 1))
		local backOff = buf(pos, 1):uint()
		backOff = BitHolder:_and(backOff, 0x0F)		--0000 1111
		pos = pos + 1

		t:add(f_CSysCode, buf(pos, 2))
		local sysCode = buf(pos, 2):uint()
		pos = pos + 2

		t:add(f_MSAddress, buf(pos, 3))
		pos = pos + 3

		t:add(f_CRC, buf(pos, 2))
		pos = pos + 2

		g_info = g_info .. string.format("Wait:%d Backoff:%d ", randomWait, backOff)
		pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("em_c_aloha")
end



----------------------------------------------------------------------------------
-- Date: 2014-11-03
-- Author: Liao Ying-RQT768
-- File: EmeraldCRand.lua
-- Description: Handle the Emerald C_Rand CSBK PDU only. Called by the EmeraldCSBK.lua.
----------------------------------------------------------------------------------
do

	local p_self = Proto("em_c_rand", "Em_C_Rand")		-- The name can't contains Upper Case Letter

	------Fields for C_Rand Register--------------------
	local f_Reg_Reserved1 = ProtoField.uint8("em_c_rand.RegReserved1", "Reserved", base.HEX, nil, 0x80)		-- mask is 1000 0000
	-- Privacy is same as f_Privacy
	local f_IPInform = ProtoField.bool("em_c_rand.IpInform", "IP Inform", 8, nil, 0x20)						-- mask is 0010 0000
	local f_PowerSaveRequest = ProtoField.uint8("em_c_rand.PowerSaveRequest", "Power Save Request", base.HEX, nil, 0x1C)	-- mask is 0001 1100
	local f_Register = ProtoField.uint8("em_c_rand.Register", "Register", base.HEX, gt_Register, 0x02)	-- mask is 0000 0010
	-- Prx is same as f_PX
	-- Ap Spl is same as f_SupD
	local f_Reg_Reserved2 = ProtoField.uint8("em_c_rand.RegReserved2", "Reserved", base.HEX, nil, 0x30)		-- mask is 0011 0000
	-- Redistration is same as f_ServiceKind
	----------------------------------------------------
	-- Random access by SU for User Id
	local f_Char1 = ProtoField.uint8("em_c_rand.Char1", "Char1", base.HEX, nil, 0x3F)		-- mask is 0011 1111
	local f_NumOfChar = ProtoField.uint8("em_c_rand.NumOfChar", "Number Of Char", base.HEX, nil, 0xF0)		-- mask is 1111 0000
	local f_Char2 = ProtoField.uint8("em_c_rand.Char2", "Char2", base.HEX, nil, 0xFC)		-- mask is 1111 1100
	local f_Char3 = ProtoField.uint16("em_c_rand.Char3", "Char3", base.HEX, nil, 0x3F0)		-- mask is 0000 0011 1111 0000
	local f_Char4 = ProtoField.uint16("em_c_rand.Char4", "Char4", base.HEX, nil, 0xFC0)		-- mask is 0000 1111 1100 0000
	local f_Char5 = ProtoField.uint8("em_c_rand.Char5", "Char5", base.HEX, nil, 0x3F)		-- mask is 0011 1111

	----------------------------------------------------
	
	local f_Emergency = ProtoField.bool("em_c_rand.Emergency", "Emergency", 8, nil, 0x80)			-- mask is 1000 0000
	local f_EA_IG = ProtoField.bool("em_c_rand.IG", "IG", 8, nil, 0x80)								-- mask is 1000 0000

	local f_Privacy = ProtoField.bool("em_c_rand.Privacy", "Privacy", 8, nil, 0x40)					-- mask is 0100 0000
	local f_EA_SD = ProtoField.bool("em_c_rand.SupplementaryData", "Supplementary Data", 8, nil, 0x40)		-- mask is 0100 0000
	local f_SD = ProtoField.bool("em_c_rand.SupplementaryData", "Supplementary Data", 8, nil, 0x20)			-- mask is 0010 0000
	
	local f_Broadcast = ProtoField.bool("em_c_rand.Broadcast", "Broadcast", 8, nil, 0x10)					-- mask is 0001 0000
	local f_HR = ProtoField.bool("em_c_rand.HighRate", "High Rate", 8, nil, 0x10)							-- mask is 0001 0000

	local f_OV = ProtoField.bool("em_tv_grant.OpenVoice", "Open Voice Call Mode", 8, nil, 0x08)				-- mask is 0000 1000
	local f_PL = ProtoField.uint8("em_c_rand.PriorityLevel", "Priority Level", base.DEC, nil, 0x06)			-- mask is 0000 0110
	local f_StatM = ProtoField.uint8("em_c_rand.StatM", "Stat M(Most significant bits of status)", base.HEX, nil, 0x3E)	-- mask is 0011 1110
	local f_PX = ProtoField.bool("em_c_rand.ProxyFlag", "Proxy Flag", 8, nil, 0x01)							-- mask is 0000 0001

	local f_Reserved1 = ProtoField.uint8("em_c_rand.Reserved1", "Reserved 1", base.HEX)	-- nil, 0xFF)					-- mask is 1111 1111
	local f_Reserved2 = ProtoField.uint8("em_c_rand.Reserved2", "Reserved 2", base.HEX, nil, 0xF0)						-- mask is 1111 0000

	local f_SupD = ProtoField.uint8("em_c_rand.SupD", "Appended Blocks for Supplementary Data", base.HEX, nil, 0xC0)	-- mask is 1100 0000
	local f_ShD = ProtoField.uint8("em_c_rand.ShD", "Appended Blocks for UDT Short Data", base.HEX, nil, 0x30)	-- mask is 0011 0000
	local f_AL = ProtoField.bool("em_c_rand.AmbientListening", "Ambient Listening", 8, nil, 0x20)				-- mask is 0010 0000
	local f_AR = ProtoField.bool("em_c_rand.Reject", "Reject FOACSU call", 8, nil, 0x20)						-- mask is 0010 0000
	local f_Reserved = ProtoField.uint8("em_c_rand.Reserved", "Reserved", base.HEX, nil, 0x10)					-- mask is 0001 0000

	local f_StatL = ProtoField.uint8("em_c_rand.StatL", "Stat L(Least significant bits of status)", base.HEX, nil, 0x30)	 --0011 0000
	local f_ServiceKind = ProtoField.uint8("em_c_rand.ServiceKind", "Service Kind", base.HEX, gt_ServiceKind, 0x0F)			 --0000 1111
	
	local f_TargetAddress = ProtoField.uint24("em_c_rand.TargetAddress", "Target Address", base.HEX, gt_Address)
	local f_CSyscode = ProtoField.uint16("em_c_rand.CSyscode", "C Syscode", base.HEX)

	local f_SourceAddress = ProtoField.uint24("em_c_rand.SourceAddress", "Source Address", base.HEX, gt_Address)

	local f_CrcCCITT = ProtoField.uint16("em_c_rand.CRC", "CRC CCITT", base.HEX)

	p_self.fields = {
					------For Reg------
					f_Reg_Reserved1,
					f_IPInform,
					f_PowerSaveRequest,
					f_Register,
					f_Reg_Reserved2,
					------------------

					------------------
					f_Emergency,
					f_EA_IG,
					f_Privacy,
					f_SD,
					f_EA_SD,
					f_Broadcast,
					f_HR,
					f_OV,
					f_PL,
					f_StatM,
					f_StatL,
					f_PX,
					f_Reserved1,
					f_Reserved2,
					f_SupD,
					f_ShD,
					f_AL,
					f_Reserved,
					f_ServiceKind,
					f_TargetAddress,
					f_CSyscode,
					f_SourceAddress, 
					f_CrcCCITT
					}
		
	function p_self.dissector(buf, pkt, root)

		if (g_IsShowSubProtocolName) then
			pkt.cols.protocol:set(p_self.description)
		end
		local t = root:add(p_self, buf(0))
		local pos = 0

		if (0x0 == g_ServiceKind 				-- Individual Voice Call, Ambient Listening
			or 0x1 == g_ServiceKind 			-- (Group, Broadcast, All, Emergency) Voice Call
			or 0x9 == g_ServiceKind) then		-- Answer Call Service

			ParseE_PX(buf, pkt, t, pos)
			pos = pos + 1

			ParseSupD_SK(buf, pkt, t, pos)
			pos = pos + 1

		elseif (0x2 == g_ServiceKind 			-- Individual Packet Data Call
				or 0x3 == g_ServiceKind 		-- Talk Group Packet Data Call
				or 0x4 == g_ServiceKind 		-- UDT Short Data Individual Call
				or 0x5 == g_ServiceKind) then	-- UDT Short Data Talk Group Call

			ParseE_PX(buf, pkt, t, pos)
			pos = pos + 1

			ParseShD_SK(buf, pkt, t, pos)
			pos = pos + 1

		elseif (0xC == g_ServiceKind) then		-- Call Alert
			
			if (g_MFID == 0x10) then			-- Motorola_MFID
				ParseCallAlert(buf, pkt, t, pos)
			end
			pos = pos + 2
		elseif (0xE == g_ServiceKind) then		-- Registration

			ParseRegistration(buf, pkt, t, pos)
			pos = pos + 2 + 3 + 3
		elseif (0xD == g_ServiceKind) then		-- Random access by SU for User Id

			ParseUserID(buf, pkt, t, pos)		-- Not Test.
			pos = pos + 2 + 3 + 3
		elseif (0x7 == g_ServiceKind) then		-- Emergency Alarm

			ParseEmergencyAlarm(buf, pkt, t, pos)
			pos = pos + 2
		else
			pos = pos + 1
			t:add(f_ServiceKind, buf(pos, 1))
			pos = pos + 1
		end

		if (0xE ~= g_ServiceKind and 0xD ~= g_ServiceKind) then			-- Not Registration and Not User Id

			t:add(f_TargetAddress, buf(pos, 3))
			pos = pos + 3
			
			t:add(f_SourceAddress, buf(pos, 3))
			pos = pos + 3

			g_info = g_info .. string.format("[%s] Src:0x%X Tgt:0x%X",
				gt_ServiceKind[g_ServiceKind], g_SourceAddress, g_TargetAddress)

		else
			local newServiceKindValue = BitHolder:_lshift(g_Opcode, 8) + g_ServiceKind
		
			if (0x0 == g_MFID) then				-- Standart Registration
		
				g_info = g_info .. string.format("[%s] Src:0x%X CSyscode:0x%X",
					gt_ServiceKind[newServiceKindValue], g_SourceAddress, g_TargetAddress)
			else

				g_info = g_info .. string.format("[%s] Src:0x%X Tgt:0x%X",
					gt_ServiceKind[newServiceKindValue], g_SourceAddress, g_TargetAddress)

			end
		end

		t:add(f_CrcCCITT, buf(pos, 2))
		pos = pos + 2

		pkt.cols.info:set(g_info)
	end

	-- Check wheather the em_c_rand dissector has been created successfully.
	CheckProtocolDissector("em_c_rand")


	------------------------------------------------------------------------------------
	-- Parse the first byte of C_Rand:
	--	 1    2    3    4     5    6    7    8
	--|  E |  P | SD | B/HR | OV |    PL   | PX |
	------------------------------------------------------------------------------------
	function ParseE_PX(buf, pkt, t, pos)

		t:add(f_Emergency, buf(pos, 1))
		t:add(f_Privacy, buf(pos, 1))
		t:add(f_SD, buf(pos, 1))

		if (0x2 == g_ServiceKind 			-- Individual Packet Data Call
			or 0x3 == g_ServiceKind) then	-- Talk Group Packet Data Call
			t:add(f_HR, buf(pos, 1))
		else
			t:add(f_Broadcast, buf(pos, 1))
		end

		t:add(f_OV, buf(pos, 1))
		t:add(f_PL, buf(pos, 1))
		t:add(f_PX, buf(pos, 1))

	end

	------------------------------------------------------------------------------------
	-- Parse the second byte of C_Rand:
	--	1    2    3    4    5    6    7    8
	--| Sup_D  | AL |  R |    Service Kind   |
	------------------------------------------------------------------------------------
	function ParseSupD_SK(buf, pkt, t, pos)

		t:add(f_SupD, buf(pos, 1))
		if (0x9 == g_ServiceKind) then		-- Answer Call Service
			t:add(f_AR, buf(pos, 1))
		else
			t:add(f_AL, buf(pos, 1))
		end
		t:add(f_Reserved, buf(pos, 1))
		t:add(f_ServiceKind, buf(pos, 1))

	end

	------------------------------------------------------------------------------------
	-- Parse the second byte of C_Rand: 
	--	1    2    3    4    5    6    7    8
	--| Sup_D  |   Sh_D  |    Service Kind   |
	------------------------------------------------------------------------------------
	function ParseShD_SK(buf, pkt, t, pos)

		t:add(f_SupD, buf(pos, 1))
		t:add(f_ShD, buf(pos, 1))
		t:add(f_ServiceKind, buf(pos, 1))

	end

	------------------------------------------------------------------------------------
	-- Parse the first 2 bytes of C_Rand: 
	--
	-- |        Reserved 1         |
	-- | Reserved 2 | Service Kind |
	------------------------------------------------------------------------------------
	function ParseCallAlert(buf, pkt, t, pos)

		t:add(f_Reserved1, buf(pos + 0, 1))
		t:add(f_Reserved2, buf(pos + 1, 1))

	end

	------------------------------------------------------------------------------------
	-- Parse the first 2 bytes of C_Rand: 
	--     1    2    3   4   5   6   7   8
	-- 1 | IG | SD |   Start_M(5bit)  | PX  |	
	-- 2 | AL | IG | Start_L | Service Kind |	
	-- 3 |                                  |	
	-- 4 |      Emergency Group Address     |	
	-- 5 |                                  |	
	-- 6 |                                  |	
	-- 7 |        Source SU Address         |	
	-- 8 |                                  |	
	------------------------------------------------------------------------------------
	function ParseEmergencyAlarm(buf, pkt, t, pos)

		t:add(f_EA_IG, buf(pos, 1))
		t:add(f_EA_SD, buf(pos, 1))
		t:add(f_StatM, buf(pos, 1))
		t:add(f_PX, buf(pos, 1))
		
		t:add(f_SupD, buf(pos + 1, 1))
		t:add(f_StatL, buf(pos + 1, 1))
		t:add(f_ServiceKind, buf(pos + 1, 1))

	end

	------------------------------------------------------------------------------------
	-- Parse the Standard Registration C_Rand: 
	--     1   2     3     4   5   6   7    8
	-- 1 | P | R | IPInf | Power Save Req | PX  |	
	-- 2 | SupD  |      R    |    Service Kind  |
	-- 3 |            0000 0000                 |	
	-- 4 |                                      |
	-- 5 |            C_Syscode                 |	
	-- 6 |                                      |
	-- 7 |          Source SU Address           |	
	-- 8 |                                      |

	-- Parse the Motorola Registration C_Rand: 
	--     1   2     3     4   5   6   7    8
	-- 1 | P | R | IPInf | Power Save Req | PX  |	
	-- 2 | SupD  |      R    |    Service Kind  |
	-- 3 |                                      |	
	-- 4 |          Target Address              |
	-- 5 |                                      |	
	-- 6 |                                      |
	-- 7 |          Source SU Address           |	
	-- 8 |                                      |
	------------------------------------------------------------------------------------
	function ParseRegistration(buf, pkt, t, pos)

		t:add(f_Reg_Reserved1, buf(pos, 1))
		t:add(f_Privacy, buf(pos, 1))
		t:add(f_IPInform, buf(pos, 1))
		t:add(f_PowerSaveRequest, buf(pos, 1))
		t:add(f_Register, buf(pos, 1))
		t:add(f_PX, buf(pos, 1))

		t:add(f_SupD, buf(pos + 1, 1))
		t:add(f_Reg_Reserved2, buf(pos + 1, 1))
		local newServiceKindValue = BitHolder:_lshift(g_Opcode, 8) + g_ServiceKind
		-- Logger:AppendLog("newServiceKindValue: 0x%X", newServiceKindValue)
		-- t:add(f_ServiceKind, buf(pos + 1, 1), newServiceKindValue, "" .. gt_ServiceKind[newServiceKindValue])
		local ti = t:add(f_ServiceKind, buf(pos + 1, 1))
		ti:append_text("  -->  " .. gt_ServiceKind[newServiceKindValue])

		if (0x10 == g_MFID) then		-- Motorola
			
			t:add(f_TargetAddress, buf(pos + 2, 3))
			t:add(f_SourceAddress, buf(pos + 5, 3))

		else 							-- Standard

			t:add(f_CSyscode, buf(pos + 3, 2))
			t:add(f_SourceAddress, buf(pos + 5, 3))

		end
	end



	------------------------------------------------------------------------------------
	-- Parse the Proprieatry C_MSI_Rand: Random access by SU for user ID.
	------------------------------------------------------------------------------------
	function ParseUserID(buf, pkt, t, pos)

		if (0x10 == g_MFID) then		-- Motorola

			t:add(f_Reg_Reserved1, buf(pos, 1))
			t:add(f_Privacy, buf(pos, 1))
			t:add(f_Char1, buf(pos, 1))

			t:add(f_NumOfChar, buf(pos + 1, 1))
			local newServiceKindValue = BitHolder:_lshift(g_Opcode, 8) + g_ServiceKind
			local ti = t:add(f_ServiceKind, buf(pos + 1, 1))
			ti:append_text("  -->  " .. gt_ServiceKind[newServiceKindValue])

			
			t:add(f_Char2, buf(pos + 2, 1))
			t:add(f_Char3, buf(pos + 2, 2))
			t:add(f_Char4, buf(pos + 3, 2))
			t:add(f_Char5, buf(pos + 4, 1))
			t:add(f_SourceAddress, buf(pos + 5, 3))

		else 							-- Standard

			--t:add(f_CSyscode, buf(pos + 3, 2))
			--t:add(f_SourceAddress, buf(pos + 5, 3))

		end
	end
end



----------------------------------------------------------------------------------
-- Date: 2014-10-30
-- Author: Liao Ying-RQT768
-- File: EmeraldPClear.lua
-- Description: Handle the Emerald P_Clear CSBK PDU only. Called by the EmeraldCSBK.lua.
----------------------------------------------------------------------------------
do

	local p_self = Proto("em_p_clear", "Em_P_Clear")		-- The name can't contains Upper Case Letter

	--local f_MFID = ProtoField.uint8("em_p_clear.mfid", "MFID(May be the Feature set ID)", base.HEX)

	local f_PhysicalChannelNum = ProtoField.uint16("em_p_clear.PhysicalChannelNumber", "Physical Channel Number", base.DEC, nil, 0xFFF0)	-- mask is 0xFFF0
	local f_Reserved = ProtoField.uint8("em_p_clear.Reserved", "Reserved", base.HEX, nil, 0x0E)	-- mask is 1110
	local f_IG = ProtoField.uint8("em_p_clear.IG", "IG", base.HEX, gt_IG, 0x01)	-- mask is 0001

	local f_TargetAddress = ProtoField.uint24("em_p_clear.TargetAddress", "Target Address", base.HEX, gt_Address)

	local f_SourceAddress = ProtoField.uint24("em_p_clear.SourceAddress", "Source Address", base.HEX, gt_Address)

	local f_CrcCCITT = ProtoField.uint16("em_p_clear.CRC", "CRC CCITT", base.HEX)

	p_self.fields = {
					--f_MFID, 
					f_PhysicalChannelNum, 
					f_Reserved,
					f_IG,
					f_TargetAddress, 
					f_SourceAddress,
					f_CrcCCITT
					}
		
	function p_self.dissector(buf, pkt, root)

		if (g_IsShowSubProtocolName) then
			pkt.cols.protocol:set(p_self.description)
		end
		local t = root:add(p_self, buf(0))
		local pos = 0

		--t:add(f_MFID, buf(pos, 1))
		--pos = pos + 1

		t:add(f_PhysicalChannelNum, buf(pos, 2))
		local pcn = buf(pos, 2):uint()
		pcn = BitHolder:_rshift(pcn, 4)
		pos = pos + 1

		t:add(f_Reserved, buf(pos, 1))
		t:add(f_IG, buf(pos, 1))
		local ig = buf(pos, 1):uint()
		ig = BitHolder:_and(ig, 0x1)
		pos = pos + 1

		t:add(f_TargetAddress, buf(pos, 3))
		pos = pos + 3
		
		t:add(f_SourceAddress, buf(pos, 3))
		pos = pos + 3
		
		g_info = g_info .. string.format("Src:0x%X Tgt:0x%X ", g_SourceAddress, g_TargetAddress)
		pkt.cols.info:set(g_info)
		
		t:add(f_CrcCCITT, buf(pos, 2))
		pos = pos + 2
	end

	CheckProtocolDissector("em_p_clear")
end



----------------------------------------------------------------------------------
-- Date: 2014-10-30
-- Author: Liao Ying-RQT768
-- File: EmeraldTdGrant.lua
-- Description: Handle the Emerald Td_Grant CSBK PDU only. Called by the EmeraldCSBK.lua.
----------------------------------------------------------------------------------
do

	local t_PacketMode = {
		[0x0] = "2:1 mode",
		[0x1] = "1:1 mode (not supported)"
	}

	local p_self = Proto("em_d_grant", "Em_D_Grant")		-- The name can't contains Upper Case Letter

	local f_PhysicalChannelNum = ProtoField.uint16("em_d_grant.PhysicalChannelNumber", "Physical Channel Number", base.DEC, nil, 0xFFF0)	-- mask is 0xFFF0
	local f_LogicalChannelNum = ProtoField.uint8("em_d_grant.LogicalChannelNumber", "Logical Channel Number", base.HEX, gt_LogicChannelNum, 0x08)	-- mask is 1000
	local f_PacketMode = ProtoField.uint8("em_d_grant.PacketMode", "Packet Mode", base.HEX, t_PacketMode, 0x04)	-- mask is 0100
	local f_Emergency = ProtoField.bool("em_d_grant.Emergency", "Emergency", 8, nil, 0x02)	-- mask is 0010
	local f_Offset = ProtoField.uint8("em_d_grant.Offset", "Offset", base.HEX, gt_Offset, 0x01)	-- mask is 0001

	local f_TargetAddress = ProtoField.uint24("em_d_grant.TargetAddress", "Target Address", base.HEX, gt_Address)

	local f_SourceAddress = ProtoField.uint24("em_d_grant.SourceAddress", "Source Address", base.HEX, gt_Address)

	local f_CrcCCITT = ProtoField.uint16("em_d_grant.CRC", "CRC CCITT", base.HEX)

	p_self.fields = {

					f_PhysicalChannelNum, 
					f_LogicalChannelNum, 
					f_PacketMode, 
					f_Emergency, 
					f_Offset, 
					f_TargetAddress, 
					f_SourceAddress, 
					f_CrcCCITT
					}
		
	function p_self.dissector(buf, pkt, root)

		if (g_IsShowSubProtocolName) then
			pkt.cols.protocol:set(p_self.description)
		end
		local t = root:add(p_self, buf(0))
		local pos = 0

		--t:add(f_MFID, buf(pos, 1))
		--pos = pos + 1

		t:add(f_PhysicalChannelNum, buf(pos, 2))
		local pcn = buf(pos, 2):uint()
		pcn = BitHolder:_rshift(pcn, 4)
		pos = pos + 1

		t:add(f_LogicalChannelNum, buf(pos, 1))
		local lcn = buf(pos, 1):uint()
		lcn = BitHolder:_and(lcn, 0x08)
		lcn = BitHolder:_rshift(lcn, 3)
		t:add(f_PacketMode, buf(pos, 1))
		t:add(f_Emergency, buf(pos, 1))
		t:add(f_Offset, buf(pos, 1))
		pos = pos + 1

		t:add(f_TargetAddress, buf(pos, 3))
		pos = pos + 3
		
		t:add(f_SourceAddress, buf(pos, 3))
		pos = pos + 3
		
		t:add(f_CrcCCITT, buf(pos, 2))
		pos = pos + 2

		-- g_info = g_info .. string.format("PhysicalChannelNum:%d LogicalChannelNum:%d ", pcn, lcn)
		g_info = g_info .. string.format("Src:0x%X Tgt:0x%X ", g_SourceAddress, g_TargetAddress)
		pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("em_d_grant")
end



----------------------------------------------------------------------------------
-- Date: 2014-10-30
-- Author: Liao Ying-RQT768
-- File: EmeraldTvGrant.lua
-- Description: Handle the Emerald Tv_Grant CSBK PDU only. Called by the EmeraldCSBK.lua.
----------------------------------------------------------------------------------
do
	local p_self = Proto("em_v_grant", "Em_V_Grant")		-- The name can't contains Upper Case Letter

	--local f_MFID = ProtoField.uint8("em_v_grant.mfid", "MFID", base.HEX)

	local f_PhysicalChannelNum = ProtoField.uint16("em_v_grant.PhysicalChannelNumber", "Physical Channel Number", base.DEC, nil, 0xFFF0)	-- mask is 0xFFF0
	local f_LogicalChannelNum = ProtoField.uint8("em_v_grant.LogicalChannelNumber", "Logical Channel Number", base.HEX, gt_LogicChannelNum, 0x08)	-- mask is 1000
	local f_OpenVoiceCallMode = ProtoField.uint8("em_v_grant.OpenVocie", "Open Voice Call Mode(Not Supported)", base.HEX, nil, 0x04)	-- mask is 0100
	local f_Emergency = ProtoField.bool("em_v_grant.Emergency", "Emergency", 8, nil, 0x02)	-- mask is 0010
	local f_Offset = ProtoField.uint8("em_v_grant.Offset", "Offset", base.HEX, gt_Offset, 0x01)	-- mask is 0001

	local f_TargetAddress = ProtoField.uint24("em_v_grant.TargetAddress", "Target Address", base.HEX, gt_Address)

	local f_SourceAddress = ProtoField.uint24("em_v_grant.SourceAddress", "Source Address", base.HEX, gt_Address)

	local f_CrcCCITT = ProtoField.uint16("em_v_grant.CRC", "CRC CCITT", base.HEX)

	p_self.fields = {
					--f_MFID, 
					f_PhysicalChannelNum, 
					f_LogicalChannelNum, 
					f_OpenVoiceCallMode, 
					f_Emergency, 
					f_Offset, 
					f_TargetAddress, 
					f_SourceAddress, 
					f_CrcCCITT
					}
		
	function p_self.dissector(buf, pkt, root)

		if (g_IsShowSubProtocolName) then
			pkt.cols.protocol:set(p_self.description)
		end
		local t = root:add(p_self, buf(0))
		local pos = 0

		--t:add(f_MFID, buf(pos, 1))
		--pos = pos + 1

		t:add(f_PhysicalChannelNum, buf(pos, 2))
		local pcn = buf(pos, 2):uint()
		pcn = BitHolder:_rshift(pcn, 4)
		pos = pos + 1

		t:add(f_LogicalChannelNum, buf(pos, 1))
		local lcn = buf(pos, 1):uint()
		lcn = BitHolder:_and(lcn, 0x08)
		lcn = BitHolder:_rshift(lcn, 3)
		t:add(f_OpenVoiceCallMode, buf(pos, 1))
		t:add(f_Emergency, buf(pos, 1))
		t:add(f_Offset, buf(pos, 1))
		pos = pos + 1

		t:add(f_TargetAddress, buf(pos, 3))
		pos = pos + 3
		
		local tSrc = t:add(f_SourceAddress, buf(pos, 3))
		-- tSrc:append_text(gt_Address[g_SourceAddress])
		pos = pos + 3
		
		t:add(f_CrcCCITT, buf(pos, 2))
		pos = pos + 2

		-- g_info = g_info .. string.format("PhysicalChannelNum:%d LogicalChannelNum:%d ", pcn, lcn)
		g_info = g_info .. string.format("Src:0x%X Tgt:0x%X ", g_SourceAddress, g_TargetAddress)
		pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("em_v_grant")
end







----------------------------------------------------------------------------------
-- Date: 2014-10-30
-- Author: Liao Ying-RQT768
-- File: EmeraldCAck.lua
-- Description: Handle the Emerald C_ACK CSBK PDU only. Called by the EmeraldCSBK.lua.
--[[
	1. Ack for Registration (C_ACKD) (Outbound Control Channel, Reply by FNE)	
		The following Reason Codes are valid in case of Registration: C_ACK, C_NACK
		Response for Registration  : C_ACKD (Reg_Accepted) PDU, (D: Downlink, U: Uplink)
		Response for Authentication: C_ACKU (Reason Code= MS_Accepted (01000100), Target address=Response, Source Address=My SUID) PDU. 

	2. Proprietary Ack for Registration (Proprietary C_ACKD)

	3. Authentication Response (C_ACKU) (Inbound Control Channel, By SU)

	4. Name – C_ACKD (Authentication Challenge Response)

]]
----------------------------------------------------------------------------------
do
	local p_self = Proto("em_c_ack", "Em_C_ACK")		-- The name can't contains Upper Case Letter

	local f_IG = ProtoField.uint8("em_c_ack.IG", "IG", base.HEX, gt_IG, 0x80)										-- mask is 1000 0000
	local f_ResponseCheck = ProtoField.uint8("em_c_ack.ResponseCheck", "Response Check", base.HEX, nil, 0x7E)		-- mask is 0111 1110
	local f_ResponseCheckMoto = ProtoField.uint8("em_c_ack.ResponseCheck", "Response Check", base.HEX, nil, 0xFE)	-- mask is 1111 1110
	local f_ReasonCode = ProtoField.uint16("em_c_ack.ReasonCode", "Reason Code", base.HEX, gt_ACKReasonCode, 0x1FE)	-- mask is 0000 0001 1111 1110
		local f_ACKType = ProtoField.uint16("em_c_ack.ACKType", "ACK Type", base.HEX, gt_ACKType, 0x180)			-- mask is 0000 0001 1000 0000
		local f_Direction = ProtoField.uint16("em_c_ack.Direction", "Direction", base.HEX, gt_ACKDirection, 0x40)	-- mask is 0000 0000 0100 0000
		local f_Reason = ProtoField.uint16("em_c_ack.Reason", "Reason", base.HEX, nil, 0x3E)						-- mask is 0000 0000 0011 1110

	local f_Reserved = ProtoField.uint8("em_c_ack.Reserved", "Reserved", base.HEX, nil, 0x01)						-- mask is 0000 0001

	local f_TargetAddress = ProtoField.uint24("em_c_ack.TargetAddress", "Target Address", base.HEX, gt_Address)
	local f_AuthenticationResponse = ProtoField.uint24("em_c_ack.AuthenticationResponse", "Authentication Response", base.HEX)

	local f_SourceAddress = ProtoField.uint24("em_c_ack.SourceAddress", "Source Address", base.HEX, gt_Address)

	local f_CrcCCITT = ProtoField.uint16("em_c_ack.CRC", "CRC CCITT", base.HEX)

	p_self.fields = {
					f_IG,
					f_ResponseCheck,
					f_ResponseCheckMoto,
					f_ReasonCode,
					f_Reserved,
					f_ACKType,
					f_Direction,
					f_Reason, 
					f_TargetAddress,
					f_AuthenticationResponse,
					f_SourceAddress, 
					f_CrcCCITT
					}
		
	function p_self.dissector(buf, pkt, root)

		if (g_IsShowSubProtocolName) then
			pkt.cols.protocol:set(p_self.description)
		end

		local ackReaconCode = -1
		local ackDirection = -1
		local ackType = -1
		local errorInfo = ""

		local t = root:add(p_self, buf(0))
		local pos = 0

		if (0x10 == g_MFID) then						-- Motorola
			t:add(f_ResponseCheckMoto, buf(pos, 1))
		else
			t:add(f_IG, buf(pos, 1))
			t:add(f_ResponseCheck, buf(pos, 1))
		end

		ackReaconCode = buf(pos, 2):uint()
		ackReaconCode = BitHolder:_and(ackReaconCode, 0x1FE)
		ackReaconCode = BitHolder:_rshift(ackReaconCode, 1)
		--Logger:AppendLog("ackReaconCode: %s", ackReaconCode)
		
		t_reason = t:add(f_ReasonCode, buf(pos, 2))
		if (0x10 == g_MFID) and (0x63 == ackReaconCode) then						-- Motorola
			t_reason:append_text(" --> if MFID == Motorola, means Reg_But_No_AffiliationAccepted")
		end

		do
			t_reason:add(f_ACKType, buf(pos, 2))
			ackType = buf(pos, 2):uint()
			ackType = BitHolder:_and(ackType, 0x180)
			ackType = BitHolder:_rshift(ackType, 7)
			--Logger:AppendLog("ackType: %s", ackType)

			t_reason:add(f_Direction, buf(pos, 2))
			ackDirection = buf(pos + 1, 1):uint()
			ackDirection = BitHolder:_and(ackDirection, 0x40)
			ackDirection = BitHolder:_rshift(ackDirection, 6)
			--Logger:AppendLog("ackDirection: %s", ackDirection)

			-- Check Data
			if (0x20 == g_Opcode and 1 ~= ackDirection) then		-- C_ACKDownlink

				errorInfo = "(Data Confliction Detected. C_ACKD direction must be 1.)"
				Logger:AppendLog(errorInfo)

			elseif (0x21 == g_Opcode and 0 ~= ackDirection) then

				errorInfo = "(Data Confliction Detected. C_ACKU direction must be 0.)"
				Logger:AppendLog(errorInfo)

			end

			t_reason:add(f_Reason, buf(pos, 2))
		end
		pos = pos + 1

		t:add(f_Reserved, buf(pos, 1))
		pos = pos + 1

		if (0x44 == ackReaconCode) then
			t:add(f_AuthenticationResponse, buf(pos, 3))
		else
			t:add(f_TargetAddress, buf(pos, 3))
		end
		pos = pos + 3
		
		t:add(f_SourceAddress, buf(pos, 3))
		pos = pos + 3
		
		t:add(f_CrcCCITT, buf(pos, 2))
		pos = pos + 2

		g_info = g_info .. string.format("C_%s %s Src:0x%X Tgt:0x%X %s",
			gt_ACKType[ackType], gt_ACKDirection[ackDirection], g_SourceAddress, g_TargetAddress, errorInfo)
		pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("em_c_ack")
end





----------------------------------------------------------------------------------
-- Date: 2014-10-30
-- Author: Liao Ying-RQT768
-- File: EmeraldCBCast.lua
-- Description: Handle the Emerald C_BCAST CSBK PDU only. Called by the EmeraldCSBK.lua.
--[[
	1.  Name: C_BCAST [Vote Now]
		Type: CSBK
		Direction: Downlink in Control Channel 

	2.	Name: C_BCAST [Ann/Withdraw TSCC]
		Type: CSBK
		Direction: Downlink in Control Channel 

	3.	Name: C_BCAST [Adjacent Site Information]
		Type: CSBK
		Direction: Downlink in Control Channel 
]]
----------------------------------------------------------------------------------
do
	local p_self = Proto("em_c_bcast", "Em_C_BCAST")		-- The name can't contains Upper Case Letter

	local f_AnnType = ProtoField.uint8("em_c_bcast.AnnType", "Ann Type", base.HEX, gt_AnnType, 0xF1)					-- mask is 1111 1000
	
	local f_BcastParam1 = ProtoField.uint24("em_c_bcast.BCastParam1", "BCast Param 1", base.HEX, nil, 0x7FFE0)			-- mask is 0000 0111 1111 1111 1110 0000
	local f_Reserved1 = ProtoField.uint16("em_c_bcast.Reserved", "Reserved", base.HEX, nil, 0x780)						-- mask is 0000 0111 1000 0000
	local f_Ch1ColorCode = ProtoField.uint8("em_c_bcast.Ch1ColorCode", "Channel 1 Color Code", base.HEX, nil, 0x78) 	-- mask is 0111 1000
	local f_Ch2ColorCode = ProtoField.uint16("em_c_bcast.Ch2ColorCode", "Channel 2 Color Code", base.HEX, nil, 0x780)	-- mask is 0000 0111 1000 0000
	local f_Ch1AwFlag = ProtoField.uint8("em_c_bcast.Ch1AwFlag", "Channel 1 Add/Withdraw Flag", base.HEX, nil, 0x40) 	-- mask is 0100 0000
	local f_Ch2AwFlag = ProtoField.uint8("em_c_bcast.Ch2AwFlag", "Channel 2 Add/Withdraw Flag", base.HEX, nil, 0x20) 	-- mask is 0010 0000

	local f_Reg = ProtoField.bool("em_c_bcast.Reg", "Require to register", 8, nil, 0x10)								-- mask is 0001 0000
	local f_BackOff = ProtoField.uint8("em_c_bcast.Backoff", "Back Off", base.DEC, nil, 0x0F)							-- mask is 00001111
	local f_CSysCode = ProtoField.uint16("em_c_bcast.CSyscode", "C Syscode", base.HEX)

	local f_BcastParam2 = ProtoField.uint24("em_c_bcast.BCastParam2", "BCast Param 2", base.HEX)
	local f_BcastCh1 = ProtoField.uint16("em_c_bcast.BCastCh1", "BCast Channel 1", base.HEX, nil, 0xFFF0)				-- mask is 1111 1111 1111 0000 
	local f_BcastCh2 = ProtoField.uint16("em_c_bcast.BCastCh2", "BCast Channel 2", base.HEX, nil, 0x0FFF)			    -- mask is 0000 0000 0000 1111 1111 1111
	local f_2LSB = ProtoField.uint16("em_c_bcast.2LSB", "2 LSB", base.HEX, nil, 0xC0)								    -- mask is 1100 0000 
	local f_AC = ProtoField.bool("em_c_bcast.ActiveConnection", "Active Connection", 8, nil, 0x20)						-- mask is 0010 0000
	local f_Reserved2 = ProtoField.uint16("em_c_bcast.Reserved", "Reserved", base.HEX, nil, 0x1F8)						-- mask is 0001 1111 1000 0000
	local f_SiteStart = ProtoField.uint8("em_c_bcast.SiteStart", "Site Start", base.HEX, nil, 0x70)						-- mask is 0111 0000
	local f_VotedSiteChannel = ProtoField.uint16("em_c_bcast.VotedSiteChannel", "Voted Site Channel", base.HEX, nil, 0x0FFF)				-- mask is 0000 1111 1111 1111
	local f_AdjSiteChannel = ProtoField.uint16("em_c_bcast.AdjSiteChannel", "Adjacent Site Active Control Channel", base.HEX, nil, 0x0FFF)	-- mask is 0000 1111 1111 1111

	local f_CrcCCITT = ProtoField.uint16("em_c_bcast.CRC", "CRC CCITT", base.HEX)

	p_self.fields = {
					f_AnnType,
					f_BcastParam1,
					f_Ch1ColorCode,
					f_Ch2ColorCode,
					f_Ch1AwFlag,
					f_Ch2AwFlag,
					f_Reg,
					f_BackOff,
					f_CSysCode,
					f_BcastParam2,
					f_BcastCh1,
					f_BcastCh2,
					f_2LSB,
					f_AC,
					f_Reserved2,
					f_Reserved1,
					f_SiteStart,
					f_VotedSiteChannel,
					f_AdjSiteChannel,
					f_CrcCCITT
					}
		
	function p_self.dissector(buf, pkt, root)

		if (g_IsShowSubProtocolName) then
			pkt.cols.protocol:set(p_self.description)
		end

		local t = root:add(p_self, buf(0))
		local pos = 0

		if (0x10 == g_MFID) then						-- Motorola

			-- Call Motorola BCast function
			return
		end
		t:add(f_AnnType, buf(pos, 1))
		annType = buf(pos, 1):uint()
		annType = BitHolder:_rshift(annType, 4)

		-- Logger:AppendLog("annType: %s", annType)
		if (0 == annType) then		-- Ann-WD_TSCC

			t:add(f_Reserved1, buf(pos, 2))
			pos = pos + 1

			t:add(f_Ch1ColorCode, buf(pos, 1))
			t:add(f_Ch2ColorCode, buf(pos, 2))
			pos = pos + 1

			t:add(f_Ch1AwFlag, buf(pos, 1))
			t:add(f_Ch2AwFlag, buf(pos, 1))
			t:add(f_Reg, buf(pos, 1))
			t:add(f_BackOff, buf(pos, 1))
			pos = pos + 1

			t:add(f_CSysCode, buf(pos, 2))
			pos = pos + 2

			t:add(f_BcastCh1, buf(pos, 2))
			pos = pos + 1

			t:add(f_BcastCh2, buf(pos, 2))
			pos = pos + 2

		elseif (6 == annType or 2 == annType) then	-- Adjacent_site or Vote_Now
			
			t:add(f_BcastParam1, buf(pos, 3))
			pos = pos + 2

			t:add(f_Reg, buf(pos, 1))
			t:add(f_BackOff, buf(pos, 1))
			pos = pos + 1

			t:add(f_CSysCode, buf(pos, 2))
			pos = pos + 2

			t:add(f_2LSB, buf(pos, 1))
			t:add(f_AC, buf(pos, 1))
			t:add(f_Reserved2, buf(pos, 2))
			pos = pos + 1

			t:add(f_SiteStart, buf(pos, 1))
			
			if (6 == annType) then
				t:add(f_AdjSiteChannel, buf(pos, 2))
			elseif (2 == annType) then
				t:add(f_VotedSiteChannel, buf(pos, 2))
			else

			end

			pos = pos + 2

		else 		-- Ex
			pos = pos + 8
		end

		t:add(f_CrcCCITT, buf(pos, 2))
		pos = pos + 2

		g_info = g_info .. string.format("%s", gt_AnnType[annType] or " ")
			
		pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("em_c_bcast")
end





----------------------------------------------------------------------------------
-- Date: 2014-10-30
-- Author: Liao Ying-RQT768
-- File: EmeraldPMaint.lua
-- Description: Handle the Emerald P_MAINT CSBK PDU only. Called by the EmeraldCSBK.lua.
----------------------------------------------------------------------------------
do
	local p_self = Proto("em_p_maint", "Em_P_Maint")		-- The name can't contains Upper Case Letter

	local f_Reserved1 = ProtoField.uint16("em_p_maint.Reserved", "Reserved", base.HEX, nil, 0xFFF0)						-- mask is 1111 1111 1111 0000
	local f_MaintKind = ProtoField.uint8("em_p_maint.MaintKind", "Maintenance Kind", base.HEX, gt_MaintKind, 0x0E)		-- mask is 0000 1110
	local f_Reserved2 = ProtoField.uint8("em_p_maint.Reserved", "Reserved", base.HEX, nil, 0x01)						-- mask is 0000 0001
	

	local f_TargetAddress = ProtoField.uint24("em_p_maint.TargetAddress", "Target Address", base.HEX)
	
	local f_SourceAddress = ProtoField.uint24("em_p_maint.SourceAddress", "Source Address", base.HEX, gt_Address)

	local f_CrcCCITT = ProtoField.uint16("em_p_maint.CRC", "CRC CCITT", base.HEX)

	p_self.fields = {
					f_Reserved1,
					f_Reserved2,
					f_MaintKind,
					f_TargetAddress,
					f_SourceAddress,
					f_CrcCCITT
					}
		
	function p_self.dissector(buf, pkt, root)

		if (g_IsShowSubProtocolName) then
			pkt.cols.protocol:set(p_self.description)
		end

		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_Reserved1, buf(pos, 2))
		pos = pos + 1

		t:add(f_MaintKind, buf(pos, 1))
		maintKind = buf(pos, 1):uint()
		maintKind = BitHolder:_and(maintKind, 0x0E)
		maintKind = BitHolder:_rshift(maintKind, 1)
		t:add(f_Reserved2, buf(pos, 1))
		pos = pos + 1

		t:add(f_TargetAddress, buf(pos, 3))
		pos = pos + 3

		t:add(f_SourceAddress, buf(pos, 3))
		pos = pos + 3

		t:add(f_CrcCCITT, buf(pos, 2))
		pos = pos + 2

		g_info = g_info .. string.format("Src:0x%X Tgt:0x%X", g_SourceAddress, g_TargetAddress)
			
		pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("em_p_maint")
end





----------------------------------------------------------------------------------
-- Date: 2014-11-11
-- Author: Liao Ying-RQT768
-- File: EmeraldCMove.lua
-- Description: Handle the Emerald C_MOVE CSBK PDU only. Called by the EmeraldCSBK.lua.
----------------------------------------------------------------------------------
do
	local p_self = Proto("em_c_move", "Em_C_Move")		-- The name can't contains Upper Case Letter

	local f_Reserved1 = ProtoField.uint16("em_c_move.Reserved", "Reserved", base.HEX, nil, 0xFF10)			-- mask is 1111 1111 1000 0000
	local f_Mask = ProtoField.uint8("em_c_move.Mask", "Mask", base.HEX, nil, 0x7C)							-- mask is 0111 1100
	local f_Reserved2 = ProtoField.uint16("em_c_move.Reserved", "Reserved", base.HEX, nil, 0x03E0)			-- mask is 0000 0011 1110 0000
	
	local f_Reg = ProtoField.bool("em_c_move.Reg", "Require to register", 8, nil, 0x10)						-- mask is 0001 0000
	local f_BackOff = ProtoField.uint8("em_c_move.Backoff", "Back Off", base.DEC, nil, 0x0F)				-- mask is 0000 1111

	local f_Reserved3 = ProtoField.uint8("em_c_move.Reserved", "Reserved", base.HEX, nil, 0xF0)				-- mask is 1111 0000
	local f_ChannelID = ProtoField.uint16("em_c_move.ChannelID", "New Active Control ID", base.HEX, nil, 0x0FFF)	-- mask is 0000 1111 1111 1111

	local f_MSAddress = ProtoField.uint24("em_c_move.MSAddress", "MS Address", base.HEX)

	local f_CrcCCITT = ProtoField.uint16("em_c_move.CRC", "CRC CCITT", base.HEX)

	p_self.fields = {
					f_Reserved1,
					f_Reserved2,
					f_Reserved3,
					f_Mask,
					f_Reg,
					f_BackOff,
					f_ChannelID,
					f_MSAddress,
					f_CrcCCITT
					}
		
	function p_self.dissector(buf, pkt, root)

		if (g_IsShowSubProtocolName) then
			pkt.cols.protocol:set(p_self.description)
		end

		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_Reserved1, buf(pos, 2))
		pos = pos + 1

		t:add(f_Mask, buf(pos, 1))
		t:add(f_Reserved2, buf(pos, 2))
		pos = pos + 1

		t:add(f_Reg, buf(pos, 1))
		t:add(f_BackOff, buf(pos, 1))
		pos = pos + 1

		t:add(f_Reserved3, buf(pos, 1))
		t:add(f_ChannelID, buf(pos, 2))
		pos = pos + 2

		t:add(f_MSAddress, buf(pos, 3))
		pos = pos + 3

		t:add(f_CrcCCITT, buf(pos, 2))
		pos = pos + 2

		--g_info = g_info .. string.format("Src:0x%X Tgt:0x%X", g_SourceAddress, g_TargetAddress)
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("em_c_move")
end





----------------------------------------------------------------------------------
-- Date: 2014-11-11
-- Author: Liao Ying-RQT768
-- File: EmeraldCAcvit.lua
-- Description: Handle the Emerald C_ACVIT CSBK PDU only. Called by the EmeraldCSBK.lua.
----------------------------------------------------------------------------------
do
	local p_self = Proto("em_c_acvit", "Em_C_ACVIT")		-- The name can't contains Upper Case Letter

	local f_SOM = ProtoField.uint8("em_c_acvit.ServiceOptionsMirror", "Service Options Mirror", base.HEX, nil, 0xFE)		-- mask is 1111 1110
	local f_SKF = ProtoField.uint8("em_c_acvit.ServiceKindFlag", "Service Kind Flag", base.HEX, gt_SKF, 0x01)				-- mask is 0000 0001

	local f_Reserved1 = ProtoField.uint8("em_c_acvit.Reserved", "Reserved", base.HEX, nil, 0xC0)						-- mask is 1100 0000
	local f_ApBlock = ProtoField.uint8("em_c_acvit.AppendedDataBlock", "Appended Data Blocks", base.DEC, nil, 0x30)	 	-- mask is 0011 0000
	local f_ServiceKind = ProtoField.uint8("em_c_acvit.ServiceKind", "Service Kind", base.HEX, gt_ServiceKind, 0x0F) 	-- mask is 0000 1111

	local f_TargetAddress = ProtoField.uint24("em_c_acvit.TargetAddress", "Target Address", base.HEX, gt_Address)
	local f_AuthChallengeValue = ProtoField.uint24("em_c_acvit.AuthChallengeValue", "Authentication Challenge Value", base.HEX, nil)

	local f_CrcCCITT = ProtoField.uint16("em_c_acvit.CRC", "CRC CCITT", base.HEX)

	p_self.fields = {
					f_SOM,
					f_SKF,
					f_Reserved1,
					f_ApBlock,
					f_ServiceKind,
					f_TargetAddress,
					f_AuthChallengeValue,
					f_CrcCCITT
					}
		
	function p_self.dissector(buf, pkt, root)

		if (g_IsShowSubProtocolName) then
			pkt.cols.protocol:set(p_self.description)
		end

		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_SOM, buf(pos, 1))
		t:add(f_SKF, buf(pos, 1))
		pos = pos + 1

		t:add(f_Reserved1, buf(pos, 1))
		t:add(f_ApBlock, buf(pos, 1))
		t:add(f_ServiceKind, buf(pos, 1))
		pos = pos + 1

		t:add(f_TargetAddress, buf(pos, 3))
		pos = pos + 3

		t:add(f_AuthChallengeValue, buf(pos, 3))
		pos = pos + 3

		t:add(f_CrcCCITT, buf(pos, 2))
		pos = pos + 2

		g_info = g_info .. string.format("Src:0x%X Tgt:0x%X", g_SourceAddress, g_TargetAddress)
		pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("em_c_acvit")
end





----------------------------------------------------------------------------------
-- Date: 2014-11-11
-- Author: Liao Ying-RQT768
-- File: EmeraldPProtect.lua
-- Description: Handle the Emerald P_PROTECT CSBK PDU only. Called by the EmeraldCSBK.lua.
----------------------------------------------------------------------------------
do
	t_ProtectKind = {
		[0x0] = "DIS_PTT",
		[0x1] = "EN_PTT",
		[0x2] = "Illegally Parked"
	}

	local p_self = Proto("em_p_protect", "Em_P_PROTECT")		-- The name can't contains Upper Case Letter

	local f_Reserved1 = ProtoField.uint16("em_p_protect.Reserved", "Reserved", base.HEX, nil, 0xFFF0)	 	-- mask is 1111 1111 1111 0000

	local f_ProtectKind = ProtoField.uint8("em_p_protect.ProtectKind", "Protect Kind", base.HEX, t_ProtectKind, 0x0E) 	-- mask is 0000 1110
	local f_IG = ProtoField.uint8("em_p_protect.IG", "IG", base.HEX, gt_IG, 0x01)										-- mask is 0000 0001

	local f_TargetAddress = ProtoField.uint24("em_p_protect.TargetAddress", "Target Address", base.HEX, gt_Address)
	local f_SourceAddress = ProtoField.uint24("em_p_protect.SourceAddress", "Source Address", base.HEX, gt_Address)

	local f_CrcCCITT = ProtoField.uint16("em_p_protect.CRC", "CRC CCITT", base.HEX)

	p_self.fields = {
					f_Reserved1,
					f_ProtectKind,
					f_IG,
					f_TargetAddress,
					f_SourceAddress,
					f_CrcCCITT
					}
		
	function p_self.dissector(buf, pkt, root)

		if (g_IsShowSubProtocolName) then
			pkt.cols.protocol:set(p_self.description)
		end

		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_Reserved1, buf(pos, 2))
		pos = pos + 1

		t:add(f_ProtectKind, buf(pos, 1))
		t:add(f_IG, buf(pos, 1))
		pos = pos + 1

		t:add(f_TargetAddress, buf(pos, 3))
		pos = pos + 3

		t:add(f_SourceAddress, buf(pos, 3))
		pos = pos + 3

		t:add(f_CrcCCITT, buf(pos, 2))
		pos = pos + 2

		g_info = g_info .. string.format("Src:0x%X Tgt:0x%X", g_SourceAddress, g_TargetAddress)
		pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("em_p_protect")
end

