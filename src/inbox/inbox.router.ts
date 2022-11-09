import { Request, Response, Router as router } from 'express';

import Inbox from './inbox.service';

const inboxRouter = router();

const fakeEmails = [
  {
    from: 'teddy@gmail.com',
    subject: 'Having some trouble ?',
    date: 'Today',
  },
  {
    from: 'john&dot.com',
    subject: 'Buy new airpods',
    date: 'Yesterday',
  },
];

inboxRouter.get('/:login', async (req: Request, res: Response) => {
  const { login } = req.params;
  // const emails = await Inbox.getUserEmailList(login)
  const params = { login, emails: fakeEmails, email: {} };

  res.render('inbox', params);
});

inboxRouter.get('/:login/message/:id', async (req: Request, res: Response) => {
  const { login, id } = req.params;

  // if (Inbox.verifyEmailPath(login, id)) {
  //   const { source } = await Inbox.getUserEmail(login, id);
  const source = 'apejapeapzejapieja';
  if (true) {
    res.render('inbox', { login, email: { id, source, from: 'teddy@gmail.com',
    subject: 'Having some trouble ?',
    date: 'Today', }, emails: fakeEmails });
  } else {
    res.redirect(`/inbox/${login}`);
  }
});

inboxRouter.get(
  '/:login/message/:id/unsafe',
  async (req: Request, res: Response) => {
    const { login, id } = req.params;

    if (Inbox.verifyEmailPath(login, id)) {
      const { mail } = await Inbox.getUserEmail(login, id);

      if (mail) {
        if (mail.html) {
          res.send(`<base target="_blank">\n${mail.html}`);
        } else {
          res.send(mail.textAsHtml);
        }
      } else {
        res.redirect(`/inbox/${login}`);
      }
    } else {
      res.redirect(`/inbox/${login}`);
    }
  }
);

inboxRouter.get(
  '/:login/message/:id/download',
  async (req: Request, res: Response) => {
    const { login, id } = req.params;

    if (Inbox.verifyEmailPath(login, id)) {
      const { mail, path } = await Inbox.getUserEmail(login, id);

      if (mail && path) {
        res.download(path, 'e-mail.cafe.txt');
      } else {
        res.redirect(`/inbox/${login}`);
      }
    } else {
      res.redirect(`/inbox/${login}`);
    }
  }
);

export default inboxRouter;
