// Generated by CoffeeScript 1.7.1
(function() {
  var $, ResumableUpload, tus;

  $ = require("jquery");

  ResumableUpload = require("./ResumableUpload.coffee");

  tus = require("./Tus.coffee");

  $(function() {
    var upload;
    if (!tus.UploadSupport) {
      console.log("Upload is not supported");
      return;
    }
    upload = null;
    $('.js-stop').click(function(e) {
      e.preventDefault();
      if (upload) {
        return upload.stop();
      }
    });
    return $('input[type=file]').change(function() {
      var $input, $parent, file, getChecksum, options, startUpload;
      $input = $(this);
      $parent = $input.parent();
      file = this.files[0];
      $('.js-stop').removeClass('disabled');
      options = {
        endpoint: 'http://localhost:1080/files/',
        resetBefore: $('#reset_before').prop('checked'),
        resetAfter: true
      };
      $('.progress').addClass('active');
      tus.check(file, options).fail(function(error, status) {
        return upload();
      }).done(function(url, file) {
        if (confirm("Do you want to overwrite file " + file.name + "?")) {
          return upload();
        }
      });
      upload = function() {
        if ($('#checksum').prop('checked')) {
          return getChecksum();
        } else {
          options.clientChecksum = null;
          return startUpload();
        }
      };
      getChecksum = function() {
        return tus.checksum(file, options).progress(function(e, bytesUploaded, bytesTotal) {
          var percentage;
          percentage = (bytesUploaded / bytesTotal * 100).toFixed(2);
          return $('.progress-bar').css('width', "" + percentage + "%");
        }).done(function(file, md5) {
          options.clientChecksum = md5;
          return startUpload();
        });
      };
      return startUpload = function() {
        return upload = tus.upload(file, options).fail(function(error, status) {
          return alert("Failed because: " + error + ". Status: " + status);
        }).always(function() {
          $input.val('');
          $('.js-stop').addClass('disabled');
          return $('.progress').removeClass('active');
        }).progress(function(e, bytesUploaded, bytesTotal) {
          var percentage;
          percentage = (bytesUploaded / bytesTotal * 100).toFixed(2);
          return $('.progress-bar').css('width', "" + percentage + "%");
        }).done(function(url, file, md5) {
          var $download;
          if (options.clientChecksum) {
            if (options.clientChecksum === md5) {
              console.log("File checksum is ok.\nServer Checksum: " + md5 + " = Client: " + options.clientChecksum);
            } else {
              console.log("File checksum error.\nServer Checksum: " + md5 + " = Client: " + options.clientChecksum);
            }
          }
          $download = $("<a>Download " + file.name + " (" + file.size + " bytes " + md5 + ")</a><br />").appendTo($parent);
          $download.attr('href', url);
          return $download.addClass('btn').addClass('btn-success');
        });
      };
    });
  });

}).call(this);

//# sourceMappingURL=app.map