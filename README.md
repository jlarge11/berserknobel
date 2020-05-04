# Introduction
This project contains all of the infrastructure for the dailywombat.com website.  It's currently broken out into three folders:  cert, site, and dns.  If creating from scratch, you should apply each folder in that order and destroy in the reverse order.

# Remote State
For state and variable management, we have the [dailywombat](https://app.terraform.io/app/dailywombat/workspaces) organization in Terraform Cloud.  Currently, the only environment we're using is prod.  By convention, each folder has its own workspace for each environment.  For example, the `cert` folder is tied to the `cert-prod` remote workspace when we're dealing with the `prod` environment.  Each remote workspace needs to set the following environment variables...

* aws_access_key_id for the `jlarge` IAM user.
* aws_secret_access_key for the `jlarge` IAM user.
* environment

# The cert folder
This folder contains the TLS certificate for dailywombat.com that will be placed in the CloudFront distribution.  If you are recreating this, the cert will be in a Pending Approval state.  An email asking for approval will be sent to justinlarge1974@gmail.com.  Once approved, the cert will be in an Issued status in the Certificate Manager.  Note that, while most of this infrastructure is in `us-west-1`, the certificate is in `us-east-1`, because that's the only region AWS supports for certificates at this time.

# The site folder
This folder contains most of the infrastructure, incuding the S3 bucket for the static content and the CloudFront distribution that sits in front of it.  If you are recreating this, then you'll also need to reapply the `dns` folder to make sure its A record points to the new CloudFront distribution.

# The dns folder
This folder contains the DNS hosted zone as well as the A record that points to the CloudFront distribution in front of the static site.  If you are recreating this, you also need to do the following in the AWS console under Route53...
* Navigate to the newly created hosted zone.
* Click on the NS record which should contain four name servers.
* In another tab, go to the `dailywombat.com` in the Registered Domains section.
* Click on "Add or edit name servers".
* One by one, replace the ones that are in there with the name servers that are in the NS record in the hosted zone in the other tab.
* After a couple of minutes, go into a browser and navigate to `dailywombat.com`.
