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
exports.AppController = void 0;
const common_1 = require("@nestjs/common");
const auth_decorators_1 = require("./decorators/auth.decorators");
const firebase_service_1 = require("./firebase/firebase.service");
let AppController = class AppController {
    firebaseService;
    constructor(firebaseService) {
        this.firebaseService = firebaseService;
    }
    getHealth() {
        return {
            status: 'ok',
            timestamp: new Date().toISOString(),
            service: 'TrueWorkers Backend',
            version: '1.0.0',
            firebase: 'connected',
        };
    }
    getFirebaseStatus() {
        return {
            firebase: {
                status: 'initialized',
                projectId: process.env.FIREBASE_PROJECT_ID,
                environment: process.env.NODE_ENV,
                timestamp: new Date().toISOString(),
            },
        };
    }
};
exports.AppController = AppController;
__decorate([
    (0, auth_decorators_1.Public)(),
    (0, common_1.Get)('health'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], AppController.prototype, "getHealth", null);
__decorate([
    (0, auth_decorators_1.Public)(),
    (0, common_1.Get)('firebase-status'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], AppController.prototype, "getFirebaseStatus", null);
exports.AppController = AppController = __decorate([
    (0, common_1.Controller)(),
    __metadata("design:paramtypes", [firebase_service_1.FirebaseService])
], AppController);
//# sourceMappingURL=app.controller.js.map