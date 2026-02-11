/**
 * Generate placeholder raster tiles for hand-drawn map
 * Creates simple colored tiles with noise texture
 * Tiles are saved to public/tiles/{z}/{x}/{y}.png
 */

const fs = require('fs');
const path = require('path');

// Configuration for tile generation
const TILE_SIZE = 256;
const ZOOM_LEVELS = [0, 1, 2]; // Generate tiles for zoom levels 0, 1, 2
const OUTPUT_DIR = path.join(__dirname, '..', 'public', 'tiles');

// Simple function to generate SVG tile with watercolor-like texture
function generateTileSVG(z, x, y) {
  // Create a base color with slight variations per tile
  const baseHue = (x * 137 + y * 97 + z * 53) % 360;
  const baseSaturation = 20 + (x + y) % 30;
  const baseLightness = 85 + (x * y) % 10;
  
  // Create watercolor effect with multiple overlapping shapes
  let svg = `<?xml version="1.0" encoding="UTF-8"?>
<svg width="${TILE_SIZE}" height="${TILE_SIZE}" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <filter id="noise">
      <feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="4" />
      <feColorMatrix type="saturate" values="0.3"/>
    </filter>
    <filter id="watercolor">
      <feTurbulence type="fractalNoise" baseFrequency="0.05" numOctaves="3" result="noise" />
      <feDisplacementMap in="SourceGraphic" in2="noise" scale="10" />
      <feGaussianBlur stdDeviation="1.5" />
    </filter>
  </defs>
  
  <!-- Base background -->
  <rect width="${TILE_SIZE}" height="${TILE_SIZE}" fill="hsl(${baseHue}, ${baseSaturation}%, ${baseLightness}%)" />
  
  <!-- Watercolor texture layers -->
  <rect width="${TILE_SIZE}" height="${TILE_SIZE}" fill="hsl(${baseHue + 20}, ${baseSaturation + 10}%, ${baseLightness - 5}%)" opacity="0.3" filter="url(#watercolor)" />
  <rect width="${TILE_SIZE}" height="${TILE_SIZE}" fill="hsl(${baseHue - 20}, ${baseSaturation + 5}%, ${baseLightness - 3}%)" opacity="0.2" filter="url(#watercolor)" />
  
  <!-- Paper texture -->
  <rect width="${TILE_SIZE}" height="${TILE_SIZE}" fill="white" opacity="0.15" filter="url(#noise)" />
  
  <!-- Tile coordinates for debugging (optional, can be removed) -->
  <text x="10" y="30" font-family="monospace" font-size="12" fill="#999" opacity="0.5">z${z}/x${x}/y${y}</text>
</svg>`;
  
  return svg;
}

// Function to create directory recursively if it doesn't exist
function ensureDir(dir) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

// Generate tiles for each zoom level
function generateTiles() {
  console.log('Generating placeholder tiles...');
  
  for (const z of ZOOM_LEVELS) {
    const tilesAtZoom = Math.pow(2, z);
    
    for (let x = 0; x < tilesAtZoom; x++) {
      const xDir = path.join(OUTPUT_DIR, z.toString(), x.toString());
      ensureDir(xDir);
      
      for (let y = 0; y < tilesAtZoom; y++) {
        const tilePath = path.join(xDir, `${y}.svg`);
        const svgContent = generateTileSVG(z, x, y);
        fs.writeFileSync(tilePath, svgContent);
        
        console.log(`Generated tile: ${z}/${x}/${y}.svg`);
      }
    }
  }
  
  console.log(`\nTile generation complete!`);
  console.log(`Generated tiles for zoom levels: ${ZOOM_LEVELS.join(', ')}`);
  console.log(`Total tiles: ${ZOOM_LEVELS.reduce((sum, z) => sum + Math.pow(4, z), 0)}`);
  console.log(`Tiles saved to: ${OUTPUT_DIR}`);
}

// Run tile generation
try {
  generateTiles();
} catch (error) {
  console.error('Error generating tiles:', error);
  process.exit(1);
}
