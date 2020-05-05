# Introduction
This project contains all of the infrastructure for the `dailywombat.com` website.  It's currently broken out into three folders:  `cert`, `site`, and `dns`.  If creating from scratch, you should apply each folder in that order and destroy in the reverse order.

# Remote State
State and variable management is managed with Terraform Cloud in the [dailywombat](https://app.terraform.io/app/dailywombat/workspaces) organization.  Environment management (dev, prod, etc) is a little wonky with Terraform Cloud.  Each environment (e.g. `prod`) will be represented by one local workspace named `prod` and three remote workspaces with `prod` combined with the particular infrastructure folder (e.g. `site-prod`).  Currently, the only environment is `prod`, so that means the Terraform Cloud organization currently has `cert-prod`, `site-prod`, and `dns-prod`.  If I added a `dev` environment, I would have `cert-dev`, `site-dev`, and `dns-dev`.   Unfortunately, that means I have to repeat many of the same variables in all of them.  I'm not really sure of a better way to manage this.  Local `tfvars` files will force me to complicate my `terraform` commands, and some of these variables contain secrets.

Currently, each remote environment carries the following variables...

* `aws_access_key_id` for the `jlarge` IAM user.
* `aws_secret_access_key` for the `jlarge` IAM user.
* `environment` - My original attempt was to use `var.workspace`, but that always brings back the value `default` for some reason.  I found [issue](https://github.com/hashicorp/terraform/issues/22802) out there that gets into that confusion.

# The cert folder
This folder contains the TLS certificate for `dailywombat.com` that will be placed in the CloudFront distribution.  If you are recreating this, the cert will be in a Pending Approval state.  An email asking for approval will be sent to `justinlarge1974@gmail.com`.  Once approved, the cert will be in an Issued status in the Certificate Manager.  Note that, while most of this infrastructure is in `us-west-1`, the certificate is in `us-east-1`, because that's the only region AWS supports for certificates at this time.

# The site folder
This folder contains most of the infrastructure, including the S3 bucket for the static content and the CloudFront distribution that sits in front of it.  If you are recreating this, then you'll also need to reapply the `dns` folder to make sure its A record points to the new CloudFront distribution.  You'll also need to push up the static content up again by pulling down the [main-ui](https://github.com/daily-wombat/main-ui) project and running `npm run deploy`.

# The dns folder
This folder contains the DNS hosted zone as well as the A record that points to the CloudFront distribution in front of the static site.  **Warning:**  When applying, don't run `terraform apply` by itself.  Instead, run the `tfapply` script that's sitting in this folder, because it will take the extra step of syncing the name servers on the domain registration with the ones that were assigned to the newly created hosted zone.

# Problems with name servers
By far, my biggest hurdle in getting all of this to work is that every time the DNS hosted zone is recreated, four new name servers are randomly assigned to it, and these will not be the same servers that are in the domain registration.  It took me a day of troubleshooting before I realized this, mainly because I'm not experienced in troubleshooting DNS issues (I'm still pretty bad at it).  Once I saw this as the issue, I tried the following things...

### Attempt 1:  Go into the AWS console and manually update the name servers
This solved my problem right away, but I didn't want to stay with a manual solution very long.

### Attempt 2:  See if there is a Terraform resource for the domain registration
I did see a somewhat popular [issue](https://github.com/hashicorp/terraform/issues/5368) where somebody asked for a resource called `aws_route53_domain`, but from the looks it, it kind of died on the vine.

### Attempt 3:  Add a local-exec provisioner with a script that syncs the name servers
I think I could get this to work if I was doing local Terraform, but I ran into problems with Terraform Cloud because its worker servers don't have much software on them.  In particular, they don't have the AWS CLI.  I went down this road for a while but ultimately gave up on it.

### Attempt 4:  Create a separate script that runs terraform apply and then syncs up the name servers
This is what I went with.  It works, and it's better than dealing with things manually, but it's not my favorite thing in the world.  First of all, it takes that name server syncing out of Terraform, so technically you could argue that it's a form of configuration drift.  Second, it's real easy for somebody to forget about this script and simply run `terraform apply`.  I added in a warning message about this that gets displayed to the console, but still.
