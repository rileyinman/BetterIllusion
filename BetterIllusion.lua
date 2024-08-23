--- STEAMODDED HEADER
--- MOD_NAME: Better Illusion
--- MOD_ID: better_illusion
--- MOD_AUTHOR: [rilight / rileyinman]
--- MOD_DESCRIPTION: Full rework of the Magic Trick and Illusion vouchers. If you only want to patch Illusion to generate seals, disable the rework config option.
--- LOADER_VERSION_GEQ: 1.0.0
--- PREFIX: better_illusion

----------------------------------------------
------------MOD CODE -------------------------

better_illusion = SMODS.current_mod

sendDebugMessage("Better Illusion Voucher patch activated!")

better_illusion.config_tab = function()
    return {n=G.UIT.ROOT, config={r = 0.1, minw = 8, align = "tm", padding = 0.2, colour = G.C.BLACK}, nodes={
        {n=G.UIT.R, config={padding = 0.2}, nodes={
            {n=G.UIT.R, config={align = "cm"}, nodes={
                create_toggle({
                    label = localize('better_illusion_rework'),
                    ref_table = better_illusion.config,
                    ref_value = 'rework'
                })
            }}
        }}
    }}
end

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
SMODS.Seal:take_ownership('Red', { extra_cost = 1 })
SMODS.Seal:take_ownership('Blue', { extra_cost = 1 })
SMODS.Seal:take_ownership('Gold', { extra_cost = 1 })
SMODS.Seal:take_ownership('Purple', { extra_cost = 1 })

function add_playing_card_enhancement_cost(card)
    if not better_illusion.config.rework then return end

    if card.ability and card.ability.set == 'Enhanced' then
        for k, v in pairs(G.P_CENTER_POOLS.Enhanced) do
            if card.ability.effect == v.effect then
                if v.extra_cost then
                    card.extra_cost = card.extra_cost + v.extra_cost
                else
                    card.extra_cost = card.extra_cost + 1
                end
            end
        end
    end
end

function add_playing_card_seal_cost(card)
    if not better_illusion.config.rework then return end

    if card.seal then
        for k, v in pairs(G.P_CENTER_POOLS.Seal) do
            if card.seal == v.key then
                if v.extra_cost then
                    card.extra_cost = card.extra_cost + v.extra_cost
                else
                    card.extra_cost = card.extra_cost + 1
                end
            end
        end
    end
end

function create_shop_playing_card_container()
    if not better_illusion.config.rework then return {n=G.UIT.R} end

    return ({n=G.UIT.R, config={align = "cl"}, nodes={
        {n=G.UIT.R, config={align = "cm", padding = 0.05, r = 0.1, colour = G.C.DYN_UI.MAIN}, nodes={
            {n=G.UIT.R, config={align = "cm", padding = 0.05, r = 0.1, colour = G.C.BLACK}, nodes={
                {n=G.UIT.C, config={align = "cm", padding = 0.2, r=0.2, colour = G.C.L_BLACK, minw = 2.2}, nodes={
                    {n=G.UIT.R, nodes={
                        {n=G.UIT.O, config={align = "cl", object = G.shop_playing_card}}
                    }}
                }}
            }}
        }}
    }})
end

function create_shop_playing_card_area()
    if not better_illusion.config.rework then return nil end

    return CardArea(
        G.ROOM.T.x, G.ROOM.T.y, G.CARD_W, G.CARD_H,
        {card_limit = 1, type = 'shop', highlight_limit = 1}
    )
end

function load_shop_playing_card(refresh)
    if not better_illusion.config.rework or not G.GAME.used_vouchers["v_magic_trick"] then return end

    if G.load_shop_playing_card then
        nosave_shop = true
        G.shop_playing_card:load(G.load_shop_playing_card)

        local playing_card = G.shop_playing_card.cards[1]
        create_shop_card_ui(playing_card)
        playing_card:start_materialize()

        G.load_shop_playing_card = nil
    else
        local new_shop_card = create_playing_card_for_shop(G.shop_playing_card)
        G.shop_playing_card:emplace(new_shop_card)
        if refresh then new_shop_card:juice_up() end
    end
end

function create_playing_card_for_shop(area)
    if not better_illusion.config.rework then return end

    local type = (G.GAME.used_vouchers["v_illusion"] or pseudorandom(pseudoseed('magic_trick')) > 0.6) and 'Enhanced' or 'Base'
    local playing_card = create_card(type, area, nil, nil, nil, nil, nil, 'sho')
    create_shop_card_ui(playing_card, type, area)

    if G.GAME.used_vouchers["v_illusion"] then
        playing_card:set_seal(SMODS.poll_seal({key = 'illusion', mod = 10}))
        playing_card:set_edition(poll_edition('illusion', 10, true))
    end

    return playing_card
end

function remove_shop_playing_card()
    if not better_illusion.config.rework then return end

    local playing_card = G.shop_playing_card:remove_card(G.shop_playing_card.cards[1])
    playing_card:remove()
    playing_card = nil
end

----------------------------------------------
------------MOD CODE END----------------------
