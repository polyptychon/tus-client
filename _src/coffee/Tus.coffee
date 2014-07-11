$ = require "jquery"
ResumableUpload = require "./ResumableUpload"
PolyResumableUpload = require "./PolyResumableUpload"
CheckFileExists = require "./CheckFileExists"
FileChecksum = require "./FileChecksum"

module.exports = {
  upload: (file, options) ->
    upload = new PolyResumableUpload(file, options)
    upload._start() if (file)
    return upload
  check: (file, options) ->
    check = new CheckFileExists(file, options)
    check._checkFileExists() if (file)
    return check
  checksum: (file, options) ->
    checksum = new FileChecksum(file, options)
    checksum._computeChecksum(0) if (file)
    return checksum
  UploadSupport: ResumableUpload.SUPPORT
}