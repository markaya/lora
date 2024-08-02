--- Check If file exists
---@param file string
---@return boolean
function _G.file_exists(file)
  local f = io.open(file, "rb")
  if f then
    f:close()
  end
  return f ~= nil
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
---@param file string
---@return table
function _G.lines_from(file)
  if not file_exists(file) then
    return {}
  end
  local lines = {}
  for line in io.lines(file) do
    lines[#lines + 1] = line
  end
  return lines
end

---Split string on selected charac
---@param str string String that will be split
---@param delim string char on which to split string
---@param maxNb? number maximum number of times to split a string
---@return table
function _G.split_string(str, delim, maxNb)
  -- Eliminate bad cases...
  if string.find(str, delim) == nil then
    return { str }
  end
  if maxNb == nil or maxNb < 1 then
    maxNb = 0 -- No limit
  end
  local result = {}
  local pat = "(.-)" .. delim .. "()"
  local nb = 0
  local lastPos
  for part, pos in string.gmatch(str, pat) do
    nb = nb + 1
    result[nb] = part
    lastPos = pos
    if nb == maxNb then
      break
    end
  end
  -- Handle the last field
  if nb ~= maxNb then
    result[nb + 1] = string.sub(str, lastPos)
  end
  return result
end

---Load cards
---@return Card[]
function _G.load_cards_from_file()
  ---@type string
  local file = "resources/PNG/L/_cards.csv"

  ---@type string[]
  local lines = lines_from(file)

  ---@type Card[]
  local cards_from_file = {}

  for _, v in pairs(lines) do
    ---@type string
    local str = v:gsub("[\n\r]", "")
    ---@type string[]
    local result = split_string(str, "_")
    if result[2] ~= "back" and result[2] ~= "joker" and result[2] ~= "empty" then
      local value = tonumber(result[3]) or VALUES[result[3]]
      table.insert(cards_from_file, Card:new(SIGNS[result[2]], value, str))
    end
  end

  return cards_from_file
end
