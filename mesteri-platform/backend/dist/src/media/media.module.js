"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MediaModule = void 0;
const common_1 = require("@nestjs/common");
const platform_express_1 = require("@nestjs/platform-express");
const media_controller_1 = require("./media.controller");
const media_upload_service_1 = require("./media-upload.service");
const file_validation_middleware_1 = require("./middleware/file-validation.middleware");
const prisma_module_1 = require("../prisma/prisma.module");
let MediaModule = class MediaModule {
    configure(consumer) {
        consumer
            .apply(file_validation_middleware_1.FileValidationMiddleware)
            .forRoutes(media_controller_1.MediaController);
    }
};
exports.MediaModule = MediaModule;
exports.MediaModule = MediaModule = __decorate([
    (0, common_1.Module)({
        imports: [
            prisma_module_1.PrismaModule,
            platform_express_1.MulterModule.register({
                storage: 'memory',
                limits: {
                    fileSize: 104857600,
                },
            }),
        ],
        controllers: [media_controller_1.MediaController],
        providers: [media_upload_service_1.MediaUploadService, file_validation_middleware_1.FileValidationMiddleware],
        exports: [media_upload_service_1.MediaUploadService],
    })
], MediaModule);
//# sourceMappingURL=media.module.js.map