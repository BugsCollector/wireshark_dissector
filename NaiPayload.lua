
----------------------------------------------------------------------------------
-- Date: 2015-03-03
-- Author: Liao Ying-RQT768
-- File: NaiPayload.lua
-- Description: 
-- The NaiPayload is not asn.1 format,
-- We need to parse it as the document 'MultiSite_System_Protocol.doc' described.
----------------------------------------------------------------------------------
do
	gt_WLOpcode = {
		[0x00] = "Not Defined",
		[0x01] = "WL_REGISTRATION_REQUEST",			-- done
		[0x02] = "WL_REGISTRATION_STATUS",			-- done
		[0x03] = "WL_REGISTRATION_GENERAL_OPS",		-- done
		[0x04] = "WL_PROTOCOL_VERSION_QUERY",		-- done
		[0x05] = "WL_PROTOCOL_VERSION_QUERY_RESPONSE",		-- done
		[0x06] = "RESERVED",
		[0x07] = "WL_DATA_PDU_TX",			-- done
		[0x08] = "WL_DATA_PDU_TX_STATUS",	-- done
		[0x09] = "WL_DATA_PDU_RX",			-- done
		[0x0A] = "RESERVED",
		[0x0B] = "RESERVED",
		[0x0C] = "RESERVED",
		[0x0D] = "RESERVED",
		[0x0E] = "RESERVED",
		[0x0F] = "RESERVED",
		[0x10] = "RESERVED",
		[0x11] = "WL_CHNL_STATUS",			-- done
		[0x12] = "WL_CHNL_STATUS_QUERY",	-- done
		[0x13] = "WL_VC_CHNL_CTRL_REQ",		-- done
		[0x14] = "RESERVED",
		[0x15] = "RESERVED",
		[0x16] = "WL_VC_CHNL_CTRL_STATUS",	-- done
		[0x17] = "WL_VC_CSBK_CALL",			-- done
		[0x18] = "WL_VC_VOICE_START",		-- done
		[0x19] = "WL_VC_VOICE_END_BURST",	-- done
		[0x1A] = "Not Defined",
		[0x1B] = "Not Defined",
		[0x1C] = "Not Defined",
		[0x1D] = "Not Defined",
		[0x1E] = "Not Defined",
		[0x1F] = "Not Defined",
		[0x20] = "WL_VC_CALL_SESSION_STATUS",-- done
		[0x21] = "WL_VC_VOICE_BURST",		-- done
		[0x22] = "WL_VC_PRIVACY_BURST",		-- done
		[0x23] = "RESERVED FOR VOICE",
		[0x24] = "RESERVED FOR VOICE",
		[0x25] = "RESERVED FOR VOICE",
		[0x26] = "RESERVED FOR VOICE",
		[0x27] = "RESERVED FOR VOICE",
		[0x28] = "RESERVED FOR VOICE",
		[0x29] = "RESERVED FOR VOICE",
		[0x2A] = "RESERVED FOR VOICE",
		[0x2B] = "RESERVED FOR VOICE",
		[0x2C] = "RESERVED FOR VOICE",
		[0x2D] = "RESERVED FOR VOICE",
		[0x2E] = "RESERVED FOR VOICE",
		[0x2F] = "RESERVED FOR VOICE",
		[0x30] = "WL_Data_Call_Request",
		[0x31] = "WL_Data_Call_Status",
		[0x32] = "WL_Data_Call_Receive",
		
		--    0x33-0xFF RESERVED.
		[0xFF] = "WLOpcodeEnd"
	}

	g_WLOpcode = 0
	g_PayLoadLength = 0

	local p_self = Proto("eml_naipayload", "EML_NaiPayload")		-- The name can't contains Upper Case Letter

	local f_Opcode = ProtoField.uint8("eml_naipayload.Opcode", "Opcode", base.HEX)
	local f_PeerID = ProtoField.uint32("eml_naipayload.PeerID", "PeerID", base.HEX)
	local f_WLOpcode = ProtoField.uint8("eml_naipayload.WLOpcode", "Wireline Opcode", base.HEX, gt_WLOpcode)
	

	p_self.fields = {
					f_Opcode,
					f_PeerID,
					f_WLOpcode
					}
		
	function p_self.dissector(buf, pkt, root)
		Logger:AppendLog("parseNaiPayload, dissector.")
		
		local t = root:add(p_self, buf(0))
		local pos = 1 -- The first 0x06 is an unknown byte, discade it.

		t:add(f_Opcode, buf(pos, 1))
		pos = pos + 1

		t:add(f_PeerID, buf(pos, 4))
		pos = pos + 4

		t:add(f_WLOpcode, buf(pos, 1))
		g_WLOpcode = buf(pos, 1):uint()
		pos = pos + 1

		g_info = g_info .. string.format("NAIPDU - WLOpcode: %s", gt_WLOpcode[g_WLOpcode])
		pkt.cols.info:set(g_info)

		local sub_dissector
		local subDissectorName = ""

		if g_WLOpcode == 0x09 then
			subDissectorName = "eml_naipayload_rx" --WL_DATA_PDU_RX
		elseif g_WLOpcode == 0x08 then
			subDissectorName = "eml_naipayload_tx_status"	-- WL_DATA_PDU_TX_STATUS
		elseif g_WLOpcode == 0x07 then
			subDissectorName = "eml_naipayload_tx"	--WL_DATA_PDU_TX
		elseif g_WLOpcode == 0x01 then
			subDissectorName = "eml_naipayload_reg_request"	--WL_REGISTRATION_REQUEST
		elseif g_WLOpcode == 0x02 then
			subDissectorName = "eml_naipayload_reg_status"	--WL_REGISTRATION_STATUS
		elseif g_WLOpcode == 0x03 then
			subDissectorName = "eml_naipayload_reg_ops"	--WL_REGISTRATION_GENERAL_OPS
		elseif g_WLOpcode == 0x04 then
			subDissectorName = "eml_naipayload_version_query"	--WL_PROTOCOL_VERSION_QUERY
		elseif g_WLOpcode == 0x05 then
			subDissectorName = "eml_naipayload_version_response"	--WL_PROTOCOL_VERSION_QUERY_RESPONSE
		elseif g_WLOpcode == 0x11 then
			subDissectorName = "eml_naipayload_channel_status"	--WL_CHNL_STATUS
		elseif g_WLOpcode == 0x12 then
			subDissectorName = "eml_naipayload_channel_status_query"	--WL_CHNL_STATUS_QUERY
		elseif g_WLOpcode == 0x13 then
			subDissectorName = "eml_naipayload_vc_chnl_ctrl_req"	--WL_VC_CHNL_CTRL_REQ
		elseif g_WLOpcode == 0x16 then
			subDissectorName = "eml_naipayload_vc_chnl_ctrl_status"	--WL_VC_CHNL_CTRL_STATUS
		elseif g_WLOpcode == 0x17 then
			subDissectorName = "eml_naipayload_vc_csbk_call"	--WL_VC_CSBK_CALL
		elseif g_WLOpcode == 0x18 then
			subDissectorName = "eml_naipayload_vc_voice_start"	--WL_VC_VOICE_START
		elseif g_WLOpcode == 0x19 then
			subDissectorName = "eml_naipayload_vc_voice_end"	--WL_VC_VOICE_END_BURST
		elseif g_WLOpcode == 0x20 then
			subDissectorName = "eml_naipayload_vc_call_session_status"	--WL_VC_CALL_SESSION_STATUS
		elseif g_WLOpcode == 0x21 then
			subDissectorName = "eml_naipayload_vc_voice_call"	--WL_VC_VOICE_BURST
		elseif g_WLOpcode == 0x22 then
			subDissectorName = "eml_naipayload_vc_voice_privacy"	--WL_VC_PRIVACY_BURST
		elseif g_WLOpcode == 0x30 then
			subDissectorName = "eml_naipayload_datacallrequest"		--WL_Data_Call_Request
		elseif g_WLOpcode == 0x31 then
			subDissectorName = "eml_naipayload_datacallstatus"		--WL_Data_Call_Status
		elseif g_WLOpcode == 0x32 then
			subDissectorName = "eml_naipayload_datacallreceive"		--WL_Data_Call_Receive
		else
			subDissectorName = "data"

		end

		sub_dissector = Dissector.get(subDissectorName)
		if sub_dissector ~= nil then
			sub_dissector:call(buf(pos):tvb(), pkt, t)
		end
	end

	CheckProtocolDissector("eml_naipayload")
end



----------------------------------------------------------------------------------
-- Date: 2015-03-03
-- Author: Liao Ying-RQT768
-- Description: WL_DATA_PDU_TX(_REQUEST) 0x07
----------------------------------------------------------------------------------
do

	local p_self = Proto("eml_naipayload_tx", "WL_DATA_PDU_TX")		-- The name can't contains Upper Case Letter

	local f_slotNumber = ProtoField.uint8("eml_naipayload_tx.slotNumber", "Slot Number", base.HEX)
	
	local f_pduID = ProtoField.uint32("eml_naipayload_tx.PDUID", "PDU ID", base.HEX)
	
	local f_callType = ProtoField.uint8("eml_naipayload_tx.callType", "Call Type", base.HEX)
	
	local f_sourceID = ProtoField.uint32("eml_naipayload_tx.SourceID", "Source ID", base.HEX)
	
	local f_targetID = ProtoField.uint32("eml_naipayload_tx.TargetID", "Target ID", base.HEX)
	
	local f_priority = ProtoField.uint8("eml_naipayload_tx.Priority", "Priority", base.HEX)

	local f_conventionalChannelAccessParameters = ProtoField.uint8("eml_naipayload_tx.conventionalChannelAccessParameters", "conventionalChannelAccessParameters", base.HEX)

	local f_conventionalChannelAccessTimeOut = ProtoField.uint8("eml_naipayload_tx.conventionalChannelAccessTimeOut", "conventionalChannelAccessTimeOut", base.HEX)

	local f_preambleDuration = ProtoField.uint8("eml_naipayload_tx.preambleDuration", "preambleDuration", base.HEX)

	local f_trunkedChannelParameters = ProtoField.uint8("eml_naipayload_tx.trunkedChannelParameters", "trunkedChannelParameters", base.HEX)

	local f_headerAttr = ProtoField.uint8("eml_naipayload_rx.headerAttr", "Header Attributes", base.HEX)

	local f_ipHdrCompressionandPrivacy = ProtoField.uint8("eml_naipayload_rx.ipHdrCompressionandPrivacy", "ipHdrCompressionandPrivacy", base.HEX)

	local f_algorithmID = ProtoField.uint8("eml_naipayload_tx.algorithmID", "algorithmID", base.HEX)

	local f_privacyKeyID = ProtoField.uint8("eml_naipayload_tx.privacyKeyID", "privacyKeyID", base.HEX)

	local f_privacyIV = ProtoField.uint32("eml_naipayload_tx.privacyIV", "privacyIV", base.HEX)

	local f_payloadLength = ProtoField.uint16("eml_naipayload_tx.payloadLength", "payloadLength", base.HEX)

	--local f_payload = ProtoField.uint8("eml_naipayload_tx.payload", "Payload", base.HEX)
	local f_payload = ProtoField.new("Payload", "eml_naipayload_tx.payload", ftypes.BYTES)
	
	local f_currentVersion = ProtoField.uint8("eml_naipayload_tx.currentersion", "Current / Accepted Version", base.HEX)

	local f_oldestVersion = ProtoField.uint8("eml_naipayload_tx.oldestVersion", "Oldest Version", base.HEX)

	local f_authenticationID = ProtoField.uint32("eml_naipayload_tx.AuthenticationID", "Authentication ID", base.HEX)
	
	local f_authenticationSignation = ProtoField.new("AuthenticationSignation", "eml_naipayload_tx.AuthenticationSignation", ftypes.BYTES)

	p_self.fields = {
					f_slotNumber,
					f_pduID,
					f_callType,
					f_sourceID,
					f_targetID,
					f_priority,
					f_conventionalChannelAccessParameters,
					f_conventionalChannelAccessTimeOut,
					f_preambleDuration,
					f_trunkedChannelParameters,
					f_headerAttr,
					f_ipHdrCompressionandPrivacy,
					f_algorithmID,
					f_privacyKeyID,
					f_privacyIV,
					f_payloadLength,
					f_payload,
					f_currentVersion,
					f_oldestVersion,
					f_authenticationID,
					f_authenticationSignation
					}
		
	function p_self.dissector(buf, pkt, root)
		
		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_slotNumber, buf(pos, 1))
		pos = pos + 1
		t:add(f_pduID, buf(pos, 4))
		pos = pos + 4
		t:add(f_callType, buf(pos, 1))
		pos = pos + 1
		t:add(f_sourceID, buf(pos, 4))
		pos = pos + 4
		t:add(f_targetID, buf(pos, 4))
		pos = pos + 4
		t:add(f_priority, buf(pos, 1))
		pos = pos + 1
		t:add(f_conventionalChannelAccessParameters, buf(pos, 1))
		pos = pos + 1
		t:add(f_conventionalChannelAccessTimeOut, buf(pos, 1))
		pos = pos + 1
		t:add(f_preambleDuration, buf(pos, 1))
		pos = pos + 1
		t:add(f_trunkedChannelParameters, buf(pos, 1))
		pos = pos + 1
		t:add(f_headerAttr, buf(pos, 1))
		pos = pos + 1
		t:add(f_ipHdrCompressionandPrivacy, buf(pos, 1))
		pos = pos + 1
		t:add(f_algorithmID, buf(pos, 1))
		pos = pos + 1
		t:add(f_privacyKeyID, buf(pos, 1))
		pos = pos + 1
		t:add(f_privacyIV, buf(pos, 4))
		pos = pos + 4
		
		t:add(f_payloadLength, buf(pos, 2))
		g_PayLoadLength = buf(pos, 2):uint()
		pos = pos + 2

		t:add(f_payload, buf(pos, g_PayLoadLength))
		pos = pos + g_PayLoadLength

		t:add(f_currentVersion, buf(pos, 1))
		pos = pos + 1
		t:add(f_oldestVersion, buf(pos, 1))
		pos = pos + 1

		t:add(f_authenticationID, buf(pos, 4))
		pos = pos + 4
		t:add(f_authenticationSignation, buf(pos, 10))
		pos = pos + 10

		--g_info = g_info .. string.format("WLOpcode:0x%X", g_WLOpcode)	
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("eml_naipayload_tx")
end



----------------------------------------------------------------------------------
-- Date: 2015-03-03
-- Author: Liao Ying-RQT768
-- Description: WL_DATA_PDU_TX_STATUS  0x08
----------------------------------------------------------------------------------
do

	local p_self = Proto("eml_naipayload_tx_status", "WL_DATA_PDU_TX_STATUS")		-- The name can't contains Upper Case Letter

	local f_slotNumber = ProtoField.uint8("eml_naipayload_tx_status.slotNumber", "Slot Number", base.HEX)
	
	local f_pduID = ProtoField.uint32("eml_naipayload_tx_status.PDUID", "PDU ID", base.HEX)
	
	local f_pduDeliveryStatusType = ProtoField.uint8("eml_naipayload_tx_status.pduDeliveryStatusType", "pduDeliveryStatusType", base.HEX)
	
	local f_pduDeliveryStatusCode = ProtoField.uint8("eml_naipayload_tx_status.pduDeliveryStatusCode", "pduDeliveryStatusCode", base.HEX)
	
	local f_subOpcode = ProtoField.uint16("eml_naipayload_tx_status.SubOpcode", "SubOpcode", base.HEX)
	
	local f_currentVersion = ProtoField.uint8("eml_naipayload_tx_status.currentersion", "Current / Accepted Version", base.HEX)

	local f_oldestVersion = ProtoField.uint8("eml_naipayload_tx_status.oldestVersion", "Oldest Version", base.HEX)

	p_self.fields = {
					f_slotNumber,
					f_pduID,
					f_pduDeliveryStatusType,
					f_pduDeliveryStatusCode,
					f_subOpcode,
					f_currentVersion,
					f_oldestVersion
					}
		
	function p_self.dissector(buf, pkt, root)
		
		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_slotNumber, buf(pos, 1))
		pos = pos + 1
		t:add(f_pduID, buf(pos, 4))
		pos = pos + 4
		t:add(f_pduDeliveryStatusType, buf(pos, 1))
		pos = pos + 1
		t:add(f_pduDeliveryStatusCode, buf(pos, 1))
		pos = pos + 1
		t:add(f_subOpcode, buf(pos, 2))
		pos = pos + 2

		t:add(f_currentVersion, buf(pos, 1))
		pos = pos + 1
		t:add(f_oldestVersion, buf(pos, 1))
		pos = pos + 1

		--g_info = g_info .. string.format("WLOpcode:0x%X", g_WLOpcode)	
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("eml_naipayload_tx_status")
end


----------------------------------------------------------------------------------
-- Date: 2015-03-03
-- Author: Liao Ying-RQT768
-- Description: WL_DATA_PDU_RX  0x09
----------------------------------------------------------------------------------
do

	local p_self = Proto("eml_naipayload_rx", "WL_DATA_PDU_RX")		-- The name can't contains Upper Case Letter

	local f_slotNumber = ProtoField.uint8("eml_naipayload_rx.slotNumber", "Slot Number", base.HEX)
	
	local f_pduID = ProtoField.uint32("eml_naipayload_rx.PDUID", "PDU ID", base.HEX)
	
	local f_callType = ProtoField.uint8("eml_naipayload_rx.callType", "Call Type", base.HEX)
	
	local f_sourceID = ProtoField.uint32("eml_naipayload_rx.SourceID", "Source ID", base.HEX)
	
	local f_targetID = ProtoField.uint32("eml_naipayload_rx.TargetID", "Target ID", base.HEX)
	
	local f_headerAttr = ProtoField.uint8("eml_naipayload_rx.headerAttr", "Header Attributes", base.HEX)

	local f_ipHdrCompressionandPrivacy = ProtoField.uint8("eml_naipayload_rx.ipHdrCompressionandPrivacy", "ipHdrCompressionandPrivacy", base.HEX)

	local f_algorithmID = ProtoField.uint8("eml_naipayload_rx.algorithmID", "algorithmID", base.HEX)

	local f_privacyKeyID = ProtoField.uint8("eml_naipayload_rx.privacyKeyID", "privacyKeyID", base.HEX)

	local f_privacyIV = ProtoField.uint32("eml_naipayload_rx.privacyIV", "privacyIV", base.HEX)

	local f_payloadLength = ProtoField.uint16("eml_naipayload_rx.payloadLength", "payloadLength", base.HEX)

	--local f_payload = ProtoField.uint8("eml_naipayload_rx.payload", "Payload", base.HEX)
	local f_payload = ProtoField.new("Payload", "eml_naipayload_rx.payload", ftypes.BYTES)
	
	local f_CRC = ProtoField.uint32("eml_naipayload_rx.crc", "CRC", base.HEX)

	local f_rawRSSIvalue = ProtoField.uint16("eml_naipayload_rx.rawRSSIvalue", "rawRSSIvalue", base.HEX)

	local f_currentVersion = ProtoField.uint8("eml_naipayload_rx.currentersion", "Current / Accepted Version", base.HEX)

	local f_oldestVersion = ProtoField.uint8("eml_naipayload_rx.oldestVersion", "Oldest Version", base.HEX)

	p_self.fields = {
					f_slotNumber,
					f_pduID,
					f_callType,
					f_sourceID,
					f_targetID,
					f_headerAttr,
					f_ipHdrCompressionandPrivacy,
					f_algorithmID,
					f_privacyKeyID,
					f_privacyIV,
					f_payloadLength,
					f_payload,
					f_CRC,
					f_rawRSSIvalue,
					f_currentVersion,
					f_oldestVersion
					}
		
	function p_self.dissector(buf, pkt, root)
		
		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_slotNumber, buf(pos, 1))
		pos = pos + 1
		t:add(f_pduID, buf(pos, 4))
		pos = pos + 4
		t:add(f_callType, buf(pos, 1))
		pos = pos + 1
		t:add(f_sourceID, buf(pos, 4))
		pos = pos + 4
		t:add(f_targetID, buf(pos, 4))
		pos = pos + 4
		t:add(f_headerAttr, buf(pos, 1))
		pos = pos + 1
		t:add(f_ipHdrCompressionandPrivacy, buf(pos, 1))
		pos = pos + 1
		t:add(f_algorithmID, buf(pos, 1))
		pos = pos + 1
		t:add(f_privacyKeyID, buf(pos, 1))
		pos = pos + 1
		t:add(f_privacyIV, buf(pos, 4))
		pos = pos + 4
		
		t:add(f_payloadLength, buf(pos, 2))
		g_PayLoadLength = buf(pos, 2):uint()
		pos = pos + 2

		t:add(f_payload, buf(pos, g_PayLoadLength))
		pos = pos + g_PayLoadLength

		t:add(f_CRC, buf(pos, 4))
		pos = pos + 4
		t:add(f_rawRSSIvalue, buf(pos, 2))
		pos = pos + 2
		t:add(f_currentVersion, buf(pos, 1))
		pos = pos + 1
		t:add(f_oldestVersion, buf(pos, 1))
		pos = pos + 1

		--g_info = g_info .. string.format("WLOpcode:0x%X", g_WLOpcode)	
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("eml_naipayload_rx")
end


----------------------------------------------------------------------------------
-- Date: 2015-03-05
-- Author: Liao Ying-RQT768
-- Description: WL_REGISTRATION_REQUEST  0x01
----------------------------------------------------------------------------------
do

	local p_self = Proto("eml_naipayload_reg_request", "WL_REGISTRATION_REQUEST")		-- The name can't contains Upper Case Letter

	local f_slotNumber = ProtoField.uint8("eml_naipayload_reg_request.slotNumber", "Slot Number", base.HEX)
	
	local f_pduID = ProtoField.uint32("eml_naipayload_reg_request.PDUID", "PDU ID", base.HEX)
	
	local f_registrationID = ProtoField.uint16("eml_naipayload_reg_request.registrationID", "registrationID", base.HEX)
	
	local f_wirelineStatusRegistration = ProtoField.uint8("eml_naipayload_reg_request.wirelineStatusRegistration", "wirelineStatusRegistration", base.HEX)

	local f_numberOfRegistrationEntries = ProtoField.uint8("eml_naipayload_reg_request.numberOfRegistrationEntries", "numberOfRegistrationEntries", base.HEX)

	local f_addressType = ProtoField.uint8("eml_naipayload_reg_request.addressType", "addressType", base.HEX)
	
	local f_addressRangeStart = ProtoField.uint32("eml_naipayload_reg_request.addressRangeStart", "addressRangeStart", base.HEX)
	
	local f_addressRangeEnd = ProtoField.uint32("eml_naipayload_reg_request.addressRangeEnd", "addressRangeEnd", base.HEX)
	
	local f_VoiceAttributes = ProtoField.uint8("eml_naipayload_reg_request.VoiceAttributes", "VoiceAttributes", base.HEX)
	
	local f_CSBKAttributes = ProtoField.uint8("eml_naipayload_reg_request.CSBKAttributes", "CSBKAttributes", base.HEX)
	
	local f_DataAttributes = ProtoField.uint8("eml_naipayload_reg_request.DataAttributes", "DataAttributes", base.HEX)
	
	local f_currentVersion = ProtoField.uint8("eml_naipayload_reg_request.currentersion", "Current / Accepted Version", base.HEX)

	local f_oldestVersion = ProtoField.uint8("eml_naipayload_reg_request.oldestVersion", "Oldest Version", base.HEX)
	
	local f_authenticationID = ProtoField.uint32("eml_naipayload_reg_request.AuthenticationID", "Authentication ID", base.HEX)
	
	local f_authenticationSignation = ProtoField.new("AuthenticationSignation", "eml_naipayload_reg_request.AuthenticationSignation", ftypes.BYTES)

	p_self.fields = {
					f_slotNumber,
					f_pduID,
					f_registrationID,
					f_wirelineStatusRegistration,
					f_numberOfRegistrationEntries,
					f_addressType,
					f_addressRangeStart,
					f_addressRangeEnd,
					f_VoiceAttributes,
					f_CSBKAttributes,
					f_DataAttributes,
					f_currentVersion,
					f_oldestVersion,
					f_authenticationID,
					f_authenticationSignation
					}
		
	function p_self.dissector(buf, pkt, root)
		
		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_slotNumber, buf(pos, 1))
		pos = pos + 1
		t:add(f_pduID, buf(pos, 4))
		pos = pos + 4
		t:add(f_registrationID, buf(pos, 2))
		pos = pos + 2
		t:add(f_wirelineStatusRegistration, buf(pos, 1))
		pos = pos + 1
		t:add(f_numberOfRegistrationEntries, buf(pos, 1))
		pos = pos + 1
		t:add(f_addressType, buf(pos, 1))
		pos = pos + 1
		t:add(f_addressRangeStart, buf(pos, 4))
		pos = pos + 4
		t:add(f_addressRangeEnd, buf(pos, 4))
		pos = pos + 4

		t:add(f_VoiceAttributes, buf(pos, 1))
		pos = pos + 1
		t:add(f_CSBKAttributes, buf(pos, 1))
		pos = pos + 1
		t:add(f_DataAttributes, buf(pos, 1))
		pos = pos + 1

		t:add(f_currentVersion, buf(pos, 1))
		pos = pos + 1
		t:add(f_oldestVersion, buf(pos, 1))
		pos = pos + 1

		t:add(f_authenticationID, buf(pos, 4))
		pos = pos + 4
		t:add(f_authenticationSignation, buf(pos, 10))
		pos = pos + 10
		--g_info = g_info .. string.format("WLOpcode:0x%X", g_WLOpcode)	
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("eml_naipayload_reg_request")
end

----------------------------------------------------------------------------------
-- Date: 2015-03-05
-- Author: Liao Ying-RQT768
-- Description: WL_REGISTRATION_STATUS  0x02
----------------------------------------------------------------------------------
do

	local p_self = Proto("eml_naipayload_reg_status", "WL_REGISTRATION_STATUS")		-- The name can't contains Upper Case Letter

	local f_pduID = ProtoField.uint32("eml_naipayload_reg_status.PDUID", "PDU ID", base.HEX)
	
	local f_registrationIDSlot1 = ProtoField.uint16("eml_naipayload_reg_status.registrationIDSlot1", "registrationIDSlot1", base.HEX)
	
	local f_registrationIDSlot2 = ProtoField.uint16("eml_naipayload_reg_status.registrationIDSlot2", "registrationIDSlot1", base.HEX)
	
	local f_registrationStatusType = ProtoField.uint8("eml_naipayload_reg_status.registrationStatusType", "registrationStatusType", base.HEX)

	local f_registrationStatusCode = ProtoField.uint8("eml_naipayload_reg_status.registrationStatusCode", "registrationStatusCode", base.HEX)

	local f_currentVersion = ProtoField.uint8("eml_naipayload_reg_status.currentersion", "Current / Accepted Version", base.HEX)

	local f_oldestVersion = ProtoField.uint8("eml_naipayload_reg_status.oldestVersion", "Oldest Version", base.HEX)
	
	p_self.fields = {
					f_pduID,
					f_registrationIDSlot1,
					f_registrationIDSlot2,
					f_registrationStatusType,
					f_registrationStatusCode,
					f_currentVersion,
					f_oldestVersion
					}
		
	function p_self.dissector(buf, pkt, root)
		
		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_pduID, buf(pos, 4))
		pos = pos + 4
		t:add(f_registrationIDSlot1, buf(pos, 2))
		pos = pos + 2
		t:add(f_registrationIDSlot2, buf(pos, 2))
		pos = pos + 2

		t:add(f_registrationStatusType, buf(pos, 1))
		pos = pos + 1
		t:add(f_registrationStatusCode, buf(pos, 1))
		pos = pos + 1

		t:add(f_currentVersion, buf(pos, 1))
		pos = pos + 1
		t:add(f_oldestVersion, buf(pos, 1))
		pos = pos + 1

		--g_info = g_info .. string.format("WLOpcode:0x%X", g_WLOpcode)	
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("eml_naipayload_reg_status")
end


----------------------------------------------------------------------------------
-- Date: 2015-03-05
-- Author: Liao Ying-RQT768
-- Description: WL_REGISTRATION_GENERAL_OPS  0x03
----------------------------------------------------------------------------------
do

	local p_self = Proto("eml_naipayload_reg_ops", "WL_REGISTRATION_GENERAL_OPS")		-- The name can't contains Upper Case Letter

	local f_slotNumber = ProtoField.uint8("eml_naipayload_reg_ops.slotNumber", "Slot Number", base.HEX)
	
	local f_pduID = ProtoField.uint32("eml_naipayload_reg_ops.PDUID", "PDU ID", base.HEX)
	
	local f_registrationOperationOpcode = ProtoField.uint8("eml_naipayload_reg_ops.registrationOperationOpcode", "registrationOperationOpcode", base.HEX)

	local f_currentVersion = ProtoField.uint8("eml_naipayload_reg_ops.currentersion", "Current / Accepted Version", base.HEX)

	local f_oldestVersion = ProtoField.uint8("eml_naipayload_reg_ops.oldestVersion", "Oldest Version", base.HEX)
	
	local f_authenticationID = ProtoField.uint32("eml_naipayload_reg_ops.AuthenticationID", "Authentication ID", base.HEX)
	
	local f_authenticationSignation = ProtoField.new("AuthenticationSignation", "eml_naipayload_reg_ops.AuthenticationSignation", ftypes.BYTES)

	p_self.fields = {
					f_slotNumber,
					f_pduID,
					f_registrationOperationOpcode,
					f_currentVersion,
					f_oldestVersion,
					f_authenticationID,
					f_authenticationSignation
					}
		
	function p_self.dissector(buf, pkt, root)
		
		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_slotNumber, buf(pos, 1))
		pos = pos + 1
		t:add(f_pduID, buf(pos, 4))
		pos = pos + 4
		t:add(f_registrationOperationOpcode, buf(pos, 1))
		pos = pos + 1

		t:add(f_currentVersion, buf(pos, 1))
		pos = pos + 1
		t:add(f_oldestVersion, buf(pos, 1))
		pos = pos + 1

		t:add(f_authenticationID, buf(pos, 4))
		pos = pos + 4
		t:add(f_authenticationSignation, buf(pos, 10))
		pos = pos + 10
		--g_info = g_info .. string.format("WLOpcode:0x%X", g_WLOpcode)	
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("eml_naipayload_reg_ops")
end




----------------------------------------------------------------------------------
-- Date: 2015-03-05
-- Author: Liao Ying-RQT768
-- Description: WL_PROTOCOL_VERSION_QUERY  0x04
----------------------------------------------------------------------------------
do

	local p_self = Proto("eml_naipayload_version_query", "WL_PROTOCOL_VERSION_QUERY")		-- The name can't contains Upper Case Letter

	local f_reserved = ProtoField.uint8("eml_naipayload_version_query.reserved", "Reserved", base.HEX)
	
	local f_queryID = ProtoField.uint32("eml_naipayload_version_query.QueryID", "Query ID", base.HEX)
	
	local f_currentVersion = ProtoField.uint8("eml_naipayload_version_query.currentersion", "Current / Accepted Version", base.HEX)

	local f_oldestVersion = ProtoField.uint8("eml_naipayload_version_query.oldestVersion", "Oldest Version", base.HEX)
	
	local f_authenticationID = ProtoField.uint32("eml_naipayload_version_query.AuthenticationID", "Authentication ID", base.HEX)
	
	local f_authenticationSignation = ProtoField.new("AuthenticationSignation", "eml_naipayload_version_query.AuthenticationSignation", ftypes.BYTES)

	p_self.fields = {
					f_reserved,
					f_queryID,
					f_currentVersion,
					f_oldestVersion,
					f_authenticationID,
					f_authenticationSignation
					}
		
	function p_self.dissector(buf, pkt, root)
		
		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_reserved, buf(pos, 1))
		pos = pos + 1
		t:add(f_queryID, buf(pos, 4))
		pos = pos + 4

		t:add(f_currentVersion, buf(pos, 1))
		pos = pos + 1
		t:add(f_oldestVersion, buf(pos, 1))
		pos = pos + 1

		t:add(f_authenticationID, buf(pos, 4))
		pos = pos + 4
		t:add(f_authenticationSignation, buf(pos, 10))
		pos = pos + 10
		--g_info = g_info .. string.format("WLOpcode:0x%X", g_WLOpcode)	
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("eml_naipayload_version_query")
end




----------------------------------------------------------------------------------
-- Date: 2015-03-05
-- Author: Liao Ying-RQT768
-- Description: WL_PROTOCOL_VERSION_QUERY_RESPONSE  0x05
----------------------------------------------------------------------------------
do

	local p_self = Proto("eml_naipayload_version_response", "WL_PROTOCOL_VERSION_QUERY_RESPONSE")		-- The name can't contains Upper Case Letter

	local f_reserved = ProtoField.uint8("eml_naipayload_version_response.reserved", "Reserved", base.HEX)
	
	local f_queryID = ProtoField.uint32("eml_naipayload_version_response.QueryID", "Query ID", base.HEX)
	
	local f_currentVersion = ProtoField.uint8("eml_naipayload_version_response.currentersion", "Current / Accepted Version", base.HEX)

	local f_oldestVersion = ProtoField.uint8("eml_naipayload_version_response.oldestVersion", "Oldest Version", base.HEX)
	
	--local f_authenticationID = ProtoField.uint32("eml_naipayload_version_response.AuthenticationID", "Authentication ID", base.HEX)
	
	--local f_authenticationSignation = ProtoField.new("AuthenticationSignation", "eml_naipayload_version_response.AuthenticationSignation", ftypes.BYTES)

	p_self.fields = {
					f_reserved,
					f_queryID,
					f_currentVersion,
					f_oldestVersion,
					--f_authenticationID,
					--f_authenticationSignation
					}
		
	function p_self.dissector(buf, pkt, root)
		
		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_reserved, buf(pos, 1))
		pos = pos + 1
		t:add(f_queryID, buf(pos, 4))
		pos = pos + 4

		t:add(f_currentVersion, buf(pos, 1))
		pos = pos + 1
		t:add(f_oldestVersion, buf(pos, 1))
		pos = pos + 1

		--t:add(f_authenticationID, buf(pos, 4))
		--pos = pos + 4
		--t:add(f_authenticationSignation, buf(pos, 10))
		--pos = pos + 10
		
		--g_info = g_info .. string.format("WLOpcode:0x%X", g_WLOpcode)	
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("eml_naipayload_version_response")
end


----------------------------------------------------------------------------------
-- Date: 2015-03-05
-- Author: Liao Ying-RQT768
-- Description: WL_CHNL_STATUS  0x11
----------------------------------------------------------------------------------
do

	local p_self = Proto("eml_naipayload_channel_status", "WL_CHNL_STATUS")		-- The name can't contains Upper Case Letter

	local f_slotNumber = ProtoField.uint8("eml_naipayload_channel_status.slotNumber", "Slot Number", base.HEX)
	
	local f_pduID = ProtoField.uint32("eml_naipayload_channel_status.PDUID", "PDU ID", base.HEX)
	
	local f_channelStatus = ProtoField.uint8("eml_naipayload_channel_status.channelStatus", "Channel Status", base.HEX)
	
	local f_restChannelStatus = ProtoField.uint8("eml_naipayload_channel_status.restChannelStatus", "Rest Channel Status", base.HEX)
	
	local f_typeOfCall = ProtoField.uint8("eml_naipayload_channel_status.typeOfCall", "Type Of Call", base.HEX)

	local f_currentVersion = ProtoField.uint8("eml_naipayload_channel_status.currentersion", "Current / Accepted Version", base.HEX)

	local f_oldestVersion = ProtoField.uint8("eml_naipayload_channel_status.oldestVersion", "Oldest Version", base.HEX)
	
	--local f_authenticationID = ProtoField.uint32("eml_naipayload_channel_status.AuthenticationID", "Authentication ID", base.HEX)
	
	--local f_authenticationSignation = ProtoField.new("AuthenticationSignation", "eml_naipayload_channel_status.AuthenticationSignation", ftypes.BYTES)

	p_self.fields = {
					f_slotNumber,
					f_pduID,
					f_channelStatus,
					f_restChannelStatus,
					f_typeOfCall,
					f_currentVersion,
					f_oldestVersion,
					--f_authenticationID,
					--f_authenticationSignation
					}
		
	function p_self.dissector(buf, pkt, root)
		
		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_slotNumber, buf(pos, 1))
		pos = pos + 1
		t:add(f_pduID, buf(pos, 4))
		pos = pos + 4

		t:add(f_channelStatus, buf(pos, 1))
		pos = pos + 1
		t:add(f_restChannelStatus, buf(pos, 1))
		pos = pos + 1
		t:add(f_typeOfCall, buf(pos, 1))
		pos = pos + 1

		t:add(f_currentVersion, buf(pos, 1))
		pos = pos + 1
		t:add(f_oldestVersion, buf(pos, 1))
		pos = pos + 1

		--t:add(f_authenticationID, buf(pos, 4))
		--pos = pos + 4
		--t:add(f_authenticationSignation, buf(pos, 10))
		--pos = pos + 10
		
		--g_info = g_info .. string.format("WLOpcode:0x%X", g_WLOpcode)	
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("eml_naipayload_channel_status")
end


----------------------------------------------------------------------------------
-- Date: 2015-03-05
-- Author: Liao Ying-RQT768
-- Description: WL_CHNL_STATUS_QUERY  0x12
----------------------------------------------------------------------------------
do

	local p_self = Proto("eml_naipayload_channel_status_query", "WL_CHNL_STATUS_QUERY")		-- The name can't contains Upper Case Letter

	local f_slotNumber = ProtoField.uint8("eml_naipayload_channel_status_query.slotNumber", "Slot Number", base.HEX)
	
	--local f_pduID = ProtoField.uint32("eml_naipayload_channel_status_query.PDUID", "PDU ID", base.HEX)
	
	--local f_channelStatus = ProtoField.uint8("eml_naipayload_channel_status_query.channelStatus", "Channel Status", base.HEX)
	
	--local f_restChannelStatus = ProtoField.uint8("eml_naipayload_channel_status_query.restChannelStatus", "Rest Channel Status", base.HEX)
	
	--local f_typeOfCall = ProtoField.uint8("eml_naipayload_channel_status_query.typeOfCall", "Type Of Call", base.HEX)

	local f_currentVersion = ProtoField.uint8("eml_naipayload_channel_status_query.currentersion", "Current / Accepted Version", base.HEX)

	local f_oldestVersion = ProtoField.uint8("eml_naipayload_channel_status_query.oldestVersion", "Oldest Version", base.HEX)
	
	local f_authenticationID = ProtoField.uint32("eml_naipayload_channel_status_query.AuthenticationID", "Authentication ID", base.HEX)
	
	local f_authenticationSignation = ProtoField.new("AuthenticationSignation", "eml_naipayload_channel_status_query.AuthenticationSignation", ftypes.BYTES)

	p_self.fields = {
					f_slotNumber,
					--f_pduID,
					--f_channelStatus,
					--f_restChannelStatus,
					--f_typeOfCall,
					f_currentVersion,
					f_oldestVersion,
					f_authenticationID,
					f_authenticationSignation
					}
		
	function p_self.dissector(buf, pkt, root)
		
		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_slotNumber, buf(pos, 1))
		pos = pos + 1
		
		--t:add(f_pduID, buf(pos, 4))
		--pos = pos + 4

		--t:add(f_channelStatus, buf(pos, 1))
		--pos = pos + 1
		--t:add(f_restChannelStatus, buf(pos, 1))
		--pos = pos + 1
		--t:add(f_typeOfCall, buf(pos, 1))
		--pos = pos + 1

		t:add(f_currentVersion, buf(pos, 1))
		pos = pos + 1
		t:add(f_oldestVersion, buf(pos, 1))
		pos = pos + 1

		t:add(f_authenticationID, buf(pos, 4))
		pos = pos + 4
		t:add(f_authenticationSignation, buf(pos, 10))
		pos = pos + 10
		
		--g_info = g_info .. string.format("WLOpcode:0x%X", g_WLOpcode)	
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("eml_naipayload_channel_status_query")
end



----------------------------------------------------------------------------------
-- Date: 2015-03-05
-- Author: Liao Ying-RQT768
-- Description: WL_VC_CHNL_CTRL_REQ  0x13
----------------------------------------------------------------------------------
do

	local p_self = Proto("eml_naipayload_vc_chnl_ctrl_req", "WL_VC_CHNL_CTRL_REQ")		-- The name can't contains Upper Case Letter

	local f_slotNumber = ProtoField.uint8("eml_naipayload_vc_chnl_ctrl_req.slotNumber", "Slot Number", base.HEX)
	
	local f_callID = ProtoField.uint32("eml_naipayload_vc_chnl_ctrl_req.CallID", "Call ID", base.HEX)
	
	local f_callType = ProtoField.uint8("eml_naipayload_vc_chnl_ctrl_req.callType", "Call Type", base.HEX)
	
	local f_sourceID = ProtoField.uint32("eml_naipayload_vc_chnl_ctrl_req.SourceID", "Source ID", base.HEX)
	
	local f_targetID = ProtoField.uint32("eml_naipayload_vc_chnl_ctrl_req.TargetID", "Target ID", base.HEX)

	local f_accessCriteria = ProtoField.uint8("eml_naipayload_vc_chnl_ctrl_req.AccessCriteria", "Access Criteria", base.HEX)

	local f_callAttr = ProtoField.uint8("eml_naipayload_vc_chnl_ctrl_req.CallAttr", "Call Attributes", base.HEX)

	local f_preambleDuration = ProtoField.uint8("eml_naipayload_vc_chnl_ctrl_req.preambleDuration", "preambleDuration", base.HEX)

	local f_reserved2 = ProtoField.uint16("eml_naipayload_vc_chnl_ctrl_req.Reserved", "Reserved", base.HEX)

	local f_CSBKParameters = ProtoField.uint64("eml_naipayload_vc_chnl_ctrl_req.CSBKParameters", "CSBK Parameters", base.HEX)

	local f_currentVersion = ProtoField.uint8("eml_naipayload_vc_chnl_ctrl_req.currentersion", "Current / Accepted Version", base.HEX)

	local f_oldestVersion = ProtoField.uint8("eml_naipayload_vc_chnl_ctrl_req.oldestVersion", "Oldest Version", base.HEX)
	
	local f_authenticationID = ProtoField.uint32("eml_naipayload_vc_chnl_ctrl_req.AuthenticationID", "Authentication ID", base.HEX)
	
	local f_authenticationSignation = ProtoField.new("AuthenticationSignation", "eml_naipayload_vc_chnl_ctrl_req.AuthenticationSignation", ftypes.BYTES)

	p_self.fields = {
					f_slotNumber,
					f_callID,
					f_callType,
					f_sourceID,
					f_targetID,
					f_accessCriteria,
					f_callAttr,
					f_reserved1,
					f_preambleDuration,
					f_reserved2,
					f_CSBKParameters,
					f_currentVersion,
					f_oldestVersion,
					f_authenticationID,
					f_authenticationSignation
					}
		
	function p_self.dissector(buf, pkt, root)
		
		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_slotNumber, buf(pos, 1))
		pos = pos + 1
		
		t:add(f_callID, buf(pos, 4))
		pos = pos + 4

		t:add(f_callType, buf(pos, 1))
		pos = pos + 1
		
		t:add(f_sourceID, buf(pos, 4))
		pos = pos + 4
		
		t:add(f_targetID, buf(pos, 4))
		pos = pos + 4

		t:add(f_accessCriteria, buf(pos, 1))
		pos = pos + 1

		t:add(f_callAttr, buf(pos, 1))
		pos = pos + 1

		t:add(f_reserved1, buf(pos, 1))
		pos = pos + 1

		t:add(f_preambleDuration, buf(pos, 1))
		pos = pos + 1

		t:add(f_reserved2, buf(pos, 2))
		pos = pos + 2

		t:add(f_CSBKParameters, buf(pos, 8))
		pos = pos + 8
		
		t:add(f_currentVersion, buf(pos, 1))
		pos = pos + 1
		t:add(f_oldestVersion, buf(pos, 1))
		pos = pos + 1

		t:add(f_authenticationID, buf(pos, 4))
		pos = pos + 4
		t:add(f_authenticationSignation, buf(pos, 10))
		pos = pos + 10
		
		--g_info = g_info .. string.format("WLOpcode:0x%X", g_WLOpcode)	
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("eml_naipayload_vc_chnl_ctrl_req")
end



----------------------------------------------------------------------------------
-- Date: 2015-03-05
-- Author: Liao Ying-RQT768
-- Description: WL_VC_CHNL_CTRL_STATUS  0x16
----------------------------------------------------------------------------------
do

	gt_ReasonCode = {
		[0x00] = "Race Condition Failure",
		[0x01] = "Destination Slot Busy Failure",
		[0x02] = "Group Destination Busy Failure",
		[0x03] = "All Channels Busy Failure (Rest Channel Busy)",
		[0x04] = "OTA Repeat Disabled Failure",
		[0x05] = "Signal Interference Failure",
		[0x06] = "CWID In Progress Failure",
		[0x07] = "TOT Expiry Premature Call End Failure1",
		[0x08] = "Transmit Interrupted Call Failure ",
		[0x09] = "Higher Priority Call Takeover ",
		[0x0A] = "Higher Priority Call Takeover Failure",
		[0x0B] = "Local Group Call not allowed",
		[0x0C] = "Non-Rest Channel Repeater",
		[0x0D] = "Destination Site/Sites Busy Failure",
		[0x0E] = "All Call is On-going",
		[0x0F] = "The repeater ended the call – due to under-run",
		[0x10] = "Undefined Call Failure (no unique opcode is defined for this failure)",
	}

	local p_self = Proto("eml_naipayload_vc_chnl_ctrl_status", "WL_VC_CHNL_CTRL_STATUS")		-- The name can't contains Upper Case Letter

	local f_slotNumber = ProtoField.uint8("eml_naipayload_vc_chnl_ctrl_status.slotNumber", "Slot Number", base.HEX)
	
	local f_callID = ProtoField.uint32("eml_naipayload_vc_chnl_ctrl_status.CallID", "Call ID", base.HEX)
	
	local f_callType = ProtoField.uint8("eml_naipayload_vc_chnl_ctrl_status.callType", "Call Type", base.HEX)
	
	local f_chnlCtrlstatusType = ProtoField.uint8("eml_naipayload_vc_chnl_ctrl_status.chnlCtrlstatusType", "chnlCtrlstatusType", base.HEX)
	
	local f_reasonCode = ProtoField.uint8("eml_naipayload_vc_chnl_ctrl_status.ReasonCode", "Reason Code", base.HEX, gt_ReasonCode)
	
	local f_currentVersion = ProtoField.uint8("eml_naipayload_vc_chnl_ctrl_status.currentersion", "Current / Accepted Version", base.HEX)

	local f_oldestVersion = ProtoField.uint8("eml_naipayload_vc_chnl_ctrl_status.oldestVersion", "Oldest Version", base.HEX)
	
	--local f_authenticationID = ProtoField.uint32("eml_naipayload_vc_chnl_ctrl_status.AuthenticationID", "Authentication ID", base.HEX)
	
	--local f_authenticationSignation = ProtoField.new("AuthenticationSignation", "eml_naipayload_vc_chnl_ctrl_status.AuthenticationSignation", ftypes.BYTES)

	p_self.fields = {
					f_slotNumber,
					f_callID,
					f_callType,
					f_chnlCtrlstatusType,
					f_reasonCode,
					f_currentVersion,
					f_oldestVersion,
					--f_authenticationID,
					--f_authenticationSignation
					}
		
	function p_self.dissector(buf, pkt, root)
		
		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_slotNumber, buf(pos, 1))
		pos = pos + 1
		
		t:add(f_callID, buf(pos, 4))
		pos = pos + 4

		t:add(f_callType, buf(pos, 1))
		pos = pos + 1
		
		t:add(f_chnlCtrlstatusType, buf(pos, 1))
		pos = pos + 1

		t:add(f_reasonCode, buf(pos, 1))
		pos = pos + 1

		t:add(f_currentVersion, buf(pos, 1))
		pos = pos + 1
		t:add(f_oldestVersion, buf(pos, 1))
		pos = pos + 1

		--t:add(f_authenticationID, buf(pos, 4))
		--pos = pos + 4
		--t:add(f_authenticationSignation, buf(pos, 10))
		--pos = pos + 10
		
		--g_info = g_info .. string.format("WLOpcode:0x%X", g_WLOpcode)	
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("eml_naipayload_vc_chnl_ctrl_status")
end



----------------------------------------------------------------------------------
-- Date: 2015-03-06
-- Author: Liao Ying-RQT768
-- Description: WL_VC_CSBK_CALL  0x17
----------------------------------------------------------------------------------
do

	local p_self = Proto("eml_naipayload_vc_csbk_call", "WL_VC_CSBK_CALL")		-- The name can't contains Upper Case Letter

	local f_slotNumber = ProtoField.uint8("eml_naipayload_vc_csbk_call.slotNumber", "Slot Number", base.HEX)
	
	local f_callID = ProtoField.uint32("eml_naipayload_vc_csbk_call.CallID", "Call ID", base.HEX)
	
	local f_callType = ProtoField.uint8("eml_naipayload_vc_csbk_call.callType", "Call Type", base.HEX)

	local f_sourceID = ProtoField.uint32("eml_naipayload_vc_csbk_call.SourceID", "Source ID", base.HEX)
	
	local f_targetID = ProtoField.uint32("eml_naipayload_vc_csbk_call.TargetID", "Target ID", base.HEX)
	
	local f_reserved2 = ProtoField.uint16("eml_naipayload_vc_csbk_call.Reserved", "Reserved", base.HEX)

	local f_MFID = ProtoField.uint8("eml_naipayload_vc_csbk_call.MFID", "MFID", base.HEX)

	local f_CSBKParameters = ProtoField.uint64("eml_naipayload_vc_csbk_call.CSBKParameters", "CSBK Parameters", base.HEX)

	local f_rawRSSIvalue = ProtoField.uint16("eml_naipayload_vc_csbk_call.rawRSSIvalue", "rawRSSIvalue", base.HEX)
	
	local f_currentVersion = ProtoField.uint8("eml_naipayload_vc_csbk_call.currentersion", "Current / Accepted Version", base.HEX)

	local f_oldestVersion = ProtoField.uint8("eml_naipayload_vc_csbk_call.oldestVersion", "Oldest Version", base.HEX)
	
	--local f_authenticationID = ProtoField.uint32("eml_naipayload_vc_csbk_call.AuthenticationID", "Authentication ID", base.HEX)
	
	--local f_authenticationSignation = ProtoField.new("AuthenticationSignation", "eml_naipayload_vc_csbk_call.AuthenticationSignation", ftypes.BYTES)

	p_self.fields = {
					f_slotNumber,
					f_callID,
					f_callType,
					f_sourceID,
					f_targetID,
					f_reserved2,
					f_MFID,
					f_CSBKParameters,
					f_rawRSSIvalue,
					f_currentVersion,
					f_oldestVersion,
					--f_authenticationID,
					--f_authenticationSignation
					}
		
	function p_self.dissector(buf, pkt, root)
		
		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_slotNumber, buf(pos, 1))
		pos = pos + 1
		
		t:add(f_callID, buf(pos, 4))
		pos = pos + 4

		t:add(f_callType, buf(pos, 1))
		pos = pos + 1
		
		t:add(f_sourceID, buf(pos, 4))
		pos = pos + 4

		t:add(f_targetID, buf(pos, 4))
		pos = pos + 4

		t:add(f_reserved2, buf(pos, 2))
		pos = pos + 2

		t:add(f_MFID, buf(pos, 1))
		pos = pos + 1

		t:add(f_CSBKParameters, buf(pos, 8))
		pos = pos + 8

		t:add(f_rawRSSIvalue, buf(pos, 2))
		pos = pos + 2

		t:add(f_currentVersion, buf(pos, 1))
		pos = pos + 1
		t:add(f_oldestVersion, buf(pos, 1))
		pos = pos + 1

		--t:add(f_authenticationID, buf(pos, 4))
		--pos = pos + 4
		--t:add(f_authenticationSignation, buf(pos, 10))
		--pos = pos + 10
		
		--g_info = g_info .. string.format("WLOpcode:0x%X", g_WLOpcode)	
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("eml_naipayload_vc_csbk_call")
end


----------------------------------------------------------------------------------
-- Date: 2015-03-06
-- Author: Liao Ying-RQT768
-- Description: WL_VC_VOICE_START  0x18
----------------------------------------------------------------------------------
do

	local p_self = Proto("eml_naipayload_vc_voice_start", "WL_VC_VOICE_START")		-- The name can't contains Upper Case Letter

	local f_slotNumber = ProtoField.uint8("eml_naipayload_vc_voice_start.slotNumber", "Slot Number", base.HEX)
	
	local f_callID = ProtoField.uint32("eml_naipayload_vc_voice_start.CallID", "Call ID", base.HEX)
	
	local f_callType = ProtoField.uint8("eml_naipayload_vc_voice_start.callType", "Call Type", base.HEX)

	local f_sourceID = ProtoField.uint32("eml_naipayload_vc_voice_start.SourceID", "Source ID", base.HEX)
	
	local f_targetID = ProtoField.uint32("eml_naipayload_vc_voice_start.TargetID", "Target ID", base.HEX)
	
	local f_callAttr = ProtoField.uint8("eml_naipayload_vc_voice_start.CallAttr", "Call Attributes", base.HEX)

	local f_reserved1 = ProtoField.uint8("eml_naipayload_vc_voice_start.Reserved", "Reserved", base.HEX)

	local f_MFID = ProtoField.uint8("eml_naipayload_vc_voice_start.MFID", "MFID", base.HEX)

	local f_serviceOption = ProtoField.uint8("eml_naipayload_vc_voice_start.serviceOption", "Service Option", base.HEX)

	local f_currentVersion = ProtoField.uint8("eml_naipayload_vc_voice_start.currentersion", "Current / Accepted Version", base.HEX)

	local f_oldestVersion = ProtoField.uint8("eml_naipayload_vc_voice_start.oldestVersion", "Oldest Version", base.HEX)
	
	--local f_authenticationID = ProtoField.uint32("eml_naipayload_vc_voice_start.AuthenticationID", "Authentication ID", base.HEX)
	
	--local f_authenticationSignation = ProtoField.new("AuthenticationSignation", "eml_naipayload_vc_voice_start.AuthenticationSignation", ftypes.BYTES)

	p_self.fields = {
					f_slotNumber,
					f_callID,
					f_callType,
					f_sourceID,
					f_targetID,
					f_callAttr,
					f_reserved1,
					f_MFID,
					f_serviceOption,
					f_currentVersion,
					f_oldestVersion,
					--f_authenticationID,
					--f_authenticationSignation
					}
		
	function p_self.dissector(buf, pkt, root)
		
		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_slotNumber, buf(pos, 1))
		pos = pos + 1
		
		t:add(f_callID, buf(pos, 4))
		pos = pos + 4

		t:add(f_callType, buf(pos, 1))
		pos = pos + 1
		
		t:add(f_sourceID, buf(pos, 4))
		pos = pos + 4

		t:add(f_targetID, buf(pos, 4))
		pos = pos + 4

		t:add(f_callAttr, buf(pos, 1))
		pos = pos + 1

		t:add(f_reserved1, buf(pos, 1))
		pos = pos + 1

		t:add(f_MFID, buf(pos, 1))
		pos = pos + 1

		t:add(f_serviceOption, buf(pos, 1))
		pos = pos + 1

		t:add(f_currentVersion, buf(pos, 1))
		pos = pos + 1
		t:add(f_oldestVersion, buf(pos, 1))
		pos = pos + 1

		--t:add(f_authenticationID, buf(pos, 4))
		--pos = pos + 4
		--t:add(f_authenticationSignation, buf(pos, 10))
		--pos = pos + 10
		
		--g_info = g_info .. string.format("WLOpcode:0x%X", g_WLOpcode)	
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("eml_naipayload_vc_voice_start")
end


----------------------------------------------------------------------------------
-- Date: 2015-03-06
-- Author: Liao Ying-RQT768
-- Description: WL_VC_VOICE_END_BURST  0x19
----------------------------------------------------------------------------------
do

	local p_self = Proto("eml_naipayload_vc_voice_end", "WL_VC_VOICE_END_BURST")		-- The name can't contains Upper Case Letter

	local f_slotNumber = ProtoField.uint8("eml_naipayload_vc_voice_end.slotNumber", "Slot Number", base.HEX)
	
	local f_callID = ProtoField.uint32("eml_naipayload_vc_voice_end.CallID", "Call ID", base.HEX)
	
	local f_callType = ProtoField.uint8("eml_naipayload_vc_voice_end.callType", "Call Type", base.HEX)

	local f_sourceID = ProtoField.uint32("eml_naipayload_vc_voice_end.SourceID", "Source ID", base.HEX)
	
	local f_targetID = ProtoField.uint32("eml_naipayload_vc_voice_end.TargetID", "Target ID", base.HEX)
	
	local f_RTPInformation = ProtoField.new("RTPInformation", "eml_naipayload_vc_voice_end.RTPInformation", ftypes.BYTES)

	local f_burstType = ProtoField.uint8("eml_naipayload_vc_voice_end.BurstType", "Burst Type", base.HEX)

	local f_reserved1 = ProtoField.uint8("eml_naipayload_vc_voice_end.Reserved", "Reserved", base.HEX)

	local f_MFID = ProtoField.uint8("eml_naipayload_vc_voice_end.MFID", "MFID", base.HEX)

	local f_serviceOption = ProtoField.uint8("eml_naipayload_vc_voice_end.serviceOption", "Service Option", base.HEX)

	local f_currentVersion = ProtoField.uint8("eml_naipayload_vc_voice_end.currentersion", "Current / Accepted Version", base.HEX)

	local f_oldestVersion = ProtoField.uint8("eml_naipayload_vc_voice_end.oldestVersion", "Oldest Version", base.HEX)
	
	local f_authenticationID = ProtoField.uint32("eml_naipayload_vc_voice_end.AuthenticationID", "Authentication ID", base.HEX)
	
	local f_authenticationSignation = ProtoField.new("AuthenticationSignation", "eml_naipayload_vc_voice_end.AuthenticationSignation", ftypes.BYTES)

	p_self.fields = {
					f_slotNumber,
					f_callID,
					f_callType,
					f_sourceID,
					f_targetID,
					f_RTPInformation,
					f_burstType,
					f_reserved1,
					f_MFID,
					f_serviceOption,
					f_currentVersion,
					f_oldestVersion,
					f_authenticationID,
					f_authenticationSignation
					}
		
	function p_self.dissector(buf, pkt, root)
		
		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_slotNumber, buf(pos, 1))
		pos = pos + 1
		
		t:add(f_callID, buf(pos, 4))
		pos = pos + 4

		t:add(f_callType, buf(pos, 1))
		pos = pos + 1
		
		t:add(f_sourceID, buf(pos, 4))
		pos = pos + 4

		t:add(f_targetID, buf(pos, 4))
		pos = pos + 4

		t:add(f_RTPInformation, buf(pos, 12))
		pos = pos + 12

		t:add(f_burstType, buf(pos, 1))
		pos = pos + 1

		t:add(f_reserved1, buf(pos, 1))
		pos = pos + 1

		t:add(f_MFID, buf(pos, 1))
		pos = pos + 1

		t:add(f_serviceOption, buf(pos, 1))
		pos = pos + 1

		t:add(f_currentVersion, buf(pos, 1))
		pos = pos + 1
		t:add(f_oldestVersion, buf(pos, 1))
		pos = pos + 1

		t:add(f_authenticationID, buf(pos, 4))
		pos = pos + 4
		t:add(f_authenticationSignation, buf(pos, 10))
		pos = pos + 10
		
		--g_info = g_info .. string.format("WLOpcode:0x%X", g_WLOpcode)	
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("eml_naipayload_vc_voice_end")
end


----------------------------------------------------------------------------------
-- Date: 2015-03-06
-- Author: Liao Ying-RQT768
-- Description: WL_VC_PRIVACY_BURST  0x22
----------------------------------------------------------------------------------
do

	local p_self = Proto("eml_naipayload_vc_voice_privacy", "WL_VC_PRIVACY_BURST")		-- The name can't contains Upper Case Letter

	local f_slotNumber = ProtoField.uint8("eml_naipayload_vc_voice_privacy.slotNumber", "Slot Number", base.HEX)
	
	local f_callID = ProtoField.uint32("eml_naipayload_vc_voice_privacy.CallID", "Call ID", base.HEX)
	
	local f_callType = ProtoField.uint8("eml_naipayload_vc_voice_privacy.callType", "Call Type", base.HEX)

	local f_sourceID = ProtoField.uint32("eml_naipayload_vc_voice_privacy.SourceID", "Source ID", base.HEX)
	
	local f_targetID = ProtoField.uint32("eml_naipayload_vc_voice_privacy.TargetID", "Target ID", base.HEX)
	
	local f_RTPInformation = ProtoField.new("RTPInformation", "eml_naipayload_vc_voice_privacy.RTPInformation", ftypes.BYTES)

	local f_burstType = ProtoField.uint8("eml_naipayload_vc_voice_privacy.BurstType", "Burst Type", base.HEX)

	local f_reserved1 = ProtoField.uint8("eml_naipayload_vc_voice_privacy.Reserved", "Reserved", base.HEX)

	local f_MFID = ProtoField.uint8("eml_naipayload_vc_voice_privacy.MFID", "MFID", base.HEX)

	local f_algorithmID = ProtoField.uint8("eml_naipayload_vc_voice_privacy.algorithmID", "algorithmID", base.HEX)

	local f_KeyID = ProtoField.uint8("eml_naipayload_vc_voice_privacy.ID", "KeyID", base.HEX)

	local f_IV = ProtoField.uint32("eml_naipayload_vc_voice_privacy.IV", "IV", base.HEX)

	local f_currentVersion = ProtoField.uint8("eml_naipayload_vc_voice_privacy.currentersion", "Current / Accepted Version", base.HEX)

	local f_oldestVersion = ProtoField.uint8("eml_naipayload_vc_voice_privacy.oldestVersion", "Oldest Version", base.HEX)
	
	local f_authenticationID = ProtoField.uint32("eml_naipayload_vc_voice_privacy.AuthenticationID", "Authentication ID", base.HEX)
	
	local f_authenticationSignation = ProtoField.new("AuthenticationSignation", "eml_naipayload_vc_voice_privacy.AuthenticationSignation", ftypes.BYTES)

	p_self.fields = {
					f_slotNumber,
					f_callID,
					f_callType,
					f_sourceID,
					f_targetID,
					f_RTPInformation,
					f_burstType,
					f_reserved1,
					f_MFID,
					f_algorithmID,
					f_KeyID,
					f_IV,
					f_currentVersion,
					f_oldestVersion,
					f_authenticationID,
					f_authenticationSignation
					}
		
	function p_self.dissector(buf, pkt, root)
		
		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_slotNumber, buf(pos, 1))
		pos = pos + 1
		
		t:add(f_callID, buf(pos, 4))
		pos = pos + 4

		t:add(f_callType, buf(pos, 1))
		pos = pos + 1
		
		t:add(f_sourceID, buf(pos, 4))
		pos = pos + 4

		t:add(f_targetID, buf(pos, 4))
		pos = pos + 4

		t:add(f_RTPInformation, buf(pos, 12))
		pos = pos + 12

		t:add(f_burstType, buf(pos, 1))
		pos = pos + 1

		t:add(f_reserved1, buf(pos, 1))
		pos = pos + 1

		t:add(f_MFID, buf(pos, 1))
		pos = pos + 1

		t:add(f_algorithmID, buf(pos, 1))
		pos = pos + 1

		t:add(f_KeyID, buf(pos, 1))
		pos = pos + 1

		t:add(f_IV, buf(pos, 4))
		pos = pos + 4

		t:add(f_currentVersion, buf(pos, 1))
		pos = pos + 1
		t:add(f_oldestVersion, buf(pos, 1))
		pos = pos + 1

		t:add(f_authenticationID, buf(pos, 4))
		pos = pos + 4
		t:add(f_authenticationSignation, buf(pos, 10))
		pos = pos + 10
		
		--g_info = g_info .. string.format("WLOpcode:0x%X", g_WLOpcode)	
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("eml_naipayload_vc_voice_privacy")
end


----------------------------------------------------------------------------------
-- Date: 2015-03-06
-- Author: Liao Ying-RQT768
-- Description: WL_VC_CALL_SESSION_STATUS  0x20
----------------------------------------------------------------------------------
do

	local p_self = Proto("eml_naipayload_vc_call_session_status", "WL_VC_CALL_SESSION_STATUS")		-- The name can't contains Upper Case Letter

	local f_slotNumber = ProtoField.uint8("eml_naipayload_vc_call_session_status.slotNumber", "Slot Number", base.HEX)
	
	local f_callID = ProtoField.uint32("eml_naipayload_vc_call_session_status.CallID", "Call ID", base.HEX)
	
	local f_callType = ProtoField.uint8("eml_naipayload_vc_call_session_status.callType", "Call Type", base.HEX)

	local f_sourceID = ProtoField.uint32("eml_naipayload_vc_call_session_status.SourceID", "Source ID", base.HEX)
	
	local f_targetID = ProtoField.uint32("eml_naipayload_vc_call_session_status.TargetID", "Target ID", base.HEX)
	
	local f_reserved4 = ProtoField.uint32("eml_naipayload_vc_call_session_status.Reserved", "Reserved", base.HEX)
	
	local f_callSessionStatus = ProtoField.uint8("eml_naipayload_vc_call_session_status.callSessionStatus", "callSessionStatus", base.HEX)

	local f_currentVersion = ProtoField.uint8("eml_naipayload_vc_call_session_status.currentersion", "Current / Accepted Version", base.HEX)

	local f_oldestVersion = ProtoField.uint8("eml_naipayload_vc_call_session_status.oldestVersion", "Oldest Version", base.HEX)
	
	--local f_authenticationID = ProtoField.uint32("eml_naipayload_vc_call_session_status.AuthenticationID", "Authentication ID", base.HEX)
	
	--local f_authenticationSignation = ProtoField.new("AuthenticationSignation", "eml_naipayload_vc_call_session_status.AuthenticationSignation", ftypes.BYTES)

	p_self.fields = {
					f_slotNumber,
					f_callID,
					f_callType,
					f_sourceID,
					f_targetID,
					f_reserved4,
					f_callSessionStatus,
					f_currentVersion,
					f_oldestVersion,
					--f_authenticationID,
					--f_authenticationSignation
					}
		
	function p_self.dissector(buf, pkt, root)
		
		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_slotNumber, buf(pos, 1))
		pos = pos + 1
		
		t:add(f_callID, buf(pos, 4))
		pos = pos + 4

		t:add(f_callType, buf(pos, 1))
		pos = pos + 1
		
		t:add(f_sourceID, buf(pos, 4))
		pos = pos + 4

		t:add(f_targetID, buf(pos, 4))
		pos = pos + 4

		t:add(f_reserved4, buf(pos, 4))
		pos = pos + 4

		t:add(f_callSessionStatus, buf(pos, 1))
		pos = pos + 1

		t:add(f_currentVersion, buf(pos, 1))
		pos = pos + 1
		t:add(f_oldestVersion, buf(pos, 1))
		pos = pos + 1

		--t:add(f_authenticationID, buf(pos, 4))
		--pos = pos + 4
		--t:add(f_authenticationSignation, buf(pos, 10))
		--pos = pos + 10
		
		--g_info = g_info .. string.format("WLOpcode:0x%X", g_WLOpcode)	
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("eml_naipayload_vc_call_session_status")
end


----------------------------------------------------------------------------------
-- Date: 2015-03-06
-- Author: Liao Ying-RQT768
-- Description: WL_VC_VOICE_BURST  0x21
----------------------------------------------------------------------------------
do

	local p_self = Proto("eml_naipayload_vc_voice_call", "WL_VC_VOICE_BURST")		-- The name can't contains Upper Case Letter

	local f_slotNumber = ProtoField.uint8("eml_naipayload_vc_voice_call.slotNumber", "Slot Number", base.HEX)
	
	local f_callID = ProtoField.uint32("eml_naipayload_vc_voice_call.CallID", "Call ID", base.HEX)
	
	local f_callType = ProtoField.uint8("eml_naipayload_vc_voice_call.callType", "Call Type", base.HEX)

	local f_sourceID = ProtoField.uint32("eml_naipayload_vc_voice_call.SourceID", "Source ID", base.HEX)
	
	local f_targetID = ProtoField.uint32("eml_naipayload_vc_voice_call.TargetID", "Target ID", base.HEX)
	
	local f_callAttr = ProtoField.uint8("eml_naipayload_vc_voice_call.CallAttr", "Call Attributes", base.HEX)

	local f_reserved1 = ProtoField.uint8("eml_naipayload_vc_voice_call.Reserved", "Reserved", base.HEX)

	local f_RTPInformation = ProtoField.new("RTPInformation", "eml_naipayload_vc_voice_call.RTPInformation", ftypes.BYTES)

	local f_burstType = ProtoField.uint8("eml_naipayload_vc_voice_call.BurstType", "Burst Type", base.HEX)

	-- local f_reserved1 = ProtoField.uint8("eml_naipayload_vc_voice_call.Reserved", "Reserved", base.HEX)

	local f_MFID = ProtoField.uint8("eml_naipayload_vc_voice_call.MFID", "MFID", base.HEX)

	local f_serviceOption = ProtoField.uint8("eml_naipayload_vc_voice_call.serviceOption", "Service Option", base.HEX)

	local f_algorithmID = ProtoField.uint8("eml_naipayload_vc_voice_call.algorithmID", "algorithmID", base.HEX)

	local f_KeyID = ProtoField.uint8("eml_naipayload_vc_voice_call.KeyID", "KeyID", base.HEX)

	local f_IV = ProtoField.uint32("eml_naipayload_vc_voice_call.IV", "IV", base.HEX)

	local f_AmbeFrame = ProtoField.new("AmbeFrame", "eml_naipayload_vc_voice_call.AmbeFrame", ftypes.BYTES)

	local f_rawRSSIvalue = ProtoField.uint16("eml_naipayload_vc_voice_call.rawRSSIvalue", "rawRSSIvalue", base.HEX)

	local f_currentVersion = ProtoField.uint8("eml_naipayload_vc_voice_call.currentersion", "Current / Accepted Version", base.HEX)

	local f_oldestVersion = ProtoField.uint8("eml_naipayload_vc_voice_call.oldestVersion", "Oldest Version", base.HEX)
	
	local f_authenticationID = ProtoField.uint32("eml_naipayload_vc_voice_call.AuthenticationID", "Authentication ID", base.HEX)
	
	local f_authenticationSignation = ProtoField.new("AuthenticationSignation", "eml_naipayload_vc_voice_call.AuthenticationSignation", ftypes.BYTES)

	p_self.fields = {
					f_slotNumber,
					f_callID,
					f_callType,
					f_sourceID,
					f_targetID,
					f_reserved1,
					f_callAttr,
					f_RTPInformation,
					f_burstType,
					f_MFID,
					f_serviceOption,
					f_algorithmID,
					f_KeyID,
					f_IV,
					f_AmbeFrame,
					f_rawRSSIvalue,
					f_currentVersion,
					f_oldestVersion,
					f_authenticationID,
					f_authenticationSignation
					}
		
	function p_self.dissector(buf, pkt, root)
		
		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_slotNumber, buf(pos, 1))
		pos = pos + 1
		
		t:add(f_callID, buf(pos, 4))
		pos = pos + 4

		t:add(f_callType, buf(pos, 1))
		pos = pos + 1
		
		t:add(f_sourceID, buf(pos, 4))
		pos = pos + 4

		t:add(f_targetID, buf(pos, 4))
		pos = pos + 4

		t:add(f_callAttr, buf(pos, 1))
		pos = pos + 1

		t:add(f_reserved1, buf(pos, 1))
		pos = pos + 1

		t:add(f_RTPInformation, buf(pos, 12))
		pos = pos + 12

		t:add(f_burstType, buf(pos, 1))
		pos = pos + 1

		t:add(f_reserved1, buf(pos, 1))
		pos = pos + 1

		t:add(f_MFID, buf(pos, 1))
		pos = pos + 1

		t:add(f_serviceOption, buf(pos, 1))
		pos = pos + 1

		t:add(f_algorithmID, buf(pos, 1))
		pos = pos + 1

		t:add(f_KeyID, buf(pos, 1))
		pos = pos + 1

		t:add(f_IV, buf(pos, 4))
		pos = pos + 4

		t:add(f_AmbeFrame, buf(pos, 20))
		pos = pos + 20

		t:add(f_rawRSSIvalue, buf(pos, 2))
		pos = pos + 2

		t:add(f_currentVersion, buf(pos, 1))
		pos = pos + 1
		t:add(f_oldestVersion, buf(pos, 1))
		pos = pos + 1

		t:add(f_authenticationID, buf(pos, 4))
		pos = pos + 4
		t:add(f_authenticationSignation, buf(pos, 10))
		pos = pos + 10
		
		--g_info = g_info .. string.format("WLOpcode:0x%X", g_WLOpcode)	
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("eml_naipayload_vc_voice_call")
end


----------------------------------------------------------------------------------
-- Date: 2016-05-29
-- Author: Liao Ying-RQT768
-- Description: WL_Data_Call_Request  0x30 (Emerald:WL_DATA_PDU_TX)
----------------------------------------------------------------------------------
do

	local p_self = Proto("eml_naipayload_datacallrequest", "WL_Data_Call_Request")		-- The name can't contains Upper Case Letter

	local f_LCN= ProtoField.uint8("eml_naipayload_datacallrequest.LCN", "LCN", base.HEX)
	
	local f_dataPduID = ProtoField.uint32("eml_naipayload_datacallrequest.dataPduID", "data PDU ID", base.HEX)
	
	local f_callType = ProtoField.uint8("eml_naipayload_datacallrequest.callType", "Call Type", base.HEX)

	local f_sourceID = ProtoField.uint32("eml_naipayload_datacallrequest.SourceID", "Source ID", base.HEX)
	
	local f_targetID = ProtoField.uint32("eml_naipayload_datacallrequest.TargetID", "Target ID", base.HEX)
	
	local f_CSN = ProtoField.uint32("eml_naipayload_datacallrequest.CSN", "CSN", base.HEX)

	local f_origRoleInfo = ProtoField.uint8("eml_naipayload_datacallrequest.origRoleInfo", "origRoleInfo", base.HEX)

	local f_reserved = ProtoField.new("Reserved", "eml_naipayload_datacallrequest.reserved", ftypes.BYTES)	-- 3 bytes
	
	local f_preambleDuration = ProtoField.uint8("eml_naipayload_datacallrequest.preambleDuration", "Preamble Duration", base.HEX)

	local f_dataHeaderParameters = ProtoField.uint8("eml_naipayload_datacallrequest.trunkedChParams", "Trunked Channel Parameters", base.HEX)

	local f_ipHdrCompressionandPrivacy = ProtoField.uint8("eml_naipayload_datacallrequest.ipHdrCP", "ipHdrCompressionandPrivacy", base.HEX)

	local f_algorithmID = ProtoField.uint8("eml_naipayload_datacallrequest.algorithmID", "algorithmID", base.HEX)

	local f_privacyKeyID = ProtoField.uint8("eml_naipayload_datacallrequest.privacyKeyID", "privacyKeyID", base.HEX)

	local f_privacyIV = ProtoField.uint32("eml_naipayload_datacallrequest.privacyIV", "privacyIV", base.HEX)

	local f_pduPayloadLength = ProtoField.uint16("eml_naipayload_datacallrequest.pduPayloadLength", "pduPayloadLength", base.HEX)

	local f_pduPayload = ProtoField.new("pduPayload", "eml_naipayload_datacallreceive.pduPayload", ftypes.BYTES)

	local f_wlProtocolVersion = ProtoField.uint8("eml_naipayload_datacallrequest.wlProtocolVersion", "wlProtocolVersion", base.HEX)

	local f_oldestWlProtocolVersion = ProtoField.uint8("eml_naipayload_datacallrequest.oldestWlProtocolVersion", "oldestWlProtocolVersion", base.HEX)

	local f_wlAuthID = ProtoField.uint32("eml_naipayload_datacallrequest.wlAuthID", "wlAuthID", base.HEX)

	local f_wlAuthSignation = ProtoField.new("wlAuthSignation", "eml_naipayload_datacallrequest.wlAuthSignation", ftypes.BYTES)	-- 10 bytes

	p_self.fields = {
					f_LCN,
					f_dataPduID,
					f_callType,
					f_sourceID,
					f_targetID,
					f_CSN,
					f_origRoleInfo,
					f_reserved,
					f_preambleDuration,
					f_dataHeaderParameters,
					f_ipHdrCompressionandPrivacy,
					f_algorithmID,
					f_privacyKeyID,
					f_privacyIV,
					f_pduPayloadLength,
					f_pduPayload,
					f_wlProtocolVersion,
					f_oldestWlProtocolVersion,
					f_wlAuthID,
					f_wlAuthSignation
					}
		
	function p_self.dissector(buf, pkt, root)
		
		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_LCN, buf(pos, 1))
		pos = pos + 1
		
		t:add(f_dataPduID, buf(pos, 4))
		pos = pos + 4

		t:add(f_callType, buf(pos, 1))
		pos = pos + 1
		
		t:add(f_sourceID, buf(pos, 4))
		pos = pos + 4

		t:add(f_targetID, buf(pos, 4))
		pos = pos + 4

		t:add(f_CSN, buf(pos, 4))
		pos = pos + 4

		t:add(f_origRoleInfo, buf(pos, 1))
		pos = pos + 1

		t:add(f_reserved, buf(pos, 3))
		pos = pos + 3
		
		t:add(f_preambleDuration, buf(pos, 1))
		pos = pos + 1

		t:add(f_dataHeaderParameters, buf(pos, 1))
		pos = pos + 1

		t:add(f_ipHdrCompressionandPrivacy, buf(pos, 1))
		pos = pos + 1

		t:add(f_algorithmID, buf(pos, 1))
		pos = pos + 1

		t:add(f_privacyKeyID, buf(pos, 1))
		pos = pos + 1

		t:add(f_privacyIV, buf(pos, 4))
		pos = pos + 4

		local pduPayloadLength = buf(pos, 2):uint()
		t:add(f_pduPayloadLength, buf(pos, 2))
		pos = pos + 2
		
		if (pduPayloadLength > 0 and pos + pduPayloadLength <= buf:len()) then
			t:add(f_pduPayload, buf(pos, pduPayloadLength))
			pos = pos + pduPayloadLength
		end

		t:add(f_wlProtocolVersion, buf(pos, 1))
		pos = pos + 1

		t:add(f_oldestWlProtocolVersion, buf(pos, 1))
		pos = pos + 1

		t:add(f_wlAuthID, buf(pos, 4))
		pos = pos + 4

		t:add(f_wlAuthSignation, buf(pos, 10))
		pos = pos + 10
		
		--g_info = g_info .. string.format("WLOpcode:0x%X", g_WLOpcode)	
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("eml_naipayload_datacallrequest")
end


----------------------------------------------------------------------------------
-- Date: 2016-05-29
-- Author: Liao Ying-RQT768
-- Description: WL_Data_Call_Status  0x31	(WL_PDU_TX_STATUS)
----------------------------------------------------------------------------------
do

	local p_self = Proto("eml_naipayload_datacallstatus", "WL_Data_Call_Status")		-- The name can't contains Upper Case Letter

	local f_LCN= ProtoField.uint8("eml_naipayload_datacallstatus.LCN", "LCN", base.HEX)
	
	local f_dataPduID = ProtoField.uint32("eml_naipayload_datacallstatus.dataPduID", "data PDU ID", base.HEX)
	
	local f_callType = ProtoField.uint8("eml_naipayload_datacallstatus.callType", "Call Type", base.HEX)

	local f_sourceID = ProtoField.uint32("eml_naipayload_datacallstatus.SourceID", "Source ID", base.HEX)
	
	local f_targetID = ProtoField.uint32("eml_naipayload_datacallstatus.TargetID", "Target ID", base.HEX)
	
	local f_CSN = ProtoField.uint32("eml_naipayload_datacallstatus.CSN", "CSN", base.HEX)

	local f_pduDeliveryStatusType = ProtoField.uint8("eml_naipayload_datacallstatus.pduDeliveryStatusType", "pduDeliveryStatusType", base.HEX)

	local f_pduDeliveryStatusCode = ProtoField.uint8("eml_naipayload_datacallstatus.pduDeliveryStatusCode", "pduDeliveryStatusCode", base.HEX)

	local f_subOpcodes = ProtoField.uint16("eml_naipayload_datacallstatus.subOpcodes", "subOpcodes", base.HEX)

	local f_reserved = ProtoField.uint32("eml_naipayload_datacallstatus.reserved", "reserved", base.HEX)

	local f_wlProtocolVersion = ProtoField.uint8("eml_naipayload_datacallstatus.wlProtocolVersion", "wlProtocolVersion", base.HEX)

	local f_oldestWlProtocolVersion = ProtoField.uint8("eml_naipayload_datacallstatus.oldestWlProtocolVersion", "oldestWlProtocolVersion", base.HEX)

	p_self.fields = {
					f_LCN,
					f_dataPduID,
					f_callType,
					f_sourceID,
					f_targetID,
					f_CSN,
					f_pduDeliveryStatusType,
					f_pduDeliveryStatusCode,
					f_subOpcodes,
					f_reserved,
					f_wlProtocolVersion,
					f_oldestWlProtocolVersion
					}
		
	function p_self.dissector(buf, pkt, root)
		
		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_LCN, buf(pos, 1))
		pos = pos + 1
		
		t:add(f_dataPduID, buf(pos, 4))
		pos = pos + 4

		t:add(f_callType, buf(pos, 1))
		pos = pos + 1
		
		t:add(f_sourceID, buf(pos, 4))
		pos = pos + 4

		t:add(f_targetID, buf(pos, 4))
		pos = pos + 4

		t:add(f_CSN, buf(pos, 4))
		pos = pos + 4

		t:add(f_pduDeliveryStatusType, buf(pos, 1))
		pos = pos + 1

		t:add(f_pduDeliveryStatusCode, buf(pos, 1))
		pos = pos + 1

		t:add(f_subOpcodes, buf(pos, 2))
		pos = pos + 2

		t:add(f_reserved, buf(pos, 4))
		pos = pos + 4
		
		t:add(f_wlProtocolVersion, buf(pos, 1))
		pos = pos + 1

		t:add(f_oldestWlProtocolVersion, buf(pos, 1))
		pos = pos + 1
		
		--g_info = g_info .. string.format("WLOpcode:0x%X", g_WLOpcode)	
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("eml_naipayload_datacallstatus")
end


----------------------------------------------------------------------------------
-- Date: 2016-05-29
-- Author: Liao Ying-RQT768
-- Description: WL_Data_Call_Receive  0x32
----------------------------------------------------------------------------------
do

	local p_self = Proto("eml_naipayload_datacallreceive", "WL_Data_Call_Receive")		-- The name can't contains Upper Case Letter

	local f_LCN= ProtoField.uint8("eml_naipayload_datacallreceive.LCN", "LCN", base.HEX)
	
	local f_dataPduID = ProtoField.uint32("eml_naipayload_datacallreceive.dataPduID", "data PDU ID", base.HEX)
	
	local f_callType = ProtoField.uint8("eml_naipayload_datacallreceive.callType", "Call Type", base.HEX)

	local f_sourceID = ProtoField.uint32("eml_naipayload_datacallreceive.SourceID", "Source ID", base.HEX)
	
	local f_targetID = ProtoField.uint32("eml_naipayload_datacallreceive.TargetID", "Target ID", base.HEX)
	
	local f_CSN = ProtoField.uint32("eml_naipayload_datacallreceive.CSN", "CSN", base.HEX)

	local f_origRoleInfo = ProtoField.uint8("eml_naipayload_datacallreceive.origRoleInfo", "origRoleInfo", base.HEX)

	local f_reserved = ProtoField.new("Reserved", "eml_naipayload_datacallreceive.reserved", ftypes.BYTES)	-- 3 bytes
	
	local f_dataHeaderAttributes = ProtoField.uint8("eml_naipayload_datacallreceive.dataHeaderAttributes", "dataHeaderAttributes", base.HEX)

	local f_ipHdrCompressionandPrivacy = ProtoField.uint8("eml_naipayload_datacallreceive.ipHdrCP", "ipHdrCompressionandPrivacy", base.HEX)

	local f_algorithmID = ProtoField.uint8("eml_naipayload_datacallreceive.algorithmID", "algorithmID", base.HEX)

	local f_privacyKeyID = ProtoField.uint8("eml_naipayload_datacallreceive.privacyKeyID", "privacyKeyID", base.HEX)

	local f_privacyIV = ProtoField.uint32("eml_naipayload_datacallreceive.privacyIV", "privacyIV", base.HEX)

	local f_pduPayloadLength = ProtoField.uint16("eml_naipayload_datacallreceive.pduPayloadLength", "pduPayloadLength", base.HEX)

	local f_pduPayload = ProtoField.new("pduPayload", "eml_naipayload_datacallreceive.pduPayload", ftypes.BYTES)

	local f_pduPacketCRC = ProtoField.uint32("eml_naipayload_datacallreceive.pduPacketCRC", "pduPacketCRC", base.HEX)

	local f_rawRSSIvalue = ProtoField.uint16("eml_naipayload_datacallreceive.rawRSSIvalue", "rawRSSIvalue", base.HEX)

	local f_wlProtocolVersion = ProtoField.uint8("eml_naipayload_datacallreceive.wlProtocolVersion", "wlProtocolVersion", base.HEX)

	local f_oldestWlProtocolVersion = ProtoField.uint8("eml_naipayload_datacallreceive.oldestWlProtocolVersion", "oldestWlProtocolVersion", base.HEX)

	p_self.fields = {
					f_LCN,
					f_dataPduID,
					f_callType,
					f_sourceID,
					f_targetID,
					f_CSN,
					f_origRoleInfo,
					f_reserved,
					f_dataHeaderAttributes,
					f_ipHdrCompressionandPrivacy,
					f_algorithmID,
					f_privacyKeyID,
					f_privacyIV,
					f_pduPayloadLength,
					f_pduPayload,
					f_pduPacketCRC,
					f_rawRSSIvalue,
					f_wlProtocolVersion,
					f_oldestWlProtocolVersion
					}
		
	function p_self.dissector(buf, pkt, root)
		
		local t = root:add(p_self, buf(0))
		local pos = 0

		t:add(f_LCN, buf(pos, 1))
		pos = pos + 1
		
		t:add(f_dataPduID, buf(pos, 4))
		pos = pos + 4

		t:add(f_callType, buf(pos, 1))
		pos = pos + 1
		
		t:add(f_sourceID, buf(pos, 4))
		pos = pos + 4

		t:add(f_targetID, buf(pos, 4))
		pos = pos + 4

		t:add(f_CSN, buf(pos, 4))
		pos = pos + 4

		t:add(f_origRoleInfo, buf(pos, 1))
		pos = pos + 1

		t:add(f_reserved, buf(pos, 3))
		pos = pos + 3
		
		t:add(f_dataHeaderAttributes, buf(pos, 1))
		pos = pos + 1

		t:add(f_ipHdrCompressionandPrivacy, buf(pos, 1))
		pos = pos + 1

		t:add(f_algorithmID, buf(pos, 1))
		pos = pos + 1

		t:add(f_privacyKeyID, buf(pos, 1))
		pos = pos + 1

		t:add(f_privacyIV, buf(pos, 4))
		pos = pos + 4

		local pduPayloadLength = buf(pos, 2):uint()
		t:add(f_pduPayloadLength, buf(pos, 2))
		pos = pos + 2
		
		if (pduPayloadLength > 0 and pos + pduPayloadLength <= buf:len()) then
			t:add(f_pduPayload, buf(pos, pduPayloadLength))
			pos = pos + pduPayloadLength
		end

		t:add(f_pduPacketCRC, buf(pos, 4))
		pos = pos + 4

		t:add(f_rawRSSIvalue, buf(pos, 2))
		pos = pos + 2

		t:add(f_wlProtocolVersion, buf(pos, 1))
		pos = pos + 1

		t:add(f_oldestWlProtocolVersion, buf(pos, 1))
		pos = pos + 1
		
		--g_info = g_info .. string.format("WLOpcode:0x%X", g_WLOpcode)	
		--pkt.cols.info:set(g_info)
	end

	CheckProtocolDissector("eml_naipayload_datacallreceive")
end








