"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
async function main() {
    console.log('🌱 Seeding contract test data...');
    const retentionPolicy = await prisma.retentionPolicy.upsert({
        where: { code: 'STANDARD_GUARANTEE' },
        update: {},
        create: {
            code: 'STANDARD_GUARANTEE',
            description: 'Standard 12-month guarantee for completed work',
            activeDays: 365,
            archiveDays: 1825,
            hardDeleteAfterDays: 3650,
            requiresLegalReview: false,
        },
    });
    console.log('✓ Retention policy ready');
    const client = await prisma.user.upsert({
        where: { email: 'client.test@mesteri.ro' },
        update: {},
        create: {
            email: 'client.test@mesteri.ro',
            fullName: 'Ana Popescu',
            role: client_1.UserRole.CLIENT,
            city: 'București',
            county: 'București',
            address: 'Str. Victoriei nr. 10',
            phone: '+40721234567',
        },
    });
    console.log(`✓ Client created: ${client.fullName}`);
    const craftsman = await prisma.user.upsert({
        where: { email: 'mester.test@mesteri.ro' },
        update: {},
        create: {
            email: 'mester.test@mesteri.ro',
            fullName: 'Ion Ionescu',
            role: client_1.UserRole.CRAFTSMAN,
            city: 'București',
            county: 'București',
            address: 'Str. Moților nr. 5',
            phone: '+40722345678',
            specialties: ['Instalații sanitare', 'Zugrăvit', 'Gresie și faianță'],
            yearsExperience: 10,
            isVerified: true,
        },
    });
    console.log(`✓ Craftsman created: ${craftsman.fullName}`);
    const job = await prisma.job.upsert({
        where: { id: 'test-job-contract-001' },
        update: {},
        create: {
            id: 'test-job-contract-001',
            title: 'Renovare Apartament 2 Camere',
            description: 'Renovare completă apartament: zugrăvit, parchet, gresie baie și bucătărie. Include materiale.',
            category: client_1.JobCategory.CONSTRUCTII,
            location: 'Sector 1, București',
            city: 'București',
            budgetMin: 4000,
            budgetMax: 6000,
            urgency: client_1.UrgencyLevel.MEDIUM,
            status: client_1.JobStatus.ACCEPTED,
            clientId: client.id,
        },
    });
    console.log(`✓ Job created: ${job.title}`);
    const project = await prisma.project.upsert({
        where: { jobId: job.id },
        update: {},
        create: {
            title: 'Renovare Apartament Ana Popescu',
            description: 'Proiect de renovare completă conform discuțiilor. Materiale incluse în preț.',
            totalBudget: 4800,
            status: client_1.ProjectStatus.FUNDED,
            jobId: job.id,
            clientId: client.id,
            craftsmanId: craftsman.id,
            agreedPrice: 4800,
            startDate: new Date('2025-12-01'),
            deadline: new Date('2025-12-20'),
        },
    });
    console.log(`✓ Project created: ${project.id}`);
    console.log('\n✅ Seeding complete! Test data ready.\n');
    console.log('📋 Test Users:');
    console.log(`   Client: ${client.email}`);
    console.log(`   Craftsman: ${craftsman.email}`);
    console.log(`\n📦 Test Project ID: ${project.id}`);
    console.log(`\n🚀 You can now test contract creation with:`);
    console.log(`   POST http://localhost:3000/contracts/project/${project.id}\n`);
}
main()
    .catch((e) => {
    console.error('❌ Seeding failed:', e);
    process.exit(1);
})
    .finally(async () => {
    await prisma.$disconnect();
});
//# sourceMappingURL=seed-contracts.js.map