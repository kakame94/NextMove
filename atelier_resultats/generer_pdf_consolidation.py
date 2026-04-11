#!/usr/bin/env python3
"""
Generateur PDF — Consolidation Atelier JTBD Courtier Immobilier
Genere un document PDF professionnel avec les 9 diagrammes et explications detaillees.
"""

import os
from fpdf import FPDF

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_PDF = os.path.join(BASE_DIR, "Atelier_JTBD_Courtier_Consolidation.pdf")


class AtelierPDF(FPDF):
    def header(self):
        if self.page_no() > 1:
            self.set_font("Helvetica", "I", 8)
            self.set_text_color(120, 120, 120)
            self.cell(0, 8, "Atelier JTBD - Courtier Immobilier - Mars 2026", align="R")
            self.ln(4)

    def footer(self):
        self.set_y(-15)
        self.set_font("Helvetica", "I", 8)
        self.set_text_color(120, 120, 120)
        self.cell(0, 10, f"Page {self.page_no()}/{{nb}}", align="C")

    def section_title(self, num, title):
        self.set_font("Helvetica", "B", 18)
        self.set_text_color(40, 60, 100)
        self.cell(0, 12, f"{num}. {title}", new_x="LMARGIN", new_y="NEXT")
        # Ligne decorative
        self.set_draw_color(40, 60, 100)
        self.set_line_width(0.8)
        self.line(self.l_margin, self.get_y(), self.w - self.r_margin, self.get_y())
        self.ln(6)

    def sub_title(self, text):
        self.set_font("Helvetica", "B", 13)
        self.set_text_color(80, 80, 80)
        self.cell(0, 8, text, new_x="LMARGIN", new_y="NEXT")
        self.ln(2)

    def body_text(self, text):
        self.set_font("Helvetica", "", 10)
        self.set_text_color(50, 50, 50)
        self.multi_cell(0, 5.5, text)
        self.ln(3)

    def bullet(self, text):
        self.set_font("Helvetica", "", 10)
        self.set_text_color(50, 50, 50)
        x = self.get_x()
        self.cell(6, 5.5, "-")
        self.multi_cell(0, 5.5, text)

    def verbatim(self, text):
        self.set_font("Courier", "I", 9)
        self.set_text_color(100, 60, 20)
        self.multi_cell(0, 5, f'"{text}"')
        self.set_font("Helvetica", "", 10)
        self.set_text_color(50, 50, 50)
        self.ln(2)

    def key_insight(self, text):
        self.set_fill_color(245, 240, 225)
        self.set_draw_color(200, 170, 100)
        self.set_font("Helvetica", "B", 10)
        self.set_text_color(100, 70, 20)
        x = self.get_x()
        y = self.get_y()
        self.rect(x, y, self.w - self.l_margin - self.r_margin, 10, style="DF")
        self.set_xy(x + 3, y + 2)
        self.multi_cell(self.w - self.l_margin - self.r_margin - 6, 5.5, f">> {text}")
        self.ln(5)

    def add_image_page(self, img_path, caption=""):
        """Ajoute l'image centree sur la page avec un cadre."""
        if not os.path.exists(img_path):
            return
        self.ln(4)
        img_w = self.w - self.l_margin - self.r_margin - 10
        x = self.l_margin + 5
        # Cadre leger
        self.set_draw_color(180, 180, 180)
        self.set_line_width(0.3)
        y_before = self.get_y()
        self.image(img_path, x=x, w=img_w)
        y_after = self.get_y()
        self.rect(x - 2, y_before - 2, img_w + 4, y_after - y_before + 4)
        if caption:
            self.set_font("Helvetica", "I", 8)
            self.set_text_color(120, 120, 120)
            self.cell(0, 6, caption, align="C", new_x="LMARGIN", new_y="NEXT")
        self.ln(4)


def build_pdf():
    pdf = AtelierPDF(orientation="P", unit="mm", format="A4")
    pdf.alias_nb_pages()
    pdf.set_auto_page_break(auto=True, margin=20)

    # ============================================================
    # PAGE DE COUVERTURE
    # ============================================================
    pdf.add_page()
    pdf.ln(50)
    pdf.set_font("Helvetica", "B", 32)
    pdf.set_text_color(30, 50, 90)
    pdf.cell(0, 15, "Atelier JTBD", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.set_font("Helvetica", "", 20)
    pdf.set_text_color(80, 80, 80)
    pdf.cell(0, 12, "Le Courtier Immobilier", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(8)
    pdf.set_draw_color(40, 60, 100)
    pdf.set_line_width(1)
    pdf.line(60, pdf.get_y(), pdf.w - 60, pdf.get_y())
    pdf.ln(12)
    pdf.set_font("Helvetica", "", 14)
    pdf.set_text_color(100, 100, 100)
    pdf.cell(0, 10, "Resultats consolides de l'atelier", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.cell(0, 10, "Jobs-To-Be-Done (JTBD)", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(6)
    pdf.set_font("Helvetica", "B", 14)
    pdf.set_text_color(40, 60, 100)
    pdf.cell(0, 10, "Mars 2026", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(30)
    pdf.set_font("Helvetica", "", 10)
    pdf.set_text_color(140, 140, 140)
    pdf.cell(0, 8, "9 analyses visuelles detaillees", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.cell(0, 8, "Carte d'empathie | Journee type | Matrice douleurs/gains", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.cell(0, 8, "Forces de progres | Chemin ideal | Segmentation", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.cell(0, 8, "Confort client IA | Arcs narratifs | Vision ideale", align="C", new_x="LMARGIN", new_y="NEXT")

    # ============================================================
    # TABLE DES MATIERES
    # ============================================================
    pdf.add_page()
    pdf.set_font("Helvetica", "B", 22)
    pdf.set_text_color(30, 50, 90)
    pdf.cell(0, 15, "Table des matieres", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(8)

    toc = [
        ("1", "Carte d'Empathie du Courtier Immobilier"),
        ("2", "Journee Type du Courtier"),
        ("3", "Matrice Douleurs / Gains - Priorisation"),
        ("4", "4 Forces de Progres JTBD"),
        ("5", "Chemin Ideal de la Transaction Immobiliere"),
        ("6", "Segmentation - Quoi Automatiser?"),
        ("7", "Confort des Clients avec l'IA"),
        ("8", "Arcs Narratifs JTBD - Histoires de Terrain"),
        ("9", "Baguette Magique - Vision Ideale"),
    ]
    for num, title in toc:
        pdf.set_font("Helvetica", "B", 12)
        pdf.set_text_color(40, 60, 100)
        pdf.cell(10, 9, num + ".")
        pdf.set_font("Helvetica", "", 12)
        pdf.set_text_color(60, 60, 60)
        pdf.cell(0, 9, title, new_x="LMARGIN", new_y="NEXT")

    pdf.ln(15)
    pdf.set_font("Helvetica", "I", 10)
    pdf.set_text_color(100, 100, 100)
    pdf.multi_cell(0, 6, (
        "Ce document consolide les 9 livrables visuels produits lors de l'atelier "
        "Jobs-To-Be-Done (JTBD) mene aupres d'un courtier immobilier etabli au Quebec. "
        "Chaque section presente le diagramme original accompagne d'une analyse detaillee "
        "des constats, verbatims cles et implications pour le developpement d'une solution IA."
    ))

    # ============================================================
    # 1. CARTE D'EMPATHIE
    # ============================================================
    pdf.add_page()
    pdf.section_title("1", "Carte d'Empathie du Courtier Immobilier")

    pdf.sub_title("Description du diagramme")
    pdf.body_text(
        "La carte d'empathie est un outil de design thinking qui permet de se mettre dans la peau "
        "du courtier immobilier. Elle est divisee en 6 zones : ce qu'il PENSE & RESSENT, ce qu'il "
        "VOIT dans son environnement, ce qu'il ENTEND de ses clients et collegues, ce qu'il DIT "
        "publiquement, ce qu'il FAIT concretement, et enfin ses DOULEURS et GAINS."
    )

    pdf.add_image_page(
        os.path.join(BASE_DIR, "01_carte_empathie.png"),
        "Figure 1 - Carte d'empathie du courtier immobilier"
    )

    pdf.sub_title("Analyse detaillee")

    pdf.set_font("Helvetica", "B", 11)
    pdf.set_text_color(60, 60, 60)
    pdf.cell(0, 7, "Pense & Ressent", new_x="LMARGIN", new_y="NEXT")
    pdf.body_text(
        "Le courtier est ambitieux mais realiste. Il sait que pour atteindre 10 transactions/mois, "
        "il lui faudrait un soutien administratif qu'il n'a pas. Sa peur profonde : que le dossier "
        "de financement ne passe pas, apres tout le travail investi. Il observe que la seule "
        "difference entre lui et les courtiers a 40M$/an est la presence d'une equipe admin."
    )

    pdf.set_font("Helvetica", "B", 11)
    pdf.set_text_color(60, 60, 60)
    pdf.cell(0, 7, "Voit & Entend", new_x="LMARGIN", new_y="NEXT")
    pdf.body_text(
        "Il voit Matrix/Centris comme un monopole technologique incontournable mais complexe. "
        "Il voit des equipes structurees qui reussissent. Il entend ses clients se plaindre du "
        "temps de reponse, recoit des appels anxieux a 22h-23h en haute saison (mars), et entend "
        "l'industrie entiere dire qu'il y a beaucoup d'outils mais aucun adapte au courtier."
    )

    pdf.set_font("Helvetica", "B", 11)
    pdf.set_text_color(60, 60, 60)
    pdf.cell(0, 7, "Dit & Fait", new_x="LMARGIN", new_y="NEXT")
    pdf.body_text(
        "Il affirme que son vrai travail est d'expliquer, negocier et visiter, et qu'il "
        "deleguerait TOUT l'administratif s'il le pouvait. En pratique, il travaille seul sans "
        "adjoint, fait tout lui-meme, a documente ses processus (QSE, videos YouTube, guides) "
        "et s'est bati un ecosysteme humain de confiance (courtier hypothecaire, inspecteur, notaire)."
    )

    pdf.set_font("Helvetica", "B", 11)
    pdf.set_text_color(60, 60, 60)
    pdf.cell(0, 7, "Douleurs & Gains", new_x="LMARGIN", new_y="NEXT")
    pdf.body_text(
        "Douleurs principales : temps de reponse trop long, l'admin mange le temps de vente, "
        "Matrix est une usine a gaz, pas de visibilite hypothecaire, 7000$/an en frais obligatoires. "
        "Gains : taux de cloture de 90%, signature electronique adoptee, processus documentes, "
        "reseau de confiance, capacite d'adaptation technologique rapide."
    )

    pdf.key_insight("Le courtier n'est pas en difficulte - il est limite par la capacite admin, pas par la competence terrain.")

    # ============================================================
    # 2. JOURNEE TYPE
    # ============================================================
    pdf.add_page()
    pdf.section_title("2", "Journee Type du Courtier")

    pdf.sub_title("Description du diagramme")
    pdf.body_text(
        "Ce diagramme chronologique illustre une journee type divisee en 5 plages horaires : "
        "Matin tot (7h-9h), Avant-midi (9h-12h), Midi (12h-13h), Apres-midi (13h-18h) et "
        "Soir/Weekend (18h-23h). Trois encadres en bas soulignent les constats cles : les 3 outils "
        "Centris, l'interruption principale (appels banque), et l'absence de journee type fixe."
    )

    pdf.add_image_page(
        os.path.join(BASE_DIR, "02_journee_type.png"),
        "Figure 2 - Journee type du courtier immobilier"
    )

    pdf.sub_title("Analyse detaillee")

    pdf.body_text(
        "Le matin tot (7h-9h), le courtier verifie ses messages sur Centris, consulte Contact "
        "(messagerie) et Prospect (CRM/leads), et ouvre ses dossiers Matrix. C'est un rituel "
        "quotidien de mise a jour."
    )
    pdf.body_text(
        "L'avant-midi (9h-12h) est consacre aux appels clients, suivi de dossiers, relances "
        "aupres de la banque et preparation administrative (documents, formulaires). C'est aussi "
        "le moment de coordination avec le courtier hypothecaire."
    )
    pdf.body_text(
        "L'apres-midi (13h-18h) represente le moment le plus productif : visites de proprietes, "
        "negociations telephoniques, rencontres clients et inspections. C'est le coeur du metier."
    )
    pdf.body_text(
        "Le soir et les weekends (18h-23h) sont marques par les appels de clients anxieux "
        "(surtout en mars, haute saison), les signatures electroniques et les visites pour "
        "les familles qui ne sont disponibles qu'en dehors des heures de bureau."
    )

    pdf.verbatim("Il n'y a pas une journee qui est pareille.")

    pdf.sub_title("Ecosysteme d'outils")
    pdf.body_text(
        "Le courtier utilise 3 outils Centris obligatoires : Matrix (contrats, listings, "
        "signatures, comparables - 1500-1900$/an), Prospect (CRM/leads), et Contact (messagerie "
        "interne, le 'WhatsApp des courtiers'). En parallele, il maintient un ecosysteme humain "
        "(courtier hypothecaire, inspecteur, notaire) sans aucun systeme commun entre eux - "
        "chacun dans son silo, ce qui est un point de friction majeur."
    )

    pdf.key_insight("L'interruption principale qui fait tomber des deals : les appels de derniere minute de la banque en fin de transaction.")

    # ============================================================
    # 3. MATRICE DOULEURS / GAINS
    # ============================================================
    pdf.add_page()
    pdf.section_title("3", "Matrice Douleurs / Gains - Priorisation")

    pdf.sub_title("Description du diagramme")
    pdf.body_text(
        "Cette matrice 2x2 croise deux axes : la FREQUENCE (faible a elevee, axe horizontal) "
        "et l'IMPACT (faible a eleve, axe vertical). Elle classe les douleurs identifiees en "
        "4 quadrants : Priorite #1 (haute frequence + fort impact), Gains Rapides (faible "
        "frequence + fort impact), Bon a Avoir (haute frequence + faible impact), et Ignorer "
        "(faible frequence + faible impact)."
    )

    pdf.add_image_page(
        os.path.join(BASE_DIR, "03_matrice_douleurs_gains.png"),
        "Figure 3 - Matrice douleurs/gains - Priorisation"
    )

    pdf.sub_title("Analyse par quadrant")

    pdf.set_font("Helvetica", "B", 11)
    pdf.set_text_color(180, 50, 50)
    pdf.cell(0, 7, "PRIORITE #1 (haute frequence + fort impact)", new_x="LMARGIN", new_y="NEXT")
    pdf.body_text(
        "Trois douleurs dominent : (1) Le temps de reponse trop long aux clients - quotidien et "
        "bloquant. (2) L'administratif qui mange le temps de vente - quotidien et bloquant. "
        "(3) Le manque de visibilite sur le cote hypothecaire - par transaction et bloquant. "
        "Ces trois elements sont les cibles prioritaires du MVP."
    )

    pdf.set_font("Helvetica", "B", 11)
    pdf.set_text_color(180, 130, 30)
    pdf.cell(0, 7, "GAINS RAPIDES (faible frequence + fort impact)", new_x="LMARGIN", new_y="NEXT")
    pdf.body_text(
        "Perte de deals a cause du financement qui tombe (ponctuel mais bloquant) et clients qui "
        "mentent sur leur situation financiere (irritant par transaction). Ces elements sont moins "
        "frequents mais generent un impact fort quand ils surviennent."
    )

    pdf.set_font("Helvetica", "B", 11)
    pdf.set_text_color(100, 140, 60)
    pdf.cell(0, 7, "BON A AVOIR / IGNORER", new_x="LMARGIN", new_y="NEXT")
    pdf.body_text(
        "Matrix comme usine a gaz et la haute saison ingerable sont des irritants recurrents mais "
        "a impact plus faible. Le blocage du scraping Centris et les 7000$/an en frais obligatoires "
        "sont a ignorer dans le cadre du MVP."
    )

    pdf.sub_title("Resultat du vote par pastilles (3 votes)")
    pdf.body_text(
        "L'admin qui mange le temps de vente : 2 votes. Le manque de visibilite hypothecaire : 1 vote. "
        "Le temps de reponse trop long : 1 vote (hesitation). Conclusion : l'admin et le manque "
        "de visibilite sur le financement sont les 2 douleurs dominantes a adresser en priorite."
    )

    # ============================================================
    # 4. FORCES DE PROGRES JTBD
    # ============================================================
    pdf.add_page()
    pdf.section_title("4", "4 Forces de Progres JTBD")

    pdf.sub_title("Description du diagramme")
    pdf.body_text(
        "Le modele des 4 forces de progres est un outil central du framework JTBD (Jobs-To-Be-Done). "
        "Il evalue 4 forces qui influencent la decision de changer : PUSH (insatisfaction actuelle), "
        "PULL (attraction vers la nouvelle solution), ANXIETE (peurs liees au changement) et "
        "HABITUDE (inertie du statu quo). L'equilibre entre ces forces determine la probabilite "
        "d'adoption."
    )

    pdf.add_image_page(
        os.path.join(BASE_DIR, "04_forces_progres_jtbd.png"),
        "Figure 4 - Les 4 forces de progres JTBD"
    )

    pdf.sub_title("Analyse des forces")

    pdf.set_font("Helvetica", "B", 11)
    pdf.set_text_color(180, 30, 30)
    pdf.cell(0, 7, "PUSH - Insatisfaction actuelle : 10/10 (TRES FORT)", new_x="LMARGIN", new_y="NEXT")
    pdf.body_text(
        "Le courtier fait tout seul sans adjoint. Il sait que 10 transactions/mois le tuerait. "
        "La seule difference avec les courtiers a 40M$ est l'equipe admin. Son plus gros defaut "
        "avoue : le temps de retour. L'insatisfaction est profonde et articulee."
    )

    pdf.set_font("Helvetica", "B", 11)
    pdf.set_text_color(30, 120, 30)
    pdf.cell(0, 7, "PULL - Attraction vers la solution : 10/10 (TRES FORT)", new_x="LMARGIN", new_y="NEXT")
    pdf.body_text(
        "Le courtier a une vision spontanee et precise : 'Si quelqu'un cree une adjointe IA, c'est "
        "fini - tout le monde la prendrait.' Il a deja adopte la e-signature (preuve d'adoption tech). "
        "Il estime que 80-90% des taches de l'assistante sont automatisables. Sa vision : offre "
        "d'achat generee en secondes."
    )

    pdf.set_font("Helvetica", "B", 11)
    pdf.set_text_color(200, 160, 30)
    pdf.cell(0, 7, "ANXIETE - Peurs : 3/10 (FAIBLE)", new_x="LMARGIN", new_y="NEXT")
    pdf.body_text(
        "Le courtier est personnellement ouvert a l'IA. Son inquietude porte sur les clients "
        "frileux (acheteurs, personnes agees), la Loi 25 (protection des donnees), et le fait "
        "que certaines choses peuvent etre compliquees. Mais l'anxiete est faible."
    )

    pdf.set_font("Helvetica", "B", 11)
    pdf.set_text_color(200, 130, 30)
    pdf.cell(0, 7, "HABITUDE - Inertie : 5/10 (MOYEN)", new_x="LMARGIN", new_y="NEXT")
    pdf.body_text(
        "Matrix est un ecosysteme ferme en monopole. Les processus documentes (QSE) sont des "
        "acquis a preserver. L'ecosysteme humain bati (hypothecaire, inspecteur, notaire) et les "
        "contacts de confiance representent une inertie moderee mais contournable."
    )

    pdf.key_insight(
        "VERDICT : TRES PRET A CHANGER. Push + Pull (20/20) >>> Anxiete + Habitude (8/20). "
        "Desequilibre massif en faveur du changement."
    )

    # ============================================================
    # 5. CHEMIN IDEAL
    # ============================================================
    pdf.add_page()
    pdf.section_title("5", "Chemin Ideal de la Transaction Immobiliere")

    pdf.sub_title("Description du diagramme")
    pdf.body_text(
        "Ce diagramme vertical presente les 10 etapes d'une transaction immobiliere (de 0 a 9) "
        "avec un code couleur indiquant le niveau d'automatisation possible : vert = IA "
        "(automatisable), orange = MIXTE (IA + humain), rouge = COURTIER (obligation legale). "
        "Chaque etape inclut le responsable et un verbatim du courtier."
    )

    pdf.add_image_page(
        os.path.join(BASE_DIR, "05_chemin_ideal_transaction.png"),
        "Figure 5 - Chemin ideal de la transaction immobiliere"
    )

    pdf.sub_title("Les 10 etapes detaillees")

    etapes = [
        ("[0] Marketing / Reference", "IA", "L'IA peut repondre aux premiers messages. Tout vient par reference, pas de prospection active."),
        ("[1] Premier Contact + Collecte", "IA", "Collecte des informations client (nom, adresse, type de bien, situation financiere). 80-90% automatisable."),
        ("[2] Qualification Hypothecaire", "MIXTE", "Pont avec le courtier hypothecaire, verification pre-qualification. C'est le 'trou noir' actuel."),
        ("[3] Planification Visites", "IA", "Gestion du calendrier, calcul temps de deplacement, optimisation des trajets entre visites."),
        ("[4] Visites", "COURTIER", "Obligation legale de presence physique (OACIQ). La loi ne permet pas de deleguer."),
        ("[5] Comparables + Analyse", "IA", "Analyse de marche dans Matrix. 'Les comparables c'est mecanique - l'IA peut faire ca.'"),
        ("[6] Offre d'Achat", "MIXTE", "L'IA genere l'offre, le courtier valide et negocie. Vision : offre generee en secondes."),
        ("[7] Inspection", "MIXTE", "IA/Assistante planifie, courtier negocie si problemes. Coordination avec inspecteur de confiance."),
        ("[8] Suivi Financement", "MIXTE", "Visibilite sur dossier hypotheque, anticipation des blocages. 'On perd des deals.'"),
        ("[9] Cloture", "COURTIER", "Documents finaux et signature chez le notaire. E-signature en 2-3 minutes."),
    ]
    for etape, resp, desc in etapes:
        pdf.set_font("Helvetica", "B", 10)
        color = (30, 130, 30) if resp == "IA" else (200, 130, 30) if resp == "MIXTE" else (180, 50, 50)
        pdf.set_text_color(*color)
        pdf.cell(0, 6, f"{etape} [{resp}]", new_x="LMARGIN", new_y="NEXT")
        pdf.set_font("Helvetica", "", 9)
        pdf.set_text_color(60, 60, 60)
        pdf.multi_cell(0, 4.5, desc)
        pdf.ln(1)

    pdf.key_insight("80% du parcours peut etre assiste ou automatise par IA. Seules les visites et la cloture notariale restent 100% humaines (contrainte legale OACIQ).")

    # ============================================================
    # 6. SEGMENTATION AUTOMATISATION
    # ============================================================
    pdf.add_page()
    pdf.section_title("6", "Segmentation - Quoi Automatiser?")

    pdf.sub_title("Description du diagramme")
    pdf.body_text(
        "Ce diagramme en 4 quadrants classe les taches selon deux axes : la valeur d'automatisation "
        "(verticale) et le risque/sensibilite (horizontal). Quatre zones : A AUTOMATISER (priorite), "
        "BON A AVOIR (souhaitable), ZONE GRISE (a evaluer selon le client) et NE PAS TOUCHER "
        "(contraintes legales ou confort client)."
    )

    pdf.add_image_page(
        os.path.join(BASE_DIR, "06_segmentation_automatisation.png"),
        "Figure 6 - Segmentation : quoi automatiser?"
    )

    pdf.sub_title("A AUTOMATISER (priorite)")
    pdf.body_text(
        "8 taches identifiees comme prioritaires : generation d'offres d'achat, collecte de documents "
        "client, suivi hypotheque, relances documents manquants, planification des visites, "
        "comparables de marche, reponse aux premiers messages et classement de documents."
    )

    pdf.sub_title("NE PAS TOUCHER (contraintes legales)")
    pdf.body_text(
        "4 activites intouchables : visites de proprietes (obligation legale OACIQ), signatures "
        "de documents legaux, rencontres client en personne et negociations sensibles."
    )

    pdf.sub_title("ZONE GRISE (a evaluer)")
    pdf.body_text(
        "5 activites qui dependent du profil client : communication IA avec acheteurs frileux, "
        "suivi post-visite par IA, appels aux personnes agees, premier contact telephonique. "
        "La strategie doit s'adapter au segment client (voir section 7)."
    )

    pdf.sub_title("Planification des sprints")
    pdf.body_text(
        "Sprint 1 : Recuperer infos client + relances documents + premier contact. "
        "Sprint 2 : Classement docs + pont hypothecaire + planification visites + preparation dossiers. "
        "Sprint 3 : Generation offres d'achat + comparables (integration Matrix)."
    )

    # ============================================================
    # 7. CONFORT CLIENT IA
    # ============================================================
    pdf.add_page()
    pdf.section_title("7", "Confort des Clients avec l'IA")

    pdf.sub_title("Description du diagramme")
    pdf.body_text(
        "Ce graphique en barres horizontales presente le niveau de confort avec l'IA pour "
        "4 segments clients identifies, de 10% (personnes agees) a 90% (investisseurs/a distance). "
        "Chaque barre est accompagnee de la strategie IA recommandee pour ce segment."
    )

    pdf.add_image_page(
        os.path.join(BASE_DIR, "07_confort_client_ia.png"),
        "Figure 7 - Confort des clients avec l'IA par segment"
    )

    pdf.sub_title("Analyse par segment")

    segments = [
        ("Investisseurs / a distance (90%)", "Contact IA direct OK",
         "Deja habitues au virtuel, e-signature adoptee. Automatisation complete - l'IA gere le contact direct."),
        ("Vendeurs (60%)", "IA en arriere-plan",
         "Moins sensibles car ils vendent (pas de stress d'achat). IA pour le suivi et les rappels, contact humain pour decisions."),
        ("Premiers acheteurs / public (30%)", "IA invisible",
         "Beaucoup sont encore tres frileux. Anxiete d'achat elevee (surtout mars). Appels a 22h-23h, veulent parler a un humain."),
        ("Personnes agees (10%)", "Aucune IA visible, 100% humain",
         "Beaucoup d'interdiction, pas a l'aise avec la technologie. Zero IA visible, tout passe par l'humain."),
    ]
    for title, strategy, desc in segments:
        pdf.set_font("Helvetica", "B", 10)
        pdf.set_text_color(40, 60, 100)
        pdf.cell(0, 6, f"{title} - Strategie : {strategy}", new_x="LMARGIN", new_y="NEXT")
        pdf.body_text(desc)

    pdf.key_insight("REGLE DE CONCEPTION : L'IA automatise l'ARRIERE-BOUTIQUE (invisible au client). Le contact client reste humain sauf pour les segments confortables.")

    # ============================================================
    # 8. ARCS NARRATIFS
    # ============================================================
    pdf.add_page()
    pdf.section_title("8", "Arcs Narratifs JTBD - Histoires de Terrain")

    pdf.sub_title("Description du diagramme")
    pdf.body_text(
        "Ce diagramme presente 3 arcs narratifs tires de l'experience du courtier : deux "
        "transactions perdues (hypotheque et inspection) et un changement reussi (e-signature). "
        "Chaque arc suit un flux Declencheur -> Probleme/Solution -> Consequence/Resultat, "
        "avec identification de la cause racine."
    )

    pdf.add_image_page(
        os.path.join(BASE_DIR, "08_arcs_narratifs_jtbd.png"),
        "Figure 8 - Arcs narratifs JTBD"
    )

    pdf.sub_title("Arc 1 : Transaction Perdue - Hypotheque")
    pdf.body_text(
        "Un client refere arrive avec un courtier hypothecaire externe. Le courtier immobilier "
        "n'a aucune visibilite sur le dossier hypothecaire. Le courtier hypothecaire ne fait pas "
        "son travail correctement. Resultat : transaction perdue."
    )
    pdf.verbatim("J'avais pas de controle sur la personne qui faisait l'hypotheque de ce client-la.")
    pdf.body_text(
        "L'analyse des 5 Pourquoi revele la cause racine : il n'existe aucun systeme commun entre "
        "courtier immobilier et courtier hypothecaire. Le vrai probleme est le manque de visibilite "
        "transversale sur l'ecosysteme de la transaction."
    )

    pdf.sub_title("Arc 2 : Transaction Perdue - Inspection")
    pdf.body_text(
        "L'inspection revele de la moisissure. L'inspecteur indique que c'est corrigeable, mais "
        "le vendeur refuse categoriquement de negocier. Retrait de l'offre, transaction perdue. "
        "Cause racine : manque de preparation en amont (comparables, historique du bien) pour "
        "armer le courtier de donnees objectives en negociation."
    )

    pdf.sub_title("Arc 3 : Changement Reussi - E-Signature")
    pdf.body_text(
        "Arc positif qui demontre que le courtier adopte la technologie quand 3 conditions sont "
        "reunies : (1) la valeur est evidente (gain de temps concret), (2) le benefice est "
        "immediat (pas de courbe d'apprentissage longue), (3) le probleme resolu est reel "
        "(clients a distance = bloquant sans solution). La e-signature a tout change : "
        "'tout se fait en virtuel, 2-3 minutes.'"
    )

    pdf.key_insight("Le MVP doit offrir un suivi transversal immo + hypothecaire et suivre le modele d'adoption de la e-signature : valeur evidente + immediat = adoption garantie.")

    # ============================================================
    # 9. BAGUETTE MAGIQUE
    # ============================================================
    pdf.add_page()
    pdf.section_title("9", "Baguette Magique - Vision Ideale")

    pdf.sub_title("Description du diagramme")
    pdf.body_text(
        "Ce diagramme final capture la vision ideale du courtier ('si j'avais une baguette magique'). "
        "Il presente le flux de travail reve (visite -> offre generee par IA -> signature electronique "
        "-> quelques secondes au lieu de 30-60 min) et une comparaison Aujourd'hui vs Demain (avec IA)."
    )

    pdf.add_image_page(
        os.path.join(BASE_DIR, "09_baguette_magique_vision.png"),
        "Figure 9 - Baguette Magique : vision ideale du courtier"
    )

    pdf.sub_title("Le flux de travail reve")
    pdf.verbatim(
        "Si une IA peut juste generer une offre d'achat en un rien de temps - clic, tu as deja "
        "ton fichier client, son nom, photo, tout le tralala..."
    )
    pdf.body_text(
        "Aujourd'hui : visite terminee -> retour au bureau -> ouvrir fichiers -> copier-coller -> "
        "rediger -> envoyer = 30 a 60 minutes. Demain : 'Fais-moi une offre de tel client pour "
        "telle maison' -> pret en quelques secondes."
    )

    pdf.sub_title("Agent IA = Adjointe Administrative 24/7")
    pdf.body_text(
        "Le courtier envisage un agent IA qui remplacerait 80-90% des taches d'une assistante : "
        "gestion des dossiers (fichier client, fiche Matrix, historique), generation de documents "
        "(offres d'achat, contre-offres), et suivi des clients (rappels, follow-ups, calendrier). "
        "Disponible 24/7, y compris a 22h-23h en haute saison."
    )

    pdf.sub_title("Comparaison des couts")
    pdf.body_text(
        "Agent IA : 35-50$/mois, disponible 24/7. Assistante a distance : 400-500$/mois, heures "
        "de bureau. Assistante Quebec temps plein : 2500-3000$/mois, heures de bureau. Le rapport "
        "cout/benefice est massivement en faveur de l'IA."
    )

    pdf.sub_title("Ce que le courtier ferait avec le temps libere")
    pdf.body_text(
        "Plus de visites (moment le plus productif), plus de volume (objectif 10+ transactions/mois), "
        "ouvrir sa propre agence, et se concentrer sur ce qu'il aime : expliquer, negocier, visiter. "
        "L'IA ne remplace pas le courtier - elle le libere pour qu'il fasse davantage ce qui "
        "genere de la valeur."
    )

    pdf.key_insight("La peur profonde du courtier : 'Que le dossier ne passe pas.' Cela confirme que le probleme #1 du MVP est la visibilite transversale sur l'ensemble de la transaction.")

    # ============================================================
    # PAGE DE CONCLUSION
    # ============================================================
    pdf.add_page()
    pdf.ln(10)
    pdf.set_font("Helvetica", "B", 22)
    pdf.set_text_color(30, 50, 90)
    pdf.cell(0, 15, "Synthese et Prochaines Etapes", align="C", new_x="LMARGIN", new_y="NEXT")
    pdf.ln(8)
    pdf.set_draw_color(40, 60, 100)
    pdf.set_line_width(0.8)
    pdf.line(50, pdf.get_y(), pdf.w - 50, pdf.get_y())
    pdf.ln(10)

    pdf.sub_title("Constats principaux de l'atelier")
    items = [
        "Le courtier est TRES PRET a changer (Push+Pull 20/20 vs Anxiete+Habitude 8/20).",
        "L'admin est le goulot d'etranglement #1 - pas la competence terrain.",
        "80% du parcours transactionnel peut etre assiste ou automatise par IA.",
        "La visibilite transversale (immo + hypothecaire) est le besoin critique.",
        "L'IA doit etre INVISIBLE au client (sauf investisseurs) - arriere-boutique.",
        "Le modele de la e-signature montre que l'adoption est garantie si la valeur est evidente et immediate.",
    ]
    for item in items:
        pdf.bullet(item)
        pdf.ln(1)

    pdf.ln(5)
    pdf.sub_title("Priorites MVP recommandees")
    mvp = [
        "Sprint 1 : Collecte info client + relances documents + reponse premier contact.",
        "Sprint 2 : Pont hypothecaire + planification visites + classement documents.",
        "Sprint 3 : Generation offres d'achat + comparables (integration Matrix).",
    ]
    for item in mvp:
        pdf.bullet(item)
        pdf.ln(1)

    pdf.ln(8)
    pdf.set_font("Helvetica", "I", 10)
    pdf.set_text_color(120, 120, 120)
    pdf.cell(0, 8, "Document genere a partir des resultats de l'atelier JTBD - Mars 2026", align="C", new_x="LMARGIN", new_y="NEXT")

    # ============================================================
    # EXPORT
    # ============================================================
    pdf.output(OUTPUT_PDF)
    print(f"PDF genere avec succes : {OUTPUT_PDF}")
    print(f"Nombre de pages : {pdf.page_no()}")


if __name__ == "__main__":
    build_pdf()
