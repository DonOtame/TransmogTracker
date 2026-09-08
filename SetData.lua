local ADDON_NAME, ns = ...
ns.SetData = ns.SetData or {}
local SetData = ns.SetData

function SetData:BuildSetStatus(setID)
    local setInfo = C_TransmogSets.GetSetInfo(setID)
    if not setInfo or not setInfo.name then
        return nil
    end

    -- GetAllSourceIDs returns every individual appearance variant per slot
    -- (e.g. 2 alternate looks for the same helm), which inflates counts
    -- beyond Blizzard's own Wardrobe count. GetSetPrimaryAppearances
    -- returns exactly one entry per conceptual slot (confirmed live:
    -- 9 entries for a set Blizzard's own UI also shows as X/9), and each
    -- entry's appearanceID is itself a valid sourceID for GetSourceInfo.
    local primaryAppearances = C_TransmogSets.GetSetPrimaryAppearances(setID)
    if not primaryAppearances or #primaryAppearances == 0 then
        return nil
    end

    local collected, missing = {}, {}

    for _, entry in ipairs(primaryAppearances) do
        local sourceInfo = C_TransmogCollection.GetSourceInfo(entry.appearanceID)
        if sourceInfo and sourceInfo.itemID then
            if entry.collected then
                table.insert(collected, sourceInfo.itemID)
            else
                table.insert(missing, {
                    itemID = sourceInfo.itemID,
                    sourceID = entry.appearanceID,
                    categoryID = sourceInfo.categoryID,
                    usableByPlayer = sourceInfo.isValidSourceForPlayer ~= false,
                })
            end
        end
    end

    local total = #collected + #missing
    local percent = total > 0 and math.floor((#collected / total) * 100) or 100

    table.sort(missing, function(a, b) return (a.categoryID or 99) < (b.categoryID or 99) end)

    return {
        setID = setID,
        name = setInfo.name,
        percent = percent,
        collected = collected,
        missing = missing,
    }
end
