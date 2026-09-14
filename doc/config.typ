#let conf(doc) = {
  set heading(numbering: "1.1.1")
  set text(font: "Liberation Serif", size: 11pt)
  set par(justify: true, leading: 0.65em)

  set page(
    paper: "a4",
    margin: (top: 3cm, bottom: 2.5cm, x: 2cm),
    header: context {
      let page-num = counter(page).get().first()
      let on-page = query(heading.where(level: 1)).filter(h => h.location().page() == page-num)
      let before = query(selector(heading.where(level: 1)).before(here()))
      let current = if on-page.len() > 0 { on-page.last() } else if before.len() > 0 { before.last() } else { none }
      if current != none and current.body != [Contents] and current.body != [Outline] {
        let chapter-num = counter(heading).at(current.location()).first()
        text(size: 9pt, fill: black)[
          #str(chapter-num). #current.body
          #v(0.4em)
          #line(length: 100%, stroke: 0.5pt + black)
        ]
      }
    },
    footer: context {
      text(size: 9pt, fill: black)[
        #line(length: 100%, stroke: 0.5pt + black)
        #v(0.4em)
        #align(center, counter(page).display("1"))
      ]
    }
  )

  align(center)[
    #text(size: 18pt, weight: "bold")[3D Printed Metamaterials] \
    #text(size: 14pt)[Exploratory study and Core Themes] \
    #link("https://typst.app/project/wBQGVX8CTMedKqXLVoBbtb")[Online Version]
  ]

  doc
}

#let warn(input) = {
  box(
    inset: 0.2em,
    radius: 0.2em,
    fill: rgb("#ffffff"),
    stroke: rgb("#ff0000"),
    text(fill: rgb("#ff0000"), weight: "bold", input)
  )
}

#let note(input) = {
  box(
    inset: 0.2em,
    radius: 0.2em,
    fill: rgb("#ffffff"),
    stroke: rgb("#0000ff"),
    text(fill: rgb("#0000ff"), weight: "bold", input)
  )
}

#let info(input) = {
  box(
    inset: 0.2em,
    radius: 0.2em,
    fill: rgb("#00ff00"),
    stroke: rgb("#00ff00"),
    text(fill: rgb("#ffffff"), weight: "bold", input)
  )
}

#let XXX = warn("XXX")
#let DELETE = warn("DELETE")
#let WARN = warn("WARN")
#let TODO = note("TODO")
#let NOTE = note("NOTE")
#let INFO = info("INFO")
#let OPTIONAL = info("OPTIONAL")
#let DONE = info("DONE")
