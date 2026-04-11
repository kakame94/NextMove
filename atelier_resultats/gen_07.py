import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

fig, ax = plt.subplots(figsize=(14, 10))

segments = [
    {"name": "Personnes agees", "pct": 0.10, "color": "#D32F2F",
     "label": "Beaucoup d'interdiction, pas a l'aise avec la tech",
     "strategy": "Aucune IA visible, 100% humain"},
    {"name": "Premiers acheteurs / public", "pct": 0.30, "color": "#F57C00",
     "label": "Beaucoup sont encore tres frileux",
     "strategy": "IA invisible, tout passe par le courtier"},
    {"name": "Vendeurs", "pct": 0.60, "color": "#66BB6A",
     "label": "Moins sensibles, pas de stress d'achat",
     "strategy": "IA en arriere-plan"},
    {"name": "Investisseurs / a distance", "pct": 0.90, "color": "#2E7D32",
     "label": "Deja habitues au virtuel, e-signature adoptee",
     "strategy": "Contact IA direct OK"},
]

bar_height = 0.55
y_positions = [3, 2, 1, 0]

for i, seg in enumerate(segments):
    y = y_positions[i]
    # Background bar (gray)
    ax.barh(y, 1.0, height=bar_height, color='#E0E0E0', edgecolor='#BDBDBD', linewidth=1)
    # Filled bar
    ax.barh(y, seg["pct"], height=bar_height, color=seg["color"], edgecolor='none', alpha=0.9)
    # Percentage text inside bar
    ax.text(seg["pct"] / 2, y + 0.02, f'{int(seg["pct"]*100)}%',
            ha='center', va='center', fontsize=16, fontweight='bold', color='white')
    # Segment name on the left
    ax.text(-0.02, y + 0.02, seg["name"], ha='right', va='center',
            fontsize=13, fontweight='bold', color='#212121')
    # Label below the bar
    ax.text(0.0, y - 0.38, seg["label"], ha='left', va='center',
            fontsize=10, color='#424242', style='italic')
    # Strategy on the right
    ax.text(1.02, y + 0.02, seg["strategy"], ha='left', va='center',
            fontsize=11, fontweight='bold', color=seg["color"])

ax.set_xlim(-0.02, 1.0)
ax.set_ylim(-1.2, 3.8)
ax.axis('off')

# Title
ax.set_title("Confort des Clients avec l'IA", fontsize=22, fontweight='bold',
             color='#1A237E', pad=30)

# Subtitle
ax.text(0.5, 3.65, "Niveau de confort par segment client", ha='center', va='center',
        fontsize=13, color='#616161', transform=ax.transData)

# Bottom rule box
rule_text = ("REGLE : L'IA automatise l'ARRIERE-BOUTIQUE (invisible au client).\n"
             "Le contact client reste humain sauf pour les segments confortables.")
props = dict(boxstyle='round,pad=0.8', facecolor='#FFF9C4', edgecolor='#F9A825', linewidth=2)
ax.text(0.5, -0.95, rule_text, ha='center', va='center', fontsize=12,
        fontweight='bold', color='#E65100', bbox=props)

# Strategy column header
ax.text(1.02, 3.45, "Strategie IA", ha='left', va='center',
        fontsize=12, fontweight='bold', color='#616161', style='italic')

plt.tight_layout()
fig.savefig('/Users/Eliot_1/CascadeProjects/_bmad-output/atelier_courtier_resultats/07_confort_client_ia.png',
            dpi=150, bbox_inches='tight', facecolor='white')
plt.close()
print("OK: 07_confort_client_ia.png")
