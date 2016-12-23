
do
	local p_ota = Proto("ota", "OTA")

	local ota_datatypes = {
		[0x01] = "DATA_TYPE_VOICE_HEADER",
		[0x0A] = "DATA_TYPE_VOICE",
		[0x0B] = "BDH_SYNC_BEACON",
		[0x02] = "DATA_TYPE_VOICE_TERMINATOR",
		[0x06] = "DATA_TYPE_DATA_HEADER",
		[0x08] = "DATA_TYPE_DATA_COMM_CONF",
		[0x07] = "DATA_TYPE_DATA_COMM_UNCONF",
		[0x13] = "DATA_TYPE_SYNC_UNDETECT",
		[0x22] = "DATA_TYPE_STATUS_CSBK",
		[0x23] = "DATA_TYPE_CAP_PLUS_LC_IN_CACH",
		[0x03] = "DATA_TYPE_CSBK",
		[0x00] = "DATA_TYPE_ESYNC",
		[0xFF] = "DATA_TYPE_PARITY_FAIL",
		[0x33] = "DATA_TYPE_ENCRYPTION_MSG",
		[0x16] = "DATA_TYPE_LC_IN_CACH_ARM",
		[0x27] = "DATA_TYPE_VOICE_WITH_INTERRUPT_REQUEST",
		[0x20] = "DATA_TYPE_CWID_COMPLETE",
		[0x30] = "DATA_TYPE_TRIDENT_SLC_IN_CACH_ARM",
		[0x1F] = "DATA_TYPE_PARITY_FAIL"
		}


	local ota_opcodes = {
		[0x20] = "ACK_RSP_UNIT",
		[0x1E] = "BACK_CHN_CMD_REQ",
		[0x1F] = "CALL_ALRT_REQ",
		[0x27] = "EMRG_ALRM_REQ",
		[0x24] = "EXT_FUNC_CMD_OR_RSP",
		[0x28] = "GPS_REQUEST",
		[0x29] = "GPS_ANNOUNCEMENT",
		[0x2A] = "GPS_GRANT",
		[0x26] = "NACK_RSP",
		[0x3D] = "PREAMBLE_CSBK",
		[0x1D] = "REMOTE_MON_CMD",
		[0x04] = "U_TO_U_REQ",
		[0x05] = "U_TO_U_RESP",
		[0x38] = "WAKEUP_CSBK",
		[0x3E] = "STATUS_CSBK",
		[0x3B] = "AUTOROAMING_CSBK",
		[0x01] = "RESPONSE_HEADER_BLOCK",
		[0x02] = "UNCONFIRMED_DATA_HEADER",
		[0x03] = "CONFIRMED_DATA_HEADER",
		[0x0F] = "ENCRYPTION_DATA_HEADER"
		}

	f_byte1 = ProtoField.string("ota.byte1","Header")
	f_payload = ProtoField.bytes("ota.payload","Payload", base.HEX)
	local f_datatype = ProtoField.uint8("ota.datatype", "Data Type", base.HEX, {[0x01] = "DATA_TYPE_VOICE_HEADER", [0x0A] = "DATA_TYPE_VOICE",
					[0x02] = "DATA_TYPE_VOICE_TERMINATOR", [0x06] = "DATA_TYPE_DATA_HEADER", [0x08] = "DATA_TYPE_DATA_COMM_CONF", [0x07] = "DATA_TYPE_DATA_COMM_UNCONF", [0x0B] = "BDH_SYNC_BEACON",
					[0x13] = "DATA_TYPE_SYNC_UNDETECT", [0x22] = "DATA_TYPE_STATUS_CSBK", [0x23] = "DATA_TYPE_CAP_PLUS_LC_IN_CACH", [0x03] = "DATA_TYPE_CSBK",
					[0x00] = "DATA_TYPE_ESYNC", [0xFF] = "DATA_TYPE_PARITY_FAIL", [0x33] = "DATA_TYPE_ENCRYPTION_MSG", [0x16] = "DATA_TYPE_LC_IN_CACH_ARM",
					[0x27] = "DATA_TYPE_VOICE_WITH_INTERRUPT_REQUEST", [0x20] = "DATA_TYPE_CWID_COMPLETE",})
	local f_dataHeaderOpcode = ProtoField.uint8("ota.opcode","Opcode",base.HEX, {[0x01] = "RESPONSE_HEADER_BLOCK", [0x02] = "UNCONFIRMED_DATA_HEADER",
					[0x03] = "CONFIRMED_DATA_HEADER", [0x0F] = "ENCRYPTION_DATA_HEADER",},0x3F)
	local f_csbkOpcode = ProtoField.uint8("ota.opcode","Opcode",base.HEX,{[0x20] = "ACK_RSP_UNIT", [0x1E] = "BACK_CHN_CMD_REQ",
					[0x1F] = "CALL_ALRT_REQ", [0x27] = "EMRG_ALRM_REQ", [0x24] = "EXT_FUNC_CMD_OR_RSP", [0x28] = "GPS_REQUEST", [0x29] = "GPS_ANNOUNCEMENT",
					[0x2A] = "GPS_GRANT", [0x26] = "NACK_RSP", [0x3D] = "PREAMBLE_CSBK", [0x1D] = "REMOTE_MON_CMD", [0x04] = "U_TO_U_REQ", [0x05] = "U_TO_U_RESP",
					[0x38] = "WAKEUP_CSBK", [0x3E] = "STATUS_CSBK", [0x3B] = "AUTOROAMING_CSBK",},0x3F)

	p_ota.fields = {f_byte1, f_datatype, f_csbkOpcode, f_dataHeaderOpcode, f_payload}

	function putbit(p)
		return 2 ^ (p - 1)  -- 1-based indexing
	end
	function hasbit(x, p)
		return x % (p + p) >= p
	end
	function setbit(x, p)
		return hasbit(x, p) and x or x + p
	end
	function clearbit(x, p)
		return hasbit(x, p) and x - p or x
	end


	function p_ota.dissector(buf,pkt,root)
		pkt.cols.protocol:set("OTA")
		local t = nil
		local opID = buf(0,2):uint()
		local len = buf:len()

		if opID == 0x534f then --0x534f is SO
			t = root:add(p_ota, buf(0,len))
			t:add(f_byte1, buf(0,len))
			local dispheader = buf(0,len):string()

			local info = string.format("%s",dispheader)
			pkt.cols.info:set(info)
		elseif opID == 0x80ff then
			local info = "Slot2 POLL"
			pkt.cols.info:set(info)
		elseif opID == 0x00ff then
			local info = "Slot1 POLL"
			pkt.cols.info:set(info)
		elseif opID == 0x5350 then -- 0x5350 is SPK
			t = root:add(p_ota, buf(0,6))
			t:add(f_byte1, buf(0,6))
			t:add(f_payload, buf(8, len - 8))
			local dispheader = buf(0,6):string()
			local info = string.format("%s",dispheader)
			pkt.cols.info:set(info)
				
		elseif opID == 0x5458 then --0x5458 is TX
			local datatype = buf(5,1):uint()
			t = root:add(p_ota, buf(0,5))
			t:add(f_byte1, buf(0,5))
			local dispheader = buf(0,5):string()
			t:add(f_datatype, buf(5,1))

			if datatype == 0x03 then --CSBK
				t:add(f_csbkOpcode,buf(14,1))
				local opcode = buf(14,1):uint()
				opcode=clearbit(opcode,putbit(7))
				opcode=clearbit(opcode,putbit(8))
				local info = string.format("%s[%02X]%-31s Opcode:[%X] %s",dispheader,datatype,(ota_datatypes[datatype] ~= nil) and ota_datatypes[datatype] or "Unknown datatype!",opcode,(ota_opcodes[opcode] ~= nil) and ota_opcodes[opcode] or "Unknown OTA opcode!")
				pkt.cols.info:set(info)

			elseif datatype == 0x06 then --Data Header
				t:add(f_dataHeaderOpcode, buf(14,1))
				local opcode = buf(14,1):uint()
				opcode=clearbit(opcode,putbit(7))
				opcode=clearbit(opcode,putbit(8))
				local info = string.format("%s[%02X]%-31s Opcode:[%X] %s",dispheader,datatype,(ota_datatypes[datatype] ~= nil) and ota_datatypes[datatype] or "Unknown datatype!",opcode,(ota_opcodes[opcode] ~= nil) and ota_opcodes[opcode] or "Unknown OTA opcode!")
				pkt.cols.info:set(info)

			else
				local info = string.format("%s[%02X]%-31s",dispheader,datatype,(ota_datatypes[datatype] ~= nil) and ota_datatypes[datatype] or "Unknown datatype!")
				pkt.cols.info:set(info)
			end
		end
	end
end