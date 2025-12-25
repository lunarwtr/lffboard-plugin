import "Turbine.UI"
import "Turbine.UI.Lotro"
import "LFFBoard"

LFFBoard = {
    settings = LoadLFFBoardSettings(),
    entries = {}
}
LFFBoard.window = MainWindow()
LFFBoard.options = Options()
LFFBoard.window:SetVisible(LFFBoard.settings.windowVisible);

Turbine.Shell.WriteLine("<rgb=#008080>LFFBoard</rgb> " .. Plugins.LFFBoard:GetVersion() .. " by <rgb=#FF80FF>Lunarwater</rgb>");

LFFBoardCommand = Turbine.ShellCommand();

function LFFBoardCommand:Execute( command, arg )
	if arg == 'hide' then
		LFFBoard.window:SetVisible(false);
	elseif arg == 'show' or arg == nil or arg == '' then
		LFFBoard.window:SetVisible(true);
    elseif arg == 'config' then
        Turbine.PluginManager.ShowOptions(Plugins["LFFBoard"]);
    else
        Turbine.Shell.WriteLine(self:GetHelp());
    end
end

function LFFBoardCommand:GetHelp()
    return "LFFBoard " .. Plugins.LFFBoard:GetVersion() .. " by Lunarwater\n" ..
            "    /lffboard config : configure LFFBoard \n" ..
            "    /lffboard show : shows LFFBoard \n" ..
            "    /lffboard hide : hides LFFBoard \n"
end

function LFFBoardCommand:GetShortHelp()
    return "LFFBoard (/lffboard)";
end

Turbine.Shell.AddCommand( "lffboard", LFFBoardCommand );
listCommandsCommand = Turbine.ShellCommand();


function LFFBoard.UpdateEntry(instance, sender, senderid, message)
    if not LFFBoard.entries[sender] then
        LFFBoard.entries[sender] = {}
    end
    LFFBoard.entries[sender][instance.name] = {
        instance = instance,
        sender = sender,
        senderid = senderid,
        message = message,
        time = Turbine.Engine.GetGameTime()
    }
    LFFBoard.window:Refresh()
end

-- Remove all entries for a sender
function LFFBoard.RemoveEntriesForSender(sender)
    LFFBoard.entries[sender] = nil
    LFFBoard.window:Refresh()
end

Plugins.LFFBoard.GetOptionsPanel = function(self)
    return LFFBoard.options
end

if Plugins.LFFBoard.Unload == nil then
    Plugins.LFFBoard.Unload = function()
        SaveLFFBoardSettings(LFFBoard.settings);
    end
end

local chatTypeToSetting = {
    [Turbine.ChatType.LFF] = "lff",
    [Turbine.ChatType.World] = "world",
    [Turbine.ChatType.Kinship] = "kinship"
}
Turbine.Chat.Received = function(sender, args)
    local settingKey = chatTypeToSetting[args.ChatType]
    if not settingKey or not LFFBoard.settings.channels[settingKey] then
        return
    end

    -- Turbine.Shell.WriteLine("CHAT:"..obj2string(args):gsub("<", "lt;"):gsub(">", "gt;"))

    -- New format: [World] <Select:IID:0x0000000000000000000>Name<\Select>: 'message'
    local channel, id, from, message = args.Message:match("^%[(.-)%]%s+<Select:IID:([^>]+)>(.-)<\\Select>:%s+'(.*)'%s*$")
    -- Secondary pattern: [LFF] Name: 'message'
    if not channel then
        channel, from, message = args.Message:match("^%[(.-)%]%s+([^:]+):%s+'(.*)'%s*$")
    end
    if not message then
        return
    end

    -- Remove all entries for sender if they say 'full' (case-insensitive)
    if string.find(message:lower(), "%f[%w]full%f[%W]") then
        LFFBoard.RemoveEntriesForSender(from)
        return
    end

    local entries = Parser.categorize_message(message, LFFBoardData, LFFBoard.settings.dungeons or {})
    if channel and entries then
        for _, entry in ipairs(entries) do
            LFFBoard.UpdateEntry(entry, from, id, message)
        end
    end
end
