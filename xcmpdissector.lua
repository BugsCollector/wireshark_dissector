--dissector for XCMP

do
	local p_xcmp = Proto("xcmp", "XCMP")

	local opcode_requst = {
		[0x0001] = "SOFTPOT",
		[0x0002] = "TRANSMIT_CONFIG",
		[0x0003] = "RECEIVE_CONFIG",
		[0x0004] = "TRANSMIT",
		[0x0005] = "RECEIVE",
		[0x0006] = "TX_POWER_LEVEL_INDEX",
		[0x0007] = "PREEMPHASIS_DEEMPHASIS",
		[0x0008] = "SQUELCH_CONTROL",
		[0x0009] = "VOLUME_OVERRIDE",
		[0x000A] = "RX_FREQUENCY",
		[0x000B] = "TX_FREQUENCY",
		[0x000C] = "ENTER_TEST_MODE",
		[0x000D] = "RADIO_RESET",
		[0x000E] = "RADIO_STATUS",
		[0x000F] = "VERSION_INFORMATION",
		[0x0010] = "MODEL_NUMBER",
		[0x0011] = "SERIAL_NUMBER",
		[0x0012] = "READ_UUID",
		[0x0013] = "ENCRYPTION_ALGID",
		[0x0014] = "DATA_XFER_TO_ENCRYPTION_MODULE",
		[0x0015] = "ENCRYPTION_MODULE_BOOT_MODE",
		[0x0016] = "RX_BER_CONTROL",
		[0x0017] = "RX_BER_SYNC_REPORT",
		[0x0019] = "DATECODE",
		[0x001A] = "AUTHCODE",
		[0x001B] = "FACTWARE_RX",
		[0x001C] = "AFC_CONTROL",
		[0x001D] = "ENCODE_VOICE",
		[0x001E] = "ATTENUATOR_CONTROL",
		[0x001F] = "FACTORY_INFO",
		[0x0020] = "ENCRYPTION_MODULE_SERIAL_NUMBER",
		[0x0021] = "EEPOT_SCREEN",
		[0x0029] = "LINK_QUALITY",
		[0x002B] = "LANGUAGE_PACK_CONTROL",
		[0x002C] = "LANGUAGE_PACK_INFO",
		[0x002D] = "GPS_DATA_XFER",
		[0x002E] = "SUPER_BUNDLE",
		[0x002F] = "GENERIC_OPTION_CONTROL",
		[0x0100] = "READ_ISH_ITEM",
		[0x0101] = "WRITE_ISH_ITEM",
		[0x0102] = "DELETE_ISH_IDS",
		[0x0103] = "DELETE_ISH_TYPES",
		[0x0104] = "READ_ISH_ID_SET",
		[0x0105] = "READ_ISH_TYPE_SET",
		[0x0106] = "ISH_PROGRAM_MODE",
		[0x0107] = "ISH_REORG_CONTROL",
		[0x0108] = "ISH_UNLOCK_PARTITION",
		[0x0109] = "CLONE_WRITE",
		[0x010A] = "CLONE_READ",
		[0x0200] = "ENTER_BOOT_MODE",
		[0x0300] = "READ_RADIO_KEY",
		[0x0301] = "UNLOCK_SECURITY",
		[0x0109] = "CLONE_WRITE",
		[0x010A] = "CLONE_READ",
		[0x0400] = "DEVICE_INIT_STATUS",
		[0x0401] = "DISPLAY_TEXT",
		[0x0402] = "INDICATOR_UPDATE",
		[0x0403] = "BACKLIGHT",
		[0x0404] = "GP_OUTPUT_UPDATE",
		[0x0405] = "PHYSICAL_USER_INPUT",
		[0x0406] = "VOLUME_CTRL",
		[0x0407] = "SPKR_CTRL",
		[0x0408] = "TX_PWR_LEVEL",
		[0x0409] = "TONE_CTRL",
		[0x040A] = "SHUTDOWN",
		[0x040B] = "LOCATION",
		[0x040C] = "MONITOR_CTRL",
		[0x040D] = "CHAN_SELECTION",
		[0x040E] = "MIC_CTRL",
		[0x040F] = "SCAN_CTRL",
		[0x0410] = "BATTERY_LEVEL",
		[0x0411] = "BRIGHTNESS",
		[0x0415] = "TX_CTRL",
		[0x0412] = "BUTTON_CONFIG",
		[0x0413] = "EMER_CTRL",
		[0x041B] = "SIG_DETECT",
		[0x041C] = "RMTE_RADIO_CTRL",
		[0x041D] = "DATA_SESSION",
		[0x041E] = "CALL_CTRL",
		[0x041F] = "MENU_NAVIGATION",
		[0x0421] = "DEVICE_CTRL_MOD",
		[0x0414] = "AUDIO_ROUTING",
		[0x0420] = "MENU_CONTROL",
		[0x042E] = "RADIO_ALARM_CONTROL",
		[0x042F] = "RADIO_OPERATION_STATE_CONTROL",
		[0x0438] = "NRI_CONTROL",
        }

	local opcode_mask = {
		[0x0000] = "REQ",
		[0x8000] = "REP",
		[0xB000] = "BRDCST",
	}

	local result_table = {
		[0x00] = "SUCCESS",
		[0x01] = "FAILURE",
		[0x02] = "INCORRECT_MODE",
		[0x03] = "OPCODE_NOT_SUPPORTED",
		[0x04] = "INVALID_PARAMETERS",
		[0x05] = "REPLY_TOO_BIG",
		[0x06] = "SECURITY_LOCKED",
	}

	local radio_operation_state_function = {
		[0x00] = "GET_CURRENT_RADIO_STATUS",
		[0x01] = "ENABLE_RADIO",
		[0x02] = "DISABLE_RADIO",
		[0x03] = "KNOCKDOWN_RADIO",
		[0x04] = "RM_KNOCKDOWN_RADIO",
	}


	local nri_type_table = {
		[0x00] = "DISABLE_SLOT",
		[0x01] = "ENABLE_SLOT",
		[0x02] = "TRIGGER_CWID",
		[0x03] = "SET_TRUNKING_SLC",
		[0x04] = "SLOT_IN_IDLE",
		[0x05] = "FCC_TYPE_I_DETECTED",
		[0x06] = "FCC_TYPE_II_DETECTED",
		[0x07] = "NO_FCC_DETECTED",
		[0x08] = "SET_EMERGENCY_CALL_HANG_TIMER",
		[0x09] = "SET_CONV_FALLBACK_TIMER",
		[0x0A] = "SET_CONV_FALLBACK_SLC",
		[0x0B] = "CANCEL_EMERGENCY_CALL_HANG_TIMER",
		[0x0C] = "QUERY_TIMER_PROFILE",
		[0x0D] = "SET_TIME_PROFILE",
		[0x0E] = "QUERY_FCC_STATUS",
		[0x0F] = "Query_CWID_STATUS",
		[0x10] = "SET_CONV_FALLBACK_BEACON_INTERVAL_DURATION",
		[0x11] = "SLOT_IN_CALL_HANG",
		[0x12] = "SET_PRIORITY_MONITOR_SLC",
		[0x13] = "UNSCHEDULED_PRIORITY_MONITOR_SLC",
		[0x14] = "TRIGGER_DIGITAL_CWID",
		[0x15] = "QUERY_DIGITAL_CWID_STATUS",
		[0x16] = "QUERY_CWID_CONFIG",
		[0x18] = "COLLISION_DETECTION"
	}

	local slot_num_table = {
		[0x00] = "SLOT_ONE",
		[0x01] = "SLOT_TWO",
		[0x03] = "BOTH_SLOT",
	}

	local dig_bsi_slot_num_table = {
		[0x01] = "SLOT_ONE",
		[0x02] = "SLOT_TWO",
	}

	local CWID_Status_table = {
		[0x00] = "CWID_SEND_SUCCESS",
		[0x01] = "CWID_NOT_CONFIGURED",
		[0x02] = "CWID_FAILED_FOR_ONGOING_CALL",
		[0x03] = "CWID_FAILED_NO_OUTB_IN_RD",
		[0x04] = "CWID_FAILED_FOR_UNKOWN_REASON",
	}

	local FCC_Status_table = {
		[0x00] = "NO_FCC_INTERFERENCE",
		[0x01] = "FCC_TYPE_I_EXISTS",
		[0x02] = "FCC_TYPE_II_EXISTS",
		[0x03] = "BOTH_FCC_I_II_EXISTS",
	}

	local bpeerstatus = {
		[0x00] = "DISABLED",
		[0x01] = "ENABLED",
		[0x02] = "KNOCKED_DOWN",
		[0x03] = "LOCKED",
	}

	local tras_act_slt_table = {
		[0x00] = "EITHER_SLOT",
		[0x01] = "SLOT_ONE",
		[0x02] = "SLOT_TWO",
	}

	local pm_slco_table = {
		[0xE] = "CONTROL_CHANNEL_PM_SLC",
		[0xF] = "TRUNKING_CHANNEL_PM_SLC"
	}

	local reason_table = {
		[0x0] = "CANCEL_PM_SLC_FOR_STOP_COMMAND",
		[0x1] = "CANCEL_PM_SLC_FOR_CHANNEL_IDLE"
	}

	local bsi_cfg = {
		[0x0] = "CWID_NOT_CONFIGURED",
		[0x1] = "ANALOG_CWID_CONFIGURED",
		[0x2] = "DIGITAL_CWID_CONFIGURED",
	}

	local opcode_table = {}

	for i, v in pairs(opcode_mask) do
		for j, w in pairs(opcode_requst) do
			opcode_table[ i + j ] = w .. "_" .. v
		end
	end


	local f_opcode = ProtoField.uint16("xcmp.opcode", "Opcode", base.HEX, opcode_table)
	local f_result = ProtoField.uint8("xcmp.result", "Result", base.HEX, result_table)

	local f_nri_type = ProtoField.uint8("xcmp.nri.type", "Type", base.HEX, nri_type_table)
	local f_rd_value = ProtoField.uint8("xcmp.nri.rd.value", "Disable Slot", base.HEX, slot_num_table)
	local f_dig_bsi_slot_num = ProtoField.uint8("xcmp.nri.digbsi.slot", "Trigger Digital CWID", base.HEX, dig_bsi_slot_num_table)
	local f_dig_bsi_cfg = ProtoField.uint8("xcmp.nri.digbsi.cfg", "Query CWID Configuration", base.HEX, bsi_cfg)
	local f_re_value = ProtoField.uint8("xcmp.nri.rd.value", "Enable Slot", base.HEX, slot_num_table)
	local f_four_bytes_value = ProtoField.uint32("four_bytes.value", "Value", base.HEX)
	local f_two_bytes_value =  ProtoField.uint16("two_bytes.value", "Value", base.HEX)
	local f_cancel_emer_slot_value =  ProtoField.uint8("xcmp.nri.cancel_emer_slot.value", "Cancelled Slot", base.HEX, slot_num_table)
	local f_pmslc_header = ProtoField.uint24("xcmp.nri.pmslc.header", "PM SLC Table Header", base.HEX)
	local f_pmslc_header_0 = ProtoField.uint24("xcmp.nri.pmslc.header.array0", "Array[0]", base.HEX)
	local f_pmslc_header_1 = ProtoField.uint24("xcmp.nri.pmslc.header.array1", "Array[1]", base.HEX)
	local f_pmslc_header_2 = ProtoField.uint24("xcmp.nri.pmslc.header.array2", "Array[2]", base.HEX)
	local f_pmslc_slco = ProtoField.uint8("xcmp.nri.pmslc.slco", "SLCO", base.HEX, pm_slco_table)
	local f_pmslc_cadence = ProtoField.uint8("xcmp.nri.pmslc.cadence", "Cadence", base.HEX)
	local f_pmslc_trasactslt = ProtoField.uint8("xcmp.nri.pmslc.trasactslt", "Transmit On Active Slot", base.HEX, tras_act_slt_table)
	local f_pmslc_table = ProtoField.bytes("xcmp.nri.pmslc.table", "PMSLC Item")
	local f_pmslc_table_tgid = ProtoField.uint24("xcmp.nri.pmslc.table.tgid", "Priority TGID", base.HEX)
	local f_pmslc_table_slot = ProtoField.uint8("xcmp.nri.pmslc.table.slot", "Time Slot", base.HEX, slot_num_table)
	local f_pmslc_table_repeaterid = ProtoField.uint8("xcmp.nri.pmslc.table.repeaterid", "Repeater ID", base.HEX)
	local f_pmslc_table_item_cnt = ProtoField.uint8("xcmp.nri.pmslc.cnt", "Item Cnt", base.HEX)
	local f_pmslc_reason = ProtoField.uint8("xcmp.nri.pmslc.reason", "Stop Reason", base.HEX, reason_table)

	local f_nri_brdcast_chn_idle_value = ProtoField.uint8("xcmp.nri.brdcast_chn_idle.value", "Idle Channel Slot", base.HEX, slot_num_table)
	local f_nri_brdcast_call_hang_value = ProtoField.uint8("xcmp.nri.brdcast_call_hang.value", "Call Hang Slot", base.HEX, slot_num_table)
	local f_nri_cwid_value = ProtoField.uint8("xcmp.nri.cwid.value", "CWID Status", base.HEX, CWID_Status_table)
	local f_nri_fcc_value = ProtoField.uint8("xcmp.nri.fcc.value", "FCC Status", base.HEX, FCC_Status_table)
	local f_radio_operation_func = ProtoField.uint8("xcmp.radio_operation_state_function.value", "State", base.DEC, radio_operation_state_function);
	local f_nri_set_timer_mask = ProtoField.uint8("xcmp.nri.set_time.mask", "Timer Mask", base.HEX);
	local f_bpeerstatus = ProtoField.uint8("xcmp.bpeerstatus", "Peer Status", base.HEX)
	local f_radio_operation = ProtoField.uint16("xcmp.radio_operation", "Radio Status", base.HEX)
	local f_nri_reserverd = ProtoField.uint8("xcmp.nri_reserved", "Reserved", base.HEX)
	local f_nri_grp_call_hang_value = ProtoField.uint16("xcmp.nri.set_time.grp_call", "Group Call Hang Value", base.HEX)
	local f_nri_pri_call_hang_value = ProtoField.uint16("xcmp.nri.set_time.pri_call", "Private Call Hang Value", base.HEX)
	local f_nri_emer_call_hang_value = ProtoField.uint16("xcmp.nri.set_time.emer_call", "Emergency Call Hang Value", base.HEX)
	local f_nri_sit_value = ProtoField.uint16("xcmp.nri.set_time.sit", "SIT Value", base.HEX)
	local f_nri_cfd_data_call_hang_value = ProtoField.uint16("xcmp.nri.set_time.cfd_data", "Confirmed Data Call Hang Value", base.HEX)
	local f_nri_csbk_call_hang_value = ProtoField.uint16("xcmp.nri.set_time.csbk", "CSBK Call Hang Value", base.HEX)
	local f_nri_tot = ProtoField.uint16("xcmp.nri.set_time.tot", "TOT Value", base.HEX)

	p_xcmp.fields = { f_opcode, f_result, f_nri_type, f_re_value, f_rd_value, f_four_bytes_value, f_two_bytes_value, f_cancel_emer_slot_value, f_nri_brdcast_chn_idle_value,
        	f_nri_brdcast_call_hang_value, f_nri_cwid_value, f_nri_fcc_value, f_radio_operation, f_radio_operation_func, f_pmslc_header, f_pmslc_header_0, f_pmslc_header_1, f_pmslc_header_2, f_pmslc_slco, f_pmslc_cadence, f_pmslc_trasactslt,
			f_pmslc_table, f_pmslc_table_tgid, f_pmslc_table_slot, f_pmslc_table_repeaterid, f_pmslc_table_item_cnt, f_pmslc_reason, f_dig_bsi_slot_num, f_dig_bsi_cfg, f_nri_set_timer_mask, f_nri_reserverd,
			f_nri_grp_call_hang_value, f_nri_pri_call_hang_value, f_nri_emer_call_hang_value, f_nri_sit_value, f_nri_cfd_data_call_hang_value, f_nri_csbk_call_hang_value, f_nri_tot
			}

	function p_xcmp.dissector(buf, pkt, root)
	       local buf_size = buf:len()
	       if buf_size < 2 then
	            return  -- error
	       end

	        local opcode = buf(0,2):uint()
	        local result = nil

              if opcode > 0x8000 and opcode < 0xB000 then
        	       if buf_size < 2 then
        	            return  -- error
        	       end
                     result = buf(2, 1):uint()
              end

		-- update the column info
		local info = string.format("[%04X]%-25s Len=%-3u%s",
		        opcode,
		        ((opcode_table[opcode] ~= nil) and opcode_table[opcode] or "Unknown XCMP opcode!") ,
		        buf_size,
		        (result ~= nil) and (" Result=".. result_table[result]) or ""
		        )


		pkt.cols.protocol:set("XCMP")
		pkt.cols.info:set(info)

		-- protocol detail
		local t = root:add(p_xcmp, buf(0, buf_size))
		t:add(f_opcode, buf(0, 2))

		if opcode > 0xB000 then
				if opcode == 0xB438 then	-- broadcasting
					t:add(f_nri_type, buf(2,1))
					local nri_type =  buf(2,1):uint()

					if nri_type == 0x4 then
						t:add(f_nri_brdcast_chn_idle_value, buf(3, 1))
					elseif nri_type == 0x11 then
						t:add(f_nri_brdcast_call_hang_value, buf(3, 1))
					elseif nri_type == 0x13 then
						t:add(f_pmslc_table_item_cnt, buf(3, 1))
						t:add(f_pmslc_reason, buf(4,1))
						local item_cnts = buf(3,1):uint()
						if item_cnts ~= 0 then
							for i = 0, item_cnts - 1, 1 do
								t:add(f_pmslc_table_tgid, buf(5 + i * 3, 3))
							end
						end
					end
				end

              	elseif opcode > 0x8000 then
                    t:add(f_result, buf(2,1))
					local buf_len = buf:len()

					if buf_len > 3 then
						if opcode == 0x8438 then	-- Reply
							t:add(f_nri_type, buf(3,1))
							local nri_type =  buf(3,1):uint()

							if nri_type == 0x2 then
								t:add(f_nri_cwid_value, buf(4,1))
							elseif nri_type == 0x3 then
							 	t:add(f_four_bytes_value, buf(4,4))
							elseif nri_type == 0xe then
								t:add(f_nri_fcc_value, buf(4,1))
							elseif nri_type == 0x14 then
								t:add(f_nri_cwid_value, buf(4,1))
							elseif nri_type == 0x16 then
								t:add(f_dig_bsi_cfg, buf(4, 1))
						 	end

						 elseif opcode == 0x842f then
						 	t:add(f_radio_operation_func, buf(3,1))
						 	local t1 = t:add(f_radio_operation, buf(4,2))
						 	local state =  buf(4,2):uint()
						 	local b_bit3 = getbit(state, 3)
						 	local b_bit2 = getbit(state, 2)
							local b_bit1 = getbit(state, 1)
							local b_bit0 = getbit(state, 0)
							local strBit3 = "............"..b_bit3.."... = Normal Repeat (0 means Hibernate) "
							t1:add(f_bpeerstatus, buf(4,2), strBit3)

							local strBit2 = "............."..b_bit2..".. = Unlock "
							t1:add(f_bpeerstatus, buf(4,2), strBit2)

							local strBit1 = ".............."..b_bit1..". = Repeat (0 means KnockDown) "
							t1:add(f_bpeerstatus, buf(4,2), strBit1)

							local strBit0 = "..............."..b_bit0.." = Disable "
							t1:add(f_bpeerstatus, buf(4,2), strBit0)
						end
					end

				elseif opcode == 0x0438 then
					t:add(f_nri_type, buf(2,1))
					local nri_type =  buf(2,1):uint()

					if nri_type == 0x0 then
						t:add(f_rd_value, buf(3,1))
					elseif nri_type == 0x1 then
						t:add(f_re_value, buf(3,1))
					elseif nri_type == 0x3 then
						t:add(f_four_bytes_value, buf(3,4))
					elseif nri_type == 0x8 then
						t:add(f_two_bytes_value, buf(3,2))
					elseif nri_type == 0x9 then
						t:add(f_two_bytes_value, buf(3,2))
					elseif nri_type == 0xA then
						t:add(f_four_bytes_value, buf(3,4))
					elseif nri_type == 0xB then
						t:add(f_cancel_emer_slot_value, buf(3,2))
					elseif nri_type == 0xD then
						local mask = t:add(f_nri_set_timer_mask, buf(3,1))

						local b_bit7 = getbit(buf(3,1):uint(), 7)
						local strBit7 = ""..b_bit7.."....... = Group Call Hang "
						mask:add(f_bpeerstatus, buf(3,1), strBit7)

						local b_bit6 = getbit(buf(3,1):uint(), 6)
						local strBit6 = "."..b_bit6.."...... = Private Call Hang "
						mask:add(f_bpeerstatus, buf(3,1), strBit6)

						local b_bit5 = getbit(buf(3,1):uint(), 5)
						local strBit5 = ".."..b_bit5.."..... = Emergency Call Hang "
						mask:add(f_bpeerstatus, buf(3,1), strBit5)

						local b_bit4 = getbit(buf(3,1):uint(), 4)
						local strBit4 = "..."..b_bit4..".... = SIT "
						mask:add(f_bpeerstatus, buf(3,1), strBit4)

						local b_bit3 = getbit(buf(3,1):uint(), 3)
						local strBit3 = "...."..b_bit3.."... = Confirmed Data Call Hang "
						mask:add(f_bpeerstatus, buf(3,1), strBit3)

						local b_bit2 = getbit(buf(3,1):uint(), 2)
						local strBit2 = "....."..b_bit2..".. = CSBK Call Hang "
						mask:add(f_bpeerstatus, buf(3,1), strBit2)

						local b_bit1 = getbit(buf(3,1):uint(), 1)
						local strBit1 = "......"..b_bit1..". = TOT "
						mask:add(f_bpeerstatus, buf(3,1), strBit1)

						local b_bit0 = getbit(buf(3,1):uint(), 0)
						local strBit0 = "......."..b_bit1.." = Reserved "
						mask:add(f_bpeerstatus, buf(3,1), strBit0)

						t:add(f_nri_reserverd, buf(4,1))
						t:add(f_nri_grp_call_hang_value, buf(5,2))
						t:add(f_nri_pri_call_hang_value, buf(7,2))
						t:add(f_nri_emer_call_hang_value, buf(9,2))
						t:add(f_nri_sit_value, buf(11,2))
						t:add(f_nri_cfd_data_call_hang_value, buf(13,2))
						t:add(f_nri_csbk_call_hang_value, buf(15,2))
						t:add(f_nri_tot, buf(17,2))

					elseif nri_type == 0x10 then
						t:add(f_four_bytes_value, buf(3,4))
					elseif nri_type == 0x12 then
						local t_header = t:add(f_pmslc_header, buf(3, 3))

						local t0 = t_header:add(f_pmslc_header_0, buf(3,1))
					 	local pmslc_slco = bit.band(buf(3,1):uint(), 0xF)
						t0:add(f_pmslc_slco, buf(3,1), pmslc_slco)

						local t1 = t_header:add(f_pmslc_header_1, buf(4,1))
						local pmslc_cadence = bit.band(buf(4,1):uint(), 0x7)
						local pmslc_transactslot = bit.rshift(bit.band(buf(4,1):uint(), 0x18), 0x3)

						local t_ca = t1:add(f_pmslc_cadence, buf(4,1), pmslc_cadence)
						if pmslc_cadence == 0  then
							t_ca:append_text(" (Stop Scheduling PMSLC)")
						end

						t1:add(f_pmslc_trasactslt, buf(4,1), pmslc_transactslot)

						local item_cnts = buf(5,1):uint()
						local t2 = t_header:add(f_pmslc_header_2, buf(5,1))
						if item_cnts ~= 0 then
							t2:append_text(" (Total Number of PM SLC Items)")
							local r = t:add(f_pmslc_table, buf(6, item_cnts * 4))
							for i = 0, item_cnts - 1, 1 do
								local s = r:add(f_pmslc_table, buf(6 + i * 4, 4))
								s:add(f_pmslc_table_tgid, buf(6 + i * 4, 3))
								local temp = buf(9 + i * 4, 1):uint()
								local temp_repeaterid = bit.band(temp, 0xF)
								local temp_slot = bit.band(bit.rshift(temp, 0x4), 0x1)
								s:add(f_pmslc_table_slot, buf(9 + i * 4, 1), temp_slot)
								s:add(f_pmslc_table_repeaterid, buf(9 + i * 4, 1), temp_repeaterid)
							end
						end
					elseif nri_type == 0x14 then
						t:add(f_dig_bsi_slot_num, buf(3,1))
					end

              elseif opcode == 0x42f then
				 t:add(f_radio_operation_func, buf(2,1))
              end

	end


        --local udp_encap_table = DissectorTable.get("udp.port")
	--udp_encap_table:add(50000,p_p2p)  --replace with the real port used by p2p
end

