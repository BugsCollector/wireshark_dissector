-- General utility class and function


----------------------------------------------------------------------------------
-- Date: 2014-10-28
-- Author: Liao Ying-RQT768
-- File: HeadWork.lua
-- Description: Contains a simple logger to debug the lua script.
--				Add a function to check the status of dissector.
----------------------------------------------------------------------------------
Logger = {
	
	CurrentPath,
	LogPath,
	LogFile
}

function Logger:Init(savePath)
		if savePath ~= nil then
			CurrentPath = savePath	
		else
			-- Get Current Path
			local obj = io.popen("cd")		-- Maybe remove 'local'
			CurrentPath = obj:read("*all"):sub(1,-2)
			obj:close()
		end

		CurrentPath = CurrentPath .. "\\LUALog"
		-- Create a subdirectory to save the log file
		os.execute("mkdir \"" .. CurrentPath .. "\"")

		LogPath = string.format("%s\\%s.log", CurrentPath, os.date("%Y_%m_%d"))

		LogFile = io.open(LogPath, "a+")

		self:AddLog("Lua Logger Initialized. By Liao Ying-RQT768. 2014-10-24. Version 1.0 ")
end

----------------------------------------------------------------------------------
-- You must invoke Init() fristly, then AddLog(), and then Close().
-- So, it is not recommended.
----------------------------------------------------------------------------------
function Logger:AddLog(format, ...)
	local arg = {...}
	local str

	if (#arg == 0) then		-- string.format can not deal nil parameter.
		str = format
	else
		str = string.format(format, ...)
	end
	local str2 = os.date("%Y-%m-%d %H:%M:%S") .. "\t" .. str .. "\r\n"
	if LogFile then
		LogFile:write(str2)
		print(str2)
		--self:Close()
	end

end


function Logger:Close()
	if LogFile then
		LogFile:close()
		LogFile = nil
	end
end

-- Should be invoked by dissector when parsing data.
-- Contain opening, writing and closing operation.
-- It is for debug, delete all the 'AppendLog' when release.
-- Because it is very harmful for efficiency.
function Logger:AppendLog(format, ...)
	
	CurrentPath = DATA_DIR .. "\\LUALog"
	LogPath = string.format("%s\\%s.log", CurrentPath, os.date("%Y_%m_%d"))
	LogFile = io.open(LogPath, "a+")

	local arg = {...}
	local str

	if (#arg == 0) then		-- string.format can not deal nil parameter.
		str = format
	else
		str = string.format(format, ...)
	end
	local str2 = os.date("%Y-%m-%d %H:%M:%S") .. "\t" .. str .. "\r\n"
	if LogFile then
		LogFile:write(str2)
		print(str2)
		self:Close()
	end

end

Logger:AppendLog("Lua Logger. By Liao Ying-RQT768. 2014-10-24. Version 1.0 ")
Logger:AppendLog("To debug lua script of Wireshark.")
Logger:AppendLog("You can log anything like Logger:AppendLog(\"%format\", ...)")

----------------------------------------------------------------------------------
-- Date: 2014-10-28
-- Author: Liao Ying-RQT768
-- Description: Check whether a dissector is enable or not, 
--				output the result to console and log file.
----------------------------------------------------------------------------------
function CheckProtocolDissector(dissectorName)
	local dis= Dissector.get(dissectorName)
	if (dis) then
		Logger:AppendLog("Protocol dissector initialized: %s", dissectorName)
	else
		Logger:AppendLog("Error: '%s' is not created.", dissectorName)
	end
end

----------------------------------------------------------------------------------
-- Date: 2005-XX-XX
-- Author: e-friend 
-- Description:  This module provides a selection of BitHolderwise operations.
----------------------------------------------------------------------------------
BitHolder={data32={}}
for i=1,32 do
    BitHolder.data32[i]=2^(32-i)
end

function BitHolder:d2b(arg)
    local tr={}
    for i=1,32 do
        if arg >= self.data32[i] then
            tr[i]=1
            arg=arg-self.data32[i]
        else
            tr[i]=0
        end
    end
    return tr
end --BitHolder:d2b

function BitHolder:b2d(arg)
    local nr=0
    for i=1,32 do
        if arg[i] ==1 then
            nr=nr+2^(32-i)
        end
    end
    return nr
end --BitHolder:b2d

function BitHolder:_xor(a,b)
    local op1=self:d2b(a)
    local op2=self:d2b(b)
    local r={}

    for i=1,32 do
        if op1[i]==op2[i] then
            r[i]=0
        else
            r[i]=1
        end
    end
    return self:b2d(r)
end --BitHolder:xor

function BitHolder:_and(a,b)
    local op1=self:d2b(a)
    local op2=self:d2b(b)
    local r={}
 
    for i=1,32 do
        if op1[i]==1 and op2[i]==1 then
            r[i]=1
        else
            r[i]=0
        end
    end
 return self:b2d(r)
end --BitHolder:_and

function BitHolder:_or(a,b)
    local op1=self:d2b(a)
    local op2=self:d2b(b)
    local r={}
 
    for i=1,32 do
        if op1[i]==1 or op2[i]==1 then
            r[i]=1
        else
            r[i]=0
        end
    end
    return self:b2d(r)
end --BitHolder:_or

function BitHolder:_not(a)
    local op1=self:d2b(a)
    local r={}

    for i=1,32 do
        if op1[i]==1 then
            r[i]=0
        else
            r[i]=1
        end
    end
    return self:b2d(r)
end --BitHolder:_not

function BitHolder:_rshift(a,n)
    local op1=self:d2b(a)
    local r=self:d2b(0)
 
    if n < 32 and n > 0 then
        for i=1,n do
            for i=31,1,-1 do
                op1[i+1]=op1[i]
            end
            op1[1]=0
        end
        r=op1
    end
    return self:b2d(r)
end --BitHolder:_rshift

function BitHolder:_lshift(a,n)
    local op1=self:d2b(a)
    local r=self:d2b(0)
 
    if n < 32 and n > 0 then
    for i=1,n do
        for i=1,31 do
            op1[i]=op1[i+1]
        end
        op1[32]=0
    end
    r=op1
    end
    return self:b2d(r)
end --BitHolder:_lshift


function BitHolder:print(ta)
    local sr=""
    for i=1,32 do
        sr=sr..ta[i]
    end
    Logger:AppendLog(sr)
end



----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
function hexdisp(x)
	if x > 255 or x < 0 then
		return -1
	elseif x > 15 then
		return	string.format("%x", x)
	elseif x >= 0 then
		return string.format("0%x", x)
	end
end

function getbit(x, n)
		return (((x % (2^(n+1)) / (2^n)) >= 1) and 1 or 0)
end

function wordswap(a , n)
	if ((n % 2) == 1) then
		m = n-1
	else
		m = n
	end

	local tmp

	for i = 0, m-1, 1 do
		if ((i % 2) == 0) then
			tmp = a[i]
			a[i] = a[i+1]
			a[i+1] = tmp
		end
	end
end

function bit(p)
	return 2 ^ (p - 1)  -- 1-based indexing
end
function hasbit(x, p)
	return x % (p + p) >= p       
end
function setbit(x, p)
	return hasbit(x, p) and x or x + p
end
function clearbit(x, p)
	return hasbit(x, p) and x - p or x
end



