--This version is for new LE product
--Based on:
--	MultiSite Peer-to-Peer Protocol and Procedure Definitions Version 0.0.3
-------------------------------------------------------------------------------------------------------
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

dofile("xnldissector.lua")
dofile("xcmpdissector.lua")
dofile("wlvddissector.lua")


--dissector for P2P F2 burst (DATA)
dofile("p2pdatadissector.lua")
--dissector for P2P F2 burst(Voice)
dofile("p2pvoicedissector.lua")
--dissector for LE
dofile("ledissector.lua")
--dissector for P2P
dofile("p2pdissector.lua")
-- dissector for Neptune CSBK messages
dofile("nricsbkdissector.lua")
-- dissector for Motorola P2P
-- REGISTER any new dissectors in this file!
dofile("motorolap2pdissector.lua")
dofile("win32OtaDissector.lua")