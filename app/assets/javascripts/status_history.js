// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

const formFilter = $('#js-form-filter');
const bronkTestLink = $('#broken-test-alert')
formFilter.submit((e) => {
  e.preventDefault();
  loadChart();
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


function loadChart() {
  $.ajax("sessions_status_by_date", {
    data: formFilter.serialize()
  }).done(function (data) {
      var ctx = document.getElementById('historyChartCanvas').getContext('2d');

      $('#js-loading').hide();
      if (window.historyChart) {
        window.historyChart.data = data;
        window.historyChart.update();
      } else {
        window.historyChart = Chart.Line(ctx, {
          data: data,
          options: {
            responsive: true,
            scales: {
              xAxes: [{
                gridLines: {
                  color: '#b1b1b1'
                }
              }],
              yAxes: [{
                gridLines: {
                  color: '#b1b1b1'
                }
              }]
            }
          }
        });
      }
    })
    .fail(function () {
      alert("error");
    });
}

loadChart();
loadBrokenTestAlert();
