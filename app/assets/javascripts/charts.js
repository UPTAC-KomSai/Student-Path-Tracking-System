var ctx = $("#line-chart");
var gwa = $("#gwa-variable").html();
var label = $("#label-variable").html();
var points = gwa.split(","); 
var labels1 = label.split("~"); 

var lineChart = new Chart(ctx, {
  type: 'line',
  data: {
    labels: labels1,
    datasets: [
      {
        label: "MY GWAPH",
        data: points,
        backgroundColor: [
                'rgba(75, 192, 192, 0.2)'], 
         borderColor: [
                 'rgba(75, 192, 192, 1)']  
      }
    ]
  }
});