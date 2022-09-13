import { Request, Response, Router as router } from 'express';

const homeRouter = router();

homeRouter.get('/', async (req: Request, res: Response) => {
  res.render('home');
});

homeRouter.post('/', async (req: Request, res: Response) => {
  const { login } = req.body;

  if (login) {
    res.redirect(`/inbox/${login}`);
  } else {
    res.redirect('/');
  }
});

homeRouter.get('/about', async (req: Request, res: Response) => {
  res.render('about');
});

homeRouter.get('/cgu', async (req: Request, res: Response) => {
  res.render('cgu');
});

homeRouter.get('/404', async (req: Request, res: Response) => {
  res.render('404');
});

export default homeRouter;
