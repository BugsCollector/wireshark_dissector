do
	p_wireline = Proto("wireline", "WIRELINE")

	local wireline_opcode_table = {
		[0x01] = "WL_REGISTRATION_REQUEST",
		[0x02] = "WL_REGISTRATION_STATUS",
		[0x03] = "WL_REGISTRATION_GENERAL_OPS",
		[0x04] = "WL_PROTOCOL_VERSION_QUERY",
		[0x05] = "WL_PROTOCOL_VERSION_QUERY_RESPONSE",
	        -- 0x06 (Reserved)

		[0x07] = "WL_DATA_PDU_TX",
		[0x08] = "WL_DATA_PDU_STATUS",
		[0x09] = "WL_DATA_PDU_RX",

	    -- 0x0A-0x10 (Reserved)

		[0x11] = "WL_CHNL_STATUS",
		[0x12] = "WL_CHNL_STATUS_QUERY",
		[0x13] = "WL_VC_CHNL_CTRL_REQ",

	    -- 0x14-0x15 (Reserved)

		[0x16] = "WL_VC_CHNL_CTRL_STATUS",
		[0x17] = "WL_VC_CSBK_CALL",
		[0x18] = "WL_VC_VOICE_START",
		[0x19] = "WL_VC_VOICE_END_BURST",
		[0x20] = "WL_VC_CALL_SESSION_STATUS",
		[0x21] = "WL_VC_VOICE_BURST",
		[0x22] = "WL_VC_PRIVACY_BURST",

	    -- 0x23-0x2F (Reserved)
	}

	local callType_table = {

		[0x30]	=	"Preamble Private Data Call"	,
		[0x31]	=	"Preamble Group Data Call"	,
		[0x32]	=	"Preamble Private CSBK Call"	,
		[0x33]	=	"Preamble Group CSBK Call"	,
		[0x34]	=	"Preamble Emergency Call"	,
		[0x40]	=	"Emergency CSBK Alarm Request"	,
		[0x41]	=	"Emergency CSBK Alarm Response"	,
		[0x42]	=	"Emergency Voice Call"	,
		[0x43]	=	"Private Call Request"		,
		[0x44]	=	"Private Call Response"	,
		[0x45]	=	"Call Alert Request"	,
		[0x46]	=	"Call Alert Response"	,
		[0x47]	=	"Radio Check Request"	,
		[0x48]	=	"Radio Check Response"	,
		[0x49]	=	"Radio Inhibit Request"	,
		[0x4A]	=	"Radio Inhibit Response"	,
		[0x4B]	=	"Radio Un-inhibit Request"	,
		[0x4C]	=	"Radio Un-inhibit Response"	,
		[0x4D]	=	"Radio Monitor Request"	,
		[0x4E]	=	"Radio Monitor Response"	,
		[0x4F]	=	"Group Voice Call"	,
		[0x50]	=	"Private Voice Call"	,
		[0x51]	=	"Group Data Call"	,
		[0x52]	=	"Private Data Call"	,
		[0x53]	=	"All Call"	,
		[0x54]	=	"Confirmed Data Response"	,
		[0x55]	=	"Other Calls"	,
		[0x56]	=	"IP Console Radio Un-Inhibit Request"	,
		[0x57]	=	"IP Console Radio Inhibit Request" ,
		[0x58]  = 	"IP Console Radio Un-Inhibit Response"	,
		[0x59]  = 	"IP Console Radio Inhibit Response"	,
		[0x5A]  = 	"Group Phone Call"	,
		[0x5B]  = 	"Private Phone Call"	,
		[0x5C]  = 	"Phone All Call"	,
		[0x80] 	= 	"Private Confirmed Data Call",
		[0x81] 	= 	"Private Unconfirmed Data Call",
		[0x82] 	= 	"Group Data Call",
		[0x86] 	= 	"CSBK Data Call",
		[0x8C] 	= 	"WL 3rd Party CSBK Call",
	}


	local slotNumber_table = {
		[0x00] = "RESERVED",
		[0x01] = "Slot 1",
		[0x02] = "Slot 2",
		[0x03] = "Both Slot",
	}

	local accessCriteria_table = {
		[0x00] = "RESERVED",
		[0x01] = "Polite Access",
		[0x02] = "Transmit Interrupt",
		[0x03] = "Impolite",
	}

	local burstType_table = {
		[0x00] = "Reserved",
		[0x01] = "Voice Burst A",
		[0x02] = "Voice Burst B",
		[0x03] = "Voice Burst C",
		[0x04] = "Voice Burst D",
		[0x05] = "Voice Burst E",
		[0x06] = "Voice Burst F",
		[0x07] = "Voice Terminator",
		[0x08] = "Privacy Header",
	}

	local reasonCode_table = {
		[0x80] = "Reserved"	,
		[0x03] = "Race Condition"	,
		[0x05] = "Destination Slot Busy"	,
		[0x06] = "Group Destination Busy"	,
		[0x07] = "All Channels Busy"	,
		[0x08] = "Repeat Disabled"	,
		[0x09] = "Signal Interference "	,
		[0x0A] = "CWID In Progress"	,
		[0x0B] = "TOT Expiry Premature Call End"	,
		[0x0C] = "Tranmit Interrupted Call Failure"	,
		[0x0D] = "Higher Priority Call Takeover"	,
		[0x81] = "Local Group Call Not Allowed"	,
		[0x82] = "Non Rest Channel Repeater"	,
		[0x83] = "Destination Site Busy"	,
		[0x84] = "Under Run End Call"	,
		[0x85] = "Other Unknown Call Failure"	,
		[0x86] = "Phone Party Preempted Master" ,
		[0xA0] = "No Response",
		[0xA1] = "Retry Exhausted",
		[0xA2] = "NACK Received",
		[0xA3] = "Access Timeout",
		[0xA4] = "Realtime Msg Not Transmitted",
		[0xA5] = "Buffer Full",
		[0xA6] = "All Call is Ongoing",
		[0xA7] = "Yielded to Higher Priority Msg",
		[0xA8] = "WL Opcode Not Supported",
		[0xA9] = "WL Call Type Not Supported",
	}

	local channelStatus_table = {
		[0x00] = "RESERVED",
		[0x01] = "Active Repeat",
		[0x02] = "Idle",

	        -- 0x03-0x09 (Reserved)

		[0x0A] = "Slot is blocked",
		[0x0B] = "Slot is unblocked",

	        -- 0x0C-0x0F (Reserved)

		[0x10] = "Busy Rest Channel",
		[0x11] = "Rest Channel is idle/available",
		[0x12] = "Local Group Calls Not Allowed",
		[0x13] = "Local Group Calls Allowed",
		[0x14] = "Rest Channel is blocked",

	        -- 0x15-0xFF (Reserved)
	}

	local chnlCtrlStatusType_table = {
		[0x00] = "RESERVED",
		[0x01] = "Received",
		[0x02] = "Transmitting",
		[0x03] = "Transmission Successful",
		[0x04] = "Grant",
		[0x05] = "Declined",
		[0x06] = "Interrupting",

	        -- 0x07-0xFF (Reserved)
	}

	local callSessionStatus_table = {
	        -- 0x00-0x09 (Reserved)
		[0x0A] = "Call Session - Call Hang",
		[0x0B] = "Call Session - End",

	        -- 0x0C-0xFF (Reserved)
	}

	local mfid_table = {
		[0x00] = "DMR MFID",
		
		-- 0x01-0x0F (Reserved)

		[0x10] = "Motorola MFID",

	    -- 0x11-0xFF (Reserved)
	    
	    [0x20] = "3rd Party CSBK MFID",
	}

	local callAttributes_table = {

	}
	
	local typeOfCall_table = {
		[0x00] = "None",
		[0x01] = "Voice",
		[0x02] = "CSBK",
		[0x03] = "Data",
		[0x04] = "CSBK Data",
		[0x05] = "3rd Party CSBK",
	}

----------------------------------------------- wireline data part ---------------------------------------------


	local statusType_table = {
		[0x00] = "Reserved",
		[0x01] = "Received",
		[0x02] = "Transmitting",
		[0x03] = "Delivery Successful",
		[0x04] = "Delivery Unsuccessful",
		[0x05] = "Removed",
	}

	local statusCode_table = {
		[0x00] = "NA",
		[0x10] = "NACK Received",
		[0x11] = "No Response Received from SU",
		[0x12] = "SARQ retries exhausted",

		[0x20] = "Real Time priority data not transmitted. Channel is Busy",
		[0x21] = "Pre-empted (by immediate priority data from GW)",
		[0x22] = "Limited Patience Timer expired",
		[0x30] = "Destination is Busy",
		[0x31] = "Local Group not allowed",
		[0x32] = "Rest Channel Busy",
		[0x33] = "Non-Rest Channel",
	}

	--nack type opcode:00000000 01XXX000
	local nack_type = {
		[0x00] = "NA",
		[0x40] = "Illegal format, NI may have no real meaning",
		[0x48] = "Packet CRC of a packet with NI failed",
		[0x50] = "Memory of the recipient is full",
		[0x58] = "The received FSN is out of sequence",
		[0x60] = "Undeliverable",
		[0x68] = "The received packet is out of sequence, N(S) != VI or VI + 1",
		[0x70] = "Invalid user disallowed by the system",
	}

----------------------------------------------- wireline registration part ---------------------------------------------

        local addressType = {
                [0x0] = "None",
                [0x01] = "Individual",
                [0x02] = "Group",
                [0x03] = "All Individual",
                [0x04] = "All groups",
                [0x05] = "All Wide groups",
                [0x06] = "All Local groups",
        }

        local regStatusType = {
                [0x0] = "Successful",
                [0x01] = "Unsuccessful",
        }

        local regStatusCode = {
                [0x0] = "Successful",
                [0x01] = "CFS Is Disabled",
                [0x02] = "Number of Registration Entries Exceed Max Limit",
        }

        local regOperationOpcode = {
                [0x01] = "Check Registration Status",
                [0x02] = "De-registration",
        }

----------------------- COMMON FIELD

			local f_opcode = ProtoField.uint8("wireline.opcode", "opcode", base.HEX)
			local f_peerid = ProtoField.uint32("wireline.peerid", "Peer Id", base.HEX)
			local f_wirelineOpcode = ProtoField.uint8("wireline.wirelineOpcode", "Wireline Opcode", base.HEX, wireline_opcode_table)

			local f_slotNumber = ProtoField.uint8("wireline.slotNumber", "Slot Number", base.HEX, slotNumber_table)
			local f_callID = ProtoField.uint32("wireline.callID", "Wireline Voice Call ID", base.HEX)

			local f_callType = ProtoField.uint8("wireline.callType", "Wireline Voice Call Type", base.HEX, callType_table)

			local f_sourceID = ProtoField.uint32("wireline.sourceID", "Source Radio ID", base.HEX)
			local f_targetID = ProtoField.uint32("wireline.targetID", "Target Radio ID", base.HEX)

			local f_wlstsRegAlloc = ProtoField.uint8("wireline.wlStsRegAlloc", "WirelineStatusRegistration Allocation", base.HEX)
			local f_reserved8 = ProtoField.uint8("wireline.reserved", "Reserved", base.HEX)
			local f_reserved16 = ProtoField.uint16("wireline.reserved16", "Reserved", base.HEX)
			local f_3rdpartycsbko = ProtoField.uint8("wireline.3rdpartycsbko", "3rd Party CSBKO", base.HEX)
			local f_3rdpartymfid = ProtoField.uint8("wireline.3rdpartymfid", "3rd Party MFID", base.HEX)


-- WL_PROTOCOL_VERSION
       	local f_acceptedWLProtoVer = ProtoField.uint8("wireline.acceptedWLProtoVer", "Current or Accepted WL Protocol Version", base.HEX)
       	local f_oldestWLProtoVer = ProtoField.uint8("wireline.oldestWLProtoVer", "Oldest WL Protocol Version", base.HEX)
	
		local f_queryid = ProtoField.uint32("wireline.queryid", "ID of the protocol version query PDU", base.HEX)	
		local f_authenid = ProtoField.uint32("wireline.authenid", "Wireline Authentication ID assigned to 3rd party", base.HEX)
		local f_authensig = ProtoField.bytes("wireline.authensig", "First 10 bytes of the HMAC Wireline Authen Key", base.none)

-- VOICE & DATA PRIVACY FIELD
				local f_algorithmID = ProtoField.uint8("wireline.algorithmID", "Privacy Algorithm ID", base.HEX)
				local f_keyID = ProtoField.uint8("wireline.privacyKeyID", "Privacy Key Id", base.HEX)
				local f_IV = ProtoField.uint32("wireline.privacyIV", "Privacy IV", base.HEX)


		--VOICE COMMON FIELD

			local f_callID = ProtoField.uint32("wireline.callID", "call Id", base.HEX)
			local f_callAttributes = ProtoField.uint8("wireline.callAttributes", "callAttributes", base.HEX)
			local f_mfid = ProtoField.uint8("wireline.MFID", "MFID", base.HEX, mfid_table)
			local f_ServiceOptions = ProtoField.uint8("wireline.ServiceOptions", "ServiceOptions", base.HEX)
			local f_rtpInfo = ProtoField.uint8("wireline.rtpInfo", "rtpInfo", base.HEX)


  --special Definition of voice PDU

	--WL_VC_CHNL_CTRL_REQ

			local f_accessCriteria = ProtoField.uint8("wireline.accessCriteria", "accessCriteria", base.HEX, accessCriteria_table)
			local f_preambleDuration = ProtoField.uint8("wireline.preambleDuration", "preambleDuration", base.HEX)
			local f_csbkParameters = ProtoField.uint64("wireline.csbkParameters", "csbkParameters", base.HEX)

	--WL_VC_VOICE_BURST

			local f_burstType = ProtoField.uint8("wireline.burstType", "burstType", base.HEX, burstType_table)
			local f_ambeFrames = ProtoField.uint8("wireline.ambeFrames", "ambeFrames", base.HEX)
			local f_rawRssiValue = ProtoField.uint16("wireline.rawRssiValue", "rawRssiValue", base.HEX)

	--WL_VC_VOICE_END

	--WL_CHNL_STATUS

			local f_statusPduID = ProtoField.uint32("wireline.statusPduID", "statusPduID", base.HEX)
			local f_channelStatus = ProtoField.uint8("wireline.channelStatus", "channelStatus", base.HEX, channelStatus_table)
			local f_restChannelStatus = ProtoField.uint8("wireline.restChannelStatus", "restChannelStatus", base.HEX, channelStatus_table)
			local f_typeOfCall = ProtoField.uint8("wireline.typeOfCall", "typeOfCall", base.HEX, typeOfCall_table)


	--WL_VC_CHNL_CTRL_STATUS

			local f_chnlCtrlStatusType	= ProtoField.uint8("wireline.chnlCtrlStatusType", "chnlCtrlStatusType", base.HEX, chnlCtrlStatusType_table)
			local f_reasonCode	= ProtoField.uint8("wireline.reasonCode", "reasonCode", base.HEX, reasonCode_table)

	--WL_VC_CALL_SESSION_STATUS
			local f_radioID1	= ProtoField.uint32("wireline.radioID1", "radioID1", base.HEX)
			local f_radioID2	= ProtoField.uint32("wireline.radioID2", "radioID2", base.HEX)
			local f_talkGroupID	= ProtoField.uint32("wireline.talkGroupID", "talkGroupID", base.HEX)
			local f_callSessionStatus	= ProtoField.uint8("wireline.callSessionStatus", "callSessionStatus", base.HEX, callSessionStatus_table)


		--Data COMMON FIELD

			local f_pduID = ProtoField.uint32("wireline.pduID", "Pdu Id", base.HEX)

  --special Definition of Data PDU

-- COMMON FIELD of WL_DATA_PDU_RX & WL_DATA_PDU_TX

			local f_dhAttrib = ProtoField.uint8("wireline.dhAttrib", "Data Header Attribute", base.HEX)

--sub field of f_dhAttrib
				local f_syncFlag = ProtoField.string("wireline.S", "Sync Flag")
 				local f_ns = ProtoField.string("wireline.Ns", "Package Sequence Number(N(s))")
				local f_fsn = ProtoField.string("wireline.FSN", "FSN")

				local f_properitaryHdrPresent = ProtoField.uint8("wireline.properitaryHdrPresent", "Privacy Type & Compress Header", base.HEX)
--sub field of f_properitaryHdrPresent
				local f_compressHdr = ProtoField.string("wireline.compressHdr", "Compress Header")
				local f_privacyType = ProtoField.string("wireline.privacyType", "Privacy Type")

				local f_PayloadLen = ProtoField.uint16("wireline.PayloadLen", "Wireline PDU Payload Length", base.HEX)
--WL DATA PDU Payload
				--local f_Payload = ProtoField.uint8("wireline.Payload", "Payload", base.HEX)
				local f_Payload = ProtoField.bytes("wireline.Payload", "Payload", base.HEX)
				local f_PayloadCSBKData1 = ProtoField.uint16("wireline.CSBKDATAWORD0", "CSBKDATAWORD0", base.HEX)
				local f_PayloadCSBKData2 = ProtoField.uint16("wireline.CSBKDATAWORD1", "CSBKDATAWORD1", base.HEX)
				local f_PayloadCSBKData3 = ProtoField.uint16("wireline.CSBKDATAWORD2", "CSBKDATAWORD2", base.HEX)
				local f_PayloadCSBKData4 = ProtoField.uint16("wireline.CSBKDATAWORD3", "CSBKDATAWORD3", base.HEX)
				local f_PayloadCSBKData5 = ProtoField.uint16("wireline.CSBKDATAWORD4", "CSBKDATAWORD4", base.HEX)
				local f_PayloadCSBKData6 = ProtoField.uint16("wireline.CSBKDATAWORD5", "CSBKDATAWORD5", base.HEX)
--sub WL TX DATA PDU, CSBK DATA
				local f_csbkOp = ProtoField.uint8("wireline.CSBKDATAOp", "CSBKDATAOp", base.HEX)
				local f_csbkMFID = ProtoField.uint8("wireline.CSBKDATAMFID", "CSBKDATAMFID", base.HEX)
				local f_csbkdata1sthdr = ProtoField.uint8("wireline.CSBKDATA_1stHeader", "CSBKDATA_1stHeader", base.HEX)
				local f_csbkdata2ndhdr = ProtoField.uint8("wireline.CSBKDATA_2ndHeader", "CSBKDATA_2ndHeader", base.HEX)
				local f_csbkdataCRC = ProtoField.uint8("wireline.CSBKDATA_CRC", "CSBKDATA_CRC", base.HEX)
				local f_csbkdatalongtitudehigh = ProtoField.uint16("wireline.CSBKDATALRRPlongHigh", "CSBKDATALRRPlongHigh", base.HEX)
				local f_csbkdatalatitudehigh = ProtoField.uint16("wireline.CSBKDATALRRPlatHigh", "CSBKDATALRRPlatHigh", base.HEX)
				local f_csbkdatalrrpFormat = ProtoField.uint8("wireline.CSBKDATALRRPFormat", "CSBKDATALRRPFormat", base.HEX)
				local f_csbkdatalonglow = ProtoField.uint8("wireline.CSBKDATALRRPLongLow", "CSBKDATALRRPLongLow", base.HEX)
				local f_csbkdatalatlow = ProtoField.uint8("wireline.CSBKDATALRRPLatLow", "CSBKDATALRRPLatLow", base.HEX)
				local f_csbkdataRequestID = ProtoField.uint8("wireline.CSBKDATALRRPRequestID", "CSBKDATALRRPRequestID", base.HEX)
				local f_infotimeSpeedhor = ProtoField.uint32("wireline.CSBKDATALRRPInfoTimeSpeedHor", "CSBKDATALRRPInfoTimeSpeedHor", base.HEX)
				local f_csbkdatarsv = ProtoField.uint8("wireline.CSBKDATALRRPRSV", "CSBKDATALRRPRSV", base.HEX)
				local f_csbkdatatruncatedTime = ProtoField.uint8("wireline.CSBKDATALRRPTruncatedTime", "CSBKDATALRRPTruncatedTime", base.HEX)
				local f_csbkdataResultCode = ProtoField.uint16("wireline.CSBKDATALRRPResultCode", "CSBKDATALRRPResultCode", base.HEX)
				local f_csbkdataTruncatedCurrT = ProtoField.uint16("wireline.CSBKDATALRRPTruncatedCurrT", "CSBKDATALRRPTruncatedCurrT", base.HEX)
				local f_csbkdataotherType = ProtoField.uint8("wireline.CSBKDATALRRPOtherType", "CSBKDATALRRPOtherType", base.HEX)
				local f_csbkdataReserved = ProtoField.uint16("wireline.CSBKDATALRRPReserved", "CSBKDATALRRPReserved", base.HEX)
				local f_pduPacketCRC = ProtoField.uint32("wireline.pduPacketCRC", "Data Package Crc", base.HEX)
				local f_pduHdrRSSI = ProtoField.uint16("wireline.pduHdrRSSI", "RSSI Value In Data Header", base.HEX)


-- WL_DATA_PDU_TX

				local f_dataPriority = ProtoField.uint8("wireline.dataPriority", "Wireline Data PDU Priority", base.HEX)
--sub field of f_dataPriority

					local f_dataPrio = ProtoField.string("wireline.dataPrio", "Data Priority")
					local f_realTime = ProtoField.string("wireline.realTime", "Real Time")

				local f_conCHAccessParam = ProtoField.uint8("wireline.conCHAccessParam", "Conventional Channel Access Parameters", base.HEX)
--sub field of f_conCHAccessParam
				local f_accessType = ProtoField.string("wireline.accessType", "Access Type")
				local f_SpaceDuration = ProtoField.string("wireline.SpaceDuration", "Spacing Duration")

				local f_conCHAccessTimeOut = ProtoField.uint8("wireline.conCHAccessTimeOut", "Conventional Channel Access TimeOut", base.HEX)
				local f_preambleDuration = ProtoField.uint8("wireline.preambleDuration", "Preamble Duration", base.HEX)
				local f_trunkCHParam = ProtoField.uint8("wireline.trunkCHParam", "Not Forward In LCP Mode", base.HEX)
--sub field of f_trunkCHParam
				local f_notforward = ProtoField.string("wireline.notforward", "Not Forward")


-- WL_DATA_PDU_STATUS

       local f_DeliveryStatusType = ProtoField.uint8("wireline.DeliveryStatusType", "Delivery Status Type", base.HEX, statusType_table)
       local f_DeliveryStatusCode = ProtoField.uint8("wireline.DeliveryStatusCode", "Delivery Status Code", base.HEX, statusCode_table)
       local f_SubCode = ProtoField.uint16("wireline.SubCode", "Sub Code", base.HEX)
--sub field of subCode
          local f_class = ProtoField.string("wireline.class", "Class")
				 	local f_type_status = ProtoField.string("wireline.type_status", "Type_Status")

		--Registration COMMON FIELD


-- WL_REGISTRATION_REQUEST

       local f_regID = ProtoField.uint16("wireline.regID", "Registration ID", base.HEX)
       local f_regChnStatus = ProtoField.uint8("wireline.regChnStatus", "Channel Status Registration", base.HEX)
       local f_numOfRegEntries = ProtoField.uint8("wireline.numOfRegEntries", "Number of Registration Entries", base.HEX)

       local f_addressType = ProtoField.uint8("regentry.addressType", "...Address Type", base.HEX, addressType)
       local f_addrRangeStart = ProtoField.uint32("regentry.addrRangeStart", "   Address Range Start", base.HEX)
       local f_addrRangeEnd = ProtoField.uint32("regentry.addrRangeEnd", "   Address Range End", base.HEX)
       local f_voiceAttri = ProtoField.uint8("regentry.voiceAttri", "   Voice Attribute", base.HEX)
       local f_csbkAttri = ProtoField.uint8("regentry.csbkAttri", "   CSBK Attribute", base.HEX)
       local f_dataAttri = ProtoField.uint8("regentry.dataAttri", "   DATA Attribute", base.HEX)


-- WL_REGISTRATION_STATUS

       local f_slot1_RegID = ProtoField.uint16("wireline.slot1_RegID", "Slot1 Registration ID", base.HEX)
       local f_slot2_RegID = ProtoField.uint16("wireline.slot2_RegID", "Slot2 Registration ID", base.HEX)
       local f_regStatusType = ProtoField.uint8("wireline.regStatusType", "Registration Status Type", base.HEX, regStatusType)
       local f_regStatusCode = ProtoField.uint8("wireline.regStatusCode", "Registration Status Code", base.HEX, regStatusCode)

-- WL_REGISTRATION_GENERAL_OPS

       local f_regOperationOpcode = ProtoField.uint8("wireline.regOperationOpcode", "Registration Operation Opcode", base.HEX, regOperationOpcode)


	p_wireline.fields = {
	     ---COMMON FIELD
	        f_opcode, f_peerid, f_wirelineOpcode, f_slotNumber, f_acceptedWLProtoVer, f_oldestWLProtoVer,

	     ---DATA&Voice FIELD
	        f_callID, f_callType, f_sourceID, f_targetID, f_preambleDuration,

	    ---DATA&Registration FIELD
  	     f_pduID,

	     ---DATA FIELD
        	f_dhAttrib, f_properitaryHdrPresent, f_Payload, 
        	f_PayloadLen, f_PayloadCSBKData1,f_PayloadCSBKData2,f_PayloadCSBKData3,f_PayloadCSBKData4,f_PayloadCSBKData5,f_PayloadCSBKData6,f_csbkMFID,
        	f_csbkdata1sthdr,f_csbkdata2ndhdr,f_csbkdataCRC,f_csbkOp,f_csbkdatalongtitudehigh,f_csbkdatalatitudehigh,f_csbkdatalrrpFormat,f_csbkdatalonglow,f_csbkdatalatlow,f_csbkdataRequestID,f_infotimeSpeedhor,f_csbkdatarsv,f_csbkdatatruncatedTime,f_csbkdataResultCode,f_csbkdataTruncatedCurrT,f_csbkdataotherType,f_csbkdataReserved,
        	f_dataPriority, f_conCHAccessParam, f_conCHAccessTimeOut, f_trunkCHParam, f_pduPacketCRC,
        	f_pduHdrRSSI, f_DeliveryStatusType, f_DeliveryStatusCode, f_SubCode,
             ---SUB FIELD
                f_compressHdr, f_privacyType, f_dataPrio, f_realTime, f_accessType, f_SpaceDuration, f_class, f_type_status, f_syncFlag, f_ns, f_fsn,

	     ---Voice FIELD
					f_callAttributes, f_rtpInfo, f_mfid, f_ServiceOptions, f_accessCriteria, f_csbkParameters, f_burstType, f_ambeFrames,
        	f_rawRssiValue, f_statusPduID, f_channelStatus, f_restChannelStatus, f_typeOfCall, f_chnlCtrlStatusType, f_reasonCode, f_radioID1, f_radioID2, f_talkGroupID, f_callSessionStatus,


	     ---Privacy FIELD
					f_algorithmID, f_keyID, f_IV,

       ---REGISTRATION FIELD
          f_regID, f_regChnStatus, f_numOfRegEntries,
          f_addressType, f_addrRangeStart, f_addrRangeEnd, f_voiceAttri, f_csbkAttri, f_dataAttri,
          f_slot1_RegID, f_slot2_RegID, f_regStatusType, f_regStatusCode, f_regOperationOpcode, f_reserved8, f_reserved16, f_3rdpartycsbko, f_3rdpartymfid, f_queryid, f_authenid, f_authensig
        	}


---------------------------------------------------------- data field function -----------------------------------------------------------------

-- display the columns
	function columns_display(wirelineOpcode,buf, pkt)
		local peerid = buf(1,4):uint()
		local slotNum = buf(6,1):uint()

		local info = string.format("[%0.2X]", wirelineOpcode)
		if wireline_opcode_table[wirelineOpcode] ~= nil then

			if wirelineOpcode == 0x04 or wirelineOpcode == 0x05 then
				info = info ..  string.format("%-23s peerID=0x%0.8X",
			 									wireline_opcode_table[wirelineOpcode],
			 									peerid);

			-- WL_CHNL_STATUS or WL_CHNL_STATUS_QUERY
          	elseif wirelineOpcode  == 0x11 or wirelineOpcode  == 0x12 then
			 	info = info ..  string.format("%-23s peerID=0x%0.8X slot=%d",
			 									wireline_opcode_table[wirelineOpcode],
			 									peerid,
			 									slotNum);

			-- WL_VC_CHNL_CTRL_REQ or WL_VC_CHNL_CTRL_STATUS or WL_VC_CSBK_CALL or WL_VC_VOICE_START
			-- or WL_VC_VOICE_END_BURST or WL_VC_CALL_SESSION_STATUS or WL_VC_VOICE_BURST or WL_VC_PRIVACY_BURST
	  		elseif wirelineOpcode  == 0x13 or wirelineOpcode  == 0x16 or
	  	    	wirelineOpcode  == 0x17 or wirelineOpcode  == 0x18 or
	  	       	wirelineOpcode  == 0x19 or wirelineOpcode  == 0x20 or
	  	       	wirelineOpcode  == 0x21 or wirelineOpcode  == 0x22 then

  				local callID = buf(7,4):uint()
  				local callType = buf(11,1):uint()
				if callType_table[callType] ~= nil then
			 		info = info ..  string.format("%-23s peerID=0x%0.8X slot=%d callID=%X, callType=[%s]",
			 										wireline_opcode_table[wirelineOpcode],
			 										peerid,
			 										slotNum,
			 										callID,
			 										callType_table[callType])
			 	else
					info = info .. "Unknow wireline callType!"
      	  		end

			-- WL_DATA_PDU_TX or WL_DATA_PDU_RX
			elseif wirelineOpcode == 0x07 or wirelineOpcode == 0x09 then
--      	    local slotNum = buf(6,1):uint()
  				local callType = buf(11,1):uint()
  				if callType_table[callType] ~= nil then
     				info = info ..  string.format("%-23s peerID=%d slotNumber=%d callType=[%s]",
													wireline_opcode_table[wirelineOpcode],
  					                                peerid,
  					                                slotNum,
  					                                callType_table[callType])
   				else
					info = info .. "Unknow wireline callType!"
      	  		end
      	  		
			-- WL_DATA_PDU_STATUS
			elseif wirelineOpcode == 0x08 then
--      	    local slotNum = buf(6,1):uint()
  			    local statusType = buf(11,1):uint()
  			    if statusType_table[statusType] ~= nil then
      	    		info = info ..  string.format("%-23s peerID=%d slotNumber=%d statusType=[%s]",
  								                wireline_opcode_table[wirelineOpcode],
  								                peerid,
  								                slotNum,
  							                        statusType_table[statusType])
  				else
  					info = info .. "Unknow wireline data statusType!"
  				end

			-- WL_REGISTRATION_REQUEST
			elseif wirelineOpcode == 0x01 then
--  			local slotNum = buf(6,1):uint()
  				local reg_id = buf(11,2):uint()
  				if slotNumber_table[slotNum] ~= nil then
  					info = info ..  string.format("%-23s peerID=%d slot=%s RegID=0x%X", 
  													wireline_opcode_table[wirelineOpcode], 
  													peerid, 
  													slotNumber_table[slotNum], 
  													reg_id)
  				else
					info = info .. "Unknow Slot!"
				end

			-- WL_REGISTRATION_STATUS
    	  	elseif wirelineOpcode == 0x02 then
  				local slot1_regID = buf(10,2):uint()
  	  	    	local slot2_regID = buf(12,2):uint()
  	  	    	local regStatus = buf(14,1):uint()
  	  	    	if regStatusType[regStatus] ~= nil then
					info = info ..  string.format("%-23s peerID=%d s1_RegID=0x%X s2_RegID=0x%X Status=%s",
  								                wireline_opcode_table[wirelineOpcode],
  								                peerid,
  								                slot1_regID,
  								                slot2_regID,
  								                regStatusType[regStatus])
      	    	else
					info = info .. "Unknow wireline registration statusType!"
      	    	end

			-- WL_REGISTRATION_GENERAL_OPS
			elseif wirelineOpcode == 0x03 then
--  				  local slotNum = buf(6,1):uint()
				local reg_op_opcode = buf(11,1):uint()
  				if regOperationOpcode[reg_op_opcode] ~= nil then
					info = info ..  string.format("%-23s peerID=%d slot=%s Operation=%s",
													wireline_opcode_table[wirelineOpcode],
  								                	peerid,
  								                	slotNumber_table[slotNum],
  								                	regOperationOpcode[reg_op_opcode])
				else
					info = info .. "Unknow wireline registration Operation Opcode!"
				end
			else
				 info = info .. "Unknow wireline Opcode!"
	       	end
		else
			info = info .. "Unknow wireline Opcode!"
       	end

        pkt.cols.protocol:set("WIRELINE")
        pkt.cols.info:set(info)
		end     --end of function columns_display


--status code is "NACK RECEIVED", display the subcode
		function subcode_display(n,buf)
			local v = n:add(f_SubCode, buf, nack_type)

			--CLASS
			local classBit1 = getbit(buf:uint(), 7)
			local classBit2 = getbit(buf:uint(), 6)
			local classDesc = "........"..classBit1..classBit2.."......".." = Class : "..NACK
			v:add(f_class, buf, classDesc)

			--TYPE & STATUS
			local typeBit1 = getbit(buf:uint(), 5)
			local typeBit2 = getbit(buf:uint(), 4)
			local typeBit3 = getbit(buf:uint(), 3)
			local typeStatusDesc = "........"..".."..typeBit1..typeBit2..typeBit3.."...".." = Type : ".."Binary("..typeBit1..typeBit2..typeBit3..") & Status : "
			local val = typeBit1*4 + typeBit2*2 + typeBit3
			if val == 0 or val == 1 or val == 2 or val ==4 or val == 6 then
					typeStatusDesc = typeStatusDesc.."NI"
			elseif val == 3 then
					typeStatusDesc = typeStatusDesc.."FSN"
			elseif val == 5 then
					typeStatusDesc = typeStatusDesc.."VI"
			else
					typeStatusDesc = typeStatusDesc.."Unknow Status"
			end
			v:add(f_type_status, buf, typeStatusDesc)

		end     --end of function subcode_display


--f_dhAttrib

--dhAttrib bit display
		function dhAttrib_display(n,buf)
			local v = n:add(f_dhAttrib, buf)

			local bit0 = 0
			local bit1 = 0
			local bit2 = 0
			local bit3 = 0
			local val =	0
			local dec = 0

	        --fsn
			bit0 = getbit(buf:uint(), 0)
			bit1 = getbit(buf:uint(), 1)
			bit2 = getbit(buf:uint(), 2)
			bit3 = getbit(buf:uint(), 3)
			val = bit3*8 + bit2*4 + bit1*2 + bit0
			dec = "...."..bit3..bit2..bit1..bit0.." = "..val
			v:add(f_fsn, buf, dec)

	        --Ns
			bit0 = getbit(buf:uint(), 4)
			bit1 = getbit(buf:uint(), 5)
			bit2 = getbit(buf:uint(), 6)
			val = bit2*4 + bit1*2 + bit0
			dec = "."..bit2..bit1..bit0.."....".." = "..val
			v:add(f_ns, buf, dec)

	        --s
			bit0 = getbit(buf:uint(), 7)
			val = bit0
			dec = bit0.."......."

			if val == 0 then
					dec = dec.." = Sync Flag Not Present"
			elseif val == 1 then
					dec = dec.." = Sync Flag Present"
			end
			v:add(f_syncFlag, buf, dec)

		end   --end of function dhAttrib_display


--properitaryHdrPresent bit display
		function proHdrPresent_display(n,buf)
			local v = n:add(f_properitaryHdrPresent, buf)

	                --compress header
			local compressHdrBit = getbit(buf:uint(), 0)
			local compHdrDec = "......."..compressHdrBit
			if compressHdrBit == 0 then
					compHdrDec = compHdrDec.." = Compress Header Not Present"
			elseif compressHdrBit == 1 then
					compHdrDec = compHdrDec.." = Compress Header Present"
			end
			v:add(f_compressHdr, buf, compHdrDec)

	                --privacy type
			local privacyTypeBit1 = getbit(buf:uint(), 3)
			local privacyTypeBit2 = getbit(buf:uint(), 2)
			local privacyTypeBit3 = getbit(buf:uint(), 1)
			local value = privacyTypeBit1*4 + privacyTypeBit2*2 + privacyTypeBit3
			local privacyTypeDec = "...."..privacyTypeBit1..privacyTypeBit2..privacyTypeBit3.."."
			if value == 0x0 then
					privacyTypeDec = privacyTypeDec.." = No Privacy"
			elseif value == 0x1 then
					privacyTypeDec = privacyTypeDec.." = Basic Privacy"
			elseif value == 0x2 then
					privacyTypeDec = privacyTypeDec.." = Enhanced Privacy"
			else
					privacyTypeDec = privacyTypeDec.." = Reserved"
			end
			v:add(f_privacyType, buf, privacyTypeDec)

		end   --end of function proHdrPresent_display

--conventional channel access parameter bit disaply
		function conCHAccessParam_display(n,buf)
			local v = n:add(f_conCHAccessParam, buf)

	                --access type
			local accessTypeBit1 = getbit(buf:uint(), 7)
			local accessTypeBit2 = getbit(buf:uint(), 6)
			local value1 = accessTypeBit1*2 + accessTypeBit2
			local accessTypeDec = accessTypeBit1..accessTypeBit2.."......"
			if value1 == 0x0 then
					accessTypeDec = accessTypeDec.." = Regular access"
			elseif value1 == 0x1 then
					accessTypeDec = accessTypeDec.." = Data Centric Access"
			else
					accessTypeDec = accessTypeDec.." = Reserved"
			end
			v:add(f_accessType, buf, accessTypeDec)

	                --spacing duration
			local SpaceDurationBit1 = getbit(buf:uint(), 4)
			local SpaceDurationBit2 = getbit(buf:uint(), 3)
			local SpaceDurationBit3 = getbit(buf:uint(), 2)
			local SpaceDurationBit4 = getbit(buf:uint(), 1)
			local SpaceDurationBit5 = getbit(buf:uint(), 0)
			local value2 = SpaceDurationBit1*16 + SpaceDurationBit2*8 + SpaceDurationBit3*4 + SpaceDurationBit4*2 + SpaceDurationBit5
			v:add(f_SpaceDuration, buf, "..."..SpaceDurationBit1..SpaceDurationBit2..SpaceDurationBit3..SpaceDurationBit4..SpaceDurationBit5.." = "..value2)

		end     --end of function conCHAccessParam_display

--data priority bit display
		function dataPriority_display(n,buf)
			local v = n:add(f_dataPriority, buf)

	                --data priority
			local dataPriorityBit1 = getbit(buf:uint(), 7)
			local dataPriorityBit2 = getbit(buf:uint(), 6)
			local value2 = dataPriorityBit1*2 + dataPriorityBit2
			local dataPriorityDec = dataPriorityBit1..dataPriorityBit2.."......"
			if value2 == 0x0 then
					dataPriorityDec = dataPriorityDec.." = Regular"
			elseif value2 == 0x1 then
					dataPriorityDec = dataPriorityDec.." = Priority"
			elseif value2 == 0x2 then
					dataPriorityDec = dataPriorityDec.." = Immediate"
			else
					dataPriorityDec = dataPriorityDec.." = Reserved"
			end
			v:add(f_dataPrio, buf, dataPriorityDec)

	                --real time
			local realTimeBit1 = getbit(buf:uint(), 5)
			local realTimeDec = ".."..realTimeBit1.."....."
			if realTimeBit1 == 0x0 then
					realTimeDec = realTimeDec.." = None Real Time"
			elseif realTimeBit1 == 0x1 then
					realTimeDec = realTimeDec.." = Real Time"
			else
			        --print ("")
			end
			v:add(f_realTime, buf, realTimeDec)

		end     --end of function dataPriority_display


--trunk channel parameter display
    function trunkCHParam_display(n, buf)
      local v = n:add(f_trunkCHParam, buf)
		  local notforwardBit = getbit(buf:uint(),7)
			local notForwardDec = notforwardBit.."......."
			if notforwardBit == 0x0 then
			        notForwardDec = notForwardDec.." [Forward to Remote Site]"
			elseif notforwardBit == 0x1 then
        			notForwardDec = notForwardDec.." [Not Forward to Remote Site]"
			end
			v:add(f_notforward, buf, notForwardDec)
		end
------------------------------CSBK DATA in wireline PDU-----------------------------
--data ARS display
		function CSBKDATAARS_display(n,buf,csbkOp)
		  --CSBK DATA payload
		  n:add("-------------CSBK DATA(ARS) start------------")
		  n:add("--1. payload raw data")
			n:add(f_PayloadCSBKData1,buf(0,2))
			n:add(f_PayloadCSBKData2,buf(2,2))
			n:add(f_PayloadCSBKData3,buf(4,2))
			n:add(f_PayloadCSBKData4,buf(6,2))
			n:add(f_PayloadCSBKData5,buf(8,2))
			n:add(f_PayloadCSBKData6,buf(10,2))
			n:add("--2. filed value")
  		---opcode---
			n:add(f_csbkOp,buf(0,1),csbkOp)
			--MFID---
			local csbkmfid = buf(1,1):uint()
			n:add(f_csbkMFID, buf(1,1), csbkmfid)
			--trgid---
			n:add(f_targetID, buf(2, 3))
			--srcid---
			n:add(f_sourceID, buf(5, 3))
			--first header--
			n:add(f_csbkdata1sthdr, buf(8, 1))
			--second header--
			n:add(f_csbkdata2ndhdr, buf(9, 1))
			--CRC--
      n:add(f_csbkdataCRC, buf(10, 1))
      n:add("-------------CSBK DATA(ARS) end------------")
		end     --end of function data ARS display

--data LRRP display
		function CSBKDATALRRP_latlong_display(n,buf,csbkOp)
		  --CSBK DATA payload
		  n:add("--1. payload raw data")
			n:add(f_PayloadCSBKData1,buf(0,2))
			n:add(f_PayloadCSBKData2,buf(2,2))
			n:add(f_PayloadCSBKData3,buf(4,2))
			n:add(f_PayloadCSBKData4,buf(6,2))
			n:add(f_PayloadCSBKData5,buf(8,2))
			n:add(f_PayloadCSBKData6,buf(10,2))
			n:add("--2. filed value")
			local lrrpbyte3 = buf(2,1):uint()

			--longlow
			local longlowhighbit = getbit(lrrpbyte3,5)
			local longlowlowbit = getbit(lrrpbyte3,4)
			local longlow = longlowhighbit*2+longlowlowbit
			n:add(f_csbkdatalonglow,buf(2,1),longlow)
			--latlow
			local latlow = getbit(lrrpbyte3,3)
			n:add(f_csbkdatalatlow,buf(2,1),latlow)
			--requestid
			local requestIDbit2 = getbit(lrrpbyte3,2)
			local requestIDbit1 = getbit(lrrpbyte3,1)
			local requestIDbit0 = getbit(lrrpbyte3,0)
			local requestID = requestIDbit2*4+requestIDbit1*2+requestIDbit0
			n:add(f_csbkdataRequestID,buf(2,1),requestID)
			--srcid---
			n:add(f_sourceID, buf(3, 3))
			--longitude_high--
			n:add(f_csbkdatalongtitudehigh, buf(6, 2))
			--latitude_high--
			n:add(f_csbkdatalatitudehigh, buf(8, 2))
			--CRC--
      n:add(f_csbkdataCRC, buf(10, 2))

		end     --end of function data LRRP display

--data LRRP display
		function CSBKDATALRRP_infotimespeedhor_display(n,buf,csbkOp)
		  --CSBK DATA payload
		  n:add("--1. payload raw data")
			n:add(f_PayloadCSBKData1,buf(0,2))
			n:add(f_PayloadCSBKData2,buf(2,2))
			n:add(f_PayloadCSBKData3,buf(4,2))
			n:add(f_PayloadCSBKData4,buf(6,2))
			n:add(f_PayloadCSBKData5,buf(8,2))
			n:add(f_PayloadCSBKData6,buf(10,2))
			n:add("--2. filed value")
			local lrrpbyte3 = buf(2,1):uint()
			--longlow
			local longlowhighbit = getbit(lrrpbyte3,5)
			local longlowlowbit = getbit(lrrpbyte3,4)
			local longlow = longlowhighbit*2+longlowlowbit
			n:add(f_csbkdatalonglow,buf(2,1),longlow)
			--latlow
			local latlow = getbit(lrrpbyte3,3)
			n:add(f_csbkdatalatlow,buf(2,1),latlow)
			--requestid
			local requestIDbit2 = getbit(lrrpbyte3,2)
			local requestIDbit1 = getbit(lrrpbyte3,1)
			local requestIDbit0 = getbit(lrrpbyte3,0)
			local requestID = requestIDbit2*4+requestIDbit1*2+requestIDbit0
			n:add(f_csbkdataRequestID,buf(2,1),requestID)
			--info-time and speed_hour---
			n:add(f_infotimeSpeedhor, buf(3, 3))
			--longitude_high--
			n:add(f_csbkdatalongtitudehigh, buf(6, 2))
			--latitude_high--
			n:add(f_csbkdatalatitudehigh, buf(8, 2))
			--CRC--
      n:add(f_csbkdataCRC, buf(10, 2))

		end     --end of function data LRRP display
--data LRRP display
		function CSBKDATALRRP_error_display(n,buf,csbkOp)
		  --CSBK DATA payload
		  n:add("--1. payload raw data")
			n:add(f_PayloadCSBKData1,buf(0,2))
			n:add(f_PayloadCSBKData2,buf(2,2))
			n:add(f_PayloadCSBKData3,buf(4,2))
			n:add(f_PayloadCSBKData4,buf(6,2))
			n:add(f_PayloadCSBKData5,buf(8,2))
			n:add(f_PayloadCSBKData6,buf(10,2))
			n:add("--2. filed value")
			local lrrpbyte3 = buf(2,1):uint()
			--rsv
			local rsvhighbit = getbit(lrrpbyte3,5)
			local rsvlowbit = getbit(lrrpbyte3,4)
			local rsv = rsvhighbit*2+rsvlowbit
			n:add(f_csbkdatarsv,buf(2,1),rsv)
			--truncated time
			local truncatedTime = getbit(lrrpbyte3,3)
			n:add(f_csbkdatatruncatedTime,buf(2,1),truncatedTime)
			--requestid
			local requestIDbit2 = getbit(lrrpbyte3,2)
			local requestIDbit1 = getbit(lrrpbyte3,1)
			local requestIDbit0 = getbit(lrrpbyte3,0)
			local requestID = requestIDbit2*4+requestIDbit1*2+requestIDbit0
			n:add(f_csbkdataRequestID,buf(2,1),requestID)
			--source id---
			n:add(f_sourceID, buf(3, 3))
			--result code--
			n:add(f_csbkdataResultCode, buf(6, 2))
			--truncated current time--
			n:add(f_csbkdataTruncatedCurrT, buf(8, 2))
			--CRC--
      n:add(f_csbkdataCRC, buf(10, 2))

		end     --end of function data LRRP display

--data LRRP display
		function CSBKDATALRRP_other_display(n,buf,csbkOp)
		  --CSBK DATA payload
		  n:add("--1. payload raw data")
			n:add(f_PayloadCSBKData1,buf(0,2))
			n:add(f_PayloadCSBKData2,buf(2,2))
			n:add(f_PayloadCSBKData3,buf(4,2))
			n:add(f_PayloadCSBKData4,buf(6,2))
			n:add(f_PayloadCSBKData5,buf(8,2))
			n:add(f_PayloadCSBKData6,buf(10,2))
			n:add("--2. filed value")
			local lrrpbyte3 = buf(2,1):uint()
			--other type
			local otherTypehighbit = getbit(lrrpbyte3,5)
			local otherTypelowbit = getbit(lrrpbyte3,4)
			local otherType = otherTypehighbit*2+otherTypelowbit
			n:add(f_csbkdataotherType,buf(2,1),otherType)
			--rsv
			local rsv = getbit(lrrpbyte3,3)
			n:add(f_csbkdatarsv,buf(2,1),rsv)
			--requestid
			local requestIDbit2 = getbit(lrrpbyte3,2)
			local requestIDbit1 = getbit(lrrpbyte3,1)
			local requestIDbit0 = getbit(lrrpbyte3,0)
			local requestID = requestIDbit2*4+requestIDbit1*2+requestIDbit0
			n:add(f_csbkdataRequestID,buf(2,1),requestID)
			--source id---
			n:add(f_sourceID, buf(3, 3))
			--result code or protocol version--
			n:add(f_csbkdataResultCode, buf(6, 2))
			--truncated current time--
			n:add(f_csbkdataReserved, buf(8, 2))
			--CRC--
      n:add(f_csbkdataCRC, buf(10, 2))

		end     --end of function data LRRP display

--data payload display
		function parseCSBKDATAPayload_display(n,buf,opbuf)
			local v = n:add(f_Payload, buf)
			--CSBKDATA csbkop---
	    local csbkOpbit5 = getbit(opbuf:uint(), 5)
	    local csbkOpbit4 = getbit(opbuf:uint(), 4)
	    local csbkOpbit3 = getbit(opbuf:uint(), 3)
	    local csbkOpbit2 = getbit(opbuf:uint(), 2)
	    local csbkOpbit1 = getbit(opbuf:uint(), 1)
	    local csbkOpbit0 = getbit(opbuf:uint(), 0)

	    local csbkOp = csbkOpbit0 + csbkOpbit1*2+ csbkOpbit2*4 +csbkOpbit3*8 + csbkOpbit4*16 + csbkOpbit5*32

	    if csbkOp == 8 then
	    	CSBKDATAARS_display(n,buf,csbkOp)
	    elseif csbkOp == 9 then
				--format--
				local lrrpbyte3 = buf(2,1):uint()
				local formathighbit = getbit(lrrpbyte3, 7)
				local formatlowbit = getbit(lrrpbyte3,6)
				local format = formathighbit*2+formatlowbit
				--one sentence description--
				if format == 0 then
					n:add("----CSBK DATA LRRP report with location coorinates(latitude and longitude)(start)-----")
				elseif format == 1 then
					n:add("----CSBK DATA LRRP report with location coorinates(info-time and speed-hor)(start)-----")
				elseif format == 2 then
					n:add("----CSBK DATA LRRP report with error response(start)-----")
				elseif format == 3 then
					n:add("----CSBK DATA other LRRP response(start)-----")
				else
					n:add("----not supported CSBK DATA LRRP-----")
				end
				---opcode---
				n:add(f_csbkOp,buf(0,1),csbkOp)
				--MFID---
				local csbkmfid = buf(1,1):uint()
				n:add(f_csbkMFID, buf(1,1), csbkmfid)
				--format--
				n:add(f_csbkdatalrrpFormat, buf(2,1),format)

				if format == 0 then
	      	CSBKDATALRRP_latlong_display(n,buf,csbkOp)
	      	n:add("----CSBK DATA LRRP report with location coorinates(latitude and longitude)(end)-----")
	      elseif format == 1 then
	        CSBKDATALRRP_infotimespeedhor_display(n,buf,csbkOp)
	        n:add("----CSBK DATA LRRP report with location coorinates(info-time and speed-hor)(end)-----")
	      elseif format == 2 then
	        CSBKDATALRRP_error_display(n,buf,csbkOp)
	        n:add("----CSBK DATA LRRP report with error response(end)-----")
	      elseif format == 3 then
	        CSBKDATALRRP_other_display(n,buf,csbkOp)
	        n:add("----CSBK DATA other LRRP response(end)-----")
	      else
	        --do nothing
	      end
	    else
	      n:add("-------------CSBK DATA(not supportted!!!) ------------")
	    end

		end     --end of function data payload display

---------------------------------------------------------- protocol tree function-----------------------------------------------------------------
	  -- protocol detail

-- display the Wireline Voice
		function wlvoice_display(wirelineOpcode, n, buf)

         if wirelineOpcode == 0x13  then --WL_VC_CHNL_CTRL_REQ
							n:add(f_opcode, buf(0, 1))
							n:add(f_peerid, buf(1, 4))
							n:add(f_wirelineOpcode, buf(5, 1))
							n:add(f_slotNumber, buf(6, 1))
							n:add(f_callID, buf(7, 4))
							n:add(f_callType, buf(11, 1))
          		n:add(f_sourceID, buf(12, 4))
          		n:add(f_targetID, buf(16, 4))
          		n:add(f_accessCriteria, buf(20, 1))
          		n:add(f_callAttributes, buf(21, 1))
          		-- reserved for buf(22,1)
          		n:add(f_preambleDuration, buf(23, 1))
				local tmpCallType = buf(11, 1):uint()
				if tmpCallType == 0x8C then
					n:add(f_3rdpartycsbko, buf(24,1))
					n:add(f_3rdpartymfid,buf(25,1))
				else
					n:add(f_reserved16,buf(24, 2))
				end
          		-- reserved for buf(24,2)
          		n:add(f_csbkParameters, buf(26, 8))
          		n:add(f_acceptedWLProtoVer, buf(34, 1))
           		n:add(f_oldestWLProtoVer, buf(35, 1))

					elseif wirelineOpcode == 0x11  then --WL_CHNL_STATUS
							n:add(f_opcode, buf(0, 1))
							n:add(f_peerid, buf(1, 4))
							n:add(f_wirelineOpcode, buf(5, 1))
							n:add(f_slotNumber, buf(6, 1))
							n:add(f_statusPduID, buf(7, 4))
							n:add(f_channelStatus, buf(11, 1))
							n:add(f_restChannelStatus, buf(12, 1))
							n:add(f_typeOfCall, buf(13, 1))
          		n:add(f_acceptedWLProtoVer, buf(14, 1))
           		n:add(f_oldestWLProtoVer, buf(15, 1))

					elseif wirelineOpcode == 0x12  then --WL_CHNL_STATUS_QUERY
							n:add(f_opcode, buf(0, 1))
							n:add(f_peerid, buf(1, 4))
							n:add(f_wirelineOpcode, buf(5, 1))
							n:add(f_slotNumber, buf(6, 1))
          		n:add(f_acceptedWLProtoVer, buf(7, 1))
           		n:add(f_oldestWLProtoVer, buf(8, 1))


					elseif wirelineOpcode == 0x16  then --WL_VC_CHNL_CTRL_STATUS
							n:add(f_opcode, buf(0, 1))
							n:add(f_peerid, buf(1, 4))
							n:add(f_wirelineOpcode, buf(5, 1))
							n:add(f_slotNumber, buf(6, 1))
							n:add(f_callID, buf(7, 4))
							n:add(f_callType, buf(11, 1))
							n:add(f_chnlCtrlStatusType, buf(12, 1))
							n:add(f_reasonCode, buf(13, 1))
          		n:add(f_acceptedWLProtoVer, buf(14, 1))
           		n:add(f_oldestWLProtoVer, buf(15, 1))


				elseif wirelineOpcode == 0x17  then --WL_VC_CSBK_CALL
							n:add(f_opcode, buf(0, 1))
							n:add(f_peerid, buf(1, 4))
							n:add(f_wirelineOpcode, buf(5, 1))
							n:add(f_slotNumber, buf(6, 1))
							n:add(f_callID, buf(7, 4))
							n:add(f_callType, buf(11, 1))
							n:add(f_sourceID, buf(12, 4))
          		n:add(f_targetID, buf(16, 4))
          		-- reserved for buf(20,2)
				local tmpcallType = buf(11, 1):uint()
				if tmpcallType == 0x8c then
					n:add(f_reserved8, buf(20,1))
					n:add(f_3rdpartycsbko,buf(21,1))
				else
					n:add(f_reserved16, buf(20,2))
				end

          		n:add(f_mfid, buf(22, 1))
          		n:add(f_csbkParameters, buf(23, 8))
          		n:add(f_rawRssiValue, buf(31, 2))
          		n:add(f_acceptedWLProtoVer, buf(33, 1))
           		n:add(f_oldestWLProtoVer, buf(34, 1))


				  elseif wirelineOpcode == 0x18  then --WL_VC_VOICE_START
							n:add(f_opcode, buf(0, 1))
							n:add(f_peerid, buf(1, 4))
							n:add(f_wirelineOpcode, buf(5, 1))
							n:add(f_slotNumber, buf(6, 1))
							n:add(f_callID, buf(7, 4))
							n:add(f_callType, buf(11, 1))
							n:add(f_sourceID, buf(12, 4))
          		n:add(f_targetID, buf(16, 4))
							n:add(f_callAttributes, buf(20, 1))
							-- reserved for buf(21,1)
							n:add(f_mfid, buf(22, 1))
							n:add(f_ServiceOptions, buf(23, 1))
          		n:add(f_acceptedWLProtoVer, buf(24, 1))
           		n:add(f_oldestWLProtoVer, buf(25, 1))



					 elseif wirelineOpcode == 0x19  then --WL_VC_VOICE_END
							n:add(f_opcode, buf(0, 1))
							n:add(f_peerid, buf(1, 4))
							n:add(f_wirelineOpcode, buf(5, 1))
							n:add(f_slotNumber, buf(6, 1))
							n:add(f_callID, buf(7, 4))
							n:add(f_callType, buf(11, 1))
							n:add(f_sourceID, buf(12, 4))
          		n:add(f_targetID, buf(16, 4))
          		--n:add(f_rtpInfo, buf(20, 12))
							n:add(f_burstType, buf(32, 1))
							-- reserved for buf(33,1)
							n:add(f_mfid, buf(34, 1))
							n:add(f_ServiceOptions, buf(35, 1))
          		n:add(f_acceptedWLProtoVer, buf(36, 1))
           		n:add(f_oldestWLProtoVer, buf(37, 1))

					elseif wirelineOpcode == 0x20  then --WL_VC_CALL_SESSION_STATUS
							n:add(f_opcode, buf(0, 1))
							n:add(f_peerid, buf(1, 4))
							n:add(f_wirelineOpcode, buf(5, 1))
							n:add(f_slotNumber, buf(6, 1))
							n:add(f_callID, buf(7, 4))
							n:add(f_callType, buf(11, 1))
							n:add(f_radioID1, buf(12, 4))
							n:add(f_radioID2, buf(16, 4))
							n:add(f_talkGroupID, buf(20, 4))
							n:add(f_callSessionStatus, buf(24, 1))
          		n:add(f_acceptedWLProtoVer, buf(25, 1))
           		n:add(f_oldestWLProtoVer, buf(26, 1))



           elseif wirelineOpcode == 0x21  then --WL_VC_VOICE_BURST
							n:add(f_opcode, buf(0, 1))
							n:add(f_peerid, buf(1, 4))
							n:add(f_wirelineOpcode, buf(5, 1))
							n:add(f_slotNumber, buf(6, 1))
							n:add(f_callID, buf(7, 4))
							n:add(f_callType, buf(11, 1))
           		n:add(f_sourceID, buf(12, 4))
          		n:add(f_targetID, buf(16, 4))
          		n:add(f_callAttributes,buf(20, 1))
          		-- reserved for buf(21,1)
          		-- n:add(f_rtpInfo, buf(22, 12))
							n:add(f_burstType, buf(34, 1))
          		-- reserved for buf(35,1)
							n:add(f_mfid, buf(36, 1))
							n:add(f_ServiceOptions, buf(37, 1))
							n:add(f_algorithmID, buf(38, 1))
							n:add(f_keyID, buf(38, 1))
							n:add(f_IV, buf(39, 4))
							-- n:add(f_ambeFrames, buf(43, 20))
							n:add(f_rawRssiValue, buf(63, 2))
          		n:add(f_acceptedWLProtoVer, buf(65, 1))
           		n:add(f_oldestWLProtoVer, buf(66, 1))
					else
							--print("Unknow wireline voice opcode!")
					end	--end if wirelineOpcode

		end     --end of function wlvoice_display


-- display the Wireline Data
		function wldata_display(wirelineOpcode, n, buf)
			-- WL_DATA_PDU_TX
			if wirelineOpcode == 0x07 then
				n:add(f_opcode, buf(0, 1))
				n:add(f_peerid, buf(1, 4))
				n:add(f_wirelineOpcode, buf(5, 1))
				n:add(f_slotNumber, buf(6, 1))
				n:add(f_pduID, buf(7, 4))
				n:add(f_callType, buf(11, 1))
				n:add(f_sourceID, buf(12, 4))
				n:add(f_targetID, buf(16, 4))

				dataPriority_display(n, buf(20, 1))
				conCHAccessParam_display(n,buf(21, 1))

				n:add(f_conCHAccessTimeOut, buf(22, 1))
				n:add(f_preambleDuration, buf(23, 1))

				trunkCHParam_display(n, buf(24,1))
				dhAttrib_display(n, buf(25,1))
				proHdrPresent_display(n,buf(26, 1))

				n:add(f_algorithmID, buf(27, 1))

				n:add(f_keyID, buf(28, 1))
				n:add(f_IV, buf(29, 4))
				n:add(f_PayloadLen, buf(33, 2))
				local dataLen1 = buf(33, 2):uint()
				if(data_dis ~= nil) then
					data_dis:call(buf(35):tvb(), pkt, n)
				end

				----check if CSBK DATA call--------
				local dataCallType = buf(11,1):uint()
				if dataCallType == 0x86 then
					if dataLen1 == 0x0c then
						parseCSBKDATAPayload_display(n,buf(35,dataLen1),buf(35,1))
					else
						n:add("----------incorrect CSBKDATA payload length!!!------------")
					end
				end
				----end check CSBK DATA call-------
				n:add(f_acceptedWLProtoVer, buf(35+dataLen1, 1))
				n:add(f_oldestWLProtoVer, buf(36+dataLen1, 1))


			-- WL_DATA_PDU_STATUS

					elseif wirelineOpcode == 0x08 then
              n:add(f_opcode, buf(0, 1))
              n:add(f_peerid, buf(1, 4))
              n:add(f_wirelineOpcode, buf(5, 1))
              n:add(f_slotNumber, buf(6, 1))
              n:add(f_pduID, buf(7, 4))
							n:add(f_DeliveryStatusType, buf(11, 1))
							local type = buf(11,1):uint()

				      --type is unsuccessful or removed,then display code
							if type == 0x05 or type == 0x04 then
								n:add(f_DeliveryStatusCode, buf(12, 1))
								local code = buf(12,1):uint()

                --code is nack received, then display subcode
								if code == 0x10 then
									--n:add(f_SubCode, buf(13, 2))
									subcode_display(n,buf(13,2))
								end
							end

							n:add(f_acceptedWLProtoVer, buf(15, 1))
							n:add(f_oldestWLProtoVer, buf(16, 1))


			-- WL_DATA_PDU_RX

					elseif wirelineOpcode == 0x09 then
              n:add(f_opcode, buf(0, 1))
              n:add(f_peerid, buf(1, 4))
              n:add(f_wirelineOpcode, buf(5, 1))
              n:add(f_slotNumber, buf(6, 1))
              n:add(f_pduID, buf(7, 4))
							n:add(f_callType, buf(11, 1))
							n:add(f_sourceID, buf(12, 4))
							n:add(f_targetID, buf(16, 4))
							dhAttrib_display(n, buf(20,1))

							proHdrPresent_display(n,buf(21, 1))
							n:add(f_algorithmID, buf(22, 1))
							n:add(f_keyID, buf(23, 1))
							n:add(f_IV, buf(24, 4))
							n:add(f_PayloadLen, buf(28, 2))
							local dataLen1 = buf(28, 2):uint()
							if(data_dis ~= nil) then
							        data_dis:call(buf(30,dataLen1):tvb(), pkt, n)
							end
							----check if CSBK DATA call--------
							local dataCallType = buf(11,1):uint()
							if dataCallType == 0x86 then
								if dataLen1 == 0x0c then
									parseCSBKDATAPayload_display(n,buf(30,dataLen1),buf(30,1))
								else
									n:add("----------incorrect CSBKDATA payload length!!!------------")
								end
							end
							----end check CSBK DATA call-------

							n:add(f_pduPacketCRC, buf(30+dataLen1, 4))
							n:add(f_pduHdrRSSI, buf(34+dataLen1, 2))
							n:add(f_acceptedWLProtoVer, buf(36+dataLen1, 1))
							n:add(f_oldestWLProtoVer, buf(37+dataLen1, 1))

					else
							--print("Unknow wireline data opcode!")

					end	--end if wirelineOpcode
		end     --end of function wldata_display

-- display the Wireline Registration
		function wlregistration_display(wirelineOpcode, n, buf)
		
			-- WL_REGISTRATION_REQUEST
			if wirelineOpcode == 0x01 then
				n:add(f_opcode, buf(0, 1))
	        	n:add(f_peerid, buf(1, 4))
	        	n:add(f_wirelineOpcode, buf(5, 1))
	        	n:add(f_slotNumber, buf(6, 1))
				n:add(f_pduID, buf(7, 4))
              	n:add(f_regID, buf(11, 2))
              	local sts = n:add(f_regChnStatus, buf(13, 1))
				local stsBit = buf(13, 1):uint()
				local b_bit7 = getbit(stsBit,7)
				local b_bit6 = getbit(stsBit,6)
				local b_bit5 = getbit(stsBit,5)
				local strBit7 = ""..b_bit7.."....... : Wireline Chnl Status Registered"
				sts:add(f_wlstsRegAlloc, buf(13,1), strBit7)
				
				local strBit6 = "."..b_bit6.."...... : 3rd Party CSBK: Enable "
				sts:add(f_wlstsRegAlloc, buf(13,1), strBit6)

				if b_bit6 == 1 then
					strBit5 = ".."..b_bit5.."..... : 3rd Party CSBK Path: CSBK Path"
					if b_bit5 == 0 then
						strBit5 = strBit5 .. "(Data Path Selected)"
					end
					sts:add(f_wlstsRegAlloc, buf(13,1), strBit5)
				else
					sts:add("------------- It's nonsense for 3rd Party CSBK bit is Disable ------------")
				end
              	
              	n:add(f_numOfRegEntries, buf(14, 1))
              	entryNum = buf(14,1):uint()
              	for i = 0, entryNum-1 , 1 do
                	n:add(f_addressType, buf(15+12*i, 1))
                    n:add(f_addrRangeStart, buf(16+12*i, 4))
                    n:add(f_addrRangeEnd, buf(20+12*i, 4))
                    n:add(f_voiceAttri, buf(24+12*i, 1))
                    n:add(f_csbkAttri, buf(25+12*i, 1))
                    n:add(f_dataAttri, buf(26+12*i, 1))
				end
				
				-- WL_PROTOCOL_VERSION
              	buf_len = buf:len();
              	n:add(f_acceptedWLProtoVer, buf(buf_len-2, 1))
              	n:add(f_oldestWLProtoVer, buf(buf_len-1, 1))

			-- WL_REGISTRATION_STATUS
         	elseif wirelineOpcode == 0x02 then
	       		n:add(f_opcode, buf(0, 1))
	        	n:add(f_peerid, buf(1, 4))
	        	n:add(f_wirelineOpcode, buf(5, 1))
             	n:add(f_pduID, buf(6, 4))
              	n:add(f_slot1_RegID, buf(10, 2))
              	n:add(f_slot2_RegID, buf(12, 2))
              	n:add(f_regStatusType, buf(14, 1))
              	n:add(f_regStatusCode, buf(15, 1))
 				-- WL_PROTOCOL_VERSION
              	buf_len = buf:len();
              	n:add(f_acceptedWLProtoVer, buf(buf_len-2, 1))
              	n:add(f_oldestWLProtoVer, buf(buf_len-1, 1))

			-- WL_REGISTRATION_GENERAL_OPS
         	elseif wirelineOpcode == 0x03 then
	        	n:add(f_opcode, buf(0, 1))
	        	n:add(f_peerid, buf(1, 4))
	        	n:add(f_wirelineOpcode, buf(5, 1))
	        	n:add(f_slotNumber, buf(6, 1))
	        	n:add(f_pduID, buf(7, 4))
              	n:add(f_regOperationOpcode, buf(11, 1))
				-- WL_PROTOCOL_VERSION
              	buf_len = buf:len();
              	n:add(f_acceptedWLProtoVer, buf(buf_len-2, 1))
              	n:add(f_oldestWLProtoVer, buf(buf_len-1, 1))
		
			-- 	WL_PROTOCOL_VERSION_QUERY_OP	
			elseif wirelineOpcode == 0x04 then
				n:add(f_opcode, buf(0, 1))
	        	n:add(f_peerid, buf(1, 4))
	        	n:add(f_wirelineOpcode, buf(5, 1))
	        	n:add(f_reserved8, buf(6, 1))
	        	n:add(f_queryid, buf(7,4))
				n:add(f_acceptedWLProtoVer, buf(11, 1))
            	n:add(f_oldestWLProtoVer, buf(12, 1))
            	n:add(f_authenid, buf(13, 4))
        		n:add(f_authensig, buf(17, 10))
        		
        	-- WL_PROTOCOL_VERSION_QUERY_RESPONSE_OP
        	elseif wirelineOpcode == 0x05 then    
            	n:add(f_opcode, buf(0, 1))
	        	n:add(f_peerid, buf(1, 4))
	        	n:add(f_wirelineOpcode, buf(5, 1))
	        	n:add(f_reserved8, buf(6, 1))
	        	n:add(f_queryid, buf(7,4))
				n:add(f_acceptedWLProtoVer, buf(11, 1))
            	n:add(f_oldestWLProtoVer, buf(12, 1))
            	
            else
				--print("Unknow wireline data pdu opcode!")
			end
		end     --end of function wlregistration_display



---------------------------------------------------------- wireline dissector -----------------------------------------------------------------

	function p_wireline.dissector(buf, pkt, root)
	
		local opcode = buf(0,1):uint()
		if opcode ~= 0xB2 or buf:len() <12 then
			return  -- error
		end

		local wirelineOpcode = buf(5,1):uint()

		-- update columns
		columns_display(wirelineOpcode, buf, pkt);

		buf_len = buf:len();
		local t = root:add(p_wireline, buf(0, buf_len))

		wlvoice_display(wirelineOpcode, t, buf);
		wldata_display(wirelineOpcode, t, buf);
		wlregistration_display(wirelineOpcode, t, buf);
	end --end of function dissector

	--local udp_port_table = DissectorTable.get("udp.port")
	--local ports = {50000, 50005}

	--for i, port in ipairs(ports) do
	--	udp_port_table:add(port, p_wireline)
	--end

end