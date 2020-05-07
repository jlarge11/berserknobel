# Introduction
This project serves as that main UI for `dailywombat.com`.  This UI is implemented in ReactJS and is deployed to an S3 bucket as a static website.

# Running Locally
To run locally, run `npm start`.  This will start the server and open up a browser tab at `http//localhost:3000`.

# Deploying
Before deploying, you will need to ensure all of the infrastructure configured in the [infrastructure](https://github.com/daily-wombat/infrastructure) project is in place.  Once that's ready, run `npm run deploy`.  This will run an `npm build` and then push up the contents of the newly created `build` folder to the S3 bucket.  You can then test it out by visiting `dailywombat.com`.
