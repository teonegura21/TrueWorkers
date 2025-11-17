import '../models/project_models.dart';

/// Mock project data for development and testing
final ActiveProject mockActiveProject = ActiveProject(
  id: 'proj_001',
  jobId: 'job_001',
  craftsmanId: 'craft_001',
  craftsmanName: 'Ion Popescu',
  craftsmanPhoto: '',
  craftsmanRating: 4.8,
  status: ProjectStatus.inProgress,
  projectTitle: 'Reparație robinet bucătărie și sistem țevi',
  description:
      'Se repară robinetul defect din bucătărie și se înlocuiește conducta de la chiuvetă până la punctul de curbură. Inclusiv teste de presiune.',
  milestones: [
    ProjectMilestone(
      id: 'm1',
      title: 'Demontare robinet vechi și inspectarea conductelor',
      description:
          'Se demontează sistemele existente și se verifică starea conductelor pentru eventualele defecte.',
      progress: 100,
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
      isCompleted: true,
      value: 150.0,
      status: 'completed',
    ),
    ProjectMilestone(
      id: 'm2',
      title: 'Achiziționarea materialelor necesare',
      description: 'Robinete noi, furtuncuri, garnituri și alte elemente necesare.',
      progress: 100,
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      isCompleted: true,
      value: 200.0,
      status: 'completed',
    ),
    ProjectMilestone(
      id: 'm3',
      title: 'Montare robinet nou și teste finale',
      description: 'Se instalează sistemul nou și se testează complet.',
      progress: 60,
      dueDate: DateTime.now().add(const Duration(days: 3)),
      isCompleted: false,
      value: 300.0,
      status: 'in_progress',
    ),
  ],
  completedMilestones: 2,
  messages: [
    ChatMessage(
      id: 'msg1',
      content: 'Bună ziua! Am să încep lucrul mâine dimineață la ora 9. Materialele sunt pregătite.',
      type: MessageType.craftsmanToClient,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    ChatMessage(
      id: 'msg2',
      content: 'Foarte bine, vă așteptăm. Cheile de la apartament vă așteaptă la vecina din porta.',
      type: MessageType.clientToCraftsman,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: true,
    ),
    ChatMessage(
      id: 'msg3',
      content: 'Sistemul de pornire a robinetului este aici. Robinetul are nevoie de înlocuire completă.',
      type: MessageType.craftsmanToClient,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
    ),
  ],
  totalValue: 850.0,
  paidAmount: 350.0,
  startDate: DateTime.now().subtract(const Duration(days: 3)),
  deadline: DateTime.now().add(const Duration(days: 3)),
  location: 'București, Sector 2',
  projectImages: [],
);

/// Additional mock projects for testing different states
final List<ActiveProject> mockProjectList = [
  mockActiveProject,
  // Alternative project states for QA
  mockActiveProject.copyWith(
    id: 'proj_pending',
    projectTitle: 'Instalare sistem încălzire pardoseală',
    status: ProjectStatus.pending,
  ),
  mockActiveProject.copyWith(
    id: 'proj_completed',
    projectTitle: 'Reparație ușă intrare',
    status: ProjectStatus.completed,
    completionDate: DateTime.now().subtract(const Duration(days: 1)),
  ),
];

/// Mock messages for testing
final List<ChatMessage> mockMessageList = [
  ChatMessage(
    id: 'system_1',
    content: 'Proiectul a fost creat cu succes. Meșterul va fi notificat.',
    type: MessageType.systemNotification,
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    isRead: true,
  ),
  ...mockActiveProject.messages,
];

/// Mock project statistics for testing
const mockProjectStats = {
  'totalProjects': 24,
  'activeProjects': 8,
  'completedProjects': 16,
  'averageRating': 4.7,
  'totalSpent': 15850.0,
};
