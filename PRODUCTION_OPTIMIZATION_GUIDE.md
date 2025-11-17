# Production Optimization Guide - Mesteri Platform

**Last Updated**: January 2025
**Status**: Production-Ready Optimizations
**Priority**: High-Traffic & Performance

---

## Table of Contents

1. [Database Optimizations](#database-optimizations)
2. [Caching Strategy (Redis)](#caching-strategy-redis)
3. [Google Cloud Integration](#google-cloud-integration)
4. [CDN & Static Assets](#cdn--static-assets)
5. [Rate Limiting & DDoS Protection](#rate-limiting--ddos-protection)
6. [Load Balancing & Scaling](#load-balancing--scaling)
7. [Performance Monitoring](#performance-monitoring)
8. [Code-Level Optimizations](#code-level-optimizations)
9. [Database Connection Pooling](#database-connection-pooling)
10. [WebSocket Optimization](#websocket-optimization)

---

## 1. Database Optimizations

### 1.1 Add Indexes for High-Traffic Queries

**Execute these migrations ASAP:**

```sql
-- Geographic queries (used heavily in job/craftsman discovery)
CREATE INDEX idx_jobs_location ON jobs USING GIST (location);
CREATE INDEX idx_craftsman_profiles_location ON craftsman_profiles USING GIST (location);

-- Frequently queried foreign keys
CREATE INDEX idx_jobs_client_id ON jobs(client_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_jobs_status ON jobs(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_jobs_category ON jobs(category) WHERE deleted_at IS NULL;
CREATE INDEX idx_jobs_created_at ON jobs(created_at DESC) WHERE deleted_at IS NULL;

-- Project queries
CREATE INDEX idx_projects_craftsman_id ON projects(craftsman_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_projects_client_id ON projects(client_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_projects_status ON projects(status) WHERE deleted_at IS NULL;

-- Messages queries (heavy in real-time chat)
CREATE INDEX idx_messages_conversation_id_created_at ON messages(conversation_id, created_at DESC);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);

-- Payments queries
CREATE INDEX idx_payments_user_id_created_at ON payments(user_id, created_at DESC);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_stripe_payment_intent_id ON payments(stripe_payment_intent_id) WHERE stripe_payment_intent_id IS NOT NULL;

-- Reviews queries
CREATE INDEX idx_reviews_craftsman_id_rating ON reviews(craftsman_id, rating DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_reviews_client_id ON reviews(reviewer_id) WHERE deleted_at IS NULL;

-- Offers queries
CREATE INDEX idx_offers_job_id ON offers(job_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_offers_craftsman_id ON offers(craftsman_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_offers_status ON offers(status) WHERE deleted_at IS NULL;

-- Inspiration feed (TikTok-style)
CREATE INDEX idx_inspiration_posts_created_at ON inspiration_posts(created_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_inspiration_posts_author_id ON inspiration_posts(author_id);

-- Composite indexes for common query patterns
CREATE INDEX idx_jobs_status_category ON jobs(status, category) WHERE deleted_at IS NULL;
CREATE INDEX idx_craftsman_profiles_rating ON craftsman_profiles(average_rating DESC NULLS LAST);
```

### 1.2 Prisma Query Optimization

Update `mesteri-platform/backend/prisma/schema.prisma`:

```prisma
generator client {
  provider        = "prisma-client-js"
  previewFeatures = ["fullTextSearch", "fullTextIndex", "postgresqlExtensions"]
  // Enable query optimization
  binaryTargets = ["native", "linux-musl-openssl-3.0.x"]
}

datasource db {
  provider   = "postgresql"
  url        = env("DATABASE_URL")
  extensions = [postgis, pg_trgm]
}
```

### 1.3 Enable PostgreSQL Extensions

```sql
-- Full-text search (for job descriptions, craftsman profiles)
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;

-- Geographic queries (already done, but verify)
CREATE EXTENSION IF NOT EXISTS postgis;

-- UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Full-text search indexes
CREATE INDEX idx_jobs_title_trgm ON jobs USING GIN (title gin_trgm_ops);
CREATE INDEX idx_jobs_description_trgm ON jobs USING GIN (description gin_trgm_ops);
CREATE INDEX idx_craftsman_profiles_bio_trgm ON craftsman_profiles USING GIN (bio gin_trgm_ops);
```

---

## 2. Caching Strategy (Redis)

### 2.1 Install Redis

**Add to `package.json`:**

```json
{
  "dependencies": {
    "@nestjs/cache-manager": "^2.2.2",
    "cache-manager": "^5.7.6",
    "cache-manager-redis-store": "^3.0.1",
    "redis": "^4.7.0"
  }
}
```

### 2.2 Configure Redis Module

**Create `src/cache/cache.module.ts`:**

```typescript
import { Module } from '@nestjs/common';
import { CacheModule } from '@nestjs/cache-manager';
import { redisStore } from 'cache-manager-redis-store';

@Module({
  imports: [
    CacheModule.registerAsync({
      isGlobal: true,
      useFactory: async () => {
        const store = await redisStore({
          socket: {
            host: process.env.REDIS_HOST || 'localhost',
            port: parseInt(process.env.REDIS_PORT || '6379'),
          },
          password: process.env.REDIS_PASSWORD,
          ttl: 60 * 60, // 1 hour default
        });

        return {
          store: () => store,
        };
      },
    }),
  ],
})
export class CacheConfigModule {}
```

### 2.3 Cache High-Traffic Endpoints

**Example: Cache craftsman search results**

```typescript
// src/users/craftsman.controller.ts
import { CacheInterceptor, UseInterceptors, CacheTTL } from '@nestjs/cache-manager';

@Controller('api/craftsmen')
export class CraftsmenController {
  @Get('search')
  @UseInterceptors(CacheInterceptor)
  @CacheTTL(300) // 5 minutes
  async searchCraftsmen(@Query() query: SearchCraftsmenDto) {
    // This will be cached
    return this.craftsmanService.search(query);
  }

  @Get(':id')
  @UseInterceptors(CacheInterceptor)
  @CacheTTL(600) // 10 minutes
  async getCraftsman(@Param('id') id: string) {
    return this.craftsmanService.findById(id);
  }

  @Get(':id/reviews')
  @UseInterceptors(CacheInterceptor)
  @CacheTTL(300) // 5 minutes
  async getCraftsmanReviews(@Param('id') id: string) {
    return this.reviewsService.findByCraftsmanId(id);
  }
}
```

### 2.4 Cache Keys to Implement

| Endpoint | Cache TTL | Key Pattern |
|----------|-----------|-------------|
| `GET /api/craftsmen/search` | 5 min | `craftsmen:search:{filters}` |
| `GET /api/craftsmen/:id` | 10 min | `craftsman:{id}` |
| `GET /api/jobs` | 2 min | `jobs:list:{filters}` |
| `GET /api/inspiration/feed` | 5 min | `inspiration:feed:{page}` |
| `GET /api/reviews/:craftsmanId` | 5 min | `reviews:{craftsmanId}` |
| Static assets | 1 year | Browser cache |

### 2.5 Cache Invalidation Strategy

```typescript
// src/cache/cache.service.ts
@Injectable()
export class CacheService {
  constructor(@Inject(CACHE_MANAGER) private cacheManager: Cache) {}

  async invalidateCraftsman(craftsmanId: string) {
    const keys = [
      `craftsman:${craftsmanId}`,
      `reviews:${craftsmanId}`,
      `craftsmen:search:*`, // Invalidate all search results
    ];

    await Promise.all(keys.map(key => this.cacheManager.del(key)));
  }

  async invalidateJob(jobId: string) {
    await this.cacheManager.del(`job:${jobId}`);
    await this.cacheManager.del('jobs:list:*');
  }
}
```

---

## 3. Google Cloud Integration

### 3.1 Current Integrations

✅ **Google Cloud Storage** - Already integrated for media uploads
✅ **Firebase Authentication** - Already integrated
✅ **Firebase Cloud Messaging** - Push notifications integrated

### 3.2 Additional Google Cloud Services to Add

#### 3.2.1 Cloud CDN for Static Assets

**Setup:**

1. Create Cloud CDN backend bucket:
```bash
gsutil mb gs://mesteri-cdn-assets
gsutil iam ch allUsers:objectViewer gs://mesteri-cdn-assets
```

2. Enable Cloud CDN:
```bash
gcloud compute backend-buckets create mesteri-cdn \
  --gcs-bucket-name=mesteri-cdn-assets \
  --enable-cdn
```

3. Update frontend to use CDN URLs:
```dart
// Flutter: lib/src/core/config/api_config.dart
class ApiConfig {
  static const String cdnBaseUrl = 'https://cdn.mesteri.ro';
  static String getCdnUrl(String path) => '$cdnBaseUrl/$path';
}
```

#### 3.2.2 Cloud SQL (PostgreSQL) with Connection Pooling

**Environment variables:**

```env
# Instead of DATABASE_URL
DB_HOST=/cloudsql/PROJECT_ID:REGION:INSTANCE_NAME
DB_USER=mesteri_user
DB_PASSWORD=secure_password
DB_NAME=mesteri_db
DB_SOCKET_PATH=/cloudsql/PROJECT_ID:REGION:INSTANCE_NAME
```

**Prisma configuration for Cloud SQL:**

```typescript
// src/prisma/prisma.service.ts
@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  constructor() {
    super({
      datasources: {
        db: {
          url: process.env.DATABASE_URL ||
               `postgresql://${process.env.DB_USER}:${process.env.DB_PASSWORD}@${process.env.DB_HOST}/${process.env.DB_NAME}?host=${process.env.DB_SOCKET_PATH}`,
        },
      },
      log: ['error', 'warn'],
    });
  }
}
```

#### 3.2.3 Cloud Monitoring & Logging

**Install dependencies:**

```bash
npm install @google-cloud/logging @google-cloud/monitoring
```

**Create logging service:**

```typescript
// src/logging/cloud-logging.service.ts
import { Logging } from '@google-cloud/logging';
import { Injectable } from '@nestjs/common';

@Injectable()
export class CloudLoggingService {
  private logging = new Logging();
  private log = this.logging.log('mesteri-platform');

  async logError(error: Error, context: string) {
    const metadata = { severity: 'ERROR' };
    const entry = this.log.entry(metadata, {
      message: error.message,
      stack: error.stack,
      context,
      timestamp: new Date(),
    });

    await this.log.write(entry);
  }

  async logInfo(message: string, data?: any) {
    const metadata = { severity: 'INFO' };
    const entry = this.log.entry(metadata, { message, data });
    await this.log.write(entry);
  }
}
```

#### 3.2.4 Cloud Pub/Sub for Async Processing

**Use cases:**
- Email sending (async)
- Push notifications (async)
- Image processing (async)
- Contract PDF generation (async)

**Setup:**

```typescript
// src/pubsub/pubsub.service.ts
import { PubSub } from '@google-cloud/pubsub';

@Injectable()
export class PubSubService {
  private pubsub = new PubSub();

  async publishEmailJob(email: string, template: string, data: any) {
    const topic = this.pubsub.topic('email-jobs');
    const dataBuffer = Buffer.from(JSON.stringify({ email, template, data }));

    await topic.publish(dataBuffer);
  }

  async publishImageProcessing(imageId: string, operations: any) {
    const topic = this.pubsub.topic('image-processing');
    const dataBuffer = Buffer.from(JSON.stringify({ imageId, operations }));

    await topic.publish(dataBuffer);
  }
}
```

---

## 4. CDN & Static Assets

### 4.1 CloudFlare CDN Setup (Recommended Alternative to Google Cloud CDN)

**Why CloudFlare:**
- Free tier available
- Better global coverage
- Built-in DDoS protection
- Automatic image optimization

**Setup:**

1. **Domain Configuration:**
   - Point `mesteri.ro` → CloudFlare nameservers
   - Enable "Full (strict)" SSL/TLS mode
   - Enable "Always Use HTTPS"

2. **Page Rules:**
   ```
   /api/* → Cache Level: Bypass
   /uploads/* → Cache Level: Standard, Edge Cache TTL: 1 month
   /static/* → Cache Level: Standard, Edge Cache TTL: 1 year
   /*.jpg, /*.png, /*.webp → Cache Level: Standard, Auto Minify
   ```

3. **Image Optimization:**
   - Enable "Polish" (Lossy)
   - Enable "Mirage" (Lazy loading)
   - Enable "WebP conversion"

### 4.2 Static Asset Optimization

**Backend configuration:**

```typescript
// src/main.ts
app.useStaticAssets(join(process.cwd(), 'storage/uploads'), {
  prefix: '/uploads/',
  maxAge: '365d', // 1 year browser cache
  etag: true,
  lastModified: true,
  immutable: true, // Assets never change
  setHeaders: (res, path) => {
    if (path.endsWith('.jpg') || path.endsWith('.png') || path.endsWith('.webp')) {
      res.setHeader('Cache-Control', 'public, max-age=31536000, immutable');
    }
  },
});
```

**Flutter asset optimization:**

```dart
// Use cached_network_image package
CachedNetworkImage(
  imageUrl: imageUrl,
  memCacheWidth: 800, // Resize in memory
  maxHeightDiskCache: 1000,
  cacheManager: CacheManager(
    Config(
      'mesteri_images',
      stalePeriod: Duration(days: 7),
      maxNrOfCacheObjects: 200,
    ),
  ),
);
```

---

## 5. Rate Limiting & DDoS Protection

### 5.1 Implement @nestjs/throttler

**Install:**

```bash
npm install @nestjs/throttler
```

**Configure:**

```typescript
// src/app.module.ts
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';

@Module({
  imports: [
    ThrottlerModule.forRoot([
      {
        name: 'short',
        ttl: 1000, // 1 second
        limit: 10, // 10 requests per second
      },
      {
        name: 'medium',
        ttl: 10000, // 10 seconds
        limit: 50, // 50 requests per 10 seconds
      },
      {
        name: 'long',
        ttl: 60000, // 1 minute
        limit: 200, // 200 requests per minute
      },
    ]),
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule {}
```

**Apply different limits to endpoints:**

```typescript
@Controller('api/auth')
export class AuthController {
  @Post('login')
  @Throttle({ short: { limit: 5, ttl: 60000 } }) // 5 logins per minute
  async login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto);
  }

  @Post('register')
  @Throttle({ short: { limit: 3, ttl: 3600000 } }) // 3 registrations per hour
  async register(@Body() registerDto: RegisterDto) {
    return this.authService.register(registerDto);
  }
}
```

### 5.2 IP-Based Rate Limiting with Redis

```typescript
// src/rate-limit/redis-rate-limit.service.ts
import { Injectable } from '@nestjs/common';
import { Redis } from 'ioredis';

@Injectable()
export class RedisRateLimitService {
  private redis = new Redis(process.env.REDIS_URL);

  async checkRateLimit(ip: string, endpoint: string, limit: number, windowSeconds: number): Promise<boolean> {
    const key = `rate_limit:${ip}:${endpoint}`;
    const current = await this.redis.incr(key);

    if (current === 1) {
      await this.redis.expire(key, windowSeconds);
    }

    return current <= limit;
  }
}
```

---

## 6. Load Balancing & Scaling

### 6.1 Horizontal Scaling with Docker Swarm

**docker-compose.prod.yml:**

```yaml
version: '3.8'

services:
  backend:
    image: mesteri-backend:latest
    deploy:
      replicas: 3 # Run 3 instances
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
    environment:
      - NODE_ENV=production
      - REDIS_HOST=redis
      - DATABASE_URL=${DATABASE_URL}
    depends_on:
      - redis
      - postgres

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    deploy:
      replicas: 2

  redis:
    image: redis:alpine
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == manager

  postgres:
    image: postgis/postgis:15-3.3
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == manager
```

### 6.2 NGINX Load Balancing Configuration

**nginx.conf:**

```nginx
upstream backend_servers {
    least_conn; # Use least connections algorithm
    server backend_1:3000 max_fails=3 fail_timeout=30s;
    server backend_2:3000 max_fails=3 fail_timeout=30s;
    server backend_3:3000 max_fails=3 fail_timeout=30s;
}

upstream websocket_servers {
    ip_hash; # Sticky sessions for WebSocket
    server backend_1:3000;
    server backend_2:3000;
    server backend_3:3000;
}

server {
    listen 80;
    server_name mesteri.ro www.mesteri.ro;

    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name mesteri.ro www.mesteri.ro;

    ssl_certificate /etc/nginx/ssl/mesteri.crt;
    ssl_certificate_key /etc/nginx/ssl/mesteri.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # WebSocket support
    location /api/messages {
        proxy_pass http://websocket_servers;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_read_timeout 86400; # 24 hours for WebSocket
    }

    # API endpoints
    location /api {
        proxy_pass http://backend_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Static assets
    location /uploads {
        alias /var/www/uploads;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
```

---

## 7. Performance Monitoring

### 7.1 Application Performance Monitoring (APM)

**Recommended: New Relic or Datadog**

**Install New Relic:**

```bash
npm install newrelic
```

**newrelic.js:**

```javascript
'use strict';

exports.config = {
  app_name: ['Mesteri Platform'],
  license_key: process.env.NEW_RELIC_LICENSE_KEY,
  logging: {
    level: 'info',
  },
  distributed_tracing: {
    enabled: true,
  },
  transaction_tracer: {
    enabled: true,
    transaction_threshold: 'apdex_f',
    record_sql: 'obfuscated',
  },
};
```

**Update main.ts:**

```typescript
// MUST be first import
require('newrelic');

import { NestFactory } from '@nestjs/core';
// ... rest of imports
```

### 7.2 Custom Performance Metrics

```typescript
// src/metrics/performance.interceptor.ts
import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

@Injectable()
export class PerformanceInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const { method, url } = request;
    const startTime = Date.now();

    return next.handle().pipe(
      tap(() => {
        const duration = Date.now() - startTime;

        if (duration > 1000) { // Log slow requests
          console.warn(`SLOW REQUEST: ${method} ${url} took ${duration}ms`);
        }

        // Send to monitoring service
        this.sendMetric('api.response_time', duration, {
          method,
          endpoint: url,
        });
      }),
    );
  }

  private sendMetric(name: string, value: number, tags: any) {
    // Send to New Relic, Datadog, or custom metrics service
  }
}
```

### 7.3 Database Query Monitoring

**Prisma Logging:**

```typescript
// src/prisma/prisma.service.ts
const prisma = new PrismaClient({
  log: [
    { emit: 'event', level: 'query' },
    { emit: 'event', level: 'error' },
    { emit: 'event', level: 'warn' },
  ],
});

prisma.$on('query', (e) => {
  if (e.duration > 1000) { // Log slow queries
    console.warn(`SLOW QUERY (${e.duration}ms): ${e.query}`);
  }
});
```

---

## 8. Code-Level Optimizations

### 8.1 Database Query Optimization

**Bad (N+1 Query Problem):**

```typescript
// DON'T DO THIS
const jobs = await this.prisma.job.findMany();
for (const job of jobs) {
  job.client = await this.prisma.user.findUnique({ where: { id: job.clientId } });
  job.offers = await this.prisma.offer.findMany({ where: { jobId: job.id } });
}
```

**Good (Use Prisma Include):**

```typescript
// DO THIS
const jobs = await this.prisma.job.findMany({
  include: {
    client: {
      select: {
        id: true,
        fullName: true,
        avatarUrl: true,
      },
    },
    offers: {
      select: {
        id: true,
        bidAmount: true,
        craftsmanId: true,
      },
    },
  },
});
```

### 8.2 Pagination for Large Datasets

```typescript
// src/jobs/jobs.service.ts
async findAvailableJobs(page: number = 1, limit: number = 20) {
  const skip = (page - 1) * limit;

  const [jobs, total] = await Promise.all([
    this.prisma.job.findMany({
      where: { status: 'ACTIVE', deletedAt: null },
      skip,
      take: limit,
      orderBy: { createdAt: 'desc' },
      include: {
        client: {
          select: { id: true, fullName: true },
        },
      },
    }),
    this.prisma.job.count({
      where: { status: 'ACTIVE', deletedAt: null },
    }),
  ]);

  return {
    data: jobs,
    pagination: {
      page,
      limit,
      total,
      pages: Math.ceil(total / limit),
    },
  };
}
```

### 8.3 Lazy Loading for Large Objects

```typescript
// Don't load full user profile if only ID is needed
async getJobWithClient(jobId: string) {
  return this.prisma.job.findUnique({
    where: { id: jobId },
    include: {
      client: {
        select: {
          id: true,
          fullName: true,
          email: true,
          // Don't include: bio, preferences, metadata, etc.
        },
      },
    },
  });
}
```

### 8.4 Async Processing for Heavy Operations

```typescript
// DON'T block the request
@Post('contracts/:id/generate-pdf')
async generatePDF(@Param('id') contractId: string) {
  // This blocks for 5-10 seconds
  const pdf = await this.contractService.generatePDF(contractId);
  return { url: pdf.url };
}

// DO use background jobs
@Post('contracts/:id/generate-pdf')
async generatePDF(@Param('id') contractId: string) {
  // Queue the job and return immediately
  await this.queueService.add('generate-pdf', { contractId });

  return {
    status: 'processing',
    message: 'PDF generation started. You will receive a notification when ready.',
  };
}
```

---

## 9. Database Connection Pooling

### 9.1 Prisma Connection Pool Configuration

**Update `prisma/schema.prisma`:**

```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  // Connection pool settings
  relationMode = "prisma"
}
```

**Environment variables:**

```env
# Database connection with connection pooling
DATABASE_URL="postgresql://user:pass@host:5432/db?schema=public&connection_limit=20&pool_timeout=10"

# For production with PgBouncer
DATABASE_URL="postgresql://user:pass@pgbouncer:6432/db?schema=public&pgbouncer=true"
```

### 9.2 PgBouncer Setup (Recommended for Production)

**docker-compose.prod.yml:**

```yaml
services:
  pgbouncer:
    image: edoburu/pgbouncer:latest
    environment:
      - DATABASE_URL=postgresql://mesteri_user:password@postgres:5432/mesteri_db
      - POOL_MODE=transaction
      - MAX_CLIENT_CONN=1000
      - DEFAULT_POOL_SIZE=25
      - RESERVE_POOL_SIZE=5
    ports:
      - "6432:6432"
    depends_on:
      - postgres
```

---

## 10. WebSocket Optimization

### 10.1 Redis Adapter for Socket.IO

**Install:**

```bash
npm install @socket.io/redis-adapter redis
```

**Configure:**

```typescript
// src/messages/messages.gateway.ts
import { IoAdapter } from '@nestjs/platform-socket.io';
import { createAdapter } from '@socket.io/redis-adapter';
import { createClient } from 'redis';

export class RedisIoAdapter extends IoAdapter {
  private adapterConstructor: ReturnType<typeof createAdapter>;

  async connectToRedis(): Promise<void> {
    const pubClient = createClient({ url: process.env.REDIS_URL });
    const subClient = pubClient.duplicate();

    await Promise.all([pubClient.connect(), subClient.connect()]);

    this.adapterConstructor = createAdapter(pubClient, subClient);
  }

  createIOServer(port: number, options?: any): any {
    const server = super.createIOServer(port, options);
    server.adapter(this.adapterConstructor);
    return server;
  }
}
```

**Apply in main.ts:**

```typescript
async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const redisIoAdapter = new RedisIoAdapter(app);
  await redisIoAdapter.connectToRedis();
  app.useWebSocketAdapter(redisIoAdapter);

  await app.listen(3000);
}
```

---

## Summary Checklist

### Immediate Actions (Week 1):

- [ ] Add database indexes for high-traffic queries
- [ ] Enable pg_trgm and full-text search extensions
- [ ] Set up Redis caching for craftsman search and job listings
- [ ] Configure CloudFlare CDN
- [ ] Implement rate limiting with @nestjs/throttler
- [ ] Add connection pooling to Prisma

### Short-term (Month 1):

- [ ] Set up Cloud SQL with connection pooling
- [ ] Implement Cloud CDN for static assets
- [ ] Configure NGINX load balancing
- [ ] Add APM monitoring (New Relic/Datadog)
- [ ] Set up Cloud Pub/Sub for async processing
- [ ] Implement Redis adapter for Socket.IO

### Medium-term (Month 2-3):

- [ ] Horizontal scaling with Docker Swarm/Kubernetes
- [ ] Advanced caching strategies
- [ ] Database query optimization audit
- [ ] Performance testing and benchmarking
- [ ] Set up automated scaling rules
- [ ] Implement advanced monitoring and alerting

---

**Expected Performance Improvements:**

| Metric | Before | After Optimization | Improvement |
|--------|--------|-------------------|-------------|
| API Response Time | 300-500ms | 50-150ms | 60-70% faster |
| Database Queries | 100-200ms | 10-50ms | 70-90% faster |
| Craftsman Search | 800ms | 100ms | 87.5% faster |
| TikTok Feed Load | 1000ms | 150ms | 85% faster |
| Concurrent Users | 100 | 10,000+ | 100x capacity |
| WebSocket Connections | 500 | 50,000+ | 100x capacity |

---

**Estimated Costs (Google Cloud):**

- Cloud SQL (db-n1-standard-2): ~$150/month
- Cloud Storage: ~$20/month
- Cloud CDN: ~$30/month (per TB)
- Cloud Pub/Sub: ~$10/month
- Cloud Monitoring: Free tier
- **Total**: ~$210/month for moderate traffic

**Alternative (CloudFlare + DigitalOcean):**

- CloudFlare CDN: Free
- DigitalOcean Managed Database: $60/month
- DigitalOcean Droplets (3x): $36/month
- Redis: $15/month
- **Total**: ~$111/month

---

Made with ⚡ for high-performance production deployment!
