/* ═══════════════════════════════════════════════════════════════
   Maison Forge — Budget Estimator (client-side)
   Heuristique calibrée sur le marché Québec 2026 (cuisine/SDB).
   Sources: ranges CAA Habitation, RBQ guides, propositions agences QC.
   ═══════════════════════════════════════════════════════════════ */

(function () {
  // Bases de prix par type (en k$ CAD, valeurs centrales)
  // Format: [min, center, max] pour surface "moyenne" (M), finition "confort"
  const baseTypes = {
    cuisine:               { min: 25, center: 45, max: 80 },
    salle_de_bain:         { min: 12, center: 22, max: 38 },
    reconfiguration:       { min: 35, center: 65, max: 130 },
    conversion_locative:   { min: 45, center: 80, max: 150 },
    ajout_etage:           { min: 80, center: 150, max: 280 },
    autre:                 { min: 20, center: 40, max: 80 }
  };

  // Multiplicateurs surface (relatif à "moyenne" = 1.0)
  const surfaceMul = {
    petite:       0.65,
    moyenne:      1.0,
    grande:       1.45,
    tres_grande:  2.0,
    multi_pieces: 2.6,
    incertain:    1.0
  };

  // Multiplicateurs niveau finition
  const finitionMul = {
    essentiel: 0.70,
    confort:   1.0,
    premium:   1.55
  };

  // Modificateurs délai (rush = +%)
  const delaiMul = {
    urgence:     1.12,  // rush surcoût mobilisation
    court:       1.04,
    moyen:       1.0,
    long:        0.98,  // mieux planifié
    ouvert:      0.97,
    exploration: 1.0
  };

  // Modificateur occupation (vacant = -%, on reste = +%)
  const occupationMul = {
    oui:             1.08,  // phasage = surcoût coordination
    non_relogement:  1.0,
    locatif:         0.97,
    vacant:          0.95
  };

  // Labels lisibles pour breakdown
  const surfaceLabels = {
    petite:'Petite (<80 pi²)', moyenne:'Moyenne (80-150 pi²)',
    grande:'Grande (150-300 pi²)', tres_grande:'Très grande (>300 pi²)',
    multi_pieces:'Multi-pièces', incertain:'À valider en visite'
  };
  const finitionLabels = { essentiel:'Essentiel', confort:'Confort', premium:'Premium' };
  const typeLabels = {
    cuisine:'Cuisine', salle_de_bain:'Salle de bain', reconfiguration:'Reconfiguration',
    conversion_locative:'Conversion locative', ajout_etage:'Agrandissement', autre:'Autre projet'
  };
  const delaiLabels = {
    urgence:'Asap (rush)', court:'1-3 mois', moyen:'3-6 mois',
    long:'6-12 mois', ouvert:'Pas pressé', exploration:'Exploration'
  };

  /**
   * Calcule la fourchette budgétaire estimée.
   * @param {Object} data - réponses du wizard
   * @returns {Object} { min, center, max, confidence_label, breakdown }
   */
  window.estimateBudget = function (data) {
    const type = data.projet_type || 'cuisine';
    const surface = data.surface || 'moyenne';
    const finition = data.finition || 'confort';
    const delai = data.delai || 'moyen';
    const occupation = data.occupation || 'non_relogement';
    const userBudget = parseInt(data.budget_k || '40', 10);

    const base = baseTypes[type] || baseTypes.cuisine;
    const sMul = surfaceMul[surface] || 1.0;
    const fMul = finitionMul[finition] || 1.0;
    const dMul = delaiMul[delai] || 1.0;
    const oMul = occupationMul[occupation] || 1.0;

    const totalMul = sMul * fMul * dMul * oMul;

    let min = Math.round(base.min * totalMul);
    let center = Math.round(base.center * totalMul);
    let max = Math.round(base.max * totalMul);

    // Largeur fourchette: serrer si toutes les réponses sont précises (pas "incertain")
    const incertitude = (surface === 'incertain' ? 1 : 0) + (data.delai === 'exploration' ? 1 : 0);
    if (incertitude === 0) {
      min = Math.round(min * 1.05);
      max = Math.round(max * 0.92);
    } else if (incertitude >= 2) {
      min = Math.round(min * 0.85);
      max = Math.round(max * 1.20);
    }

    // Confiance label
    let confidence_label;
    if (incertitude === 0) confidence_label = 'Confiance élevée — toutes réponses précises';
    else if (incertitude === 1) confidence_label = 'Confiance moyenne — à affiner en visite';
    else confidence_label = 'Confiance faible — visite Phase 1 nécessaire';

    // Comparaison avec budget user
    const userBudgetNote = userBudget < min ? '⚠ inférieur à fourchette estimée' :
                          userBudget > max ? '✓ marge confortable vs estimation' :
                          '✓ aligné avec fourchette estimée';

    // Breakdown ventilation typique (pourcentages indicatifs marché QC)
    const breakdown = [
      { label: 'Type', value: typeLabels[type] || '—' },
      { label: 'Surface', value: surfaceLabels[surface] || '—' },
      { label: 'Finition', value: finitionLabels[finition] || '—' },
      { label: 'Délai', value: delaiLabels[delai] || '—' },
      { label: 'Multiplicateur global', value: `× ${totalMul.toFixed(2)}` },
      { label: 'Votre budget cible', value: `${userBudget} k$` },
      { label: 'Position vs estimation', value: userBudgetNote }
    ];

    return {
      min,
      center,
      max,
      confidence_label,
      breakdown,
      ventilation_typique: {
        materiaux: Math.round(center * 0.45),
        main_oeuvre: Math.round(center * 0.40),
        coordination: Math.round(center * 0.10),
        contingence: Math.round(center * 0.05)
      }
    };
  };
})();
