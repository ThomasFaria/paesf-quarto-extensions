# Format publications PAESF

Extension Quarto pour les publications du Pôle d'analyse économique du secteur financier (DGT).
Fournit deux formats : `paesf-typst` (PDF) et `paesf-html` (site DSFR).

## Installation

```bash
quarto use template thomasfaria/paesf-quarto-extensions
```

Cela installera l'extension et créera un fichier `qmd` qui servira de base de rédaction.

## Ajouter à un projet existant

Depuis la racine du projet Quarto, exécuter :

```bash
quarto add thomasfaria/paesf-quarto-extensions
```

## Formats disponibles

| Format | Sortie | Usage |
|---|---|---|
| `paesf-typst` | PDF | BLS, Flash, Veille financière |
| `paesf-html` | Site web DSFR | Flash Financement de l'Économie |

## Usage PDF (Typst)

Dans le YAML du document :

```yaml
format:
  paesf-typst:
    papersize: a4
    margin:
      x: 1.5cm
      y: 1cm
    fontsize: 10pt
    output-file: "mon-rapport.pdf"
```

Ou en ligne de commande :

```bash
quarto render article.qmd --to paesf-typst
```

## Usage HTML (DSFR)

```yaml
format:
  paesf-html: default
```

## Métadonnées spécifiques

Ces champs apparaissent dans l'en-tête du document PDF :

```yaml
metadata:
  title: "Titre du rapport"
  subtitle: "Sous-titre (optionnel)"
  direction: "Direction générale du Trésor"
  bureau: "Pôle d'analyse économique du secteur financier"
  number: "Avril 2026 - n°XXX"
```

## Éléments spéciaux

### Encadré

```markdown
::: encadre
- Point clé 1
- Point clé 2
:::
```

### Titre de section secondaire

```markdown
## Mon titre {.titre-section}
```
