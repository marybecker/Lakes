// Initialize leaflet map
var map = L.map('map', {
    center: [41.6032, -73.0877],
    zoom: 9,
    minZoom: 4,
    maxZoom: 17
});

var basemap = L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}', {
    attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
    maxZoom: 18,
    id: 'mapbox.terrain-rgb',
    accessToken: 'pk.eyJ1IjoibWFyeS1iZWNrZXIiLCJhIjoiY2p3bTg0bDlqMDFkeTQzcDkxdjQ2Zm8yMSJ9._7mX0iT7OpPFGddTDO5XzQ'
}).addTo(map);

var photoBackground = document.getElementById("background");
var photo = document.getElementById("photo");
photoBackground.addEventListener("click",function(){
    console.log("hi");
    this.style.display = "none";
})

function displayYo(url){
    console.log(url)
    photoBackground.style.display = "inherit"
    photo.innerHTML = "<img src='" + url + "' class='webcam hires'>"
}

var geojsonMarkerOptions = {
    radius: 8,
    fillColor: "#ffffff",
    color: "#000",
    weight: 1,
    opacity: 1,
    fillOpacity: 0.8
};

var lakePtLayer = $.getJSON("assets/lakes_pt_19.geojson", function (data) {
    var lakePt =
        L.geoJSON(data, {
            pointToLayer: function (feature, latlng) {
                return L.circleMarker(latlng, geojsonMarkerOptions);
                },
        onEachFeature: function (feature, layer) {
            var popup = `<div><h2> ${feature.properties.name}</h2>
                <img src='pics/${feature.properties.STA_SEQ}.JPG'
                alt='${feature.properties.name} pic needed'
                class='webcam' onclick=displayYo('pics/${feature.properties.STA_SEQ}.JPG')>
                <p>Sample Location:  ${feature.properties.landmark} </p>
                <p>Click for report: <a href="rpts/${feature.properties.STA_SEQ}.pdf">Link</a></div>`;
                layer.bindPopup(popup)
            }
        }).addTo(map);
});

var clicked = false

function myInfo() {

    var x = document.getElementById('footer');
    if (x.style.height === '33vh') {
        x.style.height = '0px';
    } else {
        x.style.height = '33vh';
    }

    var y = document.getElementById('info-button');
    if (clicked) {
        y.style.background = 'rgba(100, 100, 100, 0.9)';
        clicked = false
    } else {
        y.style.background = 'rgba(146, 239, 146, 0.8)'
        clicked = true
    }
}
