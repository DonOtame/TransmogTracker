local ADDON_NAME, ns = ...
ns.SetData = ns.SetData or {}
local SetData = ns.SetData

function SetData:BuildSetStatus(setID)
    local setInfo = C_TransmogSets.GetSetInfo(setID)
    if not setInfo or not setInfo.name then
        return nil
    end

    local sources = C_TransmogSets.GetSetSources(setID)
    if not sources then
        return nil
    end

    local collected, missing = {}, {}

    for sourceID, isCollected in pairs(sources) do
        local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
        if sourceInfo and sourceInfo.itemID then
            if isCollected then
                table.insert(collected, sourceInfo.itemID)
            else
                table.insert(missing, {
                    itemID = sourceInfo.itemID,
                    sourceID = sourceID,
                    inventorySlot = sourceInfo.inventorySlot,
                    usableByPlayer = sourceInfo.isValidSourceForPlayer ~= false,
                })
            end
        end
    end

    local total = #collected + #missing
    local percent = total > 0 and math.floor((#collected / total) * 100) or 100

    return {
        setID = setID,
        name = setInfo.name,
        percent = percent,
        collected = collected,
        missing = missing,
    }
end
