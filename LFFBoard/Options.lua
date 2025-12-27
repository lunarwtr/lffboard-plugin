
import "Turbine"
import "Turbine.UI"
import "Turbine.UI.Lotro"
import "LFFBoard"

Options = class(Turbine.UI.Control)

function Options:Constructor()
    Turbine.UI.Control.Constructor(self)
    
    local cbWidth = 230
    local abbrBoxWidth = 340
    local rowWidth = cbWidth + abbrBoxWidth + 10
    local abbrBoxLeft = cbWidth + 10
    local categoryWidth = rowWidth + 20
    local listWidth = categoryWidth + 10
    local catCBWidth = rowWidth
    local dungeonListWidth = rowWidth

    local fontColor = Turbine.UI.Color(1,.9,.5);
    local fontFace = Turbine.UI.Lotro.Font.Verdana14;
    local headerFontFace = Turbine.UI.Lotro.Font.VerdanaBold16;
    local backColor = Turbine.UI.Color(0.1, 0.1, 0.1);
    self:SetBackColor(backColor);
    self:SetWidth(listWidth);

    local y = 10

    -- Stale post seconds input (remains at top)
    local staleLabel = Turbine.UI.Label()
    staleLabel:SetParent(self)
    staleLabel:SetFont(fontFace)
    staleLabel:SetText("Seconds to keep stale posts:")
    staleLabel:SetPosition(10, y)
    staleLabel:SetSize(200, 20)

    self.staleInput = Turbine.UI.Lotro.TextBox()
    self.staleInput:SetParent(self)
    self.staleInput:SetFont(fontFace);
    self.staleInput:SetForeColor(fontColor);
    self.staleInput:SetText(tostring(LFFBoard.settings.staleSeconds or 120))
    self.staleInput:SetPosition(220, y)
    self.staleInput:SetSize(60, 20)
    self.staleInput.TextChanged = function(sender, args)
        local v = tonumber(self.staleInput:GetText())
        if v and v > 0 then
            LFFBoard.settings.staleSeconds = v
        end
    end

    y = y + 30

	local opacityCaption=Turbine.UI.Label();
	opacityCaption:SetParent(self);
	opacityCaption:SetPosition(10, y);
	opacityCaption:SetSize(50, 18);
	opacityCaption:SetFont(fontFace);
	opacityCaption:SetText("Opacity");
	local opacityScrollbar=Turbine.UI.Lotro.ScrollBar();
	opacityScrollbar:SetOrientation(Turbine.UI.Orientation.Horizontal);
	opacityScrollbar:SetParent(self)
	opacityScrollbar:SetPosition(70, opacityCaption:GetTop()+ 2);
	opacityScrollbar:SetSize(200,10);
	opacityScrollbar:SetBackColor(Turbine.UI.Color(0,0,0));
	opacityScrollbar:SetMinimum(0);
	opacityScrollbar:SetMaximum(100);
    opacityScrollbar:SetValue(LFFBoard.settings.windowOpacity);
	opacityScrollbar.ValueChanged=function()
        LFFBoard.settings.windowOpacity=opacityScrollbar:GetValue();
        LFFBoard.window:SetOpacity(LFFBoard.settings.windowOpacity / 100);
	end
    y = y + 30

    self.lff = CreateCheckbox(self, " LFF Chat Channel", fontFace, LFFBoard.settings.channels.lff, 10, y, 230, 20)
    self.lff.CheckedChanged = function(sender, args)
        LFFBoard.settings.channels.lff = self.lff:IsChecked()
    end
    y = y + 22
    self.world = CreateCheckbox(self, " World Chat Channel", fontFace, LFFBoard.settings.channels.world, 10, y, 230, 20)
    self.world.CheckedChanged = function(sender, args)
        LFFBoard.settings.channels.world = self.world:IsChecked()
    end
    y = y + 22
    self.kinship = CreateCheckbox(self, " Kinship Chat Channel", fontFace, LFFBoard.settings.channels.kinship, 10, y, 230, 20)
    self.kinship.CheckedChanged = function(sender, args)
        LFFBoard.settings.channels.kinship = self.kinship:IsChecked()
    end
    y = y + 50

    -- Main ListBox for all categories
    self.list = Turbine.UI.ListBox()
    self.list:SetParent(self)
    self.list:SetPosition(10, y)

    -- Group dungeons by category (bucketize)
    local categories = {}
    for _, entry in ipairs(LFFBoardData) do
        if not categories[entry.category] then categories[entry.category] = {} end
        table.insert(categories[entry.category], entry)
    end
    -- Sort entries within each category after bucketing
    for _, entries in pairs(categories) do
        table.sort(entries, function(a, b) return a.name < b.name end)
    end

    -- Create and sort the list of category names
    local sortedCategories = {}
    for category in pairs(categories) do
        table.insert(sortedCategories, category)
    end
    table.sort(sortedCategories)

    -- Utility: create a row with checkbox and input
    local function createDungeonRow(entry)
        local row = Turbine.UI.Control()

        local setting = LFFBoard.settings.dungeons[entry.name] or { enabled = true, abbr = entry.abbr or {} }

        local cb = Turbine.UI.Lotro.CheckBox()
        cb:SetParent(row)
        cb:SetFont(fontFace)
        cb:SetChecked(setting.enabled)
        local cbText = ' ' .. entry.name
        local cbHeight = string.len(cbText) > 30 and 30 or 20
        cb:SetText(' ' .. entry.name)
        cb:SetSize(cbWidth, cbHeight)
        cb:SetPosition(0, 2)
        row:SetHeight(cbHeight + 4)

        local abbrStr = table.concat(setting.abbr or {}, ", ")
        local abbrBox = Turbine.UI.Lotro.TextBox()
        abbrBox:SetParent(row)
        abbrBox:SetFont(fontFace);
        abbrBox:SetForeColor(fontColor);
        abbrBox:SetOutlineColor(Turbine.UI.Color(0,0,0));
        abbrBox:SetFontStyle(Turbine.UI.FontStyle.Outline);
        abbrBox:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
        abbrBox:SetSize(abbrBoxWidth, 30)
        abbrBox:SetPosition(abbrBoxLeft, 2)
        abbrBox:SetText(abbrStr)

        -- Store changes
        cb.CheckedChanged = function(sender, args)
            LFFBoard.settings.dungeons[entry.name] = LFFBoard.settings.dungeons[entry.name] or {}
            LFFBoard.settings.dungeons[entry.name].enabled = cb:IsChecked()
        end
        abbrBox.TextChanged = function(sender, args)
            LFFBoard.settings.dungeons[entry.name] = LFFBoard.settings.dungeons[entry.name] or {}
            local raw = abbrBox:GetText()
            if raw == nil or raw:match('^%s*$') then
                LFFBoard.settings.dungeons[entry.name].abbr = {}
            else
                local abbrs = {}
                for abbr in raw:gmatch('[^,]+') do
                    local trimmed = abbr:gsub('^%s+', ''):gsub('%s+$', '')
                    if trimmed ~= '' then table.insert(abbrs, trimmed) end
                end
                LFFBoard.settings.dungeons[entry.name].abbr = abbrs
            end
        end

        -- Helper to get the checkbox for parent list iteration
        row.GetCheckbox = function() return cb end
        row.GetTextBox = function() return abbrBox end
        row:SetSize(rowWidth, cbHeight + 4)

        return row
    end

    -- Utility: create a category control with header and child ListBox
    local function createCategoryControl(category, dungeons)
        local catControl = Turbine.UI.Control()
        catControl:SetSize(categoryWidth, 28)

        -- Header with category checkbox
        local header = Turbine.UI.Control()
        header:SetParent(catControl)
        header:SetPosition(0, 0)
        header:SetSize(categoryWidth, 22)

        local catCB = Turbine.UI.Lotro.CheckBox()
        catCB:SetParent(header)
        catCB:SetText(' ' .. category)
        catCB:SetFont(headerFontFace)
        catCB:SetForeColor(fontColor)
        catCB:SetFontStyle(Turbine.UI.FontStyle.Outline)
        catCB:SetSize(catCBWidth, 20)
        catCB:SetPosition(0, 0)
        catCB:SetChecked(true)

        local listHeight = 0
        -- ListBox for dungeons
        local dungeonList = Turbine.UI.ListBox()
        dungeonList:SetParent(catControl)
        dungeonList:SetPosition(10, 32)
        -- Add dungeon rows
        for _, entry in ipairs(dungeons) do
            local row = createDungeonRow(entry)
            listHeight = listHeight + row:GetHeight()
            dungeonList:AddItem(row)
        end
        dungeonList:SetSize(dungeonListWidth, listHeight + 10)
        catControl:SetHeight(32 + dungeonList:GetHeight())

        -- Toggle all dungeons in this category and update child checkboxes
        catCB.CheckedChanged = function(sender, args)
            for i = 1, dungeonList:GetItemCount() do
                local row = dungeonList:GetItem(i)
                local cb = row.GetCheckbox and row.GetCheckbox() or nil
                if cb then
                    local entry = dungeons[i]
                    LFFBoard.settings.dungeons[entry.name] = LFFBoard.settings.dungeons[entry.name] or {}
                    LFFBoard.settings.dungeons[entry.name].enabled = catCB:IsChecked()
                    cb:SetChecked(catCB:IsChecked())
                end
            end
        end
        catControl.GetCheckbox = function() return catCB end
        return catControl
    end

    -- Render all categories and dungeons, using pre-sorted sortedCategories
    local listHeight = 0
    for _, category in ipairs(sortedCategories) do
        local dungeons = categories[category]
        local catControl = createCategoryControl(category, dungeons)
        listHeight = listHeight + catControl:GetHeight()
        self.list:AddItem(catControl)
    end
    self.list:SetSize(listWidth, listHeight)

    -- Set height based on content
    y = y + 10 + listHeight

    -- add help/about button
    self.testWindow = TestWindow()
    self.testWindow:SetVisible(false);

    local debugButton = Turbine.UI.Lotro.Button()
    debugButton:SetParent(self);
    debugButton:SetText( "debug" );
    debugButton:SetPosition( 10, y );
    debugButton:SetSize( 100, 25 );
    debugButton.Click = function( sender, args )
		self.testWindow:SetVisible( true );
		self.testWindow:Activate();
    end
    -- local resetButton = Turbine.UI.Lotro.Button()
    -- resetButton:SetParent(self);
    -- resetButton:SetText( "reset" );
    -- resetButton:SetPosition( 120, y );
    -- resetButton:SetSize( 100, 25 );
    -- resetButton.Click = function( sender, args )
	-- 	LFFBoard.settings = LoadLFFBoardSettings( true );
    -- end
    y = y + 30

    self:SetHeight(y)
end

-- Utility: save settings
function SaveLFFBoardSettings(settings)
    Turbine.PluginData.Save( Turbine.DataScope.Character, "LFFBoardSettings", settings or {} )
end

-- Utility: load and default settings
-- Helper to initialize global settings
function LoadLFFBoardSettings(reset)
    local displayWidth = Turbine.UI.Display:GetWidth()
    local displayHeight = Turbine.UI.Display:GetHeight()
    local settings = nil
    if not reset then
        settings = Turbine.PluginData.Load( Turbine.DataScope.Character, "LFFBoardSettings" )
    end

    if settings == nil then
        settings = {
            windowVisible = true,
            windowOpacity = 70,
            windowPos = {
                left = tostring((displayWidth - 550) / 2),
                top = tostring((displayHeight - 200) / 2)
            },
            iconPos = {
				left = tostring(displayWidth - 55),
				top = "230",
			},
            windowSize = {
                width = 550,
                height = 200
            },
            channels = {
                lff = true,
                world = true,
                kinship = true
            },
            fadeWindow = true,
            staleSeconds = 180,
            dungeons = {},
        }
        for _, entry in ipairs(LFFBoardData) do
            settings.dungeons[entry.name] = {
                enabled = true,
                abbr = entry.abbr or {}
            }
        end
    else
        if settings.windowVisible == nil then settings.windowVisible = true end
        if settings.windowOpacity == nil then settings.windowOpacity = 70 end
        if settings.channels == nil then
            settings.channels = { 
                lff = true, world = true, kinship = true
            }
        end
        if settings.windowPos == nil then
            settings.windowPos = {
                left = tostring((displayWidth - 550) / 2),
                top = tostring((displayHeight - 200) / 2)
            }
        end
        if settings.iconPos == nil then
            settings.iconPos = {
				left = tostring(displayWidth - 55),
				top = "230",
            }
        end
        if settings.windowSize == nil then settings.windowSize = { width = 550, height = 200 } end
        if settings.fadeWindow == nil then settings.fadeWindow = true end
        if settings.staleSeconds == nil then settings.staleSeconds = 180 end
        if settings.dungeons == nil then settings.dungeons = {} end
        for _, entry in ipairs(LFFBoardData) do
            if settings.dungeons[entry.name] == nil then
                settings.dungeons[entry.name] = {
                    enabled = true,
                    abbr = entry.abbr or {}
                }
            end
        end
        if tonumber(settings.windowPos.left) > (displayWidth - 100) or tonumber(settings.windowPos.top) > (displayHeight - 100) then
            settings.windowPos = {
                left = tostring((displayWidth - settings.windowSize.width) / 2),
                top = tostring((displayHeight - settings.windowSize.height) / 2)
            }
        end
    end
    return settings
end

function CreateCheckbox(parent, text, font, checked, x, y, width, height)
    local cb = Turbine.UI.Lotro.CheckBox()
    cb:SetParent(parent)
    cb:SetText(text or "")
    if font then cb:SetFont(font) end
    if checked ~= nil then cb:SetChecked(checked) end
    if x and y then cb:SetPosition(x, y) end
    if width and height then cb:SetSize(width, height) end
    return cb
end
