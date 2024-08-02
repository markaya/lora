local Player = require("Player")

---@class Game
---@field state STATE
---@field players Player[]
---@field playable_character_id number
---@field field Card[]
---@field playable_cards Card[]
---@field turn number
---@field selected_card Card?
Game = {}

---Start new Game
---@param loaded_cards Card[]
---@return Game
function Game:new(loaded_cards)
  local players = {}

  -- NOTE: Insert Players
  for i = 1, 4, 1 do
    table.insert(players, Player:new(i))
  end

  local newObj = {
    state = STATE.player_turn,
    players = players,
    field = {},
    turn = 1,
    playable_cards = loaded_cards,
    playable_character_id = 1,
  }
  self.__index = self
  return setmetatable(newObj, self)
end

---@param field_scale number?
function Game:draw_field(field_scale)
  local x, y
  local scale = field_scale or GLOBAL_SCALE

  if self.selected_card then
    love.graphics.setColor(0, 1, 0, 1)
  else
    love.graphics.setColor(1, 1, 1)
  end

  love.graphics.setLineWidth(3)
  -- NOTE: Main player
  love.graphics.rectangle(
    "line",
    CARD_FIELDS.main_player.x(field_scale),
    CARD_FIELDS.main_player.y(),
    cards_width * scale,
    cards_height * scale
  )

  love.graphics.setColor(1, 1, 1)
  -- NOTE: Player Right
  love.graphics.rectangle(
    "line",
    CARD_FIELDS.right_player.x(),
    CARD_FIELDS.right_player.y(),
    cards_height * scale,
    cards_width * scale
  )

  -- NOTE: player up
  love.graphics.rectangle(
    "line",
    CARD_FIELDS.top_player.x(),
    CARD_FIELDS.top_player.y(),
    cards_width * scale,
    cards_height * scale
  )

  -- NOTE: player left
  love.graphics.rectangle(
    "line",
    CARD_FIELDS.left_player.x(),
    CARD_FIELDS.left_player.y(),
    cards_height * scale,
    cards_width * scale
  )

  love.graphics.setLineWidth(1)
end

---@param debugging boolean
function Game:draw(debugging)
  if debugging then
    love.graphics.line(lgW / 2, 0, lgW / 2, lgH)
    love.graphics.line(lgW * 3 / 4, 0, lgW * 3 / 4, lgH)
    love.graphics.line(lgW * 1 / 4, 0, lgW * 1 / 4, lgH)
    love.graphics.setColor(1, 0, 0)
    love.graphics.line(0, lgH / 2, lgW, lgH / 2)
    love.graphics.line(0, lgH * 1 / 4, lgW, lgH * 1 / 4)
    love.graphics.line(0, lgH * 3 / 4, lgW, lgH * 3 / 4)
    love.graphics.setColor(1, 1, 1)
  end

  self:draw_field()

  -- NOTE: Draw Main Player

  ---@type number
  local next_player_id = game.playable_character_id
  ---@type Card[]
  local player_cards = game.players[next_player_id].cards

  local x_pos = (lgW / 2) - (#player_cards * (cards_width * GLOBAL_SCALE) * 3 / 8)
  local y_pos = lgH * 3 / 4

  local draw_selected_card = {}
  for i, card in ipairs(player_cards) do
    if card == self.selected_card then
      draw_selected_card.index = i
      draw_selected_card.x_pos = x_pos
      draw_selected_card.y_pos = y_pos
      x_pos = x_pos + (cards_width * 3 * GLOBAL_SCALE / 4)
    else
      card:draw(x_pos, y_pos, GLOBAL_SCALE)
      x_pos = x_pos + (cards_width * 3 * GLOBAL_SCALE / 4)
    end
  end
  if self.selected_card ~= nil then
    self.selected_card:draw(draw_selected_card.x_pos, draw_selected_card.y_pos, GLOBAL_SCALE)
  end

  if self.players[next_player_id].played_card ~= nil then
    self.players[next_player_id].played_card:draw(
      CARD_FIELDS.main_player.x(),
      CARD_FIELDS.main_player.y(),
      GLOBAL_SCALE
    )
  end

  -- NOTE: Draw Player 2 on Right
  next_player_id = self.next_player(game.playable_character_id)
  player_cards = game.players[next_player_id].cards
  x_pos = lgW - cards_height
  y_pos = lgH / 2 - (#player_cards * cards_width / 4) + cards_width

  for _, card in ipairs(player_cards) do
    card:drawRotated(x_pos, y_pos, -math.pi / 2, 1)
    y_pos = y_pos + (cards_width / 2)
  end

  if self.players[next_player_id].played_card ~= nil then
    self.players[next_player_id].played_card:drawRotated(
      CARD_FIELDS.right_player.x(),
      CARD_FIELDS.right_player.y() + cards_width * GLOBAL_SCALE,
      -math.pi / 2,
      GLOBAL_SCALE
    )
  end

  -- NOTE: Draw Player 3 on Top
  next_player_id = self.next_player(next_player_id)
  player_cards = game.players[next_player_id].cards
  x_pos = (lgW / 2) - (#player_cards * cards_width / 4) - cards_width * 1 / 4
  y_pos = 0

  for _, card in ipairs(player_cards) do
    card:draw(x_pos, y_pos, 1)
    x_pos = x_pos + (cards_width / 2)
  end

  if self.players[next_player_id].played_card ~= nil then
    self.players[next_player_id].played_card:draw(CARD_FIELDS.top_player.x(), CARD_FIELDS.top_player.y(), GLOBAL_SCALE)
  end

  --NOTE: Draw Player 4 on Right
  next_player_id = self.next_player(next_player_id)
  player_cards = game.players[next_player_id].cards
  x_pos = cards_height
  y_pos = lgH / 2 - (#player_cards * cards_width / 4) - cards_width * 1 / 4

  for _, card in ipairs(player_cards) do
    card:drawRotated(x_pos, y_pos, math.pi / 2, 1)
    y_pos = y_pos + (cards_width / 2)
  end

  if self.players[next_player_id].played_card ~= nil then
    self.players[next_player_id].played_card:drawRotated(
      CARD_FIELDS.left_player.x(),
      CARD_FIELDS.left_player.y() + cards_width * GLOBAL_SCALE,
      -math.pi / 2,
      GLOBAL_SCALE
    )
  end
end

function Game.next_player(current_player_id)
  -- code
  if current_player_id == 4 then
    return 1
  else
    return current_player_id + 1
  end
end

function Game:shuffle_cards()
  local j
  for i = #self.playable_cards, 1, -1 do
    j = love.math.random(i)
    self.playable_cards[i], self.playable_cards[j] = self.playable_cards[j], self.playable_cards[i]
  end
end

function Game:deal_cards()
  for i, card in ipairs(self.playable_cards) do
    local index = i % 4 + 1
    table.insert(game.players[index].cards, card)
    table.sort(game.players[index].cards, function(a, b)
      if a.sign == b.sign then
        return a.value < b.value
      else
        return a.sign < b.sign
      end
    end)
  end
end

function Game:play_a_card()
  local is_card_played = false
  for i, value in ipairs(self.players[1].cards) do
    if self.selected_card == value then
      self:increment_player_turn()
      self.players[1].played_card = self.selected_card
      table.remove(self.players[1].cards, i)
      self.selected_card = nil
      is_card_played = true
      break
    end
  end
  if is_card_played then
    self:play_cards_for_bots()
  end
end

function Game:increment_player_turn()
  if self.turn == 4 then
    self.turn = 1
  else
    self.turn = self.turn + 1
  end
end

function Game:is_your_turn()
  if self.turn == 1 then
    return true
  end
end

function Game:play_cards_for_bots()
  if self.turn ~= 1 then
    repeat
      local player = self.players[self.turn]
      local player_cards = player.cards
      local is_card_played = false
      local card_id
      for i, card in ipairs(player_cards) do
        if card.sign == game.players[1].played_card.sign then
          player.played_card = card
          card_id = i
          is_card_played = true
          break
        end
      end

      if not is_card_played then
        card_id = love.math.random(#player.cards)
        player.played_card = player.cards[card_id]
      end

      table.remove(player.cards, card_id)
      self:increment_player_turn()
    until self.turn == 1
  end
end

return Game
