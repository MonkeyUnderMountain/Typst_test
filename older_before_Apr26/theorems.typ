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


