-------------------------
--   Made by FeuFeve   --
-------------------------


local m = peripheral.wrap("right")
rednet.open("left")

m.setTextScale(1.5)
m.setTextColor(colors.white)

local logsChopped, treesCut, fuelUsed = 0, 0, 0
local acceptedIDs = {0}

function round(num, numDecimalPlaces)
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function isInAcceptedIDs(id)
	for i, acceptedID in ipairs(acceptedIDs) do
		if id == acceptedID then
			return true
		end
	end
	return false
end

function display()
	m.clear()

	m.setCursorPos(13, 2)
	m.write("FARMS STATS")

	m.setCursorPos(8, 5)
	m.write("Trees cut: "..treesCut)

	m.setCursorPos(5, 7)
	m.write("Logs chopped: "..logsChopped)

	if logsChopped ~= 0 and fuelUsed ~= 0 then -- Avoid "division by 0" error
		m.setCursorPos(3, 9)
		m.write("Ratio fuel/log: "..round(fuelUsed/logsChopped, 2))
	end
end

display()

while true do
	event, id, text = os.pullEvent()

	if event == "rednet_message" and isInAcceptedIDs(id) then
		if text == "log" then
			logsChopped = logsChopped + 1
		elseif text == "tree" then
			treesCut = treesCut + 1
		elseif text == "fuel" then
			fuelUsed = fuelUsed + 1
		end
		display()
	end
end