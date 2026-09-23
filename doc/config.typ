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
    stroke: rgb("#B71C1C"),
    text(fill: rgb("#B71C1C"), weight: "bold", input)
  )
}

#let todo(input) = {
  box(
    inset: 0.2em,
    radius: 0.2em,
    fill: rgb("#ffffff"),
    stroke: rgb("#283593"),
    text(fill: rgb("#283593"), weight: "bold", input)
  )
}

#let info(input) = {
  box(
    inset: 0.2em,
    radius: 0.2em,
    fill: rgb("#33691E"),
    stroke: rgb("#33691E"),
    text(fill: rgb("#ffffff"), weight: "bold", input)
  )
}

#let cool(input) = {
  box(
    inset: 0.2em,
    radius: 0.2em,
    fill: rgb("#2196F3"),
    stroke: rgb("#2196F3"),
    text(fill: rgb("#ffffff"), weight: "bold", input)
  )
}

#let high(input) = {
  box(
    inset: 0.2em,
    radius: 0.2em,
    fill: rgb("#EC407A"),
    stroke: rgb("#EC407A"),
    text(fill: rgb("#ffffff"), weight: "bold", input)
  )
}

#let DELETE = warn("DELETE")
#let WARN = warn("WARN")
#let TODO = todo("TODO")
#let INFO = info("INFO")
#let OPTIONAL = info("OPTIONAL")
#let DONE = info("DONE")
#let FAV = high("FAV")
#let COOL = cool("COOL")

