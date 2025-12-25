import "Turbine"
import "Turbine.UI"
import "Turbine.UI.Lotro"
import "LFFBoard"

MainWindow = class(ResizableWindow)

function MainWindow:Constructor()
    ResizableWindow.Constructor(self)

    self.timerColor = Turbine.UI.Color(0, 1, 0);
    self.headerColor = Turbine.UI.Color(0, 0.502, 1);

    self:SetText("LFF Board")
    self:SetSize(700, 400)
    self:SetPosition(300, 200)

    self.list = Turbine.UI.ListBox()
    self.lastRefreshTime = nil -- stores last refresh time
    self.list:SetParent(self)
    self.list:SetPosition(10, 25)
    self.list:SetSize(680, 375)

    self.scroll = Turbine.UI.Lotro.ScrollBar()
    self.scroll:SetOrientation(Turbine.UI.Orientation.Vertical)
    self.scroll:SetParent(self)
    self.scroll:SetPosition(690, 25)
    self.scroll:SetSize(10, 360)

    self.list:SetVerticalScrollBar(self.scroll)

    self.optionsButton = Turbine.UI.Control();
    self.optionsButton:SetParent(self);
    self.optionsButton:SetBackground(0x4114b104); -- normal gear icon
    self.optionsButton:SetPosition(self:GetWidth() - 36, 2);
    self.optionsButton:SetSize(16, 16);
    self.optionsButton.MouseClick = function()
        self.optionsButton:SetBackground(0x41152250); -- click icon
        Turbine.PluginManager.ShowOptions(Plugins["LFFBoard"]);
    end
    self.optionsButton.MouseEnter = function()
        self.optionsButton:SetBackground(0x41152251); -- hover icon
    end
    self.optionsButton.MouseLeave = function()
        self.optionsButton:SetBackground(0x4114b104); -- normal icon
    end

    self:SetVisible(LFFBoard.settings.windowVisible)
    -- self.SetOpacity =  function(sender,opacity)
    --     ResizableWindow.SetOpacity(self,opacity);
    --     self.optionsButton:SetOpacity(opacity);
    -- end
    self:SetOpacity(LFFBoard.settings.windowOpacity / 100)

    self.Update = function()     -- Only refresh if there is at least one entry and 10s have passed since last refresh
        local hasEntries = false
        for _, _ in pairs(LFFBoard.entries) do
            hasEntries = true
            break
        end
        if hasEntries then
            local elapsed = self:GetTimeSinceLastRefresh()
            if elapsed == nil or elapsed >= 10 then
                self:Refresh()
            end
        else
            self:SetWantsUpdates(false)
        end
    end
    self.SizeChanged = function(sender, args)
        LFFBoard.settings.windowSize.width = self:GetWidth();
        LFFBoard.settings.windowSize.height = self:GetHeight();
    end

    self.SetWidth = function(sender,width)
        if width<300 then width=300 end;
        ResizableWindow.SetWidth(self, width);

        self.list:SetWidth(width - 20);
        self.scroll:SetLeft(width - 10);
        self.optionsButton:SetPosition(self:GetWidth() - 36, 2);

        for index = 1, self.list:GetItemCount() do
            local row = self.list:GetItem(index);
            row:SetWidth(self.list:GetWidth() - 20);

            if row:GetControls():GetCount() == 3 then
                local personLabel = row:GetControls():Get(1);
                local msgLabel = row:GetControls():Get(3);
                local timerLabel = row:GetControls():Get(2);

                -- Set timerLabel size/position (right-aligned)
                timerLabel:SetPosition(row:GetWidth() - timerLabel:GetWidth(), 0);
                -- Set msgLabel to fill space between personLabel and timerLabel
                msgLabel:SetWidth(row:GetWidth() - personLabel:GetWidth() - timerLabel:GetWidth() - 20)
            else
                -- For heading rows, just set full width
                row:SetWidth(self.list:GetWidth() - 20);
            end
        end
    end
    self.SetHeight = function(sender,height)
        if height<200 then height=200 end;
        ResizableWindow.SetHeight(self, height);

        self.list:SetHeight(height - 35);
        self.scroll:SetHeight(height - 40);
    end
    self.SetSize = function(sender, width, height)
        if self:GetWidth() ~= width then
            self:SetWidth(width);
        end
        if self:GetHeight() ~= height then
            self:SetHeight(height);
        end
	end

    self:SetSize(LFFBoard.settings.windowSize.width, LFFBoard.settings.windowSize.height)
    self:SetPosition(LFFBoard.settings.windowPos.left, LFFBoard.settings.windowPos.top)

    self.PositionChanged = function(sender,args)
		LFFBoard.settings.windowPos.left = self:GetLeft();
		LFFBoard.settings.windowPos.top = self:GetTop();
	end
    self.VisibleChanged = function()
		LFFBoard.settings.windowVisible = self:IsVisible();
        self:SetWantsUpdates(self:IsVisible());
	end

	self.shortcut = LFFIcon();
	self.shortcut:SetPosition(LFFBoard.settings.iconPos.left, LFFBoard.settings.iconPos.top);
    self.shortcut:SetVisible( true );
	self.shortcut.LFFIconClick = function()
		self:SetVisible( not self:IsVisible() );
	end
	self.shortcut.LFFIconMoved = function(left, top)
		LFFBoard.settings.iconPos.left = left;
		LFFBoard.settings.iconPos.top = top;
	end

end

function MainWindow:Refresh()
	for index=1, self.list:GetItemCount() do
		local item = self.list:GetItem(index);
		StripControl(item, 1);
	end
	self.list:ClearItems();
    self.lastRefreshTime = Turbine.Engine.GetGameTime()

    local hasEntries = false
    local now = Turbine.Engine.GetGameTime()

    local grouped = {}
    for sender, instances in pairs(LFFBoard.entries) do
        for instanceName, entry in pairs(instances) do
            if now - entry.time > LFFBoard.settings.staleSeconds then
                instances[instanceName] = nil
            else
                local name = entry.instance and entry.instance.name or "Unknown"
                local enabled = true
                if LFFBoard.settings.dungeons and LFFBoard.settings.dungeons[name] ~= nil then
                    enabled = LFFBoard.settings.dungeons[name].enabled ~= false
                end
                if enabled then
                    if not grouped[name] then grouped[name] = {} end
                    table.insert(grouped[name], entry)
                    hasEntries = true
                end
            end
        end
        -- Clean up empty sender tables
        if next(instances) == nil then
            LFFBoard.entries[sender] = nil
        end
    end

    -- Sort instance names alphabetically
    local instance_names = {}
    for name, _ in pairs(grouped) do table.insert(instance_names, name) end
    table.sort(instance_names)

    for _, inst_name in ipairs(instance_names) do
        -- Color for dungeon heading (blue)
        local heading = string.format("<rgb=#0080FF>%s</rgb>", inst_name)
        local headingRow = Turbine.UI.Label()
        headingRow:SetFont(Turbine.UI.Lotro.Font.Verdana18);
        headingRow:SetMarkupEnabled(true);
        headingRow:SetSize(self.list:GetWidth() - 20, 20)
        headingRow:SetText(inst_name)
        headingRow:SetForeColor(self.headerColor)
        self.list:AddItem(headingRow)

        -- Sort entries by time (most recent last)
        table.sort(grouped[inst_name], function(a, b) return a.time < b.time end)
        for _, entry in ipairs(grouped[inst_name]) do
            -- Format time: show mm:ss if >= 60s, else ss
            local elapsed = math.floor(now - entry.time)
            local timeStr
            if elapsed >= 60 then
                local min = math.floor(elapsed / 60)
                local sec = elapsed % 60
                timeStr = string.format("%dm %02ds", min, sec)
            else
                timeStr = string.format("%ds", elapsed)
            end
            -- Green for time
            --timeStr = string.format("<rgb=#00FF00>%s</rgb>", timeStr)
            local msgText = entry.message or ""

            -- Create row control
            local row = Turbine.UI.Control()
            row:SetSize(self.list:GetWidth() - 20, 20)

            -- Person label (indented)
            local personLabel = Turbine.UI.Label()
            personLabel:SetParent(row)
            personLabel:SetPosition(20, 0)
            local personText
            if entry.senderid ~= nil and entry.senderid ~= "" then
                personLabel:SetMarkupEnabled(true)
                personText = string.format('<Select:IID:%s>%s<\Select>', tostring(entry.senderid), tostring(entry.sender or "?????"))
            else
                personText = entry.sender or "?????"
            end
            personLabel:SetForeColor(self.timerColor)
            personLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14)
            personLabel:SetOutlineColor(Turbine.UI.Color(0,0,0));
            personLabel:SetFontStyle(Turbine.UI.FontStyle.Outline);
            personLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
            personLabel:SetText(personText)
            personLabel:SetSize(150, 20)

            -- Timer label (right-aligned)
            local timerLabel = Turbine.UI.Label()
            timerLabel:SetParent(row)
            timerLabel:SetSize(80, 20)
            timerLabel:SetPosition(580, 0)
            timerLabel:SetPosition(row:GetWidth() - timerLabel:GetWidth(), 0);
            timerLabel:SetText(timeStr)
            timerLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14)
            timerLabel:SetOutlineColor(Turbine.UI.Color(0,0,0));
            timerLabel:SetFontStyle(Turbine.UI.FontStyle.Outline);
            timerLabel:SetForeColor(self.timerColor)
            timerLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleRight)

            -- Message label (fills space between person and timer, grows vertically)
            local msgLabel = AutoSizingLabel()
            msgLabel:SetParent(row)
            msgLabel:SetMarkupEnabled(true)
            msgLabel:SetPosition(155, 0)
            msgLabel:SetSize(row:GetWidth() - personLabel:GetWidth() - timerLabel:GetWidth() - 20, 'auto')
            msgLabel:SetFont(Turbine.UI.Lotro.Font.Verdana14)
            msgLabel:SetOutlineColor(Turbine.UI.Color(0,0,0));
            msgLabel:SetFontStyle(Turbine.UI.FontStyle.Outline);
            msgLabel.SizeChanged = function (s,a)
                local height = msgLabel:GetHeight();
                msgLabel.SizeChanged = nil
                msgLabel:SetHeight(height)
                row:SetHeight(height + 2);
            end
            msgLabel:SetText(msgText)

            self.list:AddItem(row)
            hasEntries = true
        end
    end
    self:SetWantsUpdates(hasEntries)

end

function MainWindow:GetTimeSinceLastRefresh()
    if self.lastRefreshTime == nil then
        return nil
    end
    return Turbine.Engine.GetGameTime() - self.lastRefreshTime
end
