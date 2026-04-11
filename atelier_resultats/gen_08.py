import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

fig, axes = plt.subplots(3, 1, figsize=(18, 12))
fig.suptitle("Arcs Narratifs JTBD — Histoires de Terrain", fontsize=24, fontweight='bold',
             color='#1A237E', y=0.98)

arcs = [
    {
        "title": "ARC 1 : Transaction Perdue — Hypotheque",
        "color": "#D32F2F", "light": "#FFCDD2", "border": "#B71C1C",
        "steps": [
            ("DECLENCHEUR", "Client refere"),
            ("PROBLEME", "Pas de visibilite sur\nle dossier hypothecaire"),
            ("CONSEQUENCE", "Transaction perdue"),
        ],
        "verbatim": '"J\'avais pas de controle sur la personne\nqui faisait l\'hypotheque"',
        "root": "Root cause : Manque de visibilite transversale",
    },
    {
        "title": "ARC 2 : Transaction Perdue — Inspection",
        "color": "#E65100", "light": "#FFE0B2", "border": "#BF360C",
        "steps": [
            ("DECLENCHEUR", "Inspection revele\nmoisissure"),
            ("PROBLEME", "Vendeur refuse\nde negocier"),
            ("CONSEQUENCE", "Retrait de l'offre"),
        ],
        "verbatim": '"Il ne voulait pas negocier\ndu tout du tout"',
        "root": "Root cause : Manque de preparation en amont",
    },
    {
        "title": "ARC 3 : Changement Reussi — E-Signature",
        "color": "#2E7D32", "light": "#C8E6C9", "border": "#1B5E20",
        "steps": [
            ("DECLENCHEUR", "Clients investisseurs\na distance"),
            ("SOLUTION", "Adoption signature\nelectronique"),
            ("RESULTAT", "Tout se fait en virtuel,\n2-3 minutes"),
        ],
        "verbatim": '"Clients a l\'autre bout du monde"',
        "root": "Lecon : Adopte la tech quand la valeur est evidente",
    },
]

for idx, (ax, arc) in enumerate(zip(axes, arcs)):
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 3)
    ax.axis('off')

    # Title bar
    title_box = FancyBboxPatch((0.1, 2.35), 9.8, 0.55, boxstyle="round,pad=0.1",
                                facecolor=arc["color"], edgecolor='none')
    ax.add_patch(title_box)
    ax.text(5, 2.62, arc["title"], ha='center', va='center',
            fontsize=15, fontweight='bold', color='white')

    # Step boxes
    box_width = 2.4
    box_height = 1.1
    x_positions = [0.5, 3.8, 7.1]

    for j, (step_label, step_text) in enumerate(arc["steps"]):
        x = x_positions[j]
        box = FancyBboxPatch((x, 0.95), box_width, box_height,
                              boxstyle="round,pad=0.15",
                              facecolor=arc["light"], edgecolor=arc["border"], linewidth=2)
        ax.add_patch(box)
        ax.text(x + box_width/2, 1.85, step_label, ha='center', va='center',
                fontsize=10, fontweight='bold', color=arc["color"])
        ax.text(x + box_width/2, 1.35, step_text, ha='center', va='center',
                fontsize=11, color='#212121')

        # Arrows between boxes
        if j < 2:
            ax.annotate('', xy=(x_positions[j+1] - 0.05, 1.5),
                        xytext=(x + box_width + 0.05, 1.5),
                        arrowprops=dict(arrowstyle='->', color=arc["color"],
                                       lw=3, mutation_scale=20))

    # Verbatim
    ax.text(5, 0.55, arc["verbatim"], ha='center', va='center',
            fontsize=11, style='italic', color='#424242',
            bbox=dict(boxstyle='round,pad=0.4', facecolor='#FAFAFA',
                      edgecolor='#BDBDBD', linewidth=1))

    # Root cause / lecon
    ax.text(5, 0.08, arc["root"], ha='center', va='center',
            fontsize=11, fontweight='bold', color=arc["border"])

plt.tight_layout(rect=[0, 0, 1, 0.95])
fig.savefig('/Users/Eliot_1/CascadeProjects/_bmad-output/atelier_courtier_resultats/08_arcs_narratifs_jtbd.png',
            dpi=150, bbox_inches='tight', facecolor='white')
plt.close()
print("OK: 08_arcs_narratifs_jtbd.png")
