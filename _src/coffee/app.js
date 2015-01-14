// Generated by CoffeeScript 1.8.0
(function() {
  var $, Q, ResumableUpload, tus;

  $ = require("jquery");

  ResumableUpload = require("./ResumableUpload.coffee");

  tus = require("./Tus.coffee");

  Q = require("q");

  $(function() {
    var upload;
    upload = null;
    $('.js-stop').click(function(e) {
      e.preventDefault();
      if (upload) {
        return upload.stop();
      }
    });
    return $('input[type=file]').change(function() {
      var $input, $parent, displayUploadedFile, doChecksum, file, logErrors, openDialogIfFileExist, options, resetUI, startUpload, updateProgress;
      $input = $(this);
      $parent = $input.parent();
      file = this.files[0];
      $('.js-stop').removeClass('disabled');
      $('.progress').addClass('active');
      options = {
        clientChecksum: null,
        endpoint: 'http://localhost:1080/files/',
        resetBefore: $('#reset_before').prop('checked'),
        resetAfter: true,
        chunkSize: 1,
        minChunkSize: 51200,
        maxChunkSize: 2097152,
        path: ""
      };
      openDialogIfFileExist = function(error) {
        if (confirm("Do you want to overwrite file " + file.name + "?")) {
          return true;
        } else {
          return Q.reject(error);
        }
      };
      doChecksum = function() {
        if ($('#checksum').prop('checked')) {
          return tus.checksum(file, options);
        }
      };
      startUpload = function(result) {
        if ($('#checksum').prop('checked')) {
          options.clientChecksum = result.md5;
        }
        return tus.upload(file, options);
      };
      displayUploadedFile = function(result) {
        var $download;
        $download = $("<a>Download " + file.name + " (" + file.size + " bytes " + result.md5 + ")</a><br />").appendTo($parent);
        $download.attr('href', result.url);
        return $download.addClass('btn').addClass('btn-success');
      };
      updateProgress = function(result) {
        console.log(result.percentage);
        upload = result.action;
        return $('.progress-bar').css('width', "" + result.percentage + "%");
      };
      logErrors = function(error) {
        return console.log(error);
      };
      resetUI = function() {
        return $('.js-stop').addClass('disabled');
      };
      return tus.check(file, options)["catch"](openDialogIfFileExist).then(doChecksum).then(startUpload).then(displayUploadedFile).progress(updateProgress)["catch"](logErrors).fin(resetUI);
    });
  });

}).call(this);

//# sourceMappingURL=app.js.map
