name: Packer AMI Workflow

on:
  push:
    branches:
      - main

env:
  PRODUCT_VERSION: "latest" 
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

jobs:
  packer-build:
    name: Run Packer
    runs-on: ubuntu-latest

    steps:
      - name: Checkout 
        uses: actions/checkout@v4

      - name: Setup `packer`
        uses: hashicorp/setup-packer@main
        id: setup
        with:
          version: ${{ env.PRODUCT_VERSION }}

      - name: Run `packer init`
        id: init
        run: "packer init ./aws-image.pkr.hcl"

      - name: Run `packer validate`
        id: validate
        run: "packer validate ./aws-image.pkr.hcl"

      - name: Run `packer build`
        id: build
        run: "packer build ./aws-image.pkr.hcl"

  s3-upload:
    name: Upload manifest to S3
    needs: [packer-build]
    runs-on: ubuntu-latest

    steps:
      - name: Checkout 
        uses: actions/checkout@v4

      - name: Upload to S3
        uses: shallwefootball/s3-upload-action@master
        with:
          aws_key_id: ${{ secrets.AWS_KEY_ID }}
          aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws_bucket: ${{ secrets.AWS_BUCKET }}
          source_dir: './packer-manifest.json'
          destination_dir: 'packer-manifest/packer-manifest.json'
