function inspect(direction)
	local success, data
	
	if direction == "up" then
		success, data = turtle.inspectUp()
	elseif direction == "down" then
		success, data = turtle.inspectDown()
	elseif direction == nil then
		success, data = turtle.inspect()
	end

	if success then
		return data
	else
		return nil
	end
end


data = inspect("up")
print(data.name)
print(data.metadata)