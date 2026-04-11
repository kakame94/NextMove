import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
import textwrap

try:
    fig, ax = plt.subplots(figsize=(14, 12), dpi=150)
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 12)
    ax.axis('off')
    fig.patch.set_facecolor('#FAFAFA')

    # Title
    ax.text(7, 11.5, 'Matrice Douleurs / Gains \u2014 Priorisation',
            fontsize=22, fontweight='bold', ha='center', va='center', color='#2C3E50')
    ax.text(7, 11.1, 'Atelier JTBD \u2014 Mars 2026',
            fontsize=12, ha='center', va='center', color='#7F8C8D', style='italic')

    # Grid area
    gx, gy = 2.0, 1.2
    gw, gh = 10.5, 9.0
    mid_x = gx + gw / 2
    mid_y = gy + gh / 2

    # Quadrant backgrounds
    quadrants = [
        # top-right: high impact, high freq = RED / PRIORITE #1
        (mid_x, mid_y, gw/2, gh/2, '#FADBD8', '#E74C3C'),
        # top-left: high impact, low freq = ORANGE / GAINS RAPIDES
        (gx, mid_y, gw/2, gh/2, '#FDEBD0', '#E67E22'),
        # bottom-right: low impact, high freq = YELLOW / BON A AVOIR
        (mid_x, gy, gw/2, gh/2, '#FEF9E7', '#F1C40F'),
        # bottom-left: low impact, low freq = LIGHT GREEN / IGNORER
        (gx, gy, gw/2, gh/2, '#EAFAF1', '#27AE60'),
    ]

    for qx, qy, qw, qh, color, border in quadrants:
        box = FancyBboxPatch((qx, qy), qw, qh,
                             boxstyle="round,pad=0.08",
                             facecolor=color, edgecolor=border,
                             linewidth=2, alpha=0.7)
        ax.add_patch(box)

    # Axis labels
    # X axis: Frequence
    ax.annotate('', xy=(gx + gw + 0.3, gy - 0.05),
                xytext=(gx - 0.3, gy - 0.05),
                arrowprops=dict(arrowstyle='->', color='#2C3E50', lw=2))
    ax.text(gx - 0.3, gy - 0.35, 'Faible', fontsize=10, ha='left', color='#7F8C8D')
    ax.text(gx + gw + 0.3, gy - 0.35, 'Elevee', fontsize=10, ha='right', color='#7F8C8D')
    ax.text(mid_x, gy - 0.65, 'FREQUENCE', fontsize=12, fontweight='bold',
            ha='center', color='#2C3E50')

    # Y axis: Impact
    ax.annotate('', xy=(gx - 0.05, gy + gh + 0.3),
                xytext=(gx - 0.05, gy - 0.3),
                arrowprops=dict(arrowstyle='->', color='#2C3E50', lw=2))
    ax.text(gx - 0.35, gy - 0.15, 'Faible', fontsize=10, ha='right', va='bottom',
            color='#7F8C8D', rotation=90)
    ax.text(gx - 0.35, gy + gh + 0.15, 'Eleve', fontsize=10, ha='right', va='top',
            color='#7F8C8D', rotation=90)
    ax.text(gx - 0.8, mid_y, 'IMPACT', fontsize=12, fontweight='bold',
            ha='center', va='center', color='#2C3E50', rotation=90)

    # Quadrant labels and items
    # TOP-RIGHT: PRIORITE #1
    ax.text(mid_x + gw/4, mid_y + gh/2 - 0.25, 'PRIORITE #1',
            fontsize=13, fontweight='bold', ha='center', va='top', color='#C0392B')
    tr_items = [
        "Temps de reponse trop long",
        "Admin mange le temps de vente",
        "Pas de visibilite hypothecaire"
    ]
    for i, item in enumerate(tr_items):
        wrapped = textwrap.fill('\u2022 ' + item, width=32)
        ax.text(mid_x + 0.5, mid_y + gh/2 - 1.0 - i * 0.85, wrapped,
                fontsize=9.5, ha='left', va='top', color='#922B21',
                fontweight='medium')

    # TOP-LEFT: GAINS RAPIDES
    ax.text(gx + gw/4, mid_y + gh/2 - 0.25, 'GAINS RAPIDES',
            fontsize=13, fontweight='bold', ha='center', va='top', color='#D35400')
    tl_items = [
        "Perd des deals (financement)",
        "Clients mentent sur situation financiere"
    ]
    for i, item in enumerate(tl_items):
        wrapped = textwrap.fill('\u2022 ' + item, width=32)
        ax.text(gx + 0.5, mid_y + gh/2 - 1.0 - i * 0.85, wrapped,
                fontsize=9.5, ha='left', va='top', color='#935116',
                fontweight='medium')

    # BOTTOM-RIGHT: BON A AVOIR
    ax.text(mid_x + gw/4, mid_y - 0.25, 'BON A AVOIR',
            fontsize=13, fontweight='bold', ha='center', va='top', color='#B7950B')
    br_items = [
        "Matrix = usine a gaz",
        "Haute saison = impossible seul"
    ]
    for i, item in enumerate(br_items):
        wrapped = textwrap.fill('\u2022 ' + item, width=32)
        ax.text(mid_x + 0.5, mid_y - 1.0 - i * 0.85, wrapped,
                fontsize=9.5, ha='left', va='top', color='#7D6608',
                fontweight='medium')

    # BOTTOM-LEFT: IGNORER
    ax.text(gx + gw/4, mid_y - 0.25, 'IGNORER',
            fontsize=13, fontweight='bold', ha='center', va='top', color='#1E8449')
    bl_items = [
        "Centris bloque scraping",
        "7000$/an frais obligatoires"
    ]
    for i, item in enumerate(bl_items):
        wrapped = textwrap.fill('\u2022 ' + item, width=32)
        ax.text(gx + 0.5, mid_y - 1.0 - i * 0.85, wrapped,
                fontsize=9.5, ha='left', va='top', color='#196F3D',
                fontweight='medium')

    # Dashed center lines
    ax.plot([mid_x, mid_x], [gy, gy + gh], color='#ABB2B9', lw=1.5, ls='--', alpha=0.7)
    ax.plot([gx, gx + gw], [mid_y, mid_y], color='#ABB2B9', lw=1.5, ls='--', alpha=0.7)

    plt.tight_layout(pad=0.5)
    out = '/Users/Eliot_1/CascadeProjects/_bmad-output/atelier_courtier_resultats/03_matrice_douleurs_gains.png'
    plt.savefig(out, dpi=150, bbox_inches='tight', facecolor=fig.get_facecolor())
    plt.close()
    print(f"OK: {out}")
except Exception as e:
    print(f"ERREUR: {e}")
    import traceback; traceback.print_exc()
