"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.DatabaseSeeder = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../../prisma/prisma.service");
const client_1 = require("@prisma/client");
const bcrypt = __importStar(require("bcrypt"));
var UrgencyLevel;
(function (UrgencyLevel) {
    UrgencyLevel["LOW"] = "LOW";
    UrgencyLevel["MEDIUM"] = "MEDIUM";
    UrgencyLevel["HIGH"] = "HIGH";
    UrgencyLevel["EMERGENCY"] = "EMERGENCY";
})(UrgencyLevel || (UrgencyLevel = {}));
let DatabaseSeeder = class DatabaseSeeder {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async seed() {
        await this.seedUsers();
        await this.seedJobs();
        console.log('Database seeded successfully!');
    }
    async seedUsers() {
        const users = [
            {
                email: 'client@example.com',
                passwordHash: await bcrypt.hash('password123', 10),
                fullName: 'John Client',
                city: 'Bucharest',
                county: 'Bucharest',
                userType: client_1.UserType.INDIVIDUAL,
                role: client_1.UserRole.CLIENT,
                isVerified: true,
                specialties: ['general'],
            },
            {
                email: 'craftsman@example.com',
                passwordHash: await bcrypt.hash('password123', 10),
                fullName: 'Mike Craftsman',
                city: 'Bucharest',
                county: 'Bucharest',
                userType: client_1.UserType.INDIVIDUAL,
                role: client_1.UserRole.CRAFTSMAN,
                isVerified: true,
                bio: 'Experienced electrician with 10+ years in residential and commercial work.',
                averageRating: 4.8,
                totalReviews: 25,
                specialties: ['electrik'],
            },
            {
                email: 'admin@mesteri.ro',
                passwordHash: await bcrypt.hash('admin123', 10),
                fullName: 'Admin Mesteri',
                city: 'Bucharest',
                county: 'Bucharest',
                userType: client_1.UserType.INDIVIDUAL,
                role: client_1.UserRole.CLIENT,
                isVerified: true,
                specialties: ['admin'],
            },
        ];
        for (const userData of users) {
            const existingUser = await this.prisma.user.findUnique({
                where: { email: userData.email },
            });
            if (!existingUser) {
                await this.prisma.user.create({
                    data: userData,
                });
                console.log(`Created user: ${userData.email}`);
            }
        }
    }
    async seedJobs() {
        const client = await this.prisma.user.findUnique({
            where: { email: 'client@example.com' },
        });
        if (!client)
            return;
        const jobs = [
            {
                title: 'Instalatii Electrice in Bucatarie',
                description: 'Instalare prize si corpuri iluminat in renovare bucatarie moderna. Spatiul aproximativ 15mp necesita 4 prize noi, iluminat sub-taval, si un dispozitiv de protectie.',
                category: client_1.JobCategory.ELECTRIK,
                budgetMin: 1500.0,
                budgetMax: 2500.0,
                city: 'Bucuresti',
                location: 'Sector 1',
                status: client_1.JobStatus.ACTIVE,
                clientId: client.id,
            },
            {
                title: 'Reparatii Instalatii Sanitare',
                description: 'Reparatie robinet picurator si inlocuire duca. Verificare pentru coroziune teava sub chiuveta. Materiale furnizate de client.',
                category: client_1.JobCategory.INSTALATII_SANITARE,
                budgetMin: 200.0,
                budgetMax: 400.0,
                city: 'Bucuresti',
                location: 'Sector 2',
                status: client_1.JobStatus.ACTIVE,
                clientId: client.id,
            },
            {
                title: 'Constructie Terasa Lemn',
                description: 'Constructie terasa 20mp a gradina. Necesita lemn tratat la presiune, fundament solid, si balustrade de siguranta. Trebuie sa respecte codurile locale de constructii.',
                category: client_1.JobCategory.CONSTRUCTII,
                budgetMin: 3000.0,
                budgetMax: 5000.0,
                city: 'Otopeni',
                location: 'Otopeni',
                status: client_1.JobStatus.ACTIVE,
                clientId: client.id,
            },
        ];
        for (const jobData of jobs) {
            const existingJob = await this.prisma.job.findFirst({
                where: {
                    title: jobData.title,
                    clientId: jobData.clientId,
                },
            });
            if (!existingJob) {
                await this.prisma.job.create({
                    data: jobData,
                });
                console.log(`Created job: ${jobData.title}`);
            }
        }
    }
};
exports.DatabaseSeeder = DatabaseSeeder;
exports.DatabaseSeeder = DatabaseSeeder = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], DatabaseSeeder);
//# sourceMappingURL=database-seeder.js.map