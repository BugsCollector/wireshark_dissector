----------------------------------------------------------------------------------
-- Date: 2014-11-13
-- Author: Liao Ying-RQT768
-- File: EmeraldWin32DriverInput.lua
-- Description: Handle all the Emerald Win32 Driver Input PDU.
--				The fields are very like with EmeraldCSBK, but all the data is little-endian by 16 bits.
----------------------------------------------------------------------------------

do
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------

	local p_self = Proto("em_win32_input", "Em_Win32_Input")		-- The name can't contains Upper Case Letter

	local f_slotNum  = ProtoField.uint8("em_win32_input.SlotNum", "Slot Number", base.HEX, gt_SlotNum, 0x80)	-- Mask is 1000 0000 b
	local f_dataType = ProtoField.uint8("em_win32_input.DataType", "Data Type", base.HEX, ota_datatypes)

	local f_frameLen = ProtoField.uint16("em_win32_input.FrameLength", "Frame Length", base.HEX)

	local f_sigBits  = ProtoField.uint16("em_win32_input.SigBits", "Sig Bits", base.HEX)

	local f_dataSize = ProtoField.uint16("em_win32_input.DataSize", "Data Size", base.HEX)

	local f_LB = ProtoField.bool("em_win32_input.LB", "LB", 8, nil, 0x80)	-- mask is 1000 0000
	local f_PF = ProtoField.bool("em_win32_input.PF", "PF", 8, nil, 0x40)	-- mask is 0100 0000
	local f_Opcode = ProtoField.uint8("em_win32_input.Opcode", "Opcode", base.HEX, ota_csbkOpcodes, 0x3F)	-- maks is 0x3F, means 00111111

	local f_MFID = ProtoField.uint8("em_win32_input.MFID", "MFID(May be the Feature set ID)", base.HEX, gt_MFID)

	local f_ServiceKind = ProtoField.uint8("em_win32_input.ServiceKind", "Service Kind", base.HEX, gt_ServiceKind, 0x0F) 		-- mask is 0000 1111
	
	local f_TargetAddress = ProtoField.uint24("em_win32_input.TargetAddress", "Target Address", base.HEX, gt_Address)

	local f_SourceAddress = ProtoField.uint24("em_win32_input.SourceAddress", "Source Address", base.HEX, gt_Address)

	p_self.fields = {
					f_dataType, 
					f_slotNum, 
					f_frameLen, 
					f_sigBits, 
					f_dataSize, 
					f_LB, 
					f_PF, 
					f_Opcode,
					f_MFID,
					f_ServiceKind,
					f_TargetAddress,
					f_SourceAddress
					}
		
	function p_self.dissector(buf, pkt, root)
		
		pkt.cols.protocol:set("Win32")

		-----------------------------------------
		--Reset the global var
		g_MFID = 0
		g_DataType = -1
		g_Opcode = -1
		g_ServiceKind = -1
		g_TargetAddress = 0
		g_SourceAddress = 0
		-----------------------------------------

		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_slotNum, buf(pos, 1))
		local slotNum = buf(pos, 1):uint()
		slotNum = BitHolder:_rshift(slotNum, 7)
		if (0 == slotNum) then
			g_info = g_info .. "INB1:"
		else
			g_info = g_info .. "INB2:"
		end
		pos = pos + 1

		t:add(f_dataType, buf(pos, 1))
		g_DataType = buf(pos, 1):uint()
		if (0xFF == g_DataType) then
			g_info = g_info .. "POLL"
			pkt.cols.info:set(g_info)
			return
		end
		pos = pos + 1

		g_info = g_info .. string.format("Win32Input %s[0x%X] - ", ota_datatypes[g_DataType] or "UnknownDataType", g_DataType)
		pkt.cols.info:set(g_info)

		if (0x32 == g_DataType or 0x36 == g_DataType) then	-- These data doesn't contain the following fields.
			return
		end

		t:add_le(f_frameLen, buf(pos, 2))
		local frameLen = buf(pos, 2):le_uint()
		pos = pos + 2

		t:add_le(f_sigBits, buf(pos, 2))
		local sigBits = buf(pos, 2):le_uint()
		local sync1 = BitHolder:_and(sigBits, 0x0002)
		local sync0 = BitHolder:_and(sigBits, 0x0001)
		local emb = BitHolder:_and(sigBits, 0x0010)
		pos = pos + 2

		if (0x0A == g_DataType) then			-- DATA_TYPE_VOICE: To display the ABCDEF bursts of Super Voice Frame.
			if (sync0 == 1) then
				g_info = g_info .. "Burst A"
			elseif (sync0 == 0 and emb == 0x10) then
				g_info = g_info .. "Burst E"
			else
				g_info = g_info .. "Burst B/C/D/F"
			end
			pkt.cols.info:set(g_info)
			return
		end
		
		t:add_le(f_dataSize, buf(pos, 2))
		pos = pos + 2

		-- MFID
		t:add(f_MFID, buf(pos, 1))
		g_MFID = buf(pos, 1):uint()
		pos = pos + 1
		
		-- opcode
		t:add(f_LB, buf(pos, 1))
		t:add(f_PF, buf(pos, 1))
		t:add(f_Opcode, buf(pos, 1))
		g_Opcode = buf(pos, 1):uint()
		g_Opcode = clearbit(g_Opcode, bit(7))
		g_Opcode = clearbit(g_Opcode, bit(8))
		pos = pos + 1

		-- CSBK ServiceKind Source Address 
		if (0x03 == g_DataType) then

			t:add(f_ServiceKind, buf(pos, 1))
			g_ServiceKind = buf(pos, 1):uint()
			g_ServiceKind = BitHolder:_and(g_ServiceKind, 0x0F)
			pos = pos + 2

			t:add_le(f_TargetAddress, buf(pos, 3))
			g_TargetAddress = buf(pos, 3):le_uint()
			pos = pos + 3

			t:add_le(f_SourceAddress, buf(pos, 3))
			g_SourceAddress = buf(pos, 3):le_uint()
			pos = pos + 3

			g_info = g_info .. string.format("%s [%s] Src:0x%X Tgt:0x%X",
				ota_csbkOpcodes[g_Opcode], gt_ServiceKind[g_ServiceKind], g_SourceAddress, g_TargetAddress)
			pkt.cols.info:set(g_info)
		end
	end

	CheckProtocolDissector("em_win32_input")

end
