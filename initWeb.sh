#!/usr/bin/env bash
npm install github-md-html \
    && mkdir dist \
    && cp .github/resources/favicon.svg dist \
    && npx github-md-html --input=./README.md --output=./dist/index.html --title="Acunetix | Web Application Security Scanner" --keywords="Acunetix Web Vulnerability Scanner" --description="Acunetix Web Vulnerability Scanner（AWVS）" --icon="/favicon.svg"
