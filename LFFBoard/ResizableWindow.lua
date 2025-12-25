import "Turbine"
import "Turbine.UI"
import "Turbine.UI.Lotro"

ResizableWindow = class(Turbine.UI.Window)

function ResizableWindow:Constructor()

    -- bottom right resize icon 0x4100013d
    -- close icons 0x41000196, 0x41000196, 0x41000197
    -- border top left 0x4100017a
    -- possible side borders 0x4100017b, 0x4100017c, 0x4100017e, 0x41000180
    -- border bottom left 0x4100017d
    -- border bottom right 0x4100017e
    -- border top right 0x41000179
    -- minimize icon 0x41007f87
    -- maximize icon 0x41007f88
    -- gear icons 0x4114b104, 0x41152250, 0x41152251
    Turbine.UI.Window.Constructor(self)

    -- Set semi-transparent background (e.g., black with 25% opacity)
    self:SetBackColor(Turbine.UI.Color(0.25, 0, 0, 0))

    self.titleBar = Turbine.UI.Control()
    self.titleBar:SetParent(self)
    self.titleBar:SetPosition(0, 0)
    self.titleBar:SetBackColor(Turbine.UI.Color(1,0,0,0))
    self.titleBar:SetMouseVisible(true)

    -- Title label (hidden by default)
    self.titleLabel = Turbine.UI.Label()
    self.titleLabel:SetParent(self.titleBar)
    self.titleLabel:SetPosition(5, 1)
    self.titleLabel:SetSize(100, 24)
    self.titleLabel:SetForeColor(Turbine.UI.Color(1,.9,.5))
    self.titleLabel:SetFontStyle(Turbine.UI.FontStyle.Outline);
    self.titleLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft)
    self.titleLabel:SetFont(Turbine.UI.Lotro.Font.TrajanPro16)
    self.titleLabel:SetOutlineColor(Turbine.UI.Color(0,0,0));
    self.titleLabel:SetMouseVisible(false)

    -- Close icon (button) in upper right
    self.closeButton = Turbine.UI.Control()
    self.closeButton:SetParent(self)
    self.closeButton:SetSize(16, 16)
    self.closeButton:SetBackground(0x41000196)
    self.closeButton:SetMouseVisible(true)

    self.closeButton.MouseEnter = function()
        self.closeButton:SetBackground(0x41000198)
    end
    self.closeButton.MouseLeave = function()
        self.closeButton:SetBackground(0x41000196)
    end
    self.closeButton.MouseDown = function()
        self.closeButton:SetBackground(0x41000197)
    end
    self.closeButton.MouseUp = function()
        self.closeButton:SetBackground(0x41000198)
        self:SetVisible(false)
    end

    self.resizeButton = Turbine.UI.Control()
    self.resizeButton:SetParent(self)
    self.resizeButton:SetSize(16, 16)
    self.resizeButton:SetBackground(0x4100013d)
    self.resizeButton:SetMouseVisible(false)

    -- Dragging state
    self.dragging = false
    self.dragOffsetX = 0
    self.dragOffsetY = 0

    -- Drag logic for title label
    self.titleBar.MouseDown = function(sender, args)
        if self.titleBar:IsVisible() and args.Button == Turbine.UI.MouseButton.Left then
            self.dragging = true
            self.dragOffsetX = args.X
            self.dragOffsetY = args.Y
        end
    end
    self.titleBar.MouseMove = function(sender, args)
        if self.dragging then
            local newLeft = self:GetLeft() + (args.X - self.dragOffsetX)
            local newTop = self:GetTop() + (args.Y - self.dragOffsetY)
            self:SetPosition(newLeft, newTop)
        end
    end
    self.titleBar.MouseUp = function(sender, args)
        if self.dragging then
            self.dragging = false
        end
    end

    self.resizing = false;
    self.resizeX = -1;
    self.resizeY = -1;
    self.resizeCursor = Turbine.UI.Control();
    self.resizeCursor:SetParent(self);
    self.resizeCursor:SetSize(32,32);
    self.resizeCursor:SetBackground(0x410081c0)
    self.resizeCursor:SetStretchMode(2);
    self.resizeCursor:SetPosition(self:GetWidth()/2-15,self:GetHeight()-21);
    self.resizeCursor:SetVisible(false);


    self.MouseDown = function(sender,args)
        if (args.Y > self:GetHeight() - 50) and (args.X > self:GetWidth() - 50) then
            self.resizeX = args.X;
            self.resizeY = args.Y;
            self.resizeCursor:SetLeft(args.X-12);
            self.resizeCursor:SetTop(args.Y-12);
            self.resizeCursor:SetSize(32,32);
            self.resizeCursor:SetBackground(0x41007e20)
            self.resizeCursor:SetVisible(true);
        elseif (args.Y > self:GetHeight() - 12) then
            self.resizeY = args.Y;
            self.resizeCursor:SetLeft(args.X-22);
            self.resizeCursor:SetTop(args.Y-12);
            self.resizeCursor:SetSize(32,32);
            self.resizeCursor:SetBackground(0x410081c0)
            self.resizeCursor:SetVisible(true);
        elseif (args.X > self:GetWidth() - 12) then
            self.resizeX = args.X;
            self.resizeCursor:SetLeft(args.X-12);
            self.resizeCursor:SetTop(args.Y-22);
            self.resizeCursor:SetSize(32,32);
            self.resizeCursor:SetBackground(0x410081bf)
            self.resizeCursor:SetVisible(true);
        elseif (args.Y < 2) then
            self.resizeX = args.X;
            self.resizeY = args.Y;
            self.resizeCursor:SetLeft(args.X-12);
            self.resizeCursor:SetTop(args.Y-12);
            self.resizeCursor:SetSize(16,16);
            self.resizeCursor:SetBackground(0x41007e0c)
            self.resizeCursor:SetVisible(true);
        else
            self.resizeX = -1;
            self.resizeY = -1;
        end
    end

    self.MouseMove = function(sender,args)
        if (self.resizeY > -1) then
            if args.Y ~= self.resizeY then
                self.resizing = true;
                local newHeight = self:GetHeight() - (self.resizeY - args.Y);
                if newHeight < 156 then newHeight = 156 end;
                if newHeight > (Turbine.UI.Display.GetHeight() - self:GetTop()) then newHeight = Turbine.UI.Display.GetHeight() - self:GetTop() end;
                local newX = args.X - 22;
                if newX < -13 then newX = -13 end
                if newX > (self:GetWidth() - 18) then newX = self:GetWidth() - 18 end
                self.resizeCursor:SetLeft(newX);
                self.resizeCursor:SetPosition(newX, args.Y - 9);
                self:SetHeight(newHeight);
                self.resizeY = args.Y;
            end
        end
        if (self.resizeX > -1) then
            if args.X ~= self.resizeX then
                self.resizing = true;
                local newWidth = self:GetWidth() - (self.resizeX - args.X);
                if newWidth < 414 then newWidth = 414 end;
                if newWidth > (Turbine.UI.Display.GetWidth() - self:GetLeft()) then newWidth = Turbine.UI.Display.GetWidth() - self:GetLeft() end;
                local newY = args.Y - 22;
                if newY < -13 then newY = -13 end
                if newY > (self:GetHeight() - 18) then newY = self:GetHeight() - 18 end
                self.resizeCursor:SetPosition(args.X - 9, newY);
                self:SetWidth(newWidth);
                self.resizeX = args.X;
            end
        end
    end

    self.MouseUp = function(sender,args)
        self.resizeCursor:SetVisible(false);
        self.resizeX = -1;
        self.resizeY = -1;
        if self.resizing == true then
            self.resizing = false;
        end
    end

end
function ResizableWindow:SetOpacity(opacity)
    self:SetBackColor(Turbine.UI.Color(opacity, 0, 0, 0))
end

function ResizableWindow:SetWidth(width)
    Turbine.UI.Window.SetWidth(self, width);
    self.titleBar:SetSize(width, 24)
    self.closeButton:SetPosition(self:GetWidth() - 18, 2)
    self.resizeButton:SetPosition(self:GetWidth() - 18, self:GetHeight() - 18)
end
function ResizableWindow:SetHeight(height)
    Turbine.UI.Window.SetHeight(self, height);
    self.resizeButton:SetPosition(self:GetWidth() - 18, self:GetHeight() - 18)
end
function ResizableWindow:SetSize(width, height)
    Turbine.UI.Window.SetSize(self, width, height);
    self.titleBar:SetSize(width, 24)
    self.closeButton:SetPosition(width - 18, 2)
    self.resizeButton:SetPosition(self:GetWidth() - 18, self:GetHeight() - 18)
end

function ResizableWindow:SetText(text)
    if text and text ~= "" then
        -- self.titleLabel:SetVisible(true)
        self.titleLabel:SetText(text)
    else
        --self.titleLabel:SetVisible(false)
    end
end

function ResizableWindow:GetText()
    return self.titleLabel:GetText()
end


local stripVars = { 'record', 'MouseEnter', 'MouseLeave', 'Click', 'MouseClick', 'MouseHover', 'SizeChanged', 'VisibleChanged', 'Update' };
function StripControl( control, depth )
	if depth == nil then depth = 1 end;
	if depth > 5 then return end;

	if control.GetControls ~= nil then
		local conts = control:GetControls();
		for i = 1,conts:GetCount() do
			local child = conts:Get(i);
			if child.destroy ~= nil then
				child:destroy();
			else
				StripControl( child, depth + 1 );
			end
		end
		conts:Clear();
	end

	if control.GetItemCount ~= nil and control.Getitem ~= nil then
		for index=1,control:GetItemCount() do
			local item = control:GetItem(index);
			if item.destroy ~= nil then
				item:destroy();
			else
				StripControl( item, depth + 1);
			end
		end
	end

	for i,var in pairs(stripVars) do
		if control[var] ~= nil then
			control[var] = nil
		end;
	end
end