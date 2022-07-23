function DukeHelpers.GenerateEncyclopediaPage(wikiDescription)
    if type(wikiDescription) == "string" then
        return
    end
    local output = {}
    for _, section in pairs(wikiDescription) do
        local outputSection = {}
        for _, part in pairs(section) do
            if #outputSection <= 0 then
                table.insert(outputSection, { str = part, fsize = 2, clr = 3, halign = 0 })
            else
                table.insert(outputSection, { str = part })
            end
        end
        table.insert(output, outputSection)
    end

    return output
end

function DukeHelpers.AddExternalItemDescriptionCard(card)
    if EID and card.Descriptions then
        DukeHelpers.RegisterExternalItemDescriptionLanguages(card.Id, card.Names, card.Descriptions, EID.addCard)

        local cardFrontSprite = Sprite()
        cardFrontSprite:Load("gfx/ui/eid_card_fronts.anm2", true)
        EID:addIcon("Card" .. card.Id, card.Tag, -1, 8, 8, 0, 1, cardFrontSprite)
    end
end

function DukeHelpers.AddExternalItemDescriptionItem(item)
    if EID and item.Descriptions then
        DukeHelpers.RegisterExternalItemDescriptionLanguages(item.Id, item.Names, item.Descriptions, EID.addCollectible)
    end
end

function DukeHelpers.AddExternalItemDescriptionTrinket(trinket)
    if EID and trinket.Descriptions then
        DukeHelpers.RegisterExternalItemDescriptionLanguages(trinket.Id, trinket.Names, trinket.Descriptions,
            EID.addTrinket)
    end
end

function DukeHelpers.RegisterExternalItemDescriptionLanguages(id, names, descriptions, func)
    if EID and descriptions then
        for language, description in pairs(descriptions) do
            func(EID, id, description, names[language], language)
        end
    end
end
