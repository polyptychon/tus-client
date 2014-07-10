$ = require "jquery"
PolyResumableUpload = require "./PolyResumableUpload.coffee"

module.exports = {
  upload: (file, options) ->
    upload = new PolyResumableUpload(file, options)
    upload._start() if (file)
    return upload
}
