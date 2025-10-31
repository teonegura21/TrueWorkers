# Romanian Craftsman Marketplace - Complete App Architecture
## Version 1.0 - Development Blueprint

---

## 1. SYSTEM OVERVIEW & ARCHITECTURE PHILOSOPHY

### 1.1 Core Architecture Pattern: Microservices with Event-Driven Communication

```
Why Microservices?
-----------------
1. Independent scaling - Video service can scale separately from payments
2. Fault isolation - Payment failure won't crash the feed
3. Technology flexibility - Use best tool for each service
4. Team scalability - Different teams can work on different services
5. Easier maintenance - Smaller, focused codebases
```

### 1.2 High-Level System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENTS                                 │
├──────────────────────────┬──────────────────────────────────────┤
│   Craftsman iOS App      │      Client iOS App                  │
│   Craftsman Android App  │      Client Android App              │
└──────────────┬───────────┴───────────────┬──────────────────────┘
               │                           │
               ▼                           ▼
        ┌──────────────────────────────────────────┐
        │          API Gateway (Kong/Nginx)        │
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
    │              MICROSERVICES LAYER                 │
    ├───────────────────────────────────────────────────┤
    │  ┌─────────────┐  ┌─────────────┐  ┌──────────┐ │
    │  │Auth Service │  │User Service │  │Feed Svc  │ │
    │  └─────────────┘  └─────────────┘  └──────────┘ │
    │  ┌─────────────┐  ┌─────────────┐  ┌──────────┐ │
    │  │Contract Svc │  │Payment Svc  │  │Chat Svc  │ │
    │  └─────────────┘  └─────────────┘  └──────────┘ │
    │  ┌─────────────┐  ┌─────────────┐  ┌──────────┐ │
    │  │Media Svc    │  │Search Svc   │  │Notif Svc │ │
    │  └─────────────┘  └─────────────┘  └──────────┘ │
    └───────────────────────────────────────────────────┘
                           │
    ┌──────────────────────▼──────────────────────────┐
    │           Message Queue (RabbitMQ/Kafka)        │
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

---

## 2. DATABASE SCHEMA - PostgreSQL

### 2.1 Core Design Principles

```sql
-- Why PostgreSQL?
-- 1. ACID compliance for financial transactions
-- 2. JSON support for flexible data
-- 3. Full-text search capabilities
-- 4. Excellent geographic queries with PostGIS
-- 5. Row-level security for multi-tenancy
```

### 2.2 Complete Database Schema

```sql
-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For fuzzy text search

-- ============================================
-- USERS AND AUTHENTICATION
-- ============================================

CREATE TYPE user_type AS ENUM ('client', 'craftsman');
CREATE TYPE verification_status AS ENUM ('none', 'pending', 'verified', 'rejected');
CREATE TYPE craftsman_tier AS ENUM ('basic', 'verified', 'pro', 'master');

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    user_type user_type NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    phone_verified BOOLEAN DEFAULT false,
    
    -- Identity verification
    identity_verification_status verification_status DEFAULT 'none',
    identity_verified_at TIMESTAMP WITH TIME ZONE,
    identity_document_url TEXT, -- Encrypted S3 URL
    
    -- Soft delete
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Indexes for performance
    INDEX idx_users_email (email),
    INDEX idx_users_phone (phone_number),
    INDEX idx_users_type (user_type),
    INDEX idx_users_active (is_active) WHERE is_active = true
);

CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    display_name VARCHAR(200),
    avatar_url TEXT,
    bio TEXT,
    date_of_birth DATE,
    
    -- Location with PostGIS
    location GEOGRAPHY(POINT, 4326), -- Stores lat/lon
    city VARCHAR(100),
    county VARCHAR(100),
    address TEXT,
    postal_code VARCHAR(10),
    
    -- Preferences
    language VARCHAR(5) DEFAULT 'ro', -- ro, hu, en
    notification_preferences JSONB DEFAULT '{}',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id),
    INDEX idx_profiles_location USING GIST(location),
    INDEX idx_profiles_name (first_name, last_name)
);

-- ============================================
-- CRAFTSMAN SPECIFIC TABLES
-- ============================================

CREATE TABLE craftsman_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Business verification
    business_name VARCHAR(255),
    cui VARCHAR(20), -- Cod Unic de Înregistrare
    business_type VARCHAR(50), -- PFA, SRL, etc.
    business_verification_status verification_status DEFAULT 'none',
    business_verified_at TIMESTAMP WITH TIME ZONE,
    business_documents JSONB DEFAULT '[]', -- Array of document URLs
    
    -- Professional details
    years_of_experience INTEGER,
    certifications JSONB DEFAULT '[]',
    insurance_details JSONB,
    tier craftsman_tier DEFAULT 'basic',
    
    -- Availability
    is_available BOOLEAN DEFAULT true,
    availability_status VARCHAR(50), -- 'available', 'busy', 'vacation'
    available_radius_km INTEGER DEFAULT 50,
    
    -- Statistics (denormalized for performance)
    total_projects_completed INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    total_reviews INTEGER DEFAULT 0,
    response_time_minutes INTEGER, -- Average response time
    completion_rate DECIMAL(5,2) DEFAULT 0.00,
    
    -- Financial
    hourly_rate_min DECIMAL(10,2),
    hourly_rate_max DECIMAL(10,2),
    accepts_installments BOOLEAN DEFAULT false,
    
    -- Subscription
    subscription_plan VARCHAR(50),
    subscription_expires_at TIMESTAMP WITH TIME ZONE,
    featured_until TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id),
    INDEX idx_craftsman_tier (tier),
    INDEX idx_craftsman_available (is_available),
    INDEX idx_craftsman_rating (average_rating DESC)
);

CREATE TABLE craft_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name_ro VARCHAR(100) NOT NULL,
    name_hu VARCHAR(100),
    name_en VARCHAR(100),
    slug VARCHAR(100) UNIQUE NOT NULL,
    icon_url TEXT,
    parent_id UUID REFERENCES craft_categories(id),
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    
    INDEX idx_categories_slug (slug),
    INDEX idx_categories_parent (parent_id)
);

CREATE TABLE craftsman_crafts (
    craftsman_id UUID REFERENCES craftsman_profiles(id) ON DELETE CASCADE,
    category_id UUID REFERENCES craft_categories(id) ON DELETE CASCADE,
    is_primary BOOLEAN DEFAULT false,
    years_experience INTEGER,
    
    PRIMARY KEY (craftsman_id, category_id)
);

-- ============================================
-- CONTENT AND MEDIA
-- ============================================

CREATE TYPE media_type AS ENUM ('video', 'image', 'timelapse', 'before_after');
CREATE TYPE content_status AS ENUM ('draft', 'processing', 'published', 'hidden', 'removed');

CREATE TABLE content_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    craftsman_id UUID NOT NULL REFERENCES craftsman_profiles(id) ON DELETE CASCADE,
    
    title VARCHAR(255),
    description TEXT,
    media_type media_type NOT NULL,
    media_urls JSONB NOT NULL, -- Array of URLs
    thumbnail_url TEXT,
    
    -- For before/after posts
    before_media_url TEXT,
    after_media_url TEXT,
    
    -- Video specific
    duration_seconds INTEGER,
    video_quality VARCHAR(20),
    
    -- Engagement metrics (denormalized)
    views_count INTEGER DEFAULT 0,
    likes_count INTEGER DEFAULT 0,
    shares_count INTEGER DEFAULT 0,
    saves_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    
    -- Categorization
    category_id UUID REFERENCES craft_categories(id),
    tags TEXT[],
    
    -- Location
    location GEOGRAPHY(POINT, 4326),
    location_name VARCHAR(255),
    
    -- Project reference
    project_id UUID, -- References projects table
    
    status content_status DEFAULT 'published',
    published_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_posts_craftsman (craftsman_id),
    INDEX idx_posts_status (status),
    INDEX idx_posts_published (published_at DESC),
    INDEX idx_posts_category (category_id),
    INDEX idx_posts_location USING GIST(location),
    INDEX idx_posts_engagement (likes_count DESC, views_count DESC)
);

CREATE TABLE content_interactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES content_posts(id) ON DELETE CASCADE,
    interaction_type VARCHAR(20) NOT NULL, -- 'like', 'save', 'share', 'view'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(user_id, post_id, interaction_type),
    INDEX idx_interactions_post (post_id),
    INDEX idx_interactions_user (user_id)
);

-- ============================================
-- PROJECTS AND CONTRACTS
-- ============================================

CREATE TYPE project_status AS ENUM (
    'inquiry',
    'negotiation',
    'quote_sent',
    'contract_pending',
    'contract_signed',
    'in_progress',
    'completed',
    'cancelled',
    'disputed'
);

CREATE TYPE payment_status AS ENUM (
    'pending',
    'partial',
    'paid',
    'refunded',
    'failed'
);

CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES users(id),
    craftsman_id UUID NOT NULL REFERENCES craftsman_profiles(id),
    
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category_id UUID REFERENCES craft_categories(id),
    
    -- Location
    location GEOGRAPHY(POINT, 4326),
    address TEXT,
    
    -- Timeline
    estimated_start_date DATE,
    estimated_end_date DATE,
    actual_start_date DATE,
    actual_end_date DATE,
    
    -- Financial
    estimated_budget DECIMAL(12,2),
    final_cost DECIMAL(12,2),
    payment_status payment_status DEFAULT 'pending',
    uses_installments BOOLEAN DEFAULT false,
    
    -- Status
    status project_status DEFAULT 'inquiry',
    
    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_projects_client (client_id),
    INDEX idx_projects_craftsman (craftsman_id),
    INDEX idx_projects_status (status),
    INDEX idx_projects_created (created_at DESC)
);

CREATE TABLE contracts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    contract_number VARCHAR(50) UNIQUE NOT NULL,
    
    -- Contract details
    terms_json JSONB NOT NULL, -- Structured contract terms
    pdf_url TEXT, -- Generated PDF stored in cloud
    
    -- Signatures
    client_signature_url TEXT,
    client_signed_at TIMESTAMP WITH TIME ZONE,
    client_ip_address INET,
    
    craftsman_signature_url TEXT,
    craftsman_signed_at TIMESTAMP WITH TIME ZONE,
    craftsman_ip_address INET,
    
    -- Legal
    is_legally_binding BOOLEAN DEFAULT false,
    template_id UUID, -- References contract templates
    
    -- Modifications
    parent_contract_id UUID REFERENCES contracts(id), -- For amendments
    modification_reason TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE,
    
    INDEX idx_contracts_project (project_id),
    INDEX idx_contracts_number (contract_number)
);

CREATE TABLE project_milestones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    
    title VARCHAR(255) NOT NULL,
    description TEXT,
    due_date DATE,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Payment tied to milestone
    payment_amount DECIMAL(10,2),
    payment_percentage DECIMAL(5,2),
    is_paid BOOLEAN DEFAULT false,
    
    -- Verification
    requires_client_approval BOOLEAN DEFAULT true,
    client_approved_at TIMESTAMP WITH TIME ZONE,
    
    -- Documentation
    photos JSONB DEFAULT '[]',
    notes TEXT,
    
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_milestones_project (project_id),
    INDEX idx_milestones_due (due_date)
);

-- ============================================
-- PAYMENTS AND TRANSACTIONS
-- ============================================

CREATE TYPE transaction_type AS ENUM (
    'project_payment',
    'milestone_payment',
    'subscription',
    'featured_listing',
    'refund',
    'withdrawal'
);

CREATE TYPE transaction_status AS ENUM (
    'pending',
    'processing',
    'completed',
    'failed',
    'refunded',
    'disputed'
);

CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Parties
    from_user_id UUID REFERENCES users(id),
    to_user_id UUID REFERENCES users(id),
    project_id UUID REFERENCES projects(id),
    milestone_id UUID REFERENCES project_milestones(id),
    
    -- Transaction details
    type transaction_type NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'RON',
    status transaction_status DEFAULT 'pending',
    
    -- Payment method
    payment_method VARCHAR(50), -- 'card', 'bank_transfer', 'klarna'
    payment_provider VARCHAR(50), -- 'stripe', 'paypal', 'klarna'
    provider_transaction_id VARCHAR(255),
    
    -- Escrow
    is_escrowed BOOLEAN DEFAULT false,
    escrow_released_at TIMESTAMP WITH TIME ZONE,
    
    -- Fees
    platform_fee DECIMAL(10,2) DEFAULT 0.00,
    payment_provider_fee DECIMAL(10,2) DEFAULT 0.00,
    net_amount DECIMAL(12,2),
    
    -- VAT/Tax
    vat_amount DECIMAL(10,2) DEFAULT 0.00,
    vat_rate DECIMAL(5,2),
    invoice_number VARCHAR(50),
    invoice_url TEXT,
    
    -- Installments (for Klarna integration)
    is_installment BOOLEAN DEFAULT false,
    installment_plan_id VARCHAR(100),
    installment_number INTEGER,
    total_installments INTEGER,
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    INDEX idx_transactions_from_user (from_user_id),
    INDEX idx_transactions_to_user (to_user_id),
    INDEX idx_transactions_project (project_id),
    INDEX idx_transactions_status (status),
    INDEX idx_transactions_created (created_at DESC)
);

-- ============================================
-- MESSAGING AND COMMUNICATION
-- ============================================

CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id),
    
    -- Participants (always 2 in this system)
    client_id UUID NOT NULL REFERENCES users(id),
    craftsman_id UUID NOT NULL REFERENCES users(id),
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    archived_by_client BOOLEAN DEFAULT false,
    archived_by_craftsman BOOLEAN DEFAULT false,
    
    -- Last activity (denormalized for performance)
    last_message_at TIMESTAMP WITH TIME ZONE,
    last_message_preview TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(client_id, craftsman_id, project_id),
    INDEX idx_conversations_client (client_id),
    INDEX idx_conversations_craftsman (craftsman_id),
    INDEX idx_conversations_activity (last_message_at DESC)
);

CREATE TYPE message_type AS ENUM (
    'text',
    'image',
    'video',
    'document',
    'quote',
    'contract_proposal',
    'system'
);

CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id),
    
    type message_type DEFAULT 'text',
    content TEXT,
    media_urls JSONB DEFAULT '[]',
    
    -- For quotes
    quote_amount DECIMAL(10,2),
    quote_valid_until DATE,
    
    -- Read receipts
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP WITH TIME ZONE,
    
    -- Edit history
    is_edited BOOLEAN DEFAULT false,
    edited_at TIMESTAMP WITH TIME ZONE,
    
    -- Soft delete
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_messages_conversation (conversation_id),
    INDEX idx_messages_sender (sender_id),
    INDEX idx_messages_created (created_at DESC)
);

-- ============================================
-- REVIEWS AND RATINGS
-- ============================================

CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    reviewer_id UUID NOT NULL REFERENCES users(id),
    reviewed_user_id UUID NOT NULL REFERENCES users(id),
    
    -- Ratings (1-5 scale)
    overall_rating INTEGER NOT NULL CHECK (overall_rating >= 1 AND overall_rating <= 5),
    quality_rating INTEGER CHECK (quality_rating >= 1 AND quality_rating <= 5),
    punctuality_rating INTEGER CHECK (punctuality_rating >= 1 AND punctuality_rating <= 5),
    communication_rating INTEGER CHECK (communication_rating >= 1 AND communication_rating <= 5),
    price_value_rating INTEGER CHECK (price_value_rating >= 1 AND price_value_rating <= 5),
    
    -- Review content
    title VARCHAR(255),
    comment TEXT,
    
    -- Media proof
    photos JSONB DEFAULT '[]',
    videos JSONB DEFAULT '[]',
    
    -- Verification
    is_verified BOOLEAN DEFAULT false, -- Project was completed
    
    -- Response from craftsman
    response_text TEXT,
    response_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(project_id, reviewer_id),
    INDEX idx_reviews_project (project_id),
    INDEX idx_reviews_reviewed (reviewed_user_id),
    INDEX idx_reviews_rating (overall_rating DESC)
);

-- ============================================
-- SEARCH AND DISCOVERY
-- ============================================

CREATE TABLE search_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    query TEXT NOT NULL,
    filters JSONB DEFAULT '{}',
    results_count INTEGER,
    clicked_results JSONB DEFAULT '[]',
    searched_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_search_user (user_id),
    INDEX idx_search_time (searched_at DESC)
);

CREATE TABLE saved_craftsmen (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    craftsman_id UUID NOT NULL REFERENCES craftsman_profiles(id) ON DELETE CASCADE,
    saved_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (user_id, craftsman_id)
);

-- ============================================
-- NOTIFICATIONS
-- ============================================

CREATE TYPE notification_type AS ENUM (
    'new_message',
    'new_project_inquiry',
    'quote_received',
    'contract_ready',
    'payment_received',
    'review_posted',
    'milestone_completed',
    'project_update'
);

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    type notification_type NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    
    -- Related entities
    related_id UUID, -- Can reference any entity
    related_type VARCHAR(50), -- 'project', 'message', 'review', etc.
    
    -- Delivery
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP WITH TIME ZONE,
    
    -- Push notification
    push_sent BOOLEAN DEFAULT false,
    push_sent_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_notifications_user (user_id),
    INDEX idx_notifications_unread (user_id, is_read) WHERE is_read = false
);

-- ============================================
-- ANALYTICS AND REPORTING
-- ============================================

CREATE TABLE analytics_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    session_id VARCHAR(100),
    
    event_type VARCHAR(50) NOT NULL,
    event_properties JSONB DEFAULT '{}',
    
    -- Context
    platform VARCHAR(20), -- 'ios', 'android'
    app_version VARCHAR(20),
    device_info JSONB,
    ip_address INET,
    location GEOGRAPHY(POINT, 4326),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_analytics_user (user_id),
    INDEX idx_analytics_event (event_type),
    INDEX idx_analytics_time (created_at DESC)
);

-- ============================================
-- ADMIN AND SUPPORT
-- ============================================

CREATE TABLE support_tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    
    category VARCHAR(50),
    subject VARCHAR(255),
    description TEXT,
    
    status VARCHAR(20) DEFAULT 'open', -- 'open', 'in_progress', 'resolved', 'closed'
    priority VARCHAR(20) DEFAULT 'normal', -- 'low', 'normal', 'high', 'urgent'
    
    assigned_to UUID REFERENCES users(id),
    resolved_at TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tickets_user (user_id),
    INDEX idx_tickets_status (status),
    INDEX idx_tickets_priority (priority)
);
```

---

## 3. API ARCHITECTURE - RESTful & WebSocket

### 3.1 API Design Principles

```cpp
/*
 * API Design Philosophy:
 * 
 * 1. RESTful for CRUD operations
 * 2. WebSocket for real-time features (chat, notifications)
 * 3. GraphQL consideration for complex queries (future)
 * 4. Consistent error handling
 * 5. Version management (v1, v2)
 * 6. Rate limiting per endpoint
 * 7. Request/Response compression
 * 8. JWT-based authentication
 */
```

### 3.2 Authentication Flow

```javascript
// JWT Token Structure
{
  "header": {
    "alg": "RS256",
    "typ": "JWT"
  },
  "payload": {
    "sub": "user_uuid",
    "user_type": "craftsman|client",
    "iat": 1234567890,
    "exp": 1234567890,
    "refresh_token_id": "uuid",
    "permissions": ["read:profile", "write:projects"]
  }
}

// Token Rotation Strategy
// Access Token: 15 minutes
// Refresh Token: 30 days
// Refresh Token Rotation: Yes
```

### 3.3 Complete API Endpoints

```yaml
# Base URL: https://api.mesteriminbuzunar.ro/v1

# ============================================
# Authentication Service
# ============================================

POST   /auth/register
  body: {
    email, phone_number, password, user_type,
    first_name, last_name
  }
  response: { user, tokens }

POST   /auth/login
  body: { email_or_phone, password }
  response: { user, tokens }

POST   /auth/refresh
  body: { refresh_token }
  response: { tokens }

POST   /auth/logout
  headers: { Authorization: Bearer <token> }
  response: { success }

POST   /auth/verify-phone
  body: { phone_number, code }

POST   /auth/verify-email
  body: { email, code }

POST   /auth/forgot-password
  body: { email_or_phone }

POST   /auth/reset-password
  body: { token, new_password }

# ============================================
# User Service
# ============================================

GET    /users/me
  headers: { Authorization }
  response: { user, profile }

PUT    /users/me
  body: { profile_updates }

POST   /users/me/avatar
  body: { FormData with image }

DELETE /users/me
  body: { password_confirmation }

POST   /users/me/verify-identity
  body: { document_type, document_images[] }

GET    /users/{id}/public
  response: { public_profile }

# ============================================
# Craftsman Service
# ============================================

GET    /craftsmen
  query: {
    lat, lon, radius_km,
    category_id, min_rating,
    max_price, available_now,
    page, limit
  }

GET    /craftsmen/{id}
  response: { craftsman_profile }

PUT    /craftsmen/me
  body: { profile_updates }

POST   /craftsmen/me/verify-business
  body: { cui, business_documents[] }

POST   /craftsmen/me/certifications
  body: { certification_data }

PUT    /craftsmen/me/availability
  body: { status, radius_km }

GET    /craftsmen/{id}/reviews
  query: { page, limit, sort }

GET    /craftsmen/{id}/portfolio
  query: { page, limit }

POST   /craftsmen/me/subscription
  body: { plan_type, payment_method }

# ============================================
# Content/Feed Service
# ============================================

GET    /feed
  query: {
    lat, lon,
    categories[],
    following_only,
    page, cursor
  }
  response: { posts[], next_cursor }

GET    /posts/{id}
  response: { post, engagement_stats }

POST   /posts
  body: {
    title, description,
    media_files[],
    category_id, tags[]
  }

PUT    /posts/{id}
  body: { updates }

DELETE /posts/{id}

POST   /posts/{id}/like
POST   /posts/{id}/unlike
POST   /posts/{id}/save
POST   /posts/{id}/share

GET    /posts/{id}/comments
  query: { page, limit }

POST   /posts/{id}/comments
  body: { text }

# ============================================
# Project Service
# ============================================

GET    /projects
  headers: { Authorization }
  query: { status, page, limit }

GET    /projects/{id}
  response: { project, milestones }

POST   /projects
  body: {
    craftsman_id, title,
    description, category_id,
    location, estimated_budget
  }

PUT    /projects/{id}
  body: { updates }

PUT    /projects/{id}/status
  body: { status, reason }

GET    /projects/{id}/milestones

POST   /projects/{id}/milestones
  body: { milestone_data }

PUT    /projects/{id}/milestones/{mid}
  body: { updates }

POST   /projects/{id}/milestones/{mid}/complete
  body: { photos[], notes }

POST   /projects/{id}/milestones/{mid}/approve

# ============================================
# Contract Service
# ============================================

GET    /contracts/templates
  query: { category_id }

POST   /projects/{id}/contracts
  body: {
    template_id, terms,
    milestones[]
  }

GET    /contracts/{id}
  response: { contract, pdf_url }

POST   /contracts/{id}/sign
  body: { signature_data }

POST   /contracts/{id}/amend
  body: { amendments, reason }

# ============================================
# Payment Service
# ============================================

POST   /payments/calculate-fee
  body: { amount, payment_method }

POST   /projects/{id}/payments
  body: {
    amount, payment_method,
    milestone_id
  }

GET    /payments/{id}

POST   /payments/{id}/refund
  body: { reason, amount }

GET    /payments/history
  query: { page, limit, type }

POST   /payments/klarna/session
  body: { amount, installments }

POST   /payments/webhook/{provider}
  body: { provider_payload }

# ============================================
# Messaging Service (REST + WebSocket)
# ============================================

GET    /conversations
  query: { archived, page }

GET    /conversations/{id}

POST   /conversations
  body: { recipient_id, project_id }

GET    /conversations/{id}/messages
  query: { before, limit }

POST   /conversations/{id}/messages
  body: { type, content, media[] }

PUT    /messages/{id}
  body: { content }

DELETE /messages/{id}

POST   /messages/{id}/read

# WebSocket endpoint
WS     /ws/chat
  events: {
    'message:new',
    'message:read',
    'message:typing',
    'user:online',
    'user:offline'
  }

# ============================================
# Search Service
# ============================================

GET    /search
  query: {
    q, type,
    filters{},
    page, limit
  }

GET    /search/suggestions
  query: { q, limit }

POST   /search/save
  body: { query, filters }

GET    /search/history

DELETE /search/history

# ============================================
# Review Service
# ============================================

POST   /projects/{id}/reviews
  body: {
    ratings{},
    comment,
    photos[]
  }

PUT    /reviews/{id}

DELETE /reviews/{id}

POST   /reviews/{id}/response
  body: { response_text }

POST   /reviews/{id}/report
  body: { reason }

# ============================================
# Notification Service
# ============================================

GET    /notifications
  query: { unread_only, page }

PUT    /notifications/read
  body: { notification_ids[] }

PUT    /notifications/settings
  body: { preferences{} }

POST   /devices
  body: { token, platform }

DELETE /devices/{token}
```

---

## 4. MOBILE APP ARCHITECTURE

### 4.1 Technology Stack Decision

```cpp
/*
 * Why React Native?
 * 
 * 1. Single codebase for iOS & Android
 * 2. Hot reload for faster development
 * 3. Large ecosystem & community
 * 4. Native performance for most features
 * 5. Easy integration with native modules
 * 6. Cost-effective for MVP
 * 
 * Native Modules Required:
 * - Camera/Gallery (react-native-vision-camera)
 * - Video Processing (react-native-video-processing)
 * - Push Notifications (react-native-push-notification)
 * - Maps (react-native-maps)
 * - Payment SDKs (Stripe, Klarna)
 */
```

### 4.2 App Structure - Craftsman App

```javascript
/craftsman-app/
├── src/
│   ├── api/
│   │   ├── client.js         // Axios instance with interceptors
│   │   ├── auth.js          // Authentication endpoints
│   │   ├── projects.js      // Project management
│   │   ├── content.js       // Content upload/management
│   │   ├── chat.js          // Messaging endpoints
│   │   └── payments.js      // Payment processing
│   │
│   ├── components/
│   │   ├── common/
│   │   │   ├── Button.jsx
│   │   │   ├── Input.jsx
│   │   │   ├── Card.jsx
│   │   │   ├── Modal.jsx
│   │   │   └── LoadingSpinner.jsx
│   │   │
│   │   ├── auth/
│   │   │   ├── LoginForm.jsx
│   │   │   ├── RegisterForm.jsx
│   │   │   ├── VerificationStep.jsx
│   │   │   └── BusinessVerification.jsx
│   │   │
│   │   ├── content/
│   │   │   ├── VideoUploader.jsx
│   │   │   ├── BeforeAfterComparison.jsx
│   │   │   ├── ContentEditor.jsx
│   │   │   └── EngagementStats.jsx
│   │   │
│   │   ├── projects/
│   │   │   ├── ProjectCard.jsx
│   │   │   ├── MilestoneTracker.jsx
│   │   │   ├── ContractViewer.jsx
│   │   │   └── QuoteBuilder.jsx
│   │   │
│   │   └── chat/
│   │       ├── ConversationList.jsx
│   │       ├── MessageBubble.jsx
│   │       ├── MediaPicker.jsx
│   │       └── QuoteMessage.jsx
│   │
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── WelcomeScreen.jsx
│   │   │   ├── LoginScreen.jsx
│   │   │   ├── RegisterScreen.jsx
│   │   │   └── VerificationScreen.jsx
│   │   │
│   │   ├── main/
│   │   │   ├── DashboardScreen.jsx    // Main hub with stats
│   │   │   ├── ProjectsScreen.jsx     // Active projects list
│   │   │   ├── ContentScreen.jsx      // Create/manage content
│   │   │   ├── MessagesScreen.jsx     // Chat interface
│   │   │   └── ProfileScreen.jsx      // Settings & profile
│   │   │
│   │   ├── projects/
│   │   │   ├── ProjectDetailScreen.jsx
│   │   │   ├── MilestoneScreen.jsx
│   │   │   ├── ContractScreen.jsx
│   │   │   └── PaymentScreen.jsx
│   │   │
│   │   └── content/
│   │       ├── CreatePostScreen.jsx
│   │       ├── EditPostScreen.jsx
│   │       └── AnalyticsScreen.jsx
│   │
│   ├── navigation/
│   │   ├── AppNavigator.jsx
│   │   ├── AuthNavigator.jsx
│   │   ├── MainTabNavigator.jsx
│   │   └── ProjectStackNavigator.jsx
│   │
│   ├── store/              // Redux Toolkit
│   │   ├── store.js
│   │   ├── slices/
│   │   │   ├── authSlice.js
│   │   │   ├── projectsSlice.js
│   │   │   ├── contentSlice.js
│   │   │   ├── chatSlice.js
│   │   │   └── notificationSlice.js
│   │   └── middleware/
│   │       └── socketMiddleware.js
│   │
│   ├── services/
│   │   ├── WebSocketService.js
│   │   ├── NotificationService.js
│   │   ├── MediaService.js
│   │   ├── LocationService.js
│   │   └── AnalyticsService.js
│   │
│   ├── utils/
│   │   ├── constants.js
│   │   ├── validators.js
│   │   ├── formatters.js
│   │   ├── permissions.js
│   │   └── encryption.js
│   │
│   └── hooks/
│       ├── useAuth.js
│       ├── useWebSocket.js
│       ├── useLocation.js
│       ├── useNotifications.js
│       └── usePagination.js
```

### 4.3 App Structure - Client App

```javascript
/client-app/
├── src/
│   ├── screens/
│   │   ├── main/
│   │   │   ├── FeedScreen.jsx        // TikTok-style feed
│   │   │   ├── SearchScreen.jsx      // Find craftsmen
│   │   │   ├── MessagesScreen.jsx    // Conversations
│   │   │   ├── ProjectsScreen.jsx    // My projects
│   │   │   └── ProfileScreen.jsx     // Settings
│   │   │
│   │   ├── discovery/
│   │   │   ├── CraftsmanProfileScreen.jsx
│   │   │   ├── PortfolioScreen.jsx
│   │   │   ├── ReviewsScreen.jsx
│   │   │   └── BookingScreen.jsx
│   │   │
│   │   └── projects/
│   │       ├── CreateProjectScreen.jsx
│   │       ├── ProjectTrackingScreen.jsx
│   │       ├── ContractSignScreen.jsx
│   │       └── PaymentScreen.jsx
│   │
│   └── [similar structure for other folders]
```

---

## 5. BACKEND SERVICES IMPLEMENTATION

### 5.1 Core Service Architecture (Node.js/Express)

```javascript
// Base Service Template
class BaseService {
    constructor() {
        this.app = express();
        this.setupMiddleware();
        this.setupRoutes();
        this.setupErrorHandling();
        this.connectDatabase();
        this.initializeServices();
    }
    
    setupMiddleware() {
        // CORS configuration
        this.app.use(cors({
            origin: process.env.ALLOWED_ORIGINS.split(','),
            credentials: true
        }));
        
        // Body parsing
        this.app.use(express.json({ limit: '50mb' }));
        this.app.use(express.urlencoded({ extended: true }));
        
        // Compression
        this.app.use(compression());
        
        // Security
        this.app.use(helmet());
        this.app.use(rateLimit({
            windowMs: 15 * 60 * 1000, // 15 minutes
            max: 100 // limit each IP to 100 requests per windowMs
        }));
        
        // Request logging
        this.app.use(morgan('combined'));
        
        // Request ID for tracing
        this.app.use((req, res, next) => {
            req.id = uuidv4();
            res.setHeader('X-Request-Id', req.id);
            next();
        });
    }
    
    setupErrorHandling() {
        // 404 handler
        this.app.use((req, res) => {
            res.status(404).json({
                error: 'Not Found',
                message: 'The requested resource does not exist',
                path: req.path
            });
        });
        
        // Global error handler
        this.app.use((err, req, res, next) => {
            console.error(`Error ${req.id}:`, err);
            
            const status = err.status || 500;
            const message = err.message || 'Internal Server Error';
            
            res.status(status).json({
                error: true,
                message: message,
                ...(process.env.NODE_ENV === 'development' && {
                    stack: err.stack
                })
            });
        });
    }
}
```

### 5.2 Authentication Service

```javascript
// services/auth-service/src/AuthService.js
class AuthService extends BaseService {
    async register(userData) {
        // Begin transaction
        const trx = await db.transaction();
        
        try {
            // Validate input
            await this.validateRegistration(userData);
            
            // Check duplicates
            const existing = await trx('users')
                .where('email', userData.email)
                .orWhere('phone_number', userData.phone_number)
                .first();
                
            if (existing) {
                throw new ConflictError('User already exists');
            }
            
            // Hash password
            const salt = await bcrypt.genSalt(12);
            const password_hash = await bcrypt.hash(userData.password, salt);
            
            // Create user
            const [user] = await trx('users').insert({
                email: userData.email,
                phone_number: userData.phone_number,
                password_hash,
                user_type: userData.user_type
            }).returning('*');
            
            // Create profile
            const [profile] = await trx('user_profiles').insert({
                user_id: user.id,
                first_name: userData.first_name,
                last_name: userData.last_name,
                language: userData.language || 'ro'
            }).returning('*');
            
            // Create craftsman profile if needed
            if (userData.user_type === 'craftsman') {
                await trx('craftsman_profiles').insert({
                    user_id: user.id,
                    available_radius_km: 50
                });
            }
            
            // Send verification emails/SMS
            await this.sendVerificationEmail(user.email);
            await this.sendVerificationSMS(user.phone_number);
            
            // Generate tokens
            const tokens = this.generateTokens(user.id, user.user_type);
            
            // Store refresh token
            await trx('refresh_tokens').insert({
                user_id: user.id,
                token: tokens.refresh_token,
                expires_at: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
            });
            
            await trx.commit();
            
            // Log analytics event
            await this.analytics.track({
                userId: user.id,
                event: 'User Registered',
                properties: {
                    user_type: userData.user_type,
                    platform: userData.platform
                }
            });
            
            return {
                user: this.sanitizeUser(user),
                profile,
                tokens
            };
            
        } catch (error) {
            await trx.rollback();
            throw error;
        }
    }
    
    generateTokens(userId, userType) {
        const accessToken = jwt.sign(
            {
                sub: userId,
                user_type: userType,
                type: 'access'
            },
            process.env.JWT_SECRET,
            {
                expiresIn: '15m',
                algorithm: 'RS256'
            }
        );
        
        const refreshToken = jwt.sign(
            {
                sub: userId,
                type: 'refresh'
            },
            process.env.JWT_REFRESH_SECRET,
            {
                expiresIn: '30d',
                algorithm: 'RS256'
            }
        );
        
        return { accessToken, refreshToken };
    }
}
```

### 5.3 Feed Algorithm Service

```javascript
// services/feed-service/src/FeedAlgorithm.js
class FeedAlgorithm {
    async generateFeed(userId, options = {}) {
        const {
            lat,
            lon,
            page = 1,
            limit = 20,
            categories = []
        } = options;
        
        // Get user preferences
        const userPrefs = await this.getUserPreferences(userId);
        
        // Build base query
        let query = db('content_posts as cp')
            .join('craftsman_profiles as cr', 'cp.craftsman_id', 'cr.id')
            .join('users as u', 'cr.user_id', 'u.id')
            .where('cp.status', 'published')
            .where('u.is_active', true);
        
        // Apply geographic filtering (highest priority)
        if (lat && lon) {
            query = query.whereRaw(`
                ST_DWithin(
                    cp.location::geography,
                    ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography,
                    ? * 1000
                )
            `, [lon, lat, userPrefs.search_radius_km || 50]);
        }
        
        // Apply category filtering
        if (categories.length > 0) {
            query = query.whereIn('cp.category_id', categories);
        }
        
        // Calculate relevance score
        query = query.select(
            'cp.*',
            db.raw(`
                (
                    -- Geographic proximity (40% weight)
                    CASE 
                        WHEN cp.location IS NOT NULL AND ? IS NOT NULL
                        THEN (1 - LEAST(
                            ST_Distance(
                                cp.location::geography,
                                ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography
                            ) / 50000, 1
                        )) * 0.4
                        ELSE 0
                    END +
                    
                    -- Engagement score (30% weight)
                    (
                        (cp.likes_count * 0.5 + 
                         cp.views_count * 0.1 + 
                         cp.saves_count * 0.3 +
                         cp.shares_count * 0.1) / 
                        GREATEST(
                            (cp.likes_count + cp.views_count + 
                             cp.saves_count + cp.shares_count), 
                            1
                        )
                    ) * 0.3 +
                    
                    -- Craftsman rating (20% weight)
                    (cr.average_rating / 5.0) * 0.2 +
                    
                    -- Recency (10% weight)
                    (1 - LEAST(
                        EXTRACT(EPOCH FROM (NOW() - cp.published_at)) / 604800, 
                        1
                    )) * 0.1
                    
                ) AS relevance_score
            `, [lat, lon, lat])
        );
        
        // Order by relevance
        query = query.orderBy('relevance_score', 'desc');
        
        // Apply pagination
        const offset = (page - 1) * limit;
        query = query.limit(limit).offset(offset);
        
        // Execute query
        const posts = await query;
        
        // Track impressions
        await this.trackImpressions(userId, posts.map(p => p.id));
        
        // Enrich with user interaction data
        const enrichedPosts = await this.enrichPostsWithUserData(userId, posts);
        
        return {
            posts: enrichedPosts,
            page,
            has_more: posts.length === limit
        };
    }
    
    async trackImpressions(userId, postIds) {
        const impressions = postIds.map(postId => ({
            user_id: userId,
            post_id: postId,
            interaction_type: 'view',
            created_at: new Date()
        }));
        
        await db('content_interactions')
            .insert(impressions)
            .onConflict(['user_id', 'post_id', 'interaction_type'])
            .ignore();
    }
}
```

### 5.4 Contract Generation Service

```javascript
// services/contract-service/src/ContractGenerator.js
class ContractGenerator {
    async generateContract(projectData, templateId) {
        // Load template
        const template = await this.loadTemplate(templateId);
        
        // Get all necessary data
        const [project, client, craftsman] = await Promise.all([
            this.getProjectDetails(projectData.project_id),
            this.getUserDetails(projectData.client_id),
            this.getCraftsmanDetails(projectData.craftsman_id)
        ]);
        
        // Generate contract terms
        const contractTerms = {
            contract_number: this.generateContractNumber(),
            date: new Date().toISOString(),
            
            parties: {
                client: {
                    name: `${client.first_name} ${client.last_name}`,
                    id_number: client.identity_document_number,
                    address: client.address,
                    phone: client.phone_number,
                    email: client.email
                },
                craftsman: {
                    name: craftsman.business_name || 
                          `${craftsman.first_name} ${craftsman.last_name}`,
                    cui: craftsman.cui,
                    business_type: craftsman.business_type,
                    address: craftsman.business_address,
                    phone: craftsman.phone_number,
                    email: craftsman.email
                }
            },
            
            project: {
                title: project.title,
                description: project.description,
                location: project.address,
                start_date: project.estimated_start_date,
                end_date: project.estimated_end_date,
                total_cost: project.estimated_budget,
                payment_terms: this.generatePaymentTerms(project),
                milestones: project.milestones
            },
            
            terms_and_conditions: template.terms,
            
            legal: {
                governing_law: 'Romanian Law',
                dispute_resolution: 'Romanian Courts',
                contract_validity: '1 year from signing'
            }
        };
        
        // Generate PDF
        const pdfBuffer = await this.generatePDF(contractTerms, template);
        
        // Upload to cloud storage
        const pdfUrl = await this.uploadToCloud(pdfBuffer, contractTerms.contract_number);
        
        // Save to database
        const contract = await db('contracts').insert({
            project_id: projectData.project_id,
            contract_number: contractTerms.contract_number,
            terms_json: contractTerms,
            pdf_url: pdfUrl,
            template_id: templateId,
            expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7 days
        }).returning('*');
        
        return contract[0];
    }
    
    async generatePDF(contractTerms, template) {
        // Using puppeteer for PDF generation
        const browser = await puppeteer.launch({
            headless: true,
            args: ['--no-sandbox']
        });
        
        const page = await browser.newPage();
        
        // Generate HTML from template
        const html = await this.renderTemplate(template.html, contractTerms);
        
        await page.setContent(html, {
            waitUntil: 'networkidle0'
        });
        
        // Generate PDF
        const pdfBuffer = await page.pdf({
            format: 'A4',
            printBackground: true,
            margin: {
                top: '20mm',
                bottom: '20mm',
                left: '15mm',
                right: '15mm'
            }
        });
        
        await browser.close();
        
        return pdfBuffer;
    }
    
    generateContractNumber() {
        const date = new Date();
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const random = Math.random().toString(36).substr(2, 6).toUpperCase();
        return `CTR-${year}${month}-${random}`;
    }
}
```

### 5.5 Payment Processing Service

```javascript
// services/payment-service/src/PaymentProcessor.js
class PaymentProcessor {
    constructor() {
        this.stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
        this.klarna = new KlarnaAPI({
            username: process.env.KLARNA_USERNAME,
            password: process.env.KLARNA_PASSWORD
        });
    }
    
    async processPayment(paymentData) {
        const {
            project_id,
            amount,
            payment_method,
            milestone_id,
            use_installments
        } = paymentData;
        
        // Validate payment
        await this.validatePayment(paymentData);
        
        // Calculate fees
        const fees = this.calculateFees(amount, payment_method);
        
        // Start transaction
        const trx = await db.transaction();
        
        try {
            // Create transaction record
            const [transaction] = await trx('transactions').insert({
                project_id,
                milestone_id,
                from_user_id: paymentData.client_id,
                to_user_id: paymentData.craftsman_id,
                type: 'project_payment',
                amount: amount,
                platform_fee: fees.platform,
                payment_provider_fee: fees.provider,
                net_amount: amount - fees.platform - fees.provider,
                payment_method,
                status: 'pending',
                is_escrowed: true,
                is_installment: use_installments
            }).returning('*');
            
            let paymentResult;
            
            if (use_installments && payment_method === 'klarna') {
                paymentResult = await this.processKlarnaInstallments(
                    transaction, 
                    paymentData
                );
            } else {
                paymentResult = await this.processStripePayment(
                    transaction, 
                    paymentData
                );
            }
            
            // Update transaction with provider details
            await trx('transactions')
                .where('id', transaction.id)
                .update({
                    provider_transaction_id: paymentResult.id,
                    status: 'processing',
                    metadata: paymentResult
                });
            
            // Update project payment status
            await trx('projects')
                .where('id', project_id)
                .update({
                    payment_status: milestone_id ? 'partial' : 'processing'
                });
            
            await trx.commit();
            
            // Send notifications
            await this.sendPaymentNotifications(transaction);
            
            return transaction;
            
        } catch (error) {
            await trx.rollback();
            throw new PaymentError('Payment processing failed', error);
        }
    }
    
    async processStripePayment(transaction, paymentData) {
        // Create Stripe payment intent
        const paymentIntent = await this.stripe.paymentIntents.create({
            amount: Math.round(transaction.amount * 100), // Convert to cents
            currency: 'ron',
            customer: paymentData.stripe_customer_id,
            payment_method: paymentData.stripe_payment_method_id,
            confirm: true,
            capture_method: 'manual', // Hold funds in escrow
            metadata: {
                transaction_id: transaction.id,
                project_id: transaction.project_id
            }
        });
        
        return paymentIntent;
    }
    
    async releaseEscrowFunds(transactionId) {
        const transaction = await db('transactions')
            .where('id', transactionId)
            .where('is_escrowed', true)
            .where('status', 'processing')
            .first();
            
        if (!transaction) {
            throw new Error('Transaction not found or not in escrow');
        }
        
        // Capture Stripe payment
        await this.stripe.paymentIntents.capture(
            transaction.provider_transaction_id
        );
        
        // Update transaction
        await db('transactions')
            .where('id', transactionId)
            .update({
                status: 'completed',
                is_escrowed: false,
                escrow_released_at: new Date(),
                completed_at: new Date()
            });
        
        // Transfer to craftsman's account (minus fees)
        await this.transferToCraftsman(transaction);
        
        return true;
    }
    
    calculateFees(amount, payment_method) {
        const platformFeePercentage = 0.05; // 5%
        let providerFeePercentage = 0;
        
        switch(payment_method) {
            case 'card':
                providerFeePercentage = 0.029; // 2.9% Stripe
                break;
            case 'bank_transfer':
                providerFeePercentage = 0.005; // 0.5%
                break;
            case 'klarna':
                providerFeePercentage = 0.039; // 3.9% Klarna
                break;
        }
        
        return {
            platform: amount * platformFeePercentage,
            provider: amount * providerFeePercentage
        };
    }
}
```

---

## 6. REAL-TIME FEATURES (WebSocket)

### 6.1 WebSocket Server Implementation

```javascript
// services/websocket-service/src/WebSocketServer.js
const WebSocket = require('ws');
const jwt = require('jsonwebtoken');
const Redis = require('ioredis');

class WebSocketServer {
    constructor(server) {
        this.wss = new WebSocket.Server({ server });
        this.redis = new Redis(process.env.REDIS_URL);
        this.pubClient = new Redis(process.env.REDIS_URL);
        this.subClient = new Redis(process.env.REDIS_URL);
        
        this.connections = new Map(); // userId -> WebSocket
        
        this.initialize();
    }
    
    initialize() {
        // Handle new connections
        this.wss.on('connection', async (ws, req) => {
            const token = this.extractToken(req);
            
            try {
                const user = await this.authenticateUser(token);
                
                // Store connection
                this.connections.set(user.id, ws);
                
                // Set user online status
                await this.setUserOnline(user.id);
                
                // Subscribe to user's channels
                await this.subscribeToUserChannels(user.id);
                
                // Setup message handlers
                this.setupMessageHandlers(ws, user);
                
                // Send connection success
                ws.send(JSON.stringify({
                    type: 'connection',
                    status: 'connected',
                    userId: user.id
                }));
                
                // Handle disconnect
                ws.on('close', async () => {
                    this.connections.delete(user.id);
                    await this.setUserOffline(user.id);
                });
                
            } catch (error) {
                ws.send(JSON.stringify({
                    type: 'error',
                    message: 'Authentication failed'
                }));
                ws.close();
            }
        });
        
        // Subscribe to Redis pub/sub
        this.subClient.on('message', (channel, message) => {
            this.handleRedisMessage(channel, message);
        });
    }
    
    setupMessageHandlers(ws, user) {
        ws.on('message', async (data) => {
            try {
                const message = JSON.parse(data);
                
                switch(message.type) {
                    case 'chat:message':
                        await this.handleChatMessage(user, message);
                        break;
                        
                    case 'chat:typing':
                        await this.handleTypingIndicator(user, message);
                        break;
                        
                    case 'chat:read':
                        await this.handleMessageRead(user, message);
                        break;
                        
                    case 'presence:update':
                        await this.handlePresenceUpdate(user, message);
                        break;
                        
                    case 'subscribe:feed':
                        await this.handleFeedSubscription(user, message);
                        break;
                        
                    default:
                        ws.send(JSON.stringify({
                            type: 'error',
                            message: 'Unknown message type'
                        }));
                }
                
            } catch (error) {
                console.error('Message handling error:', error);
                ws.send(JSON.stringify({
                    type: 'error',
                    message: 'Message processing failed'
                }));
            }
        });
    }
    
    async handleChatMessage(sender, message) {
        const { conversationId, content, mediaUrls } = message.data;
        
        // Save message to database
        const savedMessage = await db('messages').insert({
            conversation_id: conversationId,
            sender_id: sender.id,
            content,
            media_urls: mediaUrls || [],
            type: message.messageType || 'text'
        }).returning('*');
        
        // Get conversation participants
        const conversation = await db('conversations')
            .where('id', conversationId)
            .first();
            
        const recipientId = conversation.client_id === sender.id 
            ? conversation.craftsman_id 
            : conversation.client_id;
        
        // Send to recipient if online
        const recipientWs = this.connections.get(recipientId);
        if (recipientWs && recipientWs.readyState === WebSocket.OPEN) {
            recipientWs.send(JSON.stringify({
                type: 'chat:message',
                data: {
                    message: savedMessage[0],
                    conversation: conversation
                }
            }));
        }
        
        // Send push notification if offline
        if (!recipientWs) {
            await this.sendPushNotification(recipientId, {
                title: `New message from ${sender.name}`,
                body: content,
                data: { conversationId }
            });
        }
        
        // Update conversation last message
        await db('conversations')
            .where('id', conversationId)
            .update({
                last_message_at: new Date(),
                last_message_preview: content.substring(0, 100)
            });
        
        // Confirm to sender
        const senderWs = this.connections.get(sender.id);
        if (senderWs) {
            senderWs.send(JSON.stringify({
                type: 'chat:message:sent',
                data: { messageId: savedMessage[0].id }
            }));
        }
    }
    
    async handleTypingIndicator(user, message) {
        const { conversationId, isTyping } = message.data;
        
        // Get recipient
        const conversation = await db('conversations')
            .where('id', conversationId)
            .first();
            
        const recipientId = conversation.client_id === user.id 
            ? conversation.craftsman_id 
            : conversation.client_id;
        
        // Send typing indicator
        const recipientWs = this.connections.get(recipientId);
        if (recipientWs && recipientWs.readyState === WebSocket.OPEN) {
            recipientWs.send(JSON.stringify({
                type: 'chat:typing',
                data: {
                    conversationId,
                    userId: user.id,
                    isTyping
                }
            }));
        }
    }
    
    async broadcastToProject(projectId, message) {
        // Get project participants
        const project = await db('projects')
            .where('id', projectId)
            .first();
            
        const participants = [project.client_id, project.craftsman_id];
        
        // Broadcast to all participants
        participants.forEach(userId => {
            const ws = this.connections.get(userId);
            if (ws && ws.readyState === WebSocket.OPEN) {
                ws.send(JSON.stringify(message));
            }
        });
    }
}

module.exports = WebSocketServer;
```

---

## 7. SECURITY IMPLEMENTATION

### 7.1 Security Architecture

```javascript
// Security Middleware Stack

// 1. Rate Limiting per endpoint
const rateLimiters = {
    auth: rateLimit({
        windowMs: 15 * 60 * 1000,
        max: 5,
        message: 'Too many authentication attempts'
    }),
    
    api: rateLimit({
        windowMs: 15 * 60 * 1000,
        max: 100
    }),
    
    upload: rateLimit({
        windowMs: 60 * 60 * 1000,
        max: 30
    })
};

// 2. Input Validation
const validateInput = (schema) => {
    return (req, res, next) => {
        const { error } = schema.validate(req.body);
        if (error) {
            return res.status(400).json({
                error: 'Validation failed',
                details: error.details
            });
        }
        next();
    };
};

// 3. SQL Injection Prevention
// Using parameterized queries everywhere
const safeQuery = async (query, params) => {
    // Never use string concatenation for queries
    return await db.raw(query, params);
};

// 4. XSS Protection
const sanitizeUserContent = (content) => {
    return DOMPurify.sanitize(content, {
        ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a'],
        ALLOWED_ATTR: ['href']
    });
};

// 5. File Upload Security
const uploadSecurityMiddleware = multer({
    storage: multer.memoryStorage(),
    limits: {
        fileSize: 50 * 1024 * 1024, // 50MB
        files: 10
    },
    fileFilter: (req, file, cb) => {
        // Check file type
        const allowedTypes = /jpeg|jpg|png|gif|mp4|mov|pdf/;
        const extname = allowedTypes.test(
            path.extname(file.originalname).toLowerCase()
        );
        const mimetype = allowedTypes.test(file.mimetype);
        
        if (mimetype && extname) {
            return cb(null, true);
        } else {
            cb(new Error('Invalid file type'));
        }
    }
});

// 6. Encryption for sensitive data
class EncryptionService {
    constructor() {
        this.algorithm = 'aes-256-gcm';
        this.key = Buffer.from(process.env.ENCRYPTION_KEY, 'hex');
    }
    
    encrypt(text) {
        const iv = crypto.randomBytes(16);
        const cipher = crypto.createCipheriv(this.algorithm, this.key, iv);
        
        let encrypted = cipher.update(text, 'utf8', 'hex');
        encrypted += cipher.final('hex');
        
        const authTag = cipher.getAuthTag();
        
        return {
            encrypted,
            iv: iv.toString('hex'),
            authTag: authTag.toString('hex')
        };
    }
    
    decrypt(encryptedData) {
        const decipher = crypto.createDecipheriv(
            this.algorithm,
            this.key,
            Buffer.from(encryptedData.iv, 'hex')
        );
        
        decipher.setAuthTag(Buffer.from(encryptedData.authTag, 'hex'));
        
        let decrypted = decipher.update(encryptedData.encrypted, 'hex', 'utf8');
        decrypted += decipher.final('utf8');
        
        return decrypted;
    }
}

// 7. RBAC (Role-Based Access Control)
const authorize = (roles) => {
    return async (req, res, next) => {
        const user = req.user;
        
        if (!user) {
            return res.status(401).json({ error: 'Unauthorized' });
        }
        
        if (!roles.includes(user.user_type)) {
            return res.status(403).json({ error: 'Forbidden' });
        }
        
        next();
    };
};
```

---

## 8. DEPLOYMENT & INFRASTRUCTURE

### 8.1 Docker Configuration

```dockerfile
# Base image for Node.js services
FROM node:18-alpine AS base

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy application
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

USER nodejs

EXPOSE 3000

CMD ["node", "server.js"]
```

### 8.2 Kubernetes Deployment

```yaml
# kubernetes/craftsman-api-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: craftsman-api
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: craftsman-api
  template:
    metadata:
      labels:
        app: craftsman-api
    spec:
      containers:
      - name: api
        image: gcr.io/project-id/craftsman-api:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: craftsman-api-service
spec:
  selector:
    app: craftsman-api
  ports:
  - port: 80
    targetPort: 3000
  type: LoadBalancer
```

### 8.3 CI/CD Pipeline (GitHub Actions)

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
        with:
          node-version: '18'
      - run: npm ci
      - run: npm test
      - run: npm run lint

  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Set up Cloud SDK
        uses: google-github-actions/setup-gcloud@v0
        with:
          service_account_key: ${{ secrets.GCP_SA_KEY }}
          project_id: ${{ secrets.GCP_PROJECT_ID }}
      
      - name: Build and push Docker image
        run: |
          docker build -t gcr.io/${{ secrets.GCP_PROJECT_ID }}/craftsman-api:$GITHUB_SHA .
          docker push gcr.io/${{ secrets.GCP_PROJECT_ID }}/craftsman-api:$GITHUB_SHA
      
      - name: Deploy to GKE
        run: |
          gcloud container clusters get-credentials production-cluster --zone europe-west1-b
          kubectl set image deployment/craftsman-api craftsman-api=gcr.io/${{ secrets.GCP_PROJECT_ID }}/craftsman-api:$GITHUB_SHA
          kubectl rollout status deployment/craftsman-api
```

---

## 9. MONITORING & ANALYTICS

### 9.1 Application Monitoring

```javascript
// monitoring/metrics.js
const prometheus = require('prom-client');

// Create metrics
const httpRequestDuration = new prometheus.Histogram({
    name: 'http_request_duration_seconds',
    help: 'Duration of HTTP requests in seconds',
    labelNames: ['method', 'route', 'status']
});

const activeUsers = new prometheus.Gauge({
    name: 'active_users_total',
    help: 'Number of active users',
    labelNames: ['user_type']
});

const paymentTransactions = new prometheus.Counter({
    name: 'payment_transactions_total',
    help: 'Total number of payment transactions',
    labelNames: ['status', 'method']
});

// Middleware to track metrics
const metricsMiddleware = (req, res, next) => {
    const start = Date.now();
    
    res.on('finish', () => {
        const duration = (Date.now() - start) / 1000;
        httpRequestDuration
            .labels(req.method, req.route?.path || 'unknown', res.statusCode)
            .observe(duration);
    });
    
    next();
};

// Error tracking with Sentry
const Sentry = require('@sentry/node');

Sentry.init({
    dsn: process.env.SENTRY_DSN,
    environment: process.env.NODE_ENV,
    integrations: [
        new Sentry.Integrations.Http({ tracing: true }),
        new Sentry.Integrations.Express({ app })
    ],
    tracesSampleRate: 0.1
});
```

---

## 10. DEVELOPMENT TIMELINE

### Phase 1: MVP (3 months)
- **Month 1**: Backend core services, Database, Authentication
- **Month 2**: Mobile apps basic features, Content feed
- **Month 3**: Messaging, Basic contracts, Testing

### Phase 2: Core Features (2 months)
- **Month 4**: Payment integration, Advanced search
- **Month 5**: Video processing, Contract generation

### Phase 3: Polish & Launch (1 month)
- **Month 6**: Bug fixes, Performance optimization, Launch preparation

---

## CONCLUSION

This architecture provides:

1. **Scalability**: Microservices architecture allows independent scaling
2. **Reliability**: Multiple failover mechanisms and error handling
3. **Security**: Multiple layers of security measures
4. **Performance**: Optimized queries, caching, CDN usage
5. **Maintainability**: Clean code structure, comprehensive documentation
6. **User Experience**: Real-time features, smooth interactions

The system is designed to handle Romania's craftsman trust crisis by providing transparency, security, and quality assurance at every step.
