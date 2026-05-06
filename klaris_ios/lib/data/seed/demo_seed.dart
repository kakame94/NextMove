import '../models/conversation.dart';
import '../models/prospect.dart';
import '../models/relance.dart';

/// Hard-coded demo data. Toggled by Env.demoMode = true at app launch.
/// Useful for App Store screenshots, sales demos, offline mode.
abstract class DemoSeed {
  DemoSeed._();

  static final now = DateTime(2026, 5, 5, 14, 30);

  static final prospects = <Prospect>[
    Prospect(
      id: 'demo-1', courtierId: 'demo-broker',
      nom: 'Marie Tremblay', telephone: '514-555-0142',
      type: ProspectType.acheteur, status: ProspectStatus.qualifie,
      score: 9, secteur: 'Verdun', budget: 475000, delai: '1-3 mois',
      preApprouve: true,
      createdAt: now.subtract(const Duration(hours: 4)),
      lastContactAt: now.subtract(const Duration(minutes: 22)),
    ),
    Prospect(
      id: 'demo-2', courtierId: 'demo-broker',
      nom: 'Sébastien Côté', telephone: '438-555-0287',
      type: ProspectType.acheteur, status: ProspectStatus.qualifie,
      score: 8, secteur: 'Plateau · Mile-End', budget: 620000, delai: '<1 mois',
      preApprouve: true,
      createdAt: now.subtract(const Duration(hours: 9)),
      lastContactAt: now.subtract(const Duration(hours: 1)),
    ),
    Prospect(
      id: 'demo-3', courtierId: 'demo-broker',
      nom: 'Nadia Lemieux', telephone: '450-555-0331',
      type: ProspectType.vendeur, status: ProspectStatus.qualifie,
      score: 7, secteur: 'Laval-Centre', budget: 540000, delai: '3-6 mois',
      preApprouve: false,
      createdAt: now.subtract(const Duration(days: 1)),
      lastContactAt: now.subtract(const Duration(hours: 6)),
    ),
    Prospect(
      id: 'demo-4', courtierId: 'demo-broker',
      nom: 'Olivier Beaulieu', telephone: '514-555-0408',
      type: ProspectType.acheteur, status: ProspectStatus.contacte,
      score: 5, secteur: 'Rosemont', budget: 380000, delai: '6-12 mois',
      preApprouve: false,
      createdAt: now.subtract(const Duration(days: 2)),
      lastContactAt: now.subtract(const Duration(hours: 18)),
    ),
    Prospect(
      id: 'demo-5', courtierId: 'demo-broker',
      nom: 'Geneviève Roy', telephone: '514-555-0512',
      type: ProspectType.acheteur, status: ProspectStatus.nouveau,
      score: 3, secteur: 'NDG', budget: 295000, delai: '>12 mois',
      preApprouve: false,
      createdAt: now.subtract(const Duration(days: 4)),
    ),
  ];

  static final messagesForProspect1 = <Message>[
    Message(id: 'm1', prospectId: 'demo-1', direction: MessageDirection.inbound, sender: MessageSender.prospect,
      content: "Bonsoir, je cherche un duplex à Verdun, budget 450K", sentAt: now.subtract(const Duration(hours: 4))),
    Message(id: 'm2', prospectId: 'demo-1', direction: MessageDirection.outbound, sender: MessageSender.klaris,
      content: "Bonsoir! Merci de contacter Joanel, courtier immobilier. Je suis son assistante. Acheter ou vendre?",
      sentAt: now.subtract(const Duration(hours: 4, seconds: -30))),
    Message(id: 'm3', prospectId: 'demo-1', direction: MessageDirection.inbound, sender: MessageSender.prospect,
      content: "Acheter", sentAt: now.subtract(const Duration(hours: 3, minutes: 58))),
    Message(id: 'm4', prospectId: 'demo-1', direction: MessageDirection.outbound, sender: MessageSender.klaris,
      content: "Super! Dans quel secteur vous aimeriez acheter?", sentAt: now.subtract(const Duration(hours: 3, minutes: 58, seconds: -10))),
    Message(id: 'm5', prospectId: 'demo-1', direction: MessageDirection.inbound, sender: MessageSender.prospect,
      content: "Verdun ou le Sud-Ouest", sentAt: now.subtract(const Duration(hours: 3, minutes: 50))),
    Message(id: 'm6', prospectId: 'demo-1', direction: MessageDirection.outbound, sender: MessageSender.klaris,
      content: "C'est quoi votre budget approximatif?", sentAt: now.subtract(const Duration(hours: 3, minutes: 50, seconds: -10))),
    Message(id: 'm7', prospectId: 'demo-1', direction: MessageDirection.inbound, sender: MessageSender.prospect,
      content: "Autour de 475K finalement, je suis pré-approuvé chez Desjardins", sentAt: now.subtract(const Duration(hours: 3, minutes: 40))),
    Message(id: 'm8', prospectId: 'demo-1', direction: MessageDirection.outbound, sender: MessageSender.klaris,
      content: "Parfait! Délai d'achat?", sentAt: now.subtract(const Duration(hours: 3, minutes: 40, seconds: -10))),
    Message(id: 'm9', prospectId: 'demo-1', direction: MessageDirection.inbound, sender: MessageSender.prospect,
      content: "1 à 3 mois idéalement", sentAt: now.subtract(const Duration(hours: 3, minutes: 30))),
    Message(id: 'm10', prospectId: 'demo-1', direction: MessageDirection.outbound, sender: MessageSender.klaris,
      content: "Merci! Joanel va te contacter d'ici 2 heures avec des options qui matchent. Belle journée!",
      sentAt: now.subtract(const Duration(minutes: 22))),
  ];

  static final relances = <Relance>[
    Relance(
      id: 'r1', prospectId: 'demo-4', prospectName: 'Olivier Beaulieu', prospectScore: 5,
      step: RelanceStep.j2, status: RelanceStatus.awaitingApproval,
      scheduledFor: now.add(const Duration(hours: 3)),
      content: "Bonjour Olivier, on continue les recherches Rosemont? J'ai vu 2 nouvelles options qui pourraient t'intéresser.",
      createdAt: now.subtract(const Duration(days: 2)),
    ),
    Relance(
      id: 'r2', prospectId: 'demo-3', prospectName: 'Nadia Lemieux', prospectScore: 7,
      step: RelanceStep.j2, status: RelanceStatus.pending,
      scheduledFor: now.add(const Duration(hours: 18)),
      content: "Bonjour Nadia, on planifie une évaluation de votre propriété cette semaine?",
      createdAt: now.subtract(const Duration(days: 1)),
    ),
    Relance(
      id: 'r3', prospectId: 'demo-5', prospectName: 'Geneviève Roy', prospectScore: 3,
      step: RelanceStep.j5, status: RelanceStatus.awaitingApproval,
      scheduledFor: now.subtract(const Duration(hours: 1)),
      content: "Bonjour Geneviève, des nouveautés dans NDG cette semaine. Toujours en recherche?",
      createdAt: now.subtract(const Duration(days: 5)),
    ),
  ];
}
