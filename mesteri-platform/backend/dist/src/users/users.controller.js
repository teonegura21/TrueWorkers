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
exports.UsersController = void 0;
const common_1 = require("@nestjs/common");
const users_service_1 = require("./users.service");
const users_geo_service_1 = require("./users-geo.service");
const client_1 = require("@prisma/client");
const create_user_dto_1 = require("./dto/create-user.dto");
const update_user_dto_1 = require("./dto/update-user.dto");
const firebase_auth_guard_1 = require("../guards/firebase-auth.guard");
let UsersController = class UsersController {
    usersService;
    geoService;
    constructor(usersService, geoService) {
        this.usersService = usersService;
        this.geoService = geoService;
    }
    findAll() {
        return this.usersService.findAll();
    }
    findOne(id) {
        return this.usersService.findOne(id);
    }
    findByEmail(email) {
        return this.usersService.findByEmail(email);
    }
    findByRole(role) {
        return this.usersService.findByRole(role);
    }
    create(createUserDto) {
        return this.usersService.create(createUserDto);
    }
    update(id, updateUserDto) {
        return this.usersService.update(id, updateUserDto);
    }
    delete(id) {
        return this.usersService.delete(id);
    }
    search(query) {
        return this.usersService.search(query);
    }
    async getAllCraftsmen(specialty, isVerified, minRating, city, page, limit) {
        const filters = {
            isVerified: isVerified === 'true' ? true : undefined,
            minRating: minRating ? parseFloat(minRating) : undefined,
            city: city || undefined,
            page: page ? parseInt(page, 10) : 1,
            limit: limit ? parseInt(limit, 10) : 10,
        };
        return this.usersService.getCraftsmenWithSpecialty(specialty, filters);
    }
    async getCraftsmanProfile(id) {
        const craftsman = await this.usersService.findOne(id);
        if (craftsman.role !== client_1.UserRole.CRAFTSMAN) {
            throw new Error('User is not a craftsman');
        }
        return craftsman;
    }
    async getCraftsmanPortfolio(id) {
        const craftsman = await this.usersService.findOne(id);
        return {
            craftsmanId: id,
            fullName: craftsman.fullName,
            portfolioPhotos: craftsman.portfolioPhotos || [],
            skillsTags: craftsman.skillsTags || [],
        };
    }
    async searchCraftsmenNearby(lat, lng, radius, specialty, minRating, isVerified, page, limit) {
        const latitude = parseFloat(lat);
        const longitude = parseFloat(lng);
        if (isNaN(latitude) || isNaN(longitude)) {
            throw new Error('Invalid GPS coordinates');
        }
        return this.geoService.searchNearby({
            latitude,
            longitude,
            radiusKm: radius ? parseInt(radius, 10) : 50,
            specialty,
            minRating: minRating ? parseFloat(minRating) : undefined,
            isVerified: isVerified === 'true' ? true : undefined,
            page: page ? parseInt(page, 10) : 1,
            limit: limit ? parseInt(limit, 10) : 20,
        });
    }
    async updateUserLocation(id, locationData) {
        return this.geoService.updateLocation(id, locationData.latitude, locationData.longitude, locationData.city, locationData.county);
    }
    async getCraftsmenInBounds(neLat, neLng, swLat, swLng) {
        return this.geoService.getCraftsmenInBounds({ lat: parseFloat(neLat), lng: parseFloat(neLng) }, { lat: parseFloat(swLat), lng: parseFloat(swLng) });
    }
};
exports.UsersController = UsersController;
__decorate([
    (0, common_1.Get)(),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], UsersController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], UsersController.prototype, "findOne", null);
__decorate([
    (0, common_1.Get)('email/:email'),
    __param(0, (0, common_1.Param)('email')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], UsersController.prototype, "findByEmail", null);
__decorate([
    (0, common_1.Get)('role/:role'),
    __param(0, (0, common_1.Param)('role')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], UsersController.prototype, "findByRole", null);
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_user_dto_1.CreateUserDto]),
    __metadata("design:returntype", void 0)
], UsersController.prototype, "create", null);
__decorate([
    (0, common_1.Put)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_user_dto_1.UpdateUserDto]),
    __metadata("design:returntype", void 0)
], UsersController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], UsersController.prototype, "delete", null);
__decorate([
    (0, common_1.Get)('search'),
    __param(0, (0, common_1.Query)('q')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], UsersController.prototype, "search", null);
__decorate([
    (0, common_1.Get)('craftsmen'),
    __param(0, (0, common_1.Query)('specialty')),
    __param(1, (0, common_1.Query)('isVerified')),
    __param(2, (0, common_1.Query)('minRating')),
    __param(3, (0, common_1.Query)('city')),
    __param(4, (0, common_1.Query)('page')),
    __param(5, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String, String, String, String]),
    __metadata("design:returntype", Promise)
], UsersController.prototype, "getAllCraftsmen", null);
__decorate([
    (0, common_1.Get)('craftsmen/:id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], UsersController.prototype, "getCraftsmanProfile", null);
__decorate([
    (0, common_1.Get)('craftsmen/:id/portfolio'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], UsersController.prototype, "getCraftsmanPortfolio", null);
__decorate([
    (0, common_1.Get)('craftsmen/nearby'),
    __param(0, (0, common_1.Query)('lat')),
    __param(1, (0, common_1.Query)('lng')),
    __param(2, (0, common_1.Query)('radius')),
    __param(3, (0, common_1.Query)('specialty')),
    __param(4, (0, common_1.Query)('minRating')),
    __param(5, (0, common_1.Query)('isVerified')),
    __param(6, (0, common_1.Query)('page')),
    __param(7, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String, String, String, String, String, String]),
    __metadata("design:returntype", Promise)
], UsersController.prototype, "searchCraftsmenNearby", null);
__decorate([
    (0, common_1.Put)(':id/location'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], UsersController.prototype, "updateUserLocation", null);
__decorate([
    (0, common_1.Get)('craftsmen/map-bounds'),
    __param(0, (0, common_1.Query)('neLat')),
    __param(1, (0, common_1.Query)('neLng')),
    __param(2, (0, common_1.Query)('swLat')),
    __param(3, (0, common_1.Query)('swLng')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String, String]),
    __metadata("design:returntype", Promise)
], UsersController.prototype, "getCraftsmenInBounds", null);
exports.UsersController = UsersController = __decorate([
    (0, common_1.Controller)('users'),
    (0, common_1.UseGuards)(firebase_auth_guard_1.FirebaseAuthGuard),
    __metadata("design:paramtypes", [users_service_1.UsersService,
        users_geo_service_1.UsersGeoService])
], UsersController);
//# sourceMappingURL=users.controller.js.map