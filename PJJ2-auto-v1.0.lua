local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

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

local function teleportToArrowAndClick(arrow)
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()

    -- Ensure the arrow has a Handle with a valid CFrame
    local handle = arrow:FindFirstChild("Handle")
    if handle and handle.CFrame then
        local position = handle.CFrame.Position
        character:MoveTo(position)

        -- Construct the ClickDetector path dynamically
        local clickDetectorPath = "Items." .. arrow.Name .. ".ClickBox.ClickDetector"
        fireClickDetector(clickDetectorPath)
    else
        warn("Invalid Stand Arrow object or missing Handle/CFrame: ", arrow)
    end
end

local function findAndTeleport()
    local arrows = Workspace.Items:GetChildren()
    for _, arrow in pairs(arrows) do
        if arrow.Name == "Stand Arrow" then
            teleportToArrowAndClick(arrow)
        end
    end
end

-- Run every 3 seconds
RunService.Heartbeat:Connect(function()
    findAndTeleport()
end)

-- Initial run to avoid delay
findAndTeleport()
