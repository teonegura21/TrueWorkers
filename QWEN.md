# Mesteri Platform - Complete Technical Documentation

## Overview

The Mesteri Platform is a Romanian marketplace connecting homeowners with verified craftsmen through a trust-based system and TikTok-style inspiration feed. The platform addresses the trust crisis in the craftsman industry in Romania by providing verification, reviews, transparent processes, and secure payment systems. It's designed as a comprehensive solution for both homeowners seeking reliable craftsmen and craftsmen looking for verified work opportunities.

## Table of Contents
1. [Architecture & Design Philosophy](#architecture--design-philosophy)
2. [Technology Stack](#technology-stack)
3. [Project Structure](#project-structure)
4. [Backend Architecture](#backend-architecture)
5. [Frontend Architecture](#frontend-architecture)
6. [Database Schema](#database-schema)
7. [API Endpoints](#api-endpoints)
8. [Key Features](#key-features)
9. [Deployment & Infrastructure](#deployment--infrastructure)
10. [Security Implementation](#security-implementation)
11. [Development Methodologies](#development-methodologies)
12. [Implementation Status](#implementation-status)

## Architecture & Design Philosophy

The Mesteri Platform follows a **monorepo architecture** pattern, which evolved from an original microservices blueprint to a monolithic approach for faster MVP delivery. This pragmatic decision prioritizes rapid development and easier debugging over complex distributed systems during the initial phase.

### Original Blueprint vs Current Implementation:
- **Blueprint**: Planned microservices architecture
- **Current**: Monolithic NestJS application with 14 integrated modules
- **Rationale**: Faster time-to-market, simpler debugging, and lower infrastructure costs during MVP phase

### Core Architecture Pattern:
The system follows an **event-driven architecture** with real-time WebSocket communication for messaging and notifications, while maintaining RESTful APIs for most business operations.

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENTS                                 │
├──────────────────────────┬──────────────────────────────────────┤
│  Craftsman Flutter App   │    Client Flutter App               │
│  (iOS/Android/Web)       │  (iOS/Android/Web)                  │
└──────────────┬───────────┴───────────────┬──────────────────────┘
               │                           │
               ▼                           ▼
        ┌──────────────────────────────────────────┐
        │          API Gateway (Nginx)             │
        │  - Rate Limiting                         │
        │  - Authentication                        │
        │  - Request Routing                       │
        │  - SSL Termination                       │
        └──────────────────┬───────────────────────┘
                           │
        ┌──────────────────▼───────────────────────┐
        │         Load Balancer (HAProxy)          │
        └──────────────────┬───────────────────────┘
                           │
    ┌──────────────────────┴──────────────────────────┐
    │              NESTJS MICROSERVICE LAYER           │
    │  (Actually Monolithic with Multiple Modules)   │
    ├───────────────────────────────────────────────────┤
    │  ┌─────────────┐  ┌─────────────┐  ┌──────────┐ │
    │  │Auth Module  │  │User Module  │  │Feed Mod  │ │
    │  └─────────────┘  └─────────────┘  └──────────┘ │
    │  ┌─────────────┐  ┌─────────────┐  ┌──────────┐ │
    │  │Contract Mod │  │Payment Mod  │  │Chat Mod  │ │
    │  └─────────────┘  └─────────────┘  └──────────┘ │
    │  ┌─────────────┐  ┌─────────────┐  ┌──────────┐ │
    │  │Media Module │  │Search Module│  │Notif Mod │ │
    │  └─────────────┘  └─────────────┘  └──────────┘ │
    └───────────────────────────────────────────────────┘
                           │
    ┌──────────────────────▼──────────────────────────┐
    │           Message Queue (Internal Events)       │
    └──────────────────────────────────────────────────┘
                           │
    ┌──────────────────────▼──────────────────────────┐
    │              DATA LAYER                          │
    ├───────────────────────────────────────────────────┤
    │  PostgreSQL     Redis        Elasticsearch       │
    │  (Primary DB)   (Cache)      (Search)           │
    │                                                  │
    │  Google Cloud   CDN          S3-Compatible      │
    │  Storage        (CloudFlare) (Media Storage)    │
    └───────────────────────────────────────────────────┘
```

## Technology Stack

### Backend Technologies:
- **NestJS** (v11.0) - Modern Node.js framework with TypeScript support
- **Prisma ORM** - Type-safe database access and migration system
- **PostgreSQL** - Primary database with PostGIS extension for geographic queries
- **Firebase Admin SDK** - Authentication token verification
- **Socket.IO** - Real-time WebSocket communication
- **Multer** - File upload handling
- **Sharp** - Image processing and optimization
- **FFmpeg** - Video processing and compression
- **Stripe** - Payment processing
- **Express.js** - HTTP server framework

### Frontend Technologies:
- **Flutter** (v3.9+) - Cross-platform framework for iOS, Android, and Web
- **Dart** - Programming language for Flutter applications
- **Provider** - State management solution
- **Dio** - HTTP client for API communication
- **Socket.IO Client** - Real-time messaging in Flutter

### Infrastructure & Deployment:
- **Docker & Docker Compose** - Containerization and orchestration
- **Nginx** - Web server and reverse proxy
- **Redis** - Caching layer
- **Google Cloud Storage** - File storage for media and contracts
- **Firebase** - Authentication and push notifications
- **Git** - Version control system

### Development Tools:
- **Prisma CLI** - Database schema management
- **Webpack** - Module bundling
- **TypeScript** - Typed JavaScript superset
- **Dart Analysis Tools** - Flutter code analysis

## Project Structure

### Root Directory Structure:
```
AplicatieMesteri/
├── .gitignore
├── README.md - Main project documentation
├── IMPLEMENTATION_COMPLETE.md - Detailed implementation status
├── IMPLEMENTATION_STATUS.md - Progress tracking against blueprint
├── TECHNICAL_DOCUMENTATION.md - Comprehensive technical overview
├── DEPLOYMENT_GUIDE.md - Deployment instructions
├── QWEN.md - THIS FILE (Comprehensive technical documentation)
├── CONTRACT_SIGNING_TESTING_STRATEGY.md - Digital signature workflow
├── NOTIFICATION_SYSTEM_IMPLEMENTATION.md - Notification system details
├── MEDIA_UPLOAD_IMPLEMENTATION_STATUS.md - Media upload documentation
├── QUICK_START_GUIDE.md - Quick start instructions
├── SIGNREQUEST_SANDBOX_SETUP.md - Contract signing setup
├── TESTING_GUIDE.md - Testing procedures
├── mesteri-platform/ - Main application code
│   ├── backend/ - NestJS API server
│   ├── app_client/ - Flutter client app (homeowners)
│   └── app_mester/ - Flutter craftsman app
├── docker-compose.prod.yml - Production infrastructure
├── deploy.ps1/.sh - Deployment scripts
└── start-dev.ps1/.sh - Development startup scripts
```

### Backend Structure:
```
mesteri-platform/backend/
├── src/
│   ├── main.ts - Application entry point
│   ├── auth/ - Authentication module
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   ├── auth.guard.ts
│   │   └── dto/
│   ├── users/ - User management module
│   │   ├── users.controller.ts
│   │   ├── users.service.ts
│   │   └── dto/
│   ├── jobs/ - Job posting module
│   │   ├── jobs.controller.ts
│   │   ├── jobs.service.ts
│   │   └── dto/
│   ├── offers/ - Offer submission module
│   │   ├── offers.controller.ts
│   │   ├── offers.service.ts
│   │   └── dto/
│   ├── projects/ - Project lifecycle module
│   │   ├── projects.controller.ts
│   │   ├── projects.service.ts
│   │   └── dto/
│   ├── payments/ - Payment processing module
│   │   ├── payments.controller.ts
│   │   ├── payments.service.ts
│   │   └── dto/
│   ├── reviews/ - Review system module
│   │   ├── reviews.controller.ts
│   │   ├── reviews.service.ts
│   │   └── dto/
│   ├── messages/ - Real-time messaging module
│   │   ├── messages.controller.ts
│   │   ├── messages.service.ts
│   │   ├── messages.gateway.ts - WebSocket gateway
│   │   └── dto/
│   ├── conversations/ - Conversation management
│   │   ├── conversations.controller.ts
│   │   ├── conversations.service.ts
│   │   └── dto/
│   ├── notifications/ - Push/email notifications
│   │   ├── notifications.module.ts
│   │   ├── notifications.service.ts
│   │   ├── push-notification.service.ts
│   │   ├── email-notification.service.ts
│   │   ├── notifications.controller.ts
│   │   ├── templates/ - Email templates
│   │   │   ├── welcome.hbs
│   │   │   ├── contract-created.hbs
│   │   │   ├── contract-signed.hbs
│   │   │   ├── payment-confirmation.hbs
│   │   │   ├── offer-submitted.hbs
│   │   │   └── project-completed.hbs
│   │   └── dto/
│   ├── storage/ - File upload and storage module
│   │   ├── storage.controller.ts
│   │   ├── storage.service.ts
│   │   └── middleware/
│   ├── verification/ - User verification module
│   │   ├── verification.controller.ts
│   │   ├── verification.service.ts
│   │   └── dto/
│   ├── inspiration/ - Content feed module
│   │   ├── inspiration.controller.ts
│   │   ├── inspiration.service.ts
│   │   └── dto/
│   ├── analytics/ - Analytics tracking module
│   │   ├── analytics.controller.ts
│   │   ├── analytics.service.ts
│   │   └── dto/
│   ├── contracts/ - Contract management module
│   │   ├── contracts.controller.ts
│   │   ├── contracts.service.ts
│   │   └── dto/
│   ├── media/ - Media upload system
│   │   ├── media.controller.ts
│   │   ├── media.service.ts
│   │   ├── media.module.ts
│   │   ├── middleware/
│   │   │   └── file-validation.middleware.ts
│   │   └── dto/
│   │       ├── upload-media.dto.ts
│   │       ├── get-media-query.dto.ts
│   │       └── index.ts
│   ├── prisma/ - Database schema and migrations
│   │   ├── schema.prisma
│   │   ├── migrations/
│   │   └── seed.ts
│   ├── common/ - Shared utilities and decorators
│   │   ├── decorators/
│   │   ├── filters/
│   │   ├── guards/
│   │   └── interceptors/
│   └── config/ - Configuration files
│       ├── database.config.ts
│       └── auth.config.ts
├── package.json - Dependencies and scripts
├── tsconfig.json - TypeScript configuration
├── tsconfig.build.json - TypeScript build configuration
├── nest-cli.json - NestJS CLI configuration
├── Dockerfile - Container configuration
├── .dockerignore
├── .env* - Environment configuration files
└── README.md - Backend documentation
```

### Client App Structure (Flutter):
```
mesteri-platform/app_client/
├── lib/
│   ├── main.dart - Application entry point
│   ├── src/
│   │   ├── core/ - Core services and configuration
│   │   │   ├── config/
│   │   │   │   ├── api_config.dart
│   │   │   │   ├── app_config.dart
│   │   │   │   └── theme_config.dart
│   │   │   ├── services/
│   │   │   │   ├── auth_service.dart
│   │   │   │   ├── api_client.dart
│   │   │   │   ├── firebase_service.dart
│   │   │   │   └── notification_service.dart
│   │   │   └── utils/
│   │   │       ├── constants.dart
│   │   │       ├── validators.dart
│   │   │       └── extensions.dart
│   │   └── features/ - Feature modules
│   │       ├── auth/ - Authentication screens
│   │       │   ├── presentation/
│   │       │   │   ├── screens/
│   │       │   │   │   ├── welcome_screen.dart
│   │       │   │   │   ├── login_screen.dart
│   │       │   │   │   ├── register_screen.dart
│   │       │   │   │   └── forgot_password_screen.dart
│   │       │   │   └── widgets/
│   │       │   └── domain/
│   │       ├── home/ - Home/dashboard screens
│   │       │   ├── presentation/
│   │       │   └── domain/
│   │       ├── jobs/ - Job management screens
│   │       │   ├── presentation/
│   │       │   └── domain/
│   │       ├── craftsmen/ - Craftsman discovery
│   │       │   ├── presentation/
│   │       │   └── domain/
│   │       ├── chat/ - Messaging screens
│   │       │   ├── presentation/
│   │       │   └── domain/
│   │       ├── projects/ - Project tracking
│   │       │   ├── presentation/
│   │       │   └── domain/
│   │       ├── payments/ - Payment processing
│   │       │   ├── presentation/
│   │       │   └── domain/
│   │       └── profile/ - User profile
│   │           ├── presentation/
│   │           └── domain/
├── pubspec.yaml - Flutter dependencies and configuration
├── assets/ - Static assets
├── android/ - Android-specific configuration
├── ios/ - iOS-specific configuration
├── web/ - Web-specific configuration
├── Dockerfile - Container configuration for web deployment
├── nginx.conf - Web server configuration
└── README.md - Client app documentation
```

### Craftsman App Structure (Flutter):
```
mesteri-platform/app_mester/
├── lib/
│   ├── main.dart - Application entry point
│   ├── src/
│   │   ├── core/ - Core services and configuration
│   │   └── features/ - Feature modules
│   │       ├── auth/ - Authentication
│   │       ├── dashboard/ - Craftsman dashboard
│   │       ├── jobs/ - Job discovery
│   │       ├── offers/ - Job offers
│   │       ├── portfolio/ - Portfolio management
│   │       ├── projects/ - Project management
│   │       ├── wallet/ - Payment and earnings
│   │       └── profile/ - Profile management
├── pubspec.yaml - Flutter dependencies and configuration
├── assets/ - Static assets
├── android/ - Android-specific configuration
├── ios/ - iOS-specific configuration
├── web/ - Web-specific configuration
├── Dockerfile - Container configuration for web deployment
├── nginx.conf - Web server configuration
└── README.md - Craftsman app documentation
```

## Backend Architecture

### Module Structure:
The backend follows the **NestJS module pattern** where each feature is encapsulated in its own module with clear separation of concerns:

- **Controllers**: Handle HTTP requests and responses
- **Services**: Contain business logic and interact with other services
- **DTOs**: Define data transfer objects for validation
- **Guards**: Handle authentication and authorization
- **Middleware**: Handle cross-cutting concerns

### Authentication Flow:
```
1. User registers/logs in via Firebase
2. Firebase returns JWT token
3. Token is attached to all API requests as Authorization header
4. FirebaseAuthGuard validates token using Firebase Admin SDK
5. User identity is attached to request object
6. Controller methods can access user info via @CurrentUser() decorator
```

### Database Access Pattern:
- **Prisma ORM** provides type-safe database access
- **Repository pattern** implemented through Prisma client
- **Transaction management** for complex operations
- **Raw SQL queries** available when needed

### Real-time Communication:
- **Socket.IO** for WebSocket communication
- **MessagesGateway** handles real-time messaging
- **Event-driven architecture** for chat notifications

## Frontend Architecture

### Flutter Architecture Pattern:
Both Flutter applications follow a **feature-based architecture** with clear separation between presentation and domain layers:

- **Presentation Layer**: UI components, screens, and widgets
- **Domain Layer**: Business logic, services, and models
- **Core Layer**: Shared utilities, services, and configuration

### State Management:
- **Provider** as the primary state management solution
- **ChangeNotifier** for simple state updates
- **FutureProvider** and **StreamProvider** for async data
- **NotifierProvider** for complex state management

### API Integration:
- **Dio** HTTP client for all API communication
- **Interceptors** for authentication headers
- **Repository pattern** for data abstraction
- **DTOs** for type-safe data transfer

## Database Schema

### Core Database Design Principles:
- **PostgreSQL** with **PostGIS** for geographic queries
- **UUID primary keys** for all tables
- **Soft deletes** using `deleted_at` timestamps
- **JSONB fields** for flexible data storage
- **Enums** for status fields and categorization
- **Geographic indexing** for location-based queries

### Complete Schema Overview:

#### Users and Authentication:
```sql
-- User authentication and roles
CREATE TYPE user_role AS ENUM ('CLIENT', 'CRAFTSMAN', 'ADMIN');
CREATE TYPE verification_status AS ENUM ('NONE', 'PENDING', 'VERIFIED', 'REJECTED');

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    firebase_uid VARCHAR(255) UNIQUE NOT NULL, -- No password_hash since using Firebase
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    role user_role NOT NULL,
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    INDEX idx_users_email (email),
    INDEX idx_users_firebase_uid (firebase_uid)
);

CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    display_name VARCHAR(200),
    avatar_url TEXT,
    bio TEXT,
    location GEOGRAPHY(POINT, 4326), -- PostGIS geographic point
    city VARCHAR(100),
    county VARCHAR(100),
    address TEXT,
    postal_code VARCHAR(10),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id),
    INDEX idx_profiles_location USING GIST(location),
    INDEX idx_profiles_name (first_name, last_name)
);
```

#### Craftsman-Specific Tables:
```sql
CREATE TYPE craftsman_tier AS ENUM ('BASIC', 'VERIFIED', 'PRO', 'MASTER');

CREATE TABLE craftsman_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    business_name VARCHAR(255),
    cui VARCHAR(20), -- Cod Unic de Înregistrare
    business_type VARCHAR(50), -- PFA, SRL, etc.
    business_verification_status verification_status DEFAULT 'NONE',
    business_verified_at TIMESTAMP WITH TIME ZONE,
    years_of_experience INTEGER,
    certifications JSONB DEFAULT '[]',
    is_available BOOLEAN DEFAULT true,
    available_radius_km INTEGER DEFAULT 50,
    total_projects_completed INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    hourly_rate_min DECIMAL(10,2),
    hourly_rate_max DECIMAL(10,2),
    specialties TEXT[], -- Array of specialty names
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id),
    INDEX idx_craftsman_tier (tier),
    INDEX idx_craftsman_available (is_available),
    INDEX idx_craftsman_rating (average_rating DESC)
);
```

#### Jobs and Projects:
```sql
CREATE TYPE job_category AS ENUM (
    'INSTALATII_SANITARE', 'ZUGRAVIT', 'GRESIE_SI_FAIENTA', 
    'CONSTRUCTII', 'ELECTRICIAN', 'TAPSITOR', 'USCATORII'
);

CREATE TYPE job_status AS ENUM ('DRAFT', 'PUBLISHED', 'ACCEPTED', 'COMPLETED', 'CANCELLED');
CREATE TYPE project_status AS ENUM (
    'INQUIRY', 'NEGOTIATION', 'QUOTE_SENT', 'CONTRACT_PENDING',
    'CONTRACT_SIGNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'DISPUTED'
);

CREATE TABLE jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category job_category NOT NULL,
    location GEOGRAPHY(POINT, 4326),
    city VARCHAR(100),
    budget_min DECIMAL(10,2),
    budget_max DECIMAL(10,2),
    urgency VARCHAR(20),
    status job_status DEFAULT 'PUBLISHED',
    client_id UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_jobs_category (category),
    INDEX idx_jobs_location USING GIST(location),
    INDEX idx_jobs_status (status),
    INDEX idx_jobs_client (client_id)
);

CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    total_budget DECIMAL(12,2),
    status project_status DEFAULT 'INQUIRY',
    job_id UUID REFERENCES jobs(id) ON DELETE SET NULL,
    client_id UUID NOT NULL REFERENCES users(id),
    craftsman_id UUID NOT NULL REFERENCES users(id),
    agreed_price DECIMAL(12,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_projects_client (client_id),
    INDEX idx_projects_craftsman (craftsman_id),
    INDEX idx_projects_status (status),
    INDEX idx_projects_created (created_at DESC)
);
```

#### Messaging System:
```sql
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id),
    client_id UUID NOT NULL REFERENCES users(id),
    craftsman_id UUID NOT NULL REFERENCES users(id),
    is_active BOOLEAN DEFAULT true,
    last_message_at TIMESTAMP WITH TIME ZONE,
    last_message_preview TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(client_id, craftsman_id, project_id),
    INDEX idx_conversations_client (client_id),
    INDEX idx_conversations_craftsman (craftsman_id),
    INDEX idx_conversations_activity (last_message_at DESC)
);

CREATE TYPE message_type AS ENUM ('TEXT', 'IMAGE', 'VIDEO', 'DOCUMENT', 'QUOTE', 'CONTRACT_PROPOSAL', 'SYSTEM');

CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id),
    type message_type DEFAULT 'TEXT',
    content TEXT,
    media_urls JSONB DEFAULT '[]',
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_messages_conversation (conversation_id),
    INDEX idx_messages_sender (sender_id),
    INDEX idx_messages_created (created_at DESC)
);
```

#### Payment System:
```sql
CREATE TYPE payment_status AS ENUM ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'REFUNDED', 'DISPUTED');
CREATE TYPE transaction_type AS ENUM (
    'PROJECT_PAYMENT', 'MILESTONE_PAYMENT', 'SUBSCRIPTION', 
    'FEATURED_LISTING', 'REFUND', 'WITHDRAWAL'
);
CREATE TYPE transaction_status AS ENUM (
    'PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'REFUNDED', 'DISPUTED'
);

CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id),
    amount DECIMAL(10,2) NOT NULL,
    status payment_status DEFAULT 'PENDING',
    stripe_payment_intent_id VARCHAR(255),
    client_id UUID NOT NULL REFERENCES users(id),
    craftsman_id UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    INDEX idx_payments_project (project_id),
    INDEX idx_payments_status (status),
    INDEX idx_payments_client (client_id)
);

CREATE TABLE wallets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    balance DECIMAL(12,2) DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'RON',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE withdrawals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    amount DECIMAL(12,2) NOT NULL,
    status payment_status DEFAULT 'PENDING',
    stripe_payout_id VARCHAR(255),
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP WITH TIME ZONE,
    
    INDEX idx_withdrawals_user (user_id),
    INDEX idx_withdrawals_status (status)
);
```

#### Content and Inspiration Feed:
```sql
CREATE TYPE content_status AS ENUM ('DRAFT', 'PROCESSING', 'PUBLISHED', 'HIDDEN', 'REMOVED');

CREATE TABLE inspiration_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255),
    description TEXT,
    media_urls JSONB NOT NULL, -- Array of media URLs
    thumbnail_url TEXT,
    location GEOGRAPHY(POINT, 4326),
    location_name VARCHAR(255),
    category_id UUID REFERENCES craft_categories(id),
    views_count INTEGER DEFAULT 0,
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    craftsman_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status content_status DEFAULT 'PUBLISHED',
    published_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_posts_craftsman (craftsman_id),
    INDEX idx_posts_status (status),
    INDEX idx_posts_published (published_at DESC),
    INDEX idx_posts_location USING GIST(location),
    INDEX idx_posts_engagement (likes_count DESC, views_count DESC)
);
```

#### Reviews and Ratings:
```sql
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    reviewer_id UUID NOT NULL REFERENCES users(id),
    reviewed_user_id UUID NOT NULL REFERENCES users(id),
    overall_rating INTEGER NOT NULL CHECK (overall_rating >= 1 AND overall_rating <= 5),
    quality_rating INTEGER CHECK (quality_rating >= 1 AND quality_rating <= 5),
    punctuality_rating INTEGER CHECK (punctuality_rating >= 1 AND punctuality_rating <= 5),
    communication_rating INTEGER CHECK (communication_rating >= 1 AND communication_rating <= 5),
    price_value_rating INTEGER CHECK (price_value_rating >= 1 AND price_value_rating <= 5),
    title VARCHAR(255),
    comment TEXT,
    photos JSONB DEFAULT '[]',
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(project_id, reviewer_id),
    INDEX idx_reviews_project (project_id),
    INDEX idx_reviews_reviewed (reviewed_user_id),
    INDEX idx_reviews_rating (overall_rating DESC)
);
```

#### Media Attachments:
```sql
CREATE TYPE media_file_type AS ENUM ('IMAGE', 'VIDEO');
CREATE TYPE media_category AS ENUM ('PORTFOLIO', 'PROFILE', 'JOB', 'BEFORE_AFTER', 'INSPIRATION');
CREATE TYPE media_status AS ENUM ('PROCESSING', 'ACTIVE', 'FAILED', 'DELETED');

CREATE TABLE media_attachments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    file_name VARCHAR(255) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    thumbnail_path VARCHAR(500),
    medium_path VARCHAR(500),
    file_size BIGINT NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    width INTEGER,
    height INTEGER,
    duration INTEGER, -- For videos
    category media_category NOT NULL,
    entity_id UUID, -- Related entity ID (project, job, etc.)
    file_type media_file_type NOT NULL,
    status media_status DEFAULT 'ACTIVE',
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_media_user (user_id),
    INDEX idx_media_category (category),
    INDEX idx_media_entity (entity_id),
    INDEX idx_media_type (file_type),
    INDEX idx_media_status (status)
);
```

#### Notifications:
```sql
CREATE TYPE notification_type AS ENUM (
    'NEW_MESSAGE', 'NEW_JOB', 'OFFER_ACCEPTED', 'CONTRACT_SIGNED', 
    'PAYMENT_RECEIVED', 'NEW_REVIEW', 'PROJECT_COMPLETED', 'WELCOME'
);
CREATE TYPE notification_channel AS ENUM ('PUSH', 'EMAIL');
CREATE TYPE notification_status AS ENUM ('PENDING', 'SENT', 'DELIVERED', 'FAILED', 'BOUNCED');

CREATE TABLE device_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(500) NOT NULL,
    platform VARCHAR(20) NOT NULL, -- iOS, ANDROID, WEB
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_used_at TIMESTAMP WITH TIME ZONE,
    
    UNIQUE(token),
    INDEX idx_device_tokens_user (user_id),
    INDEX idx_device_tokens_active (is_active)
);

CREATE TABLE notification_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    notification_type notification_type NOT NULL,
    channel notification_channel NOT NULL,
    is_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id, notification_type, channel),
    INDEX idx_preferences_user (user_id)
);

CREATE TABLE notification_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type notification_type NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    data JSONB DEFAULT '{}',
    channel notification_channel NOT NULL,
    status notification_status DEFAULT 'PENDING',
    sent_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_notification_log_user (user_id),
    INDEX idx_notification_log_type (type),
    INDEX idx_notification_log_status (status)
);
```

#### Contracts:
```sql
CREATE TYPE contract_status AS ENUM (
    'DRAFT', 'PENDING_SIGNATURE', 'SIGNED', 'EXPIRED', 'CANCELLED'
);

CREATE TABLE contracts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    contract_number VARCHAR(50) UNIQUE NOT NULL,
    status contract_status DEFAULT 'DRAFT',
    terms_json JSONB NOT NULL, -- Structured contract terms
    pdf_url TEXT, -- URL to PDF document in cloud storage
    version INTEGER DEFAULT 1,
    client_signed_at TIMESTAMP WITH TIME ZONE,
    craftsman_signed_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_contracts_project (project_id),
    INDEX idx_contracts_number (contract_number),
    INDEX idx_contracts_status (status)
);
```

#### Analytics and Search:
```sql
CREATE TABLE analytics_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    session_id VARCHAR(100),
    event_type VARCHAR(50) NOT NULL,
    event_properties JSONB DEFAULT '{}',
    platform VARCHAR(20), -- 'ios', 'android', 'web'
    app_version VARCHAR(20),
    device_info JSONB,
    ip_address INET,
    location GEOGRAPHY(POINT, 4326),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_analytics_user (user_id),
    INDEX idx_analytics_event (event_type),
    INDEX idx_analytics_time (created_at DESC)
);

CREATE TABLE search_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    query TEXT NOT NULL,
    filters JSONB DEFAULT '{}',
    results_count INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_search_user (user_id),
    INDEX idx_search_time (created_at DESC)
);

CREATE TABLE saved_craftsmen (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    craftsman_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    saved_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id, craftsman_id),
    INDEX idx_saved_user (user_id),
    INDEX idx_saved_craftsman (craftsman_id)
);
```

## API Endpoints

### Authentication Endpoints:
```
POST   /auth/login                    // Login with Firebase JWT
GET    /auth/me                       // Get current user info
PUT    /auth/profile                  // Update user profile
POST   /auth/verify-email            // Email verification
```

### User Management Endpoints:
```
GET    /users/me                     // Get current user
PUT    /users/me                     // Update user profile
GET    /users/:id                    // Get user by ID
POST   /users/me/avatar             // Upload avatar
GET    /users/:id/public            // Get public profile
```

### Job Management Endpoints:
```
GET    /jobs                         // List jobs with filters
POST   /jobs                         // Create job
GET    /jobs/:id                     // Get job details
PUT    /jobs/:id                     // Update job
DELETE /jobs/:id                     // Delete job
GET    /jobs/search                  // Search jobs by location/specialty
```

### Craftsman Management Endpoints:
```
GET    /craftsmen                    // Search craftsmen
GET    /craftsmen/:id                // Get craftsman details
GET    /craftsmen/:id/reviews        // Get craftsman reviews
GET    /craftsmen/:id/portfolio      // Get craftsman portfolio
PUT    /craftsmen/me                 // Update craftsman profile
POST   /craftsmen/me/verify          // Submit verification
```

### Project Management Endpoints:
```
GET    /projects                     // List user projects
POST   /projects                     // Create project
GET    /projects/:id                 // Get project details
PUT    /projects/:id                 // Update project
GET    /projects/:id/milestones     // Get project milestones
POST   /projects/:id/milestones     // Create milestone
```

### Messaging Endpoints (WebSocket):
```
WS     /messages                     // Real-time messaging gateway
Events: 'joinProject', 'sendMessage', 'newMessage', 'typing', 'read'
```

### Payment Endpoints:
```
POST   /payments/process             // Process payment
GET    /payments/history            // Payment history
GET    /payments/:id                // Get payment details
POST   /payments/:id/refund         // Process refund
GET    /wallet/balance              // Get wallet balance
POST   /wallet/withdraw             // Request withdrawal
```

### Content Feed Endpoints:
```
GET    /inspiration                  // Get inspiration feed
POST   /inspiration                  // Create post
GET    /inspiration/:id              // Get post details
POST   /inspiration/:id/like        // Like post
POST   /inspiration/:id/comment     // Comment on post
```

### Media Upload Endpoints:
```
POST   /media/upload/image          // Upload image
POST   /media/upload/video          // Upload video
POST   /media/upload/batch          // Batch upload
DELETE /media/:id                   // Delete media
GET    /media/:userId/:category     // Get user media
```

### Contract Management Endpoints:
```
POST   /contracts/project/:projectId // Create contract for project
GET    /contracts/:id                // Get contract
POST   /contracts/:id/sign          // Sign contract
GET    /contracts/:id/download      // Download signed contract
```

### Notification Endpoints:
```
POST   /notifications/register-token // Register device token
POST   /notifications/remove-token  // Remove device token
GET    /notifications/history/:userId // Get notification history
GET    /notifications/preferences/:userId // Get notification preferences
PUT    /notifications/preferences/:userId // Update preferences
```

## Key Features

### 1. Dual-App Architecture
- **Client App**: For homeowners to post jobs, find craftsmen, manage projects
- **Craftsman App**: For craftsmen to manage profiles, bid on jobs, track projects
- Shared backend API serves both applications

### 2. Real-Time Communication
- **WebSocket-based messaging** using Socket.IO
- **Typing indicators** and read receipts
- **Conversation management** with history
- **Quote integration** within chat

### 3. Secure Payment System
- **Stripe integration** for payment processing
- **Escrow system** to protect both parties
- **Automatic fund release** upon project completion
- **Wallet system** for craftsmen earnings
- **Withdrawal functionality** with payout processing

### 4. Verification System
- **Identity verification** for both clients and craftsmen
- **Business verification** for craftsmen (CUI validation)
- **Professional certification** management
- **Review and rating system** with quality assurance

### 5. Content Feed
- **TikTok-style inspiration feed** with before/after showcases
- **Geographic-based content discovery**
- **Engagement metrics tracking**
- **Content categorization** by craft type

### 6. Job Matching
- **Advanced filtering** by location, specialty, rating
- **Geographic search** using Haversine formula
- **Job posting** with detailed specifications
- **Offer submission** system for craftsmen

### 7. Contract Management
- **Digital contract generation** with Romanian legal compliance
- **Multi-party signature collection**
- **Contract status tracking**
- **PDF generation** with templates

### 8. Media Management
- **Image and video upload** with processing
- **Automatic compression** and optimization
- **Thumbnail generation** for quick previews
- **Batch upload** capability
- **Category-based organization** (portfolio, profile, job, etc.)

### 9. Notification System
- **Push notifications** via Firebase Cloud Messaging
- **Email notifications** for important updates
- **User preference management**
- **Device token management**

### 10. Analytics and Insights
- **Search history tracking**
- **User engagement metrics**
- **Platform analytics**
- **Craftsman performance tracking**

## Deployment & Infrastructure

### Container Architecture:
```
┌─────────────────────────────────────────────────┐
│               DOCKER COMPOSE                    │
├─────────────────────────────────────────────────┤
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ │
│ │   PostgreSQL│ │   Backend   │ │   Nginx     │ │
│ │   Database  │ │   API       │ │   Frontend  │ │
│ │             │ │             │ │             │ │
│ └─────────────┘ └─────────────┘ └─────────────┘ │
│                                                 │
│ ┌─────────────┐                                 │
│ │    Redis    │                                 │
│ │   Cache     │                                 │
│ └─────────────┘                                 │
└─────────────────────────────────────────────────┘
```

### Docker Configuration:
- **Multi-stage builds** for optimized container size
- **Build stage**: Dependencies, Prisma generation, TypeScript compilation
- **Production stage**: Minimal Node.js runtime with compiled artifacts
- **Health checks** for all services
- **Persistent volumes** for database and Redis

### Environment Configuration:
```
// Backend environment variables
DATABASE_URL=postgresql://user:pass@postgres:5432/mesteri_db
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_SERVICE_ACCOUNT_KEY={...json...}
JWT_SECRET=your-secret-key
STRIPE_SECRET_KEY=your-stripe-key
GCS_BUCKET_NAME=your-storage-bucket
```

### Deployment Process:
1. **Docker Compose orchestration** for multi-container deployment
2. **Database migrations** run during deployment
3. **Static file serving** configured for Flutter web app
4. **Nginx reverse proxy** configuration for API routing
5. **SSL termination** with Let's Encrypt

### Production Infrastructure:
- **VPS/Cloud VM** deployment recommended
- **Nginx** as reverse proxy and static file server
- **Docker Compose** for service orchestration
- **Persistent volumes** for data storage
- **Health checks** and monitoring

## Security Implementation

### Authentication Security:
- **Firebase Authentication** for user management
- **JWT token validation** with Firebase Admin SDK
- **Token rotation** with refresh tokens
- **Session management** with secure storage

### API Security:
- **Rate limiting** per endpoint
- **CORS configuration** with specific origins
- **Input validation** using DTOs and class-validator
- **SQL injection prevention** via Prisma ORM

### Data Security:
- **Soft deletes** instead of permanent deletion
- **Data anonymization** for analytics
- **File validation** for uploads (type, size, content)
- **Path traversal prevention** for file uploads

### Network Security:
- **HTTPS enforcement** in production
- **Secure headers** via Helmet.js
- **Request compression** to prevent compression attacks
- **IP-based rate limiting**

### Payment Security:
- **PCI DSS compliance** through Stripe integration
- **No sensitive data storage** in application database
- **Escrow protection** for transaction security
- **Secure token management** for payment methods

## Development Methodologies

### Architecture Philosophy:
- **MVP-first approach**: Focused on delivering core functionality quickly
- **Iterative development**: Features developed in phases with continuous integration
- **Documentation-driven**: Comprehensive documentation for all systems
- **Test-driven**: Unit and integration tests for critical functionality

### Code Organization:
- **Feature-based modules**: Clear separation of concerns
- **Consistent naming**: Standardized naming conventions across codebase
- **Clean architecture**: Well-structured code with clear boundaries
- **Separation of concerns**: Business logic separate from presentation

### Quality Assurance:
- **Type safety**: TypeScript and Dart for compile-time error detection
- **Database migrations**: Prisma-based schema versioning
- **Environment management**: Different configurations for dev/test/prod
- **Error handling**: Comprehensive error handling throughout application

### Development Practices:
- **Git workflow**: Standard Git branching and merging practices
- **Code reviews**: Peer review process for quality assurance
- **Continuous integration**: Automated testing and deployment
- **Documentation**: Comprehensive documentation for all systems

### Internationalization:
- **Romanian focus**: Platform designed specifically for Romanian market
- **Cultural adaptation**: Features designed around Romanian business practices
- **Local compliance**: Legal and regulatory compliance for Romanian operations

## Implementation Status

### Completed Features (85-90%):
- ✅ User authentication and profile management
- ✅ Job posting and search functionality
- ✅ Real-time messaging system
- ✅ Payment processing with Stripe integration
- ✅ Wallet and withdrawal system
- ✅ Craftsman verification system
- ✅ Content feed with inspiration posts
- ✅ Project management and milestones
- ✅ Review and rating system
- ✅ Media upload with image/video processing
- ✅ Analytics and search history
- ✅ Notification system (backend completed)
- ✅ Contract management (data model completed)

### In Progress Features:
- 🔄 Flutter notification service implementation
- 🔄 Contract PDF generation and signing UI
- 🔄 Craftsman app job acceptance workflow
- 🔄 TikTok-style video feed enhancement

### Planned Features:
- ❌ Advanced search with Elasticsearch
- ❌ Klarna payment integration
- ❌ Video call functionality
- ❌ Advanced reporting and analytics
- ❌ Admin dashboard

### Critical Path for Production:
1. **Contract PDF generation** - Legal compliance requirement
2. **Digital signature system** - Required for payment protection
3. **Craftsman workflow completion** - Core business flow
4. **Security audit** - Production readiness
5. **Performance testing** - Scalability verification

The platform is well-positioned for deployment with most core functionality complete, requiring only the final implementation of contract signing and some advanced features for full production readiness.