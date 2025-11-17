// Mock data for craftsman job discovery and testing

class CraftsmanJob {
  final String id;
  final String clientId;
  final String clientName;
  final double clientRating;
  final String title;
  final String description;
  final String category;
  final String subCategory;
  final int budgetMin;
  final int budgetMax;
  final String location;
  final double distance; // km from craftsman
  final DateTime deadline;
  final bool isUrgent;
  final DateTime postedDate;
  final int proposalsCount;
  final List<String> attachments;

  const CraftsmanJob({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientRating,
    required this.title,
    required this.description,
    required this.category,
    required this.subCategory,
    required this.budgetMin,
    required this.budgetMax,
    required this.location,
    required this.distance,
    required this.deadline,
    required this.isUrgent,
    required this.postedDate,
    required this.proposalsCount,
    required this.attachments,
  });

  // Convert to/from JSON for API compatibility
  factory CraftsmanJob.fromJson(Map<String, dynamic> json) {
    return CraftsmanJob(
      id: json['id'] ?? '',
      clientId: json['clientId'] ?? '',
      clientName: json['clientName'] ?? '',
      clientRating: (json['clientRating'] as num?)?.toDouble() ?? 0.0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',
      budgetMin: json['budgetMin'] ?? 0,
      budgetMax: json['budgetMax'] ?? 0,
      location: json['location'] ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : DateTime.now(),
      isUrgent: json['isUrgent'] ?? false,
      postedDate: json['postedDate'] != null ? DateTime.parse(json['postedDate']) : DateTime.now(),
      proposalsCount: json['proposalsCount'] ?? 0,
      attachments: List<String>.from(json['attachments'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'clientRating': clientRating,
      'title': title,
      'description': description,
      'category': category,
      'subCategory': subCategory,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'location': location,
      'distance': distance,
      'deadline': deadline.toIso8601String(),
      'isUrgent': isUrgent,
      'postedDate': postedDate.toIso8601String(),
      'proposalsCount': proposalsCount,
      'attachments': attachments,
    };
  }
}

// Mock data for development and testing
final List<CraftsmanJob> mockCraftsmanJobs = [
  CraftsmanJob(
    id: '1',
    clientId: 'client1',
    clientName: 'Maria Popescu',
    clientRating: 4.8,
    title: 'Reparație robinet bucătărie',
    description: 'Robinetul de bucătărie pierde apă continuu. Necesită urgent reparare. Situam București sector 3.',
    category: 'Instalații Sanitare',
    subCategory: 'Reparații robinete',
    budgetMin: 150,
    budgetMax: 250,
    location: 'București, Sector 3',
    distance: 12.5,
    deadline: DateTime.now().add(const Duration(days: 3)),
    isUrgent: true,
    postedDate: DateTime.now().subtract(const Duration(hours: 2)),
    proposalsCount: 3,
    attachments: ['photo1.jpg'],
  ),

  CraftsmanJob(
    id: '2',
    clientId: 'client2',
    clientName: 'Ion Dumitrescu',
    clientRating: 4.5,
    title: 'Montaj ușă de intrare',
    description: 'Necesit montaj ușă metalică 80x210cm. Totul este pregătit, trebuie doar montată.',
    category: 'Tâmplărie PVC',
    subCategory: 'Montaj se ușe',
    budgetMin: 200,
    budgetMax: 350,
    location: 'Otopeni',
    distance: 25.3,
    deadline: DateTime.now().add(const Duration(days: 7)),
    isUrgent: false,
    postedDate: DateTime.now().subtract(const Duration(hours: 5)),
    proposalsCount: 7,
    attachments: ['door-spec.pdf', 'door1.jpg', 'door2.jpg'],
  ),

  CraftsmanJob(
    id: '3',
    clientId: 'client3',
    clientName: 'Elena Alexandru',
    clientRating: 4.9,
    title: 'Vopsire apartament 3 camere',
    description: 'Apartament nou de vopsit. 3 camere + bucătărie + baie. Grăsim până pe februarie.',
    category: 'Zugrăveli & Finisaje',
    subCategory: 'Vopsire interior',
    budgetMin: 1500,
    budgetMax: 2200,
    location: 'Pantelimon',
    distance: 8.2,
    deadline: DateTime.now().add(const Duration(days: 60)),
    isUrgent: false,
    postedDate: DateTime.now().subtract(const Duration(hours: 8)),
    proposalsCount: 15,
    attachments: ['apartment1.jpg', 'apartment2.jpg', 'apartment3.jpg'],
  ),

  CraftsmanJob(
    id: '4',
    clientId: 'client4',
    clientName: 'Mihai Vasilescu',
    clientRating: 4.3,
    title: 'Înlocuire priză defectă',
    description: 'Priza din hol nu mai funcționează. Necesită urgent înlocuire. Apartament în clădirea cu vedere la lac.',
    category: 'Instalații Electrice',
    subCategory: 'Reparații electrice',
    budgetMin: 80,
    budgetMax: 120,
    location: 'Herăstrău',
    distance: 18.7,
    deadline: DateTime.now().add(const Duration(days: 1)),
    isUrgent: true,
    postedDate: DateTime.now().subtract(const Duration(hours: 12)),
    proposalsCount: 1,
    attachments: ['outlet-problem.jpg'],
  ),

  CraftsmanJob(
    id: '5',
    clientId: 'client5',
    clientName: 'Sofia Andrei',
    clientRating: 4.7,
    title: 'Montaj blat bucătărie complet',
    description: 'Montaj blat solid natural împreună cu electrocasnice integrate. Comandem împreună mobilierul.',
    category: 'Montaj Mobilier',
    subCategory: 'Mobiliere bucătărie',
    budgetMin: 1800,
    budgetMax: 2800,
    location: 'Ciolpani',
    distance: 32.1,
    deadline: DateTime.now().add(const Duration(days: 21)),
    isUrgent: false,
    postedDate: DateTime.now().subtract(const Duration(hours: 24)),
    proposalsCount: 9,
    attachments: ['kitchen-design.pdf', 'kitchen1.jpg', 'measurements.pdf'],
  ),

  CraftsmanJob(
    id: '6',
    clientId: 'client6',
    clientName: 'Alexandru Georgescu',
    clientRating: 4.6,
    title: 'Gresie și faianță baie',
    description: 'Baie recondiționată complet. Necesită montat gresie și faianță pe 12mp. Am materialul pregătit.',
    category: 'Gresie & Faianță',
    subCategory: 'Montaj gresie faianță',
    budgetMin: 800,
    budgetMax: 1200,
    location: 'Buftea',
    distance: 16.8,
    deadline: DateTime.now().add(const Duration(days: 14)),
    isUrgent: false,
    postedDate: DateTime.now().subtract(const Duration(hours: 18)),
    proposalsCount: 12,
    attachments: ['bathroom1.jpg', 'bathroom2.jpg', 'material-list.pdf'],
  ),

  CraftsmanJob(
    id: '7',
    clientId: 'client7',
    clientName: 'Bianca Moldovanu',
    clientRating: 4.9,
    title: 'Izolație termică acoperiș',
    description: 'Casă cu demisol + parter + mansardă. Necesită izolație acoperiș și pereți exteriori pentru iarnă.',
    category: 'Termoizolații',
    subCategory: 'Izolații acoperiș',
    budgetMin: 4500,
    budgetMax: 6500,
    location: 'Chitila',
    distance: 22.4,
    deadline: DateTime.now().add(const Duration(days: 45)),
    isUrgent: true,
    postedDate: DateTime.now().subtract(const Duration(hours: 36)),
    proposalsCount: 6,
    attachments: ['house-plans.pdf', 'roof-photos.jpg', 'specifications.pdf'],
  ),

  CraftsmanJob(
    id: '8',
    clientId: 'client8',
    clientName: 'Florin Apostol',
    clientRating: 4.4,
    title: 'Reparație centrală termică',
    description: 'Centrală termică Ariston nu funcționează coreaiș. Gestionat de la producător să verifice garanția.',
    category: 'Instalații de Gaz',
    subCategory: 'Centrale termice',
    budgetMin: 300,
    budgetMax: 450,
    location: 'Popești-Leordeni',
    distance: 28.9,
    deadline: DateTime.now().add(const Duration(days: 2)),
    isUrgent: true,
    postedDate: DateTime.now().subtract(const Duration(hours: 4)),
    proposalsCount: 4,
    attachments: ['heater-manual.pdf', 'error-code.jpg', 'warranty-card.pdf'],
  ),

  CraftsmanJob(
    id: '9',
    clientId: 'client9',
    clientName: 'Cristina Roman',
    clientRating: 4.8,
    title: 'Pardoseli laminate 2 camere',
    description: 'Două camere de dormit necesită pardoseli laminate. Materialul ales este deja acasă.',
    category: 'Parchet',
    subCategory: 'Montaj laminate',
    budgetMin: 600,
    budgetMax: 850,
    location: 'Otopeni',
    distance: 19.2,
    deadline: DateTime.now().add(const Duration(days: 10)),
    isUrgent: false,
    postedDate: DateTime.now().subtract(const Duration(hours: 30)),
    proposalsCount: 8,
    attachments: ['laminate-sample.jpg', 'room1-measure.jpg', 'room2-measure.jpg'],
  ),

  CraftsmanJob(
    id: '10',
    clientId: 'client10',
    clientName: 'Daniel Enache',
    clientRating: 4.2,
    title: 'Grădinarit proprietate 600mp',
    description: 'Proprietate nouă necesită amenajare peisagistică completă. Grad întreținut deja.',
    category: 'Grădinarit',
    subCategory: 'Amenajări peisagistice',
    budgetMin: 3200,
    budgetMax: 4800,
    location: 'Sinești',
    distance: 45.6,
    deadline: DateTime.now().add(const Duration(days: 30)),
    isUrgent: false,
    postedDate: DateTime.now().subtract(const Duration(hours: 48)),
    proposalsCount: 5,
    attachments: ['yard-design.pdf', 'current-state.jpg', 'your-desired.jpg'],
  ),
];
