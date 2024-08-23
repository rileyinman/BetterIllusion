--- STEAMODDED HEADER
--- MOD_NAME: Better Illusion
--- MOD_ID: better_illusion
--- MOD_AUTHOR: [rilight / rileyinman]
--- MOD_DESCRIPTION: Simple patch that lets the Illusion voucher generate seals
--- LOADER_VERSION_GEQ: 1.0.0
--- PREFIX: better_illusion

----------------------------------------------
------------MOD CODE -------------------------

better_illusion = SMODS.current_mod

sendDebugMessage("Better Illusion Voucher patch activated!")

--- Add extra_cost values to enhancements
SMODS.Enhancement:take_ownership('m_bonus', { extra_cost = 0 })
SMODS.Enhancement:take_ownership('m_mult', { extra_cost = 0 })
SMODS.Enhancement:take_ownership('m_wild', { extra_cost = 0 })
SMODS.Enhancement:take_ownership('m_stone', { extra_cost = 0 })
SMODS.Enhancement:take_ownership('m_glass', { extra_cost = 2 })
SMODS.Enhancement:take_ownership('m_steel', { extra_cost = 2 })
SMODS.Enhancement:take_ownership('m_gold', { extra_cost = 2 })
SMODS.Enhancement:take_ownership('m_lucky', { extra_cost = 2 })

--- Add extra_cost values to seals
SMODS.Seal:take_ownership('s_red_seal', { extra_cost = 1 })
SMODS.Seal:take_ownership('s_blue_seal', { extra_cost = 1 })
SMODS.Seal:take_ownership('s_gold_seal', { extra_cost = 1 })
SMODS.Seal:take_ownership('s_purple_seal', { extra_cost = 1 })

function add_playing_card_enhancement_cost(card)
    if card.ability and card.ability.set == 'Enhanced' then
        for k, v in pairs(G.P_CENTER_POOLS.Enhanced) do
            if card.ability.effect == v.effect then
                if v.extra_cost then
                    card.extra_cost = card.extra_cost + v.extra_cost
                else
                    card.extra_cost = 1
                end
            end
        end
    end
end

function add_playing_card_seal_cost(card)
    if card.seal then
        for k, v in pairs(G.P_CENTER_POOLS.Seal) do
            if card.seal == v.key then
                if v.extra_cost then
                    card.extra_cost = card.extra_cost + v.extra_cost
                else
                    card.extra_cost = 0
                end
            end
        end
    end
end

function create_shop_playing_cards_container()
    if not G.GAME.used_vouchers["v_magic_trick"] then return {n=G.UIT.R} end

    return ({n=G.UIT.R, config={align = "cl"}, nodes={
        {n=G.UIT.R, config={align = "cm", padding = 0.05, r = 0.1, colour = G.C.DYN_UI.MAIN}, nodes={
            {n=G.UIT.R, config={align = "cm", padding = 0.05, r = 0.1, colour = G.C.BLACK}, nodes={
                {n=G.UIT.C, config={align = "cm", padding = 0.2, r=0.2, colour = G.C.L_BLACK, minw = 2.2}, nodes={
                    {n=G.UIT.R, nodes={
                        {n=G.UIT.O, config={align = "cl", object = G.shop_playing_cards}}
                    }}
                }}
            }}
        }}
    }})
end

function create_shop_playing_cards_area()
    if not G.GAME.used_vouchers["v_magic_trick"] then return nil end

    return CardArea(
        G.ROOM.T.x, G.ROOM.T.y, G.CARD_W, G.CARD_H,
        {card_limit = 1, type = 'shop', highlight_limit = 1}
    )
end

function load_shop_playing_cards(refresh)
    if G.shop_playing_cards == nil then return end

    if G.load_shop_playing_cards then
        nosave_shop = true
        G.shop_playing_cards:load(G.load_shop_playing_cards)
        for k, v in ipairs(G.shop_playing_cards.cards) do
            create_shop_card_ui(v)
            v:start_materialize()
        end
        G.load_shop_playing_cards = nil
    else
        for i=1, 1 - #G.shop_playing_cards.cards do
            local new_shop_card = create_playing_card_for_shop(G.shop_playing_cards)
            G.shop_playing_cards:emplace(new_shop_card)
            if refresh then new_shop_card:juice_up() end
        end
    end
end

function create_playing_card_for_shop(area)
    if area == nil then return end

    local type = (G.GAME.used_vouchers["v_illusion"] and pseudorandom(pseudoseed('illusion')) > 0.6) and 'Enhanced' or 'Base'
    local playing_card = create_card(type, area, nil, nil, nil, nil, nil, 'sho')
    create_shop_card_ui(playing_card, type, area)
    ---playing_card:set_seal(SMODS.poll_seal({key = 'illusion', mod = 10}))
    ---playing_card:set_edition(poll_edition('illusion', 10, true))
    return playing_card
end

function remove_shop_playing_cards()
    for i = #G.shop_playing_cards.cards,1, -1 do
        local c = G.shop_playing_cards:remove_card(G.shop_playing_cards.cards[i])
        c:remove()
        c = nil
    end
end

----------------------------------------------
------------MOD CODE END----------------------
