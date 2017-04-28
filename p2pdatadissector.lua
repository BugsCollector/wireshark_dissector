--dissector for P2P F2 burst (DATA)
do
	p_f2burstdata = Proto("f2burstdata", "CYPHER F2 Burst (Data)")

	--Cypher  Burst data types
	local cbdts = {
		--Common to Inbound and Outbound data types (DSP Rx to RF modem, RF modem to DSP Tx)
		------------------------------------------------------------------------------------------------------------------------------
		[0] = "DATA_TYPE_ESYNC_HEADER",
		[1] = "DATA_TYPE_VOICE_HEADER",
		[2] = "DATA_TYPE_VOICE_TERMINATOR",
		[3] = "DATA_TYPE_CSBK",
		[4] = "DATA_TYPE_MBC_HEADER",
		[5] = "DATA_TYPE_MBC_CONT",
		[6] = "DATA_TYPE_DATA_HEADER",
		[7] = "DATA_TYPE_UNCONFIRM_DATA_CONT",
		[8] = "DATA_TYPE_CONFIRM_DATA_CONT",
		[10] = "DATA_TYPE_VOICE",

		--Inbound data types (DSP Rx to RF modem) only
		----------------------------------------------------------------
		[11] = "DATA_TYPE_CARRIER_DETECT",
		[12] = "DATA_TYPE_CARRIER_UNDETECT",
		[19] = "DATA_TYPE_SYNC_UNDETECT",
		[14] = "DATA_TYPE_REVERSE_CHANNEL",

		--Outbound data types (RF modem to DSP Tx) only
		------------------------------------------------------------------
		[9] = "DATA_TYPE_IDLE",
		[15] = "DATA_TYPE_EMB_LC",
		[16] = "DATA_TYPE_LC_IN_CACH",
		[17] = "DATA_TYPE_REVERSE_CHANNEL_ENCODE",		-- Outbound Reverse channel payload (and NOT RC ) to be encoded.
		[18] = "DATA_TYPE_OB_CONTROL_BITS",			-- To indicate that only EMB, Slot Type or RC are present and no payload is accompanied

	}


	local f_busrtdatatype = ProtoField.uint8("f2burstdata.burstdatatype", "Burst Data Type", base.HEX, cbdts)
	local f_burstdatastatus = ProtoField.uint8("f2burstdata.burstdatastatus", "Burst Data Status", base.HEX)
	local f_length = ProtoField.uint16("f2burstdata.burstdatalength", "Length", base.DEC)
	local f_embsigbits = ProtoField.uint16("f2burstdata.embsigbits", "Emb Sig Bits", base.HEX)
	local f_bustdatasize = ProtoField.uint16("f2burstdata.burstdatasize", "Cypher Burst Data Size", base.DEC)
	local f_burstdata = ProtoField.bytes("f2burstdata.burstdata", "Burst Data", base.HEX)
	local f_emb = ProtoField.bytes("f2burstdata.emb", "EMB", base.HEX)
	local f_slottype = ProtoField.bytes("f2burstdata.slottype", "Slot Type", base.HEX)
	local f_72emb1 = ProtoField.uint16("f2burstdata.72emb", "72-bit EMB LC", base.HEX)
	local f_72emb2 = ProtoField.uint16("f2burstdata.72emb", "72-bit EMB LC", base.HEX)
	local f_72emb3 = ProtoField.uint16("f2burstdata.72emb", "72-bit EMB LC", base.HEX)
	local f_72emb4 = ProtoField.uint16("f2burstdata.72emb", "72-bit EMB LC", base.HEX)
	local f_72emb5 = ProtoField.uint16("f2burstdata.72emb", "72-bit EMB LC", base.HEX)
	local f_orssi = ProtoField.uint16("f2burstdata.orrsi", "RSSI ", base.HEX)
	local f_oemblchardbit1 = ProtoField.uint16("f2burstdata.oemblchardbit1", "EMB LC Hard Bits ", base.HEX)
	local f_oemblchardbit2 = ProtoField.uint16("f2burstdata.oemblchardbit2", "EMB LC Hard Bits ", base.HEX)
	local f_osynchardbit1 = ProtoField.uint16("f2burstdata.osynchardbit1", "Sync Hard Bits ", base.HEX)
	local f_osynchardbit2 = ProtoField.uint16("f2burstdata.osynchardbit2", "Sync Hard Bits ", base.HEX)
	local f_osynchardbit3 = ProtoField.uint16("f2burstdata.osynchardbit2", "Sync Hard Bits ", base.HEX)
	local f_osynclocation = ProtoField.uint16("f2burstdata.osynclocation", "Sync Location ", base.HEX)
	local f_ocryptoreadybit1 = ProtoField.uint16("f2burstdata.ocryptoreadybit1", "CryptoParameters ", base.HEX)
	local f_ocryptoreadybit2 = ProtoField.uint16("f2burstdata.ocryptoreadybit2", "CryptoParameters ", base.HEX)
	local f_ocryptoreadybit3 = ProtoField.uint16("f2burstdata.ocryptoreadybit3", "CryptoParameters ", base.HEX)
	local f_destaddr = ProtoField.uint32("f2burstdata.dest", "Destination Address", base.DEC)
	local f_srcaddr = ProtoField.uint32("f2burstdata.src", "Source Address", base.DEC)
	local f_rsvd3 = ProtoField.uint32("f2burstdata.rsvd3", "Reserved", base.HEX)
	local f_ivkey = ProtoField.uint32("f2burstdata.ivkey", "IV Key", base.HEX)
	local f_crc = ProtoField.uint16("f2burstdata.ivkey", "Header CRC", base.HEX)
	local f_auth = ProtoField.bytes("f2burstdata.auth", "Authentication", base.HEX)

	p_f2burstdata.fields = {f_busrtdatatype, f_burstdatastatus, f_length, f_embsigbits, f_bustdatasize, f_burstdata, f_destaddr, f_srcaddr, f_rsvd3, f_ivkey, f_crc, f_emb, f_slottype, f_72emb1, f_72emb2, f_72emb3, f_72emb4, f_72emb5, f_orssi, f_oemblchardbit1, f_oemblchardbit2, f_osynchardbit1, f_osynchardbit2, f_osynchardbit3, f_osynclocation, f_ocryptoreadybit1, f_ocryptoreadybit2, f_ocryptoreadybit3, f_auth}


	function p_f2burstdata.dissector(buffer, pkt, t)

		---------------------------------------------------------------EMB SIG BITs definition
		local f_RSSI = ProtoField.bytes("f2burstdata.RSSI", "RSSI bit Present", base.HEX)
		local f_cryptoreadybit = ProtoField.bytes("f2burstdata.cryptoready", "CrytoReady bit Present", base.HEX)
		local f_burstsourcebit = ProtoField.uint8("f2burstdata.burstsourcebit", "Burst Source Bit", base.HEX)
		local f_ignoresigbits = ProtoField.uint8("f2burstdata.ignoresigbits", "Ignore Sig Bits", base.HEX)
		local f_synclocation = ProtoField.uint8("f2burstdata.synclocation", "Sync Location Bits Present", base.HEX)
		local f_emblchardbit = ProtoField.uint8("f2burstdata.emblchardbit", "EMB LC Hard Bits", base.HEX)
		local f_badvoiceburst = ProtoField.uint8("f2burstdata.badvoiceburst", "Bad Voice Burst", base.HEX)
		local f_cdet = ProtoField.uint8("f2burstdata.cdet", "CDET", base.HEX)
		local f_shbp = ProtoField.uint8("f2burstdata.shbp", "Sync Hard Bits Present", base.HEX)
		local f_nulllc = ProtoField.uint8("f2burstdata.nullc", "NULL LC", base.HEX)
		local f_emblc72 = ProtoField.uint8("f2burstdata.emblc72", "72-bit EMB LC", base.HEX)
		local f_slottypebit = ProtoField.uint8("f2burstdata.slottypebit", "Slot Type", base.HEX)
		local f_embbit = ProtoField.bytes("f2burstdata.emb", "EMB", base.HEX)
		local f_sync = ProtoField.uint8("f2burstdata.sync", "Sync", base.HEX)
		---------------------------------------------------------------end of EMB SIG BITs definition

		---------------------------------------------------------------Burst Data definition
		local f_opcode = ProtoField.bytes("f2burstdata.opcode", "Opcode", base.HEX)
		local f_reserved = ProtoField.bytes("f2burstdata.reserved", "Reserved", base.HEX)
		local f_response = ProtoField.bytes("f2burstdata.response", "Response", base.HEX)
		local f_desttype = ProtoField.bytes("f2burstdata.desttype", "Destination Type", base.HEX)
		local f_padding = ProtoField.bytes("f2burstdata.padding", "Padding", base.HEX)
		local f_sap = ProtoField.bytes("f2burstdata.sap", "Service Access Point", base.HEX)
		local f_btf = ProtoField.bytes("f2burstdata.btf", "Blocks to Follow", base.HEX)
		local f_allblocks = ProtoField.bytes("f2burstdata.allblocks", "All Blocks", base.HEX)
		local f_fsn = ProtoField.bytes("f2burstdata.fsn", "Fragment Sequence Number", base.HEX)
		local f_n_s = ProtoField.bytes("f2burstdata.n_s", "Packet Sequence # of the sender", base.HEX)
		local f_syncflag = ProtoField.bytes("f2burstdata.syncflag", "Sync Flag", base.HEX)
		local f_rsvd = ProtoField.bytes("f2burstdata.rsvd", "Reserved", base.HEX)
		local f_status = ProtoField.bytes("f2burstdata.status", "Status", base.HEX)
		local f_type = ProtoField.bytes("f2burstdata.type", "Type", base.HEX)
		local f_class = ProtoField.bytes("f2burstdata.class", "Class", base.HEX)
		local f_mfid = ProtoField.bytes("f2burstdata.mfid", "Manufacturer's ID", base.DEC)
		local f_opcode2 = ProtoField.bytes("f2burstdata.opcode2", "Opcode2", base.HEX)
		local f_alg_id = ProtoField.bytes("f2burstdata.alg_id", "Alg Id", base.HEX)
		local f_rsvd2 = ProtoField.bytes("f2burstdata.rsvd2", "Reserved2", base.HEX)
		local f_keyid = ProtoField.bytes("f2burstdata.keyid", "Key Id", base.DEC)
		---------------------------------------------------------------End of Burst Data definition



		local f2burstlen = buffer:len()
		local t1 = t:add(p_f2burstdata, buffer(0,f2burstlen))
		--local burstdatatype = buffer(0,1):uint()

		t1:add(f_busrtdatatype, buffer(0,1))
		t1:add(f_burstdatastatus, buffer(1,1))

		local length = buffer(2,2):uint()
		t1:add(f_length, buffer(2, 2))

		local pos

		if length > 0 then

			t1:add(f_embsigbits, buffer(4,2))

			---------------------------------------------------------------------EMB SIG BITS decode
			local embsigbits1 = buffer(4,1):uint()
			local embsigbits2 = buffer(5,1):uint()

			-- FIRST BYTE OF EMB SIG BITS

			--RSSI
			local rssibit = getbit(embsigbits1,7)
			local rssibitdesc = rssibit..".......".." = Rssi Bit Present : "..rssibit
			t1:add(f_RSSI, buffer(4,1), rssibitdesc)

			--CrytoReady Bit
			local cryptoready = getbit(embsigbits1, 5)
			local cryptoreadydesc = ".."..cryptoready..".....".." = CryptoReady Bit : "..cryptoready
			t1:add(f_cryptoreadybit, buffer(4,1), cryptoreadydesc)

			--Burst Source Bit
			local burstsrcb = getbit(embsigbits1, 4)
			local burstsrcbdesc = "..."..burstsrcb.."....".." = Burst Source Bit : "..burstsrcb
			t1:add(f_burstsourcebit, buffer(4,1), burstsrcbdesc)

			--Ignore Sig Bits
			local ignsigb= getbit(embsigbits1,3)
			local ignsigbdesc = "...."..ignsigb.."...".." = Ignore Sig Bits : "..ignsigb
			t1:add(f_ignoresigbits, buffer(4,1),ignsigbdesc)

			--Sync Location
			local synclocationbit = getbit(embsigbits1,2)
			local synclocationdesc = "....."..synclocationbit.."..".." = Sync Location Bits Present : "..synclocationbit
			t1:add(f_synclocation, buffer(4,1), synclocationdesc)

			--EMB LC Hard Bits
			local emblchardbit = getbit(embsigbits1,1)
			local emblchardbitdesc = "......"..emblchardbit..".".." = EMB LC Hard Bits : "..emblchardbit
			t1:add(f_emblchardbit, buffer(4,1), emblchardbitdesc)

			--Bad Voice Burst
			local badvoiceburst = getbit(embsigbits1,0)
			local badvoiceburstdesc = "......."..badvoiceburst.." = Bad Voice Burst : "..badvoiceburst
			t1:add(f_badvoiceburst, buffer(4,1), badvoiceburstdesc)

			------------------------------------------------------------------------------------------

			-- SECOND BYTE OF EMB SIG BITS

			--CDET
			local cdet = getbit(embsigbits2,7)
			local cdetdesc = cdet..".......".." = CDET : "..cdet
			t1:add(f_cdet, buffer(5,1), cdetdesc)

			--Sync Hard Bits Present
			local shbp = getbit(embsigbits2,6)
			local shbpdesc = "."..shbp.."......".." = Sync Hard Bits Present : "..shbp
			t1:add(f_shbp, buffer(5,1), shbpdesc)

			--NULL LC
			local nulllc = getbit(embsigbits2,5)
			local nulllcdesc = ".."..nulllc..".....".." = NULL LC : "..nulllc
			t1:add(f_nulllc, buffer(5,1), nulllcdesc)

			--72 Bit EMB LC
			local emblc72 = getbit(embsigbits2,4)
			local emblc72desc = "..."..emblc72.."....".." = 72-bit EMB LC : "..emblc72
			t1:add(f_emblc72, buffer(5,1), emblc72desc)

			--Slot Type
			local slottype = getbit(embsigbits2,3)
			local slottypedesc = "...."..slottype.."...".." = Slot Type : "..slottype
			t1:add(f_slottypebit, buffer(5,1), slottypedesc)

			--EMB
			local emb = getbit(embsigbits2,2)
			local embdesc = "....."..emb.."..".." = EMB : "..emb
			t1:add(f_embbit, buffer(5,1), embdesc)

			--Sync
			local sync = embsigbits2 % 0x10
			local tmp = sync % 0x40
			local sync = sync - tmp
			local syncb = {}
			syncb[0] = getbit(embsigbits2,1)
			syncb[1] = getbit(embsigbits2,0)
			local syncdesc = "......"..syncb[0]..syncb[1].." = SYNC : "..sync
			t1:add(f_sync, buffer(5,1), syncdesc)

			---------------------------------------------------------------------End of EMB SIG BITS

			local burstSize = buffer(6,2):uint()
			t1:add(f_bustdatasize, buffer(6,2))

			pos = 6+2

			---------------------------------------------------------------------Burst Data

			length = burstSize/8
			t_burstdata = t1:add(f_burstdata,buffer(pos, length))


			---------------------------------------------------------------------Burst Data decode

			-- Decode only if its a data header
			local datatype = (buffer(0,1):uint() % 0x80)
			local featureid = buffer(pos+1, 1):uint()
			
			if (datatype == 3) and (featureid == 0x6) then
				local csbk_dissector = Dissector.get("neptune_csbk")
	            if csbk_dissector ~= nil then
	                csbk_dissector:call(buffer(pos):tvb(), pkt, t_burstdata)
	            else
	                print("No csbk dissector found")
	            end
            
			elseif datatype == 6 then
				local octet0 = buffer(pos, 1):uint()
				local octet1 = buffer(pos+1, 1):uint()
				local octet2 = buffer(pos+2, 1):uint()
				local octet3 = buffer(pos+3, 1):uint()
				local octet8 = buffer(pos+8, 1):uint()
				local octet9 = buffer(pos+9, 1):uint()

				--Opcode
				local opcode1 = getbit(octet0,0)
				local opcode2 = getbit(octet0,1)
				local opcode3 = getbit(octet0,2)
				local opcode4 = getbit(octet0,3)
				local opcode = opcode4*8 + opcode3*4 + opcode2*2 + opcode1*1
				local opcodedesc = "Opcode : 0b"..opcode4..opcode3..opcode2..opcode1.." ("..opcode..")"
				t1:add(f_opcode, buffer(pos,1), opcodedesc)

				if opcode == 3 or opcode == 2 or opcode == 1 then
					--Reserved
					local reserved1 = getbit(octet0, 4)
					local reserved2 = getbit(octet0, 5)
					local reserveddesc = "Reserved : 0b"..reserved2..reserved1
					t1:add(f_reserved, buffer(pos,1), reserveddesc)

					--Response
					local response = getbit(octet0, 6)
					local responsedesc = "Response : "..response
					t1:add(f_response, buffer(pos,1), responsedesc)

					--Group or Individual Call
					local desttype = getbit(octet0, 7);
					local desttypedesc = "Destination / Call type : "..desttype
					t1:add(f_desttype, buffer(pos,1), desttypedesc)

					--Padding
					local padding1 = getbit(octet1, 0)
					local padding2 = getbit(octet1, 1)
					local padding3 = getbit(octet1, 2)
					local padding4 = getbit(octet1, 3)
					local paddingdesc = "Padding : 0b"..padding4..padding3..padding2..padding1
					t1:add(f_padding, buffer(pos+1,1), paddingdesc)

					--Service Access Point
					local sap1 = getbit(octet1, 4)
					local sap2 = getbit(octet1, 5)
					local sap3 = getbit(octet1, 6)
					local sap4 = getbit(octet1, 7)
					local sapdesc = "Service Access Point : 0b"..sap4..sap3..sap2..sap1
					t1:add(f_sap, buffer(pos+1,1), sapdesc)

					--Destination Address
					t1:add(f_destaddr, buffer(pos+2,3))

					--Source Address
					t1:add(f_srcaddr, buffer(pos+5,3))


					--Blocks To follow
					local btf1 = getbit(octet8, 0)
					local btf2 = getbit(octet8, 1)
					local btf3 = getbit(octet8, 2)
					local btf4 = getbit(octet8, 3)
					local btf5 = getbit(octet8, 4)
					local btf6 = getbit(octet8, 5)
					local btf7 = getbit(octet8, 6)
					local btf = btf7*64 + btf6*32 + btf5*16 + btf4*8 + btf3*4 + btf2*2 + btf1*1
					local btfdesc = "Blocks To Follow : 0b"..btf7..btf6..btf5..btf4..btf3..btf2..btf1.." ("..btf..")"
					t1:add(f_btf, buffer(pos+8,1), btfdesc)

					--All Blocks
					local allblocks = getbit(octet8,7)
					local allblocksdesc = "All Blocks: "..allblocks
					t1:add(f_allblocks, buffer(pos+8,1), allblocksdesc)


					--Confirmed
					if opcode == 3 then

						t1:append_text(" (Confirmed Data Header)")
						--fragment sequence number
						local fsn1 = getbit(octet9,0)
						local fsn2 = getbit(octet9,1)
						local fsn3 = getbit(octet9,2)
						local fsn4 = getbit(octet9,3)
						local fsn = fsn4*8 + fsn3*4 + fsn2*2 + fsn1*1
						local fsndesc = "Fragment Sequence Number : 0b"..fsn4..fsn3..fsn2..fsn1.." ("..fsn..")"
						t1:add(f_fsn, buffer(pos+9,1), fsndesc)

						--Packet sequence # of the sender
						local n_s1 = getbit(octet9,4)
						local n_s2 = getbit(octet9,5)
						local n_s3 = getbit(octet9,6)
						local n_s = n_s3*4 + n_s2*2 + n_s1*1
						local n_sdesc = "Packet Sequence # of the sender : 0b"..n_s3..n_s2..n_s1.." ("..n_s..")"
						t1:add(f_n_s, buffer(pos+9,1), n_sdesc)

						--Sync Flag
						local syncflag = getbit(octet9, 7)
						local syncflagdesc = "Sync Flag : "..syncflag
						t1:add(f_syncflag, buffer(pos+9,1), syncflagdesc)

					--Unconfirmed
					elseif opcode == 2 then

						t1:append_text(" (Unconfirmed Data Header)")
						--fragment sequence number
						local fsn1 = getbit(octet9,0)
						local fsn2 = getbit(octet9,1)
						local fsn3 = getbit(octet9,2)
						local fsn4 = getbit(octet9,3)
						local fsn = fsn4*8 + fsn3*4 + fsn2*2 + fsn1*1
						local fsndesc = "Fragment Sequence Number : 0b"..fsn4..fsn3..fsn2..fsn1.." ("..fsn..")"
						t1:add(f_fsn, buffer(pos+9,1), fsndesc)

						--Reserved
						local rsvd1 = getbit(octet9,4)
						local rsvd2 = getbit(octet9,5)
						local rsvd3 = getbit(octet9,6)
						local rsvd4 = getbit(octet9,7)
						local rsvd = rsvd4*8 + rsvd3*4 + rsvd2*2 + rsvd1*1
						local rsvddesc = "Reserved : 0b"..rsvd4..rsvd3..rsvd2..rsvd1.." ("..rsvd..")"
						t1:add(f_rsvd, buffer(pos+9,1), rsvddesc)

					--Response Header Block
					elseif opcode == 1 then

						t1:append_text(" (Response Header)")
						--Status
						local status1 = getbit(octet9,0)
						local status2 = getbit(octet9,1)
						local status3 = getbit(octet9,2)
						local status = status3*4 + status2*2 + status1*1
						local statusdesc = "Status : 0b"..status3..status2..status1.." ("..status..")"
						t1:add(f_status, buffer(pos+9,1), statusdesc)

						--Type
						local type1 = getbit(octet9,3)
						local type2 = getbit(octet9,4)
						local type3 = getbit(octet9,5)
						local type4 = getbit(octet9,6)
						local type = type4*8 + type3*4 + type2*2 + type1*1
						local typedesc = "Type : 0b"..type4..type3..type2..type1.." ("..type..")"
						t1:add(f_type, buffer(pos+9,1), typedesc)

						--Class
						local class = getbit(octet9,7)
						local classdesc = "Class : "..class
						t1:add(f_class, buffer(pos+9,1), classdesc)
					end

				-- Encrypted Data Header
				elseif opcode == 15 then

					t1:append_text(" (Encrypted Data Header)")

					--Service Access Point
					local sap1 = getbit(octet0, 4)
					local sap2 = getbit(octet0, 5)
					local sap3 = getbit(octet0, 6)
					local sap4 = getbit(octet0, 7)
					local sapdesc = "Service Access Point : 0b"..sap4..sap3..sap2..sap1
					t1:add(f_sap, buffer(pos,1), sapdesc)

					--Manufacturer's ID
					local mfiddesc = "Manufacturer's ID: "..octet1
					t1:add(f_mfid, buffer(pos+1,1), mfiddesc)

					--Opcode2
					local opcode2_1 = getbit(octet2,0)
					local opcode2_2 = getbit(octet2,1)
					local opcode2_3 = getbit(octet2,2)
					local opcode2_4 = getbit(octet2,3)
					local opcode2 = opcode2_4*8 + opcode2_3*4 + opcode2_2*2 + opcode2_1*1
					local opcode2desc = "Opcode2 : 0b"..opcode2_4..opcode2_3..opcode2_2..opcode2_1.." ("..opcode2..")"
					t1:add(f_opcode2, buffer(pos+2,1), opcode2desc)

					--Alg Id
					local alg_id1 = getbit(octet2,4)
					local alg_id2 = getbit(octet2,5)
					local alg_id3 = getbit(octet2,6)
					local alg_id = alg_id3*4 + alg_id3*2 + alg_id1*1
					local alg_iddesc = "Alg Id : 0b"..alg_id3..alg_id2..alg_id1.." ("..alg_id..")"
					t1:add(f_alg_id, buffer(pos+2,1), alg_iddesc)

					--Reserved2
					local rsvd2 = getbit(octet2, 7);
					local rsvd2desc = "Reserved2 : "..rsvd2
					t1:add(f_rsvd2, buffer(pos+2,1), rsvd2desc)

					--Key Id
					local keyiddesc = "Key Id: "..octet3
					t1:add(f_keyid, buffer(pos+3,1), keyiddesc)

					--Reserved3
					t1:add(f_rsvd3, buffer(pos+4,3))

					--IV Key
					t1:add(f_ivkey, buffer(pos+6,4))

				end

				-- CRC
				t1:add(f_crc, buffer(pos+10,2))


			end

			---------------------------------------------------------------------End of Burst Data decode

			---------------------------------------------------------------------End of Burst Data

			pos = pos + length

			--EMB
			t1:add(f_emb, buffer(pos, 1))

			--Slot Type
			t1:add(f_slottype, buffer(pos+1, 1))

			pos = pos + 2

			--CHECK for 72-bit EMB if it is present
			if emblc72 == 1 then
				t1:add(f_72emb1, buffer(pos, 2))
				t1:add(f_72emb2, buffer(pos+2, 2))
				t1:add(f_72emb3, buffer(pos+4, 2))
				t1:add(f_72emb4, buffer(pos+6, 2))
				t1:add(f_72emb5, buffer(pos+8, 2))
				pos = pos + 10;
			end

			--CHECK for RSSI if it is present
			if rssibit == 1 then
				if f2burstlen >= (pos + 2) then
					t1:add(f_orssi, buffer(pos, 2))
					pos = pos + 2;
				end	
			end

			--CHECK for EMB LC Hard Bits if it is present
			if emblchardbit == 1 then
				t1.add(f_oemblchardbit1, buffer(pos, 2))
				t1.add(f_oemblchardbit2, buffer(pos+2, 2))
				pos = pos + 4
			end

			--CHECK for Sync Hard Bits if it is present
			if shbp == 1 then
				t1.add(f_osynchardbit1, buffer(pos, 2))
				t1.add(f_osynchardbit2, buffer(pos+2, 2))
				t1.add(f_osynchardbit3, buffer(pos+4, 2))
				pos = pos + 6
			end

			--CHECK for Sync Location Bits if it is present
			if synclocationbit == 1 then
				t1.add(f_osynclocation, buffer(pos, 2))
				pos = pos + 2
			end

			--CHECK for Crypto Parameter Bits if it is present
			if cryptoready == 1 then
				t1.add(f_ocryptoreadybit1, buffer(pos, 2))
				t1.add(f_ocryptoreadybit2, buffer(pos, 2))
				t1.add(f_ocryptoreadybit3, buffer(pos, 2))
				pos = pos + 6
			end

		end

		if length == 0 then
			pos = 4
		end

		if pos < f2burstlen and pos+10 == f2burstlen then
				t1:add(f_auth, buffer(pos, 10))
			end
	end
end
