## Data Updater Tool

This script (`generate_lua.pl`) is used to update the `Data.lua` file in the LFFBoard plugin by converting instance/raid/seasonal data from CSV files into the Lua data format.

### What It Does

- Reads instance, raid, and seasonal data from the provided CSV files in this directory.
- Processes and formats the data for use in the LFFBoard plugin.
- Outputs a Lua data for use in LFFBoard.

### Prerequisites (WSL/Ubuntu)


You need Perl installed (usually pre-installed on Ubuntu). You will also need the following Perl module:

- `Text::CSV` (for parsing CSV files)


To install the required module, run:

```sh
sudo apt update
sudo apt install libtext-csv-perl
```


### Example Usage

The script uses the following CSV files by default (all must be present in this directory):

- `Lotro Instances - Seasonal.csv`
- `Lotro Instances - Instances.csv`
- `Lotro Instances - Other.csv`
- `Lotro Instances - Raids.csv`

It outputs the Lua data to standard output. To update `Data.lua`, run:

```sh
perl generate_lua.pl > ../LFFBoard/Data.lua
```

This will generate or update the `Data.lua` file with the latest data from the CSVs. No command-line options are required or supported.

---
