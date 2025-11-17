"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
const romanianNames = {
    clients: [
        { name: "Ana Popescu", email: "ana.popescu@gmail.com", city: "București", county: "Ilfov" },
        { name: "Mihai Ionescu", email: "mihai.ionescu@yahoo.com", city: "Cluj-Napoca", county: "Cluj" },
        { name: "Elena Gheorghe", email: "elena.gheorghe@gmail.com", city: "Timișoara", county: "Timiș" },
        { name: "Cristian Popa", email: "cristian.popa@gmail.com", city: "Iași", county: "Iași" },
        { name: "Maria Constantinescu", email: "maria.const@yahoo.com", city: "Constanța", county: "Constanța" },
        { name: "Alexandru Radu", email: "alex.radu@gmail.com", city: "Brașov", county: "Brașov" },
        { name: "Ioana Stoica", email: "ioana.stoica@gmail.com", city: "Galați", county: "Galați" },
        { name: "Bogdan Marin", email: "bogdan.marin@yahoo.com", city: "Craiova", county: "Dolj" },
        { name: "Andreea Vasile", email: "andreea.vasile@gmail.com", city: "Ploiești", county: "Prahova" },
        { name: "Daniel Tudor", email: "daniel.tudor@gmail.com", city: "Oradea", county: "Bihor" },
        { name: "Carmen Diaconu", email: "carmen.diaconu@yahoo.com", city: "Arad", county: "Arad" },
        { name: "Florin Manea", email: "florin.manea@gmail.com", city: "Pitești", county: "Argeș" },
        { name: "Raluca Neagu", email: "raluca.neagu@gmail.com", city: "Bacău", county: "Bacău" },
        { name: "Marius Georgescu", email: "marius.georgescu@yahoo.com", city: "Sibiu", county: "Sibiu" },
        { name: "Diana Mocanu", email: "diana.mocanu@gmail.com", city: "Târgu-Mureș", county: "Mureș" },
        { name: "Adrian Ciobanu", email: "adrian.ciobanu@gmail.com", city: "Baia Mare", county: "Maramureș" },
        { name: "Gabriela Stancu", email: "gabriela.stancu@yahoo.com", city: "Buzău", county: "Buzău" },
        { name: "Radu Florea", email: "radu.florea@gmail.com", city: "Botoșani", county: "Botoșani" },
        { name: "Simona Petrescu", email: "simona.petrescu@gmail.com", city: "Suceava", county: "Suceava" },
        { name: "Vlad Enescu", email: "vlad.enescu@yahoo.com", city: "Deva", county: "Hunedoara" }
    ],
    craftsmen: [
        {
            name: "Alexandru Mesteacăn",
            email: "alex.mesteacan@gmail.com",
            specialties: ["electrician", "instalator"],
            city: "București",
            county: "Ilfov",
            rating: 4.8,
            phone: "+40721123456",
            bio: "Electrician cu experiență de 15 ani. Specializat în instalații rezidențiale și comerciale."
        },
        {
            name: "Gheorghe Dulgheru",
            email: "gheo.dulgheru@yahoo.com",
            specialties: ["tâmplar", "renovări"],
            city: "Cluj-Napoca",
            county: "Cluj",
            rating: 4.6,
            phone: "+40721234567",
            bio: "Tâmplar meșter cu 12 ani experiență. Mobile personalizate și renovări complete."
        },
        {
            name: "Ion Fieraru",
            email: "ion.fieraru@gmail.com",
            specialties: ["fierar", "sudor"],
            city: "Timișoara",
            county: "Timiș",
            rating: 4.7,
            phone: "+40721345678",
            bio: "Fierar cu 20 de ani în meserie. Garduri, porți, balustrade și construcții metalice."
        },
        {
            name: "Vasile Instalatorul",
            email: "vasile.instalator@yahoo.com",
            specialties: ["instalator", "încălzire"],
            city: "Iași",
            county: "Iași",
            rating: 4.5,
            phone: "+40721456789",
            bio: "Instalator sanitar și termic. Centrală termică, încălzire în pardoseală, reparații."
        },
        {
            name: "Marin Zugravul",
            email: "marin.zugrav@gmail.com",
            specialties: ["zugrăvit", "vopsitorie"],
            city: "Constanța",
            county: "Constanța",
            rating: 4.4,
            phone: "+40721567890",
            bio: "Zugrav profesionist cu 10 ani experiență. Vopseluri ecologice și tehnici moderne."
        },
        {
            name: "Petru Pavelu",
            email: "petru.pavelu@yahoo.com",
            specialties: ["pavele", "amenajări exterioare"],
            city: "Brașov",
            county: "Brașov",
            rating: 4.9,
            phone: "+40721678901",
            bio: "Specialist în pavaje și amenajări exterioare. Alei, terase, parcări."
        },
        {
            name: "Costel Acoperișu",
            email: "costel.acoperis@gmail.com",
            specialties: ["acoperișuri", "izolații"],
            city: "Galați",
            county: "Galați",
            rating: 4.3,
            phone: "+40721789012",
            bio: "Meșter acoperișuri cu 18 ani experiență. Țiglă, tablă, membrana, izolații."
        },
        {
            name: "Florin Gresist",
            email: "florin.gresist@yahoo.com",
            specialties: ["gresie", "faianță", "placări"],
            city: "Craiova",
            county: "Dolj",
            rating: 4.6,
            phone: "+40721890123",
            bio: "Specialist în placări ceramice. Băi, bucătării, terrase - lucrări de calitate."
        }
    ]
};
const projectTemplates = [
    {
        title: "Reparații instalații electrice",
        description: "Schimbare prize și întrerupătoare în apartament de 3 camere. Verificare tablou electric și înlocuire siguranțe.",
        budget: "200-400 RON",
        category: "electrician",
        location: "București, Sector 3"
    },
    {
        title: "Montare mobilă bucătărie",
        description: "Montare completă mobilă bucătărie IKEA. Include montaj corpuri, blat, chiuvetă și electrocasnice.",
        budget: "400-600 RON",
        category: "tâmplar",
        location: "Cluj-Napoca, Centru"
    },
    {
        title: "Instalare centrală termică",
        description: "Montare centrală termică pe gaz, racorduri și punere în funcțiune. Apartament 2 camere.",
        budget: "800-1200 RON",
        category: "instalator",
        location: "Timișoara, Complexul Studențesc"
    },
    {
        title: "Zugrăvit apartament",
        description: "Zugrăvit complet apartament 4 camere. Șpaclu, grunduire, vopsitorie lavabilă.",
        budget: "1500-2000 RON",
        category: "zugrăvit",
        location: "Iași, Copou"
    },
    {
        title: "Reparații acoperiș",
        description: "Înlocuire țigle sparte și verificare izolație acoperiș casă. Aproximativ 50mp.",
        budget: "1000-1500 RON",
        category: "acoperișuri",
        location: "Constanța, Mamaia Nord"
    },
    {
        title: "Pavaj curte",
        description: "Pavare curte cu pavele din beton. Suprafața aproximativ 100mp. Include nivelare și compactare.",
        budget: "2000-3000 RON",
        category: "pavele",
        location: "Brașov, Tractorul"
    },
    {
        title: "Renovare baie",
        description: "Renovare completă baie: gresie, faianță, instalații sanitare, mobilier. Suprafață 6mp.",
        budget: "3000-5000 RON",
        category: "renovări",
        location: "Galați, Centru"
    },
    {
        title: "Sudură poartă metalică",
        description: "Reparații poartă metalică - sudură cadru rupt și vopsitorie antirugină.",
        budget: "300-500 RON",
        category: "fierar",
        location: "Craiova, 1 Mai"
    }
];
async function main() {
    console.log('🌱 Starting database seeding...');
    console.log('🗑️ Cleaning existing data...');
    await prisma.notification.deleteMany({});
    await prisma.review.deleteMany({});
    await prisma.offer.deleteMany({});
    await prisma.project.deleteMany({});
    await prisma.job.deleteMany({});
    await prisma.user.deleteMany({});
    console.log('👥 Creating clients...');
    const clients = [];
    for (const clientData of romanianNames.clients) {
        const client = await prisma.user.create({
            data: {
                email: clientData.email,
                firebaseUid: `client_${Math.random().toString(36).substring(2, 15)}`,
                fullName: clientData.name,
                role: client_1.UserRole.CLIENT,
                userType: client_1.UserType.INDIVIDUAL,
                city: clientData.city,
                county: clientData.county,
                specialties: [],
                isVerified: Math.random() > 0.3,
                averageRating: 5.0,
                totalReviews: 0,
            },
        });
        clients.push(client);
    }
    console.log('🔨 Creating craftsmen...');
    const craftsmen = [];
    for (const craftsmanData of romanianNames.craftsmen) {
        const craftsman = await prisma.user.create({
            data: {
                email: craftsmanData.email,
                firebaseUid: `craftsman_${Math.random().toString(36).substring(2, 15)}`,
                fullName: craftsmanData.name,
                role: client_1.UserRole.CRAFTSMAN,
                userType: client_1.UserType.INDIVIDUAL,
                city: craftsmanData.city,
                county: craftsmanData.county,
                specialties: craftsmanData.specialties,
                isVerified: true,
                averageRating: craftsmanData.rating,
                totalReviews: Math.floor(Math.random() * 50) + 10,
                phone: craftsmanData.phone,
                bio: craftsmanData.bio,
            },
        });
        craftsmen.push(craftsman);
    }
    console.log('📋 Creating jobs and projects...');
    const jobStatusOptions = [client_1.JobStatus.ACTIVE, client_1.JobStatus.ACCEPTED, client_1.JobStatus.IN_PROGRESS, client_1.JobStatus.COMPLETED];
    const projectStatusOptions = [client_1.ProjectStatus.FUNDED, client_1.ProjectStatus.ACTIVE, client_1.ProjectStatus.COMPLETED, client_1.ProjectStatus.CANCELLED];
    for (let i = 0; i < 50; i++) {
        const template = projectTemplates[i % projectTemplates.length];
        const client = clients[Math.floor(Math.random() * clients.length)];
        const jobStatus = jobStatusOptions[Math.floor(Math.random() * jobStatusOptions.length)];
        let category = client_1.JobCategory.ALTELE;
        if (template.category.includes('electrician'))
            category = client_1.JobCategory.ELECTRIK;
        else if (template.category.includes('instalator'))
            category = client_1.JobCategory.INSTALATII_SANITARE;
        else if (template.category.includes('constructii'))
            category = client_1.JobCategory.CONSTRUCTII;
        const job = await prisma.job.create({
            data: {
                title: `${template.title} ${i > 7 ? `#${i + 1}` : ''}`,
                description: template.description,
                category: category,
                location: template.location,
                city: client.city,
                budgetMin: 200,
                budgetMax: 1000,
                urgency: Math.random() > 0.7 ? client_1.UrgencyLevel.HIGH : Math.random() > 0.4 ? client_1.UrgencyLevel.MEDIUM : client_1.UrgencyLevel.LOW,
                status: jobStatus,
                clientId: client.id,
            },
        });
        if (jobStatus === client_1.JobStatus.ACTIVE && Math.random() > 0.5) {
            const numOffers = Math.floor(Math.random() * 3) + 1;
            for (let j = 0; j < numOffers; j++) {
                const craftsman = craftsmen[Math.floor(Math.random() * craftsmen.length)];
                await prisma.offer.create({
                    data: {
                        jobId: job.id,
                        craftsmanId: craftsman.id,
                        bidAmount: Math.floor(Math.random() * 800) + 200,
                        estimatedDays: Math.floor(Math.random() * 10) + 1,
                        notes: `Ofertă profesională pentru ${template.title.toLowerCase()}. Experiență demonstrată și materiale de calitate.`,
                    },
                });
            }
        }
        if (jobStatus !== client_1.JobStatus.ACTIVE) {
            const craftsman = craftsmen[Math.floor(Math.random() * craftsmen.length)];
            const projectStatus = projectStatusOptions[Math.floor(Math.random() * projectStatusOptions.length)];
            await prisma.project.create({
                data: {
                    title: job.title,
                    description: job.description,
                    totalBudget: Math.floor(Math.random() * 800) + 200,
                    status: projectStatus,
                    jobId: job.id,
                    clientId: client.id,
                    craftsmanId: craftsman.id,
                    agreedPrice: Math.floor(Math.random() * 800) + 200,
                    startDate: projectStatus !== client_1.ProjectStatus.FUNDED
                        ? new Date(Date.now() - Math.random() * 30 * 24 * 60 * 60 * 1000)
                        : null,
                    endDate: projectStatus === client_1.ProjectStatus.COMPLETED
                        ? new Date(Date.now() - Math.random() * 7 * 24 * 60 * 60 * 1000)
                        : null,
                },
            });
        }
    }
    console.log('✅ Database seeding completed!');
    console.log(`📊 Created:
    - ${clients.length} clients
    - ${craftsmen.length} craftsmen  
    - 50 projects with various statuses
    - Multiple offers and messages
  `);
}
main()
    .catch((e) => {
    console.error('❌ Seeding failed:', e);
    process.exit(1);
})
    .finally(async () => {
    await prisma.$disconnect();
});
//# sourceMappingURL=seed.js.map