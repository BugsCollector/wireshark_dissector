--dissector for link establishment
do
    p_linkest = Proto("le", "Cypher Link Establishment")
    le_pdu = {
        [0x90] = "LE_INTERM_REGISTRATION_REQUEST",
        [0x91] = "LE_INTERM_REGISTRATION_RESPONSE",
        [0x92] = "LE_NOTIFICATION_MAP_REQUEST",
        [0x93] = "LE_NOTIFICATION_MAP_BROADCAST",
        [0x94] = "LE_PEER_REGISTRATION_REQUEST",
        [0x95] = "LE_PEER_REGISTRATION_RESPONSE",
        [0x96] = "LE_INTERM_KEEP_ALIVE_REQUEST",
        [0x97] = "LE_INTERM_KEEP_ALIVE_RESPONSE",
        [0x98] = "LE_PEER_KEEP_ALIVE_REQUEST",
        [0x99] = "LE_PEER_KEEP_ALIVE_RESPONSE",
        [0x9a] = "LE_DEREGISTRATION_REQUEST",
        [0x9b] = "LE_DEREGISTRATION_RESPONSE",
        [0x9e] = "LE_PEER_KEEP_ALIVE_BROADCAST",
        [0x9f] = "LE_DEREGISTRATION_PROXY_BROADCAST",
        [0x30] = "LE_SAT_INTERM_REG_REQ",
        [0x31] = "LE_INTERM_DV_KEEP_ALIVE_REQ",
        [0x32] = "LE_RRP_SATELLITE_ID_MAP",
        [0x33] = "LE_DIGITALVOTING_MAP_BROADCAST",
        [0xCC] = "LE_SITE_KEEP_ALIVE_BROADCAST",
		[0xA0] = "LE_BACKHAUL_DISCOVER",
        [0xA5] = "LE_SATELLITE_BURST",
        
    }

    le_pdu_len = {
        [0x90] = 8,
        [0x91] = 10,
        [0x92] = 6,
        [0x93] = 5, -- 8+11 (used to be 20)
        [0x94] = 5,
        [0x95] = 5,
        [0x96] = 8,
        [0x97] = 8,
        [0x98] = 10,
        [0x99] = 10,
        [0x9a] = 5,
        [0x9b] = 5,
        [0x9e] = 50,
        [0x9f] = 13,
        [0x30] = 19,
        [0x31] = 16,
        [0x32] = 12,
        [0x33] = 12,
        [0xCC] = 40,
		[0xA0] = 19,
        [0xA5] = 25
    }

    optiontype = {
        [0] = "Force",
        [1] = "Update",
    }

    slotassignment = {
        [0x00] = "No Call Support",
        [0x01] = "Local Site Call Support Only",
        [0x02] = "Multi-site Call Support",
        [0x03] = "Reserved",
    }

    slotassignmentForLCP = {
        [0x00] = "No Call Support",
        [0x01] = "LCP Trunked Repeater Support",
        [0x02] = "LCP Local Area Data Revert Support",
        [0x03] = "LCP Wide Area Data Revert Support",
    }

    peerstatus = {
        [0x00] = "Disabled",
        [0x01] = "Enabled",
        [0x02] = "Knocked Down",
        [0x03] = "Locked",
    }

    gateway_status = {
        [0x00] = "RESERVED",
        [0x01] = "Fault Condition",
        [0x02] = "RESERVED?",
        [0x03] = "RESERVED",
        [0x04] = "RESERVED",
    }

    peerservices = {
        [0x00] = "Primary Intermediary",
        [0x01] = "Secondary Intermediary",
        [0x02] = "Voice Call Support",
        [0x03] = "Data Call Support",
        [0x04] = "Packet Authentication",
        [0x05] = "XNL Slave Device",
        [0x06] = "XNL Master Device",
        [0x07] = "XNL Master Connection Status",
        [0x08] = "Slot 1 Assignment Continue Type",
        [0x09] = "Slot 1 Assignment Continue Type",
        [0x0A] = "Slot 2 Assignment Continue Type",
        [0x0B] = "Slot 2 Assignment Continue Type",
        [0x0C] = "System Trunking Controller Interface",
        [0x0D] = "Remote 3rd Party Console Application",
        [0x0E] = "Repeater Call Monitoring",
        [0x0F] = "CSBK Call",
        [0x10] = "Passive Device",
        [0x11] = "Remote Programming",
        [0x12] = "Virtual Peer",
        [0x13] = "Slot 1 Phone Gateway",
        [0x14] = "Slot 2 Phone Gateway",
        [0x15] = "RAS Capability",
        [0x16] = "Single Frequency Repeater",
        [0x17] = "MOTOTRBO Gateway",
        [0x18] = "MOTOTRBO Gateway Status",
        [0x19] = "MOTOTRBO Gateway Status",
        [0x1A] = "Wireline Voice CFS",
        [0x1B] = "Wireline Service Enabled (Slot1)",
        [0x1C] = "Wireline Service Enabled (Slot2)",
        [0x1D] = "Wireline Data CFS",
        [0x1E] = "Digital Voting",
        [0x1F] = "RESERVED"

    }
	
	local slot_num_table = {
		[0x00] = "SLOT_ONE",
		[0x01] = "SLOT_TWO",
		[0x02] = "SLOT_BOTH"
	}

    peerservicesForLCP = { -- TODO: Might need to update functions that use this
        [0x00] = "Voice Call",
        [0x01] = "Data Call",
        [0x02] = "CSBK Call",
        [0x03] = "Repeater Call Monitoring",
        [0x04] = "Packet Authentication",
        [0x05] = "XNL Connection Status",
        [0x06] = "Slot 1 Phone Gateway",
        [0x07] = "Slot 2 Phone Gateway",
        [0x08] = "RAS Capability",
        -- 0x09 and 0x0A correspond to gateway status
        [0x09] = "MOTOTRBO Gateway Status",
        [0x0A] = "MOTOTRBO Gateway Status",
        [0x0B] = "Wireline Voice CFS",
        [0x0C] = "Wireline Service Enabled (Slot1)",
        [0x0D] = "Wireline Service Enabled (Slot2)",
        [0x0E] = "Wireline Data CFS"
    }

    peerservices_status = {
        [0x00] = "Disabled",
        [0x01] = "Enabled",
        [0x02] = "RESERVED",
        [0x03] = "RESERVED"
    }

    signalingmode_status = {
        [0x00] = "No RF Support",
        [0x01] = "Analog Mode",
        [0x02] = "Digital Mode",
        [0x03] = "RESERVED"
    }

    AdditionalSlotAssignmentTypes = {
        [0x00] = "Reserved",
        [0x01] = "Capacity Plus Trunked",
        [0x02] = "Capacity Plus Data Revert",
        [0x03] = "Reserved"
    }

    BroadcastMapTypes = { -- Map Type Bit Allocations
        [0x01] = "System Wide Map",
        [0x02] = "Site Map",
        [0x04] = "Intermediary Programming Map",
        [0x08] = "Satellite Map",
        [0x10] = "Voter Map",
        [0x20] = "RESERVED",
        [0x40] = "RESERVED",
        [0x81] = "Continuation System Wide Map",
        [0x82] = "Continuation Site Map",
        [0x84] = "Continuation Intermediary Programming Map",
        [0x88] = "Continuation Satellite Map",
        [0xC0] = "Continuation Voter Map",
        [0x80] = "Map Continuation Indicator"
    }
	
	BackhaulRole = {
		[0x1] = "Drop Repeater", 
		[0x2] = "Link Forward Repeater", 
		[0x3] = "Link Backward Repeater", 
	}
	
	RepeaterState =  {
		[0x00] = "F2_CP_HIBERNATE",
		[0x10] = "F2_CP_HANGTIME",
		[0x11] = "F2_CP_HANGTIME_RCT",
		[0x20] = "F2_CP_REPEATING_1",
		[0x30] = "F2_CP_REPEATING_2",
		[0x40] = "F2_CP_REPEATING_1_2",
		[0x50] = "F2_CP_FCCBLOCK",
		[0x51] = "F2_CP_FCCBLOCK_RCT",
		[0x60] = "F2_CP_NFLBLOCK"
	}
	
	SlotState = {
		[0x00] = "FC_CALLAPP_NULL",
		[0x10] = "F2_CALLAPP_CHNL_HANG",
		[0x11] = "F2_CALLAPP_CHNL_HANG_RCT",
		[0x12] = "F2_CALLAPP_CHNL_HANG_BUSY",
		[0x13] = "F2_CALLAPP_CHNL_HANG_GPS_ANNOUNCEMENT",
		[0x20] = "F2_CALLAPP_ACTIVE",
		[0x21] = "F2_CALLAPP_ACTIVE_VHDR",
		[0x22] = "F2_CALLAPP_ACTIVE_PIHDR",
		[0x23] = "F2_CALLAPP_ACTIVE_TT",
		[0x30] = "F2_CALLAPP_CALL_HANG",
	}

    f_opcode = ProtoField.uint8("le.opcode", "Link Establish Opcode", base.HEX, le_pdu)
    f_siteid = ProtoField.uint8("le.siteid", "Site Id", base.DEC)
    f_talkgroupid = ProtoField.uint8("le.talkgroupid", "Talkgroup Id", base.DEC)
    f_maptype = ProtoField.uint8("le.maptype", "Map Type", base.HEX, BroadcastMapTypes)
    f_leadingChanID = ProtoField.uint8("le.leadchanid", "LeadChanID", base.DEC)
    f_peerid = ProtoField.uint32("le.peerid", "Peer Id", base.DEC)
    f_current = ProtoField.uint8("le.current", "Current System Version", base.HEX, pdu)
    f_oldest = ProtoField.uint8("le.oldest", "Oldest System Version", base.HEX, pdu)
    f_accepted = ProtoField.uint8("le.accepted", "Accepted System Version", base.HEX, pdu)
    f_peermapindex = ProtoField.uint16("le.map.peerindex", "Peer Index", base.DEC)
    f_talkgroupindex = ProtoField.uint16("le.map.talkgroup", "Talkgroup Index", base.DEC)
    f_siteindex = ProtoField.uint8("le.map.Neighbors", "Site Index", base.DEC)
    f_peermode = ProtoField.uint16("le.peermode", "Peer Mode", base.HEX)
    f_peermode8 = ProtoField.uint8("le.peermode", "Peer Mode", base.HEX)
    f_reschans = ProtoField.uint8("le.map.ReserveChan", "Reserved Channels", base.DEC)
    f_peerservices = ProtoField.uint16("le.peerservices", "Peer Services", base.HEX)
    f_peerservices32 = ProtoField.uint32("le.peerservices32", "Peer Services", base.HEX)

    f_cpstatus = ProtoField.bytes("le.cpstatus", "CP Status Broadcast", base.HEX)

    f_tgsites = ProtoField.uint16("le.tgsites", "Talkgroup Sites", base.HEX)
    f_neighboringSites = ProtoField.uint16("le.neighborsites", "Neighboring Sites", base.HEX)
    f_numpeers = ProtoField.uint32("le.numpeers", "Number of Peers", base.DEC)  --LE_INTERM_REGISTRATION_RESPONSE
    f_numtalkgroups = ProtoField.uint32("le.numtalkgroups", "Number of Talkgroups", base.DEC)  --INTERM_PROG_TALKGROUP_MAP
    f_numsites = ProtoField.uint8("le.numneighborsites", "Number of Sites", base.DEC)  --INTERM_PROG_TALKGROUP_MAP
    f_optiontype = ProtoField.uint8("le.optiontype", "Option Type", base.DEC, optiontype)   -- LE_SYN_COMMAND_MAP_REQUEST
    f_maplen = ProtoField.uint32("le.maplen", "Map Length", base.DEC)           --LE_NOTIFICATION_MAP_BROADCAST
    f_remotepeerid = ProtoField.uint32("le.rpeerid", "Remote Peer Id", base.DEC)
    f_remotepeerip = ProtoField.ipv4("le.rpeerip", "Remote Peer IP Address", base.HEX)
    f_remotepeerport = ProtoField.uint16("le.rpeerport", "Remote Peer Port", base.DEC)
    f_sequencenumber = ProtoField.uint16("le.seqnumber", "Sequence Number", base.DEC)
    f_preferencelevel = ProtoField.uint8("le.preferencelevel", "Preference Level", base.DEC)
    f_restchannelinfo = ProtoField.uint8("le.restchannelinfo", "Rest Channel Info", base.HEX)
    f_currentrestchannelID = ProtoField.uint8("le.restchannelid", "Current Rest Channel ID", base.HEX)
    f_newrestchannelID = ProtoField.uint8("le.newchannelid", "New Rest Channel ID", base.HEX)
    f_channelID = ProtoField.uint8("le.newchannelid", "Channel ID", base.HEX)
    f_channelstatus = ProtoField.uint8("le.newchannelstatus", "Channel Status", base.HEX)
    f_calltype = ProtoField.uint8("le.calltype", "Call Type", base.HEX)
    f_srcid = ProtoField.uint16("le.srcsubscriberid","Source Subscriber Id", base.DEC)
    f_tgtid = ProtoField.uint16("le.tgtsubscriberid","Target Subscriber Id", base.DEC)
    f_timestamp = ProtoField.uint16("le.timestamp","Timestamp", base.DEC)
    f_oldrestchannelID = ProtoField.uint16("le.oldrestchannelID","Old Rest Channel ID", base.HEX)
    f_peerIDofnewrestchannel = ProtoField.uint16("le.peerIDofnewrestchannel","Peer ID of new rest channel", base.DEC)
    f_auth = ProtoField.bytes("le.auth", "Authentication", base.HEX)

    f_kabroadcast = ProtoField.bytes("le.kabroadcast", "LE Site Keep Alive Broadcast", base.HEX)
    f_kabroadcast_p2psiterestinfo = ProtoField.uint32("le.kabroadcastsiterestinfo", "P2P_SITES_REST_INFO", base.DEC)
    f_kabroadcast_currlinkprotoversion = ProtoField.uint16("le.kabroadcastcurrlinkproto", "Current Link Protocol Version", base.HEX)
    f_kabroadcast_oldlinkprotoversion = ProtoField.uint16("le.kabroadcastoldlinkproto", "Oldest Link Protocol Version", base.HEX)

    f_sitejoin = ProtoField.bytes("le.sitejoin", "Site Join", base.DEC)
    f_sitejoin_srcpeerid = ProtoField.uint32("le.sitejoinsrcpeerid", "Src Peer ID", base.DEC)
    f_sitejoin_srcsiteid = ProtoField.uint8("le.sitejoinsrcsiteid", "Src Site ID", base.DEC)
    f_sitejoin_rest = ProtoField.uint8("le.sitejoinrest", "Rest", base.DEC)
    f_sitejoin_srcofcalls = ProtoField.uint16("le.sitejoinsrcofcalls", "Source of Calls", base.HEX)


    f_voting_siteid = ProtoField.uint8("le.votingsiteid", "Voting Site Id", base.DEC)
    f_voting_peerid = ProtoField.uint8("le.votingpeerid", "Voting Peer Id", base.DEC)
    f_voting_ipaddr = ProtoField.ipv4("le.votingipaddr", "Voting IP Address", base.DEC)
    f_voting_port = ProtoField.uint8("le.votingport", "Voting Port Number", base.DEC)
    
    f_RequestedVoterId = ProtoField.uint8("le.RequestedVoterId", "Requested Voting Peer", base.DEC)

    f_voting_rdac_mapinfo = ProtoField.uint8("le.votingrdacmapinfo", "Num of RDACs", base.DEC)
    f_voting_rdac_info = ProtoField.uint8("le.votingrdacinfo", "RDAC ", base.DEC)
    f_voting_rdac_siteid = ProtoField.uint8("le.votingrdacsiteid", "RDAC Site Id", base.DEC)
    f_voting_rdac_peerid = ProtoField.uint8("le.votingrdacpeerid", "RDAC Peer Id", base.DEC)
    f_voting_rdac_ipaddr = ProtoField.ipv4("le.votingrdacipaddr", "RDAC IP Address", base.DEC)
    f_voting_rdac_port = ProtoField.uint8("le.votingrdacport", "RDAC Port Number", base.DEC)

    f_voting_mapinfo = ProtoField.uint8("le.votingmapinfo", "Num of Satellite Peers", base.DEC)
    f_voting_satinfo = ProtoField.uint8("le.votingsatinfo", "Satellite ", base.DEC)
    f_voting_satsiteid = ProtoField.uint8("le.votingsatsiteid", "Satellite Site Id", base.DEC)
    f_voting_satpeerid = ProtoField.uint8("le.votingsatpeerid", "Satellite Peer Id", base.DEC)
    f_voting_satipaddr = ProtoField.ipv4("le.votingsatipaddr", "Satellite IP Address", base.DEC)
    f_voting_satport = ProtoField.uint8("le.votingsatport", "Satellite Port Number", base.DEC)
    f_voting_numofrdacs = ProtoField.uint8("le.votingnumofrdacs", "Number of Rdacs", base.DEC)
    f_voting_numofsats = ProtoField.uint8("le.f_voting_numofsats", "Number of Satellites", base.DEC)
    f_voting_pduseqnum = ProtoField.uint32("le.voting_pduseqnum", "PDU Sequence Num", base.DEC)
    f_voting_rsapriority = ProtoField.uint8("le.voting_rsapriority", "RSA Priority", base.DEC)
    f_voting_srcid = ProtoField.uint32("le.voting_srcid", "Voting Src ID", base.DEC)
    f_voting_tgtid = ProtoField.uint32("le.voting_srcid", "Voting Tgt ID", base.DEC)
    f_voting_chnlid = ProtoField.uint8("le.voting_chnlid", "Channel ID", base.DEC)
    f_voterseq = ProtoField.uint16("le.voterseq", "Voter", base.DEC)
    f_numvoters = ProtoField.uint32("le.numpeers", "Number of Voters", base.DEC)
    f_Deregistration_siteid = ProtoField.uint8("le.deregistrationsiteid", "Deregistration Site Id", base.DEC)
    f_Deregistration_peerid = ProtoField.uint8("le.deregistrationpeerid", "Deregistration Peer Id", base.DEC)
	f_role = ProtoField.uint8("le.role", "Role", base.DEC, BackhaulRole)
    f_brstate = ProtoField.uint8("le.brstate", "Repeater State", base.DEC, RepeaterState)
	f_forknum = ProtoField.uint8("le.forknum", "Fork Num", base.DEC)
	f_slot1state = ProtoField.uint8("le.slot1state", "Slot One State", base.DEC, SlotState)
	f_slot2state = ProtoField.uint8("le.slot2state", "Slot Two State", base.DEC, SlotState)


    p_linkest.fields = {
    f_opcode, f_siteid, f_peerid, f_maptype, f_current, f_oldest, f_accepted, f_peermapindex, f_peermode, f_peermode8,f_peerservices,
    f_peerservices32,f_cpstatus, f_numpeers, f_numtalkgroups, f_optiontype, f_maplen, f_remotepeerid, f_remotepeerip, f_remotepeerport,
    f_preferencelevel, f_restchannelinfo, f_currentrestchannelID, f_newrestchannelID, f_channelID, f_channelstatus, f_talkgroupindex,
    f_calltype, f_srcid, f_tgtid, f_timestamp, f_oldrestchannelID, f_peerIDofnewrestchannel, f_auth, f_leadingChanID, f_talkgroupid,
    f_tgsites, f_neighboringSites, f_numsites, f_siteindex, f_reschans, f_sitejoin, f_sitejoin_srcpeerid, f_sitejoin_srcsiteid,
    f_sitejoin_rest, f_kabroadcast, f_sitejoin_srcofcalls,f_Deregistration_siteid,f_Deregistration_peerid,
    f_kabroadcast_p2psiterestinfo, f_kabroadcast_currlinkprotoversion, f_kabroadcast_oldlinkprotoversion, f_voting_rdac_mapinfo,
    f_voting_rdac_info, f_voting_rdac_siteid, f_voting_rdac_peerid, f_voting_rdac_ipaddr, f_voting_rdac_port,
    f_voting_mapinfo, f_voting_siteid, f_voting_peerid, f_voting_ipaddr, f_voting_port, f_voting_satsiteid, f_voting_satinfo,
    f_voting_satpeerid, f_voting_satipaddr, f_voting_satport, f_voting_numofrdacs, f_voting_numofsats, f_voting_pduseqnum,
    f_voting_rsapriority, f_voting_srcid, f_voting_tgtid,f_voting_chnlid,f_voterseq,f_sequencenumber,f_numvoters,f_RequestedVoterId, f_role, f_brstate, f_forknum, f_slot1state, f_slot2state}

    function p_linkest.dissector(buf, pkt, root)
        local error_msg = nil
        --local HMAC_len = 10
        local opid = nil
        local peerid = nil
        local t = nil
        local buf_len = buf:len()

        if buf_len >= 5 then
            opid = buf(0,1):uint()
            peerid = buf(2,3):uint()
        end

        local f_slot2assign = ProtoField.uint8("le.slot2assign", "Slot 2 Assignement", base.HEX)
        local f_slot1assign = ProtoField.uint8("le.slot1assign", "Slot 1 Assignement", base.HEX)
        local f_signallingmode = ProtoField.uint8("le.signallingmode", "Current Signalling Mode", base.HEX)
        local f_peerstatus = ProtoField.uint8("le.peerstatus", "Peer Status", base.HEX)

        --Peer Mode (for IPSC and CapPlus Systems)
        function mode_bits_disp_ipsc_cap(n, buf)
            local u = n:add(f_peermode8, buf)

            --Peer Status
            local peerstatus2 = getbit(buf:uint(), 7)
            local peerstatus1 = getbit(buf:uint(), 6)
            local peerstat = peerstatus2*2 + peerstatus1
            local peerstatusdesc = "........"..peerstatus2..peerstatus1.."......".." = Peer Status : "..peerstatus[peerstat]
            u:add(f_peerstatus, buf, peerstatusdesc)

            -- Current Signaling Mode
            local sigmode2 =getbit(buf:uint(), 5)
            local sigmode1 = getbit(buf:uint(), 4)
            local sigmodestat = sigmode2*2 + sigmode1
            local sigmodedesc = ".........."..sigmode2..sigmode1.."....".." = Signal Mode : "..signalingmode_status[sigmodestat]
            u:add(f_signallingmode, buf, sigmodedesc)

            --Slot 1 Assignment
            local slot1assign2 = getbit(buf:uint(), 3)
            local slot1assign1 = getbit(buf:uint(), 2)
            local slot1assign = slot1assign1 + slot1assign2*2
            local slot1assigndesc = "............"..slot1assign2..slot1assign1.."..".." = Slot 1 Assignment : "..slotassignment[slot1assign]
            u:add(f_slot1assign, buf, slot1assigndesc)

            --Slot 2 Assignment
            local slot2assign2 = getbit(buf:uint(), 1)
            local slot2assign1 = getbit(buf:uint(), 0)
            local slot2assign = slot2assign1 + slot2assign2*2
            local slot2assigndesc = ".............."..slot2assign2..slot2assign1.." = Slot 2 Assignment : "..slotassignment[slot2assign]
            u:add(f_slot2assign, buf, slot2assigndesc)
        end


        --Peer Mode (for LCP systems)
        function mode_bits_disp(n, buf)
            local u = n:add(f_peermode, buf)

            --Reserved Bit 15
            local reserved15Bit = getbit(buf:uint(), 15)
            local reserved15statusdesc = ""..reserved15Bit.."...............".." = Digital Voter Bit : "..peerservices_status[reserved15Bit]
            u:add(f_peerstatus, buf, reserved15statusdesc)

            -- MOTOTRBO Gateway
            local mototrbogatewayBit = getbit(buf:uint(), 14)
            local mototrbogatewaystatusdesc = "."..mototrbogatewayBit.."..............".." = MOTOTRBO Gateway : "..peerservices_status[mototrbogatewayBit]
            u:add(f_peerstatus, buf, mototrbogatewaystatusdesc)

            -- No LE w/ Data Revert
            local nolewdatarevBit = getbit(buf:uint(), 13)
            local nolewdatarevstatusdesc = ".."..nolewdatarevBit..".............".." = No LE w/ Data Revert : "..peerservices_status[nolewdatarevBit]
            u:add(f_peerstatus, buf, nolewdatarevstatusdesc)

            --Remote Programming Peer
            local rrpBit = getbit(buf:uint(), 12)
            local rrpstatusdesc = "..."..rrpBit.."............".." = Remote Programming Peer : "..peerservices_status[rrpBit]
            u:add(f_peerstatus, buf, rrpstatusdesc)

            --Passive Device Peer
            local passiveBit = getbit(buf:uint(), 11)
            local passivestatusdesc = "...."..passiveBit.."...........".." = Passive Device (CPS) Peer : "..peerservices_status[passiveBit]
            u:add(f_peerstatus, buf, passivestatusdesc)

            --Virtual Site Peer
            local virtualBit = getbit(buf:uint(), 10)
            local virtualstatusdesc = "....."..virtualBit.."..........".." = Virtual Site Peer : "..peerservices_status[virtualBit]
            u:add(f_peerstatus, buf, virtualstatusdesc)

            --XNL Master Device
            local xnlMasterBit = getbit(buf:uint(), 9)
            local xnlMasterstatusdesc = "......"..xnlMasterBit..".........".." = XNL Master Device : "..peerservices_status[xnlMasterBit]
            u:add(f_peerstatus, buf, xnlMasterstatusdesc)

            --XNL Slave Device
            local xnlSlaveBit = getbit(buf:uint(), 8)
            local xnlSlavestatusdesc = "......."..xnlSlaveBit.."........".." = XNL Slave Device : "..peerservices_status[xnlSlaveBit]
            u:add(f_peerstatus, buf, xnlSlavestatusdesc)

            --Remote 3rd Party Console Application
            local consoleBit = getbit(buf:uint(), 7)
            local consolestatusdesc = "........"..consoleBit..".......".." = Remote 3rd Party Console Application : "..peerservices_status[consoleBit]
            u:add(f_peerstatus, buf, consolestatusdesc)

            --Primary Intermediary
            local intermBit = getbit(buf:uint(), 6)
            local intermstatusdesc = "........."..intermBit.."......".." = Primary Intermediary : "..peerservices_status[intermBit]
            u:add(f_peerstatus, buf, intermstatusdesc)

            --Peer Status
            local peerstatus2= getbit(buf:uint(), 5)
            local peerstatus1 = getbit(buf:uint(), 4)
            local peerstat = peerstatus2*2 + peerstatus1
            local peerstatusdesc = ".........."..peerstatus2..peerstatus1.."....".." = Peer Status : "..peerstatus[peerstat]
            u:add(f_peerstatus, buf, peerstatusdesc)

            --Slot 1 Assignment
            local slot1assign2 = getbit(buf:uint(), 3)
            local slot1assign1 = getbit(buf:uint(), 2)
            local slot1assign = slot1assign2*2 + slot1assign1
            local slot1assigndesc = "............"..slot1assign2..slot1assign1.."..".." = Slot 1 Assignment : "..slotassignmentForLCP[slot1assign]
            u:add(f_slot1assign, buf, slot1assigndesc)

            --Slot 2 Assignment
            local slot2assign2 = getbit(buf:uint(), 1)
            local slot2assign1 = getbit(buf:uint(), 0)
            local slot2assign = slot2assign2*2 + slot2assign1
            local slot2assigndesc = ".............."..slot2assign2..slot2assign1.." = Slot 2 Assignment : "..slotassignmentForLCP[slot2assign]
            u:add(f_slot2assign, buf, slot2assigndesc)

        end
        
        -- Version NUM
        function Version_Disp(n,buf)
            n:add(f_current, buf(0, 2))
            n:add(f_oldest,  buf(2, 2))
        end

        -- Peer ID
        function peerID_Disp(n, buf)
            n:add(f_siteid, buf(0, 1))
            n:add(f_peerid, buf(1, 3))
        end

        -- Voting site/peer ID
        --  p = 0 if voter, 1 if satellite, 2 if rdac
        --  rdac = 0 if not rdac, 1 if rdac
        function voting_peerID_Disp(n, buf, p)
            if(p == 0) then -- Voter
                n:add(f_voting_siteid, buf(0,1))
                n:add(f_voting_peerid, buf(1,3))
            elseif(p == 1) then -- Satellite
                n:add(f_voting_satsiteid, buf(0,1))
                n:add(f_voting_satpeerid, buf(1,3))
            elseif(p == 2) then -- RDAC
                n:add(f_voting_rdac_siteid, buf(0,1))
                n:add(f_voting_rdac_peerid, buf(1,3))
            end
        end
        
        -- Deregistration ID
        function DeregistrationID_Disp(n,buf)
            n:add(f_Deregistration_siteid,buf(0,1))
            n:add(f_Deregistration_peerid,buf(1,3))
        end
        
        -- Reciever ID
        function RecieverID_Disp(n,buf)
            n:add(f_voting_satsiteid,buf(0,1))
            n:add(f_voting_satpeerid,buf(1,3))
        end

        -- Voter and satellite display functions
        --     maplen = size of map
        --     n = parse tree
        --     buf = buffer
        --     sysmod = LCP = 8, IPSC = 4
        function voter_sat_disp(maplen, n, buf, sysmod)
            local currentRepeater = 0
            local numofrepeaters
            local pos = 0
            local tc
            local tf

            if(sysmod == (tonumber(0x04,10)) or sysmod == (tonumber(0x08,10))) then
                -- IPSC 0x04 or CapPlus 0x08
                numofrepeaters = maplen/11
                while(currentRepeater < numofrepeaters) do
                        if(currentRepeater == 0) then
                            -- We're on the voter repeater
                            voting_peerID_Disp(n, buf(0,4),0)
                            n:add(f_voting_ipaddr,buf(4,4))
                            n:add(f_voting_port, buf(8,2))
                            mode_bits_disp_ipsc_cap(n,buf(10,1))
                            pos = pos + 11
                            tc = n:add(f_voting_mapinfo, numofrepeaters)
                            maplen = maplen - 11
                        else
                            -- Satellite repeater
                            tf = tc:add(f_voting_satinfo, currentRepeater-1)
                            voting_peerID_Disp(tf, buf(pos,4),1)
                            tf:add(f_voting_satipaddr, buf(pos+4,4))
                            tf:add(f_voting_satport, buf(pos+8,2))
                            mode_bits_disp_ipsc_cap(tf,buf(pos+10,1))
                            pos = pos + 11
                            maplen = maplen - 11
                        end
                        currentRepeater = currentRepeater + 1;
                    end
            elseif(sysmod == (tonumber(0x10,10))) then
                -- LCP 0x010
                numofrepeaters = maplen/12
                while(currentRepeater < numofrepeaters) do
                    if(currentRepeater == 0) then
                        -- We're on the voter repeater
                        voting_peerID_Disp(n, buf(0,4),0)
                        n:add(f_voting_ipaddr,buf(4,4))
                        n:add(f_voting_port, buf(8,2))
                        mode_bits_disp(n,buf(10,2))
                        pos = pos + 12
                        tc = n:add(f_voting_mapinfo, numofrepeaters)
                        maplen = maplen - 12
                    else
                        -- Satellite repeater
                        tf = tc:add(f_voting_satinfo, currentRepeater-1)
                        voting_peerID_Disp(tf, buf(pos,4),1)
                        tf:add(f_voting_satipaddr, buf(pos+4,4))
                        tf:add(f_voting_satport, buf(pos+8,2))
                        mode_bits_disp(tf,buf(pos+10,2))
                        pos = pos + 12
                        maplen = maplen - 12
                    end
                    currentRepeater = currentRepeater + 1;
                end
            end
        end

        -- RDACs and Satellites display function
        --    maplen = size of map
        --    n = parse tree
        --    buf = buffer
        --    sysmod = LCP = 8, IPSC = 4
        function rdacs_sat_disp(maplen, n, buf, sysmod)

            local num_of_rdacs = buf(0,1):uint()
            local current_rdac = 0
            local num_of_sats = buf(1,1):uint()
            local current_sat = 0
            local pos = 0
            local rdac_dropdown
            local sat_dropdown
            local drop_down

            rdac_dropdown = n:add(f_voting_numofrdacs, buf(0,1))
            --rdac_dropdown = n:add(f_voting_rdac_mapinfo, num_of_rdacs)
            sat_dropdown = n:add(f_voting_numofsats, buf(1,1))
            --sat_dropdown = n:add(f_voting_mapinfo, num_of_sats)

            pos = pos + 2

            if(sysmod == (tonumber(0x04,10)) or sysmod == (tonumber(0x08,10))) then
                -- IPSC 0x04 or CapPlus 0x08
                -- Parse out RDACs first
                while(current_rdac < num_of_rdacs) do
                    drop_down = rdac_dropdown:add(f_voting_rdac_info, current_rdac)
                    voting_peerID_Disp(drop_down, buf(pos,4),2)
                    drop_down:add(f_voting_rdac_ipaddr, buf(pos+4,4))
                    drop_down:add(f_voting_rdac_port, buf(pos+8,2))
                    mode_bits_disp_ipsc_cap(drop_down, buf(pos+10,1))
                    pos = pos + 11
                    maplen = maplen - 11
                    current_rdac = current_rdac + 1;
                end
                while(current_sat < num_of_sats) do
                    -- Satellite repeater
                    drop_down = sat_dropdown:add(f_voting_satinfo, current_sat)
                    voting_peerID_Disp(drop_down, buf(pos,4),1)
                    drop_down:add(f_voting_satipaddr, buf(pos+4,4))
                    drop_down:add(f_voting_satport, buf(pos+8,2))
                    mode_bits_disp_ipsc_cap(drop_down,buf(pos+10,1))
                    pos = pos + 11
                    maplen = maplen - 11
                    current_sat = current_sat + 1;
                end
            elseif(sysmod == (tonumber(0x10,10))) then
                 -- LCP 0x010
                 -- Parse out RDACs first
                 while(current_rdac < num_of_rdacs) do
                    drop_down = rdac_dropdown:add(f_voting_rdac_info, current_rdac)
                    voting_peerID_Disp(drop_down, buf(pos,4),2)
                    drop_down:add(f_voting_rdac_ipaddr, buf(pos+4,4))
                    drop_down:add(f_voting_rdac_port, buf(pos+8,2))
                    mode_bits_disp(drop_down,buf(pos+10,2))
                    pos = pos + 12
                    maplen = maplen - 12
                    current_rdac = current_rdac + 1;
                 end
                 while(current_sat < num_of_sats) do
                    drop_down = sat_dropdown:add(f_voting_satinfo, currentRepeater-1)
                    voting_peerID_Disp(drop_down, buf(pos,4),1)
                    drop_down:add(f_voting_satipaddr, buf(pos+4,4))
                    drop_down:add(f_voting_satport, buf(pos+8,2))
                    mode_bits_disp(drop_down,buf(pos+10,2))
                    pos = pos + 12
                    maplen = maplen - 12
                 end
            end

        end

        -- Peer Service
        --   Displays the Peer Services bits
        --   n = parse tree
        --   buf = buffer
        --   ind = 0 for 16 bit, 1 for 32 bit
        --     lcp = 0 if NOT in LCP mode, 1 if it IS
        function service_bits_disp(n, buf, ind, lcp)
            local v
            local bit
            local b
            local temp
            if ind == 0 then
                v = n:add(f_peerservices, buf)
                bit = 15
                temp= 15
            else
                v = n:add(f_peerservices32, buf)
                bit = 31
                temp = 31
            end

            while bit >= 0 do
                local service = getbit(buf:uint(), bit)
                local servicedesc = ""
                local skip_period = false
                local service_sec_bit

                b = temp
                while b >= 0 do
                    if b ~= bit then
                        if (skip_period == false) then
                            servicedesc = servicedesc.."."
                        else
                            skip_period = false
                        end
                    else
                        if ((lcp == 1) and (bit == 0x0A)) or ((lcp == 0) and (bit == 0x19)) then -- Need to display both bits of service
                            service_sec_bit = getbit(buf:uint(), bit-1)
                            servicedesc = servicedesc..service..service_sec_bit
                            skip_period = true
                        elseif (lcp ~= 1) and ((bit == 0x0B) or (bit == 0x09)) then
                            service_sec_bit = getbit(buf:uint(), bit-1)
                            servicedesc = servicedesc..service..service_sec_bit
                            skip_period = true
                        else
                            servicedesc = servicedesc..service
                        end
                    end

                    if (b % 8) == 0 then
                        servicedesc = servicedesc .. " "
                    end

                    b = b - 1
                end

                if (lcp == 1) and (peerservicesForLCP[bit] ~= nil) then
                    servicedesc = servicedesc .. " = "..peerservicesForLCP[bit]
                elseif (lcp == 0) and (peerservices[bit] ~= nil) then
                    servicedesc = servicedesc .. " = "..peerservices[bit]
                else
                    servicedesc = servicedesc.." = Reserved"
                end

                if ((lcp == 1) and (bit == 0x0A)) or ((lcp == 0) and (bit == 0x19)) then -- MOTOTRBO Gateway Status
                    local stat1 = service
                    local stat2 = service_sec_bit
                    bit = bit - 1
                    local stat = stat1*2 + stat2
                    if(gateway_status[stat] ~= nil) then
                        servicedesc = servicedesc .. " : "..gateway_status[stat]
                    else
                        servicedesc = servicedesc .." : "  .. "Unknown Gateway Status: ".. stat
                    end
                elseif (lcp ~= 1) and ((bit == 0x0B) or (bit == 0x09)) then -- Slot 2 Assignment Continue Type
                    local stat1 = service
                    local stat2 = service_sec_bit
                    bit = bit - 1
                    local stat = stat1*2 + stat2
                    if(gateway_status[stat] ~= nil) then
                        servicedesc = servicedesc .. " : "..AdditionalSlotAssignmentTypes[stat]
                    elseif (bit == 0x0B) then
                        servicedesc = servicedesc .." : "  .. "Unknown Slot 2 Status: ".. stat
                    else -- Slot 1
                        servicedesc = servicedesc .." : "  .. "Unknown Slot 1 Status: ".. stat
                    end
                else -- Regular status
                    servicedesc = servicedesc .." : " ..peerservices_status[service]
                end

                v:add(f_peerstatus, buf, servicedesc)

                bit = bit - 1
            end
        end

        -- Talkgroup Map Decode
        function tg_map_decode(n, buf)
        
            local bit
            bit = 1
            while bit <= 16 do
                local service = getbit(buf:uint(), bit)
                local servicedesc = ""
    
                if service == 1 then
                    servicedesc = servicedesc .. "Site " .. bit .. " : Enabled"
                    n:add(f_peerstatus, buf, servicedesc)
                end
                bit = bit +1
            end
        end
        
        -- CP Status Decode
        function cp_status_disp(n, buf, ind)
            local v
            local bit
            local b
            local temp

            v = n:add(f_cpstatus, buf)
            bit = 31
            temp = 31

            while bit >= 0 do
                local service = getbit(buf:uint(), bit)
                local servicedesc = ""
                if peerservicesForLCP[bit] ~= nil then
                    servicedesc = servicedesc .. " = "..peerservicesForLCP[bit]
                else
                    servicedesc = servicedesc.." = Reserved"
                end

                v:add(f_peerstatus, buf, servicedesc)
                bit = bit -1
            end
        end

        -- Neighboring Sites Decode
        function neighbor_map_decode(n, buf)
            local bit

            bit = 1

            while bit <= 16 do
                local service = getbit(buf:uint(), bit)
                local servicedesc = ""

                if service == 1 then
                    servicedesc = servicedesc .. "Neighboring Site:" .. bit
                    n:add(f_peerstatus, buf, servicedesc)
                end

                bit = bit +1
            end
        end

        -- CP Status Broadcast PDU
        function cp_status_broadcast_disp(u, buf)
            local n = u:add(f_cpstatus,buf)
            n:add(f_opcode, buf(0,1))
            peerID_Disp(n, buf(1,4))
            n:add(f_sequencenumber, buf(5, 2))
            n:add(f_timestamp, buf(7,4))
            n:add(f_preferencelevel, buf(11, 1))
            n:add(f_restchannelinfo, buf(12, 1))
            n:add(f_oldrestchannelID, buf(13,1))
            n:add(f_currentrestchannelID, buf(14,1))
            n:add(f_peerIDofnewrestchannel, buf(15,4))
            n:add(f_newrestchannelID, buf(19,1))
            n:add(f_channelID, buf(20,1))
            n:add(f_channelstatus, buf(21,1))
            n:add(f_calltype, buf(22,1))
            n:add(f_srcid, buf(23,2))
            n:add(f_tgtid, buf(25,2))
            n:add(f_channelID, buf(27,1))
            n:add(f_channelstatus, buf(28,1))
            n:add(f_calltype, buf(29,1))
            n:add(f_srcid, buf(30,2))
            n:add(f_tgtid, buf(32,2))
        end

        -- Dissects LE_MAP_Broadcast with new map entries
        function map_broadcast_new_maps_dissect(p_linkest, buf)
            local mapopcode = buf(5,1):uint()
            local maplen = buf(6, 2):uint()
            
            if(mapopcode > 0x80) then
                mapopcode = mapopcode - 0x80
            end
            
            local peercount = maplen / 13  -- ngr468 2013-10-14 11:50:30 :change 12 to 13.
            local len = 8 + maplen -- Add first part of msg (8B) to maplen
            local peer_index = 0;
            t = root:add(p_linkest, buf(0, len+4)) -- +4 for version
            local pos = 0
            local system = buf(buf_len-2, 1):uint()

            t:add(f_opcode, buf(pos, 1))
            pos = pos + 1
            t:add(f_siteid, buf(pos, 1))
            pos = pos + 1
            t:add(f_peerid, buf(pos, 3))
            peerid = buf(pos,3):uint() -- For info field
            pos = pos + 3
            t:add(f_maptype, buf(pos, 1))
            pos = pos + 1
            t:add(f_maplen, buf(pos, 2))
            pos = pos + 2

            if mapopcode == 4 then
                local tc = t:add(f_numtalkgroups, buf(pos, 1))
                local peernum = buf(pos, 1):uint()
                pos = pos + 1
                while (peer_index < peernum) do
                    local ts = tc:add(f_talkgroupindex, peer_index)
                    ts:add(f_talkgroupid, buf(pos, 1))
                    pos = pos + 1
                    tg_map_decode(ts, buf(pos,2))
                    pos = pos + 2
                    peer_index = peer_index + 1
                end

                local tn = t:add(f_numsites, buf(pos, 1))
                peernum = buf(pos, 1):uint()
                pos = pos + 1
                peer_index = 0
                while (peer_index < peernum) do
                    local tb = tn:add(f_siteindex, peer_index+1)
                    tb:add(f_siteid, buf(pos, 1))
                    pos = pos + 1
                    tb:add(f_reschans, buf(pos, 1))
                    pos = pos + 1
                    neighbor_map_decode(tb, buf(pos,2))
                    pos = pos +2
                    peer_index = peer_index + 1
                end

            elseif mapopcode == 8 then
                voter_sat_disp(maplen, t, buf(pos,maplen), system)
                pos = pos + maplen

            elseif mapopcode == 16 then
                rdacs_sat_disp(maplen, t, buf(pos,maplen), system)
                pos = pos + maplen

            elseif mapopcode <= 2 then
                local tc = t:add(f_numpeers, peercount)
                while (peer_index < peercount) do
                    local ts = tc:add(f_peermapindex, peer_index)
                    ts:add(f_siteid, buf(pos, 1))
                    pos = pos + 1
                    ts:add(f_remotepeerid, buf(pos, 3))
                    pos = pos + 3
                    ts:add(f_remotepeerip, buf(pos, 4))
                    pos = pos + 4
                    ts:add(f_remotepeerport, buf(pos, 2))
                    pos = pos + 2
                    mode_bits_disp(ts, buf(pos,2))
                    pos = pos + 2
                    ts:add(f_leadingChanID, buf(pos, 1))
                    pos = pos + 1
                    peer_index = peer_index + 1
                end
            end
            
            Version_Disp(t,buf(buf:len() - 4,4)) --using total len of pdu subtract 4 byte obtain index.
        end

        -- Dissects LE_MAP_Broadcast with old map entries
        function map_broadcast_old_maps_dissect(p_linkest, buf)
            local maplen = buf(5, 2):uint()
            local peercount = maplen / 11
            local len = 7 -- Add first part of msg (7B) to maplen
            local peer_index = 0;
            t = root:add(p_linkest, buf(0, buf_len))
            local pos = 0

            t:add(f_opcode, buf(pos, 1))
            pos = pos + 1
            t:add(f_siteid, buf(pos, 1))
            pos = pos + 1
            t:add(f_peerid, buf(pos, 3))
            pos = pos + 3
            t:add(f_maplen, buf(pos, 2))
            pos = pos + 2

            local tc = t:add(f_numpeers, peercount)
            while (peer_index < peercount) do
                local ts = tc:add(f_peermapindex, peer_index)
                ts:add(f_siteid, buf(pos, 1))
                pos = pos + 1
                ts:add(f_remotepeerid, buf(pos, 3))
                pos = pos + 3
                ts:add(f_remotepeerip, buf(pos, 4))
                pos = pos + 4
                ts:add(f_remotepeerport, buf(pos, 2))
                pos = pos + 2
                mode_bits_disp_ipsc_cap(ts, buf(pos,1))
                pos = pos + 1
                peer_index = peer_index + 1
            end
        end

        if buf_len >= (le_pdu_len[opid] - 1) then

            -- Start root node if not map broadcast or site_join
            if opid ~= 0x93 and (opid ~= 0xCC) and (opid ~= 0xA5) then
                t = root:add(p_linkest, buf(0, buf_len))
                t:add(f_opcode, buf(0, 1))
                peerID_Disp(t, buf(1, 4))
            end

            if opid == 0x90  then     --LE_INTERM_REGISTRATION_REQUEST

                if buf_len == le_pdu_len[opid]+6 then
                    -- IPSC, CapPlus
                    mode_bits_disp_ipsc_cap(t, buf(5, 1))
                    service_bits_disp(t, buf(6, 4), 1, 0)
                    Version_Disp(t,buf(10,4))
                elseif buf_len == le_pdu_len[opid]+6+10 then
                    -- IPSC, CapPlus with Authentication
                    mode_bits_disp_ipsc_cap(t, buf(5, 1))
                    service_bits_disp(t, buf(6, 4), 1, 0)
                    Version_Disp(t,buf(10,4))
                    t:add(f_auth, buf(14, 10))
                elseif buf_len == le_pdu_len[opid]+8 then
                    -- LCP
                    mode_bits_disp(t, buf(5, 2))
                    service_bits_disp(t, buf(7, 4), 1, 1)
                    t:add(f_leadingChanID, buf(11, 1))
                    Version_Disp(t,buf(12,4))
                elseif buf_len == le_pdu_len[opid]+8+10 then
                    -- LCP with Authentication
                    mode_bits_disp(t, buf(5, 2))
                    service_bits_disp(t, buf(7, 4), 1, 1)
                    t:add(f_leadingChanID, buf(11, 1))
                    Version_Disp(t,buf(12,4))
                    t:add(f_auth, buf(16, 10))
                elseif buf_len == le_pdu_len[opid]+10 then
                    -- R1.4, R1.5, R1.5a with Authentication
                    mode_bits_disp_ipsc_cap(t, buf(5, 1))
                    service_bits_disp(t, buf(6,2),0, 0)
                    t:add(f_auth, buf(8, 10))
                else
                    -- R1.4, R1.5, R1.5a
                    mode_bits_disp_ipsc_cap(t, buf(5, 1))
                    service_bits_disp(t, buf(6, 2), 0, 0)
                end


            elseif opid == 0x91 then   --LE_INTERM_REGISTRATION_RESPONSE
                -- IPSC, CapPlus
                if buf_len == le_pdu_len[opid]+6 then
                    mode_bits_disp_ipsc_cap(t, buf(5, 1))
                    service_bits_disp(t, buf(6,4),1,0)
                    t:add(f_numpeers, buf(10, 2))
                    Version_Disp(t,buf(12,4))
                -- IPSC, CapPlus w/Authentication
                elseif buf_len == le_pdu_len[opid]+10+6 then
                    mode_bits_disp_ipsc_cap(t, buf(5,1))
                    service_bits_disp(t, buf(6,4),1,0)
                    t:add(f_numpeers, buf(10, 2))
                    Version_Disp(t,buf(12,4))
                    t:add(f_auth, buf(16, 10))
                -- LCP
                elseif buf_len == le_pdu_len[opid]+8 then
                    mode_bits_disp(t, buf(5,2))
                    service_bits_disp(t, buf(7,4),1, 1)
                    t:add(f_leadingChanID, buf(11,1))
                    t:add(f_numpeers, buf(12, 2))
                    Version_Disp(t,buf(14,4))
                -- LCP w/Authentication
                elseif buf_len == le_pdu_len[opid]+8+10 then
                    mode_bits_disp(t, buf(5,2))
                    service_bits_disp(t, buf(7,4),1,1)
                    t:add(f_leadingChanID, buf(11,1))
                    t:add(f_numpeers, buf(12, 2))
                    Version_Disp(t,buf(14,4))
                    t:add(f_auth, buf(18, 10))
                -- R1.4, R1.5, R1.5a w/Authentication
                elseif buf_len == le_pdu_len[opid]+10 then
                    mode_bits_disp_ipsc_cap(t, buf(5,1))
                    service_bits_disp(t, buf(6,2),0,0)
                    t:add(f_numpeers, buf(8, 2))
                    t:add(f_auth, buf(10, 10))
                else
                    -- R1.4, R1.5, R1.5a
                    mode_bits_disp_ipsc_cap(t, buf(5,1))
                    service_bits_disp(t, buf(6,2),0,0)
                    t:add(f_numpeers, buf(8, 2))
                end

            elseif opid == 0x92 then   --LE_NOTIFICATION_MAP_REQUEST

                if buf_len == le_pdu_len[opid]+4 then
                    -- LCP
                    t:add(f_maptype, buf(5, 1))
                    Version_Disp(t,buf(6,4))
                elseif buf_len == le_pdu_len[opid]+4+10 then
                    -- LCP w/Authentication
                    t:add(f_maptype, buf(5, 1))
                    Version_Disp(t,buf(6,4))
                    t:add(f_auth, buf(10, 10))
                elseif buf_len == le_pdu_len[opid]+9 then
                    -- IPSC, CapPlus w/Authentication
                    t:add(f_auth, buf(5, 10))
                end

            elseif opid == 0x94 then  --LE_PEER_REGISTRATION_REQUEST
                if buf_len == le_pdu_len[opid]+4 then
                    -- LCP, IPSC, CapPlus
                    Version_Disp(t,buf(5,4))
                elseif buf_len == le_pdu_len[opid]+4+10 then
                    -- LCP, IPSC, CapPlus w/Authentication
                    Version_Disp(t,buf(5,4))
                    t:add(f_auth, buf(9, 10))
                elseif buf_len == le_pdu_len[opid]+10 then
                    -- R1.4, R1.5, R1.5a w/Authentication
                    t:add(f_auth, buf(5, 10))
                end

            elseif opid == 0x95 then  --LE_PEER_REGISTRATION_RESPONSE
                if buf_len == le_pdu_len[opid]+4+10 then
                    -- IPSC, CapPlus, LCP w/Authentication
                    Version_Disp(t,buf(5,4))
                    t:add(f_auth, buf(9, 10))

                elseif buf_len == le_pdu_len[opid]+4 then
                    -- IPSC, CapPlus, LCP
                    Version_Disp(t,buf(5,4))

                elseif buf_len == le_pdu_len[opid]+10 then
                    -- R1.4, R1.5, R1.5a w/Authentication
                    t:add(f_auth, buf(5, 10))
                end

            elseif opid == 0x96 then   --LE_INTERM_KEEP_ALIVE_REQUEST
                if buf_len == le_pdu_len[opid] then -- 8 bytes
                    -- R1.4 to R1.5a
                    mode_bits_disp(t, buf(5,1))
                    service_bits_disp(t, buf(6,2),0,0)
                elseif buf_len == le_pdu_len[opid]+10 then
                    -- R1.4 to R1.5a w/ Authentication
                    mode_bits_disp(t, buf(5,1))
                    service_bits_disp(t, buf(6,2),0,0)
                    t:add(f_auth, buf(8, 10))
                elseif buf_len == le_pdu_len[opid]+6 then
                    -- IPSC, Cap_plus
                    mode_bits_disp_ipsc_cap(t, buf(5,1))
                    service_bits_disp(t, buf(6,4),1,0)
                    Version_Disp(t,buf(10,4))
                elseif buf_len == le_pdu_len[opid]+6+10 then
                    -- IPSC,Cap_plus w/ Authentication
                    mode_bits_disp_ipsc_cap(t, buf(5,1))
                    service_bits_disp(t, buf(6,4),1,0)
                    Version_Disp(t,buf(10,4))
                    t:add(f_auth, buf(14, 10))
                elseif buf_len == le_pdu_len[opid]+8 then
                    -- LCP
                    mode_bits_disp(t, buf(5,2))
                    service_bits_disp(t, buf(7,4),1,1)
                    t:add(f_leadingChanID, buf(11,1))
                    Version_Disp(t,buf(12,4))
                elseif buf_len == le_pdu_len[opid]+8+10 then
                    -- LCP w/ Authentication
                    mode_bits_disp(t, buf(5,2))
                    service_bits_disp(t, buf(7,4),1,1)
                    t:add(f_leadingChanID, buf(11,1))
                    Version_Disp(t,buf(12,4))
                    t:add(f_auth, buf(16, 10))
                end

            elseif opid == 0x97 then   --LE_INTERM_KEEP_ALIVE_RESPONSE
                if buf_len == le_pdu_len[opid] then -- 8 B
                    -- R1.4 to R1.5a
                    mode_bits_disp_ipsc_cap(t,buf(5,1))
                    service_bits_disp(t,buf(6,2),0,0)
                elseif buf_len == le_pdu_len[opid]+10 then
                    -- R1.4 to R1.5a w/ Authentication
                    mode_bits_disp_ipsc_cap(t,buf(5,1))
                    service_bits_disp(t,buf(6,2),0,0)
                    t:add(f_auth, buf(8,10))
                elseif buf_len == le_pdu_len[opid]+6 then
                    -- IPSC, Cap_plus
                    mode_bits_disp_ipsc_cap(t,buf(5,1))
                    service_bits_disp(t,buf(6,4),1,0)
                    Version_Disp(t,buf(10,4))
                elseif buf_len == le_pdu_len[opid]+6+10 then
                    -- IPSC, Cap_plus w/ Authentication
                    mode_bits_disp_ipsc_cap(t,buf(5,1))
                    service_bits_disp(t,buf(6,4),1,0)
                    Version_Disp(t,buf(10,4))
                    t:add(f_auth, buf(14,10))
                elseif buf_len == le_pdu_len[opid]+8 then
                    -- LCP
                    mode_bits_disp(t, buf(5,2))
                    service_bits_disp(t,buf(7,4),1,1)
                    t:add(f_leadingChanID, buf(11,1))
                    Version_Disp(t,buf(12,4))
                elseif buf_len == le_pdu_len[opid]+8 then
                    -- LCP w/ Authentication
                    mode_bits_disp(t, buf(5,2))
                    service_bits_disp(t,buf(7,4),1,1)
                    t:add(f_leadingChanID, buf(11,1))
                    Version_Disp(t,buf(12,4))
                    t:add(f_auth, buf(16,10))
                end


                -- TODO: Does this need authentication?
            elseif opid == 0x98 then   --LE_PEER_KEEP_ALIVE_REQUEST
                if buf_len == le_pdu_len[opid] then
                    -- Application current/oldest
                    mode_bits_disp_ipsc_cap(t,buf(5,1))
                    service_bits_disp(t,buf(6,4),1,0)
                elseif buf_len == le_pdu_len[opid]+5 then
                    -- LCP
                    mode_bits_disp(t, buf(5,2))
                    service_bits_disp(t,buf(7,4),1,1)
                    Version_Disp(t,buf(11,4))
                end

                -- TODO: Does this need authentication?
            elseif opid == 0x99 then   --LE_PEER_KEEP_ALIVE_RESPONSE
                if buf_len == le_pdu_len[opid] then -- 10 Bytes
                    -- IPSC, Cap Plus, Application
                    mode_bits_disp_ipsc_cap(t,buf(5,1))
                    service_bits_disp(t,buf(6,4),1,0)
                elseif buf_len == le_pdu_len[opid]+5 then
                    -- LCP
                    mode_bits_disp(t, buf(5,2))
                    service_bits_disp(t,buf(7,4),1,1)
                    Version_Disp(t,buf(11,4))
                end

            elseif opid == 0x9e then   --LE_PEER_KEEP_ALIVE_BROADCAST
                --t = root:add(p_linkest, buf(0, buf_len))
                mode_bits_disp(t, buf(5,2))
                service_bits_disp(t, buf(7,4),1,1)
                t:add(f_leadingChanID, buf(11, 1))
                
                --cp_status_broadcast_disp(t,buf(12,34)) --modified by ngr468
                local dissector = Dissector.get("p2p")
                dissector:call(buf(12):tvb(), pkt, t)
                
                -- What is the 46th byte for??
                Version_Disp(t,buf(47,4))
                    
            elseif opid == 0x9f then------------START------- LE_DEREGISTRATION_PROXY_BROADCAST ----------
                DeregistrationID_Disp(t,buf(5,4))
                Version_Disp(t,buf(9,4))
            ------------------ LE_DEREGISTRATION_PROXY_BROADCAST ------END---------------------------

            elseif opid == 0x9a then   --LE_DEREGISTRATION_REQUEST
                if buf_len == le_pdu_len[opid]+10 then
                    -- IPSC/CapPlus/App with Authentication
                    t:add(f_auth, buf(5, 10))
                elseif buf_len == le_pdu_len[opid]+4 then
                    --LCP
                    Version_Disp(t,buf(5,4))
                elseif buf_len == le_pdu_len[opid]+14 then
                    --LCP w/ Authentication
                    Version_Disp(t,buf(5,4))
                    t:add(f_auth, buf(9, 10))
                end

            elseif opid == 0x9b then   --LE_DEREGISTRATION_RESPONSE
                if buf_len == le_pdu_len[opid]+10 then
                    -- IPSC/CapPlus/App with Authentication
                    t:add(f_auth, buf(5, 10))
                elseif buf_len == le_pdu_len[opid]+4 then
                    --LCP
                    Version_Disp(t,buf(5,4))
                elseif buf_len == le_pdu_len[opid]+14 then
                    --LCP w/ Authentication
                    Version_Disp(t,buf(5,4))
                    t:add(f_auth, buf(9, 10))
                end

            elseif opid == 0x93 then  --LE_NOTIFICATION_MAP_BROADCAST

                -- need to determine if the map is old or new
                local oldMapEntrySize = 11
                local newMapEntrySize = 13
                -- ngr468:
                total_map_len_old = nil
                total_map_len_old = buf(5,2):uint()
                
                if((buf_len - 7) == total_map_len_old) then
                    map_broadcast_old_maps_dissect(p_linkest, buf)
                else
                    map_broadcast_new_maps_dissect(p_linkest, buf)
                end
                
            elseif opid == 0xCC then   --LE_SITE_JOIN
                t = root:add(p_linkest, buf(0, buf_len))

                t:add(f_opcode, buf(0, 1))
                peerID_Disp(t, buf(1, 4))
                mode_bits_disp(t, buf(5,2))
                service_bits_disp(t, buf(7,4), 1, 1)
                
                -- P2P Site Rest Info
                local dissector = Dissector.get("p2p")
                dissector:call(buf(11):tvb(), pkt, t)
                
                Version_Disp(t,buf(buf:len() - 4,4))
                
                --[[ P2P Site Rest Info
                local d = t:add(f_sitejoin, buf(11,1))
                d:add(f_sitejoin_srcpeerid, buf(12,4))
                d:add(f_sitejoin_srcsiteid, buf(16,1))
                d:add(f_sitejoin_rest, buf(17,1))
                
                local g = d:add(f_sitejoin_talkgroups, buf(18,16))
                wide_tgs_decode(g, buf(18,16))                
                local m = d:add(f_sitejoin_srcofcalls, buf(34,2))
                src_calls_decode(m, buf(34, 2))
                
                d:add(f_kabroadcast_currlinkprotoversion, buf(36,2))
                d:add(f_kabroadcast_oldlinkprotoversion, buf(38,2))
                --]]

            elseif opid == 0xA5 then -- LE_SATELLITE_BURST
                t = root:add(p_linkest, buf(0, buf_len))

                t:add(f_opcode, buf(0,1))
                t:add(f_current, buf(1,1))
                voting_peerID_Disp(t, buf(2,4),1)
                t:add(f_voting_pduseqnum, buf(6,4))
                t:add(f_calltype, buf(10,1))
                t:add(f_voting_rsapriority, buf(11,1))
                t:add(f_voting_srcid, buf(12,4))
                t:add(f_voting_tgtid, buf(16,4))
                t:add(f_timestamp, buf(20,4))
                t:add(f_voting_chnlid, buf(24,1))
				
			elseif opid == 0xA0 then -- LE_BACKHAUL_DISCOVER
				Version_Disp(t, buf(5,4))
				t:add(f_role, buf(9,1))
				t:add(f_brstate,buf(10,1))
				mode_bits_disp_ipsc_cap(t, buf(11,1))
				service_bits_disp(t, buf(12, 4), 1, 0)
				t:add(f_slot1state,buf(16,1))
				t:add(f_slot2state,buf(17,1))
				t:add(f_forknum, buf(18,1))

            elseif opid == 0x30 then  -- LE_INTERM_RCVR_REGISTRATION_REQUEST
                -- Check if it's 16 or 8 bits in mode field
                if buf_len == (le_pdu_len[opid])  then -- 19 bytes, LCP
                    mode_bits_disp(t, buf(5,2))
                    service_bits_disp(t, buf(7,4), 1, 1)
                    voting_peerID_Disp(t, buf(11,4),0)
                    Version_Disp(t,buf(15,4))
                elseif buf_len == (le_pdu_len[opid] - 1) then -- 18 bytes, IPSC
                    mode_bits_disp_ipsc_cap(t,buf(5,1))
                    service_bits_disp(t, buf(6,4), 1, 1)
                    voting_peerID_Disp(t, buf(10,4),0)
                    Version_Disp(t,buf(14,4))
                end
            
            elseif opid == 0x31 then  -------------START-----------------LE_INTERM_DV_KEEP_ALIVE_REQ--
                local numofReceiver = (buf:len() -16) / 4 -- 16byte including opcode\mode\service\version.. 
                
                mode_bits_disp(t, buf(5,2))
                service_bits_disp(t, buf(7,4), 1, 1)
                t:add(f_leadingChanID, buf(11, 1))
                
                local receiver_index = 0
                local pos = 12
                local tn = t:add(f_voting_mapinfo, numofReceiver)
                while (receiver_index < numofReceiver) do 
                    RecieverID_Disp(tn,buf(pos,4))
                    pos = pos + 4
                    receiver_index = receiver_index + 1
                end
                Version_Disp(t,buf(pos,4))
            ---------------------------------------LE_INTERM_DV_KEEP_ALIVE_REQ-----END-----------------
            
            elseif opid == 0x32 then  -------------START--------LE_RRP_SATELLITE_ID_MAP----------------
                local Totalmaplen = buf(5, 2):uint()
                local peer_index = 1
                local pos = 0
                local numofVoter = 0
                
                t:add(f_maplen,  buf(5, 2))
                
                -- count the voter number.
                pos = 7
                while (pos < Totalmaplen + 7) do 
                    pos = pos + 4 -- 4 bytes: voter ID 
                    pos = 4 * buf(pos,1):uint() + pos
                    pos = pos + 1 -- 1 bytes: The number of satellites of Voter
                    numofVoter = numofVoter + 1
                end
                local ts = t:add(f_numvoters, numofVoter)
                
                -- voter ID and its satellite receiver id .
                
                local VoterIndex = 1
                pos = 7
                while (VoterIndex <= numofVoter) do 
                    local tc = ts:add(f_voterseq, buf(pos+1, 3))
                    tc:add(f_siteid, buf(pos, 1))
                    pos = pos + 1
                    --tc:add(f_remotepeerid, buf(pos, 3))
                    pos = pos + 3
                    local numofReceiver = buf(pos,1):uint()
       
                    local tn = tc:add(f_voting_mapinfo, buf(pos,1))
                    pos = pos + 1
                    
                    local receiver_index = 0
                    while (receiver_index < numofReceiver) do 
                        tn:add(f_siteid, buf(pos, 1))
                        pos = pos + 1
                        tn:add(f_remotepeerid, buf(pos, 3))
                        pos = pos + 3
                        receiver_index = receiver_index + 1
                    end
                    VoterIndex = VoterIndex + 1
                end 
                
                Version_Disp(t,buf(pos,4))
                
            ---------------------------------------LE_RRP_SATELLITE_ID_MAP-----END-----------------
            
            elseif opid == 0x33 then  ------------------START---LE_DIGITALVOTING_MAP_BROADCAST 
                local OneMapLen = 11 -- (ipse & cpc)/LCP 11/12
                local Totalmaplen = buf(6, 2):uint()
                local pos = 0

                local MapType = buf(5, 1):uint()
                t:add(f_maptype, buf(5, 1))
                t:add(f_maplen,  buf(6, 2)) 
                
                if (MapType == 0x08)    then -- "Satellite Map"
                    if( Totalmaplen / OneMapLen ~= 0) then 
                        OneMapLen = 12
                    end
                    local NumRceiver = Totalmaplen / OneMapLen - 1 --ReceiverNum + Voter(1) is the total Num of MAP.
                    
                    -----------------requested voter ID ADDR PORT MODE
                    pos = 9
                    local ts = t:add(f_RequestedVoterId, buf(pos, 3))
                    pos = pos + 3
                    ts:add(f_siteid, buf(8, 1))
                    ts:add(f_voting_ipaddr, buf(pos, 4))
                    pos = pos + 4 
                    ts:add(f_voting_port, buf(pos, 2))
                    pos = pos + 2
                    if (OneMapLen == 12) then -- LCP MODE 
                        mode_bits_disp(ts, buf(pos,2))
                        pos = pos + 2
                    else -- ipsc & cpc MODE
                        mode_bits_disp_ipsc_cap(ts, buf(pos,1))
                        pos = pos + 1
                    end 
                    
                    ------------------Satellite Receiver ID ADDR PORT MODE
                    local tn = ts:add(f_voting_mapinfo, NumRceiver)
                    local receiver_index = 0
                    while (receiver_index < NumRceiver) do 
                        local tt = tn:add(f_voting_satpeerid,buf(pos+1,3))
                        tt:add(f_voting_satsiteid, buf(pos, 1))
                        pos = pos + 4 -- 4 byte: peer ID      
                 
                        tt:add(f_voting_satipaddr, buf(pos,4))
                        pos = pos + 4 
                        tt:add(f_voting_satport, buf(pos, 2))
                        pos = pos + 2
                        
                        if (OneMapLen == 12) then -- LCP MODE 
                            mode_bits_disp(tt, buf(pos,2))
                            pos = pos + 2
                        else -- ipsc & cpc MODE
                            mode_bits_disp_ipsc_cap(tt, buf(pos,1))
                            pos = pos + 1
                        end 
                        receiver_index = receiver_index + 1
                    end
                    
                elseif (MapType == 0x10) then -- "Voter Map"
                
                    local RdacNum = buf(8, 1):uint()
                    local SatelliteNum = buf(9, 1):uint()
                    local TotalMapNum =  RdacNum + SatelliteNum
                    
                    if( OneMapLen * TotalMapNum ~= Totalmaplen - 2) then 
                        OneMapLen = 12  -- LCP MODE
                    end

                    -- RDAC MAP
                    local peer_index = 0
                    pos = 10
                    local tc = t:add(f_voting_rdac_mapinfo, RdacNum)
                    while (peer_index < RdacNum) do
                        local ts = tc:add(f_peermapindex, peer_index)
                        ts:add(f_siteid, buf(pos, 1))
                        pos = pos + 1
                        ts:add(f_remotepeerid, buf(pos, 3))
                        pos = pos + 3
                        ts:add(f_remotepeerip, buf(pos, 4))
                        pos = pos + 4
                        ts:add(f_remotepeerport, buf(pos, 2))
                        pos = pos + 2
                        if (OneMapLen == 12) then -- LCP MODE 
                            mode_bits_disp(ts, buf(pos,2))
                            pos = pos + 2
                        else -- ipsc & cpc MODE
                            mode_bits_disp_ipsc_cap(ts, buf(pos,1))
                            pos = pos + 1
                        end 
                        peer_index = peer_index + 1
                    end
                    
                    -- Satellite Peer MAP
                    local peer_index = 0
                    local tt = t:add(f_voting_mapinfo, SatelliteNum)
                    while (peer_index < SatelliteNum) do
                        local tn = tt:add(f_peermapindex, peer_index)
                        tn:add(f_siteid, buf(pos, 1))
                        pos = pos + 1
                        tn:add(f_remotepeerid, buf(pos, 3))
                        pos = pos + 3
                        tn:add(f_remotepeerip, buf(pos, 4))
                        pos = pos + 4
                        tn:add(f_remotepeerport, buf(pos, 2))
                        pos = pos + 2
                        if (OneMapLen == 12) then -- LCP MODE 
                            mode_bits_disp(tn, buf(pos,2))
                            pos = pos + 2
                        else -- ipsc & cpc MODE
                            mode_bits_disp_ipsc_cap(tn, buf(pos,1))
                            pos = pos + 1
                        end 
                        peer_index = peer_index + 1
                    end  
                end
                
                Version_Disp(t,buf(pos,4))
                ---------------------------------------LE_DIGITALVOTING_MAP_BROADCAST-----------------
            end
        end

        local info = nil

        if buf_len >= 5 then
               info = string.format("[%02X]%-31s Src Peer=%-6u Len=%-3u",
                                opid,
                                ((le_pdu[opid] ~= nil) and le_pdu[opid] or "Unknown LE opcode!") ,
                                peerid,
                                buf_len
                                )
            if t == nil then
                t = root:add(p_linkest, buf(0, 5))
                t:add(f_opcode, buf(0, 1))
                t:add(f_siteid, buf(1, 1))
                t:add(f_peerid, buf(2, 3))
            end
        end

        --if buf_len < le_pdu_len[opid] then
        --       info = info .. " Wrong message length!"
        --end

        if error_msg ~= nil then
            info = info .. " - "..error_msg;
        end

        pkt.cols.protocol:set("LE")
        pkt.cols.info:set(info)
    end

    --local udp_encap_table = DissectorTable.get("udp.port")
    --udp_encap_table:add(50000, p_linkest)  --replace with the real port used by link establishmnent

end
