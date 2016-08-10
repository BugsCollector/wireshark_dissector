--dissector for P2P F2 burst(Voice)
do
	p_f2burstvoice = Proto("f2burstvoice", "CYPHER F2 Burst (Voice)")

	local slotnumcode = {
			[0x00] = "SLOT 1",
			[0x01] = "SLOT 2",
		}



	local f_length = ProtoField.uint16("f2burstvoice.length", "Length", base.DEC)

	local f_burstdatastatus = ProtoField.uint8("f2burstvoice.burstdatastatus", "Burst Data Status", base.HEX)
	local f_burst_data_status = ProtoField.uint8("f2burstvoice.burst_data_status", "Burst Data Status", base.HEX)

	local f_embsigbits = ProtoField.uint8("f2burstvoice.embsigbits", "CYPHER EMB SIG BITS", base.HEX)
	local f_bustdatasize = ProtoField.uint16("f2burstdata.burstdatasize", "Cypher Burst Data Size", base.DEC)
	local f_burstdata = ProtoField.bytes("f2burstvoice.burstdata", "Burst Data", base.HEX)

	local f_voiceframe1  = ProtoField.bytes("f2burstvoice.voiceframe1", "Voice Frame 1", base.HEX)
	local f_voiceframe2  = ProtoField.bytes("f2burstvoice.voiceframe2", "Voice Frame 2", base.HEX)
	local f_voiceframe3  = ProtoField.bytes("f2burstvoice.voiceframe3", "Voice Frame 3", base.HEX)

	local f_emblchardbits = ProtoField.uint32("f2burstvoice.emblchardbits", "EMB LC HARD BITS", base.HEX)
	local f_emb = ProtoField.uint8("f2burstvoice.emb", "EMB", base.HEX)
	local f_slottype = ProtoField.uint8("f2burstvoice.slottype", "Slot Type", base.HEX)
	local f_emblc = ProtoField.bytes("f2burstvoice.emblc", "EMB LC", base.HEX)

	local f_emblcmanid = ProtoField.uint8("f2burstvoice.manufactureid", "Manufacture's ID", base.HEX, {[0x00] = "Standard Feature", [0x10] = "Motorola Proprietary Feature"})
	local f_ivkey = ProtoField.uint32("f2burstvoice.ivkey", "IV Key", base.HEX)
	local f_destaddr = ProtoField.uint32("f2burstvoice.destaddr", "Destination Address", base.HEX)
	local f_crc = ProtoField.uint16("f2burstvoice.crc", "Header CRC", base.HEX)
	local f_auth = ProtoField.bytes("f2burstvoice.auth", "Authentication", base.HEX)

	p_f2burstvoice.fields = {f_burstdatastatus, f_length, f_embsigbits, f_bustdatasize, f_burstdata, f_mfid, f_ivkey, f_destaddr,  f_voiceframe1, f_voiceframe2, f_voiceframe3, f_emblchardbits, f_emb, f_slottype, f_emblc, f_emblcmanid, f_emblctga, f_emblcsga, f_crc, f_auth}

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
		[13] = "DATA_TYPE_SYNC_UNDETECT",
		[14] = "DATA_TYPE_REVERSE_CHANNEL",

		--Outbound data types (RF modem to DSP Tx) only
		------------------------------------------------------------------
		[9] = "DATA_TYPE_IDLE",
		[15] = "DATA_TYPE_EMB_LC",
		[16] = "DATA_TYPE_LC_IN_CACH",
		[17] = "DATA_TYPE_REVERSE_CHANNEL_ENCODE",		-- Outbound Reverse channel payload (and NOT RC ) to be encoded.
		[18] = "DATA_TYPE_OB_CONTROL_BITS",			-- To indicate that only EMB, Slot Type or RC are present and no payload is accompanied

	}

	p_f2emblc = Proto("f2emblc", "EMB LC")


	function p_f2burstvoice.dissector(buffer, packet, t)
		local f_slotnum = ProtoField.bytes("f2burstvoice.slotnum", "SLOT NUM", base.HEX, slotnumdisp,  0x80)  --This definition should be put into the function, otherwise may not work
		p_f2burstvoice.fields = {f_slotnum}

		local f_burstdatatype = ProtoField.uint8("f2burstvoice.burstdatatype", "BURST DATA TYPE", base.HEX, {[0x00] = "DETECTED", [0x01] = "UNDETECTED",},  0x7f)
		p_f2burstvoice.fields = {f_burstdatatype}

		local length
		local burstSize

		---------------------------------------------------------------EMB SIG BITs definition for Voice Header and Terminator
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
		--local f_embbit = ProtoField.uint8("f2burstdata.emb", "EMB", base.HEX)
		local f_sync = ProtoField.uint8("f2burstdata.sync", "Sync", base.HEX)
		---------------------------------------------------------------end of EMB SIG BITs definition

		---------------------------------------------------------------EMB SIG BITs definition for Voice burst A,B,C,D,E,F
		local f_emblcparity = ProtoField.uint8("f2burstvoice.emblcparity", "Embedded LC Parity", base.HEX)
		local f_embsync = ProtoField.uint8("f2burstvoice.embsync", "Sync", base.HEX)
		--local f_nulllc = ProtoField.uint8("f2burstvoice.nulllc", "NULL LC", base.HEX)
		local f_72bitemblc = ProtoField.uint8("f2burstvoice.72bitemblc", "72 Bit EMB LC", base.HEX)
		--local f_ignoresigbits = ProtoField.uint8("f2burstvoice.ignoresigbits", "Ignore Sig Bits", base.HEX)
		--local f_embbit = ProtoField.uint8("f2burstvoice.embbit", "EMB Bit Sig", base.HEX)
		local f_emblchbitsig = ProtoField.uint8("f2burstvoice.emblchbitsig", "EMB LC Hard Bits Sig", base.HEX)
		--local f_badvoiceburst = ProtoField.uint8("f2burstvoice.badvoiceburst", "Bad Voice Burst", base.HEX)
		---------------------------------------------------------------end of EMB SIG BITs definition

		local f_bv1 = ProtoField.ubytes("f2burstvoice.bv1", "BV", base.HEX)
		local f_bv2 = ProtoField.ubytes("f2burstvoice.bv2", "BV", base.HEX)

		----------------EMB LC Decode
		local f_emblcpf = ProtoField.ubytes("f2burstvoice.emblcpf", "Link Control Protection Flag", base.HEX)
		local f_emblcsf = ProtoField.ubytes("f2burstvoice.emblcsf", "MFID format", base.HEX)
		local f_emblcopcode = ProtoField.ubytes("f2burstvoice.emblcopcode", "Operand code", base.HEX)

		local f_emblcseroption = ProtoField.ubytes("f2burstvoice.serviceoption", "Service Option", base.HEX)
		local f_seropemergency = ProtoField.ubytes("f2burstvoice.seropemergency", "Emergency", base.HEX)
		local f_seropprivacy = ProtoField.ubytes("f2burstvoice.seropprivacy", "Privacy", base.HEX)
		local f_seropbroadcast = ProtoField.ubytes("f2burstvoice.seropbroadcast", "Broadcast", base.HEX)
		local f_seropovcm = ProtoField.ubytes("f2burstvoice.seropovcm", "Open Voice Call Mode", base.HEX)
		local f_seropprioritylev = ProtoField.ubytes("f2burstvoice.seropprioritylev", "Priority Level", base.HEX)

		local f_emblctga = ProtoField.uint24("f2burstvoice.emblctargegrpaddr", "Target Group Address", base.HEX)
		local f_emblcsga = ProtoField.uint24("f2burstvoice.emblcsourcegrpaddr", "Source Group Address", base.HEX)

		----------------

		----------------Burst Data Definition for LC Message or PI header
		local f_algid = ProtoField.ubytes("f2burstvoice.algid", "Alg Id", base.HEX)
		local f_rsvd1 = ProtoField.ubytes("f2burstvoice.rsvd1", "Reserved", base.HEX)
		local f_rsvd2 = ProtoField.ubytes("f2burstvoice.rsvd2", "Reserved", base.HEX)
		local f_gi = ProtoField.ubytes("f2burstvoice.gi", "Gi Bit", base.HEX)
		local f_mfid = ProtoField.bytes("f2burstvoice.mfid", "Manufacturer's ID", base.DEC)
		local f_keyid = ProtoField.bytes("f2burstvoice.keyid", "Key ID", base.HEX)
		----------------


		------------------EMB
		local f_colorcode = ProtoField.ubytes("f2burstvoice.colorcode", "Color Code", base.HEX)
		local f_eeei = ProtoField.ubytes("f2burstvoice.eeei", "End-to-End Encryption Indicator", base.HEX)
		local f_lcss = ProtoField.ubytes("f2burstvoice.lcss", "LC Start-Stop ", base.HEX)

		-------------------
		local f2burstlen = buffer:len()
		local t1 = t:add(p_f2burstvoice, buffer(0,f2burstlen))
		
		local datatype = (buffer(0,1):uint() % 0x80)
		local datatypestr = cbdts[datatype]

		--SLOT NUM
		local slotnum = 1
		local slotdesc = nil
		
		if datatype == 10 then
			slotnum = ((((buffer(0,1):uint())/ 0x80) >= 1) and 1 or 0)
			slotdesc = slotnum..".......".." = Slot number : "..slotnumcode[slotnum]
			t1:add(f_slotnum, buffer(0,1), slotdesc)
		else
			slotnum = ((((buffer(1,1):uint())/ 0x80) >= 1) and 1 or 0)
			slotdesc = "Slot number : "..slotnumcode[slotnum]
			t1:add(f_slotnum, buffer(1,1), slotdesc)
		end
		
		--CYPHER BURST DATA TYPE
		if datatype == 1 then
			t1:append_text(" (Voice Header)")
		elseif datatype == 2 then
			t1:append_text(" (Voice Terminator)")
		elseif datatype == 0 then
			t1:append_text(" (Encrypted Voice Header / PI Header)")
		else
			print("")
		end
		if datatypestr == nil then
			datatypestr = "Unknown"
		end
		
		
		local b = {}
		for i = 7, 1, -1 do
			b[7-i] = ((((datatype % (2^i)) / (2^(i-1))) >= 1) and 1 or 0)
		end
		local datatypedesc = "."
		for i = 0, 6, 1 do
			datatypedesc = datatypedesc..b[i]
		end
		
		if datatype == 10 then
			datatypedesc = datatypedesc.." = Cypher Burst Data Type : "..datatypestr
		else
			datatypedesc = "Cypher Burst Data Type : "..datatypestr
		end
		t1:add(f_burstdatatype, buffer(0, 1), datatypedesc)

		if datatype == 1 or datatype == 2 or datatype == 0 then
			--BURST DATA STATUS
			local t_status = t1:add(f_burstdatastatus, buffer(1,1))
			local state =  buffer(1,1):uint()
			local strBit2 = nil
			local strBit1 = nil
			local strBit0 = nil
			local b_bit2 = getbit(state,2)
			local b_bit1 = getbit(state,1)
			local b_bit0 = getbit(state,0)
			
			strBit2 = "....."..b_bit2..".. = RS Parity " 
			t_status:add(f_burst_data_status, buffer(1,1), strBit2)
			strBit1 = "......"..b_bit1..". = CRC Parity " 
			t_status:add(f_burst_data_status, buffer(1,1), strBit1)
			strBit0 = "......."..b_bit0.." = EMBLC Parity " 
			t_status:add(f_burst_data_status, buffer(1,1), strBit0)

			--BURST LENGTH
			length = buffer(2,2):uint()
			t1:add(f_length, buffer(2,2))

			--CYPHER BURST EMB SIG BITS
			t1:add(f_embsigbits, buffer(4, 2))

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
			--BURST DATA SIZE
			burstSize = buffer(6,2):uint()
			t1:add(f_bustdatasize, buffer(6,2))

		else
			--BURST LENGTH
			length = buffer(1,1):uint()
			t1:add(f_length, buffer(1,1))

			--CYPHER BURST EMB SIG BITS
			t1:add(f_embsigbits, buffer(2, 1))
			

			---------------------------------------------------------------------------------------------------EMB SIG BITS
			--EMBEDED LC PARITY
			local paritycode = {[0] = "Passed", [1] = "Failed",}
			local parity = (((buffer(2,1):uint() / 0x80) >= 1) and 1 or 0)
			local paritydesc = parity..".......".." = Embedded LC Parity : "..paritycode[parity]
			t1:add(f_emblcparity, buffer(2,1), paritydesc)

			--SYNC
			local sync = ((((buffer(2,1):uint() % 0x80) / 0x40) >= 1) and 1 or 0)
			local syncdesc = "."..sync.."......".." = SYNC : "..sync
			t1:add(f_embsync, buffer(2,1), syncdesc)


			--NULL LC
			local nulllccode = {[0] = "0", [1] = "Reverse channel data present",}
			local nulllc = ((((buffer(2,1):uint() % 0x40) / 0x20) >= 1) and 1 or 0)
			local nulllcdesc = ".."..nulllc..".....".." = NULL LC : "..nulllccode[nulllc]
			t1:add(f_nulllc, buffer(2,1), nulllcdesc)

			--72 BIT EMB LC
			local stbitemblc = ((((buffer(2,1):uint() % 0x20) / 0x10) >= 1) and 1 or 0)
			local stbitemblcdesc = "..."..stbitemblc.."....".." = 72 Bit EMB LC : "..stbitemblc
			t1:add(f_72bitemblc, buffer(2,1), stbitemblcdesc)

			--IGNORE SIG BITS
			local isbcode = {[0] = "0", [1] = "ARM will ignore all signaling in the burst",}
			local ignoresigbit = ((((buffer(2,1):uint() % 0x10) / 0x08) >= 1) and 1 or 0)
			local ignoresigbitdesc = "...."..ignoresigbit.."...".." = Ignore Sig Bits : "..isbcode[ignoresigbit]
			t1:add(f_ignoresigbits, buffer(2,1), ignoresigbitdesc)

			--EMB(EMBSIGBITS)
			local embbit = ((((buffer(2,1):uint() % 0x08) / 0x04) >= 1) and 1 or 0)
			local embbitdesc = "....."..embbit.."..".." = EMB : "..embbit
			t1:add(f_embbit, buffer(2,1), embbitdesc)

			--EMB LC HARD BITS SIG
			local elhbsig =  ((((buffer(2,1):uint() % 0x04) / 0x02) >= 1) and 1 or 0)
			local elhbsigdesc = "......"..elhbsig..".".." = Emb LC Hard Bits : "..elhbsig
			t1:add(f_emblchbitsig, buffer(2,1), elhbsigdesc)

			--BAD VOICE BURST
			local bvbcode = {[0] = "0", [1] = "FEC decoder detected too many errors to correct",}
			local badvoiceburst = (((buffer(2,1):uint() % 0x02) == 1) and 1 or 0)
			local badvoiceburstdesc = "......."..badvoiceburst.." = Bad Voice Burst : "..bvbcode[badvoiceburst]
			t1:add(f_badvoiceburst, buffer(2,1), badvoiceburstdesc)

			--------------------------------------------------------------------------------------------------------End of EMB SIG BITS

		end

		--BURST determination
		if length == 20 or length == 25 or length == 34 or length == 10 then
			if length == 20 then	--BURST A
				t1:append_text(" (BURST A)")
			elseif length == 25 then 	--BURST B
				t1:append_text(" (BURST B,C,D,F)")
			elseif length == 34 then
				t1:append_text(" (BURST E)")
			else
				print("Invalid burst type")
			end

			if length ~= 10 then
				--Frame 1
				t1:add(f_voiceframe1, buffer(3,7))

				-- First BV
				local bv1 = buffer(9,1):uint()
				bv1 = ((((bv1 % 0x80)/0x40) >= 1) and 1 or 0)
				local bv1desc = "."..bv1.."......".." = BV : "..bv1
				t1:add(f_bv1, buffer(9,1), bv1desc)

				--Frame 2
				t1:add(f_voiceframe2, buffer(9, 7))

				--Second BV
				local bv2 = buffer(15,1):uint()
				bv2 = ((((bv2 % 0x20) / 0x10) >= 1) and 1 or 0)
				local bv2desc = "..."..bv2.."....".." = BV : "..bv2
				t1:add(f_bv2, buffer(15,1), bv2desc)

				--Frame 3
				t1:add(f_voiceframe3, buffer(15, 7))

				if ((f2burstlen > 22) and (f2burstlen == 22+10)) then
					t1:add(f_auth, buffer(22, 10))
				end
			end

			if length == 25 then 	--BURST B,C,D,F
				print("Burst B entry")
				t1:add(f_emblchardbits, buffer(22, 4))
				t1:add(f_emb, buffer(26,1))

				-------------------------------------------------------------------------------EMB
				--Color code
				local tmp = buffer(26,1):uint() % 0x10
				local colorcode = (buffer(26,1):uint() - tmp) / 0x10
				local cc = {}
				cc[0] = (((buffer(26,1):uint() / 0x80) >= 1) and 1 or 0)
				for i = 6, 4, -1 do
					cc[6-i+1] = getbit(buffer(26,1):uint(), i)
				end
				local ccdesc = cc[0]
				for i = 1,3, 1 do
					ccdesc = ccdesc..cc[i]
				end
				ccdesc = ccdesc.."....".." = Color Code : "..colorcode
				t1:add(f_colorcode, buffer(26,1), ccdesc)

				--End-to-End Encryption Indicatior
				local eeeistr = {[0] = "End to End encryption not used on voice",
						[1] = "End to End encryption used on voice",}
				local eeei = getbit(buffer(26,1):uint(), 3)
				local eeeidesc = "...."..eeei.."...".." = EEEI : "..eeeistr[eeei]
				t1:add(f_eeei, buffer(26,1), eeeidesc)

				--LCSS
				local lcss = buffer(26,1):uint() % 0x08
				tmp = lcss % 0x02
				lcss = (lcss - tmp) / 0x02

				local lcsscode = {
					[0] = "Single fragment LC Packet",
					[1] = "First fragment of an LC Packet",
					[2] = "Last fragment of an LC Packet",
					[3] = "Continuation fragment of an LC Packet",
				}
				local lcssb = {}
				lcssb[0] = getbit(buffer(26,1):uint(), 2)
				lcssb[1] = getbit(buffer(26,1):uint(), 1)
				local lcssdesc = "....."..lcssb[0]..lcssb[1]..".".." = LC Start/Stop : "..lcsscode[lcss]
				t1:add(f_lcss, buffer(26,1), lcssdesc)
				-------------------------------------------------------------------------------EMB

				if ((f2burstlen > 27) and (f2burstlen == 27+10)) then
					t1:add(f_auth, buffer(27, 10))
				end

			elseif length == 34 then	--BURST E
				t1:add(f_emblchardbits, buffer(22, 4))
				--t1:add(f_emblc, buffer(26,9))
				local t1c = t1:add(p_f2emblc, buffer(26,9))

				-------------------------------------------------------------------------------EMB LC
				--Endian fix for this part
				local tmplc = {}
				for i = 0, 8, 1 do
					tmplc[i] = buffer(26+i,1):uint()
				end
				wordswap(tmplc, 9)


				--PF
				local pfcode = {[0] = "Un-Scrambled", [1] = "Scrambled",}
				local pf = getbit(tmplc[0], 7)
				local pfdesc = pf..".......".." = Link Control Protection Flag : "..pfcode[pf]
				t1c:add(f_emblcpf, buffer(27,1), pfdesc)

				--SF
				local sfcode = {[0] = "Implicit MFID Format", [1] = "Explicit MFID Format",}
				local sf = getbit(tmplc[0], 6)
				local sfdesc = "."..sf.."......".." = MFID Format : "..sfcode[sf]
				t1c:add(f_emblcsf, buffer(27,1), sfdesc)

				--Operand code
				local opcodecode = {[0x0] = "Group Voice Call", [0x03] = "Individual Voice Call",}
				local elopcode = tmplc[0] % 0x40
				local elopcodestr = opcodecode[elopcode]

				if elopcodestr == nil then
					elopcodestr = "Unknown"
				end

				local opbits = {}
				for i = 6, 1, -1 do
					opbits[6-i] = getbit(tmplc[0], i-1) --((((buffer(26,1):uint() % (2 ^ i)) / (2 ^ (i-1))) >= 1) and 1 or 0)
				end

				local elopcodedesc = ".."
				for i = 0, 5, 1 do
					elopcodedesc = elopcodedesc..opbits[i]
				end

				elopcodedesc = elopcodedesc.." = Operand Code : "..elopcodestr
				t1c:add(f_emblcopcode, buffer(27,1), elopcodedesc)


				--Manufacture's Id
				t1c:add(f_emblcmanid, buffer(26,1)) --tmplc[1]

				--Service Option
					--Emergency Code
				local soemergcode = {[0] = "Non-Emergency", [1] = "Emergency",}
				local emerg = getbit(tmplc[2],7)	--((buffer(28,1):uint() / 0x80)  >= 1) and 1 or 0
				local emergdesc = emerg..".......".." = Emergency : "..soemergcode[emerg]
				t1c:add(f_seropemergency, buffer(29,1), emergdesc)

					--Privacy
				local privacycode = {[0] = "Un-Scrambled", [1] = "Scrambled",}
				local privacy = getbit(tmplc[2],6) 	--((((buffer(28,1):uint()  % 0x80) / 0x40) >= 1) and 1 or 0)
				local privacydesc = "."..privacy.."......".." = Privacy : "..privacycode[privacy]
				t1c:add(f_seropprivacy, buffer(29,1), privacydesc)

					--Broadcast
				local broadcastcode  = {[0] = "Non-BroadCast", [1] = "BroadCast",}
				local broadcast =  getbit(tmplc[2],3) --((((buffer(28,1):uint()  % 0x10) / 0x08) >= 1) and 1 or 0)
				local broadcastdesc = "...."..broadcast.."...".." = Broadcast : "..broadcastcode[broadcast]
				t1c:add(f_seropbroadcast, buffer(29,1), broadcastdesc)

					--Open Voice Call Mode
				local ovcmcode = {[0] = "Non-OVCM Call", [1] = "OVCM Call",}
				local ovcm = getbit(tmplc[2],2) --((((buffer(28,1):uint()  % 0x08) / 0x04) >= 1) and 1 or 0)
				local ovcmdesc = "....."..ovcm.."..".." = Open Voice Call Mode : "..ovcmcode[ovcm]
				t1c:add(f_seropovcm, buffer(29,1), ovcmdesc)

					--Priority Level
				local prilevcode = {[0] = "No Priority", [1] = "Priority 1", [2] = "Priority 2", [3] = "Priority 3",}
				local prilev = tmplc[2] % 0x04
				local pl = {}
				pl[0] = getbit(tmplc[2],1)
				pl[1] = getbit(tmplc[2],0)
				local pldesc = "......"..pl[0]..pl[1].." = Priority Level : "..prilevcode[prilev]
				t1c:add(f_seropprioritylev, buffer(29,1), pldesc)

				--Target Group Address
				local bytedisp = {[1] = "(1st Byte)", [2] = "(3rd Byte)", [3] = "(2nd Byte)",}
				local str = "Target Group address :0x"..hexdisp(tmplc[3])..hexdisp(tmplc[5])..hexdisp(tmplc[4])
				local strdisp = {}
				for i = 1,3,1 do
					strdisp[i]= str..bytedisp[i].."(0x"..hexdisp(tmplc[2+i])..")"
				end
				t1c:add(f_emblctga, buffer(29,1), strdisp[1])
				t1c:add(f_emblctga, buffer(30,1), strdisp[3])
				t1c:add(f_emblctga, buffer(31,1), strdisp[2])

				--Source Group Address
				local bytedisp = {[1] = "(2nd Byte)", [2] = "(1st Byte)", [3] = "(3rd Byte)",}
				str = "Source Group address :0x"..hexdisp(tmplc[7])..hexdisp(tmplc[6])..hexdisp(tmplc[8])
				for i = 1,3,1 do
					strdisp[i]= str..bytedisp[i].."(0x"..hexdisp(tmplc[5+i])..")"
				end
				t1c:add(f_emblcsga, buffer(32,1), strdisp[2])
				t1c:add(f_emblcsga, buffer(33,1), strdisp[1])
				t1c:add(f_emblcsga, buffer(34,1), strdisp[3])

				-----------------------------------------------------------------------------------end of decode EMB LC
				t1:add(f_emb, buffer(35,1))

				-----------------------------------------------------------------------------------EMB
				local tmpemb = buffer(35,1):uint()
				--Color code
				local tmp = tmpemb % 0x10
				local colorcode = (tmpemb - tmp) / 0x10
				local cc = {}
				cc[0] = getbit(tmpemb, 7)
				for i = 6, 4, -1 do
					cc[6-i+1] = getbit(tmpemb, i)
				end
				local ccdesc = cc[0]
				for i = 1,3, 1 do
					ccdesc = ccdesc..cc[i]
				end
				ccdesc = ccdesc.."....".." = Color Code : "..colorcode
				t1:add(f_colorcode, buffer(35,1), ccdesc)

				--End-to-End Encryption Indicatior
				local eeeistr = {[0] = "End to End encryption not used on voice",
						[1] = "End to End encryption used on voice",}
				local eeei = getbit(tmpemb, 3)
				local eeeidesc = "...."..eeei.."...".." = EEEI : "..eeeistr[eeei]
				t1:add(f_eeei, buffer(35,1), eeeidesc)

				--LCSS
				local lcss = tmpemb % 0x08
				tmp = lcss % 0x02
				lcss = (lcss - tmp) / 0x02

				local lcsscode = {
					[0] = "Single fragment LC Packet",
					[1] = "First fragment of an LC Packet",
					[2] = "Last fragment of an LC Packet",
					[3] = "Continuation fragment of an LC Packet",
				}
				local lcssb = {}
				lcssb[0] = getbit(tmpemb, 2)
				lcssb[1] = getbit(tmpemb, 1)
				local lcssdesc = "....."..lcssb[0]..lcssb[1]..".".." = LC Start/Stop : "..lcsscode[lcss]
				t1:add(f_lcss, buffer(35,1), lcssdesc)
				-----------------------------------------------------------------------------------END of EMB

				if ((f2burstlen > 36) and (f2burstlen == 36+10)) then
					t1:add(f_auth, buffer(36, 10))
				end

			elseif length == 10 then	--VOCE HEADER OR TERMINATOR or PI Header
				local t1c = t1:add(f_burstdata, buffer(8,burstSize/8))

				if  datatype == 1 or datatype == 2 then
					-------------------------------------------------------------------------------EMB LC
					--Endian fix for this part
					local tmplc = {}
					for i = 0, 8, 1 do
						tmplc[i] = buffer(8+i,1):uint()
					end
					wordswap(tmplc, 9)


					--PF
					local pfcode = {[0] = "Un-Scrambled", [1] = "Scrambled",}
					local pf = getbit(tmplc[0], 7)
					local pfdesc = pf..".......".." = Link Control Protection Flag : "..pfcode[pf]
					t1c:add(f_emblcpf, buffer(9,1), pfdesc)

					--SF
					local sfcode = {[0] = "Implicit MFID Format", [1] = "Explicit MFID Format",}
					local sf = getbit(tmplc[0], 6)
					local sfdesc = "."..sf.."......".." = MFID Format : "..sfcode[sf]
					t1c:add(f_emblcsf, buffer(9,1), sfdesc)

					--Operand code
					local opcodecode = {[0x0] = "Group Voice Call", [0x03] = "Individual Voice Call",}
					local elopcode = tmplc[0] % 0x40
					local elopcodestr = opcodecode[elopcode]

					if elopcodestr == nil then
						elopcodestr = "Unknow"
					end

					local opbits = {}
					for i = 6, 1, -1 do
						opbits[6-i] = getbit(tmplc[0], i-1) --((((buffer(8,1):uint() % (2 ^ i)) / (2 ^ (i-1))) >= 1) and 1 or 0)
					end

					local elopcodedesc = ".."
					for i = 0, 5, 1 do
						elopcodedesc = elopcodedesc..opbits[i]
					end

					elopcodedesc = elopcodedesc.." = Operand Code : "..elopcodestr
					t1c:add(f_emblcopcode, buffer(9,1), elopcodedesc)


					--Manufacture's Id
					t1c:add(f_emblcmanid, buffer(8,1)) --tmplc[1]

					--Service Option
						--Emergency Code
					local soemergcode = {[0] = "Non-Emergency", [1] = "Emergency",}
					local emerg = getbit(tmplc[2],7)	--((buffer(28,1):uint() / 0x80)  >= 1) and 1 or 0
					local emergdesc = emerg..".......".." = Emergency : "..soemergcode[emerg]
					t1c:add(f_seropemergency, buffer(11,1), emergdesc)

						--Privacy
					local privacycode = {[0] = "Un-Scrambled", [1] = "Scrambled",}
					local privacy = getbit(tmplc[2],6) 	--((((buffer(28,1):uint()  % 0x80) / 0x40) >= 1) and 1 or 0)
					local privacydesc = "."..privacy.."......".." = Privacy : "..privacycode[privacy]
					t1c:add(f_seropprivacy, buffer(11,1), privacydesc)

						--Broadcast
					local broadcastcode  = {[0] = "Non-BroadCast", [1] = "BroadCast",}
					local broadcast =  getbit(tmplc[2],3) --((((buffer(28,1):uint()  % 0x10) / 0x08) >= 1) and 1 or 0)
					local broadcastdesc = "...."..broadcast.."...".." = Broadcast : "..broadcastcode[broadcast]
					t1c:add(f_seropbroadcast, buffer(11,1), broadcastdesc)

						--Open Voice Call Mode
					local ovcmcode = {[0] = "Non-OVCM Call", [1] = "OVCM Call",}
					local ovcm = getbit(tmplc[2],2) --((((buffer(28,1):uint()  % 0x08) / 0x04) >= 1) and 1 or 0)
					local ovcmdesc = "....."..ovcm.."..".." = Open Voice Call Mode : "..ovcmcode[ovcm]
					t1c:add(f_seropovcm, buffer(11,1), ovcmdesc)

						--Priority Level
					local prilevcode = {[0] = "No Priority", [1] = "Priority 1", [2] = "Priority 2", [3] = "Priority 3",}
					local prilev = tmplc[2] % 0x04
					local pl = {}
					pl[0] = getbit(tmplc[2],1)
					pl[1] = getbit(tmplc[2],0)
					local pldesc = "......"..pl[0]..pl[1].." = Priority Level : "..prilevcode[prilev]
					t1c:add(f_seropprioritylev, buffer(11,1), pldesc)

					--Target Group Address
					local bytedisp = {[1] = "(1st Byte)", [2] = "(3rd Byte)", [3] = "(2nd Byte)",}
					local str = "Target Group address :0x"..hexdisp(tmplc[3])..hexdisp(tmplc[5])..hexdisp(tmplc[4])
					local strdisp = {}
					for i = 1,3,1 do
						strdisp[i]= str..bytedisp[i].."(0x"..hexdisp(tmplc[2+i])..")"
					end
					t1c:add(f_emblctga, buffer(11,1), strdisp[1])
					t1c:add(f_emblctga, buffer(12,1), strdisp[3])
					t1c:add(f_emblctga, buffer(13,1), strdisp[2])

					--Source Group Address
					local bytedisp = {[1] = "(2nd Byte)", [2] = "(1st Byte)", [3] = "(3rd Byte)",}
					str = "Source Group address :0x"..hexdisp(tmplc[7])..hexdisp(tmplc[6])..hexdisp(tmplc[8])
					for i = 1,3,1 do
						strdisp[i]= str..bytedisp[i].."(0x"..hexdisp(tmplc[5+i])..")"
					end
					t1c:add(f_emblcsga, buffer(14,1), strdisp[2])
					t1c:add(f_emblcsga, buffer(15,1), strdisp[1])
					t1c:add(f_emblcsga, buffer(16,1), strdisp[3])

					--CRC
					t1c:add(f_crc, buffer(17,3))

					if ((f2burstlen > 20) and (f2burstlen == 20+10)) then
						t1.add(f_auth, buffer(20, 10))
					end

					-----------------------------------------------------------------------------------end of decode EMB LC
				elseif datatype == 0 then

					local data1 = buffer(8,1):uint()
					local data2 = buffer(9,1):uint()
					local data3 = buffer(10,2):uint()

					--Alg Id
					local algid1 = getbit(data1,0)
					local algid2 = getbit(data1,1)
					local algid3 = getbit(data1,2)
					local algiddesc = "Alg Id : 0b"..algid3..algid2..algid1
					t1:add(f_algid, buffer(8,1), algiddesc)

					--Reserved
					local rsvd1 = getbit(data1,3)
					local rsvd2 = getbit(data1,4)
					local rsvddesc = "Reserved : 0b"..rsvd2..rsvd1
					t1:add(f_rsvd1, buffer(8,1), rsvddesc)

					--gi Bit
					local gi = getbit(data1,5)
					local gidesc = "Gi Bit : "..gi
					t1:add(f_gi, buffer(8,1), gidesc)

					--Reserved
					local rsvd3 = getbit(data1,6)
					local rsvd4 = getbit(data1,7)
					local rsvddesc2 = "Reserved : 0b"..rsvd4..rsvd3
					t1:add(f_rsvd2, buffer(8,1), rsvddesc2)

					--Manufacturer's ID
					local mfiddesc = "Manufacturer's ID: "..data2
					t1:add(f_mfid, buffer(9,1), mfiddesc)

					--Key Id
					local keyiddesc = "Key Id: "..data3
					t1:add(f_keyid, buffer(10,1), keyiddesc)

					--IV Key
					t1:add(f_ivkey, buffer(11,4))

					--IV Key
					t1:add(f_destaddr, buffer(15,3))

					-- CRC
					t1:add(f_crc, buffer(18,2))



				end

				--EMB
				t1:add(f_emb, buffer(20, 1))

				--Slot Type
				t1:add(f_slottype, buffer(21, 1))

				if ((f2burstlen > 24) and (f2burstlen == 24+10)) then
					t1:add(f_auth, buffer(24, 10))
				end

			else
				print("Not a valid burst")
			end

		end






		local x = buffer(0, 1):uint()
		local y = getbit(0x40, 6)
		print("Result = "..y)



	end
end
