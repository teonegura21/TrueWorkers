"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.JobsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const client_1 = require("@prisma/client");
const CATEGORY_PRESENTATION = {
    [client_1.JobCategory.INSTALATII_SANITARE]: {
        name: 'Instalatii sanitare',
        summary: 'Reparatii si montaj profesionist pentru instalatii sanitare de incredere.',
        slug: 'instalatii-sanitare',
        aliases: ['instalatii-sanitare', 'sanitare', 'plumbing'],
    },
    [client_1.JobCategory.ELECTRIK]: {
        name: 'Instalatii electrice',
        summary: 'Electricieni certificati pentru interventii sigure si rapide.',
        slug: 'instalatii-electrice',
        aliases: ['electric', 'electricitate', 'instalatii-electrice'],
    },
    [client_1.JobCategory.CONSTRUCTII]: {
        name: 'Constructii si renovari',
        summary: 'Echipe specializate pentru renovari complete si finisaje impecabile.',
        slug: 'constructii',
        aliases: ['constructii', 'renovari', 'amenajari'],
    },
    [client_1.JobCategory.ALTELE]: {
        name: 'Servicii personalizate',
        summary: 'Mesteri versatili pentru proiecte atipice sau solicitari de nisa.',
        slug: 'servicii-diverse',
        aliases: ['diverse', 'alte-servicii', 'personalizat'],
    },
};
const OVERVIEW_DEFAULT_LIMIT = 6;
const OVERVIEW_MAX_LIMIT = 12;
const MILLISECONDS_IN_DAY = 1000 * 60 * 60 * 24;
const slugify = (value) => value
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-');
let JobsService = class JobsService {
    prisma;
    constructor(prisma) {
        this.prisma = prisma;
    }
    async findAll() {
        return this.prisma.job.findMany({
            include: {
                client: true,
                offers: true,
            },
        });
    }
    async findOne(id) {
        const job = await this.prisma.job.findUnique({
            where: { id },
            include: {
                client: true,
                offers: true,
            },
        });
        if (!job) {
            throw new common_1.NotFoundException(`Job with ID ${id} not found`);
        }
        return job;
    }
    async findByClientId(clientId) {
        return this.prisma.job.findMany({
            where: { clientId },
            include: {
                client: true,
                offers: true,
            },
        });
    }
    async findByStatus(status) {
        return this.prisma.job.findMany({
            where: { status },
            include: {
                client: true,
                offers: true,
            },
        });
    }
    async create(jobData) {
        const client = await this.prisma.user.findUnique({
            where: { id: jobData.clientId },
        });
        if (!client) {
            throw new common_1.NotFoundException(`Client with ID ${jobData.clientId} not found`);
        }
        return this.prisma.job.create({
            data: {
                ...jobData,
                city: jobData.location,
            },
            include: {
                client: true,
                offers: true,
            },
        }).then(async (job) => {
            try {
                const craftsmen = await this.prisma.user.findMany({
                    where: {
                        role: 'CRAFTSMAN',
                        specialties: { has: job.category },
                    },
                });
                for (const craftsman of craftsmen) {
                }
            }
            catch (notificationError) {
                console.error('Error sending job notifications:', notificationError);
            }
            return job;
        });
    }
    async update(id, updateData) {
        try {
            return await this.prisma.job.update({
                where: { id },
                data: updateData,
                include: {
                    client: true,
                    offers: true,
                },
            });
        }
        catch (error) {
            if (error.code === 'P2025') {
                throw new common_1.NotFoundException(`Job with ID ${id} not found`);
            }
            throw error;
        }
    }
    async delete(id) {
        try {
            await this.prisma.job.delete({
                where: { id },
            });
        }
        catch (error) {
            if (error.code === 'P2025') {
                throw new common_1.NotFoundException(`Job with ID ${id} not found`);
            }
            throw error;
        }
    }
    async searchAndFilter(query, filters) {
        const skip = filters?.page && filters?.limit ? (filters.page - 1) * filters.limit : 0;
        const take = filters?.limit || 10;
        const where = {};
        if (query) {
            where.OR = [
                { title: { contains: query, mode: 'insensitive' } },
                { description: { contains: query, mode: 'insensitive' } },
                { category: { equals: query } },
            ];
        }
        if (filters?.category) {
            where.category = filters.category;
        }
        if (filters?.status) {
            where.status = filters.status;
        }
        if (filters?.minBudget !== undefined || filters?.maxBudget !== undefined) {
            if (filters.minBudget !== undefined && filters.maxBudget !== undefined) {
                where.budgetMin = {
                    gte: filters.minBudget,
                };
                where.budgetMax = {
                    lte: filters.maxBudget,
                };
            }
            else if (filters.minBudget !== undefined) {
                where.budgetMin = {
                    gte: filters.minBudget,
                };
            }
            else if (filters.maxBudget !== undefined) {
                where.budgetMax = {
                    lte: filters.maxBudget,
                };
            }
        }
        if (filters?.location) {
            where.location = {
                contains: filters.location,
                mode: 'insensitive',
            };
        }
        if (filters?.clientId) {
            where.clientId = filters.clientId;
        }
        const [jobs, total] = await Promise.all([
            this.prisma.job.findMany({
                where,
                include: {
                    client: true,
                    offers: true,
                },
                skip,
                take,
                orderBy: { createdAt: 'desc' },
            }),
            this.prisma.job.count({ where }),
        ]);
        return { jobs, total };
    }
    async advancedSearch(searchDto) {
        const { q, category, status = client_1.JobStatus.ACTIVE, minBudget, maxBudget, city, latitude, longitude, radius = 50, urgency, sortBy = 'newest', page = 1, limit = 20, } = searchDto;
        const parsedPage = Number(page) || 1;
        const parsedLimit = Number(limit) || 20;
        const parsedRadius = Number(radius) || 50;
        if (latitude && longitude) {
            return this.searchWithGeolocation({
                q,
                category,
                status,
                minBudget,
                maxBudget,
                city,
                latitude,
                longitude,
                radius: parsedRadius,
                urgency,
                sortBy,
                page: parsedPage,
                limit: parsedLimit,
            });
        }
        const skip = (parsedPage - 1) * parsedLimit;
        const where = {};
        if (q) {
            where.OR = [
                { title: { contains: q, mode: 'insensitive' } },
                { description: { contains: q, mode: 'insensitive' } },
            ];
        }
        if (category)
            where.category = category;
        if (status)
            where.status = status;
        if (city)
            where.city = { contains: city, mode: 'insensitive' };
        if (urgency)
            where.urgency = urgency;
        if (minBudget !== undefined || maxBudget !== undefined) {
            where.AND = [];
            if (minBudget !== undefined) {
                where.AND.push({ budgetMax: { gte: minBudget } });
            }
            if (maxBudget !== undefined) {
                where.AND.push({ budgetMin: { lte: maxBudget } });
            }
        }
        let orderBy = { createdAt: 'desc' };
        switch (sortBy) {
            case 'budget_high':
                orderBy = { budgetMax: 'desc' };
                break;
            case 'budget_low':
                orderBy = { budgetMin: 'asc' };
                break;
            case 'deadline':
                orderBy = { createdAt: 'asc' };
                break;
            case 'newest':
            default:
                orderBy = { createdAt: 'desc' };
        }
        try {
            console.log('Search params:', { where, skip, limit, orderBy });
            const [jobs, total] = await Promise.all([
                this.prisma.job.findMany({
                    where,
                    include: {
                        client: {
                            select: {
                                id: true,
                                fullName: true,
                                profileImage: true,
                                averageRating: true,
                                totalReviews: true,
                            },
                        },
                        offers: {
                            select: {
                                id: true,
                                bidAmount: true,
                                estimatedDays: true,
                                notes: true,
                                craftsmanId: true,
                                createdAt: true,
                            },
                        },
                    },
                    skip,
                    take: parsedLimit,
                    orderBy,
                }),
                this.prisma.job.count({ where }),
            ]);
            const totalPages = Math.ceil(total / parsedLimit);
            return {
                data: jobs,
                meta: {
                    total,
                    page: parsedPage,
                    limit: parsedLimit,
                    totalPages,
                },
            };
        }
        catch (error) {
            console.error('AdvancedSearch ERROR:', error);
            throw error;
        }
    }
    async searchWithGeolocation(params) {
        const { q, category, status, minBudget, maxBudget, city, latitude, longitude, radius, urgency, sortBy, page, limit, } = params;
        const skip = (page - 1) * limit;
        const conditions = ['latitude IS NOT NULL', 'longitude IS NOT NULL'];
        const values = [latitude, longitude, latitude, radius];
        if (status) {
            conditions.push(`status = $${values.length + 1}`);
            values.push(status);
        }
        if (category) {
            conditions.push(`category = $${values.length + 1}`);
            values.push(category);
        }
        if (city) {
            conditions.push(`city ILIKE $${values.length + 1}`);
            values.push(`%${city}%`);
        }
        if (urgency) {
            conditions.push(`urgency = $${values.length + 1}`);
            values.push(urgency);
        }
        if (minBudget !== undefined) {
            conditions.push(`"budgetMax" >= $${values.length + 1}`);
            values.push(minBudget);
        }
        if (maxBudget !== undefined) {
            conditions.push(`"budgetMin" <= $${values.length + 1}`);
            values.push(maxBudget);
        }
        if (q) {
            conditions.push(`(title ILIKE $${values.length + 1} OR description ILIKE $${values.length + 1})`);
            values.push(`%${q}%`);
        }
        const whereClause = conditions.join(' AND ');
        let orderByClause = 'distance ASC';
        if (sortBy === 'budget_high') {
            orderByClause = '"budgetMax" DESC';
        }
        else if (sortBy === 'budget_low') {
            orderByClause = '"budgetMin" ASC';
        }
        else if (sortBy === 'newest') {
            orderByClause = '"createdAt" DESC';
        }
        const jobsWithDistance = await this.prisma.$queryRawUnsafe(`
      SELECT
        j.*,
        (
          6371 * acos(
            cos(radians($1)) * cos(radians(latitude)) *
            cos(radians(longitude) - radians($2)) +
            sin(radians($1)) * sin(radians(latitude))
          )
        ) AS distance
      FROM jobs j
      WHERE ${whereClause}
      HAVING (
        6371 * acos(
          cos(radians($3)) * cos(radians(latitude)) *
          cos(radians(longitude) - radians($2)) +
          sin(radians($3)) * sin(radians(latitude))
        )
      ) < $4
      ORDER BY ${orderByClause}
      LIMIT ${limit}
      OFFSET ${skip}
    `, ...values);
        const countResult = await this.prisma.$queryRawUnsafe(`
      SELECT COUNT(*) as count
      FROM jobs j
      WHERE ${whereClause}
      HAVING (
        6371 * acos(
          cos(radians($3)) * cos(radians(latitude)) *
          cos(radians(longitude) - radians($2)) +
          sin(radians($3)) * sin(radians(latitude))
        )
      ) < $4
    `, ...values);
        const total = parseInt(countResult[0]?.count || '0', 10);
        const totalPages = Math.ceil(total / limit);
        const jobIds = jobsWithDistance.map((j) => j.id);
        const enrichedJobs = await this.prisma.job.findMany({
            where: { id: { in: jobIds } },
            include: {
                client: {
                    select: {
                        id: true,
                        fullName: true,
                        profileImage: true,
                        averageRating: true,
                        totalReviews: true,
                    },
                },
                offers: {
                    select: {
                        id: true,
                        bidAmount: true,
                        estimatedDays: true,
                        notes: true,
                        craftsmanId: true,
                        createdAt: true,
                    },
                },
            },
        });
        const jobsMap = new Map(enrichedJobs.map((j) => [j.id, j]));
        const finalJobs = jobsWithDistance.map((jwd) => ({
            ...jobsMap.get(jwd.id),
            distance: Math.round(jwd.distance * 10) / 10,
        }));
        return {
            data: finalJobs,
            meta: {
                total,
                page,
                limit,
                totalPages,
            },
        };
    }
    async getJobsByCategory(category, filters) {
        const skip = filters?.page && filters?.limit ? (filters.page - 1) * filters.limit : 0;
        const take = filters?.limit || 10;
        const where = { category };
        if (filters?.status) {
            where.status = filters.status;
        }
        if (filters?.location) {
            where.location = {
                contains: filters.location,
                mode: 'insensitive',
            };
        }
        const [jobs, total] = await Promise.all([
            this.prisma.job.findMany({
                where,
                include: {
                    client: true,
                    offers: true,
                },
                skip,
                take,
                orderBy: { createdAt: 'desc' },
            }),
            this.prisma.job.count({ where }),
        ]);
        return { jobs, total };
    }
    async getActiveJobs(filters) {
        return this.searchAndFilter('', {
            ...filters,
            status: client_1.JobStatus.ACTIVE,
        });
    }
    async getMarketingFeed(limit = 20) {
        const jobs = await this.prisma.job.findMany({
            where: {
                status: client_1.JobStatus.ACTIVE,
                mediaUrls: { isEmpty: false },
            },
            include: { client: true },
            take: limit,
            orderBy: { createdAt: 'desc' },
        });
        return jobs.map((job) => ({
            id: job.id,
            title: job.title,
            description: job.description,
            location: job.location,
            city: job.city,
            category: job.category,
            budgetMin: job.budgetMin,
            budgetMax: job.budgetMax,
            mediaUrls: job.mediaUrls,
            clientName: job.client?.fullName,
            createdAt: job.createdAt,
        }));
    }
    async getAvailableJobsForCraftsman(craftsmanId, specialty, filters) {
        const skip = filters?.page && filters?.limit ? (filters.page - 1) * filters.limit : 0;
        const take = filters?.limit || 10;
        const where = {
            status: client_1.JobStatus.ACTIVE,
            clientId: { not: craftsmanId },
        };
        if (specialty) {
            where.category = specialty;
        }
        if (filters?.location) {
            where.location = {
                contains: filters.location,
                mode: 'insensitive',
            };
        }
        if (filters?.minBudget || filters?.maxBudget) {
            if (filters.minBudget && filters.maxBudget) {
                where.budgetMin = {
                    gte: filters.minBudget,
                };
                where.budgetMax = {
                    lte: filters.maxBudget,
                };
            }
            else if (filters.minBudget) {
                where.budgetMin = { gte: filters.minBudget };
            }
            else if (filters.maxBudget) {
                where.budgetMax = { lte: filters.maxBudget };
            }
        }
        const [jobs, total] = await Promise.all([
            this.prisma.job.findMany({
                where,
                include: {
                    client: true,
                    offers: true,
                },
                skip,
                take,
                orderBy: { createdAt: 'desc' },
            }),
            this.prisma.job.count({ where }),
        ]);
        return { jobs, total };
    }
    resolveCategory(categoryId) {
        if (!categoryId || categoryId.trim().length === 0) {
            return undefined;
        }
        const categories = Object.values(client_1.JobCategory);
        if (categories.includes(categoryId)) {
            return categoryId;
        }
        const normalized = slugify(categoryId);
        const match = categories.find((category) => {
            const presentation = CATEGORY_PRESENTATION[category];
            return (slugify(category) === normalized ||
                presentation.slug === normalized ||
                presentation.aliases.includes(normalized));
        });
        if (match) {
            return match;
        }
        throw new common_1.BadRequestException(`Categoria solicitată nu este recunoscută: ${categoryId}`);
    }
    normalizeOverviewLimit(limit) {
        if (!limit || Number.isNaN(limit)) {
            return OVERVIEW_DEFAULT_LIMIT;
        }
        return Math.min(Math.max(Math.floor(limit), 1), OVERVIEW_MAX_LIMIT);
    }
    getCategoryPresentation(category) {
        const presentation = CATEGORY_PRESENTATION[category];
        if (presentation) {
            return presentation;
        }
        return {
            name: category.replace(/_/g, ' ').toLowerCase(),
            summary: null,
            slug: slugify(category),
            aliases: [slugify(category)],
        };
    }
    average(values, precision = 2) {
        if (!values.length) {
            return null;
        }
        const total = values.reduce((sum, value) => sum + value, 0);
        return Number((total / values.length).toFixed(precision));
    }
    buildTrustBadges(input) {
        const badges = [];
        if (input.isVerified) {
            badges.push('Verificat');
        }
        if ((input.averageRating ?? 0) >= 4.7) {
            badges.push('Top rating');
        }
        if ((input.totalReviews ?? 0) >= 10) {
            badges.push('Recenzii autentice');
        }
        if (input.completedProjects >= 5) {
            badges.push('Portofoliu solid');
        }
        return badges.slice(0, 3);
    }
    async buildCategoryInsight(category) {
        const [jobSample, totalJobs, totalProjects, offersForCategory, topCraftsmanGroup] = await Promise.all([
            this.prisma.job.findMany({
                where: {
                    category,
                    status: { not: client_1.JobStatus.CANCELLED },
                },
                include: {
                    offers: {
                        select: {
                            id: true,
                            bidAmount: true,
                            craftsmanId: true,
                            createdAt: true,
                        },
                    },
                    project: {
                        select: {
                            id: true,
                            status: true,
                            startDate: true,
                            endDate: true,
                            craftsmanId: true,
                        },
                    },
                },
                orderBy: { createdAt: 'desc' },
                take: 60,
            }),
            this.prisma.job.count({
                where: {
                    category,
                    status: { not: client_1.JobStatus.CANCELLED },
                },
            }),
            this.prisma.project.count({
                where: {
                    job: { category },
                },
            }),
            this.prisma.offer.findMany({
                where: {
                    job: { category },
                },
                select: {
                    id: true,
                    bidAmount: true,
                    craftsmanId: true,
                    createdAt: true,
                    job: {
                        select: {
                            createdAt: true,
                        },
                    },
                },
            }),
            this.prisma.project.groupBy({
                by: ['craftsmanId'],
                where: {
                    job: { category },
                    craftsmanId: { not: null },
                    status: "COMPLETED",
                },
                _count: true,
                orderBy: { craftsmanId: 'asc' },
                take: 5,
            }),
        ]);
        topCraftsmanGroup.sort((a, b) => (b._count ?? 0) - (a._count ?? 0));
        if (!totalJobs) {
            return null;
        }
        const budgets = jobSample
            .map((job) => (Number(job.budgetMin) + Number(job.budgetMax)) / 2)
            .filter((value) => Number.isFinite(value));
        const gallery = Array.from(new Set(jobSample.flatMap((job) => job.mediaUrls ?? []).filter((url) => Boolean(url)))).slice(0, 12);
        const offerBids = offersForCategory
            .map((offer) => Number(offer.bidAmount ?? 0))
            .filter((value) => Number.isFinite(value) && value > 0);
        const durations = jobSample
            .map((job) => {
            const project = job.project;
            if (!project?.startDate || !project?.endDate) {
                return null;
            }
            const diff = project.endDate.getTime() - project.startDate.getTime();
            if (diff <= 0) {
                return null;
            }
            return diff / MILLISECONDS_IN_DAY;
        })
            .filter((value) => value !== null && Number.isFinite(value) && value > 0);
        const craftsmanIds = topCraftsmanGroup
            .map((entry) => entry.craftsmanId)
            .filter((id) => Boolean(id));
        const craftsmen = craftsmanIds.length
            ? await this.prisma.user.findMany({
                where: { id: { in: craftsmanIds } },
                select: {
                    id: true,
                    fullName: true,
                    averageRating: true,
                    totalReviews: true,
                    specialties: true,
                    isVerified: true,
                },
            })
            : [];
        const userById = new Map(craftsmen.map((user) => [user.id, user]));
        const responseTimesByCraftsman = new Map();
        offersForCategory.forEach((offer) => {
            if (!offer.craftsmanId || !offer.job?.createdAt || !offer.createdAt) {
                return;
            }
            const responseMs = offer.createdAt.getTime() - offer.job.createdAt.getTime();
            if (responseMs < 0) {
                return;
            }
            const hours = responseMs / (1000 * 60 * 60);
            if (!Number.isFinite(hours)) {
                return;
            }
            const bucket = responseTimesByCraftsman.get(offer.craftsmanId) ?? [];
            bucket.push(hours);
            responseTimesByCraftsman.set(offer.craftsmanId, bucket);
        });
        const topCraftsmen = topCraftsmanGroup
            .map((entry) => {
            const craftsmanId = entry.craftsmanId;
            if (!craftsmanId) {
                return null;
            }
            const user = userById.get(craftsmanId);
            if (!user) {
                return null;
            }
            const responseSamples = responseTimesByCraftsman.get(craftsmanId) ?? [];
            const avgResponse = this.average(responseSamples, 2);
            return {
                id: craftsmanId,
                name: user.fullName,
                rating: typeof user.averageRating === 'number' && !Number.isNaN(user.averageRating)
                    ? Number(user.averageRating.toFixed(2))
                    : null,
                completedProjects: entry._count,
                responseTimeHours: avgResponse,
                trustBadges: this.buildTrustBadges({
                    isVerified: user.isVerified,
                    averageRating: user.averageRating,
                    totalReviews: user.totalReviews,
                    completedProjects: entry._count,
                }),
            };
        })
            .filter((craft) => craft !== null)
            .slice(0, 3);
        const satisfactionValues = topCraftsmen
            .map((craft) => craft.rating)
            .filter((value) => value !== null && Number.isFinite(value));
        const completedProjectsTotal = topCraftsmanGroup.reduce((total, entry) => total + (entry._count ?? 0), 0);
        const topSkills = Array.from(new Set(craftsmanIds
            .flatMap((id) => userById.get(id)?.specialties ?? [])
            .map((skill) => skill?.trim())
            .filter((skill) => Boolean(skill) && skill.length > 1))).slice(0, 6);
        const presentation = this.getCategoryPresentation(category);
        const averageBudgetValue = this.average(budgets);
        const averageBidValue = this.average(offerBids);
        const averageDurationValue = this.average(durations, 1);
        const satisfactionScore = this.average(satisfactionValues);
        const metricHighlights = [];
        if (topCraftsmen.length) {
            metricHighlights.push(`${topCraftsmen.length} mesteri de top`);
        }
        if (completedProjectsTotal) {
            metricHighlights.push(`${completedProjectsTotal} proiecte finalizate`);
        }
        if (typeof averageBudgetValue === 'number') {
            metricHighlights.push(`Buget mediu ~${averageBudgetValue.toFixed(0)} RON`);
        }
        const summary = metricHighlights.length
            ? metricHighlights.join(' • ')
            : presentation.summary;
        return {
            categoryId: presentation.slug,
            categoryName: presentation.name,
            summary,
            averageBudget: averageBudgetValue,
            averageBid: averageBidValue,
            averageDurationDays: averageDurationValue,
            satisfactionScore,
            topCraftsmen,
            gallery,
            topSkills,
            metadata: {
                categoryCode: category,
                totalJobs,
                totalOffers: offersForCategory.length,
                totalProjects,
            },
        };
    }
    async getServicesOverview(params = {}) {
        const limit = this.normalizeOverviewLimit(params.limit);
        const resolvedCategory = this.resolveCategory(params.categoryId);
        const categories = [];
        if (resolvedCategory) {
            categories.push(resolvedCategory);
        }
        else {
            const grouped = await this.prisma.job.groupBy({
                by: ['category'],
                where: {
                    status: { not: client_1.JobStatus.CANCELLED },
                },
                _count: true,
                orderBy: { category: 'asc' },
                take: limit,
            });
            grouped.sort((a, b) => (b._count ?? 0) - (a._count ?? 0));
            grouped.forEach((entry) => {
                if (entry.category) {
                    categories.push(entry.category);
                }
            });
        }
        if (!categories.length) {
            return {
                data: [],
                fetchedAt: new Date().toISOString(),
            };
        }
        const insights = [];
        for (const category of categories) {
            const insight = await this.buildCategoryInsight(category);
            if (insight) {
                insights.push(insight);
            }
        }
        return {
            data: insights,
            fetchedAt: new Date().toISOString(),
        };
    }
    async findByCategory(category) {
        const result = await this.getJobsByCategory(category);
        return result.jobs;
    }
    async search(query) {
        return this.searchAndFilter(query);
    }
};
exports.JobsService = JobsService;
exports.JobsService = JobsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], JobsService);
//# sourceMappingURL=jobs.service.js.map