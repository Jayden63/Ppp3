local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Generalized function to fire ClickDetector
local function fireClickDetector(path)
    local detector = workspace
    for _, part in pairs(string.split(path, ".")) do
        detector = detector[part]
        if not detector then
            warn("Could not find ClickDetector at path: " .. path)
            return
        end
    end
    if detector and detector:IsA("ClickDetector") then
        fireclickdetector(detector)
    else
        warn("Object at path '" .. path .. "' is not a ClickDetector.")
    end
end

-- Generalized teleport and click function
local function teleportToItem(item, clickDetectorPath)
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()

    -- Ensure the item has a Handle with a valid CFrame
    local handle = item:FindFirstChild("Handle")
    if handle and handle.CFrame then
        local position = handle.CFrame.Position
        character:MoveTo(position)

        -- Fire the corresponding ClickDetector
        fireClickDetector(clickDetectorPath)
    else
        warn("Invalid item or missing Handle/CFrame: ", item)
    end
end

-- Search for specific items and teleport/click based on their type
local function findAndTeleport()
    local items = Workspace.Items:GetChildren()
    for _, item in pairs(items) do
        if item.Name == "Stand Arrow" then
            teleportToItem(item, "Items.Stand Arrow.ClickBox.ClickDetector")
        elseif item.Name == "Rokakaka Fruit" then
            teleportToItem(item, "Items.Rokakaka Fruit.ClickBox.ClickDetector")
        end
    end
end

-- Run every 3 seconds
RunService.Heartbeat:Connect(function()
    findAndTeleport()
end)

-- Initial run to avoid delay
findAndTeleport()
