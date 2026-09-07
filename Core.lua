local ADDON_NAME, ns = ...

local pendingRestoreSetID = nil

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("TRANSMOG_COLLECTION_UPDATED")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        TransmogTrackerDB = TransmogTrackerDB or {}
    elseif event == "PLAYER_LOGIN" then
        if TransmogTrackerDB.trackedSetID then
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
    if command == "track" then
        local setID = tonumber(rest)
        if not setID then
            print("|cff00ff00[TransmogTracker]|r Uso: /tt track <setID>")
            return
        end
        if ns.TrackerFrame:SetTrackedSet(setID) then
            print("|cff00ff00[TransmogTracker]|r Trackeando set " .. setID)
        else
            print("|cffff0000[TransmogTracker]|r Set " .. setID .. " no valido.")
        end
    elseif command == "stop" then
        ns.TrackerFrame:StopTracking()
        print("|cff00ff00[TransmogTracker]|r Seguimiento detenido.")
    else
        print("|cff00ff00[TransmogTracker]|r Uso: /tt track <setID> | /tt stop")
    end
end
