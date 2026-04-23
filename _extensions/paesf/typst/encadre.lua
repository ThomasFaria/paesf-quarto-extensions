-- encadre.lua
-- Transforme ::: {.encadre} ... ::: en #encadre[ ... ] pour la sortie Typst

function Div(el)
  if not quarto.doc.is_format("typst") then
    return nil
  end

  if el.classes:includes("encadre") then
    -- Convertit le contenu interne en Typst, puis l'enveloppe dans #encadre[ ... ]
    local inner = pandoc.write(pandoc.Pandoc(el.content), "typst")
    local out = "#encadre[\n" .. inner .. "\n]"
    return pandoc.RawBlock("typst", out)
  end

  return nil
end
