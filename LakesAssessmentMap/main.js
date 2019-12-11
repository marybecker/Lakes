// Set variables for map layers
var parkStyle = {
    layers: [
        'assets/nps.geojson',
        'assets/dboone.geojson'
    ],
    style: {
        color: 'orange',
        weight: 1,
        opacity: 0.8,
        fillOpacity: 0,
        fillColor: 'orange'
    }
}

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

/////////////:..://///////////
//    Add solution below    //
/////////////:..://///////////

// Add markers with popups
// Place markers by iterating through data
// for (var i = 0; i < camName.length; i++) {
//     if(camActive[i]== true) {
//         var marker = "<div><h2>" + camName[i] + "</h2>" +
//                 "<img src='" + camURL[i] + "'alt='" + camName[i] + "webcam' class='webcam'"+
//                 "<p>Elevation: </p>" + camElev[i] + " ft, looking " +
//                 camInfo[i] + "</div>";
//         var iconLocation = createIcon(typeLocation[i]);
//         L.marker(camCoords[i],{
//         icon: iconLocation
//     })
//         .addTo(map)
//         .bindPopup(marker);
//
//         document.getElementById("content").innerHTML += marker
//     }
// };

for (var i in locations) {
    var props = locations[i].properties;
    if(props.camActive) {
        var icon = L.icon({
            iconUrl: props.typeIconURL,
            iconSize: [40, 40],
            popupAnchor: [0, -15],
            className: "icon"
        });
        var popup = `<div><h2> ${locations[i].name}</h2>
            
                <img src='${props.camURL}' 
                alt='${locations[i].name} webcam' 
                class='webcam' onclick=displayYo('${props.camHiRes}')>
                
            <p>Elevation: </p> ${props.camElev} ft, looking 
            ${props.camInfo }</div>`;
        var marker = L.marker(props.camCoords, {
            icon: icon
        })
            .addTo(map)
            .bindPopup(popup);
        document.getElementById('content').innerHTML += popup
        console.log(popup)
    }
};

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

function createIcon(typeOfLocation) {
    let iconURL = "", // declare the iconURL
        iconSize = 30; // create default size

    if (typeOfLocation == "Mountain") {
        iconURL = typeIconURL[0];
    } else if (typeOfLocation == "Park") {
        iconURL = typeIconURL[1];
        iconSize = 40;
    } else {
        iconURL = typeIconURL[2];
        iconSize = 40;
    };

    // Create a Leaflet icon object
    let result = L.icon({
        iconUrl: iconURL,
        iconSize: iconSize,
        popupAnchor: [0, -15] // Center of your icon is [0,0]
    });

    // Function returns a properly formatted Leaf icon object to place on your map
    return result;

};

// var stateLayer = $.getJSON("assets/states_g.geojson", function (data) {
//
//     var states = L.geoJson(data, {
//         style: function (feature) {
//             return {
//                 color: 'lightyellow',
//                 // color: '#ffffff',
//                 weight: 1,
//                 opacity: 0.8,
//                 fillOpacity: 0
//             };
//         }
//     })
//
//     states.addTo(map)
//
// });

var geojsonMarkerOptions = {
    radius: 8,
    fillColor: "#ffffff",
    color: "#000",
    weight: 1,
    opacity: 1,
    fillOpacity: 0.8
};

var lakePtLayer = $.getJSON("assets/lakes_pt.geojson", function (data) {
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

$.when(stateLayer).done(function () {
    for (i = 0; i < parkStyle.layers.length; i++) {
        $.getJSON(parkStyle.layers[i], function (data) {
            var parkLayer = L.geoJson(data, {
                style: function (feature) {

                    return {
                        color: parkStyle.style.color,
                        weight: parkStyle.style.weight,
                        opacity: parkStyle.style.opacity,
                        fillOpacity: parkStyle.style.fillOpacity,
                        fillColor: parkStyle.style.fillColor
                    };
                },

                onEachFeature: function (feature, layer) {
                    var parkPopup =
                        `<h2>${feature.properties.Name}</h2><img src="${feature.properties.img}"><br><a href="${feature.properties.url}">Link</a>`
                    layer.bindPopup(parkPopup)
                    if (!L.Browser.mobile) {
                        layer.on('mouseover', function (e) {
                            e.target.setStyle({
                                fillOpacity: 0.4
                            });
                            // e.target.openPopup()
                        });
                        layer.on('mouseout', function (e) {
                            e.target.setStyle({
                                fillOpacity: parkStyle.style.fillOpacity
                            });
                            // e.target.closePopup()
                        });

                    }
                }
            })

            parkLayer.addTo(map)

        });
    }

});