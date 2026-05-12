// --- FUNZIONE 1: Impostazioni Generali del Documento ---
#let project(body) = {
  set document(author: "Mario Rossi", title: "Log Sviluppo Settimanale")
  
  set page(
    paper: "a4",
    margin: (x: 2cm, y: 2.5cm),
    footer: context {
      set text(8pt, fill: gray)
      line(length: 100%, stroke: 0.5pt + gray)
      align(center)[Pagina #counter(page).display()]
    }
  )
  
  set text(font: "Linux Libertine", lang: "it", size: 11pt)
  set heading(numbering: "1.")
  
  body
}

// --- FUNZIONE 2: Layout della Settimana ---
#let week_log(
  week_num, 
  date_range, 
  lun: (), mar: (), mer: (), gio: (), ven: (), 
  notes: ""
) = {
  page(header: none, footer: none)[
    #align(center)[
      #image("unipd.png", width: 8cm) 
      
      #v(2cm)
      #text(26pt, weight: "bold")[Settimana #week_num] \
      #text(18pt, gray)[#date_range]
      
      #v(2cm)
      
      #grid(
        columns: (1fr),
        gutter: 1.5em,
        text(14pt)[*Studente:* Amerigo Vegliante],
        text(14pt)[*Matricola*: 2111004],
        v(1em),
        text(14pt)[*Università degli Studi di Padova - Dipartimento di Matematica "Tullio Levi-Civita"*],
        text(14pt)[*Tutor Interno*: Prof. Nicolò Navarin],
      )
      
      #align(bottom)[
        #line(length: 100%, stroke: 0.5pt)
        #text(10pt, gray)[Diario di Bordo Tirocinio - Università degli Studi di Padova]
      ]
    ]
  ]

  text(16pt)[*Dettaglio Attività*]
  v(1em)

  let day_section(name, tasks) = {
    if tasks.len() > 0 {
      [*#name*]
      for task in tasks {
        [- #task]
      }
      v(0.5em)
    }
  }

  day_section("Lunedì", lun)
  day_section("Martedì", mar)
  day_section("Mercoledì", mer)
  day_section("Giovedì", gio)
  day_section("Venerdì", ven)

  if notes != "" {
    v(1em)
    block(
      fill: rgb("#f8f8f8"),
      inset: 12pt,
      radius: 4pt,
      width: 100%,
      stroke: 0.5pt + luma(200),
      [*Problemi Riscontrati:* \ #notes]
    )
  }
  
  pagebreak(weak: true)
}