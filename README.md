# Mesteri Platform

> Romanian marketplace connecting homeowners with verified craftsmen through a trust-based system and TikTok-style inspiration feed.

![Status](https://img.shields.io/badge/status-ready%20for%20deployment-green)
![Flutter](https://img.shields.io/badge/Flutter-3.9+-blue)
![NestJS](https://img.shields.io/badge/NestJS-11.0-red)
![Firebase](https://img.shields.io/badge/Firebase-Auth-orange)

## 🚀 Quick Start

### Prerequisites
- Docker Desktop
- Node.js 20+
- Flutter 3.9+

### Development Mode (Local)

**Windows:**
```powershell
.\start-dev.ps1
```

**Linux/Mac:**
```bash
chmod +x start-dev.sh
./start-dev.sh
```

This will:
- Install all dependencies
- Start PostgreSQL database
- Run migrations and seed data
- Start backend server on port 3000
- Launch Flutter app

### Production Deployment

**Windows:**
```powershell
# 1. Configure environment
cp .env.production.example .env.production
# Edit .env.production with your values

# 2. Deploy
.\deploy.ps1
```

**Linux/Mac:**
```bash
# 1. Configure environment
cp .env.production.example .env.production
# Edit .env.production with your values

# 2. Deploy
chmod +x deploy.sh
./deploy.sh
```

## 📚 Documentation

- **[Implementation Summary](./IMPLEMENTATION_SUMMARY.md)** - What was built and how to use it
- **[Deployment Guide](./DEPLOYMENT_GUIDE.md)** - Complete deployment instructions
- **[Final Checklist](./FINAL_CHECKLIST.md)** - Pre-launch tasks and priorities

## ✨ Key Features

### ✅ Implemented
- **Authentication with Auto-Login** - Firebase Auth with persistent sessions
- **Real-Time Messaging** - WebSocket-based chat with typing indicators
- **Craftsman Search** - Advanced filtering by location, specialty, rating
- **Inspiration Feed** - TikTok-style content showcase
- **Complete API Layer** - RESTful APIs with authentication
- **Deployment Ready** - Docker configuration for production

### ⏳ Remaining
- UI/UX polish (loading states, animations)
- Remove mock data from UI components
- End-to-end testing
- Security hardening

## 🏗️ Architecture

```
┌─────────────────┐
│  Flutter App    │  ← Web/Mobile Client
│  (Nginx)        │
└────────┬────────┘
         │ REST + WebSocket
┌────────▼────────┐
│  NestJS Backend │  ← API Server
│  (Node.js)      │
└────────┬────────┘
         │
         ├─────────────┐
         │             │
┌────────▼────┐   ┌───▼──────┐
│ PostgreSQL  │   │ Firebase │
│  Database   │   │   Auth   │
└─────────────┘   └──────────┘
```

## 📦 Project Structure

```
AplicatieMesteri/
├── mesteri-platform/
│   ├── app_client/          # Flutter web/mobile app
│   │   ├── lib/
│   │   │   ├── src/
│   │   │   │   ├── core/    # Core services & config
│   │   │   │   ├── features/ # Feature modules
│   │   │   │   └── navigation/
│   │   │   └── main.dart
│   │   ├── Dockerfile
│   │   └── nginx.conf
│   │
│   ├── backend/             # NestJS API server
│   │   ├── src/
│   │   │   ├── auth/
│   │   │   ├── users/
│   │   │   ├── messages/
│   │   │   ├── inspiration/
│   │   │   └── ...
│   │   ├── prisma/
│   │   ├── Dockerfile
│   │   └── package.json
│   │
│   └── docs/                # Documentation
│
├── docker-compose.prod.yml  # Production stack
├── .env.production.example  # Environment template
├── deploy.sh / deploy.ps1   # Deployment scripts
├── start-dev.sh / start-dev.ps1  # Dev scripts
├── DEPLOYMENT_GUIDE.md
├── IMPLEMENTATION_SUMMARY.md
├── FINAL_CHECKLIST.md
└── README.md (this file)
```

## 🔧 Tech Stack

### Frontend
- **Flutter** - Cross-platform UI framework
- **Provider** - State management
- **Firebase Auth** - Authentication
- **Socket.IO Client** - Real-time messaging
- **Dio** - HTTP client

### Backend
- **NestJS** - Node.js framework
- **Prisma** - Database ORM
- **PostgreSQL** - Primary database
- **Socket.IO** - WebSocket server
- **Firebase Admin** - Auth verification

### Infrastructure
- **Docker** - Containerization
- **Nginx** - Web server & reverse proxy
- **Redis** - Caching (optional)

## 🌐 Service URLs

### Development
- Frontend: http://localhost (or Flutter debug URL)
- Backend API: http://localhost:3000
- Database: localhost:5432

### Production
- Frontend: https://yourdomain.com
- Backend API: https://api.yourdomain.com
- WebSocket: wss://api.yourdomain.com/messages

## 🔐 Environment Variables

Key variables to configure in `.env.production`:

```bash
# Database
DATABASE_URL=postgresql://user:pass@host:5432/db

# Firebase
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_SERVICE_ACCOUNT_KEY={...json...}

# URLs
FRONTEND_URL=https://yourdomain.com
API_BASE_URL=https://api.yourdomain.com

# Security
JWT_SECRET=<generate-random-secret>
SESSION_SECRET=<generate-random-secret>
```

## 📝 Usage Examples

### Authentication
```dart
final authProvider = Provider.of<AuthProvider>(context);

// Sign in
await authProvider.signIn(
  email: 'user@example.com',
  password: 'password',
  rememberMe: true,
);

// User is automatically logged in on next app start
```

### Real-Time Messaging
```dart
// Connect and join project
await webSocketService.connect();
await webSocketService.joinProject(projectId);

// Listen for messages
webSocketService.addEventListener('new-message', (data) {
  print('New message: ${data['message']['content']}');
});

// Send message
webSocketService.sendMessage(
  projectId: projectId,
  receiverId: craftsmanId,
  content: 'Hello!',
);
```

### Search Craftsmen
```dart
final service = CraftsmenApiService();

final results = await service.searchCraftsmen(
  specialties: ['INSTALATII_SANITARE'],
  city: 'București',
  minRating: 4.0,
  isVerified: true,
);

final craftsmen = results['craftsmen'];
```

## 🧪 Testing

### Run Tests
```bash
# Backend tests
cd mesteri-platform/backend
npm test

# Flutter tests
cd mesteri-platform/app_client
flutter test
```

### E2E Testing
See `FINAL_CHECKLIST.md` for testing scenarios.

## 🚀 Deployment Checklist

- [ ] Configure `.env.production` with real values
- [ ] Set up Firebase project
- [ ] Configure domain and SSL
- [ ] Test locally with production config
- [ ] Deploy to server
- [ ] Run database migrations
- [ ] Verify all services
- [ ] Monitor logs

## 📊 Monitoring

### View Logs
```bash
# All services
docker-compose -f docker-compose.prod.yml logs -f

# Specific service
docker-compose -f docker-compose.prod.yml logs -f backend
```

### Health Checks
```bash
# Backend health
curl http://localhost:3000/api/health

# Frontend health
curl http://localhost/health
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

Copyright © 2024 Mesteri Platform

## 👥 Team

- **Teodor Negura** - Product Owner & Developer

## 🆘 Support

For issues and questions:
1. Check documentation in `/docs`
2. Review `DEPLOYMENT_GUIDE.md`
3. Check existing issues
4. Create new issue with details

## 🎯 Roadmap

### Phase 1 (Current) - MVP ✅
- [x] Authentication system
- [x] Real-time messaging
- [x] Craftsman search
- [x] Inspiration feed
- [x] Deployment setup

### Phase 2 - Polish & Launch
- [ ] UI/UX improvements
- [ ] Remove mock data
- [ ] Testing & QA
- [ ] Production deployment
- [ ] User onboarding

### Phase 3 - Growth
- [ ] Payment integration
- [ ] Advanced matching algorithm
- [ ] Mobile apps (iOS/Android)
- [ ] Marketing features
- [ ] Analytics dashboard

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- NestJS team for the solid backend framework
- Firebase for authentication services
- All open-source contributors

---

**Made with ❤️ in Romania** 🇷🇴

**Status**: Ready for deployment! 🚀

For detailed implementation info, see [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md)
