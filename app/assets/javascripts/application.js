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
//= require jquery.raty.js

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

  if((window.location.href.match('map_check') != null)||(window.location.href.match('court_select') != null)){
    var lat = Number(document.getElementById('center_latitude').value)
    var lng = Number(document.getElementById('center_longitude').value)
    map = new google.maps.Map(document.getElementById('map'),{
      center:{
        lat: lat,
        lng: lng
      },
      zoom: 13
    })
    lats_htmls = document.getElementsByClassName('latitudes')
    lngs_htmls = document.getElementsByClassName('longitudes')
    links_htmls = document.getElementsByClassName('links')
    names_htmls = document.getElementsByClassName('names')

    for(n=0; n < lats_htmls.length; n++){
      (function(){
          latlng = new google.maps.LatLng(
            lats_htmls.item(n).value,
            lngs_htmls.item(n).value
          )

          infowindow = new google.maps.InfoWindow({
            content: names_htmls.item(n).value,

          })

          marker = new google.maps.Marker({
            position: latlng,
            map: map,
            url: links_htmls.item(n).value
          })

          // クロージャ
          function set_infowindow(marker, infowindow){
            marker.addListener("click", ()=>{
              infowindow.open({
                anchor: marker,
                map,
                shouldFocus: false
              })
            })
          }
          return set_infowindow(marker, infowindow)
      })();
    }
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

          latlng = new google.maps.LatLng(
            position.coords.latitude + 0.001,
            position.coords.longitude + 0.001
            )

          marker1 = new google.maps.Marker({
            position: latlng,
            map: map,
          })

          infowindow1 = new google.maps.InfoWindow({
            content: 'さんぷる'
          })

          marker1.addListener('click',()=>{
            infowindow1.open({
              anchor: marker1,
              map,
              shouldFocus: false
            })
          })

        },

        () => {
          // error handling
        }

      );
    }
  }
}


// raty.js
const starOnPath = "<%= asset_path('star-on.png') %>"
const starOffPath = "<%= asset_path('star-off.png') %>"
const starHalfPath = "<%= asset_path('star-half.png') %>"

window.addEventListener('turbolinks:load',()=>{
  $('#eval_accessibility').raty({
    starOn: starOnPath,
    starOff: starOffPath,
    starHalf: starHalfPath,
    scoreName: 'court_review[accessibility]'
  })

  $('.evaluation').raty({
    readOnly: true,
    starOn: starOnPath,
    starOff: starOffPath,
    starHalf: starHalfPath,
    score: function(){
      return $(this).attr('data-score')
    }
  })
})
