local ADDON_NAME, ns = ...

-- English is the base locale; other locales override individual keys below.
local L = {
    TRACK_BUTTON = "Track",
    UNTRACK_BUTTON = "Untrack",
    SET_COMPLETE = "Set complete!",
    ITEM_FALLBACK = "Item %d",
    HOOK_FAIL_DETAIL = "Could not hook the difficulty button (%s). Use /tt track <setID> to track manually.",
    HOOK_FAIL_LIST = "Could not hook the Sets list (%s). Use /tt track <setID> to track manually.",
    USAGE_TRACK = "Usage: /tt track <setID>",
    NOW_TRACKING = "Now tracking set %d",
    INVALID_SET = "Set %d is not valid.",
    TRACKING_STOPPED = "Tracking stopped.",
    STOPPED_SET = "Stopped tracking set %d",
    USAGE_GENERAL = "Usage: /tt track <setID> | /tt stop [setID] | /tt anchor",
    WARNING_LEGEND = "Not wearable on this character, but still counts toward your account-wide collection.",
    ANCHOR_RESET = "Position reset - following the Objective Tracker again.",
}
ns.L = L

local locale = GetLocale()
if locale == "esES" or locale == "esMX" then
    L.TRACK_BUTTON = "Seguir"
    L.UNTRACK_BUTTON = "Quitar"
    L.SET_COMPLETE = "Set completo!"
    L.ITEM_FALLBACK = "Item %d"
    L.HOOK_FAIL_DETAIL = "No se pudo enganchar el boton de dificultad (%s). Usa /tt track <setID> para trackear manualmente."
    L.HOOK_FAIL_LIST = "No se pudo enganchar la lista de Sets (%s). Usa /tt track <setID> para trackear manualmente."
    L.USAGE_TRACK = "Uso: /tt track <setID>"
    L.NOW_TRACKING = "Trackeando set %d"
    L.INVALID_SET = "Set %d no valido."
    L.TRACKING_STOPPED = "Seguimiento detenido."
    L.STOPPED_SET = "Set %d ya no se sigue"
    L.USAGE_GENERAL = "Uso: /tt track <setID> | /tt stop [setID] | /tt anchor"
    L.WARNING_LEGEND = "No equipable en este personaje, pero igual cuenta para tu coleccion de cuenta."
    L.ANCHOR_RESET = "Posicion reiniciada - siguiendo el tracker de misiones de nuevo."
end

function ns.Print(msg)
    print("|cff00ff00[TransmogTracker]|r " .. msg)
end

function ns.PrintError(msg)
    print("|cffff0000[TransmogTracker]|r " .. msg)
end
