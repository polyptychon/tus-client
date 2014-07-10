$ = require "jquery"
CheckFileExists = require "./CheckFileExists.coffee"

module.exports = {
  check: (file, options) ->
    check = new CheckFileExists(file, options)
    check._checkFileExists() if (file)
    return check
}
