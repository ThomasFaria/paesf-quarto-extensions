-- Résout le chemin vers logo-dgt.png depuis le répertoire réel de l'extension,
-- ce qui rend l'extension fonctionnelle quel que soit son namespace d'installation
-- (ex: _extensions/paesf/ en dev local vs _extensions/thomasfaria/paesf/ après
-- `quarto use template`).
function Meta(m)
  if not quarto.doc.is_format("typst") then return m end
  if not m.logo then return m end

  local ext_dir = pandoc.path.directory(pandoc.path.directory(PANDOC_SCRIPT_FILE))
  local logo_abs = pandoc.path.join({ ext_dir, "logo-dgt.png" })
  local logo_rel = pandoc.path.make_relative(logo_abs, pandoc.system.get_working_directory())

  m.logo["path"] = pandoc.MetaInlines({ pandoc.Str(logo_rel) })
  return m
end
