# Description

A simple library for uploading files using TUS protocol.

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

### api quick guide

| Name          | Type     | parameters         | Returns      | Description |
| :-----------  | :---:    | :------------      | :----------  | :---------- |
| check         | method   | file, options      | A+ promise   |             |
| checksum      | method   | file, options      | A+ promise   |             |
| upload        | method   | file, options      | A+ promise   |             |
| stop          | method   | file               | A+ promise   |             |
| checkAll      | method   | fileList, options  | A+ promise   |             |
| checksumAll   | method   | fileList, options  | A+ promise   |             |
| uploadAll     | method   | fileList, options  | A+ promise   |             |
| stopAll       | method   | fileList           | A+ promise   |             |
| UploadSupport | property | -                  | Boolean      | Checks if browser supports File and Blob api |

### options quick guide

| Name          | Type     | Default value | Description |
| :-----------  | :---:    | :------------ | :---------- |
| endpoint      | String   | undefined     | Server URL  |
| resetBefore   | Boolean  | false         | If resetBefore is true file always uploads from first byte else if previous upload attempt was made, resumes from last uploaded byte |
| resetAfter    | Boolean  | false         | Clear localStorage after upload completes successfully |
| chunkSize     | Integer  | null          | if chunkSize is not null then file uploads in chunks else server is responsible for resuming file from last byte uploaded if uploaded operation was interrupted |
| minChunkSize  | Integer  | 51200         | Minimum chunk size |
| maxChunkSize  | Integer  | 2097152       | Maximum chunk size |
| path          | String   | ''            | The folder on server we want uploaded file to move |

