
// Définition des couleurs DGT
#let blue-dgt = rgb(0, 32, 96)
#let bg-beige = rgb(238, 236, 225)
#let link-blue = rgb(0, 102, 204)

#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  margin: (x: 1.25in, y: 1.25in),
  paper: "us-letter",
  header: (),
  direction: none,
  bureau: none,
  number: none,
  lang: "en",
  region: "US",
  font: "libertinus serif",
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-line-height: 0.65em,
  sectionnumbering: none,
  pagenumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  vertical-align: "top",
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: pagenumbering,
    background: none,
  )

  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)

  set align(
    if vertical-align == "center" or vertical-align == "horizon" {
      horizon
    } else if vertical-align == "bottom" {
      bottom
    } else {
      top
    }
  )

  // Style des titres h1 : bleu DGT avec fond beige
  show heading.where(level: 1): it => {
    set align(center)
    set text(fill: blue-dgt)
    block(
      width: 100%,
      fill: bg-beige,
      inset: (x: 15pt, y: 10pt),
      radius: 3pt,
      above: 20pt,
      below: 15pt,
    )[
      #it.body
    ]
  }

  // Style des titres h2 et h3 : bleu DGT sans fond
  show heading.where(level: 2): it => {
    set align(center)
    set text(fill: blue-dgt)
    block(above: 15pt, below: 10pt)[#it.body]
  }

  show heading.where(level: 3): it => {
    set align(center)
    set text(fill: blue-dgt)
    block(above: 15pt, below: 10pt)[#it.body]
  }

  v(-2em) // remonte le header dans la marge

  grid(
    columns: (1fr, 1fr),
    // Logo à gauche
    if header != () and "path" in header {
      align(header.location,
        box()[
          #image(header.path, width: header.width, alt: header.alt)
        ]
      )
    } else {
      []
    },
    // Informations à droite
    align(right)[
      #set text(size: 10pt)
      #if direction != none [#strong[#direction] \ ]
      #if bureau != none [#bureau \ ]
      #if authors != none [
        #authors.map(author => author.name).join(", ") \
      ]
      #if number != none [#number]
    ]
  )

  if title != none {
    align(center)[
      #block(
        width: 100%,
        fill: bg-beige,
        inset: (x: 15pt, y: 10pt),
        radius: 3pt,
      )[
        #set text(fill: blue-dgt)
        #set par(leading: heading-line-height)
        #text(weight: "bold", size: title-size)[#title]
        #if subtitle != none {
          linebreak()
          text(size: subtitle-size)[#subtitle]
        }
      ]
    ]
    v(-0.5em)
  }

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
    ]
  }

  if toc {
    block(above: 0em, below: 2em)[
    #outline(
      title: if toc_title == none { auto } else { toc_title },
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

#set table(
  inset: 6pt,
  stroke: none
)

// Encadrés bleus avec puces bleues
#let encadre(body) = block(
      stroke: (paint: blue-dgt, thickness: 3pt),
      inset: 10pt,
      radius: 3pt,
      above: 10pt,
      below: 15pt,
    )[
      #set list(marker: text(fill: blue-dgt)[•])
      #body
    ]

// Titre de section secondaire (graphique du mois, focus…)
#let titre_section(body) = block(
  above: 15pt,
  below: 10pt,
)[
  #set text(fill: blue-dgt, size: 1.25em, weight: "semibold")
  #set align(center)
  #body
]

// Liens hypertexte
#show link: it => {
  set text(fill: link-blue)
  underline(it)
}

// Captions : supprime le numéro de figure, stylise le texte
#show figure.caption: it => {
  set text(size: 0.8em, fill: rgb("#535353"), weight: "bold")
  it.body
  v(-0.5em)
}

// Callouts Quarto : corps réduit à 80%
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false,
    fill: background_color,
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"),
    width: 100%,
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%,
      below: 0pt,
      block(
        fill: background_color,
        width: 100%,
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt,
          width: 100%,
          block(fill: body_background_color, width: 100%, inset: 8pt)[
            #text(size: 0.8em)[#body]
          ])
      }
    )
}
