import { Request, Response, Router as router } from 'express';

import Inbox from './inbox.service';

const inboxRouter = router();

inboxRouter.get('/:login', async (req: Request, res: Response) => {
  const { login } = req.params;
  const emails = await Inbox.getUserEmailList(login);
  const params = { login, emails };

  res.render('inbox', params);
});

inboxRouter.get('/:login/message/:id', async (req: Request, res: Response) => {
  const { login, id } = req.params;

  if (Inbox.verifyEmailPath(login, id)) {
    const { source } = await Inbox.getUserEmail(login, id);

    res.render('webmail', { login, id, source });
  } else {
    res.redirect(`/inbox/${login}`);
  }
});

inboxRouter.get('/:login/message/:id/unsafe', async (req: Request, res: Response) => {
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
});

inboxRouter.get('/:login/message/:id/download', async (req: Request, res: Response) => {
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
});

export default inboxRouter;
