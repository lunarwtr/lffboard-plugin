
---@class LFFBoardGlobal
---@field settings LFFBoardSettings
---@field entries table<string, table<string, LFFBoardEntry>>  -- sender -> instance name -> entry data
---@field window MainWindow
---@field options Options
---@field abbrevMap table<string, LFFBoardDungeon[]>
---@field UpdateEntry fun(instance: LFFBoardDungeon, sender: string, senderid: string, message: string)
---@field RemoveEntriesForSender fun(sender: string)

---@class LFFBoardEntry
---@field instance LFFBoardDungeon
---@field sender string
---@field senderid string
---@field message string
---@field time number

---@class LFFBoardPosition
---@field left string
---@field top string

---@class LFFBoardWindowSize
---@field width integer
---@field height integer

---@class LFFBoardChannels
---@field lff boolean
---@field world boolean
---@field kinship boolean

---@class LFFBoardDungeonSetting
---@field enabled boolean
---@field abbr string[]|nil

---@class LFFBoardSettings
---@field windowVisible boolean
---@field windowOpacity integer
---@field windowPos LFFBoardPosition
---@field iconPos LFFBoardPosition
---@field windowSize LFFBoardWindowSize
---@field channels LFFBoardChannels
---@field fadeWindow boolean
---@field staleSeconds integer
---@field dungeons table<string, LFFBoardDungeonSetting>

---@class LFFBoardDungeon
---@field category string
---@field name string
---@field abbr string[]
---@field region string
---@field level_lower integer
---@field level_upper integer|nil
---@field tiers integer|nil
---@field group string[]
