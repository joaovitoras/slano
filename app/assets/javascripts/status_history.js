// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$.ajax("data")
  .done(function (data) {
    var ctx = document.getElementById('myChart').getContext('2d');

    $('#js-loading').hide();

    window.myLine = Chart.Line(ctx, {
      data: data,
      options: {
        responsive: true,
      }
    });
  })
  .fail(function () {
    alert("error");
  });
