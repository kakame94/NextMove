import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

fig, ax = plt.subplots(figsize=(12, 18), dpi=150)
fig.patch.set_facecolor('#FAFAFA')
ax.set_xlim(0, 12)
ax.set_ylim(-1, 19)
ax.set_xticks([])
ax.set_yticks([])
for spine in ax.spines.values():
    spine.set_visible(False)

ax.text(6, 18.3, 'Chemin Ideal de la Transaction Immobiliere',
        fontsize=22, fontweight='bold', ha='center', va='center', color='#1a1a2e')

steps = [
    ("0", "MARKETING / REFERENCE", "IA", "L'agente peut repondre aux premiers messages"),
    ("1", "PREMIER CONTACT + COLLECTE", "IA", "Nom, adresse, type bien, situation financiere"),
    ("2", "QUALIFICATION HYPOTHECAIRE", "MIXTE", "Pont avec courtier hypothecaire, verifier pre-qualif"),
    ("3", "PLANIFICATION VISITES", "IA", "Calendrier, temps deplacement, \"une visite ca prend 15 min\""),
    ("4", "VISITES", "COURTIER", "Obligation legale, moment le plus productif"),
    ("5", "COMPARABLES + ANALYSE", "IA", "\"C'est la qu'avec Matrix on fait les comparables\""),
    ("6", "OFFRE D'ACHAT", "MIXTE", "IA genere, courtier valide + negocie"),
    ("7", "INSPECTION", "MIXTE", "IA planifie, courtier negocie si problemes"),
    ("8", "SUIVI FINANCEMENT", "IA", "Visibilite dossier hypotheque, anticipation"),
    ("9", "CLOTURE", "COURTIER", "Documents finaux, signature notaire"),
]

colors = {
    'IA': ('#2E7D32', '#E8F5E9', '#1B5E20'),
    'MIXTE': ('#E65100', '#FFF3E0', '#BF360C'),
    'COURTIER': ('#C62828', '#FFEBEE', '#B71C1C'),
}

box_w = 9.0
box_h = 1.3
x_center = 6.0
x_left = x_center - box_w / 2
y_top = 17.2

for i, (num, title, typ, desc) in enumerate(steps):
    y = y_top - i * 1.7
    edge_color, fill_color, text_dark = colors[typ]

    # Box
    rect = mpatches.FancyBboxPatch((x_left, y - box_h/2), box_w, box_h,
                                    boxstyle="round,pad=0.15",
                                    facecolor=fill_color, edgecolor=edge_color, linewidth=2.5)
    ax.add_patch(rect)

    # Step number badge
    badge = plt.Circle((x_left + 0.5, y), 0.35, color=edge_color, zorder=5)
    ax.add_patch(badge)
    ax.text(x_left + 0.5, y, num, fontsize=11, fontweight='bold', color='white',
            ha='center', va='center', zorder=6)

    # Tag
    tag_x = x_left + box_w - 0.15
    tag_text = f"[{typ}]"
    ax.text(tag_x, y + 0.3, tag_text, fontsize=9, fontweight='bold', color=edge_color,
            ha='right', va='center')

    # Title
    ax.text(x_left + 1.2, y + 0.3, title, fontsize=11, fontweight='bold', color=text_dark,
            ha='left', va='center')

    # Description
    ax.text(x_left + 1.2, y - 0.25, desc, fontsize=8.5, color='#555555',
            ha='left', va='center', fontstyle='italic')

    # Arrow to next
    if i < len(steps) - 1:
        arrow_y_start = y - box_h / 2 - 0.02
        arrow_y_end = y - 1.7 + box_h / 2 + 0.02
        ax.annotate('', xy=(x_center, arrow_y_end), xytext=(x_center, arrow_y_start),
                     arrowprops=dict(arrowstyle='->', color='#666666', lw=2.0))

# Legend
legend_y = 0.3
legend_items = [
    ('IA (Automatisable)', '#2E7D32', '#E8F5E9'),
    ('MIXTE (Automatisation partielle)', '#E65100', '#FFF3E0'),
    ('COURTIER (Obligation legale)', '#C62828', '#FFEBEE'),
]
for j, (label, ec, fc) in enumerate(legend_items):
    lx = 1.5 + j * 3.5
    rect = mpatches.FancyBboxPatch((lx, legend_y - 0.2), 0.5, 0.4,
                                    boxstyle="round,pad=0.05", facecolor=fc, edgecolor=ec, linewidth=2)
    ax.add_patch(rect)
    ax.text(lx + 0.7, legend_y, label, fontsize=8.5, color=ec, fontweight='bold',
            va='center', ha='left')

# Note
ax.text(6, -0.5, '80% du chemin peut etre assiste par l\'IA',
        fontsize=13, fontweight='bold', ha='center', va='center', color='#1B5E20',
        bbox=dict(boxstyle='round,pad=0.4', facecolor='#E8F5E9', edgecolor='#2E7D32', linewidth=2))

out = '/Users/Eliot_1/CascadeProjects/_bmad-output/atelier_courtier_resultats/05_chemin_ideal_transaction.png'
plt.savefig(out, dpi=150, bbox_inches='tight', facecolor=fig.get_facecolor())
plt.close()
print(f"Saved: {out}")
