const options = {
    center: [41.55, -72.65],
    zoom: 9,
    zoomSnap: .1,
    zoomControl: false
};
const map = L.map('map', options);
new L.control.zoom({position:"topright"}).addTo(map);

L.esri.tiledMapLayer({url: "https://basemap.nationalmap.gov/arcgis/rest/services/USGSHydroCached/MapServer"})
    .addTo(map);


//Set styles and load boundary and basin data.  Add basin layers to layer control
var linestyle = {
    "color": "black",
    "weight": 2,
};

var StateBoundary = $.getJSON("data/StateBoundary.geojson",function(linedata){
    console.log(linedata);
    L.geoJson(linedata,{
        style:linestyle
    }).addTo(map);
});

var Sites = $.getJSON("data/draft_universeOfLakes_012621.geojson", function (data) {
        // jQuery method uses AJAX request for the GeoJSON data
        console.log(data);
        // call draw map and send data as parameter
        drawMap(data);
    });

function drawMap(data) {
    // create Leaflet data layer and add to map
    const sites = L.geoJson(data, {
        pointToLayer: function (feature, latlng) {
            return L.circleMarker(latlng,);
        },
        style: function style(feature){
            return{
                radius: 6,
                fillColor: "#ffffff",
                color: "#000",
                weight: 1,
                opacity: 0.5,
                fillOpacity: 0.7
            };
        },
        // add hover/touch functionality to each feature layer
        onEachFeature: function (feature, layer) {
            const props = layer.feature.properties;
            const boat = getLab(props["Boat_Launc"]);
            const sample = getLab(props["S_12_19"]);
            const lakeID =  get305b(props["ID305B"])

            // assemble string sequence of info for tooltip (end line break with + operator)
            let tooltipInfo = `<b>${props["GNIS_Name"]}</b></br>
                                   ID: ${props["GNIS_ID"]}</br>
                                   305bID: ${lakeID}</br>
                                   Boat Launch: ${boat}</br>
                                   Sampled 2012 - 2019: ${sample}`;

            // bind a tooltip to layer with county-specific information
            layer.bindTooltip(tooltipInfo, {
                // sticky property so tooltip follows the mouse
                sticky: true,
                className: 'customTooltip'
            });

            // when mousing over a layer
            layer.on('mouseover', function () {

                // change the stroke color and bring that element to the front
                layer.setStyle({
                    color: '#ff6e00'
                }).bringToFront();
            });

            // on mousing off layer
            layer.on('mouseout', function () {

                // reset the layer style to its original stroke color
                layer.setStyle({
                    color: '#20282e'
                });
            });
        }
    }).addTo(map);

}

//Functions to get color and add style for Basins
function getColor(CW){
    if (CW == 1){
        return '#1546d9';
    } else {
        return '#2ea1cb'
    }
}

function style(feature) {
    return {
        fillColor: getColor(feature.properties.CW),
        weight: 0.5,
        opacity: 0.7,
        color: 'white',
        fillOpacity: 0.7
    };
}

//Function to get label
function getLab(j) {
    if (j ==1) {
        return 'Yes'
    } else {
        return 'No'
    }
}

function get305b(lakeID) {
    if (lakeID == null) {
        return 'No ID'
    } else {
        return lakeID
    }
}

