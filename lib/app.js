(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var $, CheckFileExists;

$ = require("jquery");

CheckFileExists = (function() {
  CheckFileExists.DEFAULTS = {
    path: "",
    headers: {}
  };

  function CheckFileExists(file, options) {
    this.file = file;
    this.options = $.extend(CheckFileExists.DEFAULTS, options);
    this.fileUrl = null;
    this._jqXHR = null;
    this._deferred = $.Deferred();
    this._deferred.promise(this);
  }

  CheckFileExists.prototype._checkFileExists = function() {
    var headers, options;
    headers = $.extend({
      'file-path': "" + this.options.path + "/" + this.file.name
    }, this.options.headers);
    options = {
      type: 'HEAD',
      url: this.options.endpoint,
      cache: false,
      headers: headers
    };
    return $.ajax(options).fail((function(_this) {
      return function(jqXHR, textStatus, errorThrown) {
        if (jqXHR.status === 404) {
          return _this._emitFail("File not found: " + textStatus, jqXHR.status);
        } else {
          return _this._emitFail(textStatus, jqXHR.status);
        }
      };
    })(this)).done((function(_this) {
      return function(data, textStatus, jqXHR) {
        return _this._emitDone();
      };
    })(this));
  };

  CheckFileExists.prototype.stop = function() {
    if (this._jqXHR != null) {
      return this._jqXHR.abort();
    }
  };

  CheckFileExists.prototype._emitDone = function() {
    return this._deferred.resolveWith(this, [this.fileUrl, this.file]);
  };

  CheckFileExists.prototype._emitFail = function(err, status) {
    return this._deferred.rejectWith(this, [err, status]);
  };

  return CheckFileExists;

})();

module.exports = CheckFileExists;


},{"jquery":5}],2:[function(require,module,exports){
var $, PolyResumableUpload, ResumableUpload,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

$ = require("jquery");

ResumableUpload = require("./ResumableUpload.coffee");

PolyResumableUpload = (function(_super) {
  __extends(PolyResumableUpload, _super);

  PolyResumableUpload.DEFAULTS = {
    chunkSize: 1,
    minChunkSize: 51200,
    maxChunkSize: 2097152 * 100,
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
          return _emitFail('Could not get url for file resource. ' + textStatus, jqXHR.status);
        }
        _this.fileUrl = location;
        return _this._moveDone(checksum);
      };
    })(this));
  };

  return PolyResumableUpload;

})(ResumableUpload);

module.exports = PolyResumableUpload;


},{"./ResumableUpload.coffee":3,"jquery":5}],3:[function(require,module,exports){
var $, ResumableUpload;

$ = require("jquery");

ResumableUpload = (function() {
  ResumableUpload.SUPPORT = function() {
    return (typeof File !== 'undefined') && (typeof Blob !== 'undefined') && (typeof FileList !== 'undefined') && (!!Blob.prototype.webkitSlice || !!Blob.prototype.mozSlice || !!Blob.prototype.slice || false);
  };

  ResumableUpload.DEFAULTS = {
    resumable: true,
    headers: {}
  };

  function ResumableUpload(file, options) {
    this.file = file;
    this.options = $.extend(ResumableUpload.DEFAULTS, options);
    this.fileUrl = null;
    this.bytesWritten = null;
    this._jqXHR = null;
    this._deferred = $.Deferred();
    this._deferred.promise(this);
  }

  ResumableUpload.prototype._start = function() {
    if (!this.options.resumable || this.options.resetBefore === true) {
      this._urlCache(false);
    }
    if (!(this.fileUrl = this._urlCache())) {
      return this._post();
    } else {
      return this._head();
    }
  };

  ResumableUpload.prototype._post = function() {
    var headers, options;
    headers = $.extend({
      'Final-Length': this.file.size
    }, this.options.headers);
    options = {
      type: 'POST',
      url: this.options.endpoint,
      headers: headers
    };
    return $.ajax(options).fail((function(_this) {
      return function(jqXHR, textStatus, errorThrown) {
        return _this._emitFail("Could not post to file resource " + _this.options.endpoint + ". " + textStatus, jqXHR.status);
      };
    })(this)).done((function(_this) {
      return function(data, textStatus, jqXHR) {
        var location;
        location = jqXHR.getResponseHeader('Location');
        if (!location) {
          return _emitFail('Could not get url for file resource. ' + textStatus, jqXHR.status);
        }
        _this.fileUrl = location;
        return _this._uploadFile(0);
      };
    })(this));
  };

  ResumableUpload.prototype._head = function() {
    var options;
    options = {
      type: 'HEAD',
      url: this.fileUrl,
      cache: false,
      headers: this.options.headers
    };
    return $.ajax(options).fail((function(_this) {
      return function(jqXHR, textStatus, errorThrown) {
        if (jqXHR.status === 404) {
          return _this._post();
        } else {
          return _this._emitFail("Could not head at file resource: " + textStatus, jqXHR.status);
        }
      };
    })(this)).done((function(_this) {
      return function(data, textStatus, jqXHR) {
        var bytesWritten, offset;
        offset = jqXHR.getResponseHeader('Offset');
        bytesWritten = parseInt(offset, 10) ? parseInt(offset) : 0;
        return _this._uploadFile(bytesWritten);
      };
    })(this));
  };

  ResumableUpload.prototype._uploadFile = function(range_from) {
    var blob, bytesWrittenAtStart, headers, options, range_to, slice, xhr;
    this.bytesWritten = range_from;
    if (this.bytesWritten === this.file.size) {
      this._emitProgress();
      return this._emitDone();
    }
    this._urlCache(this.fileUrl);
    this._emitProgress();
    bytesWrittenAtStart = this.bytesWritten;
    range_to = this.file.size;
    if (this.options.chunkSize) {
      range_to = Math.min(range_to, range_from + this.options.chunkSize);
    }
    slice = this.file.slice || this.file.webkitSlice || this.file.mozSlice;
    blob = slice.call(this.file, range_from, range_to, this.file.type);
    xhr = $.ajaxSettings.xhr();
    headers = $.extend({
      'Offset': range_from,
      'Content-Type': 'application/offset+octet-stream'
    }, this.options.headers);
    options = {
      type: 'PATCH',
      url: this.fileUrl,
      data: blob,
      processData: false,
      contentType: this.file.type,
      cache: false,
      headers: headers,
      xhr: function() {
        return xhr;
      }
    };
    $(xhr.upload).bind('progress', (function(_this) {
      return function(e) {
        _this.bytesWritten = bytesWrittenAtStart + e.originalEvent.loaded;
        return _this._emitProgress(e);
      };
    })(this));
    return this._jqXHR = $.ajax(options).fail((function(_this) {
      return function(jqXHR, textStatus, errorThrown) {
        var msg;
        msg = jqXHR.responseText || textStatus || errorThrown;
        return _this._emitFail(msg, jqXHR.status);
      };
    })(this)).done((function(_this) {
      return function() {
        if (range_to === _this.file.size) {
          if (_this.options.resetAfter) {
            _this._urlCache(false);
          }
          return _this._emitDone();
        } else {
          return _this._uploadFile(range_to);
        }
      };
    })(this));
  };

  ResumableUpload.prototype.stop = function() {
    if (this._jqXHR != null) {
      return this._jqXHR.abort();
    }
  };

  ResumableUpload.prototype._emitProgress = function(e) {
    if (e == null) {
      e = null;
    }
    return this._deferred.notifyWith(this, [e, this.bytesWritten, this.file.size]);
  };

  ResumableUpload.prototype._emitDone = function() {
    return this._deferred.resolveWith(this, [this.fileUrl, this.file]);
  };

  ResumableUpload.prototype._emitFail = function(err, status) {
    return this._deferred.rejectWith(this, [err, status]);
  };

  ResumableUpload.prototype._urlCache = function(url) {
    var e, fingerPrint, result;
    fingerPrint = this.options.fingerprint;
    if (fingerPrint == null) {
      fingerPrint = this.fingerprint(this.file);
    }
    if (url === false) {
      return localStorage.removeItem(fingerPrint);
    }
    if (url) {
      result = false;
      try {
        result = localStorage.setItem(fingerPrint, url);
      } catch (_error) {
        e = _error;
      }
      return result;
    }
    return localStorage.getItem(fingerPrint);
  };

  ResumableUpload.prototype.fingerprint = function(file) {
    return 'tus-' + file.name + '-' + file.type + '-' + file.size;
  };

  return ResumableUpload;

})();

module.exports = ResumableUpload;


},{"jquery":5}],4:[function(require,module,exports){
var $, CheckFileExists, PolyResumableUpload;

$ = require("jquery");

PolyResumableUpload = require("./PolyResumableUpload.coffee");

CheckFileExists = require("./CheckFileExists.coffee");

module.exports = {
  upload: function(file, options) {
    var upload;
    upload = new PolyResumableUpload(file, options);
    if (file) {
      upload._start();
    }
    return upload;
  },
  check: function(file, options) {
    var check;
    check = new CheckFileExists(file, options);
    if (file) {
      check._checkFileExists();
    }
    return check;
  }
};


},{"./CheckFileExists.coffee":1,"./PolyResumableUpload.coffee":2,"jquery":5}],5:[function(require,module,exports){

},{}]},{},[4])