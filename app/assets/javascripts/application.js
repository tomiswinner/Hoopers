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


// google map src のロードが完了していれば、ページ遷移時にinitMap
window.addEventListener('turbolinks:load',()=>{
  if (isScriptLoaded){
    initMap()
  }
})



function initMap(){
  let map;
  if((($("body")[0].dataset.controller == 'courts')&&($("body")[0].dataset.action == 'show'))||
     (($("body")[0].dataset.controller == 'courts')&&($("body")[0].dataset.action == 'confirm'))){
    var lat = Number(document.getElementById('lat').value)
    var lng = Number(document.getElementById('lng').value)
    map = new google.maps.Map(document.getElementById('map'),{
      center:{
        lat: lat,
        lng: lng
      },
      zoom: 13
    })
    latlng = new google.maps.LatLng(lat,lng)
    marker = new google.maps.Marker({
      position: latlng,
      map: map,
    })
  }

  if(($("body")[0].dataset.controller == 'courts')&&($("body")[0].dataset.action == 'court_select')){
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

    var opened_window = ""

    for(n=0; n < lats_htmls.length; n++){
      (function(){
          latlng = new google.maps.LatLng(
            lats_htmls.item(n).value,
            lngs_htmls.item(n).value
          )

          infowindow = new google.maps.InfoWindow({
            content: "<a href='" + links_htmls.item(n).value + "'>" + names_htmls.item(n).value +"</a>"
          })

          marker = new google.maps.Marker({
            position: latlng,
            map: map,
          })
          console.log(links_htmls.item(n).value)

          // クロージャ
          function set_infowindow(marker, infowindow){
            marker.addListener("click", ()=>{
              infowindow.open({
                anchor: marker,
                map,
                shouldFocus: false
              })
              if(opened_window){
                opened_window.close()
              }
              opened_window = infowindow
            })
          }
          return set_infowindow(marker, infowindow)
      })();
    }
  }

  if((($("body")[0].dataset.controller == 'courts')&&($("body")[0].dataset.action == 'map_check'))||
  (($("body")[0].dataset.controller == 'courts')&&($("body")[0].dataset.action == 'map_search'))){
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

    var opened_window = ""

    for(n=0; n < lats_htmls.length; n++){
      (function(){
          latlng = new google.maps.LatLng(
            lats_htmls.item(n).value,
            lngs_htmls.item(n).value
          )

          infowindow = new google.maps.InfoWindow({
            content: "<a href='" + links_htmls.item(n).value + "'>" + names_htmls.item(n).value +"</a>"
          })

          marker = new google.maps.Marker({
            position: latlng,
            map: map,
          })
          // クロージャ
          function set_infowindow(marker, infowindow){
            marker.addListener("click", ()=>{
              infowindow.open({
                anchor: marker,
                map,
                shouldFocus: false
              })
              if((opened_window)&&(opened_window!=infowindow)){
                opened_window.close()
              }
              opened_window = infowindow
            })
          }
          return set_infowindow(marker, infowindow)
      })();
    }
  }

  if(($("body")[0].dataset.controller == 'homes')&&($("body")[0].dataset.action == 'top')){
      document.getElementById('location_btn').addEventListener('click', (e)=>{
        e.preventDefault()
        if(navigator.geolocation){
          navigator.geolocation.getCurrentPosition(
            (position) => {
              document.getElementById('latlng').value = JSON.stringify(
                  {
                  latitude: position.coords.latitude,
                  longitude: position.coords.longitude
                }
              )
            })
        }
      })
      const target = document.getElementById('latlng')
      let m_observer = new MutationObserver((m)=>{
        document.getElementById('location_form').submit()
      })
      const config = {
        attributes: true,
      }
      m_observer.observe(target, config)

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
