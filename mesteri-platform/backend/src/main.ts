import { NestFactory } from '@nestjs/core';
import { ConfigService } from '@nestjs/config';
import { AppModule } from './app.module';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);
  const configService = app.get(ConfigService);

  // Enable CORS for WebSocket connections
  app.enableCors({
    origin: configService.get('FRONTEND_URL') || [
      'http://localhost:3000',
      'http://localhost:3001',
    ],
    credentials: true,
  });

  app.setGlobalPrefix('api');

  // Configure static file serving for uploads
  const uploadPath = configService.get('UPLOAD_PATH') || './storage/uploads';
  app.useStaticAssets(join(process.cwd(), uploadPath), {
    prefix: '/uploads/',
    maxAge: '1y',
    etag: true,
    lastModified: true,
  });

  const port = configService.get<number>('PORT') || 3000;
  await app.listen(port, '0.0.0.0'); // Listen on all interfaces for better WebSocket support

  console.log(`Application is running on: ${await app.getUrl()}`);
  console.log(
    `WebSocket server is running on: ws://localhost:${port}/messages`,
  );
}
bootstrap();
