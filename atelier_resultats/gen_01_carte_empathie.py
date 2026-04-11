import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch
import textwrap

try:
    fig, ax = plt.subplots(figsize=(16, 12), dpi=150)
    ax.set_xlim(0, 16)
    ax.set_ylim(0, 12)
    ax.axis('off')
    fig.patch.set_facecolor('#F5F5F5')

    # Title
    ax.text(8, 11.6, 'Carte d\'Empathie \u2014 Le Courtier Immobilier',
            fontsize=22, fontweight='bold', ha='center', va='center', color='#2C3E50')
    ax.text(8, 11.2, 'Atelier JTBD \u2014 Mars 2026',
            fontsize=13, ha='center', va='center', color='#7F8C8D', style='italic')

    def draw_box(x, y, w, h, color, alpha=0.25, border_color=None):
        if border_color is None:
            border_color = color
        box = FancyBboxPatch((x, y), w, h,
                             boxstyle="round,pad=0.15",
                             facecolor=color, edgecolor=border_color,
                             linewidth=2, alpha=alpha)
        ax.add_patch(box)

    def add_title_and_items(x, y, w, title, items, title_color, fontsize=8.5):
        ax.text(x + w/2, y - 0.05, title,
                fontsize=12, fontweight='bold', ha='center', va='top', color=title_color)
        for i, item in enumerate(items):
            wrapped = textwrap.fill(item, width=38)
            ax.text(x + 0.25, y - 0.45 - i*0.42, '\u2022 ' + wrapped,
                    fontsize=fontsize, ha='left', va='top', color='#2C3E50', wrap=True)

    # --- CENTER ---
    cx, cy, cw, ch = 5.5, 5.0, 5.0, 2.2
    draw_box(cx, cy, cw, ch, '#ECF0F1', alpha=0.9, border_color='#2C3E50')
    center_lines = [
        "COURTIER IMMOBILIER",
        "\u2014 Etabli, ambitieux, seul \u2014",
        "Taux de cloture: 90%",
        "Volume: limite par l'admin"
    ]
    for i, line in enumerate(center_lines):
        fw = 'bold' if i == 0 else 'normal'
        fs = 11 if i == 0 else 9.5
        clr = '#2C3E50' if i == 0 else '#555555'
        ax.text(cx + cw/2, cy + ch - 0.35 - i*0.45, line,
                fontsize=fs, fontweight=fw, ha='center', va='center', color=clr)

    # --- TOP: PENSE & RESSENT ---
    tx, ty, tw, th = 4.0, 7.6, 8.0, 3.0
    draw_box(tx, ty, tw, th, '#9B59B6', alpha=0.18, border_color='#8E44AD')
    ax.text(tx + tw/2, ty + th - 0.15, 'PENSE & RESSENT', fontsize=13, fontweight='bold',
            ha='center', va='top', color='#8E44AD')
    pense_items = [
        "Si je veux faire 10 transactions/mois, ca va me tuer",
        "La difference avec les courtiers a 40M$? Juste l'equipe admin",
        "Si quelqu'un cree une adjointe IA, c'est fini",
        "Peur: Que le dossier ne passe pas"
    ]
    for i, item in enumerate(pense_items):
        ax.text(tx + 0.3, ty + th - 0.65 - i*0.55, '\u2022 ' + item,
                fontsize=8.5, ha='left', va='top', color='#2C3E50')

    # --- LEFT: VOIT ---
    lx, ly, lw, lh = 0.3, 4.6, 4.8, 3.0
    draw_box(lx, ly, lw, lh, '#3498DB', alpha=0.18, border_color='#2980B9')
    ax.text(lx + lw/2, ly + lh - 0.15, 'VOIT', fontsize=13, fontweight='bold',
            ha='center', va='top', color='#2980B9')
    voit_items = [
        "Courtiers a 40M$/an = equipe admin solide",
        "Matrix/Centris = monopole technologique",
        "Outils bombardes mais aucun ne resout le vrai probleme"
    ]
    for i, item in enumerate(voit_items):
        wrapped = textwrap.fill('\u2022 ' + item, width=40)
        ax.text(lx + 0.25, ly + lh - 0.65 - i*0.65, wrapped,
                fontsize=8.5, ha='left', va='top', color='#2C3E50')

    # --- RIGHT: ENTEND ---
    rx, ry, rw, rh = 10.9, 4.6, 4.8, 3.0
    draw_box(rx, ry, rw, rh, '#27AE60', alpha=0.18, border_color='#229954')
    ax.text(rx + rw/2, ry + rh - 0.15, 'ENTEND', fontsize=13, fontweight='bold',
            ha='center', va='top', color='#229954')
    entend_items = [
        "Clients: \"T'es trop long a repondre\"",
        "Banques: appels de derniere minute",
        "Industrie: \"On est bombardes d'outils mais aucun pour le courtier\""
    ]
    for i, item in enumerate(entend_items):
        wrapped = textwrap.fill('\u2022 ' + item, width=38)
        ax.text(rx + 0.25, ry + rh - 0.65 - i*0.65, wrapped,
                fontsize=8.5, ha='left', va='top', color='#2C3E50')

    # --- BOTTOM-LEFT: DIT ---
    blx, bly, blw, blh = 0.3, 1.6, 7.2, 2.8
    draw_box(blx, bly, blw, blh, '#E67E22', alpha=0.18, border_color='#D35400')
    ax.text(blx + blw/2, bly + blh - 0.15, 'DIT', fontsize=13, fontweight='bold',
            ha='center', va='top', color='#D35400')
    dit_items = [
        "\"Expliquer, negocier, visiter \u2014 c'est notre vrai travail\"",
        "\"Je deleguerais TOUT l'admin si je pouvais\"",
        "\"Matrix c'est trop complexe\""
    ]
    for i, item in enumerate(dit_items):
        wrapped = textwrap.fill('\u2022 ' + item, width=55)
        ax.text(blx + 0.25, bly + blh - 0.65 - i*0.6, wrapped,
                fontsize=8.5, ha='left', va='top', color='#2C3E50')

    # --- BOTTOM-RIGHT: FAIT ---
    brx, bry, brw, brh = 8.5, 1.6, 7.2, 2.8
    draw_box(brx, bry, brw, brh, '#F1C40F', alpha=0.22, border_color='#D4AC0D')
    ax.text(brx + brw/2, bry + brh - 0.15, 'FAIT', fontsize=13, fontweight='bold',
            ha='center', va='top', color='#B7950B')
    fait_items = [
        "Travaille seul sans adjoint",
        "Fait TOUT lui-meme",
        "A documente ses processus (QSE)",
        "Forme une nouvelle assistante"
    ]
    for i, item in enumerate(fait_items):
        ax.text(brx + 0.25, bry + brh - 0.65 - i*0.5, '\u2022 ' + item,
                fontsize=8.5, ha='left', va='top', color='#2C3E50')

    # --- BOTTOM BAR: DOULEURS | GAINS ---
    # Douleurs (red)
    draw_box(0.3, 0.15, 7.2, 1.25, '#E74C3C', alpha=0.18, border_color='#C0392B')
    ax.text(0.3 + 3.6, 1.25, 'DOULEURS', fontsize=11, fontweight='bold',
            ha='center', va='top', color='#C0392B')
    douleurs = ["Temps de reponse trop long", "Admin mange le temps",
                "Matrix = usine a gaz", "Pas de visibilite hypothecaire"]
    for i, d in enumerate(douleurs):
        ax.text(0.55 + (i % 2) * 3.5, 0.85 - (i // 2) * 0.35, '\u2022 ' + d,
                fontsize=7.5, ha='left', va='top', color='#922B21')

    # Gains (green)
    draw_box(8.5, 0.15, 7.2, 1.25, '#27AE60', alpha=0.18, border_color='#1E8449')
    ax.text(8.5 + 3.6, 1.25, 'GAINS', fontsize=11, fontweight='bold',
            ha='center', va='top', color='#1E8449')
    gains = ["Taux de cloture 90%", "Signature electronique",
             "Processus documentes", "Reseau de confiance"]
    for i, g in enumerate(gains):
        ax.text(8.75 + (i % 2) * 3.5, 0.85 - (i // 2) * 0.35, '\u2022 ' + g,
                fontsize=7.5, ha='left', va='top', color='#1A5276')

    plt.tight_layout(pad=0.5)
    out = '/Users/Eliot_1/CascadeProjects/_bmad-output/atelier_courtier_resultats/01_carte_empathie.png'
    plt.savefig(out, dpi=150, bbox_inches='tight', facecolor=fig.get_facecolor())
    plt.close()
    print(f"OK: {out}")
except Exception as e:
    print(f"ERREUR: {e}")
    import traceback; traceback.print_exc()
