mapboxgl.accessToken = 'pk.eyJ1IjoibWFyeS1iZWNrZXIiLCJhIjoiY2p3bTg0bDlqMDFkeTQzcDkxdjQ2Zm8yMSJ9._7mX0iT7OpPFGddTDO5XzQ';

// const map = new mapboxgl.Map({
//     container: 'map', // container element id
//     style: 'mapbox://styles/mapbox/dark-v10',
//     center: [-72.65, 41.55], // initial map center in [lon, lat]
//     zoom: 8.5
// });

const map = new mapboxgl.Map({
    container: 'map', // container ID
    style: {
        'version': 8,
        'sources': {
            'raster-tiles': {
                'type': 'raster',
                'tiles': [
                    'https://basemap.nationalmap.gov/arcgis/rest/services/USGSHydroCached/MapServer/tile/{z}/{y}/{x}'
                ],
                'tileSize': 256,
                'attribution':
                    'USGS The National Map: National Hydrography Dataset. Data refreshed October 2021.'
            }
        },
        'layers': [
            {
                'id': 'simple-tiles',
                'type': 'raster',
                'source': 'raster-tiles',
                'minzoom': 0,
                'maxzoom': 17
            }
        ]
    },
    center: [-72.65, 41.55], // starting position
    zoom: 8.5 // starting zoom
});

const years = [1985,1990,1995,2002,2006,2010,2015];

const colors = [
    "#e4f1e1",
    "#b4d9cc",
    "#89c0b6",
    "#63a6a0",
    "#448c8a",
    "#287274",
    "#0d585f"
];


// when the map is done loading
map.on('load', () => {

    // request our GEOJSON data
    d3.json('./data/diatomSites.geojson').then((data) => {
        // when loaded
        const siteData = d3.json('./data/diatomSites.geojson');
        const stateBoundaryData = d3.json('./data/StateBoundary.geojson');

        Promise.all([siteData,stateBoundaryData]).then(addLayer);

    });
});

function addLayer(data){

    console.log(data);
    const sites = data[0];
    const boundary = data[1];

    // first add the source to the map
    map.addSource('site-data', {
        type: 'geojson',
        data: sites // use our data as the data source
    });

    map.addSource('lines',{
        'type': 'geojson',
        'data': boundary
    });

    map.addLayer({
        id: 'sites',
        type: 'circle',
        source: 'site-data',
        paint: {
            // Color circles BCG, using a `match` expression.
            'circle-color': [
                'interpolate',
                ['linear'],
                ['number', ['get', 'CFPCT']],
                0,
                colors[0],
                0.09,
                colors[1],
                0.22,
                colors[2],
                0.29,
                colors[3],
                0.37,
                colors[4],
                0.5,
                colors[5],
                0.55,
                colors[6]
            ],
            'circle-opacity': 0.9,
            'circle-radius': 15,
        },
        filter: ['==',['get','SYEAR'],1985]
    });

    map.addLayer({
        'id': 'lines',
        'type': 'line',
        'source': 'lines',
        'paint': {
            'line-width': 3,
        // Use a get expression (https://docs.mapbox.com/mapbox-gl-js/style-spec/#expressions-get)
        // to set the line-color to a feature property value.
            'line-color': '#333333'
        }
    });

    addPopup('sites')
    addInteraction('sites')


}

function addInteraction(layer) {

    document.getElementById('sliderbar').addEventListener('input', (e) => {
        const year = parseInt(e.target.value);
        console.log(year);
        const filters = ['==', ['get', 'SYEAR'], years[year]];
        map.setFilter(layer, filters);
     
        // Set the label to the year
        document.getElementById('active-year').textContent = years[year];
        });

}

function addPopup(layer){

    // Create a popup, but don't add it to the map yet.
    const popup = new mapboxgl.Popup({
        className: 'sitePopup',
        closeButton: false,
        closeOnClick: false
    });

    map.on('mousemove', layer, function(e) {

        const popupInfo =   "<b>" + e.features[0].properties.NAME + "</b> </br> % CF in Year " +
                            e.features[0].properties.SYEAR + ": " +
                            (e.features[0].properties.CFPCT *100).toFixed(2) + "</br> % CF Change 1985 - 2015: " +
                            (e.features[0].properties.CHGCF *100).toFixed(2) + "</br> % Dev Change 1985 - 2015: " +
                            (e.features[0].properties.CHGDEV *100).toFixed(2) + "</br> Lake Watershed Area (SqMi): " +
                            e.features[0].properties.SQMI.toFixed(2) + "</br> Est. EF Levels: " +
                            e.features[0].properties.EF;
                            // e.features[0].properties.SDATE + "</br> Count of Sample Years: " +
                            // e.features[0].properties.YCNT + "</br> Year Range: " +
                            // e.features[0].properties.MINYEAR + " - " + e.features[0].properties.MAXYEAR;

        // When a hover event occurs on a feature,
        // open a popup at the location of the hover, with description
        // HTML from the click event's properties.
        popup.setLngLat(e.lngLat).setHTML(popupInfo).addTo(map);
    });

    // Change the cursor to a pointer when the mouse is over.
    map.on('mousemove', layer, () => {
        map.getCanvas().style.cursor = 'pointer';
    });

    // Change the cursor back to a pointer when it leaves the point.
    map.on('mouseleave', layer, () => {
        map.getCanvas().style.cursor = '';
        popup.remove();
    });
}
