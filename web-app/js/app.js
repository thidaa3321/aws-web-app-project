document.addEventListener('DOMContentLoaded', () => {
    const startTime = Date.now();

    // Fetch instance metadata
    const fetchMetadata = async (path, elementId, fallback) => {
        try {
            const response = await fetch(`http://169.254.169.254/latest/meta-data/${path}`);
            const data = await response.text();
            document.getElementById(elementId).textContent = data;
        } catch {
            document.getElementById(elementId).textContent = fallback;
        }
    };

    fetchMetadata('instance-id', 'instance-id', `i-${Math.random().toString(36).slice(2, 11)}`);
    fetchMetadata('placement/availability-zone', 'availability-zone', 'ap-southeast-1');

    // Display load time
    window.addEventListener('load', () => {
        const loadTime = Date.now() - startTime;
        document.getElementById('load-time').textContent = `${loadTime}ms`;
    });

    // Add interactive effects
    document.querySelectorAll('.service-card').forEach(card => {
        card.addEventListener('click', () => {
            card.style.transform = 'scale(0.98)';
            setTimeout(() => card.style.transform = 'translateY(-4px)', 150);
        });
    });
});

// Health check for load balancer
window.healthCheck = () => ({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: typeof process !== 'undefined' && process.uptime ? process.uptime() : 'unknown'
});
