// API Smart Search - Pencarian pintar semua kota di dunia
export default async function handler(req, res) {
    // Set CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    
    // Handle preflight request
    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }
    
    // Hanya menerima method GET
    if (req.method !== 'GET') {
        return res.status(405).json({ error: 'Method not allowed' });
    }
    
    const { q } = req.query;
    
    if (!q || q.trim().length < 2) {
        return res.status(400).json({ 
            success: false, 
            error: 'Parameter q (nama tempat) diperlukan minimal 2 karakter' 
        });
    }
    
    const searchQuery = q.trim();
    
    try {
        // Panggil Nominatim API
        const url = `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(searchQuery)}&limit=10&addressdetails=1&accept-language=id`;
        
        const response = await fetch(url, {
            headers: {
                'User-Agent': 'Solihah-App/1.0'
            }
        });
        
        if (!response.ok) {
            throw new Error(`Nominatim API error: ${response.status}`);
        }
        
        const data = await response.json();
        
        if (!data || data.length === 0) {
            return res.status(200).json({
                success: true,
                results: [],
                message: 'Tidak ada hasil ditemukan'
            });
        }
        
        // Format hasil
        const results = data.map((item, index) => {
            const address = item.address || {};
            return {
                id: index,
                name: item.display_name.split(',')[0],
                fullName: item.display_name,
                lat: parseFloat(item.lat),
                lon: parseFloat(item.lon),
                type: item.type,
                importance: item.importance || 0,
                country: address.country || '',
                city: address.city || address.town || address.village || '',
                region: address.state || ''
            };
        });
        
        return res.status(200).json({
            success: true,
            query: searchQuery,
            total: results.length,
            results: results
        });
        
    } catch (error) {
        console.error('Smart search error:', error);
        return res.status(500).json({
            success: false,
            error: 'Gagal melakukan pencarian: ' + error.message
        });
    }
}
