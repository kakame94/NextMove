"""Klaris — One-pager GTM (FR). Generator ReportLab.

Output: Klaris_GTM_OnePager_FR.pdf (1 page A4 paysage, 297mm × 210mm).
Audience: distribution rapide — partenaires, advisors, investisseurs early.
A imprimer recto seul ou envoyer en PJ courriel.

Brand: terracotta #C25A36 + cream + Helvetica (fallback Geist absent).
Source: synthese GTM v1.0 + etude marche v3.
"""

from pathlib import Path

from reportlab.lib.colors import Color, white
from reportlab.lib.pagesizes import landscape, A4
from reportlab.lib.units import mm
from reportlab.pdfgen import canvas
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont


# -----------------------------------------------------------------------------
# Brand tokens (RGB 0-1)
# -----------------------------------------------------------------------------

TERRACOTTA       = Color(0xC2 / 255, 0x5A / 255, 0x36 / 255)
TERRACOTTA_STRONG= Color(0xA8 / 255, 0x4A / 255, 0x2A / 255)
TERRACOTTA_SOFT  = Color(0xF4 / 255, 0xDB / 255, 0xCE / 255)
CREAM            = Color(0xFA / 255, 0xF9 / 255, 0xF5 / 255)
CREAM_DEEP       = Color(0xEE / 255, 0xEA / 255, 0xE2 / 255)
CHARCOAL         = Color(0x2A / 255, 0x25 / 255, 0x21 / 255)
CHARCOAL_60      = Color(0x7A / 255, 0x70 / 255, 0x68 / 255)
BORDER           = Color(0xE2 / 255, 0xDD / 255, 0xD3 / 255)
SUCCESS          = Color(0x50 / 255, 0xA0 / 255, 0x4B / 255)
WARN_AMBER       = Color(0xE0 / 255, 0xA8 / 255, 0x36 / 255)
DESTRUCTIVE      = Color(0xD6 / 255, 0x4C / 255, 0x2E / 255)
INFO             = Color(0x4F / 255, 0x8F / 255, 0xE0 / 255)


# -----------------------------------------------------------------------------
# Fonts — register Geist if available, else default Helvetica
# -----------------------------------------------------------------------------

GEIST_CANDIDATES = [
    Path("/Library/Fonts/Geist-Regular.ttf"),
    Path("/System/Library/Fonts/Geist-Regular.ttf"),
    Path.home() / "Library/Fonts/Geist-Regular.ttf",
]
GEIST_BOLD_CANDIDATES = [
    Path("/Library/Fonts/Geist-Bold.ttf"),
    Path("/System/Library/Fonts/Geist-Bold.ttf"),
    Path.home() / "Library/Fonts/Geist-Bold.ttf",
]

BODY = "Helvetica"
BODY_BOLD = "Helvetica-Bold"
MONO = "Helvetica"
MONO_BOLD = "Helvetica-Bold"

for path in GEIST_CANDIDATES:
    if path.exists():
        try:
            pdfmetrics.registerFont(TTFont("Geist", str(path)))
            BODY = "Geist"
            MONO = "Geist"
            break
        except Exception:
            pass
for path in GEIST_BOLD_CANDIDATES:
    if path.exists():
        try:
            pdfmetrics.registerFont(TTFont("Geist-Bold", str(path)))
            BODY_BOLD = "Geist-Bold"
            MONO_BOLD = "Geist-Bold"
            break
        except Exception:
            pass


# -----------------------------------------------------------------------------
# Layout helpers
# -----------------------------------------------------------------------------

def rect(c, x, y, w, h, *, fill=None, stroke=None, stroke_w=0.5, radius=0):
    if fill is not None:
        c.setFillColor(fill)
    c.setStrokeColor(stroke if stroke else fill)
    c.setLineWidth(stroke_w)
    if radius > 0:
        c.roundRect(x, y, w, h, radius,
                    stroke=1 if stroke else 0,
                    fill=1 if fill else 0)
    else:
        c.rect(x, y, w, h,
               stroke=1 if stroke else 0,
               fill=1 if fill else 0)


def text(c, x, y, txt, *, font=BODY, size=9, color=CHARCOAL, bold=False):
    c.setFillColor(color)
    f = BODY_BOLD if bold and font == BODY else (MONO_BOLD if bold and font == MONO else font)
    c.setFont(f, size)
    c.drawString(x, y, txt)


def text_centered(c, cx, y, txt, *, font=BODY, size=9, color=CHARCOAL, bold=False):
    c.setFillColor(color)
    f = BODY_BOLD if bold and font == BODY else (MONO_BOLD if bold and font == MONO else font)
    c.setFont(f, size)
    c.drawCentredString(cx, y, txt)


def text_wrap(c, x, y, w, txt, *, font=BODY, size=8, color=CHARCOAL,
              bold=False, line_height=10):
    """Naive word wrap. Returns y after last line."""
    c.setFillColor(color)
    f = BODY_BOLD if bold and font == BODY else (MONO_BOLD if bold and font == MONO else font)
    c.setFont(f, size)
    words = txt.split()
    line = ""
    cur_y = y
    for word in words:
        test_line = (line + " " + word).strip()
        if c.stringWidth(test_line, f, size) <= w:
            line = test_line
        else:
            c.drawString(x, cur_y, line)
            cur_y -= line_height
            line = word
    if line:
        c.drawString(x, cur_y, line)
    return cur_y


def divider(c, x1, y, x2, *, color=BORDER, weight=0.5):
    c.setStrokeColor(color)
    c.setLineWidth(weight)
    c.line(x1, y, x2, y)


def pill(c, x, y, w, h, label, *, fill=TERRACOTTA, text_color=white, size=7):
    rect(c, x, y, w, h, fill=fill, radius=h / 2)
    c.setFillColor(text_color)
    c.setFont(MONO_BOLD, size)
    c.drawCentredString(x + w / 2, y + (h - size) / 2 + 1, label)


def kpi_block(c, x, y, w, h, label, value, sub, *, value_color=TERRACOTTA):
    rect(c, x, y, w, h, fill=white, stroke=BORDER, stroke_w=0.5, radius=4)
    text(c, x + 6, y + h - 12, label.upper(),
         font=MONO_BOLD, size=6.5, color=CHARCOAL_60, bold=True)
    c.setFont(BODY_BOLD, 14)
    c.setFillColor(value_color)
    c.drawString(x + 6, y + h - 28, value)
    text_wrap(c, x + 6, y + h - 38, w - 12, sub,
              font=BODY, size=6.5, color=CHARCOAL_60, line_height=8)


# -----------------------------------------------------------------------------
# Layout
# -----------------------------------------------------------------------------

def build():
    page_w, page_h = landscape(A4)  # 842 × 595 pt
    out = Path(__file__).parent / "Klaris_GTM_OnePager_FR.pdf"
    c = canvas.Canvas(str(out), pagesize=landscape(A4))
    c.setTitle("Klaris — GTM One-Pager")
    c.setAuthor("Klaris")

    # Page bg cream
    rect(c, 0, 0, page_w, page_h, fill=CREAM)

    # ----------------------------------- Header strip
    h_top = 38
    rect(c, 0, page_h - h_top, page_w, h_top, fill=CHARCOAL)
    text(c, 24, page_h - 22, "K L A R I S",
         font=MONO_BOLD, size=13, color=CREAM, bold=True)
    text(c, 110, page_h - 22, "·  GO-TO-MARKET v1.0  ·  Q3 2026",
         font=MONO, size=9, color=TERRACOTTA_SOFT)
    text(c, page_w - 24 - 250, page_h - 22,
         "Bootstrap · Quebec · 100 clients M12 · 150 K$ ARR",
         font=BODY, size=9, color=CREAM)

    # ----------------------------------- Tagline
    y = page_h - 70
    text(c, 24, y, "L'adjointe IA des courtiers immo QC.",
         font=BODY_BOLD, size=22, color=CHARCOAL, bold=True)
    text(c, 24, y - 16, "Action Layer · 99-199 $/mois · conforme OACIQ + Loi 25.",
         font=BODY, size=11, color=TERRACOTTA, bold=True)

    # Tagline right side: cible
    text(c, page_w - 24 - 280, y - 4, "CIBLE M12",
         font=MONO_BOLD, size=7, color=CHARCOAL_60, bold=True)
    text(c, page_w - 24 - 280, y - 18,
         "100 clients · NRR > 100 % · churn < 3 %/mo",
         font=BODY, size=9, color=CHARCOAL)

    # ----------------------------------- 3 KPI hero row
    kpi_y = page_h - 165
    kpi_h = 60
    kpi_w = (page_w - 48 - 16) / 3
    kpi_gap = 8
    kpis = [
        ("SAM Québec", "17,85 M$", "11 900 courtiers OACIQ · ARPU 1 500 $/an",
         TERRACOTTA),
        ("CAC / LTV / Payback", "1 200 $ · 3 000 $ · 9,6 mo",
         "Ratio LTV:CAC 2,5:1 · cible bootstrap > 3:1",
         WARN_AMBER),
        ("Jalon M12", "100 clients · 150 K$ ARR",
         "M6 50 · M12 100 · M24 400 (600 K$ ARR)",
         SUCCESS),
    ]
    for i, (lbl, val, sub, col) in enumerate(kpis):
        kx = 24 + i * (kpi_w + kpi_gap)
        kpi_block(c, kx, kpi_y, kpi_w, kpi_h, lbl, val, sub, value_color=col)

    # ----------------------------------- 2-col main body
    body_y_top = kpi_y - 14
    col_w = (page_w - 48 - 16) / 2
    col_l_x = 24
    col_r_x = 24 + col_w + 16

    # LEFT COL — Persona + Killer message + 4 canaux
    cur_y = body_y_top
    text(c, col_l_x, cur_y, "PERSONA · KILLER MESSAGE",
         font=MONO_BOLD, size=7, color=CHARCOAL_60, bold=True)
    cur_y -= 14
    text(c, col_l_x, cur_y,
         "Courtier solo bilingue · 2-7 ans · 100-500 K$ GCI · 12-15+ tx/an",
         font=BODY_BOLD, size=10, color=CHARCOAL, bold=True)
    cur_y -= 16
    # Killer card
    km_h = 38
    rect(c, col_l_x, cur_y - km_h, col_w, km_h,
         fill=TERRACOTTA_SOFT, radius=4)
    text_wrap(c, col_l_x + 8, cur_y - 12, col_w - 16,
              "« Votre CRM stocke passivement. Klaris, elle, agit. "
              "Elle qualifie 24/7 en français québécois, garantit la "
              "conformité Loi 25, et ferme les rendez-vous. »",
              font=BODY, size=8, color=TERRACOTTA_STRONG, line_height=10)
    cur_y -= km_h + 14

    # 4 canaux table
    text(c, col_l_x, cur_y, "4 CANAUX ACQUISITION",
         font=MONO_BOLD, size=7, color=CHARCOAL_60, bold=True)
    cur_y -= 12
    canaux = [
        ("Meta Ads", "3-6 K$/mo · CAC 1 200 $ · 5-8 clients/mo", TERRACOTTA),
        ("RDV OACIQ kiosque", "12-15 K$/evt · brand + 100-200 emails", WARN_AMBER),
        ("Outbound directeurs", "VP Ventes 100 % · 1-3 agences/an", INFO),
        ("Referral 100 $/100 $", "5 K$/an payouts · ratio > 0,15", SUCCESS),
    ]
    row_h = 18
    for i, (name, sub, col) in enumerate(canaux):
        ry = cur_y - (i + 1) * row_h
        # Color marker
        rect(c, col_l_x, ry, 3, row_h - 2, fill=col)
        text(c, col_l_x + 10, ry + row_h - 11, name,
             font=BODY_BOLD, size=9, color=CHARCOAL, bold=True)
        text(c, col_l_x + 110, ry + row_h - 11, sub,
             font=BODY, size=8, color=CHARCOAL_60)
    cur_y -= len(canaux) * row_h + 10

    # 5 partenariats
    text(c, col_l_x, cur_y, "5 PARTENARIATS FONDATEURS · ANNÉE 1",
         font=MONO_BOLD, size=7, color=CHARCOAL_60, bold=True)
    cur_y -= 12
    partners = [
        ("Centris Inc.", "Syndication API MLS", "Dennis", "M6"),
        ("RE/MAX Anjou (Belma)", "Pilote 50+ courtiers", "Eliot", "M3"),
        ("APCIQ", "Commandite RDV OACIQ", "Seydou", "M6"),
        ("Collège Immobilier QC", "Cursus UFC techno", "Walkens", "M9"),
        ("Cabinet juridique Loi 25", "Livre blanc lead magnet", "Walkens", "M4"),
    ]
    p_row_h = 13
    for i, (cible, obj, owner, ech) in enumerate(partners):
        ry = cur_y - (i + 1) * p_row_h
        text(c, col_l_x, ry + 2, f"{i+1}. {cible}",
             font=BODY_BOLD, size=8, color=CHARCOAL, bold=True)
        text(c, col_l_x + 110, ry + 2, obj,
             font=BODY, size=7.5, color=CHARCOAL_60)
        text(c, col_l_x + col_w - 70, ry + 2, owner,
             font=MONO_BOLD, size=7.5, color=TERRACOTTA, bold=True)
        text(c, col_l_x + col_w - 22, ry + 2, ech,
             font=MONO, size=7.5, color=CHARCOAL_60)
    cur_y -= len(partners) * p_row_h + 6

    # RIGHT COL — Séquence + Budget + Actions
    cur_y = body_y_top
    text(c, col_r_x, cur_y, "SÉQUENCE 24 MOIS",
         font=MONO_BOLD, size=7, color=CHARCOAL_60, bold=True)
    cur_y -= 12
    miles = [
        ("M0-M3", "Setup", "Convention · Tech E&O · subventions · entretiens Roof.ai",
         CHARCOAL_60),
        ("M3-M6", "Activation", "Meta 3 K$/mo · 10-20 payants · pilote Belma · VP Ventes",
         WARN_AMBER),
        ("M6", "PMF proxy", "50 clients · NRR > 100 % · churn < 3 %/mo",
         TERRACOTTA),
        ("M12", "PMF validé", "100 clients · 150 K$ ARR · 1ère agence",
         SUCCESS),
        ("M18", "Décision", "Bootstrap pur OU prep Série seed si NRR > 110 %",
         INFO),
        ("M24", "Trigger ON", "400 clients · 600 K$ ARR · adapter TRESA",
         SUCCESS),
    ]
    s_row_h = 14
    for i, (jalon, name, sub, col) in enumerate(miles):
        ry = cur_y - (i + 1) * s_row_h
        pill(c, col_r_x, ry, 36, s_row_h - 3, jalon,
             fill=col, size=6.5)
        text(c, col_r_x + 42, ry + s_row_h - 11, name,
             font=BODY_BOLD, size=8.5, color=CHARCOAL, bold=True)
        text(c, col_r_x + 100, ry + s_row_h - 11, sub,
             font=BODY, size=7.5, color=CHARCOAL_60)
    cur_y -= len(miles) * s_row_h + 12

    # Budget summary
    text(c, col_r_x, cur_y, "BUDGET Y1 · NET CASH-OUT",
         font=MONO_BOLD, size=7, color=CHARCOAL_60, bold=True)
    cur_y -= 12
    budget_items = [
        ("Meta Ads", "36 K$"),
        ("RDV OACIQ + démo", "12-15 K$"),
        ("Contenu / témoignages", "8 K$"),
        ("Tech E&O assurance", "5-10 K$"),
        ("Referral payouts", "5 K$"),
        ("Subventions non-dilutives", "-30 K$"),
    ]
    b_row_h = 10
    for i, (lbl, val) in enumerate(budget_items):
        ry = cur_y - (i + 1) * b_row_h
        col_v = SUCCESS if val.startswith("-") else CHARCOAL
        text(c, col_r_x, ry + 1, lbl,
             font=BODY, size=8, color=CHARCOAL_60)
        text(c, col_r_x + col_w - 60, ry + 1, val,
             font=MONO_BOLD, size=8, color=col_v, bold=True)
    # Net line
    cur_y -= len(budget_items) * b_row_h + 4
    divider(c, col_r_x, cur_y, col_r_x + col_w, color=BORDER, weight=0.5)
    cur_y -= 12
    text(c, col_r_x, cur_y, "NET Y1",
         font=MONO_BOLD, size=8, color=CHARCOAL, bold=True)
    text(c, col_r_x + col_w - 90, cur_y, "~ 36-60 K$",
         font=BODY_BOLD, size=10, color=TERRACOTTA, bold=True)
    cur_y -= 14

    # Actions semaine 1
    text(c, col_r_x, cur_y, "ACTIONS SEMAINE 1 · DÉCISIONS BINAIRES",
         font=MONO_BOLD, size=7, color=CHARCOAL_60, bold=True)
    cur_y -= 12
    actions = [
        ("1.", "VP Ventes nommé (1 cofondateur 100 %)"),
        ("2.", "Tech E&O quote (Northbridge / Intact Tech)"),
        ("3.", "Convention cofondateurs (cap table + vesting)"),
        ("4.", "5 entretiens Roof.ai ex-clients"),
        ("5.", "Inscription RDV OACIQ 2026 + kiosque"),
    ]
    a_row_h = 12
    for i, (num, lbl) in enumerate(actions):
        ry = cur_y - (i + 1) * a_row_h
        # Checkbox
        rect(c, col_r_x, ry + 1, 8, 8, fill=None,
             stroke=CHARCOAL_60, stroke_w=0.6)
        text(c, col_r_x + 14, ry + 2, num,
             font=MONO_BOLD, size=8, color=TERRACOTTA, bold=True)
        text(c, col_r_x + 28, ry + 2, lbl,
             font=BODY, size=8.5, color=CHARCOAL)
    cur_y -= len(actions) * a_row_h + 4

    # ----------------------------------- Footer strip
    fh = 28
    rect(c, 0, 0, page_w, fh, fill=CHARCOAL)
    text(c, 24, fh - 12,
         "« Pas de levée. Pas de Centiva head-on. Bootstrap pur jusqu'à 100 clients prouvés. »",
         font=BODY, size=8, color=TERRACOTTA_SOFT, bold=True)
    text(c, 24, fh - 22,
         "Dennis · Eliot · Walkens · Seydou",
         font=MONO, size=7, color=CREAM_DEEP)
    text(c, page_w - 24 - 220, fh - 12,
         "Source : Étude de marché v3 · §4 + §7",
         font=MONO, size=7, color=CREAM_DEEP)
    text(c, page_w - 24 - 220, fh - 22,
         "alanmanou.consulting@gmail.com",
         font=MONO_BOLD, size=7, color=TERRACOTTA_SOFT, bold=True)

    c.showPage()
    c.save()
    print(f"OK -> {out}")


if __name__ == "__main__":
    build()
