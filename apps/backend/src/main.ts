import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  app.setGlobalPrefix(process.env.API_PREFIX || 'api/v1');
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
  app.enableCors();

  const port = process.env.PORT || 3000;
  await app.listen(port);
  console.log(`Backend server running on: http://localhost:${port}/${process.env.API_PREFIX || 'api/v1'}`);
}
bootstrap();