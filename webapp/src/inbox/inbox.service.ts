import { Logger, Injectable } from '@nestjs/common';
import { S3 } from '@aws-sdk/client-s3';
import { simpleParser } from 'mailparser';
import { Promise } from 'bluebird';
import * as moment from 'moment';

@Injectable()
export class InboxService {
  private readonly logger = new Logger(InboxService.name);

  async getUserInboxFromS3(user: string): Promise<object> {
    const s3ParamsList = {
      Bucket: process.env.AWS_BUCKET,
      Prefix: process.env.INBOX_PATH + user + '/',
    };
    const s3 = new S3({ region: process.env.AWS_REGION });
    const mailList = await s3.listObjectsV2(s3ParamsList);
    this.logger.debug(mailList);
    const mailListSorted = mailList.KeyCount
      ? mailList.Contents.sort(
          (a, b) => b['LastModified'].getTime() - a['LastModified'].getTime(),
        )
      : [];
    const mailInfos = [];

    this.logger.debug(process.env.AWS_BUCKET);
    this.logger.debug(process.env.INBOX_PATH + user);
    this.logger.debug('======================================');
    this.logger.debug(mailListSorted);
    this.logger.debug('======================================');

    await Promise.mapSeries(mailListSorted, async (el) => {
      const s3ParamsGet = {
        Bucket: process.env.AWS_BUCKET,
        Key: el['Key'],
      };
      const { Body } = await s3.getObject(s3ParamsGet);
      const mail = await simpleParser(await Body.transformToString());

      mailInfos.push({
        hash: el['Key'].split('/').slice(-1)[0],
        from: mail.from && mail.from.text ? mail.from.text : '',
        subject: mail.subject,
        date: moment(el['LastModified'].toString())
          .locale('fr')
          .format('DD/MM/YYYY - HH:mm'),
      });
    });
    this.logger.debug(mailInfos);

    return { login: user, emails: mailInfos };
  }

  async getUserMessageFromS3(user: string, id: string): Promise<object> {
    const s3ParamsList = {
      Bucket: process.env.AWS_BUCKET,
      Key: `${process.env.INBOX_PATH}${user}/${id}`,
    };
    const s3 = new S3({ region: process.env.AWS_REGION });
    const { Body } = await s3.getObject(s3ParamsList);

    return { login: user, id: id, source: await Body.transformToString() };
  }

  async getMailDisplay(source: string): Promise<string> {
    const mail = await simpleParser(source);

    this.logger.debug(mail.html);
    this.logger.debug(mail.textAsHtml);
    return mail.html ? mail.html : mail.textAsHtml;
  }
}
