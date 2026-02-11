/**
 * Map Configuration
 * Centralized configuration for map bounds, tile settings, and initial view
 */

export interface BBox {
  west: number;
  south: number;
  east: number;
  north: number;
}

export interface MapConfig {
  // Bounding box for the map area
  bbox: BBox;
  
  // Initial view settings
  initialCenter: [number, number];
  initialZoom: number;
  
  // Tile configuration
  tileSize: number;
  minZoom: number;
  maxZoom: number;
  
  // Tile URL pattern
  tileUrl: string;
}

// Main map configuration
// Replace these values with your actual map bounds
export const mapConfig: MapConfig = {
  // Example bbox covering a region (adjust for your actual map)
  // These coordinates are for demonstration - replace with your actual bounds
  bbox: {
    west: -50,
    south: -50,
    east: 50,
    north: 50
  },
  
  // Initial map view
  initialCenter: [0, 0], // [longitude, latitude]
  initialZoom: 1,
  
  // Tile settings
  tileSize: 256,
  minZoom: 0,
  maxZoom: 2,
  
  // Tile URL pattern - using local tiles
  tileUrl: '/tiles/{z}/{x}/{y}.svg'
};

/**
 * Convert bbox to LngLatBoundsLike format for MapLibre
 */
export function bboxToBounds(bbox: BBox): [[number, number], [number, number]] {
  return [
    [bbox.west, bbox.south],
    [bbox.east, bbox.north]
  ];
}
