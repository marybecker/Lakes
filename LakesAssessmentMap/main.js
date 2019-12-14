// initialize the map
var lat= 41.55;
var lng= -72.65;
var zoom= 9;

//Load a tile layer base map from USGS ESRI tile server https://viewer.nationalmap.gov/help/HowTo.htm
var hydro = L.esri.tiledMapLayer({url: "https://basemap.nationalmap.gov/arcgis/rest/services/USGSHydroCached/MapServer"}),
    topo = L.esri.tiledMapLayer({url: "https://basemap.nationalmap.gov/arcgis/rest/services/USGSTopo/MapServer"});

var baseMaps = {
    "Hydro": hydro,
    "Topo": topo
};

var map = L.map('map', {
    zoomControl: false,
    attributionControl: false,
    layers:[hydro]
});

map.setView([lat, lng], zoom);
map.createPane('top');
map.getPane('top').style.zIndex=650;

L.control.attribution({position: 'bottomleft'}).addTo(map);

L.control.zoom({
    position:'topright'
}).addTo(map);


// Initialize leaflet map
// var map = L.map('map', {
//     center: [41.6032, -73.0877],
//     zoom: 9,
//     minZoom: 4,
//     maxZoom: 17
// });
//
// var basemap = L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}', {
//     attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
//     maxZoom: 18,
//     id: 'mapbox.terrain-rgb',
//     accessToken: 'pk.eyJ1IjoibWFyeS1iZWNrZXIiLCJhIjoiY2p3bTg0bDlqMDFkeTQzcDkxdjQ2Zm8yMSJ9._7mX0iT7OpPFGddTDO5XzQ'
// }).addTo(map);

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
    //fillColor: "#ffffff",
    color: "#000",
    weight: 1,
    opacity: 1,
    fillOpacity: 0.8
};

var trophicStatus = ['Oligotrophic','Mesotrophic','Eutrophic'];

function getColor(d) {
    if (d == trophicStatus[0]){
        return '#67a9cf';
    } else if (d == trophicStatus[1]){
        return '#1c9099';
    } else if (d == trophicStatus[2]){
        return '#016c59';
    }
}

var categories = {},
    category;

var layersControl = L.control.layers(baseMaps,null,null,{
    collapsed:false
}).addTo(map);

function addDataToMap(data,map){
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
            layer.bindPopup(popup);
            layer.setStyle({
                fillColor: getColor(feature.properties.trophicSta)
            });
            layer.on('click',function(e){
                map.setView(e.latlng,14)
            });
            category = feature.properties.trophicSta;
            if(typeof categories[category]==="undefined"){
                categories[category] = L.layerGroup().addTo(map);
                layersControl.addOverlay(categories[category],category);
            }
            categories[category].addLayer(layer);
        }
    });
};

$.getJSON("assets/lakes_pt_19.geojson", function (data){
    addDataToMap(data,map);
});



// var lakePtLayer = $.getJSON("assets/lakes_pt_19.geojson", function (data) {
//     var lakePt =
//         L.geoJSON(data, {
//             pointToLayer: function (feature, latlng) {
//                 return L.circleMarker(latlng, geojsonMarkerOptions);
//                 },
//         onEachFeature: function (feature, layer) {
//             var popup = `<div><h2> ${feature.properties.name}</h2>
//                 <img src='pics/${feature.properties.STA_SEQ}.JPG'
//                 alt='${feature.properties.name} pic needed'
//                 class='webcam' onclick=displayYo('pics/${feature.properties.STA_SEQ}.JPG')>
//                 <p>Sample Location:  ${feature.properties.landmark} </p>
//                 <p>Click for report: <a href="rpts/${feature.properties.STA_SEQ}.pdf">Link</a></div>`;
//                 layer.bindPopup(popup);
//                 layer.setStyle({
//                     fillColor: getColor(feature.properties.trophicSta)
//                 });
//             }
//         }).addTo(map);
//
// });



var clicked = false;

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

//Jquery remove h1 map title if on a small mobile device
$(document).ready(function(){
    var width = screen.width,
        height = screen.height;
    if (screen.width <= 400 || screen.height <= 176) {
        $("h1").remove();
    }
});

//Add a legend to the map
var legend = L.control({position: 'topleft'});

    legend.onAdd = function (map) {
        var div = L.DomUtil.create('div', 'legend');
        div.innerHTML = "<h3>" +'Trophic Status'+ "</h3>";
        for (var i = 0; i < trophicStatus.length; i++) {
            var color = getColor(trophicStatus[i]);
            div.innerHTML +=
                '<span style="background:' + color + '"></span> ' +
                '<label>'+(trophicStatus[i])+ '</label>';
        }
        return div;
    };

    legend.addTo(map);





