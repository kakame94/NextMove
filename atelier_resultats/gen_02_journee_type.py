import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
import textwrap

try:
    fig, ax = plt.subplots(figsize=(18, 10), dpi=150)
    ax.set_xlim(0, 18)
    ax.set_ylim(0, 10)
    ax.axis('off')
    fig.patch.set_facecolor('#FAFAFA')

    # Title
    ax.text(9, 9.5, 'Journee Type du Courtier Immobilier',
            fontsize=24, fontweight='bold', ha='center', va='center', color='#2C3E50')
    ax.text(9, 9.05, 'Atelier JTBD \u2014 Mars 2026',
            fontsize=12, ha='center', va='center', color='#7F8C8D', style='italic')

    # Timeline blocks
    blocks = [
        {
            'label': 'MATIN TOT',
            'hours': '7h - 9h',
            'color': '#AED6F1',
            'border': '#2980B9',
            'text_color': '#1A5276',
            'items': [
                'Verifier messages Centris',
                'Contact',
                'Prospect',
                'Matrix'
            ]
        },
        {
            'label': 'AVANT-MIDI',
            'hours': '9h - 12h',
            'color': '#F5CBA7',
            'border': '#E67E22',
            'text_color': '#935116',
            'items': [
                'Appels clients',
                'Suivi dossiers',
                'Relancer banque',
                'Admin docs'
            ]
        },
        {
            'label': 'MIDI',
            'hours': '12h - 13h',
            'color': '#D5DBDB',
            'border': '#95A5A6',
            'text_color': '#566573',
            'items': [
                '(variable)'
            ]
        },
        {
            'label': 'APRES-MIDI',
            'hours': '13h - 18h',
            'color': '#ABEBC6',
            'border': '#27AE60',
            'text_color': '#1E8449',
            'items': [
                'VISITES (moment le',
                'plus productif)',
                'Negociations',
                'Rencontres',
                'Inspections'
            ]
        },
        {
            'label': 'SOIR / WEEKEND',
            'hours': '18h - 23h',
            'color': '#AEB6BF',
            'border': '#2C3E50',
            'text_color': '#1B2631',
            'items': [
                'Appels clients anxieux',
                'Signatures electroniques',
                '"10h-11h du soir',
                'le tel sonne"'
            ]
        }
    ]

    n = len(blocks)
    total_w = 16.5
    gap = 0.25
    bw = (total_w - (n - 1) * gap) / n
    bh = 4.2
    start_x = 0.75
    start_y = 4.2

    # Draw timeline arrow
    ax.annotate('', xy=(start_x + total_w + 0.3, start_y + bh / 2),
                xytext=(start_x - 0.3, start_y + bh / 2),
                arrowprops=dict(arrowstyle='->', color='#BDC3C7', lw=3))

    for i, block in enumerate(blocks):
        x = start_x + i * (bw + gap)
        y = start_y

        box = FancyBboxPatch((x, y), bw, bh,
                             boxstyle="round,pad=0.12",
                             facecolor=block['color'], edgecolor=block['border'],
                             linewidth=2.5, alpha=0.85)
        ax.add_patch(box)

        # Label
        ax.text(x + bw/2, y + bh - 0.25, block['label'],
                fontsize=11, fontweight='bold', ha='center', va='top',
                color=block['text_color'])
        # Hours
        ax.text(x + bw/2, y + bh - 0.65, block['hours'],
                fontsize=9.5, ha='center', va='top', color=block['text_color'],
                style='italic')

        # Separator line
        ax.plot([x + 0.2, x + bw - 0.2], [y + bh - 0.85, y + bh - 0.85],
                color=block['border'], lw=1, alpha=0.5)

        # Items
        for j, item in enumerate(block['items']):
            ax.text(x + 0.25, y + bh - 1.15 - j * 0.5, '\u2022 ' + item,
                    fontsize=8, ha='left', va='top', color='#2C3E50')

    # Annotation boxes below
    annotations = [
        ('3 OUTILS', 'Contact, Prospect, Matrix\n(tous Centris)', '#3498DB'),
        ('INTERRUPTION PRINCIPALE', 'Appels de la banque\nen fin de transaction', '#E74C3C'),
        ('PAS DE JOURNEE TYPE', '"Il n\'y a pas une journee\nqui est pareille"', '#8E44AD'),
    ]

    ann_w = 4.8
    ann_h = 1.8
    ann_gap = 0.6
    ann_total = len(annotations) * ann_w + (len(annotations) - 1) * ann_gap
    ann_start_x = (18 - ann_total) / 2
    ann_y = 1.6

    for i, (title, text, color) in enumerate(annotations):
        x = ann_start_x + i * (ann_w + ann_gap)
        box = FancyBboxPatch((x, ann_y), ann_w, ann_h,
                             boxstyle="round,pad=0.15",
                             facecolor='white', edgecolor=color,
                             linewidth=2.5, alpha=0.9)
        ax.add_patch(box)
        # Colored top bar
        bar = FancyBboxPatch((x + 0.05, ann_y + ann_h - 0.45), ann_w - 0.1, 0.4,
                             boxstyle="round,pad=0.05",
                             facecolor=color, edgecolor='none', alpha=0.85)
        ax.add_patch(bar)
        ax.text(x + ann_w/2, ann_y + ann_h - 0.25, title,
                fontsize=9, fontweight='bold', ha='center', va='center', color='white')
        ax.text(x + ann_w/2, ann_y + ann_h/2 - 0.2, text,
                fontsize=8.5, ha='center', va='center', color='#2C3E50')

    plt.tight_layout(pad=0.5)
    out = '/Users/Eliot_1/CascadeProjects/_bmad-output/atelier_courtier_resultats/02_journee_type.png'
    plt.savefig(out, dpi=150, bbox_inches='tight', facecolor=fig.get_facecolor())
    plt.close()
    print(f"OK: {out}")
except Exception as e:
    print(f"ERREUR: {e}")
    import traceback; traceback.print_exc()
