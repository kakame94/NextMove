import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

fig = plt.figure(figsize=(16, 14))
ax = fig.add_axes([0, 0, 1, 1])
ax.set_xlim(0, 16)
ax.set_ylim(0, 14)
ax.axis('off')
ax.set_facecolor('white')

# ============ TITLE ============
ax.text(8, 13.5, "Baguette Magique — Vision Ideale", ha='center', va='center',
        fontsize=26, fontweight='bold', color='#1A237E')

# ============ TOP SECTION: Flux de Travail Reve ============
ax.text(8, 12.7, "Flux de Travail Reve", ha='center', va='center',
        fontsize=16, fontweight='bold', color='#37474F')

flow_boxes = [
    {"x": 0.5, "text": "Visite\nterminee", "color": "#1565C0", "light": "#BBDEFB"},
    {"x": 4.3, "text": "IA genere offre\nd'achat", "color": "#2E7D32", "light": "#C8E6C9",
     "sub": "(donnees client + fiche\nMatrix deja la)"},
    {"x": 8.1, "text": "Signature\nelectronique\nenvoyee", "color": "#2E7D32", "light": "#C8E6C9"},
    {"x": 11.9, "text": "TOTAL :\nquelques secondes\nau lieu de 30-60 min", "color": "#F9A825", "light": "#FFF9C4"},
]

box_w = 3.3
box_h = 1.6
box_y = 11.0

for i, fb in enumerate(flow_boxes):
    box = FancyBboxPatch((fb["x"], box_y), box_w, box_h,
                          boxstyle="round,pad=0.2",
                          facecolor=fb["light"], edgecolor=fb["color"], linewidth=2.5)
    ax.add_patch(box)
    ax.text(fb["x"] + box_w/2, box_y + box_h/2 + (0.15 if "sub" in fb else 0),
            fb["text"], ha='center', va='center',
            fontsize=12, fontweight='bold', color=fb["color"])
    if "sub" in fb:
        ax.text(fb["x"] + box_w/2, box_y + 0.3, fb["sub"], ha='center', va='center',
                fontsize=9, color='#616161', style='italic')
    # Arrow
    if i < 3:
        ax.annotate('', xy=(flow_boxes[i+1]["x"] - 0.1, box_y + box_h/2),
                    xytext=(fb["x"] + box_w + 0.1, box_y + box_h/2),
                    arrowprops=dict(arrowstyle='->', color='#37474F', lw=2.5, mutation_scale=18))

# ============ MIDDLE: Verbatim Quote ============
quote = ('"Si une IA peut juste generer une offre d\'achat en un rien de temps —\n'
         'clic, tu as deja ton fichier client, son nom, photo, tout le tralala..."')
quote_box = FancyBboxPatch((1.5, 9.0), 13, 1.5, boxstyle="round,pad=0.3",
                            facecolor='#EDE7F6', edgecolor='#5E35B1', linewidth=2)
ax.add_patch(quote_box)
ax.text(8, 9.75, quote, ha='center', va='center',
        fontsize=13, style='italic', color='#4A148C', fontweight='bold')

# ============ BOTTOM: Comparison ============
ax.text(8, 8.3, "Comparaison : Aujourd'hui vs Demain", ha='center', va='center',
        fontsize=16, fontweight='bold', color='#37474F')

# Divider line
ax.plot([8, 8], [1.0, 7.8], color='#BDBDBD', lw=2, ls='--')

# LEFT column - Aujourd'hui
left_box = FancyBboxPatch((0.5, 1.0), 7.0, 6.8, boxstyle="round,pad=0.3",
                           facecolor='#FFEBEE', edgecolor='#C62828', linewidth=2)
ax.add_patch(left_box)
ax.text(4.0, 7.3, "AUJOURD'HUI", ha='center', va='center',
        fontsize=16, fontweight='bold', color='#C62828')

left_items = [
    "Courtier fait tout seul",
    "30-60 min par offre d'achat",
    'Temps de reponse = "mon plus gros defaut"',
    "Volume limite par l'admin",
    "Assistante : 2 500 - 3 000 $/mois",
]
for i, item in enumerate(left_items):
    y = 6.5 - i * 1.1
    ax.text(1.2, y, "\u2022  " + item, ha='left', va='center',
            fontsize=12, color='#B71C1C', fontweight='bold')

# RIGHT column - Demain
right_box = FancyBboxPatch((8.5, 1.0), 7.0, 6.8, boxstyle="round,pad=0.3",
                            facecolor='#E8F5E9', edgecolor='#2E7D32', linewidth=2)
ax.add_patch(right_box)
ax.text(12.0, 7.3, "DEMAIN (avec IA)", ha='center', va='center',
        fontsize=16, fontweight='bold', color='#2E7D32')

right_items = [
    "IA gere 80-90% de l'admin",
    "Offre d'achat en secondes",
    "Reponse instantanee 24/7",
    "10+ transactions/mois",
    "Agent IA : 35 - 50 $/mois",
]
for i, item in enumerate(right_items):
    y = 6.5 - i * 1.1
    ax.text(9.2, y, "\u2022  " + item, ha='left', va='center',
            fontsize=12, color='#1B5E20', fontweight='bold')

fig.savefig('/Users/Eliot_1/CascadeProjects/_bmad-output/atelier_courtier_resultats/09_baguette_magique_vision.png',
            dpi=150, bbox_inches='tight', facecolor='white')
plt.close()
print("OK: 09_baguette_magique_vision.png")
