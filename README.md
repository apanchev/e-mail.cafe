<p align="center">
  <a href="https://e-mail.cafe" target="blank"><img src="https://e-mail.cafe/img/coffee.png" width="150" title="hover text"></a>
</p>
<p align="center"><a href="https://e-mail.cafe" target="blank"><strong>https://e-mail.cafe</strong></a></p><br/>

## Project description
Open source temporary e-mail provider using `Terraform`, `Typescript` & `Node.js`

## Deploy to AWS:

> ⚠️ - An AWS route53 zone named by the domain name must be present in the account.</br>

Insert S3 bucket variables to store Terraform state in `backend_config/aws.tfvars`</br>
Insert domain name in `tfvars_files/aws.tfvars`</br>

Run deployment:
```
make deploy-aws
```