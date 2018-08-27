function loadHistoryChart() {
  $.ajax("sessions_status_by_date", {
    data: formFilter.serialize()
  }).done(function (data) {
    var ctx = document.getElementById('historyChartCanvas').getContext('2d');
    $('#js-loading-history').hide();
    const lastPassed = data.datasets[0].data;
    const lastFailed = data.datasets[1].data;
    const lastSetupFailed = data.datasets[2].data;

    $('#js-passed-value').text(lastPassed[lastPassed.length - 1]);
    $('#js-error-value').text(lastFailed[lastFailed.length - 1]);
    $('#js-setupfailed-value').text(lastSetupFailed[lastSetupFailed.length - 1]);

    if (window.historyChart && window.historyChart.data) {
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
