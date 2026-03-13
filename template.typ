#import "./note_for_myself.typ": *
#import "./my_macros.typ": *

#show: article_settings.with(
  section_level: "chapter",

  heading_number_mode: "level3-last",

  title: "title",
  author: "The author",
  date: datetime.today().display(),
  author_page: link("https://www.example.com")[My Homepage],
  version: "1.0.0",
)

#show: no-ref
// = title
// #outline()


== Introduction

This is the Typst version of the original LaTeX `template_section.tex`.

中文测试
the machine has too much delay, i need to replace it with a more powerful one.

为什么是楷体

whatever, it is better than latex's default font.
infinite times.
=== section_level = section

In this mode, section is the highest level and there is usually only one main section.
There is no full title page and no cover image.
All theorem-like environments share one counter, with numbering continuous through the document.

#definition[
  Let $G$ be a group. A subgroup $H subset G$ is normal if $g H g^(-1) = H$ for every $g in G$.
]

#theorem[a great man][
  If $H$ is a subgroup of index $2$ in $G$, then $H$ is normal.
]<thm:normal-subgroup>

#proof[
  #step[
    The left cosets of $H$ partition $G$ into exactly two parts.
  ]<step:cosets>
  #step[
    Every left coset is also a right coset because there are only two cosets.
    Test the typst, it can be 
  ]
  #step[
    Therefore $g H = H g$ for all $g in G$, so $H$ is normal.
  ]
  Hence we finish the proof of @thm:normal-subgroup.
]

#remark[a great man][
  You can switch to `section_level: "chapter"` or `section_level: "book"` in `#show: article_settings.with(...)` to enable a cover page behavior similar to the class file.
  Here i test the ref to the theorem, it is @thm:normal-subgroup.

  // and the ref to the step is @step:cosets.
]



Here we test the ref to step again, it is @step:cosets.
and the ref to the step in the second proof is @step:normal-intersection.

#proposition[
  The intersection of two normal subgroups is normal.
]
#step_reset()
#proof("Solution")[
  let $H_1$ and $H_2$ be normal subgroups of $G$. We want to show that $H_1  H_2$ is normal.
  #step[
    Let $g in G$ and $h in H_1  H_2$. Since $H_1$ is normal, we have $g h g^(-1) in H_1$. Similarly, since $H_2$ is normal, we have $g h g^(-1) in H_2$.
  ]<step:normal-intersection>
  #step[
    Therefore, $g h g^(-1) in H_1  H_2$, proving that $H_1  H_2$ is normal.
  ]
]


#slogan[
  "Mathematics is not about numbers, equations, computations, or algorithms: it is about understanding." - William Paul Thurston
]<slogan:math>

Test command $bb(A)$ $bb(x)$ $cal(T)$ $frak(G)$ $cal(I)$ $cal(J)$ $cal(f)$ $bb(k)$ $cal(hom)$ $scr(M)$ $scr(hom)$ $bb(1)$ $scr(M)$ #cal("I") $cal(I)_i$ #math.cal("I") $cal(T)_M$

Test the ref to the slogan, it is @slogan:math.


#lemma[
  Let $G$ be a group and let $H$ be a subgroup of $G$. If $H$ is normal in $G$, then the quotient group $G/H$ is well-defined.
]
#proof[
  Since $H$ is normal in $G$, we can define the set of left cosets of $H$ in $G$, denoted by $G/H$. The elements of $G/H$ are of the form $g H$ for some $g in G$.
  We can define a binary operation on $G/H$ by $(g H)(h H) = (g h)H$. This operation is well-defined because if $g' in g H$ and $h' in h H$, then $g' = g h_1$ and $h' = h h_2$ for some $h_1, h_2 in H$. Therefore, $(g'H)(h'H) = (g h_1)(h h_2)H = (g h)(h_1 h_2)H = (g h)H$, which shows that the operation is independent of the choice of representatives.
  With this operation, $G/H$ forms a group, called the quotient group of $G$ by $H$. Thus, we have shown that if $H$ is normal in $G$, then the quotient group $G/H$ is well-defined.
  #case[
    If $H$ is the trivial subgroup $\{e\}$, then $G/H$ is isomorphic to $G$ itself, which is a group.
  ]

  #case[
    If $H$ is the whole group $G$, then $G/H$ is the trivial group $\{e\}$, which is a group.
  ]<case:trivial-quotient>

  We have covered all cases, so the proof is complete.
]


Here we test the ref to the case, it is @case:trivial-quotient 2.

Here we test a ref to nothing, it is @case:nonexistent.

#theorem[
  In this theorem, we draw the Castersion diagram of the fiber product of two morphisms $f: X -> Z$ and $g: Y -> Z$ in the category of schemes. The diagram is as follows:
  #align(center)[
    #commutative-diagram(
      node((1,1),$W$),
      node((2,2), $X times_Z Y$),
      node((3,2), $Y$),
      node((2,3), $X$),
      node((3,3), $X$),
      
      arr((1,1),(2,2), $exists !$),
      arr((2,2),(3,2), $p_2$, label-pos: right),
      arr((2,2),(2,3), $p_1$,),
      arr((3,2),(3,3), $g$),
      arr((2,3),(3,3), $f$),
      arr((1,1),(2,3), $h$, label-offset: (0, 2pt)),
      arr((1,1),(3,2), $k$, label-offset: (0, -2pt)),
    )
  ]
  Then I can say that $f:X to Y$.
]


Here is the reference. 
Let me test @Stacks and  @Har77.



= Why I do not use Typst now

+ the syntactic sugar "/" can not be banned. For mathematical documents, we use "/" to denote the quotient (group, space, etc.) and it is very common while the fraction line is not suitable for this purpose. 
+ the indent after a display math is not supported, which is very annoying for a mathematical document.
+ it can't define a new counter for the theorem-like environments
+ it has no support for the symbol "\\varprolim".



#bibliography("ref.bib", style: "ieee")