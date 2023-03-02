import {
  Controller,
  Get,
  Post,
  Render,
  Param,
  Res,
  Body,
} from '@nestjs/common';
import { InboxService } from './inbox.service';

@Controller('inbox')
export class InboxController {
  constructor(private readonly inboxService: InboxService) {}

  @Get(':user')
  @Render('inbox')
  async getInbox(@Param('user') user: string): Promise<object> {
    return await this.inboxService.getUserInboxFromS3(user);
  }

  @Get(':user/message/:id')
  @Render('webmail')
  async getMessage(
    @Param('user') user: string,
    @Param('id') id: string,
  ): Promise<object> {
    return await this.inboxService.getUserMessageFromS3(user, id);
  }

  @Get(':user/message/:id/unsafe')
  async getMessageUnsafe(
    @Param('user') user: string,
    @Param('id') id: string,
  ): Promise<string> {
    const raw = await this.inboxService.getUserMessageFromS3(user, id);

    return await this.inboxService.getMailDisplay(raw['source']);
  }

  @Post()
  redirectToInbox(@Res() res: any, @Body('user') user: string) {
    res.redirect(`/inbox/${user}`);
  }
}
