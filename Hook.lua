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

local function GetOrCreateDetailTrackButton(detailsFrame)
    if detailsFrame.TransmogTrackerButton then
        return detailsFrame.TransmogTrackerButton
    end
    local button = CreateFrame("Button", nil, detailsFrame, "UIPanelButtonTemplate")
    button:SetSize(90, 22)
    button:SetText("Trackear")
    button:SetPoint("TOP", detailsFrame.VariantSetsDropdown, "BOTTOM", 0, -4)
    button:SetScript("OnClick", function()
        local setID = WardrobeCollectionFrame.SetsCollectionFrame.selectedSetID
        if setID then
            ns.TrackerFrame:SetTrackedSet(setID)
        end
    end)
    detailsFrame.TransmogTrackerButton = button
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

    local callbackFailed = false
    local detailButtonFailed = false
    scrollBox:RegisterCallback("OnUpdate", function()
        if not callbackFailed then
            local ok, err = pcall(function()
                scrollBox:ForEachFrame(function(rowButton)
                    if rowButton.setID then
                        GetOrCreateTrackButton(rowButton):Show()
                    else
                        if rowButton.TransmogTrackerButton then
                            rowButton.TransmogTrackerButton:Hide()
                        end
                    end
                end)
            end)
            if not ok then
                callbackFailed = true
                print("|cffff0000[TransmogTracker]|r No se pudo enganchar la lista de Sets (" .. tostring(err) .. "). Usa /tt track <setID> para trackear manualmente.")
            end
        end

        -- Independent of the list-row hook above: a "Trackear" button next
        -- to the difficulty selector in the detail/preview panel, so the
        -- exact currently-shown difficulty variant (WardrobeCollectionFrame
        -- .SetsCollectionFrame.selectedSetID, confirmed live to update with
        -- the dropdown) can be tracked directly.
        if not detailButtonFailed then
            local ok, err = pcall(function()
                local detailsFrame = WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame
                if detailsFrame and detailsFrame.VariantSetsDropdown then
                    GetOrCreateDetailTrackButton(detailsFrame):Show()
                end
            end)
            if not ok then
                detailButtonFailed = true
                print("|cffff0000[TransmogTracker]|r No se pudo enganchar el boton de dificultad (" .. tostring(err) .. "). Usa /tt track <setID> para trackear manualmente.")
            end
        end
    end, ns)
end

local function InstallHookSafely()
    local ok, err = pcall(TryInstallHook)
    if not ok then
        print("|cffff0000[TransmogTracker]|r No se pudo enganchar la lista de Sets (" .. tostring(err) .. "). Usa /tt track <setID> para trackear manualmente.")
    end
end

if C_AddOns.IsAddOnLoaded("Blizzard_Collections") then
    InstallHookSafely()
else
    EventUtil.ContinueOnAddOnLoaded("Blizzard_Collections", InstallHookSafely)
end
