// 환경별 자동 설정
(function() {
    const hostname = window.location.hostname;
    const isLocal = hostname === 'localhost' || hostname === '127.0.0.1' || hostname === '' || window.location.protocol === 'file:';

    window.APP_CONFIG = {
        N8N_URL: isLocal
            ? 'http://localhost:5678'  // 로컬 n8n
            : 'https://n8nimagestudio.up.railway.app'  // Railway n8n
    };

    console.log('Environment:', isLocal ? 'LOCAL' : 'PRODUCTION');
    console.log('N8N URL:', window.APP_CONFIG.N8N_URL);
})();
