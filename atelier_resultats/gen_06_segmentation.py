import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

fig, axes = plt.subplots(2, 2, figsize=(16, 12), dpi=150)
fig.patch.set_facecolor('#FAFAFA')
fig.suptitle('Segmentation -- Quoi Automatiser?', fontsize=24, fontweight='bold', y=0.97, color='#1a1a2e')

quadrants = [
    {
        'title': 'A AUTOMATISER',
        'icon': 'PRIORITE',
        'bg': '#E8F5E9',
        'border': '#2E7D32',
        'title_color': '#1B5E20',
        'bullet_color': '#4CAF50',
        'items': [
            "Generation offres d'achat",
            "Collecte documents client",
            "Suivi hypotheque",
            "Relances documents manquants",
            "Planification visites",
            "Comparables de marche",
            "Reponse premiers messages",
        ]
    },
    {
        'title': 'BON A AVOIR',
        'icon': 'SOUHAITABLE',
        'bg': '#FFFDE7',
        'border': '#F9A825',
        'title_color': '#F57F17',
        'bullet_color': '#FDD835',
        'items': [
            "Prospection automatisee",
            "Appels IA",
            "Resume quotidien",
            "Calcul temps deplacement",
        ]
    },
    {
        'title': 'NE PAS TOUCHER',
        'icon': 'INTERDIT',
        'bg': '#FFEBEE',
        'border': '#C62828',
        'title_color': '#B71C1C',
        'bullet_color': '#EF5350',
        'items': [
            "Visites proprietes (legal)",
            "Signatures documents (legal)",
            "Rencontres client en personne",
            "Negociations sensibles",
        ]
    },
    {
        'title': 'ZONE GRISE',
        'icon': 'A EVALUER',
        'bg': '#FFF3E0',
        'border': '#E65100',
        'title_color': '#BF360C',
        'bullet_color': '#FF9800',
        'items': [
            "Communication IA avec acheteurs frileux",
            "Suivi post-visite par IA",
            "Appels personnes agees",
            "Premier contact telephonique",
        ]
    },
]

positions = [(0,0), (0,1), (1,0), (1,1)]

for idx, (row, col) in enumerate(positions):
    ax = axes[row][col]
    q = quadrants[idx]
    ax.set_facecolor(q['bg'])
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.set_xticks([])
    ax.set_yticks([])
    for spine in ax.spines.values():
        spine.set_edgecolor(q['border'])
        spine.set_linewidth(3)

    # Title
    ax.text(5, 9.2, q['title'], fontsize=18, fontweight='bold', color=q['title_color'],
            ha='center', va='center')

    # Subtitle tag
    ax.text(5, 8.4, q['icon'], fontsize=10, fontweight='bold', color='white',
            ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor=q['border'], edgecolor='none'))

    # Items
    n_items = len(q['items'])
    y_start = 7.3
    spacing = min(1.3, 6.5 / max(n_items, 1))

    for i, item in enumerate(q['items']):
        y_pos = y_start - i * spacing

        # Bullet square
        sq = mpatches.FancyBboxPatch((0.8, y_pos - 0.18), 0.36, 0.36,
                                      boxstyle="round,pad=0.03",
                                      facecolor=q['bullet_color'], edgecolor='none')
        ax.add_patch(sq)

        # Checkmark in bullet
        ax.text(0.98, y_pos, '\u2713', fontsize=10, fontweight='bold', color='white',
                ha='center', va='center')

        ax.text(1.6, y_pos, item, fontsize=11, color='#333333',
                va='center', ha='left')

plt.subplots_adjust(hspace=0.15, wspace=0.1, top=0.91, bottom=0.04, left=0.03, right=0.97)

out = '/Users/Eliot_1/CascadeProjects/_bmad-output/atelier_courtier_resultats/06_segmentation_automatisation.png'
plt.savefig(out, dpi=150, bbox_inches='tight', facecolor=fig.get_facecolor())
plt.close()
print(f"Saved: {out}")
