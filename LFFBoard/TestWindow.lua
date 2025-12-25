import "Turbine"
import "Turbine.Gameplay"
import "Turbine.UI"
import "Turbine.UI.Lotro"
import "LFFBoard"


-- Utility: convert an object to a safe string representation
obj2string = function (o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. obj2string(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

TestWindow = class(Turbine.UI.Lotro.Window)

function TestWindow:Constructor()
    Turbine.UI.Lotro.Window.Constructor(self)

    self:SetText("LFF Board Test Chat Parser")
    self:SetSize(600, 350)
    self:SetPosition(350, 250)
    self:SetVisible(true)

    self.input = Turbine.UI.Lotro.TextBox()
    self.input:SetParent(self)
    self.input:SetMultiline(true)
    self.input:SetSize(580, 250)
    self.input:SetPosition(10, 40)
    self.input:SetText("[LFF] Alice: 'LFG HC / RT'")

    self.parseButton = Turbine.UI.Lotro.Button()
    self.parseButton:SetParent(self)
    self.parseButton:SetText("Parse")
    self.parseButton:SetSize(100, 30)
    self.parseButton:SetPosition(10, 300)


    local player = Turbine.Gameplay.LocalPlayer.GetInstance();
    local playerName = player:GetName();

    self.parseButton.Click = function()
        local text = self.input:GetText()
        local results = {}
        for line in string.gmatch(text, "[^\r\n]+") do
            local args = { Message = line, ChatType = Turbine.ChatType.Undef }
            -- Determine ChatType
            for chatTypeName, chatType in pairs(Turbine.ChatType) do
                if line:find("%[" .. chatTypeName .. "%]") then
                    args.ChatType = chatType
                    break;
                end
            end

            if Turbine.Chat.Received then 
                Turbine.Chat.Received(playerName, args)
            end
        end
    end
end
