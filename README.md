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
