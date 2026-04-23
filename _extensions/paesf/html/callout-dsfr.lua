-- Transform Quarto callouts into DSFR callouts.
-- Quarto parses `::: callout-*` into a custom AST node (quarto.Callout).
--
-- Two pitfalls avoided here:
--   1. quarto.utils.as_inlines(node.title) calls blocks_to_inlines() which
--      flattens title + body into one Inlines list → all text ends up in the
--      bold title element.
--   2. pandoc.Header(3, ...) triggers quarto-post's section-wrapping: the
--      <div class="fr-callout__text"> ends up *inside* <section class="level3">
--      which inherits font-weight:700 from the h3 → all body text appears bold
--      after the Marianne font swaps in (font-display:swap).
--
-- Fix: emit the title as a RawBlock so Quarto never wraps it in a <section>.

local function extract_title_inlines(raw)
  if raw == nil then return nil end
  local pt = pandoc.utils.type(raw)
  if pt == "Inlines" then
    return raw
  elseif pt == "Inline" then
    return pandoc.Inlines{raw}
  elseif (pt == "Blocks" or pt == "List") and #raw > 0 then
    local b = raw[1]
    if b.t == "Plain" or b.t == "Para" or b.t == "Header" then
      return b.content
    end
  elseif pt == "Block" then
    if raw.t == "Plain" or raw.t == "Para" or raw.t == "Header" then
      return raw.content
    end
  end
  return nil
end

local CALLOUT_COLORS = {
  note      = "blue-cumulus",
  warning   = "orange-terre-battue",
  important = "pink-macaron",
  tip       = "green-bourgeon",
  caution   = "yellow-tournesol",
}

function Callout(node)
  local result_blocks = {}

  -- Title ---------------------------------------------------------------
  local title_inlines = extract_title_inlines(node.title)
  if title_inlines and #title_inlines > 0 then
    local title_str = pandoc.utils.stringify(title_inlines)
    if title_str ~= "" then
      title_str = title_str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
      table.insert(result_blocks,
        pandoc.RawBlock("html", '<p class="fr-callout__title">' .. title_str .. '</p>'))
    end
  end

  -- Body ----------------------------------------------------------------
  local body = node.content
  if pandoc.utils.type(body) == "Block" then
    body = pandoc.Blocks{body}
  end
  if body ~= nil and #body > 0 then
    table.insert(result_blocks,
      pandoc.Div(body, pandoc.Attr("", {"fr-callout__text"})))
  end

  -- Outer div with color modifier ---------------------------------------
  local color = CALLOUT_COLORS[node.type]
  local classes = {"fr-callout"}
  if color then
    table.insert(classes, "fr-callout--" .. color)
  end

  return pandoc.Div(result_blocks, pandoc.Attr("", classes))
end
