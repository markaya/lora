---@class CardPosition
---@field x_pos number
---@field y_pos number
---@field scale number
CardPosition = {}

---comment
---@param x number
---@param y number
---@param card_scale? number
---@return CardPosition
function CardPosition:new(x, y, card_scale)
  local scale = card_scale or 1
  local newObj = { x_pos = x, y_pos = y, scale = scale }
  self.__index = self
  return setmetatable(newObj, self)
end

---@class Card
---@field sign SIGNS
---@field value integer
---@field image love.Image
---@field selected boolean
---@field card_position? CardPosition
Card = {}

---@param sign SIGNS
---@param value integer
---@param file_name string
---@return Card
function Card:new(sign, value, file_name)
  local image = love.graphics.newImage("resources/PNG/L/" .. file_name .. ".png")
  local newObj = { sign = sign, value = value, image = image }
  self.__index = self
  return setmetatable(newObj, self)
end

---@param x integer x position to draw on
---@param y integer y position to draw on
---@param scale number scale
function Card:draw(x, y, scale)
  self.card_position = CardPosition:new(x, y, scale)
  love.graphics.draw(self.image, x, y, 0, scale, scale)
  if self == game.selected_card then
    love.graphics.setColor(1, 0, 0)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", x - 2, y - 2, cards_width * scale, cards_height * scale)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(1)
  end
end

---Draw object rotated for Pi/2.
---@param x integer x position to draw on
---@param y integer y position to draw on
---@param rotation number rotation in radins
---@param scale? number scale of image
function Card:drawRotated(x, y, rotation, scale)
  local image_scale = scale or 1
  self.card_position = CardPosition:new(x, y)
  love.graphics.draw(self.image, x, y, rotation, image_scale, image_scale)
end

return Card
