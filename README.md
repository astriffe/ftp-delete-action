# ftp-filter-delete-action
Automate deleting files on your ftp server using this GitHub action. This action support `awk` pattern matching, which allows you to combine positive and negative matching filename patterns. It is inspired by https://github.com/StephanThierry/ftp-delete-action, which can already delete files based on filenames and wildcards. 

The combination of both is for instance useful to delete old bundle files without affecting the latest ones and hence achieve a rolling deployment to your FTP server (see example below). For this use case and assuming your latest bundle hash is `8f66a78`, awk pattern operators (see below) could be combined to: `'/main-.*js/ && !/8f66a78/'`

The example below uses GitHub secrets to generate the parameters you don't want to have visible in your repo: https://docs.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets  

## Example usage

```
name: Build and Deploy
on:
  push:
    branches: [ master ]
jobs:
  build:
    name: Build Angular App
    runs-on: [ubuntu-latest]
    steps:
        ... BUILD YOUR APPLICATION ...

  deploy:
    name: Deploy
    runs-on: [ubuntu-latest]
    needs: [build]
    steps:
      - name: Download bundle
        uses: actions/download-artifact@master
        with:
          name: your-application
          path: dist/
      - name: Deploy FTP
        uses: sebastianpopp/ftp-action@v2.0.0
        with:
          host: ${{ secrets.FTP_SERVER }}
          user: ${{ secrets.FTP_USERNAME }}
          password: ${{ secrets.FTP_PASSWORD }}
          forceSsl: true
          localDir: dist/
          remoteDir: .

  cleanup:
    name: Remove old bundle files from server
    runs-on: [ubuntu-latest]
    needs: [deploy]
    steps:
      - name: Get hashes for main-*.js
        run: echo '::set-env name=_MAIN_HASH::$(ls dist/ | grep main | head -n 1 | awk -F'[.]' '{print $2}')'
      - name: Get hashes for runtime-*.js
        run: echo '::set-env name=_RUNTIME_HASH::$(ls dist/ | grep runtime | head -n 1 | awk -F'[.]' '{print $2}')'
      - name: Get hashes for polyfills-*.js
        run: echo '::set-env name=_POLYFILLS_HASH::$(ls dist/ | grep polyfills | head -n 1 | awk -F'[.]' '{print $2}')'
      - name: Get hashes for styles.*.js
        run: echo '::set-env name=_STYLES_HASH::$(ls dist/ | grep styles | head -n 1 | awk -F'[.]' '{print $2}')'

      - name: delete main-*.js, runtime-*.js, styles.*.css, polyfills-*.js
        uses: astriffe/ftp-filter-delete-action@releases/v1
        with:
          host: ${{ secrets.FTP_SERVER }}
          user: ${{ secrets.FTP_USERNAME }}
          password: ${{ secrets.FTP_PASSWORD }}
          workingDir: .
          ignoreSsl: 1
          pattern: "(/main-/ && !/${_MAIN_HASH}/) || (/runtime-/ && !/${_RUNTIME_HASH}/) || (/styles/ && !/${_STYLES_HASH}/) || (/polyfills-/ && !/${_POLYFILLS_HASH}/)"
```

## Input parameters

Input parameter | Description | Required | Example
--- | --- | --- | ---
host | FTP server name | Yes | ftp.domain.com
user | FTP username | Yes | ftpUser
password | FTP password | Yes | secureFtpPassword
workingDir | Working directory (Use "." if you want the server default and not "/") | No, default=/ | `/public_html`
pattern | awk filter patterns | Yes | see below
ignoreSSL | Ignore invalid TLS/SSL certificate (1=ignore)  | No, default=0 | 1

### AWK Pattern Operators
The pattern might look as following:
* OR combination: `''/PATTERN1|PATTERN2/`
* AND combination, in exact order: `''/PATTERN1.*PATTERN2/`
* AND combination, in any order: `''/PATTERN1/ && /PATTERN2/`
* Negative matching: `'!/PATTERN/'`

**Example**: ``'/styles-.*css/ && !/8f66a78/'`` 