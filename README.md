
# LFFBoard Plugin

LFFBoard is a Lord of the Rings Online (LOTRO) plugin that helps players summarize and organize group-finding (LFF), World, and Kinship chat posts into a single, easy-to-read board. It automatically categorizes instance and raid requests, making it simple to see which content is being advertised and by whom.

## Features

- **Aggregates LFF, World, and Kinship chat:** Collects group-finding messages from multiple chat channels and displays them in a unified window.
- **Automatic categorization:** Uses a comprehensive, configurable list of instances and raids (with abbreviations) to categorize posts by dungeon/raid name.
- **Customizable display:**
	- Resize and reposition the main window to fit your preferences.
	- Show/hide the window or configure it via the `/lffboard` command.
	- Filter which chat channels are monitored (LFF, World, Kinship).
	- Enable/disable specific dungeons or raids, and customize abbreviations for matching.
	- Adjust window opacity and stale post timeout.
- **Live updating:** Entries automatically expire after a configurable time, and the board refreshes to show only current posts.
- **Clickable names:** Player names are clickable/selectable when available.
- **Category grouping:** Instances and raids are grouped by category for easy browsing.
- **Quick access icon:** Movable shortcut icon for fast window toggling.

## Configuration

Open the options panel via `/lffboard config` or by clicking the gear icon in the main window. Options include:

- **Stale post timeout:** Set how long (in seconds) posts remain visible.
- **Window opacity:** Adjust transparency of the board.
- **Channel selection:** Choose which chat channels to monitor.
- **Dungeon/raid filters:** Enable/disable specific content and edit abbreviations for better matching.
- **Window size and position:** Drag to resize or move the window; settings are saved automatically.

## Usage

- Use `/lffboard show` or `/lffboard hide` to toggle the board.
- Posts containing instance/raid names or abbreviations are automatically detected and categorized.
- When a player posts "full" in chat, their entries are removed from the board.

## Data

The plugin includes a large, categorized list of LOTRO instances and raids, with support for custom abbreviations and group sizes. Data is loaded from the plugin and can be extended or customized.


## Contributing

- If you notice instances missing, or new abbreviations that you've had to add or change, please consider contributing them back to help keep the plugin up to date for everyone.
- If you are familiar with making plugins, consider contributing a pull request on GitHub: https://github.com/lunarwtr/lffboard-plugin

## Technical Notes

- Written in Lua for the LOTRO Turbine plugin API.
- Main files: `Main.lua`, `MainWindow.lua`, `Options.lua`, `Parser.lua`, `Data.lua`.
- Settings are saved per character and persist between sessions.
