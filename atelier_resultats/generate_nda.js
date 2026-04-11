const fs = require("fs");
const {
  Document, Packer, Paragraph, TextRun, AlignmentType,
  HeadingLevel, BorderStyle, TabStopType, TabStopPosition,
  Header, Footer, PageNumber, LevelFormat
} = require("docx");

const today = new Date().toLocaleDateString("fr-CA", { year: "numeric", month: "long", day: "numeric" });

// Helpers
const empty = () => new Paragraph({ spacing: { after: 100 }, children: [] });
const bold = (t) => new TextRun({ text: t, bold: true, font: "Arial", size: 22 });
const normal = (t) => new TextRun({ text: t, font: "Arial", size: 22 });
const italic = (t) => new TextRun({ text: t, italics: true, font: "Arial", size: 22 });
const underline = (t) => new TextRun({ text: t, bold: true, underline: { type: "single" }, font: "Arial", size: 22 });
const blank = () => new TextRun({ text: "________________________", font: "Arial", size: 22 });

function para(children, opts = {}) {
  return new Paragraph({
    alignment: opts.align || AlignmentType.JUSTIFIED,
    spacing: { after: opts.after || 160, line: opts.line || 276 },
    indent: opts.indent ? { left: opts.indent } : undefined,
    children: Array.isArray(children) ? children : [normal(children)],
  });
}

function heading(text, level) {
  return new Paragraph({
    alignment: AlignmentType.LEFT,
    spacing: { before: 360, after: 200 },
    children: [new TextRun({ text, bold: true, font: "Arial", size: level === 1 ? 28 : 24, allCaps: level === 1 })],
  });
}

function bulletItem(text, opts = {}) {
  return new Paragraph({
    numbering: { reference: "bullets", level: 0 },
    spacing: { after: 100, line: 276 },
    alignment: AlignmentType.JUSTIFIED,
    children: [normal(text)],
  });
}

const doc = new Document({
  numbering: {
    config: [{
      reference: "bullets",
      levels: [{
        level: 0,
        format: LevelFormat.BULLET,
        text: "\u2022",
        alignment: AlignmentType.LEFT,
        style: { paragraph: { indent: { left: 720, hanging: 360 } } },
      }],
    }],
  },
  styles: {
    default: {
      document: { run: { font: "Arial", size: 22 } },
    },
  },
  sections: [{
    properties: {
      page: {
        size: { width: 12240, height: 15840 },
        margin: { top: 1440, right: 1296, bottom: 1296, left: 1296 },
      },
    },
    headers: {
      default: new Header({
        children: [new Paragraph({
          alignment: AlignmentType.RIGHT,
          children: [new TextRun({ text: "CONFIDENTIEL \u2014 NDA NextMove Inc. / Joanel Dupart", font: "Arial", size: 16, color: "888888", italics: true })],
        })],
      }),
    },
    footers: {
      default: new Footer({
        children: [new Paragraph({
          alignment: AlignmentType.CENTER,
          children: [
            new TextRun({ text: "Page ", font: "Arial", size: 16, color: "888888" }),
            new TextRun({ children: [PageNumber.CURRENT], font: "Arial", size: 16, color: "888888" }),
            new TextRun({ text: " / ", font: "Arial", size: 16, color: "888888" }),
            new TextRun({ children: [PageNumber.TOTAL_PAGES], font: "Arial", size: 16, color: "888888" }),
          ],
        })],
      }),
    },
    children: [
      // ===== TITLE =====
      new Paragraph({
        alignment: AlignmentType.CENTER,
        spacing: { after: 80 },
        children: [new TextRun({ text: "ACCORD DE CONFIDENTIALIT\u00C9 / NDA", bold: true, font: "Arial", size: 32 })],
      }),
      new Paragraph({
        alignment: AlignmentType.CENTER,
        spacing: { after: 400 },
        border: { bottom: { style: BorderStyle.SINGLE, size: 6, color: "2E75B6", space: 1 } },
        children: [new TextRun({ text: "Projet : Adjointe IA du Courtier Immobilier", font: "Arial", size: 22, color: "2E75B6", italics: true })],
      }),

      // ===== PREAMBLE =====
      para([normal("Le pr\u00E9sent Accord de Confidentialit\u00E9 (le \u00AB "), bold("Contrat"), normal(" \u00BB) est conclu")]),
      empty(),

      // BETWEEN
      para([bold("ENTRE")]),
      para([
        bold("NextMove Inc."),
        normal(", soci\u00E9t\u00E9 constitu\u00E9e en vertu des lois du Qu\u00E9bec, ayant son si\u00E8ge social au "),
        blank(),
        normal(", repr\u00E9sent\u00E9e aux pr\u00E9sentes par ses membres fondateurs :"),
      ]),
      para([normal("\u2014  Eliot Alanmanou")], { indent: 720 }),
      para([normal("\u2014  Walkens Charles")], { indent: 720 }),
      para([normal("\u2014  Seydou ________________________")], { indent: 720 }),
      para([normal("\u2014  Dennis Kodjo")], { indent: 720 }),
      para([normal("Ci-apr\u00E8s d\u00E9sign\u00E9e \u00AB "), bold("NextMove"), normal(" \u00BB ou la \u00AB "), bold("Partie R\u00E9ceptrice"), normal(" \u00BB")]),
      para([bold("D\u2019une part,")]),
      empty(),

      para([bold("ET")]),
      para([
        bold("Monsieur Joanel Dupart"),
        normal(", courtier immobilier d\u00FBment agr\u00E9\u00E9 par l\u2019Organisme d\u2019autor\u00E9glementation du courtage immobilier du Qu\u00E9bec (OACIQ), exer\u00E7ant dans la r\u00E9gion du Grand Montr\u00E9al, demeurant au "),
        blank(),
        normal("."),
      ]),
      para([normal("Ci-apr\u00E8s d\u00E9sign\u00E9 \u00AB "), bold("M. Dupart"), normal(" \u00BB ou la \u00AB "), bold("Partie Divulgatrice"), normal(" \u00BB")]),
      para([bold("D\u2019autre part,")]),
      empty(),

      para([normal("NextMove et M. Dupart, ci-apr\u00E8s d\u00E9sign\u00E9s, individuellement, une \u00AB "), bold("Partie"), normal(" \u00BB et, collectivement, les \u00AB "), bold("Parties"), normal(" \u00BB.")]),
      empty(),

      // ===== IL A PREALABLEMENT EXPOSE =====
      heading("IL A PR\u00C9ALABLEMENT EXPOS\u00C9 CE QUI SUIT :", 1),
      para("Les Parties souhaitent \u00E9changer des donn\u00E9es et informations confidentielles dans le cadre du d\u00E9veloppement d\u2019un projet technologique intitul\u00E9 \u00AB Adjointe IA du Courtier Immobilier \u00BB (le \u00AB Projet \u00BB)."),
      para("Le Projet consiste en la conception, le d\u00E9veloppement et le d\u00E9ploiement d\u2019un agent conversationnel propuls\u00E9 par l\u2019intelligence artificielle, agissant comme adjointe administrative virtuelle pour un courtier immobilier au Qu\u00E9bec. Ce projet inclut, sans limitation :"),
      bulletItem("La cr\u00E9ation d\u2019un syst\u00E8me de r\u00E9ponse automatis\u00E9e aux clients (SMS et courriel) ;"),
      bulletItem("La collecte structur\u00E9e d\u2019informations de prospects (acheteurs et vendeurs) ;"),
      bulletItem("La qualification automatique des clients et le suivi des dossiers ;"),
      bulletItem("La planification de relances et de rendez-vous ;"),
      bulletItem("La g\u00E9n\u00E9ration de r\u00E9sum\u00E9s quotidiens \u00E0 l\u2019intention du courtier ;"),
      bulletItem("L\u2019acc\u00E8s aux syst\u00E8mes Matrix, Centris, Prospect et Contact du courtier \u00E0 des fins de d\u00E9veloppement et d\u2019int\u00E9gration."),
      para("Chaque Partie souhaitant pr\u00E9server la confidentialit\u00E9 des informations communiqu\u00E9es dans le cadre du Projet, le pr\u00E9sent Accord de Confidentialit\u00E9 a \u00E9t\u00E9 conclu."),
      empty(),

      // ===== CECI EXPOSE =====
      heading("CECI EXPOS\u00C9, IL A \u00C9T\u00C9 CONVENU CE QUI SUIT :", 1),

      // ART 1 — CONFIDENTIALITE
      heading("1. CONFIDENTIALIT\u00C9", 2),
      para("L\u2019objet du pr\u00E9sent Accord de Confidentialit\u00E9 est de formaliser l\u2019engagement irr\u00E9vocable de chaque Partie de pr\u00E9server la confidentialit\u00E9 des Informations Confidentielles telles que d\u00E9finies ci-apr\u00E8s."),
      para([
        normal("Dans le cadre de cet Accord, les \u00AB "),
        bold("Informations Confidentielles"),
        normal(" \u00BB d\u00E9signent toutes informations auxquelles toute Partie ou ses Repr\u00E9sentants aura acc\u00E8s dans le cadre du Projet, et comprennent notamment, sans limitation :"),
      ]),
      bulletItem("Les identifiants d\u2019acc\u00E8s aux syst\u00E8mes Matrix, Centris, Prospect, Contact et EasyMax de M. Dupart ;"),
      bulletItem("Les donn\u00E9es relatives aux clients et prospects de M. Dupart (noms, coordonn\u00E9es, situations financi\u00E8res, historiques de transactions) ;"),
      bulletItem("Les processus m\u00E9tier, proc\u00E9dures internes et documents de certification qualit\u00E9 (QSE) de M. Dupart ;"),
      bulletItem("Les strat\u00E9gies commerciales, les r\u00E9seaux de partenaires (courtiers hypoth\u00E9caires, inspecteurs, notaires) et les m\u00E9thodes de travail de M. Dupart ;"),
      bulletItem("Toute information technique, financi\u00E8re ou commerciale \u00E9chang\u00E9e dans le cadre du Projet, qu\u2019elle soit communiqu\u00E9e par \u00E9crit, par oral, par voie \u00E9lectronique ou par tout autre moyen ;"),
      bulletItem("Le code source, l\u2019architecture technique, les prompts IA et les flux d\u2019automatisation d\u00E9velopp\u00E9s par NextMove dans le cadre du Projet."),

      para([normal("Les \u00AB "), bold("Donn\u00E9es \u00E0 caract\u00E8re personnel"), normal(" \u00BB d\u00E9signent toute information relative \u00E0 une personne physique identifi\u00E9e ou identifiable, au sens de la "), italic("Loi sur la protection des renseignements personnels dans le secteur priv\u00E9"), normal(" (RLRQ, c. P-39.1, dite \u00AB Loi 25 \u00BB) et de la "), italic("Loi sur la protection des renseignements personnels et les documents \u00E9lectroniques"), normal(" (LPRPDE).")]),

      para([normal("Les \u00AB "), bold("Repr\u00E9sentants"), normal(" \u00BB d\u00E9signent, pour chaque Partie, ses dirigeants, administrateurs, salari\u00E9s, mandataires, partenaires, conseillers et consultants.")]),

      para("Chaque Partie s\u2019engage et se porte fort du respect d\u2019un tel engagement par ses Repr\u00E9sentants \u00E0 pr\u00E9server la confidentialit\u00E9 de toutes les Informations Confidentielles et notamment \u00E0 :"),
      bulletItem("n\u2019utiliser les Informations Confidentielles que dans l\u2019unique finalit\u00E9 de d\u00E9velopper, tester et d\u00E9ployer le Projet, \u00E0 l\u2019exclusion de tout autre usage ;"),
      bulletItem("ne jamais utiliser les identifiants Matrix/Centris de M. Dupart \u00E0 d\u2019autres fins que le d\u00E9veloppement et les tests du Projet ;"),
      bulletItem("ne jamais contacter directement les clients de M. Dupart \u00E0 des fins personnelles ou commerciales ;"),
      bulletItem("tenir les Informations Confidentielles secr\u00E8tes et \u00E0 ne les divulguer \u00E0 aucun tiers, \u00E0 l\u2019exception de ses Repr\u00E9sentants intervenant dans le cadre du Projet ;"),
      bulletItem("prendre toutes les mesures n\u00E9cessaires pour emp\u00EAcher la divulgation des Informations Confidentielles ;"),
      bulletItem("stocker les identifiants de mani\u00E8re s\u00E9curis\u00E9e (gestionnaire de mots de passe, variables d\u2019environnement chiffr\u00E9es) et ne jamais les inclure dans du code source, des d\u00E9p\u00F4ts Git ou des documents partag\u00E9s ;"),
      bulletItem("ne pas utiliser les Informations Confidentielles d\u2019une mani\u00E8re pr\u00E9judiciable aux int\u00E9r\u00EAts de la Partie qui les a divulgu\u00E9es."),

      para("Ces engagements ne s\u2019appliqueront pas aux informations d\u00E8s lors que la Partie destinataire pourrait d\u00E9montrer par \u00E9crit que :"),
      bulletItem("elle est tenue de les communiquer en vertu d\u2019une d\u00E9cision de justice ou d\u2019une disposition l\u00E9gale ou r\u00E9glementaire ;"),
      bulletItem("ces informations sont dans le domaine public, pour autant qu\u2019elles ne soient pas devenues publiques du fait de la Partie destinataire ;"),
      bulletItem("elle en disposait en toute r\u00E9gularit\u00E9 pr\u00E9alablement au d\u00E9but du Projet ;"),
      bulletItem("ces informations ont \u00E9t\u00E9 re\u00E7ues d\u2019un tiers non soumis \u00E0 une obligation de confidentialit\u00E9 ;"),
      bulletItem("la Partie divulgatrice en a autoris\u00E9 par \u00E9crit la libre communication."),

      para("Toute Information Confidentielle reste la propri\u00E9t\u00E9 de la Partie qui l\u2019a divulgu\u00E9e. Aucune stipulation du pr\u00E9sent Accord ne peut \u00EAtre interpr\u00E9t\u00E9e comme impliquant un engagement \u00E0 conclure un autre accord, une clause d\u2019exclusivit\u00E9, ou l\u2019octroi d\u2019un quelconque droit sur les secrets commerciaux de l\u2019autre Partie."),

      // ART 2 — NON-CONTOURNEMENT
      heading("2. NON-CONTOURNEMENT", 2),
      para("Pendant la dur\u00E9e de l\u2019Accord et trois (3) ann\u00E9es apr\u00E8s son expiration, NextMove et ses membres s\u2019engagent \u00E0 :"),
      bulletItem("ne pas contourner M. Dupart en contractant directement avec ses clients, partenaires, courtiers hypoth\u00E9caires, inspecteurs ou tout tiers introduit par M. Dupart dans le cadre du Projet ;"),
      bulletItem("ne pas solliciter les clients de M. Dupart identifi\u00E9s gr\u00E2ce aux Informations Confidentielles \u00E0 des fins concurrentes ;"),
      bulletItem("ne pas d\u00E9velopper un produit concurrent utilisant les donn\u00E9es sp\u00E9cifiques de M. Dupart sans son accord \u00E9crit pr\u00E9alable."),
      para("R\u00E9ciproquement, M. Dupart s\u2019engage \u00E0 ne pas contourner NextMove en reproduisant ou faisant reproduire les solutions techniques d\u00E9velopp\u00E9es dans le cadre du Projet sans l\u2019accord \u00E9crit pr\u00E9alable de NextMove."),

      // ART 3 — RESTITUTION
      heading("3. RESTITUTION OU DESTRUCTION DES INFORMATIONS", 2),
      para("Chaque Partie destinataire d\u2019Informations Confidentielles s\u2019engage \u00E0 retourner \u00E0 la Partie qui les a divulgu\u00E9es ou \u00E0 d\u00E9truire, dans un d\u00E9lai de quinze (15) jours suivant la demande \u00E9crite de cette derni\u00E8re, toutes les copies et reproductions desdites Informations Confidentielles."),
      para("En particulier, NextMove s\u2019engage \u00E0 :"),
      bulletItem("r\u00E9voquer ou supprimer tout acc\u00E8s aux syst\u00E8mes Matrix, Centris et autres outils de M. Dupart dans les 48 heures suivant la demande ;"),
      bulletItem("supprimer toute copie locale des identifiants ;"),
      bulletItem("purger les donn\u00E9es clients des environnements de d\u00E9veloppement et de test ;"),
      bulletItem("fournir une attestation \u00E9crite confirmant la destruction compl\u00E8te des donn\u00E9es."),

      // ART 4 — DUREE
      heading("4. DUR\u00C9E", 2),
      para("Le pr\u00E9sent Accord de Confidentialit\u00E9 produit ses effets \u00E0 compter de la date de sa signature par les Parties et ce pour une p\u00E9riode de trois (3) ans."),
      para("Le pr\u00E9sent Accord pourra \u00EAtre r\u00E9sili\u00E9 de fa\u00E7on anticip\u00E9e par l\u2019une ou l\u2019autre des Parties, sous r\u00E9serve d\u2019un pr\u00E9avis d\u2019un (1) mois notifi\u00E9 \u00E0 l\u2019autre Partie par tout moyen permettant d\u2019\u00E9tablir la r\u00E9ception effective."),
      para("La r\u00E9siliation anticip\u00E9e n\u2019aura pas pour effet de d\u00E9gager la Partie destinataire de ses obligations concernant les Informations Confidentielles re\u00E7ues avant la date de r\u00E9siliation. Ces obligations resteront en vigueur trois (3) ans apr\u00E8s l\u2019expiration ou la cessation de l\u2019Accord."),
      para("La limitation de dur\u00E9e ne s\u2019applique pas aux Donn\u00E9es \u00E0 caract\u00E8re personnel."),

      // ART 5 — DONNEES PERSONNELLES
      heading("5. DONN\u00C9ES \u00C0 CARACT\u00C8RE PERSONNEL", 2),
      para([
        normal("Dans le cadre du pr\u00E9sent Accord, les Parties s\u2019engagent \u00E0 respecter la r\u00E9glementation en vigueur au Qu\u00E9bec applicable au traitement de donn\u00E9es \u00E0 caract\u00E8re personnel, notamment la "),
        italic("Loi sur la protection des renseignements personnels dans le secteur priv\u00E9"),
        normal(" (RLRQ, c. P-39.1), telle que modifi\u00E9e par la Loi 25, ainsi que la "),
        italic("Loi sur la protection des renseignements personnels et les documents \u00E9lectroniques"),
        normal(" (LPRPDE) en ce qui a trait aux aspects f\u00E9d\u00E9raux."),
      ]),
      para("Les Parties s\u2019engagent notamment \u00E0 :"),
      bulletItem("traiter les Donn\u00E9es \u00E0 caract\u00E8re personnel uniquement pour la finalit\u00E9 du Projet ;"),
      bulletItem("garantir la confidentialit\u00E9, la s\u00E9curit\u00E9, l\u2019int\u00E9grit\u00E9 et la disponibilit\u00E9 des Donn\u00E9es \u00E0 caract\u00E8re personnel ;"),
      bulletItem("stocker toutes les donn\u00E9es au Canada (r\u00E9gion ca-central-1 ou \u00E9quivalent) conform\u00E9ment \u00E0 la Loi 25 ;"),
      bulletItem("veiller \u00E0 ce que les personnes autoris\u00E9es \u00E0 traiter les donn\u00E9es s\u2019engagent \u00E0 respecter la confidentialit\u00E9 ;"),
      bulletItem("ne pas transf\u00E9rer de Donn\u00E9es \u00E0 caract\u00E8re personnel en dehors du territoire canadien sauf exigence l\u00E9gale ;"),
      bulletItem("notifier dans un d\u00E9lai maximum de soixante-douze (72) heures toute violation de la confidentialit\u00E9 ou de la s\u00E9curit\u00E9 entra\u00EEnant la perte, la destruction ou l\u2019alt\u00E9ration des Donn\u00E9es ;"),
      bulletItem("restituer ou d\u00E9truire les Donn\u00E9es \u00E0 caract\u00E8re personnel \u00E0 la fin de l\u2019Accord, sans pr\u00E9judice des obligations l\u00E9gales de conservation."),

      // ART 6 — STIPULATIONS DIVERSES
      heading("6. STIPULATIONS DIVERSES", 2),
      bulletItem("La violation par une Partie ou par l\u2019un de ses Repr\u00E9sentants de ses obligations au titre du pr\u00E9sent Accord entra\u00EEnera la responsabilit\u00E9 de la Partie concern\u00E9e. Les Parties conviennent qu\u2019outre les dommages-int\u00E9r\u00EAts, la Partie l\u00E9s\u00E9e dispose du droit de demander r\u00E9paration par tout autre moyen de droit."),
      bulletItem("Aucune Partie ne peut c\u00E9der ou transf\u00E9rer ses droits et obligations au titre du pr\u00E9sent Accord sans l\u2019accord pr\u00E9alable \u00E9crit de l\u2019autre Partie."),
      bulletItem("L\u2019ensemble des stipulations des pr\u00E9sentes constitue l\u2019int\u00E9gralit\u00E9 de l\u2019accord entre les Parties et remplace tous accords pr\u00E9alables."),
      bulletItem("Le pr\u00E9sent Accord ne pourra \u00EAtre modifi\u00E9 que par avenant sign\u00E9 par les repr\u00E9sentants d\u00FBment autoris\u00E9s des Parties."),
      bulletItem("Le fait pour une Partie de ne pas exercer un droit ne saurait constituer une renonciation \u00E0 ce droit."),
      bulletItem("Au cas o\u00F9 une stipulation deviendrait ill\u00E9gale, nulle ou inopposable, les autres stipulations resteront pleinement valides."),

      // ART 7 — ELECTION DE DOMICILE
      heading("7. \u00C9LECTION DE DOMICILE \u2014 NOTIFICATIONS", 2),
      para("Toutes les notifications ou communications requises dans le cadre de l\u2019Accord seront \u00E9tablies par \u00E9crit et transmises par courrier \u00E9lectronique ou remises en mains propres. Elles seront consid\u00E9r\u00E9es comme d\u00E9livr\u00E9es \u00E0 la date de r\u00E9ception effective."),
      para("Les Parties font \u00E9lection de domicile \u00E0 leur adresse respective indiqu\u00E9e ci-dessus."),

      // ART 8 — LOI APPLICABLE
      heading("8. LOI APPLICABLE \u2014 ATTRIBUTION DE JURIDICTION", 2),
      para("Le pr\u00E9sent Accord de Confidentialit\u00E9 est r\u00E9gi par et interpr\u00E9t\u00E9 conform\u00E9ment aux lois de la province de Qu\u00E9bec et aux lois f\u00E9d\u00E9rales du Canada qui s\u2019y appliquent."),
      para("Tout diff\u00E9rend n\u00E9 du pr\u00E9sent Accord qui n\u2019aurait pu \u00EAtre r\u00E9gl\u00E9 \u00E0 l\u2019amiable dans un d\u00E9lai de quarante-cinq (45) jours sera soumis \u00E0 la comp\u00E9tence exclusive des tribunaux du district judiciaire de Montr\u00E9al, province de Qu\u00E9bec."),
      empty(),

      // ===== SIGNATURES =====
      heading("SIGNATURES", 1),
      para([normal("Fait en deux (2) exemplaires originaux, \u00E0 Montr\u00E9al, le "), blank()]),
      empty(),
      empty(),

      // NextMove
      new Paragraph({
        alignment: AlignmentType.LEFT,
        border: { bottom: { style: BorderStyle.SINGLE, size: 1, color: "000000", space: 1 } },
        spacing: { after: 80 },
        children: [bold("Pour NextMove Inc.")],
      }),
      empty(),
      para([bold("Eliot Alanmanou"), normal(", membre fondateur")]),
      para([normal("Date : ________________________     Signature : ________________________")]),
      empty(),
      para([bold("Walkens Charles"), normal(", membre fondateur")]),
      para([normal("Date : ________________________     Signature : ________________________")]),
      empty(),
      para([bold("Seydou ________________________"), normal(", membre fondateur")]),
      para([normal("Date : ________________________     Signature : ________________________")]),
      empty(),
      para([bold("Dennis Kodjo"), normal(", membre fondateur")]),
      para([normal("Date : ________________________     Signature : ________________________")]),
      empty(),
      empty(),

      // Joanel
      new Paragraph({
        alignment: AlignmentType.LEFT,
        border: { bottom: { style: BorderStyle.SINGLE, size: 1, color: "000000", space: 1 } },
        spacing: { after: 80 },
        children: [bold("Pour M. Dupart")],
      }),
      empty(),
      para([bold("Joanel Dupart"), normal(", courtier immobilier")]),
      para([normal("Date : ________________________     Signature : ________________________")]),
    ],
  }],
});

const OUTPUT = "/Users/Eliot_1/CascadeProjects/Projet_Immobilier_Courtier/atelier_resultats/NDA_NextMove_Joanel_Dupart.docx";

Packer.toBuffer(doc).then(buffer => {
  fs.writeFileSync(OUTPUT, buffer);
  console.log("NDA generated: " + OUTPUT);
});
