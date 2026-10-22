</main>

<footer class="footer">
    <div class="footer-content">
        <div style="display:flex;align-items:center;gap:0.75rem;flex-wrap:wrap;">
            <div style="font-weight:700;color:var(--white);letter-spacing:-0.01em;display:flex;align-items:center;gap:0.4rem;">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="var(--secondary)" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M19 17h2c.6 0 1-.4 1-1v-3c0-.9-.7-1.7-1.5-1.9C18.7 10.6 16 10 16 10s-1.3-1.4-2.2-2.3c-.5-.4-1.1-.7-1.8-.7H5c-.6 0-1.1.4-1.4.9l-1.4 2.9A3.7 3.7 0 0 0 2 12v4c0 .6.4 1 1 1h2"/>
                    <circle cx="7" cy="17" r="2"/>
                    <path d="M9 17h6"/>
                    <circle cx="17" cy="17" r="2"/>
                </svg>
                DriveEase
            </div>
            <span style="opacity:0.3;">|</span>
            <span style="font-size:0.86rem;color:var(--slate-400);">&copy; 2026 DriveEase Technologies Inc. Enterprise Fleet Suite</span>
        </div>
        <div style="display:flex;align-items:center;gap:1.25rem;font-size:0.86rem;color:var(--slate-400);flex-wrap:wrap;">
            <span style="display:inline-flex;align-items:center;gap:0.4rem;">
                <span style="width:7px;height:7px;border-radius:50%;background:#10b981;display:inline-block;box-shadow:0 0 6px #10b981;"></span>
                <span style="color:#e2e8f0;font-weight:500;">Operations Online</span>
            </span>
            <span style="opacity:0.3;">|</span>
            <span>Security: <strong>TLS Encrypted</strong></span>
            <span style="opacity:0.3;">|</span>
            <span style="color:var(--slate-400);">v2.5.0 Enterprise</span>
        </div>
    </div>
</footer>

<!-- Application Scripts -->
<script src="<%= request.getContextPath() %>/js/main.js"></script>
</body>
</html>
