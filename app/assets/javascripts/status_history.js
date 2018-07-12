// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

const formFilter = $('#js-form-filter');

formFilter.submit((e) => {
  e.preventDefault();
  loadChart();
})

function loadChart() {
  $.ajax("data",  {
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
