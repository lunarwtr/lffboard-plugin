
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

-- Categorize message by precedence: exact name, abbreviation, partial name
function Parser.categorize_message(msg, data, dungeonConfig)
    local norm_msg = Parser.normalize_name(msg)
    local matches = {}
    local matched_names = {}

    -- 1. Exact full name match
    for i, entry in ipairs(data) do
        local entry_name = Parser.normalize_name(entry.name)
        if string.find(norm_msg, entry_name, 1, true) and not matched_names[entry_name] then
            matches[#matches+1] = entry
            matched_names[entry_name] = true
        end
    end
    -- 2. Abbreviation match
    for i, entry in ipairs(data) do
        local abbrs = entry.abbr
        if dungeonConfig[entry.name] and dungeonConfig[entry.name].abbr then
            abbrs = dungeonConfig[entry.name].abbr
        end
        local entry_name = Parser.normalize_name(entry.name)
        if not matched_names[entry_name] and abbrs then
            for _, abbr in ipairs(abbrs) do
                if abbr ~= "" then
                    local pattern = "%f[%w]" .. Parser.normalize_name(abbr) .. "%f[%W]"
                    --local pattern = "([^%w]|^)" .. Parser.normalize_name(abbr) .. "([^%w]|$)"
                    if string.find(norm_msg, pattern) then
                        matches[#matches+1] = entry
                        matched_names[entry_name] = true
                        break
                    end
                end
            end
        end
    end
    -- -- 3. Partial full name match (last word)
    -- for i, entry in ipairs(data) do
    --     local entry_name = Parser.normalize_name(entry.name)
    --     local partial = entry_name:match("(%w+)$")
    --     if partial and not matched_names[entry_name] and string.find(norm_msg, partial, 1, true) then
    --         matches[#matches+1] = entry
    --         matched_names[entry_name] = true
    --     end
    -- end
    return matches
end
