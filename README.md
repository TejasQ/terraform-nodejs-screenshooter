# ScreenShooter

This project exists due to a talk I'm giving (or _gave_, depending on the time of writing) at [Node Congress](https://nodecongress.com/). The talk is about **Infrastructure as Code** (IaC) and features a Node.js application that is deployed to [Amazon Web Services](https://aws.amazon.com/) without ever leaving the editor.

## What It Is

![This repo](https://yjc4y405v8.execute-api.eu-central-1.amazonaws.com/prod?url=https://github.com/TejasQ/terraform-nodejs-screenshooter)

This tool is a simple [lambda function](https://stackoverflow.com/questions/16501/what-is-a-lambda-function#:~:text=A%20Lambda%20Function%20%2C%20or%20a,in%20C%20and%20Objective%2DC.) that takes a given `url` as _input_, and gives you a JPEG screenshot as _output_. It serves the image above, and can provide a 720p screenshot of any website of your preference at the following [URL](https://en.wikipedia.org/wiki/URL):

`https://yjc4y405v8.execute-api.eu-central-1.amazonaws.com/prod?url={YOUR_URL_HERE}`

## How It Works

This project uses [Terraform](https://www.terraform.io/) to declaratively describe the infrastructure we need. Terraform then makes this real by talking to AWS via its API and creating/modifying the resources we need. Terraform also has state management, so it can make cumulative and incremental updates.

### The Node.js Part

[The Node.js part](screenshooter/takeScreenshot.ts) uses [chrome-aws-lambda](https://github.com/alixaxel/chrome-aws-lambda) and [puppeteer-core](https://www.npmjs.com/package/puppeteer-core) to spin up a [headless](https://en.wikipedia.org/wiki/Headless_browser) version of Chrome, visit a website, and take a screenshot. It then returns the image represented as a [Base64 string](https://css-tricks.com/data-uris/). This is wrapped in an [AWS Lambda Handler](screenshooter/index.ts) and then deployed to AWS using Terraform.

### The Terraform Part

It's [_one file_](main.tf) that outlines the infrastructure we need (think _blueprint_). It then _magically_ creates/updates this when we run `terraform apply` locally.

## How Can I Use It?

### Prerequisites

1. Ensure you have Terraform installed. If you don't, [use this guide](https://learn.hashicorp.com/tutorials/terraform/install-cli).
1. Ensure you have [an AWS account](https://console.aws.amazon.com/).
1. Ensure you have the [AWS cli](https://aws.amazon.com/cli/).
1. Ensure you've logged in on your system with the AWS cli and you have credentials under `~/.aws/credentials`.

### Getting Started

1. Clone this repo
1. `cd` into the cloned directory
1. `cd screenshooter` to open the Node.js part
1. Build the lambda function with `yarn && yarn build`
1. `cd ..` to go back
1. `terraform init && terraform apply` to put it online

Once it's online, you'll see URLs for `dev` and `prod` stages of your deployed function!

Run `terraform destroy` to tear everything down.

## Keep In Touch

If you'd like to talk or be friends or whatever, [let's do it on twitter](https://twitter.com/tejaskumar_)
