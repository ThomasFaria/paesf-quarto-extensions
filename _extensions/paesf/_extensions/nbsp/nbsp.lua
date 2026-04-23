--- fr-nbsp.lua – add no-break spaces in French documents
---
--- Copyright: © 2022 Romain Lesur
--- License: MIT – see LICENSE for details

PANDOC_VERSION:must_be_at_least '2.9.2'

--- Ajoute des espaces insécables dans le texte selon les règles typographiques françaises
--- @param inlines table Liste d'éléments inline Pandoc à traiter
--- @return table Liste modifiée avec espaces insécables
---
--- Cette fonction détecte les patterns suivants et remplace l'espace normal par un espace insécable :
---
--- 1. Espace insécable étroit (U+202F) pour :
---    - Avant les signes de ponctuation : ; ! ? : %
---    - Avant le symbole € (euro)
---    - Entre un chiffre et un groupe de 3 chiffres (ex: 1 000)
---    - Entre ° et un chiffre (ex: ° 5)
---    - Entre + ou - et un chiffre (ex: + 5)
---
--- 2. Espace insécable normal (U+00A0) pour :
---    - Entre un chiffre et les unités : ans, mill(ions/iards), point(s), ETP, M€, Md€
---    - Exemples : "10 ans", "100 millions", "5 points", "20 ETP", "50 M€", "100 Md€"
--- Ajoute des espaces insécables au sein des Str (cas sans espace du tout, ex: "5Md€", "+4,3%")
local function fix_missing_spaces_in_str(inlines)
    -- Espace insécable normal (U+00A0) : chiffre collé à une unité
    local regular_units = {'Md€', 'M€', 'ETP', 'ans', 'mill', 'point', 'pp'}
    for i = 1, #inlines do
        if inlines[i].t == 'Str' then
            local text = inlines[i].text
            for _, unit in ipairs(regular_units) do
                text = string.gsub(text, '(%d)(' .. unit .. ')', '%1\u{00a0}%2')
            end
            -- Espace insécable étroit (U+202F) : chiffre collé à % (ex: "+4,3%")
            text = string.gsub(text, '(%d)(%%)', '%1\u{202f}%2')
            -- Espace insécable étroit (U+202F) : signe +/- en début de token collé à un chiffre (ex: "+4,3")
            -- On évite de toucher les cas comme "1998-2026" (tiret entre deux chiffres)
            text = string.gsub(text, '^([%+%-])(%d)', '%1\u{202f}%2')
            inlines[i].text = text
        end
    end
    return inlines
end

local function add_non_breaking_spaces(inlines)
    local i = 1

    -- Parcourt tous les éléments inline par triplets (texte, espace, texte)
    while inlines[i+2] do
        if inlines[i].t == 'Str' and inlines[i+1].t == 'Space' and inlines[i+2].t == 'Str' then
            -- Cas 1 : Espace insécable étroit (U+202F)
            if string.match(inlines[i+2].text,  '^[;!%?%%:€]')  -- Ponctuation et symboles
            or string.match(inlines[i].text, '%d$') and string.match(inlines[i+2].text, '^%d%d%d[^%d]*')  -- Séparateur de milliers
            or string.match(inlines[i].text, '°$') and string.match(inlines[i+2].text, '^%d')  -- Degré + chiffre
            or string.match(inlines[i].text, '[+-]$') and string.match(inlines[i+2].text, '^%d') then  -- Signe + chiffre
                inlines[i].text = inlines[i].text .. '\u{202f}' .. inlines[i+2].text
                inlines:remove(i+2)
                inlines:remove(i+1)
            -- Cas 2 : Espace insécable normal (U+00A0)
            elseif string.match(inlines[i].text, '%d$') and string.match(inlines[i+2].text, '^ans.*$')  -- Chiffre + ans
            or string.match(inlines[i].text, '%d$') and string.match(inlines[i+2].text, '^mill.*$')  -- Chiffre + millions/milliards
            or string.match(inlines[i].text, '%d$') and string.match(inlines[i+2].text, '^point.*$')  -- Chiffre + points
            or string.match(inlines[i].text, '%d$') and string.match(inlines[i+2].text, '^ETP.*$')  -- Chiffre + ETP
            or string.match(inlines[i].text, '%d$') and string.match(inlines[i+2].text, '^M€.*$')  -- Chiffre + M€
            or string.match(inlines[i].text, '%d$') and string.match(inlines[i+2].text, '^Md€.*$')  -- Chiffre + Md€
            or string.match(inlines[i].text, '%d$') and string.match(inlines[i+2].text, '^pp.*$') then  -- Chiffre + pp
            
                inlines[i].text = inlines[i].text .. '\u{00a0}' .. inlines[i+2].text
                inlines:remove(i+2)
                inlines:remove(i+1)
            else
                i = i+1
            end
        else
            i = i+1
        end
    end

    return inlines
end

--- For HTML output, since the Narrow No-Break Spaces (U+202F) are not well supported
--- by browsers (they are breakable), use this solution: https://stackoverflow.com/a/1570664
--- We replace nnbsp with &thinsp; and embed them in spans with white-space:nowrap styling.
--- Detecting U+202F in Lua is tricky bc of its unicode support in string matching.
--- We must detect bytes corresponding to U+202F encoded in UTF8 (226 128 175 in decimals)
local function wrap_nnbsp_in_span(inlines)
    for i = 1, #inlines, 1 do
        if inlines[i].t == 'Str' and string.match(inlines[i].text, '\226\128\175') then
            inlines[i] = pandoc.RawInline('html', "<span style='white-space:nowrap'>" .. string.gsub(inlines[i].text, '\226\128\175', '&thinsp;') .. '</span>')
        end
    end
    return inlines
end


if quarto.doc.is_format("html") then
    return {
        {
            Inlines = function(inlines)
                inlines = fix_missing_spaces_in_str(inlines)
                inlines = add_non_breaking_spaces(inlines)
                -- inlines = wrap_nnbsp_in_span(inlines)
                return inlines
            end
        }
    }
else
    return {
        {
            Inlines = function(inlines)
                inlines = fix_missing_spaces_in_str(inlines)
                inlines = add_non_breaking_spaces(inlines)
                return inlines
            end
        }
    }
end
