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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AnalyticsController = void 0;
const common_1 = require("@nestjs/common");
const analytics_service_1 = require("./analytics.service");
const firebase_auth_guard_1 = require("../guards/firebase-auth.guard");
let AnalyticsController = class AnalyticsController {
    analyticsService;
    constructor(analyticsService) {
        this.analyticsService = analyticsService;
    }
    trackEvent(data) {
        return this.analyticsService.trackEvent(data);
    }
    getUserEvents(userId, limit) {
        return this.analyticsService.getUserEvents(userId, limit ? parseInt(limit) : 100);
    }
    getEventsByType(type, limit) {
        return this.analyticsService.getEventsByType(type, limit ? parseInt(limit) : 100);
    }
    getEventsInRange(start, end) {
        return this.analyticsService.getEventsInRange(new Date(start), new Date(end));
    }
    getEventStats(userId) {
        return this.analyticsService.getEventStats(userId);
    }
    recordSearch(data) {
        return this.analyticsService.recordSearch(data);
    }
    getUserSearchHistory(userId, limit) {
        return this.analyticsService.getUserSearchHistory(userId, limit ? parseInt(limit) : 50);
    }
    getPopularSearches(limit) {
        return this.analyticsService.getPopularSearches(limit ? parseInt(limit) : 10);
    }
    getSearchSuggestions(userId, query, limit) {
        return this.analyticsService.getSearchSuggestions(userId, query, limit ? parseInt(limit) : 5);
    }
    clearSearchHistory(userId) {
        return this.analyticsService.clearSearchHistory(userId);
    }
    recordSearchClick(searchId, resultId) {
        return this.analyticsService.recordSearchClick(searchId, resultId);
    }
    saveCraftsman(data) {
        return this.analyticsService.saveCraftsman(data);
    }
    unsaveCraftsman(userId, craftsmanId) {
        return this.analyticsService.unsaveCraftsman(userId, craftsmanId);
    }
    getSavedCraftsmen(userId) {
        return this.analyticsService.getSavedCraftsmen(userId);
    }
    isCraftsmanSaved(userId, craftsmanId) {
        return this.analyticsService.isCraftsmanSaved(userId, craftsmanId);
    }
    updateSavedCraftsman(userId, craftsmanId, data) {
        return this.analyticsService.updateSavedCraftsman(userId, craftsmanId, data);
    }
    getCraftsmenSaveStats(craftsmanId) {
        return this.analyticsService.getCraftsmenSaveStats(craftsmanId);
    }
    getUserEngagement(userId) {
        return this.analyticsService.getUserEngagement(userId);
    }
    getPlatformAnalytics() {
        return this.analyticsService.getPlatformAnalytics();
    }
};
exports.AnalyticsController = AnalyticsController;
__decorate([
    (0, common_1.Post)('events'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], AnalyticsController.prototype, "trackEvent", null);
__decorate([
    (0, common_1.Get)('events/user/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __param(1, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], AnalyticsController.prototype, "getUserEvents", null);
__decorate([
    (0, common_1.Get)('events/type/:type'),
    __param(0, (0, common_1.Param)('type')),
    __param(1, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], AnalyticsController.prototype, "getEventsByType", null);
__decorate([
    (0, common_1.Get)('events/range'),
    __param(0, (0, common_1.Query)('start')),
    __param(1, (0, common_1.Query)('end')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], AnalyticsController.prototype, "getEventsInRange", null);
__decorate([
    (0, common_1.Get)('events/stats'),
    __param(0, (0, common_1.Query)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], AnalyticsController.prototype, "getEventStats", null);
__decorate([
    (0, common_1.Post)('search'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], AnalyticsController.prototype, "recordSearch", null);
__decorate([
    (0, common_1.Get)('search/user/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __param(1, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], AnalyticsController.prototype, "getUserSearchHistory", null);
__decorate([
    (0, common_1.Get)('search/popular'),
    __param(0, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], AnalyticsController.prototype, "getPopularSearches", null);
__decorate([
    (0, common_1.Get)('search/suggestions/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __param(1, (0, common_1.Query)('q')),
    __param(2, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String]),
    __metadata("design:returntype", void 0)
], AnalyticsController.prototype, "getSearchSuggestions", null);
__decorate([
    (0, common_1.Delete)('search/user/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], AnalyticsController.prototype, "clearSearchHistory", null);
__decorate([
    (0, common_1.Post)('search/:searchId/click/:resultId'),
    __param(0, (0, common_1.Param)('searchId')),
    __param(1, (0, common_1.Param)('resultId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], AnalyticsController.prototype, "recordSearchClick", null);
__decorate([
    (0, common_1.Post)('saved-craftsmen'),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], AnalyticsController.prototype, "saveCraftsman", null);
__decorate([
    (0, common_1.Delete)('saved-craftsmen/:userId/:craftsmanId'),
    __param(0, (0, common_1.Param)('userId')),
    __param(1, (0, common_1.Param)('craftsmanId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], AnalyticsController.prototype, "unsaveCraftsman", null);
__decorate([
    (0, common_1.Get)('saved-craftsmen/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], AnalyticsController.prototype, "getSavedCraftsmen", null);
__decorate([
    (0, common_1.Get)('saved-craftsmen/:userId/:craftsmanId/check'),
    __param(0, (0, common_1.Param)('userId')),
    __param(1, (0, common_1.Param)('craftsmanId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String]),
    __metadata("design:returntype", void 0)
], AnalyticsController.prototype, "isCraftsmanSaved", null);
__decorate([
    (0, common_1.Put)('saved-craftsmen/:userId/:craftsmanId'),
    __param(0, (0, common_1.Param)('userId')),
    __param(1, (0, common_1.Param)('craftsmanId')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, Object]),
    __metadata("design:returntype", void 0)
], AnalyticsController.prototype, "updateSavedCraftsman", null);
__decorate([
    (0, common_1.Get)('saved-craftsmen/stats/:craftsmanId'),
    __param(0, (0, common_1.Param)('craftsmanId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], AnalyticsController.prototype, "getCraftsmenSaveStats", null);
__decorate([
    (0, common_1.Get)('engagement/:userId'),
    __param(0, (0, common_1.Param)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], AnalyticsController.prototype, "getUserEngagement", null);
__decorate([
    (0, common_1.Get)('platform'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], AnalyticsController.prototype, "getPlatformAnalytics", null);
exports.AnalyticsController = AnalyticsController = __decorate([
    (0, common_1.Controller)('analytics'),
    (0, common_1.UseGuards)(firebase_auth_guard_1.FirebaseAuthGuard),
    __metadata("design:paramtypes", [analytics_service_1.AnalyticsService])
], AnalyticsController);
//# sourceMappingURL=analytics.controller.js.map