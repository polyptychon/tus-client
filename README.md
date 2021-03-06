# Description

A simple library for uploading files extending [TUS protocol](http://www.tus.io/).
This library complements [sinatra-tus](https://github.com/polyptychon/sinatra-tus) server.

# Requirements

- [JQuery](http://jquery.com/)
- [Q](https://github.com/kriskowal/q)
- [SparkMD5](https://github.com/satazor/SparkMD5)

## Install

You can install this package either with `npm` or with `bower`.

### npm

```shell
npm install --save polyptychon/tus-client
```

Add a `<script>` to your `index.html`:

```html
<script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/q.js/1.1.2/q.js"></script>

<script src="/node_modules/tus-client/lib/tus-client.min.js"></script>
```

Note that this package is in CommonJS format, so you can `var tus = require('tus-client');`

### bower

```shell
bower install polyptychon/tus-client
```

Add a `<script>` to your `index.html`:

```html
<script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/q.js/1.1.2/q.js"></script>

<script src="/bower_components/tus-client/lib/tus-client.min.js"></script>
```


## Documentation

### API quick guide

| Name          | Type     | parameters         | Returns      | Description |
| :-----------  | :---:    | :------------      | :----------  | :---------- |
| checkAll      | method   | fileList, options  | A+ promise   | Checks if files already exists on server |
| checksum      | method   | file, options      | A+ promise   | Produce MD5 checksum on client. |
| upload        | method   | file, options      | A+ promise   | Starts file upload. If we have used checksum method first, after upload completes will try to compare returned MD5 from server with client MD5. If MD5 does not match promise will be rejected |
| stop          | method   | file               | A+ promise   | Stops all operations |
| checksumAll   | method   | fileList, options  | A+ promise   | Produce MD5 checksum on client for all files. |
| uploadAll     | method   | fileList, options  | A+ promise   | Starts parallel file upload for all files.  If we have used checksum method first, after upload completes will try to compare returned MD5 from server with client MD5. If MD5 does not match promise will be rejected  |
| stopAll       | method   | fileList           | A+ promise   | Stops all operations |
| UploadSupport | property | -                  | Boolean      | Checks if browser supports File and Blob api |

### options quick guide

| Name          | Type     | Default value | Description |
| :-----------  | :---:    | :------------ | :---------- |
| endpoint      | String   | undefined     | Server URL  |
| resetBefore   | Boolean  | false         | If resetBefore is true file always uploads from first byte else if previous upload attempt was made, resumes from last uploaded byte |
| resetAfter    | Boolean  | false         | Clear localStorage after upload completes successfully |
| chunkSize     | Integer  | null          | if chunkSize is not null then file uploads in chunks else if uploaded operation was interrupted server is responsible for resuming file from last byte uploaded  |
| minChunkSize  | Integer  | 51200         | Minimum chunk size |
| maxChunkSize  | Integer  | 2097152       | Maximum chunk size |
| path          | String   | ''            | The folder on server we want uploaded file to move |
| checksum      | Boolean  | false         | if we want to perform md5 checksum on server |
| moveFileAfterUpload | Boolean   | false   | if we want to rename and move uploaded file. For compatibility with other tus server this option should be false |

### Using library
```javascript
var tus = gr.polyptychon.tus;
```
### Using library with browserify
```javascript
var Q = require("q");
var tus = require("tus-client");
```
### Example
```javascript
var tus = gr.polyptychon.tus;
var options = {
  endpoint: 'http://localhost:1080/files/',
  resetBefore: false,
  resetAfter: true,
  chunkSize: 1,
  minChunkSize: 51200,
  maxChunkSize: 2097152,
  path: ""
  checksum: true
};

tus.checkAll(files, options)
  .catch(openDialogIfFileExist)
  .then(doChecksum)
  .then(startUpload)
  .then(displayUploadedFiles)
  .progress(updateProgress)
  .catch(logErrors);

function openDialogIfFileExist(error) {
  if (!(confirm("Some files are on server. Do you want to overwrite them?"))) {
    return Q.reject(error);
  }
}
function doChecksum() {
  return tus.checksumAll(files, options);
}
function startUpload() {
  return tus.uploadAll(files, options);
}
function displayUploadedFiles(result) {
  for (i = 0, l = files.length; i < l; i++) {
    console.log(files[i].name);
  }
}
function updateProgress(result) {
  console.log(result.value.percentage);
}
function logErrors(error) {
  console.log(error);
}
```
### Example (Compatible with all tus servers)
```javascript
var tus = gr.polyptychon.tus;
var options = {
  endpoint: 'http://localhost:1080/files/',
  resetBefore: false,
  resetAfter: true,
  chunkSize: null, // does not have to be null for compatibility
  moveFileAfterUpload: false // must be false for compatibility
};

tus.uploadAll(files, options)
  .then(displayUploadedFiles)
  .progress(updateProgress)
  .catch(logErrors);

function displayUploadedFiles(result) {
  for (i = 0, l = files.length; i < l; i++) {
    console.log(files[i].name);
  }
}
function updateProgress(result) {
  console.log(result.value.percentage);
}
function logErrors(error) {
  console.log(error);
}
```
