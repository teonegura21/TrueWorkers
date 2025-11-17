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
var FirebaseService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.FirebaseService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const admin = __importStar(require("firebase-admin"));
let FirebaseService = FirebaseService_1 = class FirebaseService {
    configService;
    logger = new common_1.Logger(FirebaseService_1.name);
    auth;
    firestore;
    constructor(configService) {
        this.configService = configService;
        const serviceAccountKey = this.configService.get('FIREBASE_SERVICE_ACCOUNT_KEY');
        const projectId = this.configService.get('FIREBASE_PROJECT_ID');
        if (!serviceAccountKey || !projectId) {
            throw new Error('Firebase configuration missing. Check FIREBASE_SERVICE_ACCOUNT_KEY and FIREBASE_PROJECT_ID');
        }
        try {
            const serviceAccount = JSON.parse(serviceAccountKey);
            admin.initializeApp({
                credential: admin.credential.cert(serviceAccount),
                projectId: projectId,
            });
            this.auth = admin.auth();
            this.firestore = admin.firestore();
            this.logger.log(`Firebase Admin SDK initialized for project: ${projectId}`);
        }
        catch (error) {
            this.logger.error('Failed to initialize Firebase Admin SDK:', error);
            throw error;
        }
    }
    async verifyIdToken(idToken) {
        try {
            const decodedToken = await this.auth.verifyIdToken(idToken);
            this.logger.debug(`Token verified for user: ${decodedToken.uid}`);
            return decodedToken;
        }
        catch (error) {
            this.logger.error('Token verification failed:', error);
            throw new common_1.UnauthorizedException('Invalid or expired token');
        }
    }
    async setCustomClaims(uid, role, additionalClaims = {}) {
        try {
            const claims = {
                role,
                roleCode: role === 'client' ? 0 : 1,
                ...additionalClaims,
            };
            await this.auth.setCustomUserClaims(uid, claims);
            this.logger.log(`Custom claims set for user ${uid}: ${JSON.stringify(claims)}`);
        }
        catch (error) {
            this.logger.error(`Failed to set custom claims for user ${uid}:`, error);
            throw error;
        }
    }
    async getUserByUid(uid) {
        try {
            const userRecord = await this.auth.getUser(uid);
            return userRecord;
        }
        catch (error) {
            this.logger.error(`Failed to get user ${uid}:`, error);
            throw error;
        }
    }
    async getUserByEmail(email) {
        try {
            const userRecord = await this.auth.getUserByEmail(email);
            return userRecord;
        }
        catch (error) {
            this.logger.error(`Failed to get user by email ${email}:`, error);
            throw error;
        }
    }
    async createDocument(collection, docId, data) {
        try {
            const cleanedData = this.filterUndefinedValues(data);
            await this.firestore.collection(collection).doc(docId).set(cleanedData);
            this.logger.debug(`Document created: ${collection}/${docId}`);
        }
        catch (error) {
            this.logger.error(`Failed to create document ${collection}/${docId}:`, error);
            throw error;
        }
    }
    async getDocument(collection, docId) {
        try {
            const doc = await this.firestore.collection(collection).doc(docId).get();
            return doc.exists ? doc.data() : null;
        }
        catch (error) {
            this.logger.error(`Failed to get document ${collection}/${docId}:`, error);
            throw error;
        }
    }
    async updateDocument(collection, docId, data) {
        try {
            await this.firestore.collection(collection).doc(docId).update(data);
            this.logger.debug(`Document updated: ${collection}/${docId}`);
        }
        catch (error) {
            this.logger.error(`Failed to update document ${collection}/${docId}:`, error);
            throw error;
        }
    }
    async deleteUser(uid) {
        try {
            await this.auth.deleteUser(uid);
            this.logger.log(`User deleted: ${uid}`);
        }
        catch (error) {
            this.logger.error(`Failed to delete user ${uid}:`, error);
            throw error;
        }
    }
    filterUndefinedValues(obj) {
        const filtered = {};
        for (const [key, value] of Object.entries(obj)) {
            if (value !== undefined) {
                filtered[key] = value;
            }
        }
        return filtered;
    }
    async createUserProfile(uid, profileData) {
        try {
            const userData = {
                ...profileData,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            };
            const cleanedUserData = this.filterUndefinedValues(userData);
            await this.createDocument('users', uid, cleanedUserData);
            this.logger.log(`User profile created for: ${uid}`);
        }
        catch (error) {
            this.logger.error(`Failed to create user profile for ${uid}:`, error);
            throw error;
        }
    }
};
exports.FirebaseService = FirebaseService;
exports.FirebaseService = FirebaseService = FirebaseService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService])
], FirebaseService);
//# sourceMappingURL=firebase.service.js.map