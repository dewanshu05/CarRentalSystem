package com.carrental;

import java.io.File;
import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.jsp.JspFactory;

import org.apache.catalina.Context;
import org.apache.catalina.Wrapper;
import org.apache.catalina.connector.Connector;
import org.apache.catalina.core.StandardContext;
import org.apache.catalina.servlets.DefaultServlet;
import org.apache.catalina.startup.Tomcat;
import org.apache.jasper.runtime.JspFactoryImpl;
import org.apache.jasper.servlet.JspServlet;

import com.carrental.config.DBConnection;
import com.carrental.controller.CarServlet;
import com.carrental.controller.CustomerPortalServlet;
import com.carrental.controller.CustomerServlet;
import com.carrental.controller.DashboardServlet;
import com.carrental.controller.LoginServlet;
import com.carrental.controller.RegisterServlet;
import com.carrental.controller.RentalServlet;

/**
 * Main - Standalone Runner for Car Rental Management System.
 * Automatically spins up an embedded Apache Tomcat 9 server on port 8080.
 */
public class Main {
    public static void main(String[] args) throws Exception {
        // 0. Initialize JSP Factory for Jasper compiler
        if (JspFactory.getDefaultFactory() == null) {
            JspFactory.setDefaultFactory(new JspFactoryImpl());
        }

        // 1. Initialize database (MySQL or embedded fallback)
        try {
            DBConnection.getConnection().close();
        } catch (Exception e) {
            System.err.println("Database initialization notice: " + e.getMessage());
        }

        int port = 8080;
        String portStr = System.getenv("PORT");
        if (portStr != null) {
            try {
                port = Integer.parseInt(portStr);
            } catch (Exception ignored) {}
        }

        // Locate webapp directory with multi-path resolution
        File webappDir = findWebappDir();
        File projectRoot = webappDir.getParentFile() != null && webappDir.getParentFile().getParentFile() != null 
            ? webappDir.getParentFile().getParentFile() 
            : new File(".").getAbsoluteFile();
        System.out.println("📁 Webapp directory: " + webappDir.getAbsolutePath() + " (exists: " + webappDir.exists() + ")");

        Tomcat tomcat = new Tomcat();
        tomcat.setPort(port);
        tomcat.setBaseDir(new File(projectRoot.getAbsolutePath(), "temp-tomcat").getAbsolutePath());

        Connector connector = tomcat.getConnector();
        connector.setPort(port);

        // Register application at both root "" (for cloud deployment root domain)
        // and "/CarRentalSystem" (for backwards-compatible local URL path)
        registerWebContext(tomcat, "", webappDir);
        registerWebContext(tomcat, "/CarRentalSystem", webappDir);

        tomcat.start();
        System.out.println("==================================================================");
        System.out.println("🚗 Car Rental Management System is ONLINE with Dual Role Portals!");
        System.out.println("👉 Access URL: http://localhost:" + port + "/CarRentalSystem/");
        System.out.println("👑 Owner / Admin Demo: admin / admin123");
        System.out.println("🚗 Customer Demo:       aarav / customer123");
        System.out.println("==================================================================");

        tomcat.getServer().await();
        // Keep alive indefinitely in background/daemon mode
        while (true) {
            try {
                Thread.sleep(10000);
            } catch (InterruptedException ignored) {}
        }
    }

    private static File findWebappDir() {
        File[] candidates = new File[] {
            new File("src/main/webapp"),
            new File("CarRentalSystem/src/main/webapp"),
            new File("../src/main/webapp")
        };
        for (File c : candidates) {
            if (c.exists() && new File(c, "css/style.css").exists()) {
                return c.getAbsoluteFile();
            }
        }
        try {
            File codeSource = new File(Main.class.getProtectionDomain().getCodeSource().getLocation().toURI());
            File root = codeSource.getParentFile().getParentFile();
            File dir = new File(root, "src/main/webapp");
            if (dir.exists() && new File(dir, "css/style.css").exists()) {
                return dir.getAbsoluteFile();
            }
        } catch (Exception ignored) {}
        return new File("src/main/webapp").getAbsoluteFile();
    }

    private static StandardContext registerWebContext(Tomcat tomcat, String contextPath, File webappDir) {
        StandardContext ctx = (StandardContext) tomcat.addContext(contextPath, webappDir.getAbsolutePath());
        ctx.setParentClassLoader(Main.class.getClassLoader());
        ctx.setDelegate(true);
        ctx.addWelcomeFile("index.jsp");
        ctx.setSessionTimeout(30);

        // Explicit RFC MIME types so Chrome/Edge never block styles or scripts
        ctx.addMimeMapping("css", "text/css");
        ctx.addMimeMapping("js", "application/javascript");
        ctx.addMimeMapping("svg", "image/svg+xml");
        ctx.addMimeMapping("png", "image/png");
        ctx.addMimeMapping("jpg", "image/jpeg");
        ctx.addMimeMapping("jpeg", "image/jpeg");
        ctx.addMimeMapping("gif", "image/gif");
        ctx.addMimeMapping("ico", "image/x-icon");
        ctx.addMimeMapping("json", "application/json");

        // 1. Guaranteed Static Asset Servlet for CSS, JS, Images, Icons
        Wrapper assetServlet = Tomcat.addServlet(ctx, "StaticAssetServlet", new com.carrental.controller.StaticAssetServlet(webappDir));
        assetServlet.setLoadOnStartup(1);
        ctx.addServletMappingDecoded("/css/*", "StaticAssetServlet");
        ctx.addServletMappingDecoded("/js/*", "StaticAssetServlet");
        ctx.addServletMappingDecoded("/images/*", "StaticAssetServlet");

        // 2. Register DefaultServlet as fallback
        Wrapper defaultServlet = Tomcat.addServlet(ctx, "default", new DefaultServlet());
        defaultServlet.setLoadOnStartup(1);
        ctx.addServletMappingDecoded("/", "default");

        // 3. Register JspServlet for JSP page rendering
        Wrapper jspServlet = Tomcat.addServlet(ctx, "jsp", new JspServlet());
        jspServlet.addInitParameter("fork", "false");
        jspServlet.addInitParameter("xpoweredBy", "false");
        jspServlet.setLoadOnStartup(2);
        ctx.addServletMappingDecoded("*.jsp", "jsp");

        // 3. Register Auth Servlets
        Wrapper loginServlet = Tomcat.addServlet(ctx, "LoginServlet", new LoginServlet());
        loginServlet.setLoadOnStartup(3);
        ctx.addServletMappingDecoded("/login", "LoginServlet");
        ctx.addServletMappingDecoded("/logout", "LoginServlet");

        Wrapper registerServlet = Tomcat.addServlet(ctx, "RegisterServlet", new RegisterServlet());
        registerServlet.setLoadOnStartup(3);
        ctx.addServletMappingDecoded("/register", "RegisterServlet");

        // 4. Register Customer Portal Servlets
        Wrapper customerPortalServlet = Tomcat.addServlet(ctx, "CustomerPortalServlet", new CustomerPortalServlet());
        customerPortalServlet.setLoadOnStartup(3);
        ctx.addServletMappingDecoded("/customer/dashboard", "CustomerPortalServlet");
        ctx.addServletMappingDecoded("/customer/bookings", "CustomerPortalServlet");
        ctx.addServletMappingDecoded("/customer/book", "CustomerPortalServlet");
        ctx.addServletMappingDecoded("/customer/edit-booking", "CustomerPortalServlet");
        ctx.addServletMappingDecoded("/customer/cancel-booking", "CustomerPortalServlet");

        // 5. Register Owner / Admin Controllers
        Wrapper dashServlet = Tomcat.addServlet(ctx, "DashboardServlet", new DashboardServlet());
        dashServlet.setLoadOnStartup(3);
        ctx.addServletMappingDecoded("/dashboard", "DashboardServlet");

        Wrapper carServlet = Tomcat.addServlet(ctx, "CarServlet", new CarServlet());
        carServlet.setLoadOnStartup(3);
        ctx.addServletMappingDecoded("/cars", "CarServlet");

        Wrapper custServlet = Tomcat.addServlet(ctx, "CustomerServlet", new CustomerServlet());
        custServlet.setLoadOnStartup(3);
        ctx.addServletMappingDecoded("/customers", "CustomerServlet");

        Wrapper rentServlet = Tomcat.addServlet(ctx, "RentalServlet", new RentalServlet());
        rentServlet.setLoadOnStartup(3);
        ctx.addServletMappingDecoded("/rentals", "RentalServlet");

        return ctx;
    }
}
