-------------------------
--   Made by FeuFeve   --
-------------------------


local index = 1

local line = 1
local goal = 30 -- TO CHANGE


-- Move the turtle forward and try to place a block in the inventory
local function forwardAndPlace()
	turtle.forward()

	local success = false
	while !success do
		success = turtle.placeDown()
		if !success then
			index = index + 1
			turtle.select(index)
		end
	end
end



-- Main
turtle.select(index)
turtle.placeDown()

while true do

	local success, frontBlock = turtle.inspect()
	if success then
		if frontBlock.name == "minecraft:stone" then
			if line == goal then
				break
			end

			if index % 2 == 1 then
				turtle.turnLeft()
				forwardAndPlace()
				turtle.turnLeft()
			else
				turtle.turnRight()
				forwardAndPlace()
				turtle.turnRight()
			end

			line = line + 1
		end
	end

	forwardAndPlace()

end