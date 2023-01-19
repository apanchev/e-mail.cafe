import mailparser from 'mailparser';
import bluebird from 'bluebird';
import dotenv from 'dotenv';
import moment from 'moment';
import fs from 'fs';

dotenv.config();

type S = string;
type Su = string | undefined;
type A = mailparser.Attachment[] | [];
type M = mailparser.ParsedMail | undefined;

const INBOX_DIR: string = process.env.INBOX_DIR!;

const Inbox = {
  getUserEmailList: async (login: S): Promise<object[]> => {
    const USER_INBOX: string = `${INBOX_DIR}/${login}`;
    const emails: object[] = [];

    if (fs.existsSync(USER_INBOX)) {
      const readDir = fs.readdirSync(USER_INBOX);

      await bluebird.Promise.mapSeries(readDir, async (file) => {
        const data = fs.readFileSync(`${USER_INBOX}/${file}`);
        const source = Buffer.from(data).toString('utf-8');
        const nameParts = file.split('.');
        const date = parseInt(nameParts[0], 10);

        try {
          const mail = await mailparser.simpleParser(source);

          emails.push({
            hash: `${nameParts[0]}.${nameParts[1]}`,
            from: (mail.from && mail.from.text) ? mail.from.text : '',
            subject: mail.subject,
            date: moment.unix(date).locale('fr').format('D MMMM YYYY - kk:mm'),
          });
        } catch (e) {
          console.error(e);
        }
      });
    }

    return emails.reverse();
  },

  verifyEmailPath: (login: S, id: S): boolean => {
    const filePath: string = `${INBOX_DIR}/${login}/${id}.ovh`;

    if (fs.existsSync(filePath)) {
      return true;
    }
    return false;
  },

  getUserEmail: async (login: S, id: S): Promise<{ mail: M, path: S, source: Su, attach: A }> => {
    const filePath: string = `${INBOX_DIR}/${login}/${id}.ovh`;

    try {
      const data = fs.readFileSync(filePath);
      const source = Buffer.from(data).toString('utf-8');
      const mail = await mailparser.simpleParser(source);

      return {
        mail, path: filePath, source, attach: mail.attachments,
      };
    } catch (e) {
      console.error(e);
      return {
        mail: undefined, path: '', source: '', attach: [],
      };
    }
  },
};

export default Inbox;
