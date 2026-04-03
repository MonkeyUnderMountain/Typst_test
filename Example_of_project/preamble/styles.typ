
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
  cite_color: rgb("#428ae7"),
  external_link_color: rgb("#f851e7"),
  internal_link_color: rgb("#1803ff"),
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









  // Section heading customization 
  let heading_size_1 = if section_level == "book" {2.1em} 
    else if section_level == "chapter" or section_level == "section" {1.44em}
    else {1.44em}
  let heading_size_2 = if section_level == "book" {1.44em}
    else if section_level == "chapter" or section_level == "section" {1.2em} 
    else {1.2em}
  let heading_size_3 = if section_level == "book" {1.2em} 
    else if section_level == "chapter" or section_level == "section" {1.1em}
    else {1.1em}

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
  } else {
    "1."
  }
  set heading(numbering: heading_numbering, hanging-indent: 0em)

  // define latex-like sectioning commands for user convenience, which will be mapped to the appropriate heading levels based on the `section_level` setting















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
  // show math.frac: it => [#it.num #sym.slash #it.denom]








  // Finally, render the main body content of the document.
  body
}