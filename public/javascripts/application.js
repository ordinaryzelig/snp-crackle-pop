$(function() {

  var secondsPer100Locations = 60

  // Alert message about wait time.
  $('#locate_and_download').click(function(event) {
    var locations = $('#locations').val().split("\n").length
    waitTimeMinutes = Math.round(locations / 100 * secondsPer100Locations / 60)
    alert('Estimated wait time: ' + waitTimeMinutes + ' minutes.')
  })

})
