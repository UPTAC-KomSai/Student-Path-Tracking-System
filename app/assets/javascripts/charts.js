var ctx = document.getElementById("line-chart");
var gwa = document.getElementById("gwa-variable").innerHTML;
var label = document.getElementById("label-variable").innerHTML;
var points = gwa.split(",  "); 
var labels1 = label.split("  ~  ");
var labels2 = [];
var i;
for(i = 0; i < labels1.length; i++) {
  labels2.push(labels1[i].split(" / "));
}

var lineChart = new Chart(ctx, {
  type: 'line',
  data: {
    labels: labels2,
    datasets: [
      {
        label: "GWA",
        data: points,
        backgroundColor: [
                'rgba(75, 192, 192, 0.2)'],
        fill: 'start',
        borderColor: [
                 'rgba(75, 192, 192, 1)']  
      }
    ]
  },
  options: {
    scales: {
      yAxes: [{
        ticks: {
          reverse: true,
          suggestedMin: 1,
          suggestedMax: 5,
        }
      }],
      xAxes: [{
        ticks: {
          autoSkip: false,
          minRotation: 0,
          maxRotation: 0
        }
      }]
    },
    legend: {
      display: false
    }
  }
}); 