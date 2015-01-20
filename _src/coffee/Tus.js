// Generated by CoffeeScript 1.8.0
(function() {
  var $, CheckFileExists, FileChecksum, PolyResumableUpload, Q, ResumableUpload;

  if (typeof jQuery === "undefined" || jQuery === null) {
    $ = require("jquery");
  }

  if ($ == null) {
    $ = jQuery;
  }

  if (global.Q == null) {
    Q = require("q");
  }

  if (global.Q != null) {
    Q = global.Q;
  }

  ResumableUpload = require("./ResumableUpload");

  PolyResumableUpload = require("./PolyResumableUpload");

  CheckFileExists = require("./CheckFileExists");

  FileChecksum = require("./FileChecksum");

  global.gr = global.gr || {};

  global.gr.polyptychon = global.gr.polyptychon || {};

  global.gr.polyptychon.tus = {
    upload: function(file, options) {
      var deferred, upload;
      deferred = Q.defer();
      upload = new PolyResumableUpload(file, options);
      file.stoppableAction = upload;
      upload.fail(function(error, status) {
        file.stoppableAction = null;
        return deferred.reject(new Error({
          error: error,
          status: status
        }));
      });
      upload.progress(function(e, bytesUploaded, bytesTotal) {
        var percentage;
        percentage = (bytesUploaded / bytesTotal * 100).toFixed(2);
        file.percentage = percentage;
        return deferred.notify({
          percentage: percentage,
          file: file,
          options: options
        });
      });
      upload.done(function(url, file, md5) {
        file.stoppableAction = null;
        file.percentage = null;
        if (file.md5 && md5) {
          if (file.md5 === md5) {
            return deferred.resolve({
              url: url,
              md5: md5,
              file: file,
              options: options
            });
          } else {
            return deferred.reject(new Error("Checksum does not match. " + file.md5 + " != " + md5));
          }
        } else {
          if (md5) {
            file.md5 = md5;
          }
          if (url) {
            file.url = url;
          }
          return deferred.resolve({
            url: url,
            md5: md5,
            file: file,
            options: options
          });
        }
      });
      if (file) {
        upload._start();
      }
      return deferred.promise;
    },
    check: function(file, options) {
      var check, deferred;
      deferred = Q.defer();
      check = new CheckFileExists(file, options);
      file.stoppableAction = check;
      if (file) {
        check._checkFileExists();
      }
      check.fail(function(error, status) {
        return deferred.resolve({
          file: file,
          options: options
        });
      }).done(function(url, file) {
        return deferred.reject({
          message: "File already exist",
          file: file,
          options: options
        });
      });
      return deferred.promise;
    },
    checksum: function(file, options) {
      var checksum, deferred;
      deferred = Q.defer();
      checksum = new FileChecksum(file, options);
      file.stoppableAction = checksum;
      checksum.fail(function(error) {
        file.stoppableAction = null;
        return deferred.reject(new Error(error));
      });
      checksum.progress(function(e, bytesUploaded, bytesTotal) {
        var percentage;
        percentage = (bytesUploaded / bytesTotal * 100).toFixed(2);
        file.percentage = percentage;
        return deferred.notify({
          percentage: percentage,
          file: file,
          options: options
        });
      });
      checksum.done(function(file, md5) {
        file.stoppableAction = null;
        file.percentage = null;
        file.md5 = md5;
        return deferred.resolve({
          md5: md5,
          file: file,
          options: options
        });
      });
      if (file) {
        checksum._computeChecksum(0);
      }
      return deferred.promise;
    },
    stop: function(file) {
      if (file.stoppableAction) {
        file.stoppableAction.stop();
      }
      return Q.reject("stop");
    },
    checkAll: function(files, options) {
      var file, promises, _i, _len;
      promises = [];
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        file = files[_i];
        promises.push(this.check(file, options));
      }
      return Q.all(promises);
    },
    checksumAll: function(files, options) {
      var file, promises, _i, _len;
      promises = [];
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        file = files[_i];
        promises.push(this.checksum(file, options));
      }
      return Q.all(promises);
    },
    uploadAll: function(files, options) {
      var file, promises, _i, _len;
      promises = [];
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        file = files[_i];
        promises.push(this.upload(file, options));
      }
      return Q.all(promises);
    },
    stopAll: function(files) {
      var file, _i, _len;
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        file = files[_i];
        this.stop(file);
      }
      return Q.reject("stop");
    },
    UploadSupport: ResumableUpload.SUPPORT
  };

  module.exports = global.gr.polyptychon.tus;

}).call(this);

//# sourceMappingURL=Tus.js.map
