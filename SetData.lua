local ADDON_NAME, ns = ...
ns.SetData = ns.SetData or {}
local SetData = ns.SetData

function SetData:BuildSetStatus(setID)
    local setInfo = C_TransmogSets.GetSetInfo(setID)
    if not setInfo or not setInfo.name then
        return nil
    end

    local sourceIDs = C_TransmogSets.GetAllSourceIDs(setID)
    if not sourceIDs or #sourceIDs == 0 then
        return nil
    end

    local collected, missing = {}, {}

    for _, sourceID in ipairs(sourceIDs) do
        local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
        if sourceInfo and sourceInfo.itemID then
            if sourceInfo.isCollected then
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

    table.sort(missing, function(a, b) return (a.inventorySlot or 99) < (b.inventorySlot or 99) end)

    return {
        setID = setID,
        name = setInfo.name,
        percent = percent,
        collected = collected,
        missing = missing,
    }
end
