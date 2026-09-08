local ADDON_NAME, ns = ...

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
    -- The ScrollBox's OnUpdate callback is used purely as a reliable
    -- "the Sets tab is open and active" trigger to create the detail-panel
    -- button once (idempotent) — the button itself reads
    -- WardrobeCollectionFrame.SetsCollectionFrame.selectedSetID live at
    -- click time, confirmed to track whichever difficulty is currently
    -- selected in DetailsFrame.VariantSetsDropdown.
    local scrollBox = WardrobeCollectionFrame
        and WardrobeCollectionFrame.SetsCollectionFrame
        and WardrobeCollectionFrame.SetsCollectionFrame.ListContainer
        and WardrobeCollectionFrame.SetsCollectionFrame.ListContainer.ScrollBox

    if not scrollBox then
        error("SetsCollectionFrame.ListContainer.ScrollBox not found")
    end

    local detailButtonFailed = false
    scrollBox:RegisterCallback("OnUpdate", function()
        if detailButtonFailed then
            return  -- Silent no-op after first failure
        end
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
