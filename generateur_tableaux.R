library(readr)
library(dplyr)
library(stringi)
library(DT)
library(htmltools)
library(fs)

# Création des dossiers
dir_create("histeco")
dir_create("histeco/tables_html")

# Lecture et nettoyage des données
data <- read_csv("query.csv", na = c("", "NA")) %>%
  filter(!is.na(birthYear), birthYear >= 1790) %>%
  distinct(person, .keep_all = TRUE) %>%
  mutate(
    personLabel = stri_trans_general(personLabel, "Latin-ASCII"),
    countryLabel = stri_trans_general(countryLabel, "Latin-ASCII"),
    employerLabel = stri_trans_general(employerLabel, "Latin-ASCII"),
    genderLabel = stri_trans_general(genderLabel, "Latin-ASCII"),
    period = case_when(
      birthYear >= 1790 & birthYear <= 1849 ~ "1790–1849 : Fondateurs classiques",
      birthYear >= 1850 & birthYear <= 1899 ~ "1850–1899 : Écoles et systèmes",
      birthYear >= 1900 & birthYear <= 1949 ~ "1900–1949 : Institutionnalisation théorique",
      birthYear >= 1950 & birthYear <= 1979 ~ "1950–1979 : Domination néoclassique/keynésienne",
      birthYear >= 1980 & birthYear <= 2020 ~ "1980–2020 : Crise et financiarisation",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(period))

# Corps HTML principal
html_sections <- lapply(unique(data$period), function(p) {
  df <- data %>%
    filter(period == p) %>%
    arrange(birthYear) %>%
    select(Nom = personLabel, Annee = birthYear, Nationalite = countryLabel,
           Genre = genderLabel, Employeur = employerLabel)

  section_id <- gsub("[^a-zA-Z0-9]", "_", p)
  tags$section(id = section_id,
    tags$h2(p),
    datatable(
      df,
      options = list(pageLength = 25, autoWidth = TRUE),
      class = 'compact stripe',
      caption = tags$caption(style = 'caption-side: top; font-weight: bold;', p)
    ),
    tags$p(tags$a(href = "#top", "↑ Retour en haut"))
  )
})

# Structure finale avec navigation
page <- tags$html(
  tags$head(
    tags$title("Économistes par période"),
    tags$style(HTML("
      body { font-family: Arial; margin: 20px; }
      nav ul { list-style: none; padding: 0; display: flex; flex-wrap: wrap; gap: 15px; }
      nav ul li { display: inline; }
      nav ul li a { text-decoration: none; font-weight: bold; }
      section { margin-top: 40px; border-top: 1px solid #ccc; padding-top: 20px; }
    "))
  ),
  tags$body(
    tags$a(name = "top"),
    tags$h1("Tableaux interactifs par période"),
    tags$nav(
      tags$ul(
        lapply(unique(data$period), function(p) {
          link <- paste0("#", gsub("[^a-zA-Z0-9]", "_", p))
          tags$li(tags$a(href = link, p))
        })
      )
    ),
    tagList(html_sections)
  )
)
# Sauvegarde
save_html(page, file = "histeco/index.html")