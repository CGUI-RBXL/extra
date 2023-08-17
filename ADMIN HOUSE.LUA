--FUCKING HATE THIS DUDE 2246031345;

local allowBuilding = true
local removeMeshes = true
local shortenNames = true
local partDetection = true
local partStuffing = 16
local overloadInstances = true
local overloadInstancesStuffing = 4000
local hingeDetection = true
local hingeRate = 12
local killbrickBypass = true

for _, a in ipairs(workspace.SecureParts.Lava:GetChildren()) do
    a.TouchInterest:Destroy()
end

local bootCommands = {
    {false;":chatnotifyc all 0 255 0 [OVERLORD]: Loaded OVERLORD server monitor."};
    {false;":chatnotifyc all 255 255 255 [OVERLORD]: Please do not abuse or crash anyone."};
    {false;":setmessage ['OVERLORD']: Loaded, Please do not abuse or crash anyone."};
    {true;function() task.wait(5) end};
    {true;function()
        local msg = ":setmessage off"
        if allowBuilding then
            msg ..= "| :chatnotifyc all 0 255 0 [SETTINGS]: building is allowed!"
        else
            msg ..= "| :chatnotifyc all 255 0 0 [SETTINGS]: building is not allowed."
        end
        if partDetection then
            msg ..= "| :chatnotifyc all 255 255 255 [SETTINGS]: Only " .. partStuffing .. " parts allowed in one chunk (4x4x4)."
        end
        return msg
    end};
    --{false;":chatnotifyc all 255 255 255 [SETTINGS]: Only " .. overloadInstancesStuffing .. " parts allowed."};
}
local buildingGrant = {
    {true;function() allowBuilding = true end};
    {false;":music 2778386920 true"};
    {false;":chatnotifyc all 0 255 0 [OVERLORD]: THIS SERVER HAS BEEN GRANTED BUILDING PERMS BACK."};
}
local buildingRevoke = {
    {true;function() allowBuilding = false end};
    --{false;":music 7023635858"};
    {false;":music 2778386920 true"};
    {false;":chatnotifyc all 255 0 0 [OVERLORD]: THIS SERVER HAS BEEN REVOKED BUILDING PERMS."};
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

local plrGui = game:GetService("Players").LocalPlayer.PlayerGui
function descendant(parent, name)
    local children = parent:GetChildren()
    if #children > 0 then
        for _, a in ipairs(children) do
            if a.Name == name then
                return a
            else
                local descendantFound = descendant(a, name)
                if descendantFound then
                    return descendantFound
                end
            end
        end
    end
    return nil
end
local vim = game:GetService('VirtualInputManager')

local function m1click(x, y) 
    vim:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait()
    vim:SendMouseButtonEvent(x, y, 0, false, game, 0)
end
function say(x)
    local cmdBox = descendant(plrGui, "ComText")
    local exec
    if cmdBox then
        exec = cmdBox.Parent.Parent:FindFirstChild("Execute")
    end
    if exec then
        cmdBox.Text = x
        m1click(math.floor(exec.AbsolutePosition.X) + 1, math.floor(exec.AbsolutePosition.Y) + 51)
    else
        local cb = plrGui.Chat.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar
        local prev = cb.Text
        cb:CaptureFocus()
        cb.Text = "/e :cmdbox"
        cb:ReleaseFocus(true)
        if #prev > 0 then
            cb:CaptureFocus()
        end
        cb.Text = prev
        task.wait(1)
        say(x)
    end
end

function saySeq(x, ...)
    local pack = ""
    for a, b in ipairs(x) do
        if b[1] then
            if #pack > 0 then
                say(pack)
                pack = ""
            end
            local result = b[2](...)
            if result then
                pack ..= result .. " | "
                say(pack)
                pack = ""
            end
        else
            pack ..= b[2] .. " | "
        end
    end
    if #pack > 0 then
        say(pack)
        pack = ""
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
        say(":f3x")
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
    elseif msg:sub(1, 7) == ">super " then
        say(table.concat(table.create(100, msg:sub(8)), " | "))
    elseif msg:sub(1, 6) == ">mega " then
        say(table.concat(table.create(50, msg:sub(8)), " | "))
    elseif msg:sub(1, 6) == ">bulk " then
        say(table.concat(table.create(10, msg:sub(8)), " | "))
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
function makeSmartList(obj)
    return table.concat({math.round(obj.Position.X / 4),math.round(obj.Position.Y / 4),math.round(obj.Position.Z / 4)}, ",")
end
function isNotPlayer(obj)
    for _, a in ipairs(game.Players:GetPlayers()) do
        if obj:IsDescendantOf(a.Character) then
            return false
        end
    end
    return true
end
local dontSpam = true
game:GetService("RunService").RenderStepped:Connect(function()
    local smartlist = {}
    local deleteThings = false
    local rotates = 0
    for _, a in ipairs(workspace:GetDescendants()) do
        if a:IsA("SpecialMesh") and removeMeshes then
            a:Destroy()
        elseif a:IsA("Humanoid") and shortenNames and #a.DisplayName > 50 then
            a.DisplayName = "DISPLAYNAME TOO LONG TO DISPLAY"
        elseif (a:IsA("BasePart") or a:IsA("MeshPart") or a:IsA("Truss")) and isNotPlayer(a) and not (a:IsDescendantOf(workspace.SecureParts) or (a:FindFirstChild("OVERLORD_CRASHPAD") and a:IsDescendantOf(workspace.OVERLORD_CRASHPAD))) and partDetection and not deleteThings then
            local smartlistItem = makeSmartList(a)
            if smartlist[smartlistItem] then
                smartlist[smartlistItem] += 1
                if smartlist[smartlistItem] >= partStuffing then
                    deleteThings = true
                end
            else
                smartlist[smartlistItem] = 1
            end
        elseif a:IsA("Rotate") and not deleteThings then
            rotates += 1
            if rotates >= hingeRate then
                deleteThings = true
            end
        end
    end
    if deleteThings and dontSpam then
        say(":chatnotifyc all 255 0 0 [OVERLORD]: Cleared all parts to prevent server crash.")
        dontSpam = false
        buildClear()
        task.wait(0.5)
        dontSpam = true
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
game.CoreGui.BubbleChat.DescendantAdded:Connect(function(obj)
    if obj:IsA("TextLabel") then
        if #obj.Text > 200 then
            obj.Parent.Parent.Visible = false
        end
    end
end)
task.wait(3)
saySeq(bootCommands)
