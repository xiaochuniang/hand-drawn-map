<template>
  <div class="map-container">
    <div ref="mapContainer" class="map"></div>
    
    <!-- Controls Panel -->
    <div class="controls-panel">
      <!-- Language Switch -->
      <div class="control-group">
        <label>{{ t('controls.language') }}</label>
        <select v-model="currentLocale" @change="changeLanguage">
          <option value="zh">中文</option>
          <option value="en">English</option>
        </select>
      </div>
      
      <!-- Layer Toggles -->
      <div class="control-group">
        <label>{{ t('controls.layers') }}</label>
        <div class="checkbox-group">
          <label>
            <input type="checkbox" v-model="layerVisibility.pois" @change="toggleLayer('pois')" />
            {{ t('layers.pois') }}
          </label>
          <label>
            <input type="checkbox" v-model="layerVisibility.viewpoints" @change="toggleLayer('viewpoints')" />
            {{ t('layers.viewpoints') }}
          </label>
          <label>
            <input type="checkbox" v-model="layerVisibility.routes" @change="toggleLayer('routes')" />
            {{ t('layers.routes') }}
          </label>
        </div>
      </div>
      
      <!-- Route Mode Filter -->
      <div class="control-group">
        <label>{{ t('controls.mode') }}</label>
        <select v-model="selectedMode" @change="filterRoutes">
          <option value="all">{{ t('modes.all') }}</option>
          <option value="walk">{{ t('modes.walk') }}</option>
          <option value="bike">{{ t('modes.bike') }}</option>
          <option value="boat">{{ t('modes.boat') }}</option>
        </select>
      </div>
      
      <!-- Route Statistics -->
      <div v-if="routeStats && selectedMode !== 'all'" class="control-group route-stats">
        <h4>{{ t('modes.' + selectedMode) }} {{ t('layers.routes') }}</h4>
        <p>{{ t('route.duration') }}: {{ routeStats.totalDuration }} {{ t('route.minutes') }}</p>
        <p>{{ t('route.distance') }}: {{ routeStats.totalDistance }} {{ t('route.km') }}</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import maplibregl, { Map, Popup } from 'maplibre-gl';
import 'maplibre-gl/dist/maplibre-gl.css';
import { mapConfig, bboxToBounds } from '../config/mapConfig';

const { t, locale } = useI18n();

const mapContainer = ref<HTMLDivElement | null>(null);
let map: Map | null = null;
let popup: Popup | null = null;

const currentLocale = ref(locale.value);
const selectedMode = ref('all');
const layerVisibility = ref({
  pois: true,
  viewpoints: true,
  routes: true
});

const routeStats = ref<{ totalDuration: number; totalDistance: number } | null>(null);

// Initialize map
onMounted(() => {
  if (!mapContainer.value) return;
  
  map = new maplibregl.Map({
    container: mapContainer.value,
    style: {
      version: 8,
      sources: {
        'raster-tiles': {
          type: 'raster',
          tiles: [mapConfig.tileUrl],
          tileSize: mapConfig.tileSize,
          minzoom: mapConfig.minZoom,
          maxzoom: mapConfig.maxZoom
        }
      },
      layers: [
        {
          id: 'background',
          type: 'background',
          paint: {
            'background-color': '#f0f0f0'
          }
        },
        {
          id: 'raster-layer',
          type: 'raster',
          source: 'raster-tiles',
          paint: {
            'raster-opacity': 1
          }
        }
      ]
    },
    center: mapConfig.initialCenter,
    zoom: mapConfig.initialZoom
  });
  
  map.on('load', () => {
    if (!map) return;
    
    // Fit bounds to bbox
    map.fitBounds(bboxToBounds(mapConfig.bbox), {
      padding: 50,
      duration: 1000
    });
    
    // Add data sources
    addDataSources();
    
    // Add layers
    addLayers();
    
    // Add interactions
    addInteractions();
  });
});

// Add GeoJSON data sources
function addDataSources() {
  if (!map) return;
  
  map.addSource('pois', {
    type: 'geojson',
    data: '/pois.geojson'
  });
  
  map.addSource('viewpoints', {
    type: 'geojson',
    data: '/viewpoints.geojson'
  });
  
  map.addSource('routes', {
    type: 'geojson',
    data: '/routes.geojson'
  });
}

// Add map layers
function addLayers() {
  if (!map) return;
  
  // Routes layer
  map.addLayer({
    id: 'routes-layer',
    type: 'line',
    source: 'routes',
    paint: {
      'line-color': [
        'match',
        ['get', 'mode'],
        'walk', '#2ecc71',
        'bike', '#3498db',
        'boat', '#9b59b6',
        '#95a5a6'
      ],
      'line-width': 3,
      'line-opacity': 0.8
    }
  });
  
  // POIs layer
  map.addLayer({
    id: 'pois-layer',
    type: 'circle',
    source: 'pois',
    paint: {
      'circle-radius': 8,
      'circle-color': '#e74c3c',
      'circle-stroke-width': 2,
      'circle-stroke-color': '#ffffff'
    }
  });
  
  // Viewpoints layer
  map.addLayer({
    id: 'viewpoints-layer',
    type: 'circle',
    source: 'viewpoints',
    paint: {
      'circle-radius': 10,
      'circle-color': '#f39c12',
      'circle-stroke-width': 2,
      'circle-stroke-color': '#ffffff'
    }
  });
}

// Add interactive features
function addInteractions() {
  if (!map) return;
  
  // POI click handler
  map.on('click', 'pois-layer', (e) => {
    if (!e.features || e.features.length === 0) return;
    
    const feature = e.features[0];
    if (!feature) return;
    
    const properties = feature.properties;
    
    if (!properties) return;
    
    const coordinates = (feature.geometry as any).coordinates.slice();
    const nameKey = locale.value === 'zh' ? 'name_zh' : 'name_en';
    const descKey = locale.value === 'zh' ? 'desc_zh' : 'desc_en';
    
    showPopup(coordinates, properties[nameKey], properties[descKey]);
  });
  
  // Viewpoints click handler
  map.on('click', 'viewpoints-layer', (e) => {
    if (!e.features || e.features.length === 0) return;
    
    const feature = e.features[0];
    if (!feature) return;
    
    const properties = feature.properties;
    
    if (!properties) return;
    
    const coordinates = (feature.geometry as any).coordinates.slice();
    const nameKey = locale.value === 'zh' ? 'name_zh' : 'name_en';
    const descKey = locale.value === 'zh' ? 'desc_zh' : 'desc_en';
    
    showPopup(coordinates, properties[nameKey], properties[descKey]);
  });
  
  // Routes click handler
  map.on('click', 'routes-layer', (e) => {
    if (!e.features || e.features.length === 0) return;
    
    const feature = e.features[0];
    if (!feature) return;
    
    const properties = feature.properties;
    
    if (!properties) return;
    
    const coordinates = e.lngLat;
    const nameKey = locale.value === 'zh' ? 'name_zh' : 'name_en';
    const descKey = locale.value === 'zh' ? 'desc_zh' : 'desc_en';
    const duration = properties.duration_min;
    const distance = properties.distance_km;
    
    const description = `
      ${properties[descKey]}<br/>
      <strong>${t('route.duration')}:</strong> ${duration} ${t('route.minutes')}<br/>
      <strong>${t('route.distance')}:</strong> ${distance} ${t('route.km')}
    `;
    
    showPopup([coordinates.lng, coordinates.lat], properties[nameKey], description);
  });
  
  // Change cursor on hover
  map.on('mouseenter', 'pois-layer', () => {
    if (map) map.getCanvas().style.cursor = 'pointer';
  });
  map.on('mouseleave', 'pois-layer', () => {
    if (map) map.getCanvas().style.cursor = '';
  });
  
  map.on('mouseenter', 'viewpoints-layer', () => {
    if (map) map.getCanvas().style.cursor = 'pointer';
  });
  map.on('mouseleave', 'viewpoints-layer', () => {
    if (map) map.getCanvas().style.cursor = '';
  });
  
  map.on('mouseenter', 'routes-layer', () => {
    if (map) map.getCanvas().style.cursor = 'pointer';
  });
  map.on('mouseleave', 'routes-layer', () => {
    if (map) map.getCanvas().style.cursor = '';
  });
}

// Show popup
function showPopup(coordinates: [number, number], title: string, description: string) {
  if (!map) return;
  
  if (popup) {
    popup.remove();
  }
  
  popup = new maplibregl.Popup()
    .setLngLat(coordinates)
    .setHTML(`<h3>${title}</h3><p>${description}</p>`)
    .addTo(map);
}

// Toggle layer visibility
function toggleLayer(layerName: 'pois' | 'viewpoints' | 'routes') {
  if (!map) return;
  
  const layerIdMap = {
    pois: 'pois-layer',
    viewpoints: 'viewpoints-layer',
    routes: 'routes-layer'
  };
  
  const layerId = layerIdMap[layerName];
  const visibility = layerVisibility.value[layerName] ? 'visible' : 'none';
  
  map.setLayoutProperty(layerId, 'visibility', visibility);
}

// Filter routes by mode
async function filterRoutes() {
  if (!map) return;
  
  const filter = selectedMode.value === 'all' 
    ? null 
    : ['==', ['get', 'mode'], selectedMode.value];
  
  map.setFilter('routes-layer', filter as any);
  
  // Calculate statistics
  if (selectedMode.value !== 'all') {
    try {
      const response = await fetch('/routes.geojson');
      const routesData = await response.json();
      const features = routesData.features.filter((f: any) => 
        f.properties.mode === selectedMode.value
      );
      
      const totalDuration = features.reduce((sum: number, f: any) => 
        sum + f.properties.duration_min, 0
      );
      const totalDistance = features.reduce((sum: number, f: any) => 
        sum + f.properties.distance_km, 0
      ).toFixed(1);
      
      routeStats.value = {
        totalDuration,
        totalDistance: parseFloat(totalDistance)
      };
    } catch (error) {
      console.error('Error calculating route stats:', error);
    }
  } else {
    routeStats.value = null;
  }
}

// Change language
function changeLanguage() {
  locale.value = currentLocale.value;
  
  // Update popup if it's open
  if (popup) {
    popup.remove();
    popup = null;
  }
}

// Watch locale changes to update existing popups
watch(locale, () => {
  if (popup) {
    popup.remove();
    popup = null;
  }
});

// Cleanup
onUnmounted(() => {
  if (popup) {
    popup.remove();
  }
  if (map) {
    map.remove();
  }
});
</script>

<style scoped>
.map-container {
  position: relative;
  width: 100%;
  height: 100vh;
}

.map {
  width: 100%;
  height: 100%;
}

.controls-panel {
  position: absolute;
  top: 20px;
  right: 20px;
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  max-width: 280px;
  z-index: 1;
}

.control-group {
  margin-bottom: 20px;
}

.control-group:last-child {
  margin-bottom: 0;
}

.control-group label {
  display: block;
  font-weight: 600;
  margin-bottom: 8px;
  color: #333;
}

.control-group select {
  width: 100%;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.checkbox-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.checkbox-group label {
  display: flex;
  align-items: center;
  font-weight: normal;
  margin-bottom: 0;
  cursor: pointer;
}

.checkbox-group input[type="checkbox"] {
  margin-right: 8px;
}

.route-stats {
  background: #f8f9fa;
  padding: 12px;
  border-radius: 4px;
}

.route-stats h4 {
  margin: 0 0 8px 0;
  font-size: 14px;
  color: #333;
}

.route-stats p {
  margin: 4px 0;
  font-size: 13px;
  color: #666;
}

/* Popup styles */
:deep(.maplibregl-popup-content) {
  padding: 15px;
  border-radius: 8px;
}

:deep(.maplibregl-popup-content h3) {
  margin: 0 0 8px 0;
  font-size: 16px;
  color: #333;
}

:deep(.maplibregl-popup-content p) {
  margin: 0;
  font-size: 14px;
  color: #666;
  line-height: 1.5;
}
</style>
