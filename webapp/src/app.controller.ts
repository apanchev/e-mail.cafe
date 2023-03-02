import { Controller, Get, Render } from '@nestjs/common';

@Controller()
export class AppController {
  @Get()
  @Render('home')
  root() {
    return '';
  }

  @Get('cgu')
  @Render('cgu')
  getCgu() {
    return '';
  }

  @Get('about')
  @Render('about')
  getAbout() {
    return '';
  }
}
