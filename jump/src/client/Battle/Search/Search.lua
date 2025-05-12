local Search = {}

function Search:SearchNearlyByTag(searchOrigin, tagName)
    local findPart = nil
	local distance2Character = math.huge
    
	local dir = nil
	for _, part in pairs(workspace:GetDescendants()) do
		if part:HasTag(tagName) then
			local curDis = (part.CFrame.p - searchOrigin).Magnitude
			dir = (part.CFrame.p - searchOrigin).unit
			if curDis < distance2Character then
				findPart = part
				distance2Character = curDis
			end
		end
	end
	
	if findPart ~= nil then
		return findPart, dir
	end
end

return Search