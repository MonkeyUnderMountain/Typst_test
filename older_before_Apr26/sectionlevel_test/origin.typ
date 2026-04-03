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