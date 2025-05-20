
# Histeco – Analyse exploratoire des économistes français et belges via Wikidata

Cette missive présente une interface interactive qui recense les économistes belges et français nés après 1789 à partir des données disponibles sur Wikidata. Il s'agit d'une analyse exploratoire menée  suite à ma lecture rapide du travail de **Heckman & Moktan (2018)**, centré sur les revues du Top 5 américain.

## 🎯 potentiels objectifs

- Réaliser une **analyse robuste** des trajectoires académiques d’économistes francophones et belges.
- Encourager une **réplication** du travail **Heckman & Moktan (2018)**
- Proposer une **cartographie temporelle** des économistes à partir d'une périodisation bien connue de l’histoire des pensées en sciences économiques.

## 🔍 Données & Requête SPARQL

Les données ont été extraites via [Wikidata](https://query.wikidata.org/) à l'aide de la requête SPARQL suivante :

```sparql
PREFIX wd: <http://www.wikidata.org/entity/>
PREFIX wdt: <http://www.wikidata.org/prop/direct/>
PREFIX schema: <http://schema.org/>

SELECT ?person ?personLabel ?birthYear ?countryLabel ?employerLabel ?genderLabel ?article WHERE {
  VALUES ?country { wd:Q31 wd:Q142 }  # Q31 = Belgique, Q142 = France

  ?person wdt:P106 wd:Q188094;
          wdt:P27 ?country;
          wdt:P569 ?birthDate;
          wdt:P21 ?gender.

  OPTIONAL { ?person wdt:P108 ?employer. }
  OPTIONAL {
    ?article schema:about ?person;
             schema:inLanguage "fr";
             schema:isPartOf <https://fr.wikipedia.org/>.
  }
  OPTIONAL {
    ?articleEn schema:about ?person;
               schema:inLanguage "en";
               schema:isPartOf <https://en.wikipedia.org/>.
  }

  BIND(YEAR(?birthDate) AS ?birthYear)
  BIND(COALESCE(?article, ?articleEn) AS ?article)

  SERVICE wikibase:label {
    bd:serviceParam wikibase:language "fr,en".
  }
}
ORDER BY DESC(?birthYear)
```

## 🧠 Périodisation : une lecture schumpétérienne

La classification temporelle est inspirée de la **périodisation de l’histoire de la pensée économique** proposée par **Joseph Schumpeter** dans son ouvrage posthume _History of Economic Analysis_, publié par sa femme en 1954. Chaque période reflète un moment structurant du discours économique, en lien avec les mutations institutionnelles du champ scientifique.

| Période | Orientation dominante |
|--------|------------------------|
| 1790–1849 | Fondateurs classiques |
| 1850–1899 | Écoles & systèmes (marginalisme, historicisme) |
| 1900–1949 | Institutionnalisation théorique (Keynes, Marshall) |
| 1950–1979 | Domination néoclassique / keynésienne |
| 1980–2020 | Crise et financiarisation |

🎧 Pour une introduction accessible à cette histoire, voir le podcast France Culture :  
[Entendez-vous l’éco ? — émission du 15 mai 2025](https://www.radiofrance.fr/franceculture/podcasts/entendez-vous-l-eco/entendez-vous-l-eco-emission-du-jeudi-15-mai-2025-8472991)

## 📁 Structure du projet

- `index.html` : page interactive avec navigation par période
- `generateur_tableaux.R` : script R complet pour générer le site
- `tables_html/` : tableaux dynamiques par période
- `svg_tables/` *(en option)* : versions statiques des tableaux (format SVG)

## 🚧 Piste pour les 6 mois à venir

1. **Élargissement de l’échantillon** : inclure les économistes allemands, italiens, espagnols, néerlandais.
2. **Annotation manuelle** de la typologie des publications pour chaque économiste (revues, affiliations, trajectoires).
3. **Construction d’un réseau** de co-affiliation ou de mentorat à partir de Wikidata et d'interviews.
4. **Régression logistique** sur la probabilité de publication dans une revue prestigieuse selon le genre, la nationalité, le type d’institution.
5. **Comparaison directe** avec les données des revues du Top 5 utilisées par Heckman & Moktan.

## 📜 Licence

Projet à visée exploratoire, ouvert et libre d’utilisation pour tout projet de recherche collaboratif.
