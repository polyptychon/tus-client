// Generated by CoffeeScript 1.8.0
(function() {
  var $, PolyResumableUpload, ResumableUpload,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  if (typeof jQuery === "undefined" || jQuery === null) {
    $ = require("jquery");
  }

  ResumableUpload = require("./ResumableUpload");

  PolyResumableUpload = (function(_super) {
    __extends(PolyResumableUpload, _super);

    PolyResumableUpload.DEFAULTS = {
      chunkSize: 1,
      minChunkSize: 51200,
      maxChunkSize: 2097152,
      path: ""
    };

    function PolyResumableUpload(file, options) {
      options = $.extend(PolyResumableUpload.DEFAULTS, options);
      this._chunkTimer = -1;
      PolyResumableUpload.__super__.constructor.call(this, file, options);
    }

    PolyResumableUpload.prototype._getChunkSize = function() {
      var chunkSize, diff;
      if (this._chunkTimer < 0) {
        chunkSize = this.options.minChunkSize;
      } else {
        diff = (new Date().getTime()) - this._chunkTimer;
        chunkSize = Math.round(this.options.chunkSize / diff * 1000);
      }
      this._chunkTimer = new Date().getTime();
      return Math.min(Math.max(this.options.minChunkSize, chunkSize), this.options.maxChunkSize);
    };

    PolyResumableUpload.prototype._uploadFile = function(range_from) {
      if (this.options.chunkSize) {
        this.options.chunkSize = this._getChunkSize();
      }
      return PolyResumableUpload.__super__._uploadFile.call(this, range_from);
    };

    PolyResumableUpload.prototype._emitDone = function() {
      return this._moveFile();
    };

    PolyResumableUpload.prototype._moveDone = function(md5) {
      return this._deferred.resolveWith(this, [this.fileUrl, this.file, md5]);
    };

    PolyResumableUpload.prototype._moveFile = function() {
      var headers, options;
      headers = $.extend({
        'Final-Length': this.file.size,
        'file-path': "" + this.options.path + "/" + this.file.name
      }, this.options.headers);
      options = {
        type: 'PUT',
        url: this.fileUrl,
        cache: false,
        headers: headers
      };
      return $.ajax(options).fail((function(_this) {
        return function(jqXHR, textStatus, errorThrown) {
          if (jqXHR.status === 404) {
            return _this._emitFail("Could not move file resource: " + textStatus, jqXHR.status);
          } else {
            return _this._emitFail("Could not head at file resource: " + textStatus, jqXHR.status);
          }
        };
      })(this)).done((function(_this) {
        return function(data, textStatus, jqXHR) {
          var checksum, location;
          checksum = jqXHR.getResponseHeader('Checksum');
          location = jqXHR.getResponseHeader('Location');
          if (!location) {
            return _this._emitFail('Could not get url for file resource. ' + textStatus, jqXHR.status);
          }
          _this.fileUrl = location;
          return _this._moveDone(checksum);
        };
      })(this));
    };

    return PolyResumableUpload;

  })(ResumableUpload);

  module.exports = PolyResumableUpload;

}).call(this);

//# sourceMappingURL=PolyResumableUpload.js.map
