---@diagnostic disable: inject-field, duplicate-set-field
local love = require("love")

---@type Player
local Player = require("Player")

---@type Game
local Game = require("Game")

---@type Card
local Card = require("Card")

require("Utils")

---@enum SIGNS
SIGNS = {
  clubs = 1,
  diamonds = 2,
  spades = 3,
  hearts = 4,
}

---@enum STATE
STATE = {
  paused = "paused",
  pick_game = "pick_game",
  player_turn = "player_turn",
}

---@enum VALUES
VALUES = { A = 15, J = 12, Q = 13, K = 14 }

love.load = function()
  _G.card_back_image = love.graphics.newImage("resources/PNG/L/card_back.png")

  _G.cards_width = card_back_image:getWidth()
  _G.cards_height = card_back_image:getHeight()

  _G.lgW = love.graphics.getWidth()
  _G.lgH = love.graphics.getHeight()

  CARD_FIELDS = {
    main_player = {
      x = function(scale)
        local image_scale = scale or GLOBAL_SCALE
        return lgW / 2 - ((cards_width * image_scale) / 2) - 2
      end,
      y = function()
        return lgH / 2 + math.floor(lgH / 17)
      end,
    },
    right_player = {
      x = function()
        return lgW / 2 + math.floor(lgH / 17)
      end,
      y = function(scale)
        local image_scale = scale or GLOBAL_SCALE
        return lgH / 2 - ((cards_width * image_scale) / 2)
      end,
    },
    top_player = {
      x = function(scale)
        local image_scale = scale or GLOBAL_SCALE
        return lgW / 2 - ((cards_width * image_scale) / 2) - 2
      end,
      y = function(scale)
        local image_scale = scale or GLOBAL_SCALE
        return lgH / 2 - math.floor(lgH / 17) - (cards_height * image_scale)
      end,
    },
    left_player = {
      x = function(scale)
        local image_scale = scale or GLOBAL_SCALE
        return lgW / 2 - math.floor(lgH / 17) - (cards_height * image_scale)
      end,
      y = function(scale)
        local image_scale = scale or GLOBAL_SCALE
        return lgH / 2 - ((cards_width * image_scale) / 2)
      end,
    },
  }

  GLOBAL_SCALE = 1.5

  ---@type Game
  _G.game = Game:new(load_cards_from_file())
  game:shuffle_cards()
  game:deal_cards()
end

love.update = function(dt) end

function love.mousepressed(x, y, button)
  if button == 1 then
    if game.selected_card and game:is_your_turn() then
      if check_if_field_clicked(x, y) then
        game:play_a_card()
        return
      end
    end
    check_is_card_clicked(x, y)
  end
end

function _G.check_if_field_clicked(x, y)
  if x > CARD_FIELDS.main_player.x() and x < CARD_FIELDS.main_player.x() + cards_width * GLOBAL_SCALE then
    if y > CARD_FIELDS.main_player.y() and y < CARD_FIELDS.main_player.y() + cards_height * GLOBAL_SCALE then
      return true
    end
  end
  return false
end

function _G.check_is_card_clicked(x, y)
  ---@type Card[]
  local player_cards = game.players[1].cards
  local start_y_pos
  local cards_scale

  ---@type integer, Card
  local _, first_element = next(player_cards)
  if first_element == nil then
    return
  else
    start_y_pos = first_element.card_position.y_pos
    cards_scale = first_element.card_position.scale
  end

  if y < start_y_pos or y > start_y_pos + cards_height * cards_scale then
    game.selected_card = nil
    return
  elseif clicked_on_selected(x, cards_scale) then
    return
  elseif #player_cards == 1 then
    local _, card = next(player_cards)
    if x > card.card_position.x_pos or x < card.card_position.x_pos + cards_scale * cards_width then
      game.selected_card = card
    else
      game.selected_card = nil
    end
  else
    for i, card in ipairs(player_cards) do
      if i == 1 then
        if x < card.card_position.x_pos then
          game.selected_card = nil
        end
      else
        local _, next_card = next(player_cards, i)
        if next_card == nil then
          if x > player_cards[i - 1].card_position.x_pos and x < card.card_position.x_pos then
            game.selected_card = player_cards[i - 1]
            return
          elseif x > card.card_position.x_pos and x < card.card_position.x_pos + cards_scale * cards_width then
            game.selected_card = card
            return
          elseif x > card.card_position.x_pos + cards_scale * cards_width then
            game.selected_card = nil
          end
        else
          if x > player_cards[i - 1].card_position.x_pos and x < card.card_position.x_pos then
            game.selected_card = player_cards[i - 1]
            return
          end
        end
      end
    end
  end
end

function _G.clicked_on_selected(x, cards_scale)
  if game.selected_card == nil then
    return false
  else
    return x > game.selected_card.card_position.x_pos
      and x < game.selected_card.card_position.x_pos + cards_scale * cards_width
  end
end

love.draw = function()
  game:draw(true)
end
