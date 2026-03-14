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
    local sampleMessages = [=[
[LFF] Brandybuckle: '4/6 for Palace t2 need heals/support/tank'
[LFF] Crumblebeard: 'Caves T2, 1/3, dps'
[LFF] Wobbleshield: '3/6 need tank/support/debuff (cleanser preferred but ill take whatever) for palace/hold t2'
[LFF] Saddlebottom: 'LF Tank, naruhel T3 5/6 160'
[LFF] Taterfoot: '123'
[LFF] Wobbleshield: '3/6 palace + hold t2 need cleanser/tank/support''
[LFF] Grumblesnout: 'Caves T1 2/3 need tank'
[LFF] Wobbleshield: 'need tank + any for palace/hold t2'
[LFF] Puddlejumper: 'Caves T1 Need Hunter Warden Burg or Shanty 2/3 pst'
[LFF] Noodlearms: 'Hold T1 need healer and DPS 4/6 pst']=]
    self.input:SetText(sampleMessages)

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
                elseif line:find("%[To%s+" .. chatTypeName .. "%]") then
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
