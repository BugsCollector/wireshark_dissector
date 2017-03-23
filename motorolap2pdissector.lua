-- disector for Motorola P2P
do
	local p_motoP2P = Proto("MOT_P2P_LE", "Motorola P2P LE")
	local data_dis = Dissector.get("data")

	local protos = {
		[1] = Dissector.get("p2p"),
		[2] = Dissector.get("le"),
		[3] = Dissector.get("wireline"),
	}

	function p_motoP2P.dissector(buf, pkt, root)
		---------------
		g_info = ""
		---------------
		local pdu_id = buf(0, 1):uint()
		local pdu_id2 = buf(1, 1):uint()
		local proto_type = nil

		
		if pdu_id >= 0x30 and pdu_id <= 0x33 then -- Voting
		    proto_type = 2
		elseif pdu_id == 0xCC then
		    proto_type = 2
		elseif pdu_id >= 0x90 and pdu_id < 0xB0 then
		    proto_type = 2
		elseif pdu_id == 0xB2 then
        	proto_type = 3
		elseif pdu_id >= 0xA0 then
		    proto_type = 1
		elseif pdu_id == 0x30 then -- Emerald
		    user_define_dissector_name = "eml"	
		elseif pdu_id == 0x53 or pdu_id == 0x54 or pdu_id == 0x00 then		-- OTA PDU
		    user_define_dissector_name = "ota"
		elseif pdu_id < 0x90 then -- P2P
		    proto_type = 1
		else		-- Emerald Win32 Driver Input PDU
		    user_define_dissector_name = "em_win32_input"
		end

		local dissector = protos[proto_type]

		if dissector ~= nil then
		    dissector:call(buf(0):tvb(), pkt, root)
		elseif user_define_dissector_name ~= nil then
		    local selected_dissector = Dissector.get(user_define_dissector_name)
		    if selected_dissector ~= nil then
		        selected_dissector:call(buf(0):tvb(), pkt, root)
		    else
		        data_dis:call(buf(0):tvb(), pkt, root)
		    end
		else
			data_dis:call(buf(0):tvb(), pkt, root)
		end

	end

	local udp_encap_table = DissectorTable.get("udp.port")
	local ports = {}

	for i = 3000, 70000, 1 do
	   table.insert(ports, i)
	end

	for i, port in ipairs(ports) do   --replace with the real port used by p2p
		udp_encap_table:add(port, p_motoP2P)
	end

end
