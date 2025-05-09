export default async function handler(req, res) {
    const apiKey = '4c7117605367b492987b38b2abcd4af1';
    const lat = 38.5256;
    const lon = -121.3920;
  
    const url = `https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=${apiKey}&units=imperial`;
  
    try {
      const response = await fetch(url);
      const data = await response.json();
      res.setHeader('Access-Control-Allow-Origin', '*');
      res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0');
      res.status(200).json({ temp: data.main.temp });
    } catch (err) {
      res.status(500).json({ error: 'Failed to fetch temperature' });
    }
  }
  