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
//= require jquery3
//= require popper
//= require bootstrap-sprockets

//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require_tree .

let isScriptLoaded = false;

// google map src のロードが完了してなければ、callback にて initMap
function noticeLoadCompletion(){
  isScriptLoaded = true
  initMap()
}


// google map src のロードが完了していれば、ページ遷移時にイベント監視
window.addEventListener('turbolinks:load',()=>{
  if (isScriptLoaded){
    initMap()
  }
})


function initMap(){
  let map;
  if(window.location.href.match('courts/.*/detail') != null){
    var lat = Number(document.getElementById('lat').value)
    var lng = Number(document.getElementById('lng').value)
    map = new google.maps.Map(document.getElementById('map'),{
      center:{
        lat: lat,
        lng: lng
      },
      zoom: 13
    })
  }

  if(window.location.href.match('map_search') != null){
    if(navigator.geolocation){
      navigator.geolocation.getCurrentPosition(
        (position) => {
          map = new google.maps.Map(document.getElementById('map'), {
            center: {
              lat: position.coords.latitude,
              lng: position.coords.longitude,
              },
            zoom: 13
            })
          },
        () => {
          // error handling
        }
      );
    }
  }
}
