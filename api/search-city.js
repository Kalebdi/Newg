// API untuk pencarian pintar dengan fuzzy matching
// Mendukung pencarian nama kota di seluruh dunia dengan toleransi kesalahan

export default async function handler(req, res) {
    // CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    
    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }

    const { q } = req.query;
    
    if (!q || q.trim().length < 2) {
        return res.status(400).json({ 
            success: false, 
            error: 'Parameter q (nama tempat) diperlukan minimal 2 karakter' 
        });
    }

    const searchQuery = q.trim().toLowerCase();
    
    try {
        // Langkah 1: Cari di Nominatim (OSM) untuk data real-time
        const nominatimUrl = `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(searchQuery)}&limit=10&addressdetails=1&accept-language=id`;
        const response = await fetch(nominatimUrl, {
            headers: { 'User-Agent': 'Solihah-App/1.0' }
        });
        
        let results = await response.json();
        
        if (!results || results.length === 0) {
            return res.status(404).json({
                success: false,
                error: 'Lokasi tidak ditemukan',
                suggestions: []
            });
        }
        
        // Format hasil dengan skor relevansi
        const formattedResults = results.map((item, index) => {
            // Hitung skor relevansi berdasarkan kecocokan nama
            let score = calculateRelevanceScore(searchQuery, item.display_name, item.type);
            
            return {
                id: index,
                name: item.display_name.split(',')[0],
                fullName: item.display_name,
                lat: parseFloat(item.lat),
                lon: parseFloat(item.lon),
                type: item.type,
                importance: item.importance || 0,
                score: score,
                country: item.address?.country || '',
                city: item.address?.city || item.address?.town || item.address?.village || '',
                region: item.address?.state || ''
            };
        });
        
        // Urutkan berdasarkan skor relevansi
        formattedResults.sort((a, b) => b.score - a.score);
        
        // Kirim 10 hasil terbaik
        const topResults = formattedResults.slice(0, 10);
        
        return res.status(200).json({
            success: true,
            query: searchQuery,
            total: topResults.length,
            results: topResults
        });
        
    } catch (error) {
        console.error('Smart search error:', error);
        return res.status(500).json({
            success: false,
            error: 'Gagal melakukan pencarian. Silakan coba lagi.',
            suggestions: []
        });
    }
}

// Fungsi untuk menghitung skor relevansi
function calculateRelevanceScore(query, displayName, type) {
    let score = 0;
    const nameLower = displayName.toLowerCase();
    const queryWords = query.split(/\s+/);
    const nameWords = nameLower.split(/[\s,]+/);
    
    // 1. Exact match dengan nama lengkap
    if (nameLower === query) {
        score += 100;
    }
    
    // 2. Prefix match (nama diawali dengan query)
    if (nameLower.startsWith(query)) {
        score += 50;
    }
    
    // 3. Setiap kata dalam query cocok dengan kata dalam nama
    for (const qWord of queryWords) {
        for (const nWord of nameWords) {
            // Exact word match
            if (nWord === qWord) {
                score += 30;
            }
            // Partial match (kata mengandung query)
            else if (nWord.includes(qWord) && qWord.length > 2) {
                score += 15;
            }
            // Fuzzy match (Levenshtein distance)
            else if (fuzzyMatch(nWord, qWord, 2)) {
                score += 10;
            }
        }
    }
    
    // 4. Prioritas berdasarkan tipe lokasi
    const typePriority = {
        'city': 20,
        'town': 18,
        'village': 15,
        'suburb': 12,
        'district': 10,
        'state': 5,
        'country': 3
    };
    score += typePriority[type] || 0;
    
    // 5. Prioritas untuk kata yang umum dicari
    const highPriorityKeywords = ['jakarta', 'surabaya', 'bandung', 'tangerang', 'bali', 'yogyakarta', 'medan'];
    for (const keyword of highPriorityKeywords) {
        if (nameLower.includes(keyword)) {
            score += 5;
        }
    }
    
    return Math.min(score, 200); // Batasi maksimal 200
}

// Fungsi fuzzy match (Levenshtein distance)
function fuzzyMatch(str1, str2, maxDistance) {
    if (Math.abs(str1.length - str2.length) > maxDistance) return false;
    
    const matrix = [];
    for (let i = 0; i <= str1.length; i++) matrix[i] = [i];
    for (let j = 0; j <= str2.length; j++) matrix[0][j] = j;
    
    for (let i = 1; i <= str1.length; i++) {
        for (let j = 1; j <= str2.length; j++) {
            const cost = str1[i - 1] === str2[j - 1] ? 0 : 1;
            matrix[i][j] = Math.min(
                matrix[i - 1][j] + 1,
                matrix[i][j - 1] + 1,
                matrix[i - 1][j - 1] + cost
            );
        }
    }
    
    return matrix[str1.length][str2.length] <= maxDistance;
}
