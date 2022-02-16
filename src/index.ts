import express from 'express';
import dotenv from 'dotenv';
import path from 'path';

import homeRouter from './home/home.router';
import inboxRouter from './inbox/inbox.router';

dotenv.config();

if (process.env.NODE_ENV === 'production') {
  console.debug = () => {};
}

const app = express();

app.use(express.static(path.join(__dirname, "../public")));
app.use(express.urlencoded({ extended: false }));
app.set('view engine', 'ejs');

app.use('/', homeRouter);
app.use('/inbox', inboxRouter);

const PORT: number = parseInt(process.env.PORT as string, 10);
app.listen(PORT, () => {
  console.log(`Listening on port ${PORT}`);
});