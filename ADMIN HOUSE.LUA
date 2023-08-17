--FUCKING HATE THIS DUDE 2246031345;

local allowBuilding = true

local bootCommands = {
    {false;":chatnotifyc all 0 255 0 [OVERLORD]: Loaded OVERLORD server monitor."};
    {false;":chatnotifyc all 255 255 255 [OVERLORD]: Please do not abuse or crash anyone."};
    {false;":setmessage ['OVERLORD']: Loaded, Please do not abuse or crash anyone."};
    {true;function() task.wait(5) end};
    {false;":setmessage off"};
    {true;function()
        if allowBuilding then
            return ":chatnotifyc all 0 255 0 [SETTINGS]: building is allowed!"
        end
        return ":chatnotifyc all 255 0 0 [SETTINGS]: building is not allowed."
    end};
}
local buildingGrant = {
    {true;function() allowBuilding = true end};
    {false;":music 2778386920 true"};
    {false;":chatnotifyc all 15 235 15 [OVERLORD]: THIS SERVER HAS BEEN GRANTED BUILDING PERMS BACK."};
}
local buildingRevoke = {
    {true;function() allowBuilding = false end};
    --{false;":music 7023635858"};
    {false;":music 2778386920 true"};
    {false;":chatnotifyc all 235 15 15 [OVERLORD]: THIS SERVER HAS BEEN REVOKED BUILDING PERMS."};
}
local crash = {
    {true;function(person) return ":loadb OVERLORD_CRASHPAD" end};
    {true;function(person) return ":jail " .. person end};
    {true;function(person) return ":re " .. person end};
    {true;function() task.wait(4) end};
    {true;function(person) return ":unjail " .. person end};
    {true;function() task.wait(1) end};
    {true;function(person) return ":tp " .. person .. " waypoint-crashpad" end};
    {true;function(person) return ":chatnotifyc all 235 15 15 [OVERLORD]: " .. person .. " has been sent to Brazil." end};
}

function say(x)
    local cb = game:GetService("Players").LocalPlayer.PlayerGui.Chat.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar
    cb.Text = x
    cb:CaptureFocus()
    cb:ReleaseFocus(true)
end

function saySeq(x, ...)
    for _, a in ipairs(x) do
        if a[1] then
            local result = a[2](...)
            if result then
                say("/e " .. result, "All")
            end
        else
            say("/e " .. a[2], "All")
        end
    end
end

function buildClear()
    local folder = game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Folder")
    if folder then
        local remote = folder.SyncAPI.ServerEndpoint
        local removeList = {}
        for _, a in ipairs(workspace:GetChildren()) do
            if not table.find({"Terrain"; "Camera"}, a.ClassName) and a.Name ~= "OVERLORD_CRASHPAD" and a.Name ~= "SecureParts" and not game.Players:GetPlayerFromCharacter(a) then
                table.insert(removeList, a)
            end
        end
        for _, a in ipairs(workspace.BuildingBlocks:GetChildren()) do
            table.insert(removeList, a)
        end
        pcall(function() remote:InvokeServer("Remove", removeList) end)
    else
        say("/e :f3x")
        game:GetService("Players").LocalPlayer.Backpack.ChildAdded:Wait()
        task.wait(0.25)
        buildClear()
    end
end

local banList = {}
local permBan = {[1571050455] = true; [261470664] = true; --[[[2404242404] = true; [3894108483] = true]]}

function plrAdd(plr)
    local id = plr.UserId
    if permBan[id] then
        saySeq(crash, target)
    elseif permBan[id] then
        saySeq(crash, target)
    end
end

game.Players.PlayerAdded:Connect(function(plr)
    plrAdd(plr)
end)

for _, a in ipairs(game.Players:GetPlayers()) do
    plrAdd(a)
end

game.Players.LocalPlayer.Chatted:Connect(function(msg)
    if msg == ">build off" then
        saySeq(buildingRevoke)
    elseif msg == ">build on" then
        saySeq(buildingGrant)
    elseif msg == ">build clear" then
        buildClear()
    elseif msg:sub(1, 7) == ">crash " then
        local target = msg:sub(8)
        if game.Players:FindFirstChild(target) then
            saySeq(crash, target)
        end
    elseif msg:sub(1, 5) == ">ban " then
        local target = msg:sub(6)
        local plr = game.Players:FindFirstChild(target)
        if plr then
            banList[target] = true
            saySeq(crash, target)
        end
    elseif msg:sub(1, 7) == ">unban " then
        local target = msg:sub(8)
        if tonumber(target) then
            target = tonumber(target)
            banList[target] = nil
        end
    elseif msg:sub(1, 6) == ">pban " then
        local target = msg:sub(7)
        local plr = game.Players:FindFirstChild(target)
        if plr then
            permBan[target] = true
            saySeq(crash, target)
        end
    elseif msg:sub(1, 8) == ">unpban " then
        local target = msg:sub(9)
        if tonumber(target) then
            target = tonumber(target)
            permBan[target] = nil
        end
    elseif msg:sub(1, 10) == ">printbans" then
        print("All bans:")
        for a, _ in pairs(banList) do
            print(a)
        end
    elseif msg:sub(1, 11) == ">printpbans" then
        print("All perm bans:")
        for a, _ in pairs(permBan) do
            print(a)
        end
    end
end)
task.spawn(function()
    while task.wait(0.1) do
        if not workspace.SecureParts.AdminPads:FindFirstChild(game.Players.LocalPlayer.Name .. "'s admin") then
            local ogPos = game.Players.LocalPlayer.Character.PrimaryPart.CFrame
            game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(workspace.SecureParts.AdminPads:FindFirstChild("Touch to get admin").Head.CFrame)
            task.wait(0.25)
            game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(ogPos)
        end
    end
end)
game:GetService("RunService").RenderStepped:Connect(function()
    for _, a in ipairs(workspace:GetDescendants()) do
        if a:IsA("SpecialMesh") then
            a:Destroy()
        end
    end
end)
task.spawn(function()
    while true do
        task.wait(0.25)
        if not allowBuilding then
            buildClear()
        end
    end
end)
task.wait(3)
saySeq(bootCommands)
