
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:getService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")


local TELEPORT_DELAY = 3
local autoFarmEnabled = true

local function fireClickDetector(path, retries)
    retries = retries or 3 -- Default to 3 retries
    local detector = workspace
    for _, part in pairs(string.split(path, ".")) do
        detector = detector[part]
        if not detector then
            warn("Could not find ClickDetector at path: " .. path .. ". Retries left: " .. (retries - 1))
            if retries > 1 then
                return fireClickDetector(path, retries - 1)
            else
                return
            end
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

    local handle = item:FindFirstChild("Handle")
    if handle and handle.CFrame then
        local position = handle.CFrame.Position
        character:MoveTo(position)

        -- Fire ClickDetector
        fireClickDetector(clickDetectorPath)
    else
        warn("Invalid item or missing Handle/CFrame: ", item)
    end
end


local itemPaths = {
    ["Requiem Arrow"] = "Items.Requiem Arrow.ClickBox.ClickDetector",
    ["Sinner's Soul"] = "Items.Sinner's Soul.ClickBox.ClickDetector",
    ["Aja Mask"] = "Items.Aja Mask.Handle.ClickDetector",
    ["Corpse Part"] = "Items.Corpse Part.handle.ClickDetector",
    ["Dio Diary"] = "Items.Dio Diary.handle.ClickDetector"
}


local function findAndTeleport()
    if not autoFarmEnabled then return end -- Exit if autofarm is disabled
    local items = Workspace.Items:GetChildren()
    for _, item in pairs(items) do
        local path = itemPaths[item.Name]
        if path then
            teleportToItem(item, path)
        end
    end
end

-- Run at adjustable intervals
RunService.Heartbeat:Connect(function()
    wait(TELEPORT_DELAY)
    findAndTeleport()
end)

-- Initial run to avoid delay
findAndTeleport()


local function createButtons()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false

    -- Toggle Button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Parent = screenGui
    toggleButton.Size = UDim2.new(0, 200, 0, 50)
    toggleButton.Position = UDim2.new(0.5, -210, 0, 20) -- Centered to the left of Sell button
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Text = "AutoFarm: ON"
    toggleButton.TextScaled = true
    toggleButton.BorderSizePixel = 2
    toggleButton.BorderColor3 = Color3.fromRGB(255, 255, 255)

    toggleButton.MouseButton1Click:Connect(function()
        autoFarmEnabled = not autoFarmEnabled
        toggleButton.Text = "AutoFarm: " .. (autoFarmEnabled and "ON" or "OFF")
        toggleButton.BackgroundColor3 = autoFarmEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(150, 50, 50)
    end)

    -- Sell Button
    local sellButton = Instance.new("TextButton")
    sellButton.Parent = screenGui
    sellButton.Size = UDim2.new(0, 200, 0, 50)
    sellButton.Position = UDim2.new(0.5, 10, 0, 20) -- Centered to the right of Toggle button
    sellButton.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
    sellButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    sellButton.Text = "Sell Items"
    sellButton.TextScaled = true
    sellButton.BorderSizePixel = 2
    sellButton.BorderColor3 = Color3.fromRGB(255, 255, 255)

    sellButton.MouseButton1Click:Connect(function()
        -- Stop autofarm temporarily (lowk doesnt work)
        local wasAutoFarmEnabled = autoFarmEnabled
        autoFarmEnabled = false
        toggleButton.Text = "AutoFarm: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)

        -- Teleport to fixed coordinates using SetPrimaryPartCFrame
        local player = Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.CFrame = CFrame.new(479.8929138183594, 25.999996185302734, 564.3986206054688)
        else
            warn("HumanoidRootPart not found for teleportation.")
        end

        -- Wait before interacting with the NPC
        wait(1) -- Add a delay to ensure the player is positioned correctly

        -- Equip and sell all items from the player's backpack in rapid succession
        local backpack = Players.LocalPlayer:WaitForChild("Backpack")
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                Players.LocalPlayer.Character.Humanoid:EquipTool(tool)
                wait(0.1) -- Small delay to simulate quick switching
                local sellEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Item"):WaitForChild("SellHoldingItem")
                if sellEvent then
                    sellEvent:FireServer()
                end
            end
        end

        -- Close the NPC shop
        local closeShopEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Item"):WaitForChild("CloseNPCShop")
        if closeShopEvent then
            closeShopEvent:FireServer()
        end

        -- Resume autofarm if it was enabled before
        if wasAutoFarmEnabled then
            autoFarmEnabled = true
            toggleButton.Text = "AutoFarm: ON"
            toggleButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        end
    end)
end

-- Ensure the toggle and sell buttons are always visible
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
createButtons()
