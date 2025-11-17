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
var FirebaseAuthGuard_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.FirebaseAuthGuard = void 0;
const common_1 = require("@nestjs/common");
const core_1 = require("@nestjs/core");
const firebase_service_1 = require("../firebase/firebase.service");
let FirebaseAuthGuard = FirebaseAuthGuard_1 = class FirebaseAuthGuard {
    firebaseService;
    reflector;
    logger = new common_1.Logger(FirebaseAuthGuard_1.name);
    constructor(firebaseService, reflector) {
        this.firebaseService = firebaseService;
        this.reflector = reflector;
    }
    async canActivate(context) {
        const isPublic = this.reflector.getAllAndOverride('isPublic', [
            context.getHandler(),
            context.getClass(),
        ]);
        if (isPublic) {
            return true;
        }
        const request = context.switchToHttp().getRequest();
        const token = this.extractTokenFromHeader(request);
        if (!token) {
            this.logger.warn('No token provided in request');
            throw new common_1.UnauthorizedException('No authentication token provided');
        }
        try {
            const decodedToken = await this.firebaseService.verifyIdToken(token);
            request.user = {
                uid: decodedToken.uid,
                email: decodedToken.email,
                role: decodedToken.role || 'client',
                roleCode: decodedToken.roleCode || 0,
                emailVerified: decodedToken.email_verified,
                customClaims: decodedToken,
            };
            const requiredRoles = this.reflector.getAllAndOverride('roles', [
                context.getHandler(),
                context.getClass(),
            ]);
            if (requiredRoles && !requiredRoles.includes(request.user.role)) {
                this.logger.warn(`User ${request.user.uid} with role ${request.user.role} attempted to access route requiring roles: ${requiredRoles.join(', ')}`);
                throw new common_1.UnauthorizedException('Insufficient permissions');
            }
            this.logger.debug(`Authentication successful for user: ${decodedToken.uid}`);
            return true;
        }
        catch (error) {
            this.logger.error('Authentication failed:', error.message);
            throw new common_1.UnauthorizedException('Invalid or expired token');
        }
    }
    extractTokenFromHeader(request) {
        const authHeader = request.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return null;
        }
        return authHeader.substring(7);
    }
};
exports.FirebaseAuthGuard = FirebaseAuthGuard;
exports.FirebaseAuthGuard = FirebaseAuthGuard = FirebaseAuthGuard_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [firebase_service_1.FirebaseService,
        core_1.Reflector])
], FirebaseAuthGuard);
//# sourceMappingURL=firebase-auth.guard.js.map