#let letter(
  lang: "de",
  from-name: none,
  from-street: none,
  from-house-number: none,
  from-postcode: none,
  from-city: none,
  from-phone: none,
  from-email: none,
  bank-iban: none,
  bank-bic: none,
  bank-name: none,
  tax-number: none,
  to-name: none,
  to-department: none,
  to-street: none,
  to-house-number: none,
  to-postcode: none,
  to-city: none,
  subject: none,
  date: none,
  location: none,
  opening: none,
  closing: none,
  ps: none,
  enclosures: none,
  body,
) = {
  let from-address = if from-street != none and from-postcode != none and from-city != none {
    [#from-street #from-house-number, #from-postcode #from-city]
  }
  let to-address = {
    let street-line = if to-street != none {
      [#to-street#if to-house-number != none [ #to-house-number]]
    }
    let city-line = if to-postcode != none or to-city != none {
      [#if to-postcode != none [#to-postcode ]#if to-city != none [#to-city]]
    }
    if street-line != none and city-line != none {
      [#street-line \ #city-line]
    } else if street-line != none {
      street-line
    } else {
      city-line
    }
  }
  let display-place = if location != none { location } else { from-city }
  set page(
    paper: "a4",
    margin: (top: 25mm, bottom: 40mm, left: 25mm, right: 25mm),
    footer: context {
      if from-phone != none or bank-iban != none or tax-number != none {
        line(length: 100%, stroke: 0.5pt + gray)
        set text(size: 8pt, fill: luma(100))
        grid(
          columns: (1fr, 1fr, 1fr),
          gutter: 8mm,
          if from-phone != none {
            [*Kontakt*
            #v(1mm)
            #box(width: 2.5em, align(right)[Tel:]) #h(0.5em) #from-phone
            #if from-email != none [\ #box(width: 2.5em, align(right)[Mail:]) #h(0.5em) #from-email]]
          },
          if bank-iban != none {
            [*Kontodaten*
            #v(1mm)
            #box(width: 3em, align(right)[IBAN:]) #h(0.5em) #bank-iban
            #if bank-bic != none [\ #box(width: 3em, align(right)[BIC:]) #h(0.5em) #bank-bic]
            #if bank-name != none [\ #box(width: 3em, align(right)[Bank:]) #h(0.5em) #bank-name]]
          },
          if tax-number != none {
            [*Steuernummer*
            #v(1mm)
            #tax-number]
          },
        )
      }
    },
  )

  set text(size: 11pt, lang: lang)
  set par(leading: 0.65em)

  // DIN 5008 fold marks (105mm and 210mm from top edge)
  place(top + left, dx: -20mm, dy: 105mm - 25mm, line(length: 5mm, stroke: 0.5pt + luma(200)))
  place(top + left, dx: -20mm, dy: 210mm - 25mm, line(length: 5mm, stroke: 0.5pt + luma(200)))
  // DIN 5008 punch mark (148.5mm from top edge)
  place(top + left, dx: -20mm, dy: 148.5mm - 25mm, line(length: 5mm, stroke: 0.5pt + luma(200)))

  // Sender header
  if from-name != none {
    text(size: 14pt, weight: "bold", from-name)
    linebreak()
    if from-address != none {
      text(size: 9pt, fill: luma(100), from-address)
    }
  }

  // DIN 5008 address field starts at 45mm from top (Form B)
  place(top + left, dy: 45mm - 25mm)[
    #block(width: 85mm, height: 45mm)[
      // Return address zone (5mm, font max 8pt)
      #block(height: 5mm)[
        #if from-name != none [
          #text(size: 8pt, fill: luma(100))[
            #from-name#if from-address != none [ · #from-address]
          ]
        ]
      ]
      // Recipient zone (40mm)
      #block(height: 40mm)[
        #if to-name != none [*#to-name*\ ]
        #if to-department != none [#to-department\ ]
        #if to-address != none [#to-address]
      ]
    ]
  ]

  // Content starts after address field (45mm + 45mm = 90mm from top, plus spacing)
  v(45mm - 25mm + 45mm + 8.46mm)

  // Date
  {
    let format-date(dt, lang) = {
      if lang == "de" {
        let german-months = ("Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember")
        let month-name = german-months.at(dt.month() - 1)
        [#dt.day(). #month-name #dt.year()]
      } else {
        dt.display("[day]. [month repr:long] [year]")
      }
    }
    let display-date = if date != none { date } else { format-date(datetime.today(), lang) }
    align(right)[#if display-place != none [#display-place, ]#display-date]
    v(10mm)
  }

  // Subject
  if subject != none {
    text(weight: "bold", subject)
    v(8mm)
  }

  // Opening
  if opening != none {
    opening
    v(1em)
  }

  // Body
  body

  // Closing
  if closing != none {
    v(2em)
    closing
    v(3cm)
    if from-name != none {
      line(length: 50%, stroke: 0.5pt + gray)
      from-name
    }
  }

  // Postscript
  if ps != none {
    v(1em)
    emph(ps)
  }

  // Enclosures
  if enclosures != none {
    v(1em)
    [*Anlage:* #enclosures]
  }
}

#show: body => letter(
$if(lang)$  lang: "$lang$",$endif$
$if(from-name)$  from-name: [$from-name$],$endif$
$if(from-street)$  from-street: [$from-street$],$endif$
$if(from-house-number)$  from-house-number: [$from-house-number$],$endif$
$if(from-postcode)$  from-postcode: [$from-postcode$],$endif$
$if(from-city)$  from-city: [$from-city$],$endif$
$if(from-phone)$  from-phone: [$from-phone$],$endif$
$if(from-email)$  from-email: [$from-email$],$endif$
$if(bank-iban)$  bank-iban: [$bank-iban$],$endif$
$if(bank-bic)$  bank-bic: [$bank-bic$],$endif$
$if(bank-name)$  bank-name: [$bank-name$],$endif$
$if(tax-number)$  tax-number: [$tax-number$],$endif$
$if(to-name)$  to-name: [$to-name$],$endif$
$if(to-department)$  to-department: [$to-department$],$endif$
$if(to-street)$  to-street: [$to-street$],$endif$
$if(to-house-number)$  to-house-number: [$to-house-number$],$endif$
$if(to-postcode)$  to-postcode: [$to-postcode$],$endif$
$if(to-city)$  to-city: [$to-city$],$endif$
$if(subject)$  subject: [$subject$],$endif$
$if(date)$  date: [$date$],$endif$
$if(location)$  location: [$location$],$endif$
$if(opening)$  opening: [$opening$],$endif$
$if(closing)$  closing: [$closing$],$endif$
$if(ps)$  ps: [$ps$],$endif$
$if(enclosures)$  enclosures: [$enclosures$],$endif$
  body,
)

$body$
