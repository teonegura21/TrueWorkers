

enum JobStatus { offersReceived, inProgress, completed }

class Offer {
  final String mesterName;
  final double price;
  final String details;

  Offer({required this.mesterName, required this.price, required this.details});
}

class Craftsman {
  final String name;
  final double rating;
  final double responseTime;
  final int completedProjects;
  final List<String> trustBadges;

  const Craftsman({
    required this.name,
    required this.rating,
    required this.responseTime,
    required this.completedProjects,
    this.trustBadges = const [],
  });
}

class Job {
  final String id;
  final String title;
  final String description;
  final String location;
  final String category;
  final int budgetMin;
  final int budgetMax;
  final JobStatus status;
  final List<Offer> offers;
  final List<Craftsman> craftsmenAvailable;
  final Offer? acceptedOffer;
  final double? finalPrice;
  final double? rating;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.budgetMin,
    required this.budgetMax,
    required this.status,
    this.offers = const [],
    this.craftsmenAvailable = const [],
    this.acceptedOffer,
    this.finalPrice,
    this.rating,
  });
}

final List<Job> mockJobs = [
  // Offers Received
  Job(
    id: 'job_001',
    title: 'Reparație acoperiș',
    description: 'Scurgeri în zona coșului de fum. Necesită inspecție și reparație urgentă.',
    location: 'București, Sector 1',
    category: 'Construcții',
    budgetMin: 400,
    budgetMax: 700,
    status: JobStatus.offersReceived,
    craftsmenAvailable: const [
      Craftsman(name: 'Ion Popescu', rating: 4.3, responseTime: 2, completedProjects: 15, trustBadges: ['Verified']),
      Craftsman(name: 'Vasile Ionescu', rating: 4.7, responseTime: 1, completedProjects: 23, trustBadges: ['Verified', 'Premium']),
      Craftsman(name: 'Gheorghe Marinescu', rating: 4.9, responseTime: 3, completedProjects: 45, trustBadges: ['Verified', 'Premium']),
    ],
    offers: [
      Offer(mesterName: 'Ion Popescu', price: 500, details: 'Pot veni mâine, materialele incluse.'),
      Offer(mesterName: 'Vasile Ionescu', price: 450, details: 'Disponibil de săptămâna viitoare.'),
      Offer(mesterName: 'Gheorghe Marinescu', price: 600, details: 'Ofer garanție 2 ani.'),
    ],
  ),
  Job(
    id: 'job_002',
    title: 'Zugrăvit apartament 2 camere',
    description: 'Zugrăvit lavabil alb, pereți și tavan. Aproximativ 60 mp de suprafață.',
    location: 'Cluj-Napoca, Zona Centru',
    category: 'Zugrăveli',
    budgetMin: 800,
    budgetMax: 1500,
    status: JobStatus.offersReceived,
    craftsmenAvailable: const [
      Craftsman(name: 'Mesterul Manole', rating: 4.8, responseTime: 2, completedProjects: 37, trustBadges: ['Verified', 'Premium']),
    ],
    offers: [
      Offer(mesterName: 'Mesterul Manole', price: 1200, details: 'Timp de execuție: 3 zile.'),
    ],
  ),

  // In Progress
  Job(
    id: 'job_003',
    title: 'Montaj parchet laminat',
    description: 'Montaj parchet și plintă pentru un dormitor de 15 mp.',
    location: 'București, Sector 3',
    category: 'Montaj Mobilier',
    budgetMin: 250,
    budgetMax: 450,
    status: JobStatus.inProgress,
    craftsmenAvailable: const [
      Craftsman(name: 'Andrei Georgescu', rating: 4.6, responseTime: 1, completedProjects: 28, trustBadges: ['Verified']),
    ],
    acceptedOffer: Offer(mesterName: 'Andrei Georgescu', price: 350, details: 'Încep lucrarea pe 10 Septembrie.'),
  ),
  Job(
    id: 'job_004',
    title: 'Instalare aer condiționat',
    description: 'Instalare unitate AC de 12000 BTU, include kit-ul de instalare.',
    location: 'Cluj-Napoca, Zona Iulius Mall',
    category: 'Instalații Termice',
    budgetMin: 300,
    budgetMax: 500,
    status: JobStatus.inProgress,
    craftsmenAvailable: const [
      Craftsman(name: 'SC Clima SRL', rating: 4.9, responseTime: 4, completedProjects: 67, trustBadges: ['Verified', 'Premium']),
    ],
    acceptedOffer: Offer(mesterName: 'SC Clima SRL', price: 400, details: 'Echipa ajunge la ora 14:00.'),
  ),

  // Completed
  Job(
    id: 'job_005',
    title: 'Schimbat priză baie',
    description: 'Priza veche s-a ars, trebuie înlocuită cu una nouă cu protecție la umiditate.',
    location: 'București, Sector 2',
    category: 'Electrik',
    budgetMin: 120,
    budgetMax: 200,
    status: JobStatus.completed,
    craftsmenAvailable: const [
      Craftsman(name: 'Electrician Rapid', rating: 5.0, responseTime: 0.5, completedProjects: 89, trustBadges: ['Verified', 'Premium']),
    ],
    acceptedOffer: Offer(mesterName: 'Electrician Rapid', price: 150, details: 'Lucrare finalizată.'),
    finalPrice: 150,
    rating: 5,
  ),
  Job(
    id: 'job_006',
    title: 'Curățenie generală după constructor',
    description: 'Curățenie completă apartament 3 camere după renovare.',
    location: 'Cluj-Napoca, Zona Gheorgheni',
    category: 'Reparații Acasă',
    budgetMin: 600,
    budgetMax: 900,
    status: JobStatus.completed,
    craftsmenAvailable: const [
      Craftsman(name: 'Curat Lună SRL', rating: 4.7, responseTime: 3, completedProjects: 124, trustBadges: ['Verified', 'Premium']),
    ],
    acceptedOffer: Offer(mesterName: 'Curat Lună SRL', price: 800, details: 'Servicii profesionale.'),
    finalPrice: 850, // with extra services
    rating: 4.5,
  ),
];

final List<Job> jobsWithOffers = mockJobs.where((job) => job.status == JobStatus.offersReceived).toList();
final List<Job> jobsInProgress = mockJobs.where((job) => job.status == JobStatus.inProgress).toList();
final List<Job> jobsCompleted = mockJobs.where((job) => job.status == JobStatus.completed).toList();

// Combined all jobs for search functionality
final List<Job> allJobs = List.from(mockJobs);
