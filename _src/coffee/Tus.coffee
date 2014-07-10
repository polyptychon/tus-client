$ = require "jquery"
PolyResumableUpload = require "./PolyResumableUpload"
CheckFileExists = require "./CheckFileExists"

module.exports = {
  upload: (file, options) ->
    upload = new PolyResumableUpload(file, options)
    upload._start() if (file)
    return upload
  check: (file, options) ->
    check = new CheckFileExists(file, options)
    check._checkFileExists() if (file)
    return check
}