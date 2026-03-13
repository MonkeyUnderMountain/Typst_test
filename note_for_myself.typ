// noteformyself.typ




//---------------------------------------------------------------------------------
// theorem-like environments and proof environments
//---------------------------------------------------------------------------------
// the package `ctheorems` is used to create theorem-like environments with custom styling
#import "@preview/ctheorems:1.1.3": *

// Define a helper function to create your specific box style
#let my-thm(name, color) = thmbox(
  "theorem", 
  name,
  base: none,
  fill: color.lighten(90%),
  stroke: (
    left: 2pt + color,
    top: none,
    right: none,
    bottom: none,
  ),
  inset: (top: 6pt, left: 8pt, right: 8pt, bottom: 6pt),                  // The "left" and "right" padding
  radius: 0pt,                 // Sharp corners
  padding: (top: 0em, bottom: 0em),
  breakable: true,
  supplement: name
)
// Define a helper function for plain styled environments without background fill
#let my-plain-thm(name, color) = thmbox(
  "theorem", 
  name,
  base: none,
  fill: none,
  stroke: (
    left: 2pt + color,
    top: none,
    right: none,
    bottom: none,
  ),  
  inset: (
    top: 3pt,
    bottom: 3pt,
    left: 8pt,
    right: 8pt,
  ),
  // radius: 0pt,                 // Sharp corners
  padding: (top: 0em, bottom: 0em),
  breakable: true,
  supplement: name
)
// define specific theorem-like environments with different colors
#let definition = my-thm("Definition", blue)
#let proposition = my-thm("Proposition", rgb("#C00040"))
#let theorem = my-thm("Theorem", red)
#let lemma = my-thm("Lemma", orange)
#let corollary = my-thm("Corollary", rgb("#FF00FF"))
#let conjecture = my-thm("Conjecture", rgb("#EE82EE"))
#let question = my-thm("Question", rgb("#D8BFD8"))
// define plain styled environments without background fill
#let remark = my-plain-thm("Remark", rgb("#808000"))
#let claim = my-plain-thm("Claim", orange)
#let example = my-plain-thm("Example", green)
#let exercise = my-plain-thm("Exercise", rgb("#008080"))
#let construction = my-plain-thm("Construction", rgb("#0000FF"))
#let notation = my-plain-thm("Notation", rgb("#191970"))

// the slogan environment is a special case with custom formatting
#let slogan = thmbox(
  "slogan",
  "Slogan",
  fill: green.lighten(90%),
  stroke: 2pt + green,
  radius: 0pt,
  inset: 8pt,
  padding: (top: 0pt, bottom: 0pt),
  bodyfmt: x => emph(x),
  titlefmt: _ => strong("Slogan"),
)

// the `thmproof` environment is used for proofs, with a flexible label and a QED symbol at the end
#let _styled_proof(label) = thmproof(
  "proof",
  label,
  padding: (top: 0pt, bottom: 0pt),
  inset: (top: 3pt, left: 8pt, right: 8pt, bottom: 3pt),
  breakable: true,
  stroke: (
    left: 2pt + rgb("#A7C8C9"),
    top: none,
    right: none,
    bottom: none,
  ),
)
#let proof(..args) = {
  let pos = args.pos()
  if pos.len() == 1 and type(pos.at(0)) == content {
    _styled_proof("Proof")(pos.at(0))
  } else if pos.len() == 2 and type(pos.at(0)) == str and type(pos.at(1)) == content {
    _styled_proof(pos.at(0))(pos.at(1))
  } else {
    panic("Use #proof[...] or #proof(\"Label\")[...]")
  }
}

// Step and Case environment with a reset-able counter and reset function
#let no_num(..args) = []
#let step_counter = counter("step")
#let step_reset() = {
  step_counter.update(0)
}
#let step(body) = thmbox(
  "step",
  [#step_counter.step()
    #context {"Step " + step_counter.display()}],
  base: none,
  stroke: (
    left: 2pt + orange,
    top: none,
    right: none,
    bottom: none,
  ),
  inset: (
    top: 3pt,
    bottom: 3pt,
    left: 8pt,
    right: 8pt,
  ),
  padding: (top: 0em, bottom: 0em),
  breakable: true,
  supplement: "Step",
).with(
  numbering: none,
  refnumbering: no_num,
)(body)

#let case_counter = counter("case")
#let case_reset() = {
  case_counter.update(0)
}
#let case(body) = thmbox(
  "case",
  [#case_counter.step()
    #context {"Case " + case_counter.display()}],
  base: none,
  stroke: (
    left: 2pt + orange,
    top: none,
    right: none,
    bottom: none,
  ),
  inset: (
    top: 3pt,
    bottom: 3pt,
    left: 8pt,
    right: 8pt,
  ),
  padding: (top: 0em, bottom: 0em),
  breakable: true,
  supplement: "Case",
).with(
  numbering: none,
  refnumbering: no_num,
)(body)





// ---------------------------------------------------------------------------------
// The package `commute` is used to draw commutative diagrams, 
//-----------------------------------------------------------------------------------
#import "@preview/commute:0.3.0": node, arr, commutative-diagram




//---------------------------------------------------------------------------------
// reset math fonts with better styling for math environments
//---------------------------------------------------------------------------------
#let cal(body) = {
    set text(font: "STIX Two Math")
    math.cal(body)
}
#let scr(body) = {
    set text(font: "Libertinus Math")
    math.scr(body)
}
#let bb(body) = {
    set text(font: "Libertinus Math")
    math.bb(body)
}











//------------------------------------------------------------------------------
//function to draw title page
//------------------------------------------------------------------------------

#let draw_title_page(title,figure,setence) = {

  //title page setting
  set page(margin: 0em)
  set block(spacing: 0pt)

  // Top band (~25%): sky blue with centered title
  rect(width: 100%, height: 20%, fill: rgb("#94cee5"), stroke: none)[
    #box(width: 80%, height: 100%)[
      #place(left + horizon, dx: 5%)[
        #text(size: 40pt, weight: 750,)[#title]
      ]
    ]
  ]

  // Middle band (~60%): light yellow-gray with image placeholder
  rect(width: 100%, height: 72%, stroke: none, fill: rgb("#e6e1c6"))[
    // central placeholder box for an image
    #place(center + bottom, dy: -5%)[
      #box(width: 60%, height: 60%, fill: rgb("#ffffff"), radius: 8pt, clip: true)[
        #if figure != ""{
          place(center + bottom)[
            #image(figure, width: 100%, height: 100%, fit: "contain")]
        } else {
          place(center + horizon)[
            #stack(
              spacing: 0.5cm,
              text(size: 18pt, fill: rgb("#999999"))[No image provided],
              text(size: 10pt, fill: red)[Warning: image path is empty or missing. Set `title_figure` to a valid path.]
            )
          ]
        }
      ]
    ]

    // right-bottom sentence within the middle band
    #place(right + bottom, dy: -3%, dx: -3%, float: true, scope: "parent")[
        #box(width: 70%)[
          #text(size: 12pt)[#setence]
        ]
    ]
  ]

  // Bottom band (~15%): dark gray
  rect(width: 100%, height: 8%, fill: rgb("#a9a9a9"), stroke: none)[]

  // recover the page style for the rest of the document
  pagebreak()
  set page(margin: 36pt)
} 








//---------------------------------------------------------------------------------
// for bib management, to be completed in the future



#let no-ref(it) = {
  show ref: _ => [[?]]
  it
}









//---------------------------------------------------------------------------------
// The main class wrapper for the document, which can be customized with different section levels and metadata
// The `article_settings` function takes in parameters for section level, title, author, date, author page link, version, and the main body content of the document.
//----------------------------------------------------------------------------------

#let article_settings(
  section_level: "section",

  title: none,
  author: none,
  date: datetime.today().display(),
  author_page: none,
  version: none,
  title_picture: "",
  title_setence: "here is the sentence on the title page, you can set it with `title_setence` parameter.",

  page_paper: "a4",
  page_margin: 36pt,
  font: none,
  font_size: 12pt,
  
  heading_number_mode: "full",

  make_title: true,

  body,

  ref_color: rgb("#C00040"),
  heading_ref_color: rgb("#005F73"),
  equation_ref_color: rgb("#AE2012"),
  cite_color: rgb("#6D597A"),
  external_link_color: rgb("#0A66C2"),
  internal_link_color: rgb("#0077B6"),
) = {
  // Make theorem figure styling active at the document level via the class wrapper.
  show: thmrules.with(qed-symbol: $square$)
  //-- make outline entries link to their location in the document
  show outline.entry: it => link(it.element.location(), it)






  //draw the title page if `make_title` is true and a title is provided
  if make_title and title != none {
    draw_title_page(title, title_picture, title_setence)
  }








  //-- Set up page layout, document metadata, and text styling based on the provided parameters.
  set page(
    paper: page_paper,
    margin: (top: page_margin, bottom: page_margin+ 0.5 * font_size, left: page_margin, right: page_margin),
    footer: context { 
      align(center + top, counter(page).display("1"))
    },
  )
  set document(title: title, author: author)
  set text(size: font_size)
  if font != none and font != "" {
    set text(font: font)
  }
  set par(justify: true, first-line-indent: 2em)









  // Section heading customization (compute sizes first to avoid `set` inside `if`):
  let heading_size_1 = if section_level == "book" or section_level == "chapter" or section_level == "section" {2.1em} 
    else {1.728em}
  let heading_size_2 = if section_level == "book" or section_level == "chapter" or section_level == "section" {1.728em} 
    else {1.44em}
  let heading_size_3 = if section_level == "book" or section_level == "chapter" or section_level == "section" {1.44em} 
    else {1.2em}
  show heading.where(level: 1): set text(
    size: heading_size_1,
    weight: "bold",
    fill: black,
  )
  show heading.where(level: 2): set text(
    size: heading_size_2,
    weight: "bold",
    fill: black,
  )
  show heading.where(level: 3): set text(
    size: heading_size_3,
    weight: "bold",
    fill: black,
  )

  // Number only level-3 headings in section mode.
  // `hanging-indent: 0em` removes leftover prefix spacing on unnumbered levels.
  let heading_numbering = if section_level == "section" {
    (..nums) => {
      let parts = nums.pos()
      if parts.len() == 3 {
        numbering("1.", parts.last())
      } else {
        none
      }
    }
  } else if section_level == "chapter" {
    (..nums) => {
      let parts = nums.pos()
      if parts.len() == 2 {
        numbering("1.", parts.last())
      } else if parts.len() == 3 {
        none
      }
    }
  } else {
    "1."
  }
  set heading(numbering: heading_numbering, hanging-indent: 0em)
















  // Distinguish hyperlinks by semantic kind: refs, citations, and raw links.
  show ref: it => {
    let el = it.element
    if el == none {
      [
        #set text(fill: ref_color)
        #it
      ]
    } else if el.func() == heading {
      [
        #set text(fill: heading_ref_color)
        #it
      ]
    } else if el.func() == math.equation {
      [
        #set text(fill: equation_ref_color)
        #it
      ]
    } else {
      [
        #set text(fill: ref_color)
        #it
      ]
    }
  }
  show cite: it => {
    text(fill: cite_color)[#it]
  }
  show link: it => {
    let is_external = if type(it.dest) == str {
      it.dest.starts-with("http://") or it.dest.starts-with("https://") or it.dest.starts-with("mailto:")
    } else {
      false
    }
    let c = if is_external { external_link_color } else { internal_link_color }
    if is_external {
      text(fill: c)[#underline(it)]
    } else {
      text(fill: c)[#it]
    }
  }
  // remove thm numbering from refs to steps and cases, since they are often used inside proofs and don't need to be numbered globally.
  show ref: it => {
    if it.element == none or it.element.func() != figure or it.element.kind != "thmenv" {
      return it
    }

    let supplement = it.element.supplement
    if it.citation.supplement != none {
      supplement = it.citation.supplement
    }

    let loc = it.element.location()
    let thms = query(selector(<meta:thmenvcounter>).after(loc))
    let number = thmcounters.at(thms.first().location()).at("latest")

    if it.element.numbering == none or it.element.numbering == no_num {
      return link(it.target, [#supplement])
    }

    link(it.target, [#supplement~#numbering(it.element.numbering, ..number)])
  }
  //
  










  //-- Conditionally render the title section if a title is provided, including author metadata as a footnote.
  let author_meta = [
    #author, #h(2pt) #date
    #if author_page != none [ ,#h(2pt) #author_page .
    ]
  ]
  show page: it => {
    let page_number = it.number()
    if page_number == 1 {
      footer[align(left)[small[author_meta]]]
    } else {
      none
    }
  }






  // Set default fonts for the document, with better styling for math environments.
  set text(font: "New Computer Modern")
  show math.equation: set text(font: (
    // 1. force double-struck (bb) letters, symbols, and digits to Libertinus Math
    // (
    //   name: "Libertinus Math",
    //   covers: regex("[\\u{2102}\\u{2115}\\u{2119}-\\u{211D}\\u{2124}\\u{2128}\\u{1D538}-\\u{1D56B}\\u{1D7D8}-\\u{1D7E1}]")
    // ),
    // 2. main font for Latin letters, digits, and common math symbols
    "Cambria Math",
    // 3. fallback for remaining math symbols and broad Unicode coverage
    "New Computer Modern Math",
  ))






  // make the / symbol become the original slash in math mode, instead of a fraction formula. This is useful when you want to write something like "G/H" without it being interpreted as a fraction.
  show math.frac: it => [#it.num #sym.slash #it.denom]








  // Finally, render the main body content of the document.
  body
}