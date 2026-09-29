local ADDON_NAME, ns = ...
TransmogTrackerDB = TransmogTrackerDB or {}
TransmogTrackerDB.trackedSetIDs = TransmogTrackerDB.trackedSetIDs or {}
ns.TrackerFrame = ns.TrackerFrame or {}
local TrackerFrame = ns.TrackerFrame

-- TransmogTrackerDB.trackedSetIDs is the source of truth for what is tracked.
-- TrackerFrame.statuses only holds sets whose data has loaded this session, so
-- a set the client can't resolve yet (cold transmog cache at login) stays in
-- the saved list and is retried instead of being dropped.
TrackerFrame.statuses = {}
TrackerFrame.collapsedSets = {}
TrackerFrame.sections = {}

local ROW_HEIGHT = 18
local ROW_GAP = 2
local HEADER_HEIGHT = 32
local SECTION_GAP = 8
local SIDE_PADDING = 8
local DEFAULT_WIDTH = 220

local WHITE = "Interface/Buttons/WHITE8x8"
local BAR_TEXTURE = "Interface/TargetingFrame/UI-StatusBar"
local BAR_COLOR = { 0.3, 0.6, 1.0 }
local BAR_COLOR_COMPLETE = { 0.2, 0.8, 0.3 }
local MAX_SLOT_WIDTH = 70
local UNKNOWN_ITEM_COLOR = "|cff9d9d9d"
local UNKNOWN_BORDER = { 0.4, 0.4, 0.4 }

-- Flat, frameless panel to sit next to the Objective Tracker, which has no
-- backdrop of its own.
local frame = CreateFrame("Frame", "TransmogTrackerFrame", UIParent)
frame:SetSize(DEFAULT_WIDTH, 40)
frame.bg = frame:CreateTexture(nil, "BACKGROUND")
frame.bg:SetAllPoints(frame)
frame.bg:SetColorTexture(0, 0, 0, 0.35)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:Hide()

frame.warningLegend = CreateFrame("Frame", nil, frame)
frame.warningLegend:SetHeight(16)
frame.warningLegend.icon = frame.warningLegend:CreateTexture(nil, "OVERLAY")
frame.warningLegend.icon:SetSize(14, 14)
frame.warningLegend.icon:SetPoint("LEFT", 0, 0)
frame.warningLegend.icon:SetTexture("Interface/DialogFrame/UI-Dialog-Icon-AlertNew")
frame.warningLegend.text = frame.warningLegend:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
frame.warningLegend.text:SetPoint("LEFT", frame.warningLegend.icon, "RIGHT", 4, 0)
frame.warningLegend.text:SetPoint("RIGHT", frame.warningLegend, "RIGHT", 0, 0)
frame.warningLegend.text:SetJustifyH("LEFT")
frame.warningLegend.text:SetWordWrap(true)
frame.warningLegend.text:SetText(ns.L.WARNING_LEGEND)
frame.warningLegend:Hide()

TrackerFrame.frame = frame

local function AcquireRow(section, index)
    local row = section.rows[index]
    if not row then
        -- A plain Frame (not a Button) so it doesn't swallow drags meant for
        -- the tracker.
        row = CreateFrame("Frame", nil, section)
        row:SetHeight(ROW_HEIGHT)

        -- Quality-colored 1px border: a slightly larger solid square behind
        -- the icon.
        row.iconBorder = row:CreateTexture(nil, "BACKGROUND")
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(16, 16)
        row.icon:SetPoint("LEFT", 1, 0)
        row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        row.iconBorder:SetTexture(WHITE)
        row.iconBorder:SetPoint("TOPLEFT", row.icon, "TOPLEFT", -1, 1)
        row.iconBorder:SetPoint("BOTTOMRIGHT", row.icon, "BOTTOMRIGHT", 1, -1)

        row.warning = row:CreateTexture(nil, "OVERLAY")
        row.warning:SetSize(14, 14)
        row.warning:SetPoint("LEFT", row.icon, "RIGHT", 3, 0)
        row.warning:SetTexture("Interface/DialogFrame/UI-Dialog-Icon-AlertNew")

        -- The slot is the thing you actually want to know is missing, so it
        -- gets the bigger, brighter font; the item name is secondary.
        row.slot = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.slot:SetJustifyH("LEFT")
        row.slot:SetWordWrap(false)

        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.text:SetPoint("LEFT", row.warning, "RIGHT", 4, 0)
        row.text:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        row.text:SetJustifyH("LEFT")
        row.text:SetWordWrap(false)

        section.rows[index] = row
    end
    return row
end

local function AcquireSection(index)
    local section = TrackerFrame.sections[index]
    if section then
        return section
    end

    section = CreateFrame("Frame", nil, frame)
    section.rows = {}

    -- The whole header toggles collapse. It's a Button, so it must forward
    -- drags to the tracker frame or dragging by the header would do nothing.
    section.header = CreateFrame("Button", nil, section)
    section.header:SetPoint("TOPLEFT", section, "TOPLEFT", 0, 0)
    section.header:SetPoint("TOPRIGHT", section, "TOPRIGHT", 0, 0)
    section.header:SetHeight(HEADER_HEIGHT)
    section.header:RegisterForDrag("LeftButton")
    section.header:SetScript("OnDragStart", function()
        frame:GetScript("OnDragStart")(frame)
    end)
    section.header:SetScript("OnDragStop", function()
        frame:GetScript("OnDragStop")(frame)
    end)
    section.header:SetScript("OnClick", function()
        local setID = section.setID
        TrackerFrame.collapsedSets[setID] = not TrackerFrame.collapsedSets[setID] or nil
        TrackerFrame:Render()
    end)

    section.toggleIcon = section.header:CreateTexture(nil, "OVERLAY")
    section.toggleIcon:SetSize(10, 10)
    section.toggleIcon:SetPoint("TOPLEFT", SIDE_PADDING - 2, -5)

    -- Only visible while the section is hovered, to keep the header quiet.
    section.closeButton = CreateFrame("Button", nil, section)
    section.closeButton:SetSize(16, 16)
    section.closeButton:SetPoint("TOPRIGHT", -4, -2)
    -- The header is a sibling Button spanning the same area; without an
    -- explicit higher level it can win the click and just collapse the set.
    section.closeButton:SetFrameLevel(section.header:GetFrameLevel() + 2)
    section.closeButton.label = section.closeButton:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    section.closeButton.label:SetPoint("CENTER", 0, 1)
    section.closeButton.label:SetText("\195\151") -- U+00D7 multiplication sign
    section.closeButton.label:SetTextColor(0.7, 0.7, 0.7)
    section.closeButton:SetAlpha(0)
    section.closeButton:SetScript("OnClick", function()
        TrackerFrame:RemoveSet(section.setID)
    end)
    section.header:SetScript("OnEnter", function()
        section.closeButton:SetAlpha(1)
    end)
    section.header:SetScript("OnLeave", function()
        if not section.closeButton:IsMouseOver() then
            section.closeButton:SetAlpha(0)
        end
    end)
    section.closeButton:SetScript("OnEnter", function(self)
        self:SetAlpha(1)
        self.label:SetTextColor(1, 1, 1)
    end)
    section.closeButton:SetScript("OnLeave", function(self)
        self.label:SetTextColor(0.7, 0.7, 0.7)
        if not section.header:IsMouseOver() then
            self:SetAlpha(0)
        end
    end)

    section.count = section:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    section.count:SetPoint("TOPRIGHT", section, "TOPRIGHT", -22, -6)
    section.count:SetJustifyH("RIGHT")

    -- Both title anchors are TOP-based (count's top sits 2px below the
    -- title's) so the vertical position isn't over-constrained.
    section.title = section:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    section.title:SetPoint("TOPLEFT", section, "TOPLEFT", SIDE_PADDING + 12, -4)
    section.title:SetPoint("TOPRIGHT", section.count, "TOPLEFT", -6, 2)
    section.title:SetJustifyH("LEFT")
    section.title:SetWordWrap(false)

    section.bar = CreateFrame("StatusBar", nil, section)
    section.bar:SetStatusBarTexture(BAR_TEXTURE)
    section.bar:SetMinMaxValues(0, 100)
    section.bar:SetHeight(4)
    section.bar:SetPoint("TOPLEFT", section, "TOPLEFT", SIDE_PADDING, -22)
    section.bar:SetPoint("TOPRIGHT", section, "TOPRIGHT", -SIDE_PADDING, -22)
    section.bar.bg = section.bar:CreateTexture(nil, "BACKGROUND")
    section.bar.bg:SetAllPoints(section.bar)
    section.bar.bg:SetColorTexture(1, 1, 1, 0.12)

    TrackerFrame.sections[index] = section
    return section
end

-- Fills one section and returns its height and whether any piece is unusable.
local function LayoutSection(section, status)
    local collapsed = TrackerFrame.collapsedSets[status.setID]
    section.setID = status.setID
    section.title:SetText(status.name)
    section.toggleIcon:SetTexture(collapsed
        and "Interface/Buttons/UI-PlusButton-Up"
        or "Interface/Buttons/UI-MinusButton-Up")

    local complete = #status.missing == 0
    if complete then
        section.count:SetText("|cff00ff00" .. ns.L.SET_COMPLETE .. "|r")
    else
        section.count:SetText(string.format("%d/%d", #status.collected, #status.collected + #status.missing))
    end
    section.bar:SetValue(status.percent)
    local barColor = complete and BAR_COLOR_COMPLETE or BAR_COLOR
    section.bar:SetStatusBarColor(barColor[1], barColor[2], barColor[3])

    local hasWarning = false
    local visibleRows = 0
    local widestSlot = 0
    if not collapsed then
        for i, piece in ipairs(status.missing) do
            visibleRows = i
            local row = AcquireRow(section, i)
            local itemName, _, quality, _, _, _, _, _, _, itemIcon = GetItemInfo(piece.itemID)
            row.icon:SetTexture(itemIcon or 134400) -- 134400 = default question-mark icon

            -- Until item data arrives, name and border stay grey; the
            -- GET_ITEM_INFO_RECEIVED watcher re-renders once it does.
            local qualityColor = itemName and quality and ITEM_QUALITY_COLORS[quality]
            local nameColor = UNKNOWN_ITEM_COLOR
            local border = UNKNOWN_BORDER
            if qualityColor then
                nameColor = string.format("|cff%02x%02x%02x",
                    qualityColor.r * 255, qualityColor.g * 255, qualityColor.b * 255)
                border = { qualityColor.r, qualityColor.g, qualityColor.b }
            end
            row.iconBorder:SetVertexColor(border[1], border[2], border[3])

            row.slot:SetWidth(0) -- back to auto width so the measurement below is the natural one
            row.slot:SetText(piece.slotName or "")
            row.text:SetText(nameColor .. (itemName or string.format(ns.L.ITEM_FALLBACK, piece.itemID)) .. "|r")
            widestSlot = math.max(widestSlot, row.slot:GetStringWidth())

            -- The warning icon sits at the right edge so the slot and name
            -- columns stay aligned whether or not a row has one.
            row.warning:SetShown(not piece.usableByPlayer)
            row.warning:ClearAllPoints()
            row.warning:SetPoint("RIGHT", row, "RIGHT", 0, 0)
            row.text:ClearAllPoints()
            row.text:SetPoint("RIGHT", piece.usableByPlayer and row or row.warning,
                piece.usableByPlayer and "RIGHT" or "LEFT", piece.usableByPlayer and 0 or -3, 0)
            if not piece.usableByPlayer then
                hasWarning = true
            end

            local offset = -(HEADER_HEIGHT + (i - 1) * (ROW_HEIGHT + ROW_GAP))
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", section, "TOPLEFT", SIDE_PADDING, offset)
            row:SetPoint("TOPRIGHT", section, "TOPRIGHT", -SIDE_PADDING, offset)
            row:Show()
        end

        -- Second pass: every row in the section shares one slot column, sized
        -- to the widest slot name (capped so long ones truncate).
        local slotWidth = math.min(math.ceil(widestSlot), MAX_SLOT_WIDTH)
        for i = 1, visibleRows do
            local row = section.rows[i]
            row.slot:SetWidth(slotWidth)
            row.slot:ClearAllPoints()
            row.slot:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
            row.text:SetPoint("LEFT", row.slot, "RIGHT", 6, 0)
        end
    end

    for i = visibleRows + 1, #section.rows do
        section.rows[i]:Hide()
    end

    local height = HEADER_HEIGHT
    if visibleRows > 0 then
        height = height + visibleRows * (ROW_HEIGHT + ROW_GAP)
    end
    return height, hasWarning
end

function TrackerFrame:Render()
    local y = -SECTION_GAP
    local shown = 0
    local hasWarning = false

    for _, setID in ipairs(TransmogTrackerDB.trackedSetIDs) do
        local status = self.statuses[setID]
        if status then
            shown = shown + 1
            local section = AcquireSection(shown)
            local height, sectionWarning = LayoutSection(section, status)
            section:ClearAllPoints()
            section:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, y)
            section:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, y)
            section:SetHeight(height)
            section:Show()
            y = y - height - SECTION_GAP
            hasWarning = hasWarning or sectionWarning
        end
    end

    for i = shown + 1, #self.sections do
        self.sections[i]:Hide()
    end

    if shown == 0 then
        frame:Hide()
        return
    end

    local legendHeight = 0
    frame.warningLegend:ClearAllPoints()
    frame.warningLegend:SetPoint("TOPLEFT", frame, "TOPLEFT", SIDE_PADDING, y)
    frame.warningLegend:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -SIDE_PADDING, y)
    frame.warningLegend:SetShown(hasWarning)
    if hasWarning then
        local textHeight = math.max(16, frame.warningLegend.text:GetStringHeight())
        frame.warningLegend:SetHeight(textHeight)
        legendHeight = textHeight + SECTION_GAP
    end

    -- y already includes the gap after the last section, which doubles as the
    -- bottom padding.
    frame:SetHeight(-y + legendHeight)

    if not frame:IsShown() then
        frame:Show()
        self:AnchorToObjectiveTracker()
    end
end

local function NotifyChanged()
    if TrackerFrame.onChanged then
        TrackerFrame.onChanged()
    end
end

function TrackerFrame:IsTracked(setID)
    for _, id in ipairs(TransmogTrackerDB.trackedSetIDs) do
        if id == setID then
            return true
        end
    end
    return false
end

-- Returns false when the set can't be resolved (invalid ID or data not ready).
function TrackerFrame:AddSet(setID)
    local status = ns.SetData:BuildSetStatus(setID)
    if not status then
        return false
    end
    if not self:IsTracked(setID) then
        table.insert(TransmogTrackerDB.trackedSetIDs, setID)
    end
    self.statuses[setID] = status
    self:Render()
    NotifyChanged()
    return true
end

function TrackerFrame:RemoveSet(setID)
    local ids = TransmogTrackerDB.trackedSetIDs
    for i = #ids, 1, -1 do
        if ids[i] == setID then
            table.remove(ids, i)
        end
    end
    self.statuses[setID] = nil
    self.collapsedSets[setID] = nil
    self:Render()
    NotifyChanged()
end

function TrackerFrame:StopAll()
    wipe(TransmogTrackerDB.trackedSetIDs)
    wipe(self.statuses)
    wipe(self.collapsedSets)
    self:Render()
    NotifyChanged()
end

-- Recomputes every saved set. A set whose data isn't available yet keeps its
-- last known status (or stays unloaded) - it is never removed from the saved
-- list here, only an explicit RemoveSet/StopAll does that.
-- Returns two values: whether every saved set has a loaded status, and whether
-- any missing piece is flagged unusable. Right after login the client can
-- report isValidSourceForPlayer=false for pieces that are in fact wearable
-- until transmog data settles, so callers retry while that flag is set.
function TrackerFrame:Refresh()
    local allLoaded = true
    local hasUnusable = false
    for _, setID in ipairs(TransmogTrackerDB.trackedSetIDs) do
        local status = ns.SetData:BuildSetStatus(setID)
        if status then
            self.statuses[setID] = status
        elseif not self.statuses[setID] then
            allLoaded = false
        end
        local current = self.statuses[setID]
        if current then
            for _, piece in ipairs(current.missing) do
                if not piece.usableByPlayer then
                    hasUnusable = true
                end
            end
        end
    end
    self:Render()
    NotifyChanged()
    return allLoaded, hasUnusable
end

function TrackerFrame:AnchorToObjectiveTracker()
    frame:ClearAllPoints()

    -- A manual drag opts the frame out of auto-anchoring, otherwise the
    -- 0.2s watcher below immediately snaps it back to the Objective
    -- Tracker (which is shown in nearly all normal gameplay) and the
    -- dragged position never has any visible effect. /tt anchor clears it.
    if not TransmogTrackerDB.manualPosition and ObjectiveTrackerFrame and ObjectiveTrackerFrame:IsShown() then
        frame:SetPoint("TOPRIGHT", ObjectiveTrackerFrame, "BOTTOMRIGHT", 0, -10)
        frame:SetWidth(ObjectiveTrackerFrame:GetWidth())
    elseif TransmogTrackerDB.framePosition then
        local p = TransmogTrackerDB.framePosition
        frame:SetPoint(p.point, UIParent, p.relativePoint, p.x, p.y)
        frame:SetWidth(DEFAULT_WIDTH)
    else
        frame:SetPoint("CENTER", UIParent, "CENTER", 300, 0)
        frame:SetWidth(DEFAULT_WIDTH)
    end
end

function TrackerFrame:ResetAnchor()
    TransmogTrackerDB.manualPosition = nil
    TransmogTrackerDB.framePosition = nil
    self:AnchorToObjectiveTracker()
end

local anchorThrottle = 0
local anchorWatcher = CreateFrame("Frame")
anchorWatcher:SetScript("OnUpdate", function(self, elapsed)
    anchorThrottle = anchorThrottle + elapsed
    if anchorThrottle < 0.2 then
        return
    end
    anchorThrottle = 0
    -- Re-anchoring mid-drag would yank the frame out of the user's hand.
    if frame:IsShown() and not frame.isMoving then
        TrackerFrame:AnchorToObjectiveTracker()
    end
end)

frame:SetScript("OnDragStart", function(self)
    self.isMoving = true
    self:StartMoving()
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    self.isMoving = false
    local point, _, relativePoint, x, y = self:GetPoint()
    TransmogTrackerDB.framePosition = { point = point, relativePoint = relativePoint, x = x, y = y }
    TransmogTrackerDB.manualPosition = true
    self:SetWidth(DEFAULT_WIDTH)
end)

-- GetItemInfo can miss on first call for items not yet cached client-side,
-- leaving a row stuck on its "Item %d" fallback until something else
-- triggers a Render. Re-render once the server delivers the data.
local itemInfoWatcher = CreateFrame("Frame")
itemInfoWatcher:RegisterEvent("GET_ITEM_INFO_RECEIVED")
itemInfoWatcher:SetScript("OnEvent", function(self, event, itemID, success)
    if not success then
        return
    end
    for _, status in pairs(TrackerFrame.statuses) do
        for _, piece in ipairs(status.missing) do
            if piece.itemID == itemID then
                TrackerFrame:Render()
                return
            end
        end
    end
end)
