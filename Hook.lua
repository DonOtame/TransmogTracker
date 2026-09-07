local ADDON_NAME, ns = ...

local function GetOrCreateTrackButton(rowButton)
    if rowButton.TransmogTrackerButton then
        return rowButton.TransmogTrackerButton
    end
    local button = CreateFrame("Button", nil, rowButton)
    button:SetSize(16, 16)
    button:SetPoint("RIGHT", rowButton, "RIGHT", -4, 0)
    button:SetNormalTexture("Interface/Buttons/UI-GuildButton-PublicNote-Up")
    button:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")
    button:SetScript("OnClick", function()
        if rowButton.setID then
            ns.TrackerFrame:SetTrackedSet(rowButton.setID)
        end
    end)
    rowButton.TransmogTrackerButton = button
    return button
end

local function TryInstallHook()
    local scrollBox = WardrobeCollectionFrame
        and WardrobeCollectionFrame.SetsCollectionFrame
        and WardrobeCollectionFrame.SetsCollectionFrame.ListContainer
        and WardrobeCollectionFrame.SetsCollectionFrame.ListContainer.ScrollBox

    if not scrollBox then
        error("SetsCollectionFrame.ListContainer.ScrollBox not found")
    end

    scrollBox:RegisterCallback("OnUpdate", function()
        scrollBox:ForEachFrame(function(rowButton)
            if rowButton.setID then
                GetOrCreateTrackButton(rowButton):Show()
            end
        end)
    end, ns)
end

local ok, err = pcall(TryInstallHook)
if not ok then
    print("|cffff0000[TransmogTracker]|r No se pudo enganchar la lista de Sets (" .. tostring(err) .. "). Usa /tt track <setID> para trackear manualmente.")
end
