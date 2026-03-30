export default async function handler(req, res) {
    // Set CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }
    const { q } = req.query;
    if (!q) {
        return res.status(400).json({ error: 'Parameter q diperlukan' });
    }
    try {
        // Gunakan Nominatim untuk geocoding
        const response = await fetch(`https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(q)}&limit=1&addressdetails=1`);
        const data = await response.json();
        if (data && data.length > 0) {
            const { lat, lon, display_name } = data[0];
            return res.status(200).json({ lat: parseFloat(lat), lon: parseFloat(lon), display_name });
        } else {
            return res.status(404).json({ error: 'Lokasi tidak ditemukan' });
        }
    } catch (error) {
        console.error(error);
        return res.status(500).json({ error: 'Gagal mencari lokasi' });
    }
}
