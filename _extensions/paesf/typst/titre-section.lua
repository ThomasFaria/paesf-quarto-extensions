-- styles/lua-filters/titre-section.lua
-- Transforme les titres avec {.titre-section} en appel Typst #titre_section[ ... ]

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function inlines_to_typst(inlines)
  -- On convertit les inlines d'un Header en typst.
  -- Astuce: passer par un Para puis enlever les retours.
  local doc = pandoc.Pandoc({ pandoc.Para(inlines) }, pandoc.Meta({}))
  local txt = pandoc.write(doc, "typst")
  txt = trim(txt)
  -- pandoc.write(...) met souvent le contenu sur une ligne, parfois avec retours.
  -- On compactifie raisonnablement:
  txt = txt:gsub("\n+", " ")
  return trim(txt)
end

function Header(el)
  if not quarto.doc.is_format("typst") then
    return nil
  end

  if not el.classes:includes("titre-section") then
    return nil
  end

  local inner = inlines_to_typst(el.content)
  local out = "#titre_section[" .. inner .. "]"

  return pandoc.RawBlock("typst", out)
end
