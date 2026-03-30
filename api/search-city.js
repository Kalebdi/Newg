export default async function handler(req, res) {
    // Enable CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    
    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }

    const { q } = req.query;
    
    if (!q) {
        return res.status(400).json({ 
            error: true, 
            message: 'Parameter q (nama kota) diperlukan' 
        });
    }

    try {
        // Panggil Nominatim API untuk geocoding
        const response = await fetch(
            `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(q)}&limit=1&addressdetails=1`,
            {
                headers: {
                    'User-Agent': 'Solihah-App/1.0'
                }
            }
        );
        
        const data = await response.json();
        
        if (data && data.length > 0) {
            const { lat, lon, display_name } = data[0];
            return res.status(200).json({
                success: true,
                lat: parseFloat(lat),
                lon: parseFloat(lon),
                display_name: display_name
            });
        } else {
            return res.status(404).json({
                error: true,
                message: 'Kota tidak ditemukan'
            });
        }
    } catch (error) {
        console.error('Geocoding error:', error);
        return res.status(500).json({
            error: true,
            message: 'Gagal mencari lokasi. Silakan coba lagi.'
        });
    }
}
