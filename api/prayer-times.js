export default async function handler(req, res) {
    // Enable CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    
    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }

    const { lat, lon } = req.query;
    
    if (!lat || !lon) {
        return res.status(400).json({
            error: true,
            message: 'Parameter lat dan lon diperlukan'
        });
    }

    try {
        // Panggil API Aladhan untuk jadwal shalat
        // Method 20 = Kementerian Agama RI
        const url = `https://api.aladhan.com/v1/timings?latitude=${lat}&longitude=${lon}&method=20`;
        const response = await fetch(url);
        const data = await response.json();
        
        if (data.code === 200 && data.data && data.data.timings) {
            return res.status(200).json({
                success: true,
                timings: data.data.timings,
                date: data.data.date
            });
        } else {
            return res.status(500).json({
                error: true,
                message: 'Data jadwal tidak valid dari API'
            });
        }
    } catch (error) {
        console.error('Prayer times error:', error);
        return res.status(500).json({
            error: true,
            message: 'Gagal mengambil jadwal shalat. Periksa koneksi internet.'
        });
    }
}
