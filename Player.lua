---@class Player
---@field id integer
---@field cards Card[]
---@field score integer
---@field played_card Card?
---@field taken_cards Card[]
Player = { score = 20 }

---@param id integer
---@return Player
function Player:new(id)
  local newObj = { id = id, cards = {}, score = 0, played_card = nil, taken_cards = {} }
  self.__index = self
  return setmetatable(newObj, self)
end

---@param card Card
function Player:removeCard(card)
  for index, value in ipairs(self.cards) do
    if card == value then
      table.remove(self.cards, index)
    end
  end
end

---@param card Card
function Player:add_card(card)
  table.insert(self.cards, card)
end

return Player
