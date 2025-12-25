
import "Turbine";
import "Turbine.Gameplay";
import "Turbine.UI";
import "Turbine.UI.Lotro";
import "LFFBoard";

LFFIcon = class( Turbine.UI.Window );

function LFFIcon:Constructor()
	Turbine.UI.Window.Constructor( self );

	self.icon = "lffboard.tga";
	self.iconHighlight = "lffboard-highlight.tga"

	self:SetPosition(Turbine.UI.Display.GetWidth()-75,230);
	self:SetSize(35,35);
	self:SetZOrder(110);
	self:SetVisible( true );
	self:SetBackColor( Turbine.UI.Color(0,0,0,0) );
	
	self.button = Turbine.UI.Control();
	self.button:SetParent(self);
	self.button:SetPosition(0,0);
	self.button:SetSize(35,35);
	self.button:SetBlendMode( Turbine.UI.BlendMode.AlphaBlend );
	self.button:SetBackground("LFFBoard/" .. self.icon);

	self.LFFIconClick = function() end
	self.LFFIconMoved = function(left, top) end

	self.button.MouseEnter = function(sender,args)
		self.button:SetBackground("LFFBoard/" .. self.iconHighlight);
	end
	self.button.MouseLeave = function(sender,args)
		self.button:SetBackground("LFFBoard/" .. self.icon);
	end		
	self.button.MouseDown = function( sender, args )
		if(args.Button == Turbine.UI.MouseButton.Left) then
			sender.dragStartX = args.X;
			sender.dragStartY = args.Y;
			sender.dragging = true;
			sender.dragged = false;
		end
	end
	self.button.MouseUp = function( sender, args )
		if(args.Button == Turbine.UI.MouseButton.Left) then
			if (sender.dragging) then
				sender.dragging = false;
			end
			if not sender.dragged then
				self.LFFIconClick();
			else 
				self.LFFIconMoved( self:GetLeft(), self:GetTop());
			end
		end
	end
	self.button.MouseMove = function(sender,args)
		if ( sender.dragging ) then
			local left, top = self:GetPosition();
			self:SetPosition( left + ( args.X - sender.dragStartX ), top + args.Y - sender.dragStartY );
			sender:SetPosition( 0, 0 );
			sender.dragged = true;
		end
	end
	
end
