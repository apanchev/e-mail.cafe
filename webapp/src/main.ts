import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';
import { HttpExceptionFilter } from './app.filter';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule, {
    logger:
      process.env.NODE_ENV === 'production'
        ? ['error', 'warn']
        : ['error', 'warn', 'log', 'debug'],
  });

  app.useGlobalFilters(new HttpExceptionFilter());
  app.useStaticAssets(join(__dirname, '..', 'public'));
  app.setBaseViewsDir(join(__dirname, '..', 'views'));
  app.setViewEngine('ejs');
  await app.listen(process.env.PORT);
  console.info(`Running server with port: ${process.env.PORT}`);
}
bootstrap();
