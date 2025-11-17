import {
  PrismaClient,
  UserRole,
  UserType,
  JobCategory,
  JobStatus,
  ProjectStatus,
  UrgencyLevel,
  ContractStatus,
  ConversationType,
  ConversationParticipantRole,
  MessageKind,
  AttachmentStatus,
  AttachmentEntity,
  ProjectEventType,
} from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function clearDatabase() {
  console.log('🧹 Clearing existing data...');
  await prisma.attachmentLink.deleteMany();
  await prisma.attachment.deleteMany();
  await prisma.message.deleteMany();
  await prisma.conversationParticipant.deleteMany();
  await prisma.conversation.deleteMany();
  await prisma.contract.deleteMany();
  await prisma.projectEvent.deleteMany();
  await prisma.milestone.deleteMany();
  await prisma.project.deleteMany();
  await prisma.offer.deleteMany();
  await prisma.notification.deleteMany();
  await prisma.review.deleteMany();
  await prisma.job.deleteMany();
  await prisma.user.deleteMany();
  await prisma.retentionPolicy.deleteMany();
}

async function seedRetentionPolicies() {
  console.log('🗄️  Seeding retention policies...');
  const policies = [
    {
      code: 'STANDARD_GUARANTEE',
      description: 'Primary guarantee window for signed contracts and project artefacts.',
      activeDays: 180,
      archiveDays: 1080,
      hardDeleteAfterDays: null,
      requiresLegalReview: true,
    },
    {
      code: 'SUPPORT_THREAD',
      description: 'Default retention for support and messaging threads.',
      activeDays: 90,
      archiveDays: 365,
      hardDeleteAfterDays: null,
      requiresLegalReview: true,
    },
  ];

  for (const policy of policies) {
    await prisma.retentionPolicy.create({ data: policy });
  }
}

async function seedUsers() {
  console.log('👤 Seeding users...');
  const passwordHash = await bcrypt.hash('Secret123!', 10);

  // Client user (Teodor)
  const client = await prisma.user.create({
    data: {
      email: 'teodor.negura@mesteri.ro',
      passwordHash,
      fullName: 'Teodor Negura',
      city: 'București',
      county: 'București',
      address: 'Str. Universității 15',
      phone: '+40 723 999 888',
      userType: UserType.INDIVIDUAL,
      role: UserRole.CLIENT,
      profilePicture: 'https://i.pravatar.cc/300?img=12',
    },
  });

  // 8 Craftsmen with complete profiles
  const craftsmen = [];

  // 1. Ion Popescu - Instalator Sanitare
  craftsmen.push(await prisma.user.create({
    data: {
      email: 'ion.popescu@mesteri.ro',
      passwordHash,
      fullName: 'Ion Popescu',
      city: 'București',
      county: 'București',
      address: 'Bd. Basarabia 45',
      phone: '+40 724 111 222',
      userType: UserType.SRL,
      role: UserRole.CRAFTSMAN,
      isVerified: true,
      averageRating: 4.9,
      totalReviews: 127,
      profilePicture: 'https://i.pravatar.cc/300?img=33',
      bio: 'Meșter cu experiență în instalații sanitare. Lucrări garantate și materiale de calitate. Intervenții rapide în București și Ilfov.',
      yearsExperience: 15,
      portfolioPhotos: [
        'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=800',
        'https://images.unsplash.com/photo-1620626011761-996317b8d101?w=800',
        'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=800',
        'https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?w=800',
        'https://images.unsplash.com/photo-1604014237800-1c9102c219da?w=800',
        'https://images.unsplash.com/photo-1563298723-dcfebaa392e3?w=800',
        'https://images.unsplash.com/photo-1581858726788-75bc0f6a952d?w=800',
        'https://images.unsplash.com/photo-1595514535116-2e87e3883825?w=800',
      ],
      skillsTags: ['Instalații sanitare', 'Reparații robinete', 'Montaj centrale', 'Canalizări', 'Încălzire în pardoseală'],
      certifications: ['Autorizație ANRE', 'Certificat instalator gaze'],
      insuranceVerified: true,
      specialties: ['instalații sanitare', 'centrale termice'],
      availability: 'Disponibil din 28 octombrie',
    },
  }));

  // 2. Vasile Ionescu - Electrician
  craftsmen.push(await prisma.user.create({
    data: {
      email: 'vasile.ionescu@mesteri.ro',
      passwordHash,
      fullName: 'Vasile Ionescu',
      city: 'București',
      county: 'București',
      address: 'Str. Grivița 78',
      phone: '+40 725 333 444',
      userType: UserType.PFA,
      role: UserRole.CRAFTSMAN,
      isVerified: true,
      averageRating: 4.8,
      totalReviews: 98,
      profilePicture: 'https://i.pravatar.cc/300?img=52',
      bio: 'Electrician autorizat ANRE. Instalații electrice rezidențiale și comerciale. Montaj panouri fotovoltaice.',
      yearsExperience: 12,
      portfolioPhotos: [
        'https://images.unsplash.com/photo-1621905251918-48416bd8575a?w=800',
        'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?w=800',
        'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=800',
        'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=800',
        'https://images.unsplash.com/photo-1581092921461-eab62e97a780?w=800',
        'https://images.unsplash.com/photo-1621905252472-3d0c9a8b2fef?w=800',
        'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800',
        'https://images.unsplash.com/photo-1581092918056-0c4c3acd3789?w=800',
        'https://images.unsplash.com/photo-1581092583537-20d51b4b4f1b?w=800',
        'https://images.unsplash.com/photo-1581092162384-8987c1d64718?w=800',
      ],
      skillsTags: ['Instalații electrice', 'Tablouri electrice', 'Iluminat LED', 'Panouri fotovoltaice', 'Automatizări'],
      certifications: ['Autorizație ANRE electrician', 'Curs instalator fotovoltaic'],
      insuranceVerified: true,
      specialties: ['instalații electrice', 'automatizări'],
      availability: 'Disponibil acum',
    },
  }));

  // 3. Gheorghe Dumitrescu - Constructor
  craftsmen.push(await prisma.user.create({
    data: {
      email: 'gheorghe.dumitrescu@mesteri.ro',
      passwordHash,
      fullName: 'Gheorghe Dumitrescu',
      city: 'Cluj-Napoca',
      county: 'Cluj',
      address: 'Str. Dorobanților 23',
      phone: '+40 726 555 666',
      userType: UserType.SRL,
      role: UserRole.CRAFTSMAN,
      isVerified: true,
      averageRating: 4.95,
      totalReviews: 156,
      profilePicture: 'https://i.pravatar.cc/300?img=60',
      bio: 'Constructor cu peste 20 de ani experiență. Specialitate: structuri, zidărie, renovări complete. Echipă proprie.',
      yearsExperience: 20,
      portfolioPhotos: [
        'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=800',
        'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800',
        'https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=800',
        'https://images.unsplash.com/photo-1590486803833-1c5dc8ddd4c8?w=800',
        'https://images.unsplash.com/photo-1513828583688-c52646db42da?w=800',
        'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800',
        'https://images.unsplash.com/photo-1503594384566-461fe158e797?w=800',
        'https://images.unsplash.com/photo-1448630360428-65456885c650?w=800',
        'https://images.unsplash.com/photo-1599809275671-b5942cabc7a2?w=800',
        'https://images.unsplash.com/photo-1487958449943-2429e8be8625?w=800',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
        'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800',
        'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?w=800',
        'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=800',
        'https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=800',
      ],
      skillsTags: ['Construcții', 'Zidărie', 'Renovări', 'Structuri beton', 'Fundații', 'Mansardări'],
      certifications: ['Autorizație constructor', 'ISCIR'],
      insuranceVerified: true,
      specialties: ['construcții', 'renovări'],
      availability: 'Disponibil din noiembrie',
    },
  }));

  // 4. Maria Constantin - Zugrăveală & Finisaje
  craftsmen.push(await prisma.user.create({
    data: {
      email: 'maria.constantin@mesteri.ro',
      passwordHash,
      fullName: 'Maria Constantin',
      city: 'București',
      county: 'București',
      address: 'Str. Aviației 92',
      phone: '+40 727 777 888',
      userType: UserType.PFA,
      role: UserRole.CRAFTSMAN,
      isVerified: true,
      averageRating: 4.85,
      totalReviews: 84,
      profilePicture: 'https://i.pravatar.cc/300?img=47',
      bio: 'Specialistă în zugrăveli decorative și finisaje interioare. Atenție la detalii și finisaje impecabile.',
      yearsExperience: 8,
      portfolioPhotos: [
        'https://images.unsplash.com/photo-1562259949-e8e7689d7828?w=800',
        'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=800',
        'https://images.unsplash.com/photo-1615873968403-89e068629265?w=800',
        'https://images.unsplash.com/photo-1604709177225-055f99402ea3?w=800',
        'https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=800',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
        'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=800',
        'https://images.unsplash.com/photo-1615873968403-89e068629265?w=800',
        'https://images.unsplash.com/photo-1615874959474-d609969a20ed?w=800',
        'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=800',
        'https://images.unsplash.com/photo-1616137422495-6c7ef40d0f13?w=800',
        'https://images.unsplash.com/photo-1616486029423-aaa4789e8c9a?w=800',
      ],
      skillsTags: ['Zugrăveli', 'Vopsitorie', 'Finisaje', 'Tencuieli decorative', 'Șpaclu', 'Tapet'],
      certifications: ['Curs finisaje decorative'],
      insuranceVerified: false,
      specialties: ['zugrăveli', 'finisaje'],
      availability: 'Disponibil acum',
    },
  }));

  // 5. Andrei Popa - Tâmplar
  craftsmen.push(await prisma.user.create({
    data: {
      email: 'andrei.popa@mesteri.ro',
      passwordHash,
      fullName: 'Andrei Popa',
      city: 'Timișoara',
      county: 'Timiș',
      address: 'Str. Fabricii 45',
      phone: '+40 728 123 456',
      userType: UserType.PFA,
      role: UserRole.CRAFTSMAN,
      isVerified: true,
      averageRating: 4.92,
      totalReviews: 73,
      profilePicture: 'https://i.pravatar.cc/300?img=15',
      bio: 'Tâmplar cu pasiune pentru lemn masiv. Mobilier custom, parchet, scări interioare. Atelier propriu.',
      yearsExperience: 10,
      portfolioPhotos: [
        'https://images.unsplash.com/photo-1602872030219-ad2b9a54315c?w=800',
        'https://images.unsplash.com/photo-1617806118233-18e1de247200?w=800',
        'https://images.unsplash.com/photo-1615971677499-5467cbab01c0?w=800',
        'https://images.unsplash.com/photo-1556228453-efd6c1ff04f6?w=800',
        'https://images.unsplash.com/photo-1610810434142-8ae9e4135940?w=800',
        'https://images.unsplash.com/photo-1594026112284-02bb6f3352fe?w=800',
        'https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=800',
        'https://images.unsplash.com/photo-1600585154363-67eb9e2e2099?w=800',
        'https://images.unsplash.com/photo-1616047006789-b7af5afb8c20?w=800',
      ],
      skillsTags: ['Tâmplărie', 'Mobilier custom', 'Parchet', 'Scări interioare', 'Uși', 'Ferestre lemn'],
      certifications: ['Curs tâmplărie'],
      insuranceVerified: true,
      specialties: ['tâmplărie', 'mobilier'],
      availability: 'Disponibil din noiembrie',
    },
  }));

  // 6. Elena Marinescu - Designer Interior
  craftsmen.push(await prisma.user.create({
    data: {
      email: 'elena.marinescu@mesteri.ro',
      passwordHash,
      fullName: 'Elena Marinescu',
      city: 'București',
      county: 'București',
      address: 'Bd. Magheru 12',
      phone: '+40 729 999 111',
      userType: UserType.PFA,
      role: UserRole.CRAFTSMAN,
      isVerified: true,
      averageRating: 4.88,
      totalReviews: 52,
      profilePicture: 'https://i.pravatar.cc/300?img=48',
      bio: 'Designer de interior cu viziune modernă. Consultanță, proiectare 3D, coordonare lucrări. Stiluri: minimalist, scandinav, industrial.',
      yearsExperience: 7,
      portfolioPhotos: [
        'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=800',
        'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=800',
        'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800',
        'https://images.unsplash.com/photo-1600210491892-03d54c0aaf87?w=800',
        'https://images.unsplash.com/photo-1600566753151-384129cf4e3e?w=800',
        'https://images.unsplash.com/photo-1615874959474-d609969a20ed?w=800',
        'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=800',
        'https://images.unsplash.com/photo-1616137422495-6c7ef40d0f13?w=800',
      ],
      skillsTags: ['Design interior', 'Consultanță', 'Renovări', 'Proiectare 3D', 'Amenajări moderne'],
      certifications: ['Diplomă design interior', 'AutoCAD', '3DS Max'],
      insuranceVerified: false,
      specialties: ['design interior', 'consultanță'],
      availability: 'Disponibil acum',
    },
  }));

  // 7. Mihai Georgescu - Instalații Termice
  craftsmen.push(await prisma.user.create({
    data: {
      email: 'mihai.georgescu@mesteri.ro',
      passwordHash,
      fullName: 'Mihai Georgescu',
      city: 'Cluj-Napoca',
      county: 'Cluj',
      address: 'Str. Memorandumului 88',
      phone: '+40 730 222 333',
      userType: UserType.SRL,
      role: UserRole.CRAFTSMAN,
      isVerified: true,
      averageRating: 4.91,
      totalReviews: 109,
      profilePicture: 'https://i.pravatar.cc/300?img=56',
      bio: 'Specialist în climatizare și încălzire. Pompe de căldură, sisteme VRV, încălzire în pardoseală. Service autorizat.',
      yearsExperience: 14,
      portfolioPhotos: [
        'https://images.unsplash.com/photo-1621905251918-48416bd8575a?w=800',
        'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=800',
        'https://images.unsplash.com/photo-1581092921461-eab62e97a780?w=800',
        'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=800',
        'https://images.unsplash.com/photo-1620626011761-996317b8d101?w=800',
        'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=800',
        'https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?w=800',
      ],
      skillsTags: ['Climatizare', 'Încălzire', 'Pompe de căldură', 'VRV', 'Încălzire pardoseală', 'Service AC'],
      certifications: ['Autorizație ANRE', 'Certificat F-gaze', 'Service AC'],
      insuranceVerified: true,
      specialties: ['climatizare', 'încălzire'],
      availability: 'Ocupat până în decembrie',
    },
  }));

  // 8. Cristina Moldoveanu - Curățenie Profesională
  craftsmen.push(await prisma.user.create({
    data: {
      email: 'cristina.moldoveanu@mesteri.ro',
      passwordHash,
      fullName: 'Cristina Moldoveanu',
      city: 'București',
      county: 'București',
      address: 'Str. Pantelimon 156',
      phone: '+40 731 444 555',
      userType: UserType.PFA,
      role: UserRole.CRAFTSMAN,
      isVerified: true,
      averageRating: 4.87,
      totalReviews: 142,
      profilePicture: 'https://i.pravatar.cc/300?img=44',
      bio: 'Servicii de curățenie profesională. Specializare: curățenie după renovări, deep cleaning, birouri. Echipă și echipamente profesionale.',
      yearsExperience: 5,
      portfolioPhotos: [
        'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800',
        'https://images.unsplash.com/photo-1585421514738-01798e348b17?w=800',
        'https://images.unsplash.com/photo-1628177142898-93e36e4e3a50?w=800',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
        'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=800',
        'https://images.unsplash.com/photo-1600566753151-384129cf4e3e?w=800',
      ],
      skillsTags: ['Curățenie după renovări', 'Deep cleaning', 'Curățenie birouri', 'Dezinfecție', 'Geamuri'],
      certifications: ['Curs curățenie profesională'],
      insuranceVerified: false,
      specialties: ['curățenie', 'întreținere'],
      availability: 'Disponibil acum',
    },
  }));

  // Admin user
  const admin = await prisma.user.create({
    data: {
      email: 'admin@mesteri.ro',
      passwordHash,
      fullName: 'Admin Mesteri',
      city: 'București',
      county: 'București',
      role: UserRole.ADMIN,
    },
  });

  return { client, craftsmen, admin };
}

async function seedProjectData(clientId: string, craftsmanId: string) {
  console.log('🏗️  Seeding project, contract & messaging data...');

  const job = await prisma.job.create({
    data: {
      title: 'Renovare baie garsonieră',
      description: 'Demontare mobilier, montaj gresie și faianță, instalare obiecte sanitare.',
      category: JobCategory.CONSTRUCTII,
      location: 'Str. Lalelelor 3, București',
      city: 'București',
      budgetMin: 3000,
      budgetMax: 4500,
      urgency: UrgencyLevel.MEDIUM,
      status: JobStatus.ACCEPTED,
      clientId,
      mediaUrls: [
        'gs://mesteri-dev/project-photos/job-001/before-1.jpg',
      ],
    },
  });

  await prisma.offer.create({
    data: {
      jobId: job.id,
      craftsmanId,
      bidAmount: 4200,
      estimatedDays: 5,
      notes: 'Include transport materiale și evacuare moloz.',
    },
  });

  const project = await prisma.project.create({
    data: {
      jobId: job.id,
      clientId,
      craftsmanId,
      title: 'Renovare baie Popescu',
      description: 'Coordonare completă renovare baie garsonieră.',
      totalBudget: 4300,
      agreedPrice: 4200,
      status: ProjectStatus.ACTIVE,
      progressPercent: 20,
      startDate: new Date(),
      galleryUrls: [],
      milestones: [{
        title: 'Demontare',
        completed: false,
      }],
    },
  });

  await prisma.milestone.create({
    data: {
      projectId: project.id,
      title: 'Demontare mobilier existent',
      description: 'Demontare completă și evacuare obiecte vechi.',
      status: 'in_progress',
      dueDate: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000),
    },
  });

  const standardPolicy = await prisma.retentionPolicy.findUniqueOrThrow({
    where: { code: 'STANDARD_GUARANTEE' },
  });

  const supportPolicy = await prisma.retentionPolicy.findUniqueOrThrow({
    where: { code: 'SUPPORT_THREAD' },
  });

  const contract = await prisma.contract.create({
    data: {
      projectId: project.id,
      version: 1,
      status: ContractStatus.SIGNED,
      clientSignedAt: new Date(),
      mesterSignedAt: new Date(),
      guaranteeExpiresAt: new Date(Date.now() + 180 * 24 * 60 * 60 * 1000),
      retentionPolicyId: standardPolicy.id,
      storageObjectPath: 'gs://mesteri-dev/contracts/contract-001.pdf',
      hashSha256: 'dummyhash123',
    },
  });

  await prisma.project.update({
    where: { id: project.id },
    data: {
      primaryContractId: contract.id,
      guaranteeExpiresAt: contract.guaranteeExpiresAt,
    },
  });

  const conversation = await prisma.conversation.create({
    data: {
      projectId: project.id,
      type: ConversationType.PROJECT,
      createdById: clientId,
      retentionPolicyId: supportPolicy.id,
    },
  });

  await prisma.project.update({
    where: { id: project.id },
    data: {
      primaryConversationId: conversation.id,
    },
  });

  await prisma.conversationParticipant.createMany({
    data: [
      {
        conversationId: conversation.id,
        userId: clientId,
        role: ConversationParticipantRole.CLIENT,
      },
      {
        conversationId: conversation.id,
        userId: craftsmanId,
        role: ConversationParticipantRole.MESTER,
      },
    ],
  });

  const message = await prisma.message.create({
    data: {
      conversationId: conversation.id,
      senderId: clientId,
      kind: MessageKind.TEXT,
      body: 'Bună, Mihai! Am atașat pozele cu baia înainte de renovare.',
      retentionPolicyId: supportPolicy.id,
    },
  });

  const attachment = await prisma.attachment.create({
    data: {
      bucket: 'mesteri-dev',
      objectPath: 'project-photos/job-001/before-1.jpg',
      contentType: 'image/jpeg',
      fileSize: 1024 * 450,
      checksumSha256: 'dummychecksum123',
      uploadedById: clientId,
      retentionPolicyId: supportPolicy.id,
      status: AttachmentStatus.ACTIVE,
    },
  });

  await prisma.attachmentLink.create({
    data: {
      attachmentId: attachment.id,
      entityType: AttachmentEntity.MESSAGE,
      entityId: message.id,
      role: 'BEFORE_PHOTO',
    },
  });

  await prisma.projectEvent.create({
    data: {
      projectId: project.id,
      actorId: craftsmanId,
      eventType: ProjectEventType.STATUS_CHANGE,
      payload: {
        from: 'PLANNED',
        to: 'IN_PROGRESS',
        note: 'Echipa a început demontarea mobilierului.',
      },
    },
  });
}

// PHASE 2: Seed Inspiration Posts (TikTok-style feed)
async function seedInspirationPosts(craftsmen: any[]) {
  console.log('✨ Seeding inspiration posts...');

  const posts = [
    // Ion Popescu - Instalator Sanitare (5 posts)
    {
      craftsmanId: craftsmen[0].id,
      title: 'Renovare baie completă - Sector 3',
      description: 'Transformare totală baie veche. Montaj gresie mare format, instalaţii sanitare noi, cabină dus walk-in. Materiale premium, finisaje impecabile. Durată: 7 zile.',
      beforePhoto: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=800',
      afterPhoto: 'https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?w=800',
      additionalPhotos: [
        'https://images.unsplash.com/photo-1620626011761-996317b8d101?w=800',
        'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=800',
      ],
      skillsShowcased: ['Instalații sanitare', 'Montaj gresie', 'Cabină dus'],
      category: 'INSTALATII_SANITARE',
      location: 'Str. Vitan 45, București',
      city: 'București',
      likes: 142,
      views: 2341,
      shares: 23,
    },
    {
      craftsmanId: craftsmen[0].id,
      title: 'Montare centrală termică condensație',
      description: 'Instalare centrală Vaillant condensație + sistem încălzire în pardoseală living 45mp. Eficienţă maximă, consum redus.',
      afterPhoto: 'https://images.unsplash.com/photo-1581858726788-75bc0f6a952d?w=800',
      additionalPhotos: ['https://images.unsplash.com/photo-1595514535116-2e87e3883825?w=800'],
      skillsShowcased: ['Centrale termice', 'Încălzire pardoseală'],
      location: 'Drumul Taberei, București',
      city: 'București',
      likes: 89,
      views: 1523,
      shares: 12,
    },
    // Vasile Ionescu - Electrician (6 posts)
    {
      craftsmanId: craftsmen[1].id,
      title: 'Tablou electric modern - casă 200mp',
      description: 'Tablou electric ABB complet automatizat cu protecții diferențiale pe fiecare circuit. Etichetare profesională, organizare impecabilă.',
      afterPhoto: 'https://images.unsplash.com/photo-1621905251918-48416bd8575a?w=800',
      additionalPhotos: [
        'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=800',
        'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=800',
      ],
      skillsShowcased: ['Tablouri electrice', 'Instalații electrice'],
      location: 'Pipera, București',
      city: 'București',
      likes: 234,
      views: 3892,
      shares: 45,
      isPromoted: true,
      promotionEnds: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000),
    },
    {
      craftsmanId: craftsmen[1].id,
      title: 'Sistem panouri fotovoltaice 8kW',
      description: 'Instalare 20 panouri fotovoltaice cu invertor hibrid. Economie 90% la factura de electricitate. Soluție eco-friendly pentru viitor!',
      afterPhoto: 'https://images.unsplash.com/photo-1581092918056-0c4c3acd3789?w=800',
      additionalPhotos: [
        'https://images.unsplash.com/photo-1581092583537-20d51b4b4f1b?w=800',
        'https://images.unsplash.com/photo-1581092162384-8987c1d64718?w=800',
      ],
      skillsShowcased: ['Panouri fotovoltaice', 'Instalații electrice'],
      location: 'Clinceni, Ilfov',
      city: 'București',
      likes: 312,
      views: 5234,
      shares: 67,
    },
    // Gheorghe Dumitrescu - Constructor (7 posts)
    {
      craftsmanId: craftsmen[2].id,
      title: 'Casă nouă 180mp - de la fundație la acoperiș',
      description: 'Construcție completă casă pe structură BCA + cărămidă. Fundații, zidărie, acoperiș țiglă. Execuție 6 luni. Garanție 10 ani structură!',
      beforePhoto: 'https://images.unsplash.com/photo-1590486803833-1c5dc8ddd4c8?w=800',
      afterPhoto: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
      additionalPhotos: [
        'https://images.unsplash.com/photo-1503594384566-461fe158e797?w=800',
        'https://images.unsplash.com/photo-1599809275671-b5942cabc7a2?w=800',
        'https://images.unsplash.com/photo-1448630360428-65456885c650?w=800',
      ],
      skillsShowcased: ['Construcții', 'Zidărie', 'Fundații', 'Acoperiș'],
      category: 'CONSTRUCTII',
      location: 'Florești, Cluj',
      city: 'Cluj-Napoca',
      likes: 567,
      views: 8934,
      shares: 123,
      isPinned: true,
    },
    // Add more posts for other craftsmen
    {
      craftsmanId: craftsmen[3].id, // Maria Constantin - Zugrăveală
      title: 'Zugrăveală living modern 60mp',
      description: 'Zugrăveală și tencuială decorativă living. Finisaj mat elegant, colori calde. Atenție la detalii!',
      beforePhoto: 'https://images.unsplash.com/photo-1604709177225-055f99402ea3?w=800',
      afterPhoto: 'https://images.unsplash.com/photo-1615873968403-89e068629265?w=800',
      additionalPhotos: [
        'https://images.unsplash.com/photo-1616137422495-6c7ef40d0f13?w=800',
      ],
      skillsShowcased: ['Zugrăveli', 'Tencuieli decorative'],
      location: 'Avrigilor, București',
      city: 'București',
      likes: 156,
      views: 2891,
      shares: 34,
    },
    {
      craftsmanId: craftsmen[4].id, // Andrei Popa - Tâmplar
      title: 'Bibliotecă custom din lemn masiv',
      description: 'Mobilier custom din stejar masiv. Proiect unic, finisaje manuale, atenție la fiecare detaliu.',
      afterPhoto: 'https://images.unsplash.com/photo-1602872030219-ad2b9a54315c?w=800',
      additionalPhotos: [
        'https://images.unsplash.com/photo-1617806118233-18e1de247200?w=800',
        'https://images.unsplash.com/photo-1615971677499-5467cbab01c0?w=800',
      ],
      skillsShowcased: ['Tâmplărie', 'Mobilier custom'],
      location: 'Timișoara',
      city: 'Timișoara',
      likes: 278,
      views: 4123,
      shares: 56,
    },
    {
      craftsmanId: craftsmen[5].id, // Elena Marinescu - Designer
      title: 'Amenajare apartament 3 camere stil minimalist',
      description: 'Design complet apartament 85mp. Stil minimalist-scandinav. Paleta neutră, funcționalitate maximă.',
      beforePhoto: 'https://images.unsplash.com/photo-1600210491892-03d54c0aaf87?w=800',
      afterPhoto: 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=800',
      additionalPhotos: [
        'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=800',
        'https://images.unsplash.com/photo-1615874959474-d609969a20ed?w=800',
      ],
      skillsShowcased: ['Design interior', 'Amenajări moderne'],
      location: 'Dorobanți, București',
      city: 'București',
      likes: 423,
      views: 6234,
      shares: 89,
    },
    {
      craftsmanId: craftsmen[6].id, // Mihai Georgescu - Instalații Termice
      title: 'Sistem climatizare VRV casă 300mp',
      description: 'Instalare sistem VRV Daikin cu 8 unități interioare. Climatizare și încălzire eficientă în toată casa.',
      afterPhoto: 'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=800',
      skillsShowcased: ['Climatizare', 'VRV'],
      location: 'Buna Ziua, Cluj-Napoca',
      city: 'Cluj-Napoca',
      likes: 198,
      views: 3456,
      shares: 41,
    },
  ];

  // Create all inspiration posts
  for (const postData of posts) {
    await prisma.inspirationPost.create({
      data: postData,
    });
  }

  console.log(`✅ Created ${posts.length} inspiration posts`);
}

// Seed reviews for craftsmen
async function seedReviews(client: any, craftsmen: any[]) {
  console.log('⭐ Seeding reviews...');

  const reviews = [
    {
      reviewerId: client.id,
      revieweeId: craftsmen[0].id,
      projectId: 'dummy-project-1',
      rating: 5,
      comment: 'Lucru impecabil! Ion a fost foarte profesionist. A terminat baia la timp și cu materiale de calitate. Recomand cu încredere!',
      status: 'approved',
      tags: ['profesionist', 'punctual', 'calitate'],
      helpfulCount: 12,
    },
    {
      reviewerId: client.id,
      revieweeId: craftsmen[1].id,
      projectId: 'dummy-project-2',
      rating: 5,
      comment: 'Vasile a instalat tabloul electric perfect. Foarte atent la detalii, totul etichetat frumos. Mulțumit!',
      status: 'approved',
      tags: ['atenție la detalii', 'profesional'],
      helpfulCount: 8,
    },
  ];

  for (const review of reviews) {
    await prisma.review.create({
      data: review,
    });
  }

  console.log(`✅ Created ${reviews.length} reviews`);
}

async function main() {
  await clearDatabase();
  await seedRetentionPolicies();
  const { client, craftsmen, admin } = await seedUsers();
  await seedProjectData(client.id, craftsmen[0].id);
  await seedInspirationPosts(craftsmen);
  await seedReviews(client, craftsmen);

  console.log('✅ Seed completed successfully.');
  console.log(`✅ Created ${craftsmen.length} craftsmen with complete profiles`);
  console.log('✅ Database ready for MVP development!');
}

main()
  .catch((error) => {
    console.error('❌ Seed failed:', error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
