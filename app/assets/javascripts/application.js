// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require chart.js/dist/Chart.min.js
//= require jquery/dist/jquery.min.js
//= require bootstrap/dist/js/bootstrap.bundle.min.js
//= require_tree .

Chart.defaults.global.defaultFontColor = '#f8f9fa';
$(function () {
  $('[data-toggle="popover"]').popover({
    template: '<div class="popover text-dark" role="tooltip">' +
                '<div class="arrow"></div>' +
                '<h3 class="popover-header"></h3>' +
                '<div class="popover-body"></div>' +
              '</div>'
  })
})

const formFilter = $('#js-form-filter');
const bronkTestLink = $('#broken-test-alert')
formFilter.submit((e) => {
  e.preventDefault();
  loadHistoryChart();
  loadHistoryTimeChart();
  loadBrokenTestAlert();
})

bronkTestLink.click(() => {
  bronkTestLink.removeClass('jello-horizontal');
})

function loadBrokenTestAlert() {
  $.ajax("broken_tests", {
    data: formFilter.serialize()
  }).done(function (testNames) {
    if (testNames.length > 0) {
      bronkTestLink.addClass("text-warning jello-horizontal");
      bronkTestLink.attr("data-content", testNames);
    } else {
      bronkTestLink.removeClass('text-warning jello-horizontal');
    }
  })
    .fail(function () {
      alert("error");
    });
}

loadHistoryChart();
loadHistoryTimeChart();
loadBrokenTestAlert();
