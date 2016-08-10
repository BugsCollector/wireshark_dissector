-- General ASN.1 utility functions

function getbit(x, n)
		return (((x % (2^(n+1)) / (2^n)) >= 1) and 1 or 0)
end

-- This method extracts bit values from a bitstring and displays them on the dissector tree
--	It does this by left shifting the wanted bit of the current byte
--  to the most sig fig bit place then right shifting to the least sig fig bit place
function asn1ParseBitString(buf, len, bit_table, tree)
	local unusedbits = buf(0, 1):uint()
	local bitsize = ((len-1)*8) - unusedbits -- How many used bits there are
	local byte = 0
	local bit = 0
	local start
	local val, str

	-- If no mapping bit_table is given, just return
	if bit_table == nil then
		return
	end

	local tablesize = #bit_table
	-- Lua indexes from 1. Must check if 0 has anything in it
	if bit_table[0] ~= nil then
		tablesize = tablesize + 1
		start = 0
	else
		start = 1
	end

	if len > 1 then
		buf = buf(1, len-1) -- Only read after the unused bits byte
	end

	for bit=start, tablesize-1 do
		str = bit_table[bit]
		if bit > bitsize-1 then
			byte = 0
		else
			byte = buf(math.floor(bit/8), 1):uint()
		end

		val = getbit(byte, 7 - (bit % 8))
		tree:add(str..": "..val)
	end
end

-- Returns: p_type: Type of this ASN.1 field
--			p_len: The length value
--			read_len: read_len marker moved to after the length bytes
function asn1ParseTagLength(buf, read_len, buf_len)
	local p_type = 0
	local p_len
	-- Get tag/type
	p_type = buf(read_len,1)
	read_len = read_len + 1

	-- Get Length
	p_len = buf(read_len, 1):uint()
	read_len = read_len + 1
	if p_len > 128 then
		local octs_to_read = p_len - 128
		p_len = buf(read_len, octs_to_read):uint()
		read_len = read_len + octs_to_read
	end
	return p_type, p_len, read_len
end

-- Peeks into descriptor and retrieves the opcode and srcuniqueid
--	Note: This must change whenever Descriptor ASN1 file changes
-- Returns:	opcode: The opcode of the PDU
--			srcuniqueid: The srcuniqueid (quintuplet?)
function descriptorPeek(buf, buf_len, read_len)
	local opcode = 0
	local srcuniqueid = 0
	local p_tag
	local p_desc_len
	local desc_end	= 0

	p_tag, p_desc_len, read_len = asn1ParseTagLength(buf, read_len, buf_len)
	desc_end = read_len+p_desc_len
	while read_len < desc_end do
		p_tag, p_len, read_len = asn1ParseTagLength(buf, read_len, buf_len)
		p_tag = p_tag:uint()
		if p_tag == 0x81 then
			opcode = buf(read_len, p_len):uint()
		elseif p_tag == 0x82 then
			srcuniqueid = buf(read_len, p_len):uint()
		end

		if opcode > 0 and srcuniqueid > 0 then
			break
		end

		read_len = read_len + p_len
	end

	return opcode, srcuniqueid
end

-- Parses SEQUENCE types. Tags in SEQ are ignored
function parseSEQ(buf, buf_len, t, attr_table, fieldtype)
	local read_len = 0
	local p_tag = 0
	local p_len
	local cur_tag, start
	local cur_table -- entry of attr_table
	local sub_t -- for this SEQ subtree
	local bitsub_t -- for bitstring subtrees
	local attr_table_size = #attr_table

	if attr_table[0] ~= nil then
		attr_table_size = attr_table_size + 1
		start = 0
	else
		start = 1
	end

	-- Create subtree
	sub_t = t:add(fieldtype, buf)

	-- Parse sequentially
	for cur_tag=start, #attr_table do
		cur_table = attr_table[cur_tag]

		if read_len >= buf_len then
			-- Done. Nothing left to parse
			break
		end

		if cur_table ~= nil then
			-- Read T and L
			p_tag, p_len, read_len = asn1ParseTagLength(buf, read_len, buf_len)

			-- Read Value
			if cur_table[1] == "BIT STRING" then
				bitsub_t = sub_t:add(cur_table[0], buf(read_len, p_len))
				asn1ParseBitString(buf(read_len, p_len), p_len, cur_table[2], bitsub_t)
				read_len = read_len + p_len
			elseif cur_table[1] == "SET" then
				read_len = read_len + parseSET(buf(read_len, p_len), p_len, sub_t, cur_table[2], cur_table[0] )
			elseif cur_table[1] == "SEQ" then
				read_len = read_len + parseSEQ(buf(read_len, p_len), p_len, sub_t, cur_table[2], cur_table[0] )
			elseif cur_table[1] == "SEQUENCE OF" then
				-- Note: SEQ OF can have 0 or more entries. This checks for 0 entries before attempting to parse.
				if p_len > 0 then
					read_len = read_len + parseSEQOF(buf(read_len, p_len), p_len, sub_t, cur_table)
				end
			else -- INTEGER, ENUM, etc.
				sub_t:add(cur_table[0], buf(read_len, p_len))
				read_len = read_len + p_len
			end
		end
	end

	return read_len
end


-- Parses SET types
function parseSET(buf, buf_len, t, attr_table, fieldtype)
	local read_len = 0
	local p_tag = 0
	local p_len = 0
	local cur_table -- entry of attr_table
	local sub_t -- for this SEQ/SET subtree
	local bitsub_t -- for bitstring subtrees

	-- Create subtree
	sub_t = t:add(fieldtype, buf)

	while read_len < buf_len do
		-- Read T and L
		p_tag, p_len, read_len = asn1ParseTagLength(buf, read_len, buf_len)
		p_tag = p_tag:uint()

		-- Get the child attribute table
		cur_table = attr_table[p_tag]

		-- Read Value
		if cur_table[1] == "BIT STRING" then
		
			if attr_table == naipayload_table then
				parseNaiPayload(buf(read_len, p_len), p_len, sub_t)
			else
				bitsub_t = sub_t:add(cur_table[0], buf(read_len, p_len))
				asn1ParseBitString(buf(read_len, p_len), p_len, cur_table[2], bitsub_t)
			end
			read_len = read_len + p_len
		elseif cur_table[1] == "SET" then
			read_len = read_len + parseSET(buf(read_len, p_len), p_len, sub_t, cur_table[2], cur_table[0] )
		elseif cur_table[1] == "SEQ" then
			read_len = read_len + parseSEQ(buf(read_len, p_len), p_len, sub_t, cur_table[2], cur_table[0] )
		elseif cur_table[1] == "SEQUENCE OF" then
			-- Note: SEQ OF can have 0 or more entries. This checks for 0 entries before attempting to parse.
			if p_len > 0 then
				read_len = read_len + parseSEQOF(buf(read_len, p_len), p_len, sub_t, cur_table)
			end
		else -- INTEGER, ENUM, etc.
			if p_len == 5 then
				-- Skip and ignore the leading byte since it's not part of the value
				sub_t:add(cur_table[0], buf(read_len+1, p_len-1))
			else
				-- Read normally since p_len bytes will fit in an int
				sub_t:add(cur_table[0], buf(read_len, p_len))
			end
			read_len = read_len + p_len
		end
	end

	return read_len
end

function parseSEQOF(buf, buf_len, t, seq_table)
	local read_len = 0
	local p_tag	= 0
	local p_len		= 0
	local sub_t
	local count = 0
	local attr_table_of = seq_table[2]
	local of_name = seq_table[3]
	local fieldtype = seq_table[4]
	local of_type = seq_table[5]

	while read_len < buf_len do
		-- Read Type and Length of Seq Of element
		p_tag, p_len, read_len = asn1ParseTagLength(buf, read_len, buf_len)

		-- Parse element of SEQOF
		if of_type == "SEQUENCE" then
			-- Create the subtree for element
			count = count + 1
			sub_t = t:add(of_name.." "..count)
			read_len = read_len + parseSEQ(buf(read_len, p_len), p_len, sub_t, attr_table_of, fieldtype)
		elseif of_type == "SET" then
			-- Create the subtree for element
			count = count + 1
			sub_t = t:add(of_name.." "..count)
			read_len = read_len + parseSET(buf(read_len, p_len), p_len, sub_t, attr_table_of, fieldtype)
		else
			-- INTEGER, BIT STRING, ENUM , etc.
			t:add(fieldtype, buf(read_len, p_len))
			read_len = read_len + p_len
		end
		
	end
	return read_len
end

function asn1Dissect(buf, pkt, root)
	g_pkt = pkt

	local buf_len = buf:len()
	local t = root:add(p_linkest, buf(0, buf_len))
	local read_len		= 0
	local p_tag		= 0
	local p_len			= 0

	-- Read top-level PDU Type and length
	p_tag, p_len, read_len = asn1ParseTagLength(buf, read_len, buf_len)
	
	-- discard the last 4 bytes in the PDU
	-- the last 4 bytes are added for sort purpose
	-- because we can't make sure the sequence of packages received by receiver.py are the same as the sequence repeater send them out
	-- we added a 4 bytes sequence number at the end of each package send out by repeater in Win32Runner.exe
	-- receiver.py will using this sequence number to sort the packages before writing it to output.txt
	if buf_len == (p_len + read_len + 4) then
		buf_len = buf_len - 4
	end

	if buf_len == (p_len + read_len) then -- Make sure top length aligns with PDU len
		local t_opcode	= 0
		local srcuniqueid	= 0
		local info
		local str_opcode
		local sub_buf = buf:range(read_len, buf_len-read_len)
		local arg_len = buf_len-read_len

		-- Peek descriptor --
		t_opcode, srcuniqueid = descriptorPeek(buf, buf_len, read_len)		

		str_opcode = opcode[t_opcode]

		local pdudata = __pdu_table[t_opcode]
		
		if pdudata ~= nil then
			-- Start parsing of top-level ASN.1 Types
			read_len = parseSEQ(sub_buf, arg_len, t, pdudata[0], pdudata[1])
		else
			info = string.format("No opcode found: "..t_opcode)
		end

		str_opcode = opcode[t_opcode]

		-- Check atiaopcode's table if opcode not found yet
		if str_opcode == nil then
			-- Check if atiaopcode table exists
			if type(atiaopcode) == "table" then
				str_opcode = atiaopcode[t_opcode]
			end
		end

		-- Info text
		if str_opcode ~= nil then
			if str_opcode ~= "nAIPDU" then
				info = string.format(str_opcode.."\tSrcUniqueID: 0x%x",srcuniqueid)
			end
		end

		pkt.cols.protocol:set("EM")
		if info ~= nil then
			pkt.cols.info:set(info)
		end
	else
		t:add("ASN.1 top-level length does not align with buffer length!\nASN.1 Len: "..(p_len+read_len).."\nbuf len: "..buf_len)
	end
	
end
---------------------------------------------------------------------------------------
-- 2015-03-03
-- Liao Ying-RQT768
-- The NaiPayload is not asn.1 format,
-- We need to parse it as the document 'MultiSite_System_Protocol.doc' described.
---------------------------------------------------------------------------------------
function parseNaiPayload(buf, buf_len, t)
	local sub_dissector = Dissector.get("eml_naipayload")
	if sub_dissector ~= nil then
		sub_dissector:call(buf(0):tvb(), g_pkt, t)
	else
	end

end
