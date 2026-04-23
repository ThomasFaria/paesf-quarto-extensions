if quarto.doc.is_format("html") then
  function Meta(meta)
    if meta.download ~= nil then
      local href = pandoc.utils.stringify(meta.download)
      href = href:gsub('"', '&quot;')
      quarto.doc.include_text("in-header",
        '<meta name="pdf-download" content="' .. href .. '">')
    end
    return meta
  end
end
