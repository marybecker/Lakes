mapboxgl.accessToken = 'pk.eyJ1IjoibWFyeS1iZWNrZXIiLCJhIjoiY2p3bTg0bDlqMDFkeTQzcDkxdjQ2Zm8yMSJ9._7mX0iT7OpPFGddTDO5XzQ';

const filterGroup = document.getElementById('filter-group');
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

map.on('load', () => {

    // request our GEOJSON data
    d3.json('./LakesYSI/data/lakes_pt.geojson').then((data) => {
        // when loaded

        const sitesData = d3.json('./LakesYSI/data/lakes_pt_ysi_sites.geojson');
        const stateBoundaryData = d3.json('./data/StateBoundary.geojson');

        Promise.all([sitesData,stateBoundaryData]).then(addLayer);

    });
});

function addLayer(data){

    console.log(data);
    const sites = data[0];
    const boundary = data[1];

    // first add the source to the map
    map.addSource('sites', {
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
        source: 'sites',
        paint: {
            // Color circles BCG, using a `match` expression.
            'circle-color': "#123f5a",
            'circle-opacity': 0.75,
            'circle-radius': 10,
        }
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

}

function addPopup(layer){

    // Create a popup, but don't add it to the map yet.
    const popup = new mapboxgl.Popup({
        className: 'sitePopup',
        closeButton: false,
        closeOnClick: false
    });

    map.on('click', layer, function(e) {

        const popupInfo =   "<b>" + e.features[0].properties.name +" ("+
                            e.features[0].properties.STA_SEQ+ ")</b></br>" +
                            "<a href ='./LakesYSI/ysipdf/bysite/" + e.features[0].properties.STA_SEQ + ".pdf' target='_blank'> Report";

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
    // map.on('click', layer, () => {
    //     map.getCanvas().style.cursor = '';
    //     popup.remove();
    // });
}

