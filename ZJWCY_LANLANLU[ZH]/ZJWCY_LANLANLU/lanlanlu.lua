local ATLAS_KEY1 = 'ZJWCY_lll_atlas1'
local FULL_PURE_RED = HEX('FF0000')
local NEVER = 'nEVeR'
local LOC_TXT_RSL = {
    zh_CN = {
        name = '辞职申请',
        text = {
            '本赛局内',
            '售出过的{C:attention}小丑牌{}',
            '不会再出现'
        }
    },
    default = {}
}
local MESSAGE_TRIGGERED_RSL = '前程似锦！'
local LOC_TXT_VSN = {
    zh_CN = {
        name = '剪刀手',
        text = {
            '所有{C:attention}顺子{}和{C:attention}三条{}',
            '都可以由',
            '{C:attention}两张{}牌组成'
        }
    },
    default = {}
}
local LOC_TXT_AMH = {
    zh_CN = {
        name = '反物质汉堡',
        text = {
            '击败{C:attention}Boss盲注{}后售出此牌',
            '可以为右侧{C:attention}小丑牌{}',
            '添加{C:dark_edition}负片{}效果',
            '{C:inactive}（#1#）{}'
        }
    },
    default = {}
}
local CENTER_NEGATIVE = G.P_CENTERS['e_negative']
local LOCVAR_INACTIVE_AMH = '尚未击败Boss盲注'
local MESSAGE_ACTIVE_AMH = '出炉！'
local MESSAGE_RIGHTEST_AMH = '右侧没有小丑牌！'
local MESSAGE_CANNOT_AMH = '版本不可叠加！'
local MESSAGE_TRIGGERED_AMH = '呕......'
local LOC_TXT_RTT = {
    zh_CN = {
        name = '食物小丑牌',
        text = {
            '大麦克香蕉、鸡蛋、冰淇淋、',
            '卡文迪什、黑龟豆、爆米花、',
            '零糖可乐、拉面、苏打水、',
            LOC_TXT_AMH['zh_CN'].name
        }
    },
    default = {}
}
local LOC_TXT_RND = {
    zh_CN = {
        name = '罗纳德',
        text = {
            '离开商店时',
            '自动花费{C:money}$#1#{}生成一张',
            '{C:dark_edition}负片{}食物{C:attention}小丑牌{}'
        }
    },
    default = {}
}
local MESSAGE_TRIGGERED_RND = '蓝↗蓝↗路↑'
local MESSAGE_CHOICELESS_RND = '没有可生成的牌！'
local LOC_TXT_CHALLENGE = { name = '蓝蓝路' }

SMODS.Atlas {
    key = ATLAS_KEY1,
    path = 'lll_atlas1.png',
    px = 71,
    py = 95
}

local RSL_FULL_KEY = 'j_ZJWCY_lll_resignation_letter'
local RSL_RECORD_SELLING = function(card)
    local sold_jokers = G.GAME.current_round[RSL_FULL_KEY].sold_jokers
    local key = card.config.center_key

    for _, v in ipairs(sold_jokers) do
        if key == v then
            return
        end
    end
    sold_jokers[#sold_jokers + 1] = key
end
SMODS.Joker {
    key = 'resignation_letter',
    loc_txt = LOC_TXT_RSL,
    blueprint_compat = false,
    discovered = true,
    rarity = 2,
    atlas = ATLAS_KEY1,
    pos = { x = 0, y = 0 },
    cost = 6,
    calculate = function(self, card, context)
        local sold_card = context.card

        if
            context.selling_card and
            not context.blueprint and
            sold_card.config.center.set == 'Joker' and
            not rawequal(sold_card, card)
        then
            sold_card.config.center.yes_pool_flag = NEVER
            card_eval_status_text(card, 'extra', nil, nil, nil, { message = MESSAGE_TRIGGERED_RSL })
            RSL_RECORD_SELLING(sold_card)
            return
        end
    end,
    add_to_deck = function(self, card, from_debuff)
        if self.is_only_active(card) then
            self.set_yes_flags(NEVER)
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        if self.is_only_active(card) then
            self.set_yes_flags(nil)
        end
    end,
    load = function(self, card, card_table, other_card)
        --local now = socket.gettime()
        local now = os.time()

        --if (now > G.GAME.current_round[RSL_FULL_KEY].last_loading_time + 999999) then
        if (now > G.GAME.current_round[RSL_FULL_KEY].last_loading_time) then
            for _, v in ipairs(G.GAME.current_round[RSL_FULL_KEY].sold_jokers) do
                G.P_CENTERS[v].yes_pool_flag = NEVER
            end
            G.GAME.current_round[RSL_FULL_KEY].last_loading_time = now
        end
    end,
    is_only_active = function(card)
        for _, v in ipairs(SMODS.find_card(RSL_FULL_KEY)) do
            if not rawequal(v, card) then
                return false
            end
        end
        return true
    end,
    set_yes_flags = function(value)
        for _, v in ipairs(G.GAME.current_round[RSL_FULL_KEY].sold_jokers) do
            G.P_CENTERS[v].yes_pool_flag = value
        end
    end
}

local VSN_FULL_KEY = 'j_ZJWCY_lll_v_sign'
SMODS.Joker {
    key = 'v_sign',
    loc_txt = LOC_TXT_VSN,
    blueprint_compat = false,
    discovered = true,
    rarity = 2,
    atlas = ATLAS_KEY1,
    pos = { x = 1, y = 0 },
    cost = 6,
    update = function(self, card, dt)
        if not rawequal(evaluate_poker_hand, NEW_EPH) then
            evaluate_poker_hand = NEW_EPH
        end
    end
}

local RTT_FULL_KEY = 'j_ZJWCY_lll_ronald_tooltip'
SMODS.Joker {
    key = 'ronald_tooltip',
    loc_txt = LOC_TXT_RTT,
    yes_pool_flag = NEVER,
    no_collection = true
}

local RND_FULL_KEY = 'j_ZJWCY_lll_ronald'
local AMH_FULL_KEY = 'j_ZJWCY_lll_antimatter_hamburger'
local RND_FOOD_KEYS = {
    'j_gros_michel', 'j_egg',         'j_ice_cream',
    'j_cavendish',   'j_turtle_bean', 'j_diet_cola',
    'j_popcorn',     'j_ramen',       'j_selzer',
    AMH_FULL_KEY
}
local RND_FOOD_COST = 10
SMODS.Joker {
    key = 'ronald',
    loc_txt = LOC_TXT_RND,
    blueprint_compat = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS[RTT_FULL_KEY]
        if card.edition == nil or not card.edition['negative'] then
            info_queue[#info_queue + 1] = CENTER_NEGATIVE
        end
        return { vars = { RND_FOOD_COST } }
    end,
    rarity = 4,
    atlas = ATLAS_KEY1,
    pos = { x = 2, y = 0 },
    soul_pos = { x = 2, y = 1 },
    cost = 20,
    calculate = function(self, card, context)
        local _card = context.blueprint_card or card
        local yes_pool_flag, no_pool_flag
        local choices = {}
        local chosen_key
        local food_card

        if context.ending_shop then
            for _, v in ipairs(RND_FOOD_KEYS) do
                yes_pool_flag, no_pool_flag = G.P_CENTERS[v].yes_pool_flag, G.P_CENTERS[v].no_pool_flag
                if
                    (#SMODS.find_card(v, true) == 0 or #SMODS.find_card('j_ring_master') > 0) and
                    (yes_pool_flag == nil or G.GAME.pool_flags[yes_pool_flag]) and
                    not G.GAME.pool_flags[no_pool_flag]
                then
                    choices[#choices + 1] = v
                end
            end
            if #choices > 0 then
                chosen_key = pseudorandom_element(choices, pseudoseed('ronald'))
                food_card = create_card(nil, G.jokers, nil, nil, nil, nil, chosen_key, nil)
                G.GAME.joker_buffer = 1
                food_card:set_edition({ negative = true }, true)
                food_card:add_to_deck()
                G.jokers:emplace(food_card)
                food_card:start_materialize()
                G.GAME.joker_buffer = 0
                card_eval_status_text(_card, 'extra', nil, nil, nil, { message = MESSAGE_TRIGGERED_RND, colour = FULL_PURE_RED })
                ease_dollars(-RND_FOOD_COST)
            else
                card_eval_status_text(_card, 'extra', nil, nil, nil, { message = MESSAGE_CHOICELESS_RND, colour = FULL_PURE_RED })
            end
            return
        end
    end
}

SMODS.Joker {
    key = 'antimatter_hamburger',
    loc_txt = LOC_TXT_AMH,
    blueprint_compat = false,
    eternal_compat = false,
    discovered = true,
    config = { extra = { is_active = false } },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = CENTER_NEGATIVE
        return { vars = { card.ability.extra.is_active and localize('k_active') or LOCVAR_INACTIVE_AMH } }
    end,
    rarity = 3,
    atlas = ATLAS_KEY1,
    pos = { x = 3, y = 0 },
    cost = 8,
    calculate = function(self, card, context)
        if
            context.end_of_round and
            not context.repetition and
            not context.individual and
            not context.blueprint and
            G.GAME.blind.boss
        then
            local eval = function(_card) return not _card.REMOVED end
            
            card.ability.extra.is_active = true
            juice_card_until(card, eval, true)
            return {
                message = MESSAGE_ACTIVE_AMH,
                colour = G.C.FILTER
            }
        end

        if
            context.selling_self and
            not context.blueprint and
            card.ability.extra.is_active
        then
            local jokers = G.jokers.cards
            local card_being_negative

            for i = 1, #jokers do
                if rawequal(jokers[i], card) then
                    card_being_negative = jokers[i + 1]
                    if card_being_negative == nil then
                        card_eval_status_text(card, 'extra', nil, nil, nil, { message = MESSAGE_RIGHTEST_AMH, colour = FULL_PURE_RED })
                    elseif card_being_negative.edition ~= nil and next(card_being_negative.edition) ~= nil then
                        card_eval_status_text(card, 'extra', nil, nil, nil, { message = MESSAGE_CANNOT_AMH, colour = FULL_PURE_RED })
                    else
                        card_eval_status_text(card_being_negative, 'extra', nil, nil, nil, { message = MESSAGE_TRIGGERED_AMH })
                        card_being_negative:set_edition({ negative = true }, true)
                        card_being_negative:juice_up(0.3, 0.5)
                        check_for_unlock({type = 'have_edition'})
                    end
                    break
                end
            end
            return
        end
    end
}

SMODS.Challenge {
    key = 'lanlanlu_challenge',
    loc_txt = LOC_TXT_CHALLENGE,
    jokers = {
        { id = RSL_FULL_KEY },
        { id = VSN_FULL_KEY, eternal = true },
        { id = RND_FULL_KEY, eternal = true },
        { id = AMH_FULL_KEY },
        { id = 'j_seance' }
    },
    rules = { modifiers = {
        { id = 'hands', value = 3 },
        { id = 'joker_slots', value = 6 },
        { id = 'dollars', value = 12 },
    } }
}

local ORIGINAL_IGO = Game.init_game_object
function Game:init_game_object()
    local game = ORIGINAL_IGO(self)

    game.current_round[RSL_FULL_KEY] = {
        sold_jokers = {},
        last_loading_time = 0
    }
    return game
end

local ORIGINAL_SC = Card.sell_card
function Card:sell_card()
    ORIGINAL_SC(self)
    RSL_RECORD_SELLING(self)
end

local ORIGINAL_GS = get_straight
function get_straight(hand)
    local ret = ORIGINAL_GS(hand)

    if #ret == 0 and #SMODS.find_card(VSN_FULL_KEY) > 0 then
        local num_cards = #hand
        local id_ahead, id_behind
        local max_distance = #SMODS.find_card('j_shortcut') > 0 and 3 or 2
        
        if num_cards > 1 then
            for i = 1, num_cards - 1 do
                id_ahead = hand[i]:get_id()
                if id_ahead > 1 then
                    for j = i + 1, num_cards do
                        id_behind = hand[j]:get_id()
                        if id_ahead ~= id_behind then
                            if
                                id_ahead == 14 and
                                (id_ahead - id_behind < max_distance or id_behind <= max_distance)
                            then
                                return { { hand[j], hand[i] } }
                            elseif
                                id_behind == 14 and
                                (id_behind - id_ahead < max_distance or id_ahead <= max_distance)
                            then
                                return { { hand[i], hand[j] } }
                            elseif id_behind > 1 and math.abs(id_ahead - id_behind) < max_distance then
                                return id_ahead < id_behind and { { hand[i], hand[j] } } or { { hand[j], hand[i] } }
                            end
                        end
                    end
                end
            end
        end
    end
    return ret
end

--[[
local ORIGINAL_GXS = get_X_same
function get_X_same(num, hand)
    local ret = ORIGINAL_GXS(num, hand)

    if 
        #ret == 0 and
        #SMODS.find_card(VSN_FULL_KEY) > 0 and
        num == 3
    then
        return ORIGINAL_GXS(2, hand)
    end
    return ret
end
]]

local SMODS_EPH = evaluate_poker_hand
function NEW_EPH(hand)
    local results = SMODS_EPH(hand)
    local pair = results['Pair']
    local two_pair = results['Two Pair']

    if #SMODS.find_card(VSN_FULL_KEY) > 0 then
        if #two_pair > 0 then
            results['Full House'] = two_pair
        elseif #pair > 0 then
            results['Three of a Kind'] = pair
        end
    end

    return results
end
