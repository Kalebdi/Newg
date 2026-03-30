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
        // Gunakan API Aladhan dengan metode 20 (Kemenag RI)
        const url = `https://api.aladhan.com/v1/timings?latitude=${lat}&longitude=${lon}&method=20`;
        const response = await fetch(url);
        const data = await response.json();
        if (data.code === 200 && data.data && data.data.timings) {
            return res.status(200).json({ timings: data.data.timings });
        } else {
            return res.status(500).json({ error: 'Data jadwal tidak valid' });
        }
    } catch (error) {
        console.error(error);
        return res.status(500).json({ error: 'Gagal mengambil jadwal shalat' });
    }
}
