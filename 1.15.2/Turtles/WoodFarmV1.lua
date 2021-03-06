-------------------------
--   Made by FeuFeve   --
-------------------------


rednet.open("left") -- TO CHANGE
farmCentralComputerID = 1 -- TO CHANGE


-- Used to know if a certain bloc is a log ("minecraft:oak_log" for example)
local function endsWith(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end


-- Used to display a message on the turtle's screen
local function updateMessage(message)
	term.clear()
	term.setCursorPos(2, 2)
	write(message)
end


-- Used to refuel the turtle by checking each slot of the inventory
-- If specified, the fuelThreshold indicates the fuel level the turtle has to have before going back to work
local function checkFuel(fuelThreshold)
	updateMessage("Searching for a fuel source...")

	fuelThreshold = fuelThreshold or 1
	local fuelLevel = turtle.getFuelLevel()

	while fuelLevel < fuelThreshold do

		-- Try to refuel on each inventory slot
		for i = 1, 16 do
			turtle.select(i)
			hasRefueled = turtle.refuel(1)
			fuelLevel = turtle.getFuelLevel()

			-- If found a slot where there is a source a fuel, refuel until there is no item left or the fuelLevel is abose the fuelThreshold
			while hasRefueled and fuelLevel < fuelThreshold do
				hasRefueled = turtle.refuel(1)
				fuelLevel = turtle.getFuelLevel()
			end

			-- Check if the fuelLevel is ok (above fuelThreshold), if so end the function
			if fuelLevel >= fuelThreshold then
				break
			end
		end
	end
	
	updateMessage("Working...")
end


-- Used to drop the turtle's inventory in a chest located under the turtle
local function dropInventoryDown(from, to)
	checkFuel(100) -- Ensure that the turtle has at least 100 fuel before emptying its inventory

	from = from or 1
	to = to or 16

	for i = from, to do
		turtle.select(i)
		turtle.dropDown()
	end
end


-- Used to plant a sapling
local function plantTree()
	turtle.select(2)

	local item = turtle.getItemDetail()
	if item then
		if endsWith(item.name, "sapling") then
			turtle.placeDown()
		else
			for i = 1, 16 do
				turtle.select(i)

				local item = turtle.getItemDetail()
				if item then
					if endsWith(item.name, "sapling") then
						turtle.placeDown()
						break
					end
				end
			end
		end
	end
end


-- Used to cut a tree
local function cutTree()
	-- Cut the tree (go up)
	while true do
		checkFuel()

		local success, topBlock = turtle.inspectUp()
		if success then
			if endsWith(topBlock.name, "log") then
				turtle.digUp()
				rednet.send(farmCentralComputerID, "log")

				turtle.up()
				rednet.send(farmCentralComputerID, "fuel")
			else
				break
			end
		else
			break
		end
	end

	-- Go back down, cut the last log (trunk) and replace it with a sapling
	while true do
		checkFuel()

		local success, bottomBlock = turtle.inspectDown()
		if success then
			if endsWith(bottomBlock.name, "log") then
				turtle.digDown()
				rednet.send(farmCentralComputerID, "log")

				plantTree()
				break
			elseif endsWith(bottomBlock.name, "leaves") then
				turtle.digDown()
				turtle.down()
				rednet.send(farmCentralComputerID, "fuel")
			elseif endsWith(bottomBlock.name, "sapling") then
				break
			else
				turtle.digUp()
				turtle.up()
				rednet.send(farmCentralComputerID, "fuel")
				break
			end
		else
			turtle.down()
			rednet.send(farmCentralComputerID, "fuel")
		end
	end

	rednet.send(farmCentralComputerID, "tree")
end


-- Used when restarting the turtle
local function init()
	checkFuel()

	local success, bottomBlock = turtle.inspectDown()
	if success then
		if not endsWith(bottomBlock.name, "log") and not endsWith(bottomBlock.name, "leaves") then
			return
		end
	end

	local success, topBlock = turtle.inspectUp()
	if success then
		if endsWith(topBlock.name, "log") or endsWith(topBlock.name, "leaves") then
			turtle.digUp()
			if endsWith(topBlock.name, "log") then
				rednet.send(farmCentralComputerID, "log")
			end

			turtle.up()
			rednet.send(farmCentralComputerID, "fuel")

			checkFuel()
			cutTree()
		end
	else
		turtle.up()
		rednet.send(farmCentralComputerID, "fuel")

		checkFuel()
		cutTree()
	end
end



-- Main
local success, frontBlock, topBlock, bottomBlock
local fuelThreshold = 200

init()

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
		elseif endsWith(frontBlock.name, "log") then
			turtle.dig()
			rednet.send(farmCentralComputerID, "log")
		elseif endsWith(frontBlock.name, "leaves") then
			turtle.dig()
		elseif endsWith(frontBlock.name, "sapling") then
			turtle.digUp()
			turtle.up()
			rednet.send(farmCentralComputerID, "fuel")
		end
	end

	-- Top block (manage inventory/chest)
	success, topBlock = turtle.inspectUp()
	if success then
		if endsWith(topBlock.name, "log") then
			cutTree()

		elseif topBlock.name == "minecraft:brown_wool" then
			-- Drop all the inventory in the chest under
			dropInventoryDown()

		elseif topBlock.name == "minecraft:green_wool" then
			-- Get saplings until the chest is empty or the turtle has at least 16

			turtle.select(2)
			turtle.suckDown()

		elseif topBlock.name == "minecraft:black_wool" then
			-- Get a fuel source from the chest under and refuel until a certain threshold is exceeded
			turtle.select(1)
			turtle.suckDown()
			local fuelLevel = turtle.getFuelLevel()

			while fuelLevel < fuelThreshold do
				checkFuel(fuelThreshold)
				fuelLevel = turtle.getFuelLevel()
				turtle.select(1)
				turtle.dropDown()
				turtle.suckDown()
			end
		end
	end

	-- Bottom block
	success, bottomBlock = turtle.inspectDown()
	if success then
		if endsWith(bottomBlock.name, "log") then
			-- Cut the last log (trunk) and replant a sapling
			turtle.digDown()
			rednet.send(farmCentralComputerID, "log")

			plantTree()
		end
	else
		plantTree()
	end


	turtle.forward()
	rednet.send(farmCentralComputerID, "fuel")
end