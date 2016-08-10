--dissector for XNL

do
	p_xnl= Proto("xnl", "XNL")
	
	local opcode_table = {
		[0x0001] = "MASTER_PRESENT_BRDCST",
		[0x0002] = "MASTER_STATUS_BRDCST",
		[0x0003] = "DEVICE_MASTER_QUERY",
		[0x0004] = "DEVICE_AUTH_KEY_REQUEST",
		[0x0005] = "DEVICE_AUTH_KEY_REPLY",
		[0x0006] = "DEVICE_CONN_REQUEST",
		[0x0007] = "DEVICE_CONN_REPLY",		

		[0x0008] = "DEVICE_SYSMAP_REQUEST",
		[0x0009] = "DEVICE_SYSMAP_BRDCST",
		[0x000A] = "DEVICE_RESET_MSG",
		[0x000B] = "DATA_MSG",
		[0x000C] = "DATA_MSG_ACK",
	}
    	
	local f_opcode = ProtoField.uint16("xnl.opcode", "opcode", base.HEX, opcode_table)
	local f_protoid = ProtoField.uint8("xnl.protoid", "Proto Id", base.HEX)
	local f_flag = ProtoField.uint8("xnl.flag", "Flag", base.HEX)
       local f_destination = ProtoField.uint16("xnl.destination", "Destination", base.HEX)
       local f_source = ProtoField.uint16("xnl.source", "Source", base.HEX)
       local f_transaction = ProtoField.uint16("xnl.transaction", "Transaction", base.HEX)
       local f_payloadlength = ProtoField.uint16("xnl.payloadlen", "Payload Length", base.DEC)
       
       -- MASTER_PRESENT_BRDCST
       local f_versionnumber = ProtoField.uint32("xnl.versionNumber", "XNL Version Number", base.HEX)
       local f_masterdeviceprioritylevel = ProtoField.uint16("xnl.masterDevicePriorityLevel", "Master Device Priority Level", base.HEX)
       local f_tiebreakrandomnumber = ProtoField.uint16("xnl.tiebreakRandomNumber", "Tie Break Random Number", base.HEX)
		
        -- MASTER_STATUS_BRDCST
       local f_masterlogicalidentifier = ProtoField.uint16("xnl.masterLogicalIdentifier", "Master Logical Identifier", base.HEX)
       local f_datamessagesent = ProtoField.uint8("xnl.dataMessageSent", "Data Message Sent", base.HEX)
		        
       -- DEVICE_AUTH_KEY_REPLY
       local f_temporaryxnladdress = ProtoField.uint16("xnl.temporaryXnlAddress", "Temporary XNL Address", base.HEX)
       local f_unencryptedauthenticationvalue = ProtoField.uint64("xnl.unencryptedAuthenticationValue", "Unencrypted Authentication Value", base.HEX)

        -- DEVICE_CONN_REQUEST
       local f_preferredXnlAddress = ProtoField.uint16("xnl.preferredXnlAddress", "Preferred XNL Address", base.HEX)
       local f_deviceType = ProtoField.uint8("xnl.deviceType", "Device Type", base.HEX)
       local f_authenticationLevel = ProtoField.uint8("xnl.authenticationLevel", "Authentication Level", base.HEX)
       local f_encryptedAuthenticationValue = ProtoField.uint64("xnl.encryptedAuthenticationValue", "Encrypted Authentication Value", base.HEX)

        -- DEVICE_CONN_REPLY
       local f_resultCode = ProtoField.uint8("xnl.resultCode", "Result Code", base.HEX)
       local f_transactionIdBase = ProtoField.uint8("xnl.transactionIdBase", "Transaction Id Base", base.HEX)
       local f_xnlAddress = ProtoField.uint16("xnl.xnlAddress", "XNL Address", base.HEX)
       local f_logicalAddress = ProtoField.uint16("xnl.logicalAddress", "Logical Address", base.HEX)
	
	-- DEVICE_SYSMAP_BRDCST
       local f_sizeOfSysMapArray = ProtoField.uint16("xnl.sizeOfSysMapArray", "Size of SysMap array", base.HEX)
       local f_sysMapArray = ProtoField.bytes("xnl.sysMapArray", "SysMap Array")
       local f_logicalIdentifier = ProtoField.uint16("xnl.logicalIdentifier", "Logical Identifier", base.HEX)

	
	p_xnl.fields = {f_opcode, f_protoid, f_flag, f_destination, f_source, f_transaction, f_payloadlength,
        	f_versionnumber, f_masterdeviceprioritylevel, f_tiebreakrandomnumber,
        	f_masterlogicalidentifier, f_datamessagesent,
        	f_temporaryxnladdress, f_unencryptedauthenticationvalue,
        	f_preferredXnlAddress, f_deviceType, f_authenticationLevel, f_encryptedAuthenticationValue,
        	f_resultCode, f_transactionIdBase, f_xnlAddress, f_logicalAddress,
        	f_sysMapArray, f_sizeOfSysMapArray, f_logicalIdentifier,        	
        	}
        	
	print("in xnl")
	
	
	
	function p_xnl.dissector(buf, pkt, root)
	       
	       if buf:len() <12 then	       
	            return  -- error
	       end
	       
		local opcode = buf(0,2):uint()
		local id = buf(2,1):uint()
		local flag = buf(3,1):uint()
		local dest = buf(4,2):uint()
		local src = buf(6,2):uint()
		local transid = buf(8,2):uint()
		local payloadlen = buf(10,2):uint() 
  		   
		-- update columns		
		local info = string.format("[%0.4X]", opcode);					
		if opcode_table[opcode] ~= nil then
		    info = info ..  string.format("%-23s 0x%0.4X > 0x%0.4X PID=0x%0.2X Flag=0x%0.2X Trans=0x%0.4X Len=%u",
			opcode_table[opcode],
			src,
			dest,
			id,
			flag,
      			transid,
			payloadlen)
		else
		    info = info .. "Unknow XNL opcode!"
		end
		
		pkt.cols.protocol:set("XNL")
		pkt.cols.info:set(info)
		
		-- protocol detail
		if (payloadlen + 12) > buf:len() then
				    return -- error
		end
				
		local t = root:add(p_xnl, buf(0, 12))
		t:add(f_opcode, buf(0, 2))	
		t:add(f_protoid, buf(2, 1))	
		t:add(f_flag, buf(3, 1))	
		t:add(f_destination, buf(4, 2))	
		t:add(f_source, buf(6, 2))	
		t:add(f_transaction, buf(8, 2))	
		t:add(f_payloadlength, buf(10, 2))	

                if opcode == 0x0001  then 	
                    if payloadlen >= 8 then
                        t:add(f_versionnumber, buf(12, 4))	
                        t:add(f_masterdeviceprioritylevel, buf(16, 2))	
                        t:add(f_tiebreakrandomnumber, buf(18, 2))	                  
                    end
                elseif opcode == 0x0002  then
                    if payloadlen >= 7 then                    
                        t:add(f_versionnumber, buf(12, 4))	
                        t:add(f_masterdeviceprioritylevel, buf(16, 2))	
                        t:add(f_tiebreakrandomnumber, buf(18, 1))	                  
                    end                
                elseif opcode == 0x0005  then
                    if payloadlen >= 10 then                    
                        t:add(f_temporaryxnladdress, buf(12, 2))	
                        t:add(f_unencryptedauthenticationvalue, buf(14, 8))	
                    end                
                elseif opcode == 0x0006  then
                    if payloadlen >= 12 then                    
                        t:add(f_preferredXnlAddress, buf(12, 2))	
                        t:add(f_deviceType, buf(14, 1))	
                        t:add(f_authenticationLevel, buf(15, 1))	
                        t:add(f_encryptedAuthenticationValue, buf(16, 8))	
                    end  
                elseif opcode == 0x0007  then
                    if payloadlen >= 14 then                    
                        t:add(f_resultCode, buf(12, 1))	
                        t:add(f_transactionIdBase, buf(13, 1))	
                        t:add(f_xnlAddress, buf(14, 2))	
                        t:add(f_logicalAddress, buf(16, 2))	
                        t:add(f_encryptedAuthenticationValue, buf(18, 8))	
                    end                      
                elseif opcode == 0x0009  then
                    if payloadlen >= 5 then
                        local sizeOfSysMapArray = buf(12,2):uint()
                        if (sizeOfSysMapArray * 5 + 2) > payloadlen  then
                            --error
                        else
                            
                            t:add(f_sizeOfSysMapArray, buf(12, 2))
                           local r = t:add(f_sysMapArray, buf(14, sizeOfSysMapArray* 5))
                            for i = 0, sizeOfSysMapArray - 1, 1 do
                                local s = r:add(f_sysMapArray, buf(14+i*5, 5))
                                s:add(f_logicalIdentifier, buf(14+i*5, 2))	
                                s:add(f_xnlAddress, buf(16+i*5, 2))	
                                s:add(f_authenticationLevel, buf(18+i*5, 1))	
                            end
                        end
                    else
                        -- erorr
                    end      
                    
                 elseif opcode == 0x000B  then
                        local xcmp_dissector = Dissector.get("xcmp")        
                        if xcmp_dissector ~= nil then
                             xcmp_dissector:call(buf(12):tvb(), pkt, root)
                        else
                                print("No xcmp dissector found")
                        end                                     
                else

                end  
		
	end
	
		
	
	--local tcp_encap_table = DissectorTable.get("tcp.port")
	--local ports = {8002}	
	--for i, port in ipairs(ports) do
	--	tcp_encap_table:add(port, p_xnl)  
	--end
	
end




do
	local p_xnlHeader= Proto("payloadHeader", "Payload Header (Two byte length)")
	local data_dis = Dissector.get("data")
       
	local f_length = ProtoField.uint16("payloadHeader.length", "Length", base.DEC)
	p_xnlHeader.fields = { f_length}
        		
	function p_xnlHeader.dissector(buf, pkt, root)
	       local buf_size = buf:len() 
	       if buf_size < 2 then	       
	            return  -- error
	       end
	       
	       local length =  buf(0, 2):uint()
	       if (length + 2) > buf_size then
	            return -- error
	       end
		
		-- protocol detail
		local t = root:add(p_xnlHeader, buf(0, 2))
		t:add(f_length, buf(0, 2))	
		
		local dissector = Dissector.get("xnl")	
	
	       -- dissector hand over
		if dissector ~= nil then
			dissector:call(buf(2):tvb(), pkt, root)
		else
			data_dis:call(buf(2):tvb(), pkt, root)
		end
				
	end
	
	local udp_encap_table = DissectorTable.get("tcp.port")
	local ports = {8002}
	
	for i, port in ipairs(ports) do  
		udp_encap_table:add(port, p_xnlHeader)  
	end
		
end