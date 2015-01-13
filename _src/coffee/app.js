// Generated by CoffeeScript 1.8.0
(function() {
  var $, ResumableUpload, tus;

  $ = require("jquery");

  ResumableUpload = require("./ResumableUpload.coffee");

  tus = require("./Tus.coffee");

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
      var $input, $parent, file, options;
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
      return tus.check(file, options).then(function(result) {
        if ($('#checksum').prop('checked')) {
          return tus.checksum(file, options);
        }
      }).then(function(result) {
        if ($('#checksum').prop('checked')) {
          options.clientChecksum = result.md5;
        }
        return tus.upload(file, options);
      }).then(function(result) {
        var $download;
        $download = $("<a>Download " + file.name + " (" + file.size + " bytes " + result.md5 + ")</a><br />").appendTo($parent);
        $download.attr('href', result.url);
        return $download.addClass('btn').addClass('btn-success');
      }).progress(function(result) {
        console.log(result.percentage);
        upload = result.action;
        return $('.progress-bar').css('width', "" + result.percentage + "%");
      })["catch"](function(error) {
        return console.log(error);
      }).fin(function() {
        return $('.js-stop').addClass('disabled');
      });
    });
  });

}).call(this);

//# sourceMappingURL=app.js.map
