----------------------------------------------------------------------------------
-- Date: 2014-11-10
-- Author: Liao Ying-RQT768
-- File: EmeraldCACH.lua
-- Description: Handle all the Emerald CACH PDU. Call sub dissectors by SLCO.
----------------------------------------------------------------------------------
do
	------------------------------------------------------------------------------
	-- Some Common String Tables.
	-- For All the CSBK PDU.
	-- The 'gt' prefix means global table.
	------------------------------------------------------------------------------
	gt_ShortGroupID = {
		[0x000] = "Full Group Id (24-bit) follows in next SLC",
		[0x3FD] = "Site All Call",
		[0x3FE] = "Multi-Site All Call",
		[0x3FF] = "System All Call"
	}
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------


	------------------------------------------------------------------------------
	-- Some Common Global Var
	------------------------------------------------------------------------------
	g_SLCO = nil
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
		
	local t_cachSLCO = {
		[0x02] = "SYS_Params Short LC",
		[0x0E] = "CALL_Params Short LC",
		[0x0F] = "CALL_Params_Ext Short LC",
		[0xFF] = "CACH_SLCO_END"
		}


	local p_self = Proto("em_cach", "Em_CACH")		-- The name can't contains Upper Case Letter

	local f_slotNum  = ProtoField.uint8("em_cach.SlotNum", "Slot Number", base.HEX, gt_SlotNum, 0x80)	-- Mask is 1000 0000 b
	local f_dataType = ProtoField.uint8("em_cach.DataType", "Data Type", base.HEX, t_dataTypes)

	local f_frameLen = ProtoField.uint16("em_cach.FrameLength", "Frame Length", base.HEX)

	local f_sigBits  = ProtoField.uint16("em_cach.SigBits", "Sig Bits", base.HEX)

	local f_dataSize = ProtoField.uint16("em_cach.DataSize", "Data Size", base.HEX)

	local f_SLCO = ProtoField.uint8("em_cach.SLCO", "SLCO", base.HEX, ota_csbkOpcodes, 0x0F)	-- maks is 0x0F, means 0000 1111

	local f_MFID = ProtoField.uint8("em_cach.MFID", "MFID(May be the Feature set ID)", base.HEX, gt_MFID)

	p_self.fields = {
					f_dataType, 
					f_slotNum, 
					f_frameLen, 
					f_sigBits, 
					f_dataSize, 
					f_LB, 
					f_PF, 
					f_SLCO,
					f_MFID
					}
	
	function p_self.dissector(buf, pkt, root)

		-----------------------------------------
		--Reset the global var
		g_DataType = -1
		g_SLCO = -1
		-----------------------------------------

		if (g_IsShowSubProtocolName) then
			pkt.cols.protocol:set(p_self.description)
		end

		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_dataType, buf(pos, 1))
		pos = pos + 1
		g_DataType = buf(pos, 1):uint()

		t:add(f_slotNum, buf(pos, 1))
		pos = pos + 1

		t:add(f_frameLen, buf(pos, 2))
		pos = pos + 2

		t:add(f_sigBits, buf(pos, 2))
		pos = pos + 2

		t:add(f_dataSize, buf(pos, 2))
		pos = pos + 2

		-- SLCO
		t:add(f_SLCO, buf(pos, 1))
		g_SLCO = buf(pos, 1):uint()
		g_SLCO = BitHolder:_and(g_SLCO, 0x0F)
		g_info = g_info .. string.format("CACH %s[0x%X] - ", t_cachSLCO[g_SLCO] or "UnknownSLCO", g_SLCO)

		pkt.cols.info:set(g_info)
		pos = pos + 1
		
		local sub_dissector
		local subDissectorName = ""
		if (0x02 == g_SLCO) then
		
			subDissectorName = "em_cach_sysparams"	

		elseif (0xE == g_SLCO) or (0xF == g_SLCO) then

			subDissectorName = "em_cach_callparams"

		else
			subDissectorName = "data"
		end

		sub_dissector = Dissector.get(subDissectorName)
		if sub_dissector ~= nil then
			sub_dissector:call(buf(pos):tvb(), pkt, t)
		else
		end
	end

	CheckProtocolDissector("em_cach")
end




----------------------------------------------------------------------------------
-- Date: 2014-11-10
-- Author: Liao Ying-RQT768
-- File: EmeraldCACHCallParams.lua
-- Description: Handle the Emerald Call Params CACH PDU only.
----------------------------------------------------------------------------------
do
	local p_self = Proto("em_cach_callparams", "Em_CACH_CallParams")		-- The name can't contains Upper Case Letter

	local f_SLCO = ProtoField.uint8("em_cach_callparams.SLCO", "Short LC Opcode", base.HEX, nil, 0x0F)						-- mask is 0000 1111

	local f_ChannelID = ProtoField.uint16("em_cach_callparams.ChannelID", "Physical Channel ID", base.HEX, nil, 0xFFF0)		-- mask is 1111 1111 1111 0000
	local f_Slot = ProtoField.uint8("em_cach_callparams.Slot", "Slot", base.HEX, nil, 0x08)									-- mask is 0000 1000
	local f_Emergency = ProtoField.bool("em_cach_callparams.Emergency", "Emergency", 8, nil, 0x04)							-- mask is 0000 0100
	local f_ShortTalkGroupID = ProtoField.uint16("em_cach_callparams.ShortTalkGroupID", "Short Talk Group ID", base.HEX, nil, 0x3FF)-- mask is 0000 0011 1111 1111
	local f_TalkGroupID = ProtoField.uint24("em_cach_callparams.TalkGroupID", "Full 24-bit Talk Group ID", base.HEX)

	local f_Crc = ProtoField.uint8("em_cach_callparams.CRC", "Short LC CRC", base.HEX)

	p_self.fields = {
					f_SLCO,
					f_ChannelID,
					f_Slot,
					f_Emergency,
					f_ShortTalkGroupID,
					f_TalkGroupID,
					f_Crc
					}
		
	function p_self.dissector(buf, pkt, root)

		if (g_IsShowSubProtocolName) then
			pkt.cols.protocol:set(p_self.description)
		end

		local t = root:add(p_self, buf(0))
		local pos = 0

		--t:add(f_SLCO, buf(pos, 1))
		--pos = pos + 1

		if (0x0E == g_SLCO) then		-- Call_Params_Ext Short LC
			
			t:add(f_TalkGroupID, buf(pos, 3))
			pos = pos + 3

		elseif (0xF == g_SLCO) then	-- Call_Parmas Short LC
			
			t:add(f_ChannelID, buf(pos, 2))
			pos = pos + 1

			t:add(f_Slot, buf(pos, 1))
			t:add(f_Emergency, buf(pos, 1))
			t:add(f_ShortTalkGroupID, buf(pos, 2))
			pos = pos + 2

		else

			pos = pos + 3
		end

		t:add(f_Crc, buf(pos, 1))
		pos = pos + 1

		--g_info = g_info .. string.format("Src:0x%X Tgt:0x%X", g_SourceAddress, g_TargetAddress)	
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("em_cach_callparams")
end




----------------------------------------------------------------------------------
-- Date: 2014-11-10
-- Author: Liao Ying-RQT768
-- File: EmeraldCACHSysParams.lua
-- Description: Handle the Emerald System Params CACH PDU only.
----------------------------------------------------------------------------------
do
	local p_self = Proto("em_cach_sysparams", "Em_CACH_SysParams")		-- The name can't contains Upper Case Letter

	local f_SLCO = ProtoField.uint8("em_cach_sysparams.SLCO", "Short LC Opcode", base.HEX, nil, 0x0F)						-- mask is 0000 1111

	local f_NetworkModel = ProtoField.uint8("em_cach_sysparams.NetworkModel", "Network Model", base.HEX, gt_NetworkModel, 0xC0)		-- mask is 1100 0000
	local f_Syscode = ProtoField.uint16("em_cach_sysparams.Syscode", "NetID + SiteID", base.HEX, nil, 0x3FFC)						-- mask is 0011 1111 1111 1100
		local f_NetID = ProtoField.uint16("em_cach_sysparams.NetID", "Net ID", base.HEX)
		local f_SiteID = ProtoField.uint16("em_cach_sysparams.SiteID", "Site ID", base.HEX)

	local f_Reg = ProtoField.bool("em_cach_sysparams.Reg", "Require to register", 8, nil, 0x02)								-- mask is 0000 0010

	local f_CommonSlotCounter = ProtoField.uint16("em_cach_sysparams.CommonSlotCounter", "Common Slot Counter", base.HEX, nil, 0x01FF)	-- mask is 0000 0001 1111 1111

	local f_Crc = ProtoField.uint8("em_cach_sysparams.CRC", "Short LC CRC", base.HEX)

	p_self.fields = {
					f_SLCO,
					f_NetworkModel,
					f_Syscode,
					f_NetID,
					f_SiteID,
					f_Reg,
					f_CommonSlotCounter,
					f_Crc
					}
		
	function p_self.dissector(buf, pkt, root)

		if (g_IsShowSubProtocolName) then
			pkt.cols.protocol:set(p_self.description)
		end

		local t = root:add(p_self, buf(0))
		local pos = 0

		--t:add(f_SLCO, buf(pos, 1))
		--pos = pos + 1

		t:add(f_NetworkModel, buf(pos, 1))
		local networkModel = buf(pos, 1):uint()
		networkModel = BitHolder:_rshift(networkModel, 6)

		local netID = 0
		local siteID = 0
		syscodeTree = t:add(f_Syscode, buf(pos, 2))
		do
			-- Tiny:  9 3
			-- Small: 7 5
			-- Large: 4 8
			-- Huge:  2 10
			netID = buf(pos, 2):uint()
			--Logger:AppendLog("1 netID = 0x%X", netID)
			netID = BitHolder:_and(netID, 0x3FFC)		-- mask is 0011 1111 1111 1100
			--Logger:AppendLog("2 netID = 0x%X", netID)
			netID = BitHolder:_rshift(netID, 2 + 12 - gt_NetIDWidth[networkModel])
			--Logger:AppendLog("3 netID = 0x%X", netID)
			syscodeTree:add(f_NetID, buf(pos, 2), netID)

			siteID = buf(pos, 2):uint()
			--Logger:AppendLog("1 siteID = 0x%X", siteID)
			siteID = BitHolder:_and(siteID, 0x3FFC)		-- mask is 0011 1111 1111 1100
			--Logger:AppendLog("2 siteID = 0x%X", siteID)
			for i = 1, gt_NetIDWidth[networkModel], 1 do
				siteID = clearbit(siteID, bit(16 - 2 - i + 1))
				--Logger:AppendLog("2.%d Clear: %d, siteID = 0x%X", i, 16 - 2 - i + 1, siteID)
			end
			--Logger:AppendLog("3 siteID = 0x%X", siteID)
			siteID = BitHolder:_rshift(siteID, 2)
			--Logger:AppendLog("4 siteID = 0x%X", siteID)
			syscodeTree:add(f_SiteID, buf(pos, 2), siteID)

		end
		pos = pos + 1

		t:add(f_Reg, buf(pos, 1))
		t:add(f_CommonSlotCounter, buf(pos, 2))
		pos = pos + 2

		t:add(f_Crc, buf(pos, 1))
		pos = pos + 1

		--g_info = g_info .. string.format("Src:0x%X Tgt:0x%X", g_SourceAddress, g_TargetAddress)	
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("em_cach_sysparams")
end

