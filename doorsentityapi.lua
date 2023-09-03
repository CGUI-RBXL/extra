print("DOORS API v1.0 LOADED!")
--Services
local module_events = require(game.ReplicatedStorage.ClientModules.Module_Events)
local localPlayer:Player = game:GetService("Players").LocalPlayer
local tweenService:TweenService = game:GetService("TweenService")
local runService:RunService = game:GetService("RunService")

--The api for the entity paths
local pathNodes = {workspace.CurrentRooms:FindFirstChild("0").RoomEntrance}
workspace.CurrentRooms.ChildAdded:Connect(function(room:Model)
	table.insert(pathNodes, room.RoomEntrance)
	local pathfindnodes:Folder = room:WaitForChild("PathfindNodes", 5)
	if not pathfindnodes then warn("failed to get nodes for room " .. room.Name .. ".") end
	for _, node:BasePart in ipairs(pathfindnodes:GetChildren()) do
		table.insert(pathNodes, node)
	end
end)
runService.RenderStepped:Connect(function()
	for _, node:BasePart in ipairs(pathNodes) do
		if node.Parent == nil then
			table.remove(table.find(pathNodes, node))
		end
	end
end)

--The class for entities & main variables
local class = {}

--Just some functions cuz why not
local makeEvent = function()
	local event = Instance.new("BindableEvent")
	return {
		fire = function(...)
			event:Fire(...)
		end,
		event = event.Event;
	}
end
local blF = function()
	return function()end
end
local getRoom = function(a)
	local oldObject = a
	while a ~= workspace.CurrentRooms do
		oldObject = a
		if a == game then
			warn("getRoom reaches game from " a:GetFullName .. ".")
			return nil
		end
		a = a.Parent
	end
	return oldObject
end

--Creates a new entity
class.new = function(model:Model)
	--Needs to be "special"
	assert(model and typeof(model) == "Instance" and model:IsA("Model"), "object must be an instance.")
	assert(model.Archivable, "object must be Archivable.")
	assert(model.PrimaryPart, "object must have a PrimaryPart.")
	local localModel = model:Clone()
	
	local object = {}
	
	--All the properties
	object.properties = {}
	object.properties.speed = 60
	object.properties.startDelay = 3
	
	object.properties.flickerLights = true
	object.properties.flickerDuration = 0.5
	object.properties.breakLights = true
	
	object.properties.movingBackwards = false
	object.properties.reboundTimes = 0
	object.properties.reboundDelay = 3
	
	object.properties.kills = true
	object.properties.sight = 45
	
	object.properties.deathName = "Unnamed"
	object.properties.deathMessages = {"Lorem ipsum dolor sit amet"; "add your own texts here"; "entity.deathMessages"}
	object.properties.roomsDeath = false
	
	--All the events
	local backendEvents = {}
	backendEvents.spawn = makeEvent()
	backendEvents.move = makeEvent()
	backendEvents.rebound = makeEvent()
	backendEvents.reboundFinished = makeEvent()
	backendEvents.finish = makeEvent()
	backendEvents.kill = makeEvent()
	
	object.events = {}
	for name:string, eventData in pairs(backendEvents) do
		object.events[name] = eventData.event
	end
	
	--All the callbacks
	object.callbacks = {}
	object.callbacks.preSpawn = blF()
	object.callbacks.onSpawn = blF()
	object.callbacks.onMove = blF()
	object.callbacks.onRebound = blF()
	object.callbacks.onReboundFinished = blF()
	object.callbacks.onFinish = blF()
	object.callbacks.onKill = blF()
	object.callbacks.postKill = blF()
	
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Include
	
	--Spawning & Sceduling
	object.spawn = function()
		object.callbacks.preSpawn()
		local entityModel:Model = localModel:Clone()
		entityModel.Parent = workspace
		local movingPart:BasePart = entityModel.PrimaryPart
		local offset:Vector3 = entityModel.WorldPivot.Position - movingPart.PrimaryPart.Position
		
		local moveTo = function(place:Vector3)
			object.callbacks.onMove(place)
			local distance = ((movingPart.Position + offset) - place).Magnitude
			local moveTime:number = distance / object.properties.speed
			tweenService:Create(movingPart, TweenInfo.new(moveTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Position = place - offset}):Play()
			task.wait(moveTime)
			backendEvents.move.event(place)
		end
		
		if object.properties.flickerLights then
			module_events.flicker(localPlayer:GetAttribute("CurrentRoom"), object.properties.flickerDuration)
		end
		
		local node, movingBackwards, reboundsLeft = 1, object.properties.movingBackwards, object.properties.reboundTimes
		if movingBackwards then
			node = #pathNodes
		end
		entityModel:PivotTo(pathNodes[node])
		rayParams.FilterDescendantsInstances = workspace.CurrentRooms:GetDescendants()
		table.insert(rayParams.FilterDescendantsInstances, localPlayer.Character.Humanoid.RootPart)
		local inRoom = -1
		local renderSteppedEntity = runService.RenderStepped:Connect(function()
			if localPlayer:GetAttribute("Alive") then
				if (movingPart.Position - localPlayer.Character.Humanoid.RootPart.Position).Magnitude <= object.properties.sight then
					local rayCast = workspace:Raycast(movingPart.Position, CFrame.lookAt(movingPart.Position, localPlayer.Character.Humanoid.RootPart.Position).LookVector * object.properties.sight, rayParams)
					if rayCast and rayCast.Instance == localPlayer.Character.Humanoid.RootPart then
						object.callbacks.onKill()
						if object.properties.kills then
							localPlayer.Character.Humanoid.Health = 0
							localPlayer:SetAttribute("Alive", false)
						end
						backendEvents.kill.fire()
						object.callbacks.postKill()
					end
				end
			end
			if object.properties.breakLights then
				local floorCast = workspace:Raycast(movingPart.Position, Vector3.yAxis * -25)
				if floorCast and floorCast.Instance then
					local room = getRoom(floorCast.Instance)
					if room then
						local roomNumber = tonumber(room.Name)
						if roomNumber then
							if roomNumber ~= inRoom then
								inRoom = roomNumber
								module_events.shatter(roomNumber)
							end
						end
					end
				end
			end
		end)
		object.callbacks.onSpawn()
		backendEvents.spawn.fire(entityModel)
		task.wait(object.properties.startDelay)
		while true do
			if movingBackwards then
				node -= 1
				if node < #pathNodes then
					if reboundsLeft > 0 then
						reboundsLeft -= 1
						object.callbacks.onReboundFinished(reboundsLeft)
						object.events.reboundFinished.event(reboundsLeft)
						task.wait(object.properties.reboundDelay)
						object.callbacks.onRebound(reboundsLeft)
						object.events.rebound.event(reboundsLeft)
						movingBackwards = false
						node += 1
						if reboundsLeft == 0 then
							movingPart.Anchored = false
							break
						end
					else
						movingPart.Anchored = false
						break
					end
				end
			else
				node += 1
				if node > #pathNodes then
					if reboundsLeft > 0 then
						movingBackwards = true
						node -= 1
					else
						movingPart.Anchored = false
						break
					end
				else
					moveTo(pathNodes[node])
				end
			end
		end
		object.callbacks.onFinish()
		backendEvents.finish.fire(entityModel)
	end
	
	--Stacking capibilites
	object.bang = function(prop, value)
		object.properties[prop] = value
		return object
	end
	
	return object
end

return class
