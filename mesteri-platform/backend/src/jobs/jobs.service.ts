import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Job, User, JobStatus, JobCategory, Prisma } from '@prisma/client';
import { ServicesOverviewResponse, ServiceInsightDto, CraftsmanInsightDto } from './dto/service-insight.dto';

export type { Job };

const CATEGORY_PRESENTATION: Record<JobCategory, { name: string; summary: string; slug: string; aliases: string[] }> = {
  [JobCategory.INSTALATII_SANITARE]: {
    name: 'Instalatii sanitare',
    summary: 'Reparatii si montaj profesionist pentru instalatii sanitare de incredere.',
    slug: 'instalatii-sanitare',
    aliases: ['instalatii-sanitare', 'sanitare', 'plumbing'],
  },
  [JobCategory.ELECTRIK]: {
    name: 'Instalatii electrice',
    summary: 'Electricieni certificati pentru interventii sigure si rapide.',
    slug: 'instalatii-electrice',
    aliases: ['electric', 'electricitate', 'instalatii-electrice'],
  },
  [JobCategory.CONSTRUCTII]: {
    name: 'Constructii si renovari',
    summary: 'Echipe specializate pentru renovari complete si finisaje impecabile.',
    slug: 'constructii',
    aliases: ['constructii', 'renovari', 'amenajari'],
  },
  [JobCategory.ALTELE]: {
    name: 'Servicii personalizate',
    summary: 'Mesteri versatili pentru proiecte atipice sau solicitari de nisa.',
    slug: 'servicii-diverse',
    aliases: ['diverse', 'alte-servicii', 'personalizat'],
  },
};

const OVERVIEW_DEFAULT_LIMIT = 6;
const OVERVIEW_MAX_LIMIT = 12;

const MILLISECONDS_IN_DAY = 1000 * 60 * 60 * 24;

const slugify = (value: string): string =>
  value
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-');

@Injectable()
export class JobsService {
  constructor(private prisma: PrismaService) {}

  async findAll(): Promise<Job[]> {
    return this.prisma.job.findMany({
      include: {
        client: true,
        offers: true,
      },
    });
  }

  async findOne(id: string): Promise<Job> {
    const job = await this.prisma.job.findUnique({
      where: { id },
      include: {
        client: true,
        offers: true,
      },
    });
    if (!job) {
      throw new NotFoundException(`Job with ID ${id} not found`);
    }
    return job;
  }

  async findByClientId(clientId: string): Promise<Job[]> {
    return this.prisma.job.findMany({
      where: { clientId },
      include: {
        client: true,
        offers: true,
      },
    });
  }

  async findByStatus(status: JobStatus): Promise<Job[]> {
    return this.prisma.job.findMany({
      where: { status },
      include: {
        client: true,
        offers: true,
      },
    });
  }

  async create(jobData: {
    title: string;
    description: string;
    category: JobCategory;
    location: string;
    budgetMin: number;
    budgetMax: number;
    clientId: string;
  }): Promise<Job> {
    // Check if client exists
    const client = await this.prisma.user.findUnique({
      where: { id: jobData.clientId },
    });
    if (!client) {
      throw new NotFoundException(
        `Client with ID ${jobData.clientId} not found`,
      );
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
      // Send notifications to matching craftsmen
      try {
        const craftsmen = await this.prisma.user.findMany({
          where: {
            role: 'CRAFTSMAN',
            specialties: { has: job.category },
          },
        });

        for (const craftsman of craftsmen) {
          // TODO: Implement push notifications when service is ready
          // await this.pushNotificationService.onNewJobOffer(craftsman.id, {
          //   jobId: job.id,
          //   jobTitle: job.title,
          //   category: job.category,
          //   location: job.location,
          //   budget: `${job.budgetMin}-${job.budgetMax}`,
          // }).catch(err => {
          //   console.error(`Failed to send notification to craftsman ${craftsman.id}:`, err);
          // });
        }
      } catch (notificationError) {
        console.error('Error sending job notifications:', notificationError);
        // Don't fail job creation if notifications fail
      }

      return job;
    });
  }

  async update(id: string, updateData: Prisma.JobUpdateInput): Promise<Job> {
    try {
      return await this.prisma.job.update({
        where: { id },
        data: updateData,
        include: {
          client: true,
          offers: true,
        },
      });
    } catch (error) {
      if (error.code === 'P2025') {
        throw new NotFoundException(`Job with ID ${id} not found`);
      }
      throw error;
    }
  }

  async delete(id: string): Promise<void> {
    try {
      await this.prisma.job.delete({
        where: { id },
      });
    } catch (error) {
      if (error.code === 'P2025') {
        throw new NotFoundException(`Job with ID ${id} not found`);
      }
      throw error;
    }
  }

  async searchAndFilter(
    query?: string,
    filters?: {
      category?: JobCategory;
      status?: JobStatus;
      minBudget?: number;
      maxBudget?: number;
      location?: string;
      clientId?: string;
      page?: number;
      limit?: number;
    },
  ): Promise<{ jobs: Job[]; total: number }> {
    const skip =
      filters?.page && filters?.limit ? (filters.page - 1) * filters.limit : 0;
    const take = filters?.limit || 10;

    const where: Prisma.JobWhereInput = {};

    // Add search query
    if (query) {
      where.OR = [
        { title: { contains: query, mode: 'insensitive' } },
        { description: { contains: query, mode: 'insensitive' } },
        { category: { equals: query as JobCategory } },
      ];
    }

    // Apply filters
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
      } else if (filters.minBudget !== undefined) {
        where.budgetMin = {
          gte: filters.minBudget,
        };
      } else if (filters.maxBudget !== undefined) {
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

  /**
   * Advanced search with geolocation support
   */
  async advancedSearch(searchDto: {
    q?: string;
    category?: JobCategory;
    status?: JobStatus;
    minBudget?: number;
    maxBudget?: number;
    city?: string;
    latitude?: number;
    longitude?: number;
    radius?: number;
    urgency?: any;
    sortBy?: string;
    page?: number;
    limit?: number;
  }): Promise<{ data: any[]; meta: any }> {
    const {
      q,
      category,
      status = JobStatus.ACTIVE,
      minBudget,
      maxBudget,
      city,
      latitude,
      longitude,
      radius = 50,
      urgency,
      sortBy = 'newest',
      page = 1,
      limit = 20,
    } = searchDto;

    // Parse numbers from query params (they come as strings)
    const parsedPage = Number(page) || 1;
    const parsedLimit = Number(limit) || 20;
    const parsedRadius = Number(radius) || 50;

    // If geolocation is provided, use raw SQL for distance calculation
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

    // Regular search without geolocation
    const skip = (parsedPage - 1) * parsedLimit;
    const where: Prisma.JobWhereInput = {};

    // Text search
    if (q) {
      where.OR = [
        { title: { contains: q, mode: 'insensitive' } },
        { description: { contains: q, mode: 'insensitive' } },
      ];
    }

    // Filters
    if (category) where.category = category;
    if (status) where.status = status;
    if (city) where.city = { contains: city, mode: 'insensitive' };
    if (urgency) where.urgency = urgency;

    // Budget range
    if (minBudget !== undefined || maxBudget !== undefined) {
      where.AND = [];
      if (minBudget !== undefined) {
        where.AND.push({ budgetMax: { gte: minBudget } });
      }
      if (maxBudget !== undefined) {
        where.AND.push({ budgetMin: { lte: maxBudget } });
      }
    }

    // Sorting
    let orderBy: Prisma.JobOrderByWithRelationInput = { createdAt: 'desc' };
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
    } catch (error) {
      console.error('AdvancedSearch ERROR:', error);
      throw error;
    }
  }

  /**
   * Search with geolocation using raw SQL
   */
  private async searchWithGeolocation(params: {
    q?: string;
    category?: JobCategory;
    status?: JobStatus;
    minBudget?: number;
    maxBudget?: number;
    city?: string;
    latitude: number;
    longitude: number;
    radius: number;
    urgency?: any;
    sortBy?: string;
    page: number;
    limit: number;
  }): Promise<{ data: any[]; meta: any }> {
    const {
      q,
      category,
      status,
      minBudget,
      maxBudget,
      city,
      latitude,
      longitude,
      radius,
      urgency,
      sortBy,
      page,
      limit,
    } = params;

    const skip = (page - 1) * limit;

    // Build WHERE conditions for raw SQL
    const conditions: string[] = ['latitude IS NOT NULL', 'longitude IS NOT NULL'];
    const values: any[] = [latitude, longitude, latitude, radius];

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
      conditions.push(
        `(title ILIKE $${values.length + 1} OR description ILIKE $${values.length + 1})`,
      );
      values.push(`%${q}%`);
    }

    const whereClause = conditions.join(' AND ');

    // Determine sort order
    let orderByClause = 'distance ASC';
    if (sortBy === 'budget_high') {
      orderByClause = '"budgetMax" DESC';
    } else if (sortBy === 'budget_low') {
      orderByClause = '"budgetMin" ASC';
    } else if (sortBy === 'newest') {
      orderByClause = '"createdAt" DESC';
    }

    // Raw SQL query with distance calculation
    const jobsWithDistance: any[] = await this.prisma.$queryRawUnsafe(
      `
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
    `,
      ...values,
    );

    // Get total count
    const countResult: any[] = await this.prisma.$queryRawUnsafe(
      `
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
    `,
      ...values,
    );

    const total = parseInt(countResult[0]?.count || '0', 10);
    const totalPages = Math.ceil(total / limit);

    // Enrich with client and offers data
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

    // Merge distance data with enriched jobs
    const jobsMap = new Map(enrichedJobs.map((j) => [j.id, j]));
    const finalJobs = jobsWithDistance.map((jwd) => ({
      ...jobsMap.get(jwd.id),
      distance: Math.round(jwd.distance * 10) / 10, // Round to 1 decimal
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

  async getJobsByCategory(
    category: JobCategory,
    filters?: {
      status?: JobStatus;
      location?: string;
      page?: number;
      limit?: number;
    },
  ): Promise<{ jobs: Job[]; total: number }> {
    const skip =
      filters?.page && filters?.limit ? (filters.page - 1) * filters.limit : 0;
    const take = filters?.limit || 10;

    const where: Prisma.JobWhereInput = { category };

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

  async getActiveJobs(filters?: {
    category?: JobCategory;
    location?: string;
    page?: number;
    limit?: number;
  }): Promise<{ jobs: Job[]; total: number }> {
    return this.searchAndFilter('', {
      ...filters,
      status: JobStatus.ACTIVE,
    });
  }

  async getMarketingFeed(limit: number = 20) {
    const jobs = await this.prisma.job.findMany({
      where: {
        status: JobStatus.ACTIVE,
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

  async getAvailableJobsForCraftsman(
    craftsmanId: string,
    specialty?: JobCategory,
    filters?: {
      location?: string;
      minBudget?: number;
      maxBudget?: number;
      page?: number;
      limit?: number;
    },
  ): Promise<{ jobs: Job[]; total: number }> {
    const skip =
      filters?.page && filters?.limit ? (filters.page - 1) * filters.limit : 0;
    const take = filters?.limit || 10;

    const where: Prisma.JobWhereInput = {
      status: JobStatus.ACTIVE,
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
      } else if (filters.minBudget) {
        where.budgetMin = { gte: filters.minBudget };
      } else if (filters.maxBudget) {
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
  private resolveCategory(categoryId?: string): JobCategory | undefined {
    if (!categoryId || categoryId.trim().length === 0) {
      return undefined;
    }

    const categories = Object.values(JobCategory) as JobCategory[];
    if (categories.includes(categoryId as JobCategory)) {
      return categoryId as JobCategory;
    }

    const normalized = slugify(categoryId);
    const match = categories.find((category) => {
      const presentation = CATEGORY_PRESENTATION[category];
      return (
        slugify(category) === normalized ||
        presentation.slug === normalized ||
        presentation.aliases.includes(normalized)
      );
    });

    if (match) {
      return match;
    }

    throw new BadRequestException(
      `Categoria solicitată nu este recunoscută: ${categoryId}`,
    );
  }

  private normalizeOverviewLimit(limit?: number): number {
    if (!limit || Number.isNaN(limit)) {
      return OVERVIEW_DEFAULT_LIMIT;
    }

    return Math.min(Math.max(Math.floor(limit), 1), OVERVIEW_MAX_LIMIT);
  }

  private getCategoryPresentation(category: JobCategory) {
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

  private average(values: number[], precision = 2): number | null {
    if (!values.length) {
      return null;
    }
    const total = values.reduce((sum, value) => sum + value, 0);
    return Number((total / values.length).toFixed(precision));
  }

  private buildTrustBadges(input: {
    isVerified?: boolean | null;
    averageRating?: number | null;
    totalReviews?: number | null;
    completedProjects: number;
  }): string[] {
    const badges: string[] = [];

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

  private async buildCategoryInsight(category: JobCategory): Promise<ServiceInsightDto | null> {
    const [jobSample, totalJobs, totalProjects, offersForCategory, topCraftsmanGroup] = await Promise.all([
      this.prisma.job.findMany({
        where: {
          category,
          status: { not: JobStatus.CANCELLED },
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
          status: { not: JobStatus.CANCELLED },
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

    // Sort craftsman by count descending
    topCraftsmanGroup.sort((a, b) => (b._count ?? 0) - (a._count ?? 0));

    if (!totalJobs) {
      return null;
    }

    const budgets = jobSample
      .map((job) => (Number(job.budgetMin) + Number(job.budgetMax)) / 2)
      .filter((value) => Number.isFinite(value));

    const gallery = Array.from(
      new Set(
        jobSample.flatMap((job) => job.mediaUrls ?? []).filter((url) => Boolean(url)),
      ),
    ).slice(0, 12);

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
      .filter((value): value is number => value !== null && Number.isFinite(value) && value > 0);

    const craftsmanIds = topCraftsmanGroup
      .map((entry) => entry.craftsmanId)
      .filter((id): id is string => Boolean(id));

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

    const responseTimesByCraftsman = new Map<string, number[]>();
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

    const topCraftsmen: CraftsmanInsightDto[] = topCraftsmanGroup
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
          rating:
            typeof user.averageRating === 'number' && !Number.isNaN(user.averageRating)
              ? Number(user.averageRating.toFixed(2))
              : null,
          completedProjects: entry._count as number,
          responseTimeHours: avgResponse,
          trustBadges: this.buildTrustBadges({
            isVerified: user.isVerified,
            averageRating: user.averageRating,
            totalReviews: user.totalReviews,
            completedProjects: entry._count as number,
          }),
        };
      })
      .filter((craft): craft is CraftsmanInsightDto => craft !== null)
      .slice(0, 3);

    const satisfactionValues = topCraftsmen
      .map((craft) => craft.rating)
      .filter((value): value is number => value !== null && Number.isFinite(value));

    const completedProjectsTotal = topCraftsmanGroup.reduce((total, entry) => total + ((entry._count as number) ?? 0), 0);

    const topSkills = Array.from(
      new Set(
        craftsmanIds
          .flatMap((id) => userById.get(id)?.specialties ?? [])
          .map((skill) => skill?.trim())
          .filter((skill): skill is string => Boolean(skill) && skill.length > 1),
      ),
    ).slice(0, 6);

    const presentation = this.getCategoryPresentation(category);
    const averageBudgetValue = this.average(budgets);
    const averageBidValue = this.average(offerBids);
    const averageDurationValue = this.average(durations, 1);
    const satisfactionScore = this.average(satisfactionValues);

    const metricHighlights: string[] = [];

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

  async getServicesOverview(params: {
    categoryId?: string;
    limit?: number;
  } = {}): Promise<ServicesOverviewResponse> {
    const limit = this.normalizeOverviewLimit(params.limit);
    const resolvedCategory = this.resolveCategory(params.categoryId);

    const categories: JobCategory[] = [];
    if (resolvedCategory) {
      categories.push(resolvedCategory);
    } else {
      const grouped = await this.prisma.job.groupBy({
        by: ['category'],
        where: {
          status: { not: JobStatus.CANCELLED },
        },
        _count: true,
        orderBy: { category: 'asc' },
        take: limit,
      });

      grouped.sort((a, b) => (b._count ?? 0) - (a._count ?? 0));

      grouped.forEach((entry) => {
        if (entry.category) {
          categories.push(entry.category as JobCategory);
        }
      });
    }

    if (!categories.length) {
      return {
        data: [],
        fetchedAt: new Date().toISOString(),
      };
    }

    const insights: ServiceInsightDto[] = [];
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
  // Compatibility methods for controller - now implemented above as getJobsByCategory and searchAndFilter
  async findByCategory(category: string): Promise<Job[]> {
    const result = await this.getJobsByCategory(category as JobCategory);
    return result.jobs;
  }

  async search(query: string): Promise<{ jobs: Job[]; total: number }> {
    return this.searchAndFilter(query);
  }
}
