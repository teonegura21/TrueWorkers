"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const config_1 = require("@nestjs/config");
const app_module_1 = require("./app.module");
const path_1 = require("path");
async function bootstrap() {
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    const configService = app.get(config_1.ConfigService);
    app.enableCors({
        origin: configService.get('FRONTEND_URL') || [
            'http://localhost:3000',
            'http://localhost:3001',
        ],
        credentials: true,
    });
    app.setGlobalPrefix('api');
    const uploadPath = configService.get('UPLOAD_PATH') || './storage/uploads';
    app.useStaticAssets((0, path_1.join)(process.cwd(), uploadPath), {
        prefix: '/uploads/',
        maxAge: '1y',
        etag: true,
        lastModified: true,
    });
    const port = configService.get('PORT') || 3000;
    await app.listen(port, '0.0.0.0');
    console.log(`Application is running on: ${await app.getUrl()}`);
    console.log(`WebSocket server is running on: ws://localhost:${port}/messages`);
}
bootstrap();
//# sourceMappingURL=main.js.map