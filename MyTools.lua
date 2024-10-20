-- ************************************************************************************************
-- MyTools
-- ************************************************************************************************

-- Author: Fetty42
-- Version: 1.0.0.0

local dbPrintfOn = false
local dbInfoPrintfOn = false

local function dbInfoPrintf(...)
	if dbInfoPrintfOn then
    	print(string.format(...))
	end
end

local function dbPrintf(...)
	if dbPrintfOn then
    	print(string.format(...))
	end
end


MyTools = {}; -- Class


-- global variables
MyTools.dir = g_currentModDirectory
MyTools.modName = g_currentModName

-- 
function MyTools:tableToString(t, separator)
	local str = ""
	for _, value in pairs(t) do
		if str == "" then
			str = tostring(value)
		else
			str = str .. separator .. tostring(value)
		end
	end
	return str
end


function MyTools:getCountElements(myTable)
	local i = 0
	for _, _ in pairs(myTable) do
		i = i + 1
	end
	return i	
end

function MyTools:round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

-- Save copied tables in `copies`, indexed by original table.
-- http://lua-users.org/wiki/CopyTable
function MyTools:deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[MyTools:deepcopy(orig_key, copies)] = MyTools:deepcopy(orig_value, copies)
            end
            setmetatable(copy, MyTools:deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
