# Introduction
This folder serves as that main UI for the site that you create with your fork of the [terraform-route53-cloudfront-s3](https://github.com/jlarge11-demos/terraform-route53-cloudfront-s3) repo.  Normally, this would be a standalone Git repo, but in this instance, I placed it here so that it lives with your fork of the `terraform-route53-cloudfront-s3` repo that needs it for the demo.  This UI is implemented in ReactJS and is deployed to an S3 bucket as a static website.

# Running Locally
To run locally, run `npm start`.  This will start the server and open up a browser tab at `http//localhost:3000`.

# Deploying
Before deploying, you will need to ensure all of the infrastructure configured in your fork of the [terraform-route53-cloudfront-s3](https://github.com/jlarge11-demos/terraform-route53-cloudfront-s3) project is in place.  Once that's ready, run `npm run deploy`.  This will run an `npm build` and then push up the contents of the newly created `build` folder to the S3 bucket.  You can then test it out by visiting the domain you setup in this demo.
