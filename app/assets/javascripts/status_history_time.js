function loadHistoryTimeChart() {
  $.ajax("sessions_time_by_date", {
    data: formFilter.serialize()
  }).done(function (data) {
    var ctx = document.getElementById('historyTimeChartCanvas').getContext('2d');
    $('#js-loading-history-time').hide();
    const durationAvg = data.datasets[0].data;
    $('#js-duration-avg').text(`${durationAvg[durationAvg.length - 1]}m`);

    if (window.historyTimeChartCanvas && window.historyTimeChartCanvas.data) {
      window.historyTimeChartCanvas.data = data;
      window.historyTimeChartCanvas.update();
    } else {
      window.historyTimeChartCanvas = Chart.Line(ctx, {
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
