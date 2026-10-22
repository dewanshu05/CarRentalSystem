package com.carrental.controller;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * StaticAssetServlet
 * -------------------------------------------------------------------------
 * Guaranteed static resource handler for embedded Tomcat deployments.
 * Explicitly serves CSS, JS, Fonts, Images, and SVGs with exact RFC MIME types
 * and HTTP caching so modern browsers (Chrome/Firefox/Edge) never reject styles.
 * -------------------------------------------------------------------------
 */
public class StaticAssetServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final File webappDir;

    public StaticAssetServlet(File webappDir) {
        this.webappDir = webappDir;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String servletPath = req.getServletPath(); // e.g. /css/style.css or /css
        String pathInfo = req.getPathInfo();       // e.g. /style.css
        String fullPath = servletPath + (pathInfo != null ? pathInfo : "");

        if (fullPath.startsWith("/")) {
            fullPath = fullPath.substring(1);
        }

        // Try candidate locations to locate the requested file
        File file = new File(webappDir, fullPath);
        if (!file.exists()) {
            file = new File("src/main/webapp/" + fullPath);
        }
        if (!file.exists()) {
            file = new File("CarRentalSystem/src/main/webapp/" + fullPath);
        }

        if (file.exists() && file.isFile()) {
            setMimeType(resp, file.getName());
            resp.setContentLengthLong(file.length());
            resp.setHeader("Cache-Control", "public, max-age=86400");
            try (OutputStream out = resp.getOutputStream()) {
                Files.copy(file.toPath(), out);
                out.flush();
            }
            return;
        }

        // Fallback: Check classpath resources
        InputStream is = getClass().getClassLoader().getResourceAsStream(fullPath);
        if (is != null) {
            setMimeType(resp, fullPath);
            resp.setHeader("Cache-Control", "public, max-age=86400");
            try (InputStream in = is; OutputStream out = resp.getOutputStream()) {
                byte[] buffer = new byte[8192];
                int bytesRead;
                while ((bytesRead = in.read(buffer)) != -1) {
                    out.write(buffer, 0, bytesRead);
                }
                out.flush();
            }
            return;
        }

        resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Static file not found: " + fullPath);
    }

    private void setMimeType(HttpServletResponse resp, String filename) {
        String lower = filename.toLowerCase();
        if (lower.endsWith(".css")) {
            resp.setContentType("text/css; charset=UTF-8");
        } else if (lower.endsWith(".js")) {
            resp.setContentType("application/javascript; charset=UTF-8");
        } else if (lower.endsWith(".svg")) {
            resp.setContentType("image/svg+xml");
        } else if (lower.endsWith(".png")) {
            resp.setContentType("image/png");
        } else if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) {
            resp.setContentType("image/jpeg");
        } else if (lower.endsWith(".gif")) {
            resp.setContentType("image/gif");
        } else if (lower.endsWith(".ico")) {
            resp.setContentType("image/x-icon");
        } else if (lower.endsWith(".woff2")) {
            resp.setContentType("font/woff2");
        } else if (lower.endsWith(".woff")) {
            resp.setContentType("font/woff");
        } else if (lower.endsWith(".ttf")) {
            resp.setContentType("font/ttf");
        } else {
            resp.setContentType("text/plain; charset=UTF-8");
        }
    }
}
