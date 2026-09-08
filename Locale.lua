local ADDON_NAME, ns = ...

-- English is the base locale; other locales override individual keys below.
local L = {
    STOP_TRACKING = "Stop Tracking",
    TRACK_BUTTON = "Track",
    SET_COMPLETE = "Set complete!",
    PIECES_FORMAT = "%d/%d pieces (%d%%)",
    ITEM_FALLBACK = "Item %d",
    HOOK_FAIL_DETAIL = "Could not hook the difficulty button (%s). Use /tt track <setID> to track manually.",
    HOOK_FAIL_LIST = "Could not hook the Sets list (%s). Use /tt track <setID> to track manually.",
    USAGE_TRACK = "Usage: /tt track <setID>",
    NOW_TRACKING = "Now tracking set %d",
    INVALID_SET = "Set %d is not valid.",
    TRACKING_STOPPED = "Tracking stopped.",
    USAGE_GENERAL = "Usage: /tt track <setID> | /tt stop",
}
ns.L = L

local locale = GetLocale()
if locale == "esES" or locale == "esMX" then
    L.STOP_TRACKING = "Detener seguimiento"
    L.TRACK_BUTTON = "Seguir"
    L.SET_COMPLETE = "Set completo!"
    L.PIECES_FORMAT = "%d/%d piezas (%d%%)"
    L.ITEM_FALLBACK = "Item %d"
    L.HOOK_FAIL_DETAIL = "No se pudo enganchar el boton de dificultad (%s). Usa /tt track <setID> para trackear manualmente."
    L.HOOK_FAIL_LIST = "No se pudo enganchar la lista de Sets (%s). Usa /tt track <setID> para trackear manualmente."
    L.USAGE_TRACK = "Uso: /tt track <setID>"
    L.NOW_TRACKING = "Trackeando set %d"
    L.INVALID_SET = "Set %d no valido."
    L.TRACKING_STOPPED = "Seguimiento detenido."
    L.USAGE_GENERAL = "Uso: /tt track <setID> | /tt stop"
end

function ns.Print(msg)
    print("|cff00ff00[TransmogTracker]|r " .. msg)
end

function ns.PrintError(msg)
    print("|cffff0000[TransmogTracker]|r " .. msg)
end
