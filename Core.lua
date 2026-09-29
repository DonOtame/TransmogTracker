local ADDON_NAME, ns = ...

local RESTORE_MAX_ATTEMPTS = 15
local RESTORE_INTERVAL = 2

-- The transmog collection cache can still be cold right after login: sets may
-- not resolve yet, and pieces can be reported as not wearable by this
-- character when they are. Retry on a timer (and on TRANSMOG_COLLECTION_UPDATED
-- via Refresh) until everything is loaded with no unusable flags, or the
-- attempts run out - a set with genuinely unwearable pieces just stops there.
local function RestoreTrackedSets(attempt)
    local allLoaded, hasUnusable = ns.TrackerFrame:Refresh()
    if (allLoaded and not hasUnusable) or attempt >= RESTORE_MAX_ATTEMPTS then
        return
    end
    C_Timer.After(RESTORE_INTERVAL, function()
        RestoreTrackedSets(attempt + 1)
    end)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("TRANSMOG_COLLECTION_UPDATED")

frame:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        TransmogTrackerDB = TransmogTrackerDB or {}
        TransmogTrackerDB.trackedSetIDs = TransmogTrackerDB.trackedSetIDs or {}
        -- Migrate the old single-set field to the list.
        local legacyID = TransmogTrackerDB.trackedSetID
        if legacyID then
            if not ns.TrackerFrame:IsTracked(legacyID) then
                table.insert(TransmogTrackerDB.trackedSetIDs, legacyID)
            end
            TransmogTrackerDB.trackedSetID = nil
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- PLAYER_ENTERING_WORLD fires on every loading screen (login, zone,
        -- instance transitions), not just once - only restore on the first
        -- one (login or /reload), not on every subsequent zone change.
        local isInitialLogin, isReloadingUi = arg1, arg2
        if isInitialLogin or isReloadingUi then
            RestoreTrackedSets(1)
        end
    elseif event == "TRANSMOG_COLLECTION_UPDATED" then
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
        if ns.TrackerFrame:AddSet(setID) then
            ns.Print(string.format(ns.L.NOW_TRACKING, setID))
        else
            ns.PrintError(string.format(ns.L.INVALID_SET, setID))
        end
    elseif command == "stop" then
        local setID = tonumber(rest)
        if setID then
            ns.TrackerFrame:RemoveSet(setID)
            ns.Print(string.format(ns.L.STOPPED_SET, setID))
        else
            ns.TrackerFrame:StopAll()
            ns.Print(ns.L.TRACKING_STOPPED)
        end
    elseif command == "anchor" then
        ns.TrackerFrame:ResetAnchor()
        ns.Print(ns.L.ANCHOR_RESET)
    else
        ns.Print(ns.L.USAGE_GENERAL)
    end
end
