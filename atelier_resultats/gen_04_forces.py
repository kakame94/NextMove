import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from textwrap import fill

fig, axes = plt.subplots(2, 2, figsize=(16, 12), dpi=150)
fig.patch.set_facecolor('#F5F5F5')
fig.suptitle('4 Forces de Progres JTBD', fontsize=24, fontweight='bold', y=0.97, color='#1a1a2e')

forces = [
    {
        'title': 'PUSH',
        'subtitle': 'Forces qui poussent a changer',
        'level': 10,
        'bg': '#8B0000',
        'bar_color': '#FF4444',
        'text_color': 'white',
        'items': [
            "Je fais tout seul, sans adjoint",
            "Si je veux faire 10 transactions/mois,\nca va me tuer",
            "La difference avec les courtiers a 40M$?\nJuste l'equipe admin",
            "Le temps de retour -- c'est mon\nplus gros defaut"
        ]
    },
    {
        'title': 'PULL',
        'subtitle': 'Attraction vers la nouvelle solution',
        'level': 10,
        'bg': '#1B5E20',
        'bar_color': '#4CAF50',
        'text_color': 'white',
        'items': [
            "Si quelqu'un cree une adjointe IA,\nc'est fini. Tout le monde la prendrait.",
            "Preuve: passage a la e-signature\n= adoption tech",
            "80-90% des taches assistante\nautomatisables",
            "Vision: offre d'achat generee\nen secondes"
        ]
    },
    {
        'title': 'ANXIETE',
        'subtitle': 'Peurs face au changement',
        'level': 3,
        'bg': '#E65100',
        'bar_color': '#FF9800',
        'text_color': 'white',
        'items': [
            "Ouvert a l'IA personnellement",
            "Inquietude: clients frileux\n(acheteurs, personnes agees)",
            "Loi 25 (protection donnees)",
            "Certaines choses ca peut etre\ncomplique"
        ]
    },
    {
        'title': 'HABITUDE',
        'subtitle': 'Inertie du statu quo',
        'level': 5,
        'bg': '#37474F',
        'bar_color': '#78909C',
        'text_color': 'white',
        'items': [
            "Matrix = ecosysteme ferme, monopole",
            "Processus documentes (QSE)\n= acquis a preserver",
            "Ecosysteme humain bati\n(hypothecaire, inspecteur, notaire)",
            "Contacts de confiance"
        ]
    }
]

positions = [(0,0), (0,1), (1,0), (1,1)]

for idx, (row, col) in enumerate(positions):
    ax = axes[row][col]
    f = forces[idx]
    ax.set_facecolor(f['bg'])
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.set_xticks([])
    ax.set_yticks([])
    for spine in ax.spines.values():
        spine.set_visible(False)

    # Title and subtitle
    ax.text(5, 9.4, f['title'], fontsize=20, fontweight='bold', color=f['text_color'],
            ha='center', va='center')
    ax.text(5, 8.7, f['subtitle'], fontsize=11, fontstyle='italic', color=f['text_color'],
            ha='center', va='center', alpha=0.9)

    # Progress bar
    bar_y = 7.8
    bar_x = 1.0
    bar_w = 8.0
    bar_h = 0.5
    # Background bar
    ax.add_patch(mpatches.FancyBboxPatch((bar_x, bar_y), bar_w, bar_h,
                 boxstyle="round,pad=0.05", facecolor='#333333', edgecolor='none', alpha=0.5))
    # Filled bar
    fill_w = bar_w * (f['level'] / 10)
    ax.add_patch(mpatches.FancyBboxPatch((bar_x, bar_y), fill_w, bar_h,
                 boxstyle="round,pad=0.05", facecolor=f['bar_color'], edgecolor='none', alpha=0.9))
    ax.text(5, bar_y + bar_h/2, f"{f['level']}/10", fontsize=13, fontweight='bold',
            color='white', ha='center', va='center')

    # Bullet items
    y_start = 7.0
    for i, item in enumerate(f['items']):
        y_pos = y_start - i * 1.65
        # Bullet circle
        ax.plot(0.7, y_pos, 'o', color=f['bar_color'], markersize=7)
        ax.text(1.2, y_pos, item, fontsize=9, color=f['text_color'],
                va='center', ha='left', linespacing=1.3)

plt.subplots_adjust(hspace=0.15, wspace=0.1, top=0.92, bottom=0.08, left=0.03, right=0.97)

# Verdict at bottom
fig.text(0.5, 0.025,
         'VERDICT: TRES PRET A CHANGER -- Push + Pull (20/20) >>> Anxiete + Habitude (8/20)',
         fontsize=15, fontweight='bold', ha='center', va='center',
         color='white',
         bbox=dict(boxstyle='round,pad=0.6', facecolor='#1B5E20', edgecolor='#4CAF50', linewidth=2))

out = '/Users/Eliot_1/CascadeProjects/_bmad-output/atelier_courtier_resultats/04_forces_progres_jtbd.png'
plt.savefig(out, dpi=150, bbox_inches='tight', facecolor=fig.get_facecolor())
plt.close()
print(f"Saved: {out}")
