local success, frontBlock, topBlock, bottomBlock

while true do

	-- Check the fuel level and refuel if needed
	checkFuel()

	-- Front block (turn right/left)
	success, frontBlock = turtle.inspect()
	if success then
		if frontBlock.name == "minecraft:red_wool" then
			turtle.turnRight()
		elseif frontBlock.name == "minecraft:yellow_wool" then
			turtle.turnLeft()
		end
	end

	-- Top block (manage inventory/chest)
	success, topBlock = turtle.inspectUp()
	if success then
		if topBlock.name == "minecraft:brown_wool" then
			-- Drop all the inventory in the chest under
			dropInventoryDown()

		elseif topBlock.name == "minecraft:green_wool" then
			-- Get sapplings until the chest is empty or the turtle has at least 16
			write("Collecting sapplings in the chest below...")

			turtle.select(2)
			turtle.suckDown()
			local sapplingsCount = turtle.getItemCount(2)

			while sapplingsCount < 16 do
				turtle.dropDown()
				turtle.suckDown()
				sapplingsCount = turtle.getItemCount(2)
			end

			print("Done (has "..turtle.getItemCount(2).." sapplings).")

		elseif topBlock.name == "minecraft:black_wool" then
			-- Get a fuel source from the chest under and refuel until a certain threshold is exceeded
			write("Collecting a fuel source in the chest below and refueling the turtle...")

			turtle.select(1)
			turtle.suckDown()
			local fuelLevel = turtle.getFuelLevel()

			while fuelLevel < 200 do
				checkFuel(200)
				turtle.select(1)
				turtle.dropDown()
				turtle.suckDown()
			end

			print("Done (fuel level: "..turtle.getFuelLevel..", fuel sources: "..turtle.getItemCount(1)..").")
		end
	end

	-- Bottom block
	-- success, bottomBlock = turtle.inspectDown()
	-- if success then
		-- if bottomBlock.name == ""

	turtle.forward()
end


-- Used to refuel the turtle by checking each slot of the inventory
-- If specified, the fuelThreshold indicates the fuel level the turtle has to have before going back to work
function checkFuel(fuelThreshold)
	fuelThreshold = fuelThreshold or 1
	local fuelLevel = turtle.getFuelLevel()

	while fuelLevel < fuelThreshold do

		-- Try to refuel on each inventory slot
		for i = 1, 16 do
			turtle.select(i)
			hasRefueled = turtle.refuel(1)
			fuelLevel = turtle.getFuelLevel()

			-- If found a slot where there is a source a fuel, refuel until there is no item left or the fuelLevel is abose the fuelThreshold
			while hasRefueled and fuelLevel < 10 do
				hasRefueled = turtle.refuel(1)
				fuelLevel = turtle.getFuelLevel()
			end

			-- Check if the fuelLevel is ok (above fuelThreshold), if so end the function
			if fuelLevel >= fuelThreshold then
				break
			end
		end
	end
end


-- Used to drop the turtle's inventory in a chest located under the turtle
function dropInventoryDown(from, to)
	from = from or 1
	to = to or 16

	if from == 1 and to == 16 then
		write("Dropping all the inventory inside of the the chest below...")
	else
		write("Dropping the inventory from slot "..from.." to "..to.."...")
	end

	for i = from, to do
		turtle.select(i)
		turtle.dropDown()
	end

	print(" Done.")
end