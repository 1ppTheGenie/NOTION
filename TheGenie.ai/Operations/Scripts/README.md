{
"url": "https://bbc.co.uk/news", // url to capture
"s3key": "lambda/test.pdf", // file path in s3, user is responsible for correct file suffix
"pdf": true, // will be a PNG file if not
"format": "A4", // size of PDF. Ignored for PNG
"landscape": true, // orientation of PDF. Ignored for PNG
// html: {string or array} // HTML to render - AWS needs to be able to see the server!! Array of html produces a multi-page PDF
// width: {integer}, // output width in pixels
// height: {integer}, // output height in pixels
// bucket: {string}, // name of top-level s3 bucket
// pdfWidth: {string}, // eg "1200mm" - width of PDF,
// pdfHeight {string}, // eg "1200mm" - width of PDF
// format: {string}, // eg "A4" - page size of PDF,
// landscape:{boolean}, // whether to rotate the PDF through 90%, Note pdfWidth becomes it's height and vice versa if used
// clip: {boolean}, // clips output to part of page
// clipX: {integer}, // X pos of clip - only works if clip == true
// clipY: {integer}, // X pos of clip - only works if clip == true
// clipWidth: {integer}, // width of clip - only works if clip == true
// clipHeight: {integer}, // heightof clip - only works if clip == true
// callback: {string}, // url to post final render response to
}

AWS CLI:

aws lambda publish-layer-version --layer-name chromium-layer --description "Chromium binaries" --content S3Bucket=dynamic-array-layers,S3Key=chrome-aws-lambda.zip --compatible-runtimes nodejs14.x --region eu-west-2

npm run create -- --region eu-west-2 --role arn:aws:iam::584678469437:role/genie-puppeteer

npm run add-layers -- --region eu-west-2 --layers "arn:aws:lambda:eu-west-2:584678469437:layer:sharp-layer:2" "arn:aws:lambda:eu-west-2:584678469437:layer:chromium-layer:3"

npm run aws -- --region eu-west-2
