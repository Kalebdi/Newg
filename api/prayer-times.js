export default async function handler(req, res) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    
    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }

    const { lat, lon } = req.query;
    
    if (!lat || !lon) {
        return res.status(400).json({ error: 'Parameter lat dan lon diperlukan' });
    }

    try {
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
            return res.status(500).json({ error: 'Data jadwal tidak valid' });
        }
    } catch (error) {
        console.error('Prayer times error:', error);
        return res.status(500).json({ error: 'Gagal mengambil jadwal shalat' });
    }
}
