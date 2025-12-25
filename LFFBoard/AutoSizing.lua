

import "Turbine.UI";
import "Turbine.UI.Lotro";
import "LFFBoard";

AutoSizingLabel = class( Turbine.UI.Label );
function AutoSizingLabel:Constructor()
    Turbine.UI.Label.Constructor( self );

    local vert =Turbine.UI.Lotro.ScrollBar();
    vert:SetOrientation(Turbine.UI.Orientation.Vertical);
    vert:SetBackColor(Turbine.UI.Color(0,0,0));
    vert:SetPosition(0,0);
    vert:SetSize(1,1);
    vert:SetParent(self);
    vert.VisibleChanged = function(s,a)
		if s:IsVisible() then self:SetHeight('auto') end
	end 
    
    local hor =Turbine.UI.Lotro.ScrollBar();
    hor:SetOrientation(Turbine.UI.Orientation.Horizontal);
    hor:SetBackColor(Turbine.UI.Color(0,0,0));
    hor:SetPosition(0,0);
    hor:SetSize(1,1);
    hor:SetParent(self);
	hor.VisibleChanged = function(s,a)
		if s:IsVisible() then self:SetWidth('auto') end
	end   
	
	self.bars = { vert = vert, hor = hor };
	self:SetSize(2,2, true);
	self:SetWantsUpdates(false);
	self.Update = function()
		if self.bars ~= nil and not self.issizing then 
			self:SetSize(self.width, self.height);
		end
	end
	--self:SetSize('auto','auto');
	self.issizing = false;
	
end

function AutoSizingLabel:SetText( text )
	Turbine.UI.Label.SetText(self, text);
	self:SetSize(self.width, self.height);
end

function AutoSizingLabel:SetSize(w,h, noss)
	Turbine.UI.Label.SetSize(self,2,2);
	self:SetWantsUpdates(false);
	self.issizing = true;
	self:SetWidth(w, true);
	self:SetHeight(h, true);
	self.issizing = false;
	if not noss and self.SizeChanged ~= nil then self:SizeChanged(); end
end

function AutoSizingLabel:SetWidth(w, fromss)
	self:SetWantsUpdates(false);
	self:SetHorizontalScrollBar(nil);
	self.width = w;
	if w == 'auto' then
		self:SetHorizontalScrollBar(self.bars.hor);
		if  self.bars.hor:IsVisible() then
			local count = 1; 
			while self.bars.hor:IsVisible() do
				Turbine.UI.Label.SetWidth(self,self:GetWidth() + 2);
				count = count + 1;
			end
		else
			self:SetWantsUpdates(true);
		end			
	else
	 	Turbine.UI.Label.SetWidth(self,w);
	end
	if not fromss and self.SizeChanged ~= nil then self:SizeChanged(); end
end

function AutoSizingLabel:SetHeight(h, fromss)
	self:SetWantsUpdates(false);
	self:SetVerticalScrollBar(nil);
	self.height = h;
	if h == 'auto' then
		self:SetVerticalScrollBar(self.bars.vert);
		if self.bars.vert:IsVisible() then 
			local count = 1;
			--Turbine.UI.Label.SetHeight(self,1);
			while self.bars.vert:IsVisible() and count < 100 do
				Turbine.UI.Label.SetHeight(self,self:GetHeight() + 2);
				count = count + 1;
			end
		else
			self:SetWantsUpdates(true);
		end
	else
	 	Turbine.UI.Label.SetHeight(self,h);
	end
	if not fromss and self.SizeChanged ~= nil then self:SizeChanged(); end
end
