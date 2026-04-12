# Recherche : Humanisation IA Conversationnelle — SMS Immobilier QC

**Source :** Recherche interne NextMove Inc.
**Date :** Avril 2026
**Sujet :** Strategies d'Ingenierie de Requetes pour l'Humanisation des Assistants Virtuels

---

## Insights cles pour le prompt systeme

### 1. Adjective Latching (Accrochage adjectival)
Les LLM souffrent d'un phenomene ou un adjectif de ton ("chaleureux", "amical") est exagere exponentiellement. Dire "sois gentille" produit des textes de parc d'attractions. **Solution :** Decrire des contraintes physiques, pas des adjectifs. "Tu tapes vite sur ton telephone entre deux rendez-vous" > "Sois concise".

### 2. Contraintes negatives = contre-productif
Dire "n'utilise pas d'emojis" ACTIVE les poids neuronaux associes aux emojis. **Solution :** Substitution comportementale. "Limite les emojis a 1 fonctionnel par message (📅 pour un RDV)" > "Pas d'emojis".

### 3. Hyperparametres critiques
| Parametre | Valeur | Pourquoi |
|-----------|--------|----------|
| Temperature | 0.3-0.4 | Limite les exuberances lexicales tout en gardant le naturel |
| Frequency Penalty | 0.4-0.6 | Force la variation lexicale, elimine "Parfait!" repetitif |
| Presence Penalty | 0.2-0.3 | Pousse la conversation vers l'action, evite les boucles d'empathie |
| Top-p | 0.9 | Maintient l'acces au registre vernaculaire QC |

### 4. Persona Pattern > adjectifs
Definir un monde operationnel complet : "Tu es une adjointe SENIOR avec 10 ans d'experience, ton temps est precieux, tu geres un volume eleve de dossiers" → justifie cognitivement la concision.

### 5. Normes OQLF (redaction inclusive)
- JAMAIS de point median (client·e·s) — proscrit par l'OQLF
- Privilegier les termes epicenes : "la clientele", "le personnel"
- Parentheses acceptables : "un(e) client(e)"

### 6. Matrice Chaleur-Competence
L'exces de chaleur DIMINUE la perception de competence. L'objectif n'est pas de maximiser la chaleur mais de calibrer pour projeter une competence tranquille avec une chaleur implicite.

### 7. SMS comme medium hybride
Le SMS fusionne oralite et code ecrit. Variables morphosyntaxiques QC :
- "on" > "nous" (proximite naturelle)
- Ponctuation = prosodie (le point final = calme et controle)
- Variation de longueur = rythme humain

---

## Document complet

Le document de recherche complet (9 sections, ~5000 mots) couvre :
1. Introduction et problematique de l'IA conversationnelle
2. Stylometrie et psycholinguistique (AI Slop)
3. Sociolinguistique du francais quebecois par texto
4. Cadre reglementaire OACIQ et Loi 25
5. Ingenierie de requetes : methodologies avancees
6. Analyse critique du prompt systeme
7. Architecture du prompt optimise
8. Recommandations hyperparametriques
9. Conclusion

Disponible en interne sur demande.
