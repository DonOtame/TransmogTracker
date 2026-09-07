local ADDON_NAME, ns = ...
ns.TrackerFrame = ns.TrackerFrame or {}
local TrackerFrame = ns.TrackerFrame

local frame = CreateFrame("Frame", "TransmogTrackerFrame", UIParent, "BackdropTemplate")
frame:SetSize(220, 40)
frame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
frame:SetBackdropColor(0, 0, 0, 0.7)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:Hide()

frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.title:SetPoint("TOPLEFT", 10, -8)
frame.title:SetText("")

frame.progress = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
frame.progress:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -4)
frame.progress:SetText("")

frame.rows = {}
frame.rowsContainer = CreateFrame("Frame", nil, frame)
frame.rowsContainer:SetPoint("TOPLEFT", frame.progress, "BOTTOMLEFT", 0, -8)
frame.rowsContainer:SetPoint("RIGHT", frame, "RIGHT", -10, 0)

frame.stopButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
frame.stopButton:SetSize(140, 20)
frame.stopButton:SetText("Detener seguimiento")
frame.stopButton:SetScript("OnClick", function() TrackerFrame:StopTracking() end)

TrackerFrame.frame = frame

local ROW_HEIGHT = 20

local function AcquireRow(index)
    local frame = TrackerFrame.frame
    local row = frame.rows[index]
    if not row then
        row = CreateFrame("Button", nil, frame.rowsContainer)
        row:SetHeight(ROW_HEIGHT)
        row:SetPoint("LEFT", frame.rowsContainer, "LEFT", 0, 0)
        row:SetPoint("RIGHT", frame.rowsContainer, "RIGHT", 0, 0)

        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(16, 16)
        row.icon:SetPoint("LEFT", 0, 0)

        row.warning = row:CreateTexture(nil, "OVERLAY")
        row.warning:SetSize(14, 14)
        row.warning:SetPoint("LEFT", row.icon, "RIGHT", 2, 0)
        row.warning:SetTexture("Interface/DialogFrame/UI-Dialog-Icon-AlertNew")

        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.text:SetPoint("LEFT", row.warning, "RIGHT", 4, 0)
        row.text:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        row.text:SetJustifyH("LEFT")

        row:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetItemByID(self.itemID)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", GameTooltip_Hide)

        frame.rows[index] = row
    end
    return row
end

function TrackerFrame:Populate(status)
    local frame = self.frame
    frame.title:SetText(status.name)

    if #status.missing == 0 then
        frame.progress:SetText("|cff00ff00Set completo!|r")
    else
        frame.progress:SetText(string.format("%d/%d piezas (%d%%)",
            #status.collected, #status.collected + #status.missing, status.percent))
    end

    local previousRow
    for i, piece in ipairs(status.missing) do
        local row = AcquireRow(i)
        row.itemID = piece.itemID
        local itemName, _, _, _, _, _, _, _, _, itemIcon = GetItemInfo(piece.itemID)
        row.icon:SetTexture(itemIcon or 134400) -- 134400 = default question-mark icon
        row.text:SetText(itemName or ("Item " .. piece.itemID))
        row.warning:SetShown(not piece.usableByPlayer)

        if previousRow then
            row:SetPoint("TOP", previousRow, "BOTTOM", 0, -2)
        else
            row:SetPoint("TOP", frame.rowsContainer, "TOP", 0, 0)
        end
        row:Show()
        previousRow = row
    end

    for i = #status.missing + 1, #frame.rows do
        frame.rows[i]:Hide()
    end

    local visibleRows = math.max(#status.missing, 1)
    frame.stopButton:ClearAllPoints()
    frame.stopButton:SetPoint("TOP", frame.rowsContainer, "TOP", 0, -(visibleRows * (ROW_HEIGHT + 2)) - 6)
    frame:SetHeight(60 + visibleRows * (ROW_HEIGHT + 2) + 26)
end

function TrackerFrame:SetTrackedSet(setID)
    local status = ns.SetData:BuildSetStatus(setID)
    if not status then
        return false
    end
    self.trackedSetID = setID
    TransmogTrackerDB.trackedSetID = setID
    self:Populate(status)
    self.frame:Show()
    self:AnchorToObjectiveTracker()
    return true
end

function TrackerFrame:Refresh()
    if not self.trackedSetID then
        return
    end
    local status = ns.SetData:BuildSetStatus(self.trackedSetID)
    if not status then
        self:StopTracking()
        return
    end
    self:Populate(status)
end

function TrackerFrame:StopTracking()
    self.trackedSetID = nil
    TransmogTrackerDB.trackedSetID = nil
    self.frame:Hide()
end

function TrackerFrame:AnchorToObjectiveTracker()
    local frame = self.frame
    frame:ClearAllPoints()

    if ObjectiveTrackerFrame and ObjectiveTrackerFrame:IsShown() then
        frame:SetPoint("TOPRIGHT", ObjectiveTrackerFrame, "BOTTOMRIGHT", 0, -10)
        frame:SetWidth(ObjectiveTrackerFrame:GetWidth())
    elseif TransmogTrackerDB.framePosition then
        local p = TransmogTrackerDB.framePosition
        frame:SetPoint(p.point, UIParent, p.relativePoint, p.x, p.y)
    else
        frame:SetPoint("CENTER", UIParent, "CENTER", 300, 0)
    end
end

local anchorThrottle = 0
local anchorWatcher = CreateFrame("Frame")
anchorWatcher:SetScript("OnUpdate", function(self, elapsed)
    anchorThrottle = anchorThrottle + elapsed
    if anchorThrottle < 0.2 then
        return
    end
    anchorThrottle = 0
    if TrackerFrame.frame:IsShown() then
        TrackerFrame:AnchorToObjectiveTracker()
    end
end)

TrackerFrame.frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relativePoint, x, y = self:GetPoint()
    TransmogTrackerDB.framePosition = { point = point, relativePoint = relativePoint, x = x, y = y }
end)
