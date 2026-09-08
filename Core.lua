local ADDON_NAME, ns = ...

local pendingRestoreSetID = nil

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("TRANSMOG_COLLECTION_UPDATED")

frame:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        TransmogTrackerDB = TransmogTrackerDB or {}
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- PLAYER_ENTERING_WORLD fires on every loading screen (login, zone,
        -- instance transitions), not just once - only restore on the first
        -- one (login or /reload), not on every subsequent zone change.
        local isInitialLogin, isReloadingUi = arg1, arg2
        if (isInitialLogin or isReloadingUi) and TransmogTrackerDB.trackedSetID then
            if not ns.TrackerFrame:SetTrackedSet(TransmogTrackerDB.trackedSetID) then
                pendingRestoreSetID = TransmogTrackerDB.trackedSetID
            end
        end
    elseif event == "TRANSMOG_COLLECTION_UPDATED" then
        if pendingRestoreSetID then
            ns.TrackerFrame:SetTrackedSet(pendingRestoreSetID)
            pendingRestoreSetID = nil
        end
        ns.TrackerFrame:Refresh()
    end
end)

SLASH_TRANSMOGTRACKER1 = "/tt"
SlashCmdList["TRANSMOGTRACKER"] = function(msg)
    local command, rest = msg:match("^(%S*)%s*(.-)$")
    command = command:lower()
    if command == "track" then
        local setID = tonumber(rest)
        if not setID then
            ns.Print(ns.L.USAGE_TRACK)
            return
        end
        if ns.TrackerFrame:SetTrackedSet(setID) then
            ns.Print(string.format(ns.L.NOW_TRACKING, setID))
        else
            ns.PrintError(string.format(ns.L.INVALID_SET, setID))
        end
    elseif command == "stop" then
        ns.TrackerFrame:StopTracking()
        ns.Print(ns.L.TRACKING_STOPPED)
    else
        ns.Print(ns.L.USAGE_GENERAL)
    end
end
