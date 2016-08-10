--dissector for CSBK

do
    local protoname = "Neptune CSBK"
    p_csbk = Proto("neptune_csbk", protoname)

    local csbk_opcodes = {
        [0x01] = "CSBK_NEIGHBOR_SITES",
        [0x03] = "CSBK_CHANNEL_GRANT",
        [0x05] = "CSBK_BUSY_QUEUE_GRANT",
        [0x06] = "CSBK_DATA_SERVICE",
        [0X0B] = "CSBK_EMERGENCY_ALERT",
        [0X0C] = "CSBK_DATA_POST_AMBLE",
        [0X0F] = "CSBK_CC_REDIRECT",
        [0X10] = "CSBK_NEG_RESP",
        [0X11] = "CSBK_CALL_REQUEST",
        [0x12] = "CSBK_ACKNOWLEDGEMENT",
        [0x13] = "CSBK_DATA_GO_AHEAD",
        [0x14] = "CSBK_REGISTRATION_REQ",
        [0x15] = "CSBK_DEREGISTRATION_REQ",
        [0x17] = "CSBK_BUSY_QUEUE_CANCEL",
        [0x18] = "CSBK_REGISTRATION_RESP",
        [0x19] = "CSBK_FULL_ESN_RESP",
        [0x1A] = "CSBK_EMERGENCY_RESP",
    }
    
    local feature_set_ids = {
        [0x06] = "TRIDENT_MFID",
    }

    local f_lastblock = ProtoField.new("Last Block", "neptune_csbk.lastblock", ftypes.UINT8,nil,base.DEC,0x80)
    local f_protectflag = ProtoField.new("Protect Flag", "neptune_csbk.protectflag", ftypes.UINT8,nil,base.DEC,0x40)
    local f_csbko = ProtoField.new("CSBK Opcode", "neptune_csbk.csbko",ftypes.UINT8,csbk_opcodes,base.HEX,0x3f)
    local f_fsid = ProtoField.new("Feature Set ID", "neptune_csbk.fsid", ftypes.UINT8, feature_set_ids, base.HEX)
    local f_srcid = ProtoField.new("Source ID", "neptune_csbk.srcid", ftypes.UINT24, nil, base.DEC)
    local f_dstid = ProtoField.new("Destination ID", "neptune_csbk.dstid", ftypes.UINT24, nil, base.DEC)
    local f_chnidx = ProtoField.new("Channel Index", "neptune_csbk.chnidx", ftypes.UINT8, nil, base.DEC, 0xf0)
    local f_chnidx2 = ProtoField.new("Channel Index", "neptune_csbk.chnidx", ftypes.UINT8, nil, base.DEC, 0x0f)
    local f_timeslot = ProtoField.new("Time Slot", "neptune_csbk.timeslot", ftypes.UINT8, nil, base.DEC, 0x08)
    local f_calldetails = ProtoField.new("Call Details", "neptune_csbk.calldetails", ftypes.UINT8, nil, base.HEX)
    local f_neighbor = ProtoField.new("Neighbor Site ID", "neptune_csbk.neighbor", ftypes.UINT8, nil, base.DEC)
    local f_srcnt = ProtoField.new("Site Reset Count", "neptune_csbk.srcnt", ftypes.UINT24, nil, base.DEC, 0x00000f)
    local f_networkd_id = ProtoField.new("Network ID", "neptune_csbk.netid", ftypes.UINT16, nil, base.HEX, 0xfff0)
    local f_reserved1 = ProtoField.new("Reserved", "neptune_csbk.reserved", ftypes.UINT8, nil, base.HEX, 0x07)
    local f_reserved2 = ProtoField.new("Reserved", "neptune_csbk.reserved", ftypes.UINT24, nil, base.DEC, 0xfffff0)
    local f_reserved3 = ProtoField.new("Reserved", "neptune_csbk.reserved", ftypes.UINT8, nil, base.HEX)
    local f_freq = ProtoField.new("Frequency File Version", "neptune_csbk.freqfilever", ftypes.UINT16, nil, base.HEX)
	
	local f_unit_id = ProtoField.new("Unit ID", "neptune_csbk.unit_id", ftypes.UINT24, nil, base.DEC)
    local f_group_id = ProtoField.new("Group ID", "neptune_csbk.group_id", ftypes.UINT24, nil, base.DEC)
    local f_reserved_byte2 = ProtoField.new("Reserved", "neptune_csbk.reserved", ftypes.UINT16, nil, base.HEX)
    local f_esn_index = ProtoField.new("ESN Index", "neptune_csbk.esn_index", ftypes.UINT8, nil, base.Hex, 0xC0)
    local f_flags = ProtoField.new("Flags", "neptune_csbk.flags", ftypes.UINT8, nil, base.Hex, 0x3F)
    local f_esn_byte_value = ProtoField.new("ESN Byte Value", "neptune_csbk.esn_byte_value", ftypes.UINT8, nil, base.Hex)
    local f_resp_paras = ProtoField.new("Response Parameters", "neptune_csbk.resp_paras", ftypes.UINT8, nil, base.Hex)
	local f_reserved_bit4 = ProtoField.new("Reserved", "neptune_csbk.reserved", ftypes.UINT8, nil, base.HEX, 0xF0)
	local f_data_info = ProtoField.new("Data Information", "neptune_csbk.datainfo", ftypes.UINT24, nil, base.DEC)
	local f_reason = ProtoField.new("NACK Reason", "neptune_csbk.reason", ftypes.UINT8, nil, base.HEX)
	local f_emer_alt_seq = ProtoField.new("Emergency Alert Seq Num", "neptune_csbk.emer_alt_seq", ftypes.UINT8, nil, base.HEX, 0xF0)
	local f_esn = ProtoField.new("ESN", "neptune_csbk.esn", ftypes.UINT32, nil, base.HEX)

    p_csbk.fields = {
        f_lastblock,
        f_csbko,
        f_protectflag,
        f_fsid,
        f_srcid,
        f_dstid,
        f_chnidx,
        f_timeslot,
        f_reserved1,
        f_calldetails,
        f_neighbor,
        f_reserved2,
        f_srcnt,
        f_reserved3,
        f_unit_id, 
        f_group_id,
        f_reserved_byte2,
        f_esn_index,
        f_flags,
        f_esn_byte_value,
        f_resp_paras,
        f_freq,
        f_reason,
		f_data_info
        }

    function p_csbk.dissector(buf, pkt, root)
        local csbklen = buf:len()
        local t = root:add(p_csbk, buf(0,csbklen))
        local csbko = bit.band(buf(0,1):uint(),0x3f)
        local desc = csbk_opcodes[csbko]

        pkt.cols.protocol:set(protoname)
        if desc == nil then
            pkt.cols.info:set("Unknown CSBK Opcode!")
        else
            pkt.cols.info:set(desc)
        end

        t:add(f_lastblock, buf(0,1))
        t:add(f_protectflag, buf(0,1))
        t:add(f_csbko, buf(0,1))
        t:add(f_fsid, buf(1,1))

        if csbko == 0x01 then
            t:add(f_neighbor,buf(2,1))
            t:add(f_neighbor,buf(3,1))
            t:add(f_neighbor,buf(4,1))
            t:add(f_neighbor,buf(5,1))
            t:add(f_neighbor,buf(6,1))
            t:add(f_reserved2,buf(7,3))
            t:add(f_srcnt,buf(7,3))
        elseif csbko == 0x03 or csbo == 0x1A then
            t:add(f_srcid,buf(2,3))
            t:add(f_dstid,buf(5,3))
            t:add(f_chnidx,buf(8,1))
            t:add(f_timeslot,buf(8,1))
            t:add(f_reserved1,buf(8,1))
            t:add(f_calldetails,buf(9,1))
        elseif csbko == 0x05 or csbko == 0x11 or csbko == 0x12 then
            t:add(f_srcid,buf(2,3))
            t:add(f_dstid,buf(5,3))
            t:add(f_calldetails,buf(8,1))
            t:add(f_reserved3,buf(9,1))
        elseif csbko == 0x06 then
            t:add(f_dstid,buf(2,3))
            t:add(f_chnidx,buf(5,1))
            t:add(f_timeslot,buf(5,1))
            t:add(f_reserved1, buf(5,1))
            t:add(f_calldetails,buf(6,1))
            t:add(f_data_info, buf(7,3))
        elseif csbko == 0x0B then
           	t:add(f_srcid,buf(2,3))
           	t:add(f_dstid,buf(5,3))
            t:add(f_calldetails,buf(8,1))
            t:add(f_emer_alt_seq, buf(9,1))
            t:add(f_reserved1, buf(9,1))
        elseif csbko == 0x0c then
            t:add(f_dstid,buf(2,3))
            t:add(f_calldetails,buf(5,1))
            t:add(f_data_info, buf(6,3))
            t:add(f_reserved2, buf(9,1))
         elseif csbko == 0x0E then
            t:add(f_dstid,buf(2,3))
            t:add(f_neighbor,buf(5,1))
            t:add(f_networkd_id, buf(6,2))
            t:add(f_chnidx2, buf(7,1))
            t:add(f_freq, buf(8,2))
        elseif csbko == 0x0F then
            t:add(f_dstid,buf(2,3))
            t:add(f_neighbor,buf(5,1))
            t:add(f_networkd_id, buf(6,2))
            t:add(f_chnidx2, buf(7,1))
            t:add(f_freq, buf(8,2))
        elseif csbko == 0x10 then
            t:add(f_srcid,buf(2,3))
            t:add(f_dstid,buf(5,3))
            t:add(f_calldetails,buf(8,1))
            t:add(f_reason,buf(9,1))
        elseif csbko == 0x13 then
        	t:add(f_srcid, buf(2,3))
        	t:add(f_calldetails,buf(5,1))
        	t:add(f_data_info, buf(6,3))
        	t:add(f_reserved1, buf(9,1))
        elseif csbko == 0x14 then
        	t:add(f_unit_id, buf(2,3))
        	t:add(f_group_id, buf(5,3))
        	t:add(f_esn_index, buf(8,1))
        	t:add(f_flags, buf(8,1))
        	t:add(f_esn_byte_value, buf(9,1))
        elseif csbko == 0x15 then
        	t:add(f_unit_id, buf(2,3))
        	t:add(f_group_id, buf(5,3))
        	t:add(f_reserved_byte2, buf(8,2))
        elseif csbko == 0x17 then
        	t:add(f_srcid,buf(2,3))
           	t:add(f_dstid,buf(5,3))
            t:add(f_calldetails,buf(8,1))
            t:add(f_reserved1, buf(9,1))
        elseif csbko == 0x18 then
        	t:add(f_unit_id, buf(2,3))
        	t:add(f_group_id, buf(5,3))
        	t:add(f_resp_paras, buf(8,1))
        	t:add(f_reserved_bit4, buf(9,1))
        	t:add(f_srcnt, buf(9,1))
        elseif csbko == 0x19 then
        	t:add(f_unit_id, buf(2,3))
        	t:add(f_esn, buf(5, 4))
        	t:add(f_reserved1, buf(9,1))
        end

    end

end
