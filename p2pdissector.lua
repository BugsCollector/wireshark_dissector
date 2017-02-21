--dissector for P2P
do
	local p_p2p = Proto("p2p", "Cypher P2P")
	local p2p_pdu = {
		[0x04] = "P2P_CALL_ALERT_RESP",
		[0x06] = "P2P_PVT_CALL_RESP",
		[0x07] = "P2P_EMRG_ALRM_REQ",
		[0x08] = "P2P_EMRG_ALRM_RESP",
		[0x0A] = "P2P_RAD_MON_RESP",
		[0x0C] = "P2P_EXT_FNCT_RESP",
		[0x70] = "P2P_XCMP_XNL_DATA",
		[0x80] = "P2P_GRP_VOICE_CALL",
		[0x81] = "P2P_PVT_VOICE_CALL",
		[0x83] = "P2P_GRP_DATA_CALL",
		[0x84] = "P2P_PVT_DATA_CALL",
		[0x85] = "P2P_ALL_SITE_WAKEUP",
		[0x86] = "P2P_REMOTE_INTERRUPT_REQUEST",
		[0x87] = "P2P_GRP_VOICE_PLUS_CALL",
		[0x88] = "P2P_PVT_VOICE_PLUS_CALL",
		[0x05] = "P2P_COMMON_CSBK_RESP",
		[0x61] = "RCM_CALL_TRANS_STATUS",
		[0x62] = "RCM_CALL_CONTROL_NOTIF",
		[0x63] = "RCM_REPEAT_BLOCK",
		[0xC1] = "CP_STATUS_BROADCAST",
		[0xC3] = "CALL_SETUP_MESSAGE",
		[0xC7] = "P2P_ARB_SYNC",
		[0xCA] = "P2P_SITES_REST_INFO",
		[0xCD] = "P2P_CALL_REJECT",
		[0xd0] = "NCS_REQUEST_PDU",
		[0xd1] = "NCS_REPLY_PDU",
		[0xF0] = "RAS_REQUEST",
        [0XF1] = "RAS_RESPONSE",
		[0xf2] = "DBH_BEACON"
	}

	local p2p_pdu_len = {
		[0x04] = 17,
		[0x06] = 17,
		[0x07] = 17,
		[0x08] = 17,
		[0x0A] = 17,
		[0x0C] = 16,
		[0x70] =  7,
		[0x80] = 18,
		[0x81] = 18,
		[0x83] = 18,
		[0x84] = 18,
		[0x85] = 11,
		[0x86] = 16,
		[0x87] = 18,
		[0x88] = 18,
		[0x05] = 60,
		[0x61] = 18,
		[0x62] =  7,
		[0x63] =  6,
		[0xC1] = 25,
		[0xC3] = 53,
		[0xC7] = 7,
		[0xCA] = 7,
		[0xCD] = 14,
		[0xd0] = 14,
		[0xd1] = 30,
		[0xF0] = 5,
        [0XF1] = 5,
		[0xF2] = 6
	}

	local ext_fnct_opcode = {
		[0x00] = "RADIO_CHECK",
		[0x7e] = "RADIO_UNINIHIBIT",
		[0x7f] = "RADIO_INHIBIT",
		[0x80] = "RADIO_CHECH_ACK",
		[0xfe] = "RADIO_UINHIBIT_ACK",
		[0xff] = "RADIO_INHIBIT_ACK",
	}
	  
	local dbh_beacon_cmd = {
		[0x00] = "START_BEACON",
		[0x01] = "LE_BEACON",
		[0x02] = "START_ROAMING_BEACON"
	}  
	
	local slot_num_table = {
		[0x00] = "SLOT_ONE",
		[0x01] = "SLOT_TWO"
	}

	local f_opcode = ProtoField.uint8("p2p.opcode","Opcode",base.HEX, p2p_pdu)
    local f_siteid = ProtoField.uint8("p2p.siteid", "Site Id", base.DEC)
    local f_restid = ProtoField.uint8("p2p.restid", "Rest Id", base.DEC)
    local f_peerid = ProtoField.uint32("p2p.peerid","Peer Id",base.DEC)
    local f_srcpeerid = ProtoField.uint32("p2p.peerid","Source Peer ID",base.DEC)
    local f_srcsiteid = ProtoField.uint8("p2p.srcsiteid", "Source Site ID", base.DEC)
    local f_callsrcid = ProtoField.uint32("p2p.callsrcid", "Call Src ID", base.DEC)
    local f_calltgtid = ProtoField.uint32("p2p.calltgtid", "Call Tgt ID", base.DEC)
    local f_callseqnum = ProtoField.uint8("p2p.callseqnum", "Call Sequence Number", base.HEX)
    local f_ncsseqid = ProtoField.uint32("p2p.ncsseqid", "NCS Sequence ID", base.DEC)
    local f_ncsver = ProtoField.uint8("p2p.ncsver", "NCS Version", base.DEC)
    local f_ncsclientreqtimestmp = ProtoField.uint32("p2p.f_ncsclientreqtimestmp", "NCS Client Request Timestamp", base.DEC)
    local f_ncsservergetquesttimestmp = ProtoField.uint32("p2p.f_ncsclientreqtimestmp", "NCS Server Get Quest Timestamp", base.DEC)
    local f_ncsserverreptimestmp = ProtoField.uint32("p2p.f_ncsclientreqtimestmp", "NCS Server Reply Timestamp", base.DEC)
    local f_ncsslotboundtimestmp = ProtoField.uint32("p2p.f_ncsclientreqtimestmp", "NCS Slot Boundry Timestamp", base.DEC)
    local f_ncshwtimer = ProtoField.uint32("p2p.f_ncsclientreqtimestmp", "NCS HW Timer Switch Rate", base.DEC)
    local f_srcid = ProtoField.uint32("p2p.srcsubscriberid","Source Subscriber Id", base.DEC)
    local f_tgtid = ProtoField.uint32("p2p.tgtsubscriberid","Target Subscriber Id", base.DEC)
    local f_callpriority = ProtoField.uint8("p2p.callpriority", "Call Priority", base.DEC)
    local f_availnumchans = ProtoField.uint8("p2p.availchannum", "Available Channel Number", base.DEC)
    local f_availablechan = ProtoField.uint8("p2p.availchanls", "Available Channels", base.DEC)
    local f_channel = ProtoField.uint8("p2p.channel", "Channel", base.DEC)
    local f_floorcontroltag = ProtoField.uint32("p2p.floorctltag", "Floor Control Tag", base.HEX)
    local f_callcontrolinfo = ProtoField.uint8("p2p.callcontrolinfo", "Call Control Information", base.HEX)
    local f_call_ctrl_info = ProtoField.uint8("p2p.call_control_info", "Call Control Information", base.HEX)
    local f_msgtype = ProtoField.uint8("p2p.msgtype", "Message Type", base.HEX)
    local f_handledchanid = ProtoField.uint16("p2p.handledchanid", "Handled Channel ID", base.HEX)
    local f_lastpacket =  ProtoField.uint8("p2p.lastpackcet", "Last Packet", base.HEX)
    local f_busyrestchnlid = ProtoField.uint8("p2p.busyrestchnlid", "Busy Rest Channel ID", base.DEC)
    local f_wideareatgid = ProtoField.uint8("p2p.wideareatgid", "Wide Area tg ID", base.Dec)
    local f_wideareatalkgrps = ProtoField.uint8("p2p.wideareatalkgrps", "TG IDs of ongoing calls", base.DEC)
    local f_dbh_syncbeacon_cmd = ProtoField.uint8("p2p.dbhsyncbeaconcmd", "DBH Beacon", base.DEC, dbh_beacon_cmd)
    local f_dbh_syncbeacon_num = ProtoField.uint8("p2p.dbhsyncbeaconnum", "DBH Beacon Number", base.DEC)
	local f_dbh_minhopcount =  ProtoField.uint8("p2p.dbhsyncbeaconmihopcount", "DBH Start Beacon Main Chain Min Hop Count", base.DEC)
	local f_dbh_offset2TxBegin =  ProtoField.uint8("p2p.dbhsyncbeaconoffset2txbegin", "DBH Start Beacon Offset2TxBegin", base.DEC)
	local f_lebeacon_hopcnt = ProtoField.uint8("p2p.lebeaconhopcnt", "DBH LE Beacon Hop Count", base.DEC)
	local f_lebeacon_slot = ProtoField.uint8("p2p.lebeaconslot", "DBH LE Beacon Beacon Slot Num", base.DEC, slot_num_table)
	local f_lebeacon_ofn = ProtoField.uint8("p2p.lebeaconofn", "DBH LE Beacon Beacon Original Fork Num", base.DEC)
	local f_lebeacon_srcbrid = ProtoField.uint16("p2p.lebeaconsourcerepeaterid", "Source Repeater ID", base.DEC)
	local f_lebeacon_modebit = ProtoField.uint16("p2p.lebeaconmodebit", "Source Repeater Mode Bits", base.HEX)
	local f_lebeacon_servicebit = ProtoField.uint32("p2p.lebeaconservicebits", "Source Repeater Service Bits", base.HEX)
	
	-- Added for RCM messages
    local f_calltype = ProtoField.uint8("p2p.calltype", "Call Type", base.HEX, {[0x30] = "Preamble Private Data Call", [0x31] = "Preamble Group Data Call", [0x32] = "Preamble Private CSBK Call", [0x33] = "Preamble Group CSBK Call", [0x34] = "Preamble Emergency Call", [0x40] = "Emergency CSBK Alarm Request", [0x41] = "Emergency CSBK Alarm Response", [0x42] = "Emergency Voice Call", [0x43] = "Private Call Request", [0x44] = "Private Call Response", [0x45] = "Call Alert Request", [0x46] = "Call Alert Response", [0x47] = "Radio Check Request", [0x48] = "Radio Check Response", [0x49] = "Radio Inhibit/Disable Request", [0x4A] = "Radio Inhibit/Disable Response", [0x4B] = "Radio Un-Inhibit/Enable Request", [0x4C] = "Radio Un-Inhibit/Enable Response", [0x4D] = "Radio Monitor Request", [0x4E] = "Radio Monitor Response", [0x4F] = "Group Voice Call", [0x50] = "Private Voice Call", [0x51] = "Group Data Call", [0x52] = "Private Data Call", [0x53] = "All Call", [0x54] = "Confirmed Data Response", [0x55] = "Other Calls", [0x56] = "IP Console Radio Un-Inhibit Request", [0x57] = "IP Console Radio Inhibit Request", [0x58] = "IP Console Radio Un-Inhibit Response", [0x59] = "IP Console Radio Inhibit Response", [0x5A] = "Group Phone Call", [0x5B] = "Private Phone Call", [0x5C] = "Phone All Call" })
    
    local f_callsecuritytype = ProtoField.uint8("p2p.callsecuritytype", "Call Security Type", base.HEX, {[0] = "Clear", [1] = "Basic Privacy", [2]="Enhanced Privacy"} )
    local f_featureid = ProtoField.uint8("p2p.featureid", "Feature ID/MFID",  base.HEX, {[0] = "Standard Feature", [0x10]="Motorola Proprietary Feature"} )
    
    local f_callstatus = ProtoField.uint16("p2p.callstatus", "Call Status", base.HEX, {[0] = "Invalid, Reserved", [1] = "Call Started", [2]="Call Ended", [3]="Ended with Race Condition Failure", [4]="Ended with Invalid or Prohibited Call Failure", [5]="Ended with Destination Slot Busy Failure", [6]="Ended with Subscriber Destination Busy Failure", [7]="Ended with All Channels Busy Failure", [8]="Ended with OTA Repeat Disable Failure", [9]="Ended with Signal Interference Failure", [10]="Ended with CWID In Progress Failure", [12]="Ended with TOT Expiry, Premature Call End Failure", [13]="Ended with Transmit Interrupted Call Failure", [14]="Ended with Higher Priority Call Takeover Failure", [15]="Ended with Other Unknown Failure"} )
    
    local f_callstate1 = ProtoField.uint8("p2p.callstate1", "Call State 1",  base.DEC, {[1] = "REPEAT", [2] = "IDLE", [3]="SLOT DISABLED",})
    local f_callstate2 =  ProtoField.uint8("p2p.callstate2", "Call State 2",  base.DEC, {[1] = "REPEAT", [2] = "IDLE", [3]="SLOT DISABLED",} )
    local f_rptblockstatus = ProtoField.uint8("p2p.rptcallstatus", "Repeat Block Status",  base.DEC, {[1] = "FCC Type 1 Started", [2] = "FCC Type 1 Ended", [3]="FCC Type 2 Started", [4]="FCC Type 2 Ended", [5]="CWID Started", [6]="CWID Ended"} )
    
    local f_emergency = ProtoField.uint8("p2p.emergency", "Emergency", base.HEX)

    local f_pduseqnum = ProtoField.uint32("p2p.pduseqnum", "PDU Sequence Number", base.DEC)
    local f_subscriberid = ProtoField.uint32("p2p.subscriberid", "Subscriber Id", base.DEC)
    local f_regdereg = ProtoField.uint8("p2p.regdereg", "REG DREG", base.DEC)
    
    local f_talkgroupid = ProtoField.uint32("p2p.talkgroupid", "Talk Group Id", base.DEC)
    local f_affdisaff = ProtoField.uint8("p2p.affdisaff", "AFF DISAFF", base.DEC)
    local f_reciprocate = ProtoField.uint8("p2p.reciprocate", "Reciprocate", base.DEC)
    --	local f_srcid = ProtoField.uint32("p2p.srcsubscriberid", "SRCSUBSCRIBERID", base.DEC)
    --	local f_tgtid = ProtoField.uint32("p2p.tgtsubscriberid", "TGTSUBSCRIBERID", base.DEC)
    
    local f_callalertresp = ProtoField.uint8("p2p.callalertresp", "Call Alert Response", base.HEX, {[0x00] = "ACK", [0x01] = "NACK",})
    local f_answerresp = ProtoField.uint8("p2p.answerresp", "Private Call Response", base.HEX, {[0x20] = "PROCEED", [0x21] = "DENY",})
    local f_emrgalrmresp = ProtoField.uint8("p2p.emrgalrmresp", "Emergency Alarm Resp", base.HEX, {[0x00] = "ACK", [0x01] = "NACK",})
    local f_easn = ProtoField.uint8("p2p.easn", "Emergency Sequence Number", base.DEC)
    local f_txmultiplier = ProtoField.uint8("p2p.txmultiplier", "TX Multiplier", base.HEX)
    local f_radmonresp = ProtoField.uint8("p2p.radmonresp", "Rad Monitor Response", base.HEX, {[0x00] = "ACK", [0x01] = "NACK",})
    local f_extfnctopcode = ProtoField.uint8("p2p.extfnctopcode", "Extended Function Opcode", base.HEX, ext_fnct_opcode)
    local f_callresp = ProtoField.uint8("p2p.callresp", "CALL Response", base.HEX)
    local f_channelnum =  ProtoField.uint8("p2p.channelnum", "The Channel Number", base.DEC)
    local f_xnllength =  ProtoField.uint8("p2p.xnllength", "The Length of XNL XCMP", base.DEC)
    local f_wakeuptype = ProtoField.uint8("p2p.wakeupType", "The wakeup type - beacon or csbk wakeup type", base.Dec, {[0x01] = "All Site wakeup", [0x02] = "Wakeup Beacon",})
    
    -- csbk common response
    --local f_pduseqnum = ProtoField.uint32("p2ppduseqnum", "PDU Sequence Number", base.HEX)
    local f_commonCSBKRespType = ProtoField.uint8("p2p.commonCSBKRespType", "Common CSBK Reponse Type", base.HEX, {[0x00] = "Unknown", [0x05] = "Private Call Response", [0x1F] = "Call Alert Response", [0x27] = "Emergency Alarm Response", [0x29] = "Radio Monitor Response", })
    local f_commonCSBKInfoResp = ProtoField.uint8("p2p.commonCSBKInfoResp", "CSBK Info Response", base.HEX, { [0x20]="ACK",[0x26] = "NACK",} )
    
    -- authentication
    local f_auth = ProtoField.bytes("p2p.auth", "Authentication", base.HEX)
    
    -- Added for TI
    local f_ttSequence = ProtoField.uint8("p2p.ttSequence", "TI TT Sequence", base.DEC)
    local f_tiSrcid = ProtoField.uint32("p2p.tiSrcid","TI source ID",base.DEC)
    local f_bsOpcode = ProtoField.uint8("p2p.bsOpcode", "TI BS Opcode", base.DEC)
    
    local f_sitejoin_talkgroups = ProtoField.bytes("le.sitejointalkgroups", "Wide Area Talk Groups", base.HEX)
    local f_sitejoin_srcofcalls = ProtoField.uint16("le.sitejoinsrcofcalls", "Source of Calls", base.HEX)
    local f_sitejoin_tgs = ProtoField.uint8("le.sitejointgs", "Talkgroup Statuses", base.HEX)
    local f_sitejoin_srcofcallsspec = ProtoField.uint8("le.sitejoinsrcspec", "Specific src", base.DEC)

    p_p2p.fields = {f_opcode, f_peerid, f_srcpeerid, f_callseqnum,
        f_srcid, f_tgtid,  f_callpriority, f_floorcontroltag, f_callcontrolinfo,
        f_pduseqnum, f_subscriberid, f_regdereg, f_siteid, f_msgtype,
        f_talkgroupid, f_affdisaff, f_reciprocate, f_handledchanid,
        f_callalertresp,f_emergency, f_restid,
        f_answerresp,
        f_emrgalrmresp,
        f_easn,
        f_txmultiplier,
        f_radmonresp,
        f_ncsseqid,
        f_ncsver,
        f_ncsclientreqtimestmp,
        f_ncsservergetquesttimestmp,
        f_ncsserverreptimestmp,
        f_ncsslotboundtimestmp,
        f_ncshwtimer,
        f_callresp,
        f_channelnum,
        f_xnllength,
        f_wakeuptype,
        f_commonCSBKRespType,
        f_commonCSBKInfoResp,f_auth,
        f_calltype, f_callsecuritytype, f_featureid, f_callstatus,
        f_callstate1, f_callstate2,
        f_rptblockstatus, f_availnumchans, f_availablechan, f_channel,
        f_ttSequence, f_tiSrcid, f_bsOpcode, f_busyrestchnlid, f_wideareatgid,
        f_wideareatalkgrps, f_srcsiteid, f_callsrcid, f_calltgtid,f_sitejoin_talkgroups,f_sitejoin_srcofcalls, 
		f_dbh_syncbeacon_cmd, f_dbh_syncbeacon_num, f_dbh_minhopcount, f_dbh_offset2TxBegin, f_lebeacon_hopcnt, f_lebeacon_slot, f_lebeacon_ofn, f_lebeacon_srcbrid, f_lebeacon_modebit, f_lebeacon_servicebit }
        
    local audio_dis = Dissector.get("data")
        
    --p2p voice packet 
    function p_p2p.dissector(buf,pkt,root)
    
    -- variables for info field
    local opid = buf(0,1):uint()
    local peerid = nil
    local buf_len = buf:len()
    
    local t	= nil
    
    -- Decipher Wide Area Talk Groups fields
    function wide_tgs_decode(n, buf)
    
        local byte = 0
        while byte < 16 do
            local tgID = buf(byte,1):uint()
            local tgdescript = "Talk Group " .. byte+1 .. " ID: " .. tgID
            n:add(f_sitejoin_tgs, buf, tgdescript)
            byte = byte + 1
        end
    end
    
    -- Src of Calls decode
    function src_calls_decode(n,buf)
        local bit = 1
        local count = 16

        while bit <= 16 do
            local src = getbit(buf:uint(), bit)
            local descript = ""

            if(bit <= 4) then
                descript = src .. ": RESERVED"
            elseif(src == 1) then
                descript = src .. ": Call initiated from src repeater on chnl " .. count
            else
                descript = src .. ": Call NOT initiated from src repeater on chnl " .. count
            end
            n:add(f_sitejoin_srcofcallsspec, buf, descript)
            bit = bit + 1
            count = count - 1
        end
    end
        
    pkt.cols.protocol:set("P2P")
    if (p2p_pdu_len[opid] ~= nil) and (buf_len >= p2p_pdu_len[opid]) then
        if opid == 0x04 or opid == 0x06 or opid == 0x08 or opid == 0x0A then
            t = root:add(p_p2p, buf(0, 17))
            t:add(f_opcode, buf(0,1))
            t:add(f_peerid, buf(2, 3))
            peerid = buf(2, 3):uint() -- for info field
            t:add(f_pduseqnum, buf(5, 4))
            t:add(f_srcid, buf(9, 3))
            t:add(f_tgtid, buf(12, 3))
            t:add(f_callresp, buf(15, 1))
            t:add(f_channelnum, buf(16, 1))
    
            if buf_len == 17+10 then
                t:add(f_auth, buf(17, 10))
            end
    
        elseif opid == 0x07 then
            t = root:add(p_p2p, buf(0, 17))
            t:add(f_opcode, buf(0,1))
            t:add(f_peerid, buf(2, 3))
            peerid = buf(2, 3):uint() -- for info field
            t:add(f_pduseqnum, buf(5, 4))
            t:add(f_srcid, buf(9, 3))
            t:add(f_tgtid, buf(12, 3))
            t:add(f_easn, buf(15, 1))
            t:add(f_channelnum, buf(16, 1))
            if buf_len == 17+10 then
                t:add(f_auth, buf(17, 10))
            end
            
        elseif opid == 0xC1 then  --CP_STATUS_BROADCAST
            if buf_len == 34+10 then
                t = root:add(p_linkest, buf(0, 44))
            else
                t = root:add(p_linkest, buf(0, 5))
            end
            t:add(f_opcode, buf(0, 1))
            t:add(f_peerid, buf(2, 3))
            peerid = buf(2, 3):uint() -- for info field
            t:add(f_sequencenumber, buf(5, 2))
            t:add(f_timestamp, buf(7,4))
            t:add(f_preferencelevel, buf(11, 1))
            t:add(f_restchannelinfo, buf(12, 1))
            t:add(f_oldrestchannelID, buf(13,1))
            t:add(f_currentrestchannelID, buf(14, 1))
            t:add(f_peerIDofnewrestchannel, buf(15,4))
            t:add(f_newrestchannelID, buf(19, 1))
            t:add(f_channelID, buf(20, 1))
            t:add(f_channelstatus, buf(21, 1))
            t:add(f_calltype, buf(22, 1))
            t:add(f_srcid, buf(23, 2))
            t:add(f_tgtid, buf(25, 2))
            t:add(f_channelID, buf(27, 1))
            t:add(f_channelstatus, buf(28, 1))
            t:add(f_calltype, buf(29, 1))
            t:add(f_srcid, buf(30, 2))
            t:add(f_tgtid, buf(32, 2))
            
            if buf_len == 34+10 then
                t:add(f_auth, buf(34, 10))
            end
            
        elseif opid == 0x0C then 		--P2P_EXT_FNCT_RESP
            t = root:add(p_p2p, buf(0, 16))
            t:add(f_opcode, buf(0, 1))
            t:add(f_peerid, buf(2, 3))
            peerid = buf(2, 3):uint() -- for info field
            t:add(f_pduseqnum, buf(5, 4))
            t:add(f_srcid, buf(9, 3))
            t:add(f_tgtid, buf(12, 3))
            t:add(f_extfnctopcode, buf(15, 1))
            if buf_len == 16+10 then
                t:add(f_auth, buf(16, 10))
            end
            
        elseif opid == 0xc3 then            -- Call Setup Message
            t = root:add(p_p2p, buf(0, p2p_pdu_len[opid]))            
            t:add(f_opcode, buf(0, 1))
            t:add(f_siteid, buf(1, 1))
            t:add(f_peerid, buf(2, 3))
            peerid = buf(2, 3):uint() -- for info field
            t:add(f_callseqnum, buf(5, 1))
            t:add(f_msgtype, buf(6,1))
            t:add(f_availnumchans, buf(7,1))
             
            local tc = t:add(f_availablechan, 16)
            tc:add(f_channel, buf(8,1))
            tc:add(f_channel, buf(9,1))
            tc:add(f_channel, buf(10,1))
            tc:add(f_channel, buf(11,1))
            tc:add(f_channel, buf(12,1))
            tc:add(f_channel, buf(13,1))
            tc:add(f_channel, buf(14,1))
            tc:add(f_channel, buf(15,1))
            tc:add(f_channel, buf(16,1))
            tc:add(f_channel, buf(17,1))
            tc:add(f_channel, buf(18,1))
            tc:add(f_channel, buf(19,1))
            tc:add(f_channel, buf(20,1))
            tc:add(f_channel, buf(21,1))
            tc:add(f_channel, buf(22,1))
            tc:add(f_channel, buf(23,1))
            
            local t_callctrlinfo2 = t:add(f_callcontrolinfo, buf(24,1))
			local callctrlinfo =  buf(24,1):uint()
			local b_bit7 = getbit(callctrlinfo,7)
			local b_bit6 = getbit(callctrlinfo,6)
			local b_bit5 = getbit(callctrlinfo,5)
			local b_bit4 = getbit(callctrlinfo,4)	
			local b_bit1 = getbit(callctrlinfo,1)	
			local b_bit0 = getbit(callctrlinfo,0)	
			local strBit7 = nil
			local strBit6 = nil
			local strBit5 = nil
			local strBit4 = nil			
            local strBit1 = nil			
			local strBit0 = nil
			strBit7 = ""..b_bit7.."....... = Secure " 
			t_callctrlinfo2:add(f_call_ctrl_info, buf(17,1), strBit7)		
			strBit6 = "."..b_bit6.."...... = Last Package " 
			t_callctrlinfo2:add(f_call_ctrl_info, buf(17,1), strBit6)		
			strBit5 = ".."..b_bit5.."..... = Channel Number " 
			t_callctrlinfo2:add(f_call_ctrl_info, buf(17,1), strBit5)
			strBit4 = "..."..b_bit4..".... = Phone " 
			t_callctrlinfo2:add(f_call_ctrl_info, buf(17,1), strBit4)
			strBit1 = "......"..b_bit1..". = EGPS Win ID " 
			t_callctrlinfo2:add(f_call_ctrl_info, buf(17,1), strBit1)
			strBit0 = "......."..b_bit0.." = Phone Master " 
			t_callctrlinfo2:add(f_call_ctrl_info, buf(17,1), strBit0)
			
            t:add(f_srcid, buf(25, 3))
            t:add(f_tgtid, buf(28, 3))
            t:add(f_calltype, buf(31,1))
            t:add(f_floorcontroltag, buf(32, 4))
            t:add(f_busyrestchnlid, buf(36, 1))
            -- Wide area talk groups in ongoing calls
            local tg = t:add(f_wideareatalkgrps, 16)
            tg:add(f_wideareatgid, buf(37, 1))
            tg:add(f_wideareatgid, buf(38, 1))
            tg:add(f_wideareatgid, buf(39, 1))
            tg:add(f_wideareatgid, buf(40, 1))
            tg:add(f_wideareatgid, buf(41, 1))
            tg:add(f_wideareatgid, buf(42, 1))
            tg:add(f_wideareatgid, buf(43, 1))
            tg:add(f_wideareatgid, buf(44, 1))
            tg:add(f_wideareatgid, buf(45, 1))
            tg:add(f_wideareatgid, buf(46, 1))
            tg:add(f_wideareatgid, buf(47, 1))
            tg:add(f_wideareatgid, buf(48, 1))
            tg:add(f_wideareatgid, buf(49, 1))
            tg:add(f_wideareatgid, buf(50, 1))
            tg:add(f_wideareatgid, buf(51, 1))
            tg:add(f_wideareatgid, buf(52, 1))
            
        elseif opid == 0xc7 then	-- P2P AR Beacon Sync
            t = root:add(p_p2p, buf(0,7))
            t:add(f_opcode, buf(0, 1))
            t:add(f_peerid, buf(1, 4))
            peerid = buf(1, 4):uint() -- for info field
            t:add(f_msgtype, buf(5, 1))
            t:add(f_siteid, buf(6, 1))
            
        elseif opid == 0xca then	-- Site Rest Info
            t = root:add(p_p2p, buf(0,buf:len()))
            t:add(f_opcode, buf(0, 1))
            t:add(f_peerid, buf(1, 4))
            peerid = buf(1, 4):uint() -- for info field
            t:add(f_siteid, buf(5, 1))
            t:add(f_restid, buf(6, 1))
            local g = t:add(f_sitejoin_talkgroups, buf(7,16))
            wide_tgs_decode(g, buf(7,16))                
            local m = t:add(f_sitejoin_srcofcalls, buf(23,2))
            src_calls_decode(m, buf(23, 2))
            
        elseif opid == 0xCD then	-- P2P_CALL_REJECT
            t = root:add(p_p2p, buf(0,p2p_pdu_len[opid]))
            t:add(f_opcode, buf(0, 1))
            t:add(f_msgtype, buf(1, 1))
            t:add(f_srcpeerid, buf(2, 3))
            peerid = buf(2, 3):uint() -- for info field
            t:add(f_pduseqnum, buf(5, 1))
            t:add(f_srcsiteid, buf(6, 1))
            t:add(f_callsrcid, buf(7, 3))
            t:add(f_calltgtid, buf(10, 3))
            t:add(f_calltype,  buf(13, 1))
            
        elseif opid == 0x70 then 		--P2P_XCMP_XNL_DATA
            --print("p2p xcmp xnl data")
            t = root:add(p_p2p, buf(0,7))
            t:add(f_opcode, buf(0, 1))
            t:add(f_peerid, buf(1, 4))
            --peerid = buf(1, 4):uint() -- for info field
            t:add(f_xnllength, buf(5, 2))
            
            local xnl_dissector = Dissector.get("xnl")
            if xnl_dissector ~= nil then
                xnl_dissector:call(buf(7):tvb(), pkt, root)
            else
                print("No xcmp dissector found")
            end
            
        elseif opid == 0x80 or opid == 0x81 or opid == 0x83 or opid == 0x84 or opid == 0x87 or opid == 0x88 or opid == 0x7f or opid == 0x7e then   	 --P2P VOICE PACKET
            local len = buf_len
            t = root:add(p_p2p, buf(0,len))
            t:add(f_opcode, buf(0, 1))
            t:add(f_peerid, buf(1, 4))
            peerid = buf(1, 4):uint() -- for info field
            t:add(f_callseqnum, buf(5, 1))
            t:add(f_srcid, buf(6, 3))
            t:add(f_tgtid, buf(9, 3))
            t:add(f_callpriority, buf(12, 1))
            ---t:add(f_secure, buf(15,1))
            t:add(f_floorcontroltag, buf(13, 4))      
			
            local t_callctrlinfo = t:add(f_callcontrolinfo, buf(17,1)) 
			local callctrlinfo =  buf(17,1):uint()
			local b_bit7 = getbit(callctrlinfo,7)
			local b_bit6 = getbit(callctrlinfo,6)
			local b_bit5 = getbit(callctrlinfo,5)
			local b_bit4 = getbit(callctrlinfo,4)	
			local b_bit1 = getbit(callctrlinfo,1)	
			local b_bit0 = getbit(callctrlinfo,0)	
			local strBit7 = nil
			local strBit6 = nil
			local strBit5 = nil
			local strBit4 = nil			
            local strBit1 = nil			
			local strBit0 = nil
			strBit7 = ""..b_bit7.."....... = Secure " 
			t_callctrlinfo:add(f_call_ctrl_info, buf(17,1), strBit7)		
			strBit6 = "."..b_bit6.."...... = Last Package " 
			t_callctrlinfo:add(f_call_ctrl_info, buf(17,1), strBit6)		
			strBit5 = ".."..b_bit5.."..... = Channel Number " 
			t_callctrlinfo:add(f_call_ctrl_info, buf(17,1), strBit5)
			strBit4 = "..."..b_bit4..".... = Phone " 
			t_callctrlinfo:add(f_call_ctrl_info, buf(17,1), strBit4)
			strBit1 = "......"..b_bit1..". = EGPS Win ID " 
			t_callctrlinfo:add(f_call_ctrl_info, buf(17,1), strBit1)
			strBit0 = "......."..b_bit0.." = Phone Master " 
			t_callctrlinfo:add(f_call_ctrl_info, buf(17,1), strBit0)
			
			---t:add(f_lastpacket, buf(20,1))
            ---audio_dis:call(buf(21):tvb(), pkt, root)
            
            local rtp_dissector = Dissector.get("rtp")
            if rtp_dissector ~= nil then
                rtp_dissector:call(buf(18):tvb(), pkt, t)
            else
                print("No standard rtp dissector")
            end
            --copy code here again--
            pkt.cols.protocol:set("P2P")
            --pkt.cols.info:set(info)
            --end--
            
            if opid == 0x80 or opid == 0x81 or opid == 0x87 or opid == 0x88 then
                local f2burstvoice_dissector = Dissector.get("f2burstvoice")
                if f2burstvoice_dissector ~= nil then
                    f2burstvoice_dissector:call(buf(30):tvb(), pkt, t)
                else
                    --print("No Voice Burst dissector")
                    audio_dis:call(buf(30):tvb(), pkt, t)
                end
                if opid == 0x87 or opid == 0x88 then
                    local length = buf(31,1):uint()
                    if length >= 20 then
                        t:add(f_ttSequence, buf(32+length,1))
                        t:add(f_tiSrcid, buf(33+length,3))
                        t:add(f_bsOpcode, buf(36+length))
                    end
                    --need to decode the last 5 bytes of the packet
                    --this may be difficult because the size of the data changes
                    --how do we determine where to start decoding this
                    --ask anthony later it might have to be a part of voice decoding
                end
            end
            
            if opid == 0x83 or opid == 0x84 or opid == 0x7f or opid == 0x7e then
                local f2burstdata_dissector = Dissector.get("f2burstdata")
                if f2burstdata_dissector ~= nil then
                    f2burstdata_dissector:call(buf(30):tvb(), pkt, t)
                else
                    --print("No Data Burst dissector")
                    audio_dis:call(buf(33):tvb(), pkt, t)
                end
            end
            
            --audio_dis:call(buf(34):tvb(), pkt, t)
            
            
            elseif opid == 0x85 then
                t = root:add(p_p2p, buf(0, 11))
                t:add(f_opcode, buf(0,1))
                t:add(f_peerid, buf(1, 4))
                peerid = buf(1, 4):uint() -- for info field
                t:add(f_pduseqnum, buf(5, 4))
                t:add(f_channelnum, buf(9, 1))
                t:add(f_wakeuptype, buf(10, 1))
            
                if buf_len == 11+10 then
                    t:add(f_auth, buf(11, 10))
                end
            
            elseif opid == 0x86 then		--REMOTE INTERRUPT REQUEST
                t = root:add(p_p2p, buf(0, 16))
                t:add(f_opcode, buf(0,1))
                t:add(f_peerid, buf(1, 4))
                peerid = buf(1, 4):uint() -- for info field
                t:add(f_pduseqnum, buf(5, 4))
                t:add(f_srcid, buf(9, 3))
                t:add(f_tgtid, buf(12, 3))
                t:add(f_channelnum, buf(15, 1))
                if buf_len == 16+10 then
                    t:add(f_auth, buf(16, 10))
                end
                elseif opid == 0x05 then   -- common csbk opcode
                if buf_len == 60 +10 then
                    t = root:add(p_p2p, buf(0, 70))
                else
                    t = root:add(p_p2p, buf(0, 60))
                end
            
                t:add(f_opcode,	buf(0, 1))
                t:add(f_peerid, buf(1, 4))
                peerid = buf(1, 4):uint() -- for info field
                t:add(f_pduseqnum, buf(5, 4))
                t:add(f_commonCSBKRespType, buf(9,1))
                t:add(f_srcid, buf(10, 3))
                t:add(f_tgtid, buf(13, 3))
                t:add(f_commonCSBKInfoResp, buf(16,1))
                t:add(f_channelnum, buf(17, 1))
                
                if buf_len == 60+10 then
                    t:add(f_auth, buf(60, 10))
                end
                
                -- f2 burst data
                local f2burstdata_dissector = Dissector.get("f2burstdata")
                if f2burstdata_dissector ~= nil then
                    f2burstdata_dissector:call(buf(18):tvb(), pkt, t)
                else
                    --print("No Data Burst dissector")
                    audio_dis:call(buf(33):tvb(), pkt, t)
                end
                -- end f2 burst data             
            
            elseif opid == 0x61 then
                -- RCM Call Transmission opcode
                if buf_len == 26 then
                    t = root:add(p_p2p, buf(0, 26))
                end
            
                t:add(f_opcode,	buf(0, 1))
                t:add(f_siteid, buf(1, 1))
                t:add(f_peerid, buf(2, 3))
                peerid = buf(2, 3):uint() -- for info field
                t:add(f_srcpeerid, buf(5, 4))
                t:add(f_pduseqnum, buf(9, 4))
                t:add(f_channelnum, buf(13, 1))
                t:add(f_callstatus, buf(14,2))
                t:add(f_srcid, buf(16, 3))
                t:add(f_tgtid, buf(19, 3))
                t:add(f_calltype, buf(22,1))
                t:add(f_callpriority, buf(23,1))
                t:add(f_callsecuritytype, buf(24,1))
                t:add(f_featureid, buf(25,1))              
            
            elseif opid == 0x62 then
                -- RCM Call Control Notification opcode
                if buf_len == 7 then
                    t = root:add(p_p2p, buf(0, 7))
                end
                
                t:add(f_opcode,	buf(0, 1))
                t:add(f_siteid, buf(1, 1))
                t:add(f_peerid, buf(2, 3))
                peerid = buf(2, 3):uint() -- for info field
                t:add(f_callstate1, buf(5, 1))
                t:add(f_callstate2, buf(6, 1))
            
            elseif opid == 0x63 then
                -- RCM Repeat Blocked Indication
                if buf_len == 6 then
                    t = root:add(p_p2p, buf(0, 6))
                end
            
                t:add(f_opcode,	buf(0, 1))
                t:add(f_siteid, buf(1, 1))
                t:add(f_peerid, buf(2, 3))
                peerid = buf(2, 3):uint() -- for info field
                t:add(f_rptblockstatus, buf(5, 1))
            
            elseif opid == 0xd0 then -- NCS_REQUEST_PDU
                t = root:add(p_p2p, buf(0, 14))
                t:add(f_opcode, buf(0, 1))
                t:add(f_siteid, buf(1, 1))
                t:add(f_peerid, buf(2, 3))
                t:add(f_ncsver, buf(5, 1))
                peerid = buf(2, 3):uint() -- for info field
                t:add(f_ncsseqid, buf(6,4))
                t:add(f_ncsclientreqtimestmp, buf(10,4))
            
            elseif opid == 0xd1 then -- NCS_REPLY_PDU
                t = root:add(p_p2p, buf(0, 30))
                t:add(f_opcode, buf(0, 1))
                t:add(f_siteid, buf(1, 1))
                t:add(f_peerid, buf(2, 3))
                peerid = buf(2, 3):uint() -- for info field
                t:add(f_ncsver, buf(5,1))
                t:add(f_ncsseqid, buf(6,4))
                t:add(f_ncsclientreqtimestmp, buf(10,4))
                t:add(f_ncsservergetquesttimestmp, buf(14,4))
                t:add(f_ncsserverreptimestmp, buf(18,4))
                t:add(f_ncsslotboundtimestmp, buf(22,4))
                t:add(f_ncshwtimer, buf(26,4))
				
	    elseif opid == 0xf2 then -- DBH_BEACON
	    	t = root:add(p_p2p, buf(0, buf_len))
			t:add(f_opcode, buf(0, 1))
			peerid = buf(1,4):uint()
			t:add(f_peerid, buf(1, 4))
			t:add(f_dbh_syncbeacon_cmd, buf(5,1))
			local cmd = buf(5,1):uint()
			if cmd == 0x0 then	-- Start Beacon
				t:add(f_dbh_minhopcount, buf(6,1))
				t:add(f_dbh_offset2TxBegin, buf(7,1))
			elseif cmd == 0x1 then -- LE Beacon	
				t:add(f_dbh_syncbeacon_num, buf(6,1))
				local num = buf(6,1):uint()
				if num > 0 then
					for i = 0, num-1, 1 do
						local byte1 = buf(7+4*i,1):uint()
						
						local hopcnt = bit.band(byte1, 0xf)
						t:add(f_lebeacon_hopcnt, buf(7+4*i,1), hopcnt)
						
						local slot = bit.rshift(bit.band(byte1, 0x10), 4)
						t:add(f_lebeacon_slot, buf(7+4*i,1), slot)
						
						local ofn = bit.rshift(bit.band(byte1, 0xE0), 5)
						t:add(f_lebeacon_ofn, buf(7+4*i,1), ofn)
						
						t:add(f_lebeacon_srcbrid, buf(8+4*i,2)) 
						mode_bits_disp_ipsc_cap(t, buf(10+4*i,2))
						service_bits_disp(t, buf(12+4*i,3), 1, 0)
						--t:add(f_lebeacon_modebit, buf(10+4*i,2))
						--t:add(f_lebeacon_servicebit, buf(12+4*i,3))
					end
				end
			end
			end
        end
            
        -- info field
        local info = nil
        if (buf_len >= 5) and (opid ~= nil) and (peerid ~= nil) then
		        info = string.format("[%02X]%-31s Src Peer=%-6u	Len=%-3u",
		        opid,
		        ((p2p_pdu[opid]	~= nil)	and	p2p_pdu[opid] or "Unknown P2P opcode!")	,
		        peerid,
		        buf_len
		        )
        end
        
	if info ~= nil then
		if (p2p_pdu_len[opid] ~= nil) and (buf_len < p2p_pdu_len[opid]) then
			info	= info .. "	Wrong message length!"
		end
	end
        
       	if info ~= nil then
        	pkt.cols.info:set(info)
       	end
        
        -- for invalid message type
        if t == nil	then
            if buf_len >= 5 then
                t =	root:add(p_linkest,	buf(0, 5))
                t:add(f_opcode,	buf(0, 1))
                t:add(f_peerid,	buf(1, 4))
            end
        end       
    end
        
    --local udp_encap_table = DissectorTable.get("udp.port")
    --udp_encap_table:add(50000,p_p2p)  --replace with the real port used by p2p   
end
