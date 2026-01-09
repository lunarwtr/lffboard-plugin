
import "LFFBoard.Types"

Parser = {}

function Parser.normalize_name(str)
    str = string.lower(str or "")
    str = str:gsub("[/.,+:]+", " ")
    str = str:gsub("^the%s+", "")
    str = str:gsub("[^%w%s]", "")
    str = str:gsub("%s+", " ")
    str = str:gsub("%s+of the%s+", " ")
    return str
end

--- Categorize message by precedence: exact name, abbreviation (specific/generic), partial name
---@param msg string The message to parse
---@param data LFFBoardDungeon[] The list of dungeon data
---@param abbrevMap table<string, LFFBoardDungeon[]> Prebuilt abbreviation map (abbr → dungeons)
---@return LFFBoardDungeon[] matches Only specific matches if present, otherwise generic matches
function Parser.categorize_message(msg, data, abbrevMap)
    local norm_msg = Parser.normalize_name(msg)
    local specific_matches = {}
    local generic_matches = {}
    local matched_names = {}

    -- Turbine.Shell.WriteLine("[LFFBoard] categorize_message: msg='" .. msg .. "' norm='" .. norm_msg .. "'")

    -- 1. Exact full name match
    for i, entry in ipairs(data) do
        local entry_name = Parser.normalize_name(entry.name)
        if string.find(norm_msg, entry_name, 1, true) and not matched_names[entry_name] then
            table.insert(specific_matches, entry)
            matched_names[entry_name] = true
            -- Turbine.Shell.WriteLine("[LFFBoard] Exact name match: " .. entry.name)
        end
    end

    -- 2. Abbreviation match using abbrevMap
    local abbr_hits = {}
    for abbr, entries in pairs(abbrevMap) do
        local pattern = "%f[%w]" .. abbr .. "%f[%W]"
        if string.find(norm_msg, pattern) then
            table.insert(abbr_hits, {abbr = abbr, entries = entries})
            -- Turbine.Shell.WriteLine("[LFFBoard] Abbr match: '" .. abbr .. "' count=" .. tostring(#entries))
        end
    end

    -- Sort abbr_hits: specific (count==1) first, then generic
    table.sort(abbr_hits, function(a, b)
        return #a.entries < #b.entries
    end)

    for _, hit in ipairs(abbr_hits) do
        if #hit.entries == 1 then
            local entry = hit.entries[1]
            local entry_name = Parser.normalize_name(entry.name)
            if not matched_names[entry_name] then
                table.insert(specific_matches, entry)
                matched_names[entry_name] = true
                -- Turbine.Shell.WriteLine("[LFFBoard] Specific abbr match: " .. entry.name)
            end
        else
            for _, entry in ipairs(hit.entries) do
                local entry_name = Parser.normalize_name(entry.name)
                if not matched_names[entry_name] then
                    table.insert(generic_matches, entry)
                    matched_names[entry_name] = true
                    -- Turbine.Shell.WriteLine("[LFFBoard] Generic abbr match: " .. entry.name)
                end
            end
        end
    end

    -- Prefer specific matches over generic
    -- Turbine.Shell.WriteLine("[LFFBoard] specific_matches=" .. tostring(#specific_matches) .. " generic_matches=" .. tostring(#generic_matches))
    if #specific_matches > 0 then
        return specific_matches
    else
        return generic_matches
    end
end

---Called at startup or when options change
---@param data LFFBoardDungeon[] The list of dungeon data
---@param dungeonConfig table<string, LFFBoardDungeonSetting> User settings for dungeons
---@return table<string, LFFBoardDungeon[]> abbreviation map
function Parser.build_abbr_map(data, dungeonConfig)
    local abbr_map = {}
    for _, entry in ipairs(data) do
        local abbrs = dungeonConfig[entry.name] and dungeonConfig[entry.name].abbr or entry.abbr
        if abbrs then
            for _, abbr in ipairs(abbrs) do
                local norm_abbr = Parser.normalize_name(abbr)
                if not abbr_map[norm_abbr] then abbr_map[norm_abbr] = {} end
                table.insert(abbr_map[norm_abbr], entry)
            end
        end
    end
    return abbr_map
end