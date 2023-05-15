import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { ConfigModule } from '@nestjs/config';
import { InboxModule } from './inbox/inbox.module';

@Module({
  imports: [ConfigModule.forRoot(), InboxModule],
  controllers: [AppController],
  providers: [],
})
export class AppModule {}
