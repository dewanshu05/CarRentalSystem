# DriveEase — Car Rental Management System
### College Java Project (B.Tech CSE - 5th Semester)
**Technologies:** Java, Servlets, JSP, JDBC, MySQL, HTML5, CSS3, JavaScript

---

## 🌟 Dual-Portal Architecture: Owner vs Customer

The system strictly separates **Vehicle Owner / Admin** operations from **Customer** self-service, secured with session-based authentication and role authorization checks:

```
                          ┌───────────────────────────┐
                          │   Login / Register Page   │
                          │   (/login and /register)  │
                          └─────────────┬─────────────┘
                                        │
                    ┌───────────────────┴───────────────────┐
                    │                                       │
            [Role: ADMIN]                           [Role: CUSTOMER]
                    ▼                                       ▼
    ┌───────────────────────────────┐       ┌───────────────────────────────┐
    │     OWNER / ADMIN PORTAL      │       │        CUSTOMER PORTAL        │
    │  - Global Revenue & KPIs      │       │  - Personalized Greeting      │
    │  - Add / Edit / Delete Cars   │       │  - Browse Available Cars      │
    │  - Manage Customer Directory  │       │  - Book Vehicle for Self      │
    │  - View All Bookings          │       │  - View Personal History      │
    │  - Process Vehicle Returns    │       │  - Invoices & Cost Breakdown  │
    │  - Calculate Late Fees        │       │  - Access to Admin: BLOCKED   │
    └───────────────────────────────┘       └───────────────────────────────┘
```

---

## 🔑 Default Login Credentials (Demo Accounts)

A **1-Click Auto-Fill** button is available directly on the login page for quick demonstrations:

| Portal Role | Username | Password | Access Capabilities |
| :--- | :--- | :--- | :--- |
| **👑 Vehicle Owner / Admin** | `admin` | `admin123` | Full control: Fleet CRUD, all customer profiles, all bookings, vehicle inspection returns, late penalty fees, global revenue. |
| **🚗 Customer (Sample 1)** | `aarav` | `customer123` | Customer view: Browse available cars, rent a vehicle, view personal booking history & invoice receipts. |
| **🚗 Customer (Sample 2)** | `priya` | `customer123` | Customer view: Priya Patel profile. |
| **📝 New Customer** | *Self-Register* | *Your choice* | Click **Register as Customer** on `/register` to create a new driver account. |

> [!IMPORTANT]
> **Strict Security Enforcement:** If a customer attempts to directly type or access Owner/Admin URLs (such as `/cars`, `/customers`, `/rentals`), the controller automatically blocks the request and redirects them with an **"Access Denied! Owner privileges required"** alert.

---

## 💻 How to Run this Project in Visual Studio Code (Step-by-Step)

### Option 1: Run via VS Code Integrated Terminal (Fastest & Recommended)
1. Launch **Visual Studio Code**.
2. Click **File &rarr; Open Folder...** and select:
   `c:\Users\divur\Desktop\Frontend Development\CarRentalSystem`
3. Open the integrated terminal in VS Code:
   - Press **`Ctrl + ~`** (or go to **Terminal &rarr; New Terminal**).
4. Run the application with Maven:
   ```powershell
   mvn exec:java
   ```
   *(Or simply type `.\run.bat`)*
5. The built-in embedded Apache Tomcat 9 server boots up on port 8080!
6. Open your browser and navigate to:
   ```
   http://localhost:8080/CarRentalSystem/
   ```

---

### Option 2: Run via VS Code Java Extension Pack (Run & Debug)
1. In VS Code, install the extension:
   - **Extension Pack for Java** (by Microsoft)
2. Open `src/main/java/com/carrental/Main.java`.
3. You will see a small **"Run | Debug"** text hyperlink above `public static void main(String[] args)`.
4. Click **Run**.
5. VS Code will compile the classes and start the server. Check the **Debug Console** or **Terminal** tab for the startup banner.
6. Open: `http://localhost:8080/CarRentalSystem/`

---

### Option 3: Deploy to External Apache Tomcat in VS Code
1. In VS Code Extensions, install:
   - **Community Server Connectors** (or **Tomcat for Java**).
2. Build the `.war` package in the terminal:
   ```powershell
   mvn clean package
   ```
3. A war file `target/CarRentalSystem.war` is generated.
4. Copy `target/CarRentalSystem.war` into your Tomcat `webapps/` folder, then start Tomcat.
5. Browse to `http://localhost:8080/CarRentalSystem/`.

---

## 🗄️ Database Setup (MySQL)

1. Open **MySQL Workbench** or MySQL CLI.
2. Run the script:
   ```sql
   SOURCE c:/Users/divur/Desktop/Frontend Development/CarRentalSystem/database/database.sql;
   ```
3. In [`DBConnection.java`](file:///c:/Users/divur/Desktop/Frontend%20Development/CarRentalSystem/src/main/java/com/carrental/config/DBConnection.java), verify:
   ```java
   private static final String USER = "root";
   private static final String PASSWORD = "root"; // Set to your local MySQL password
   ```
4. *Smart Fallback:* If your MySQL service is temporarily stopped, the system automatically uses a local embedded database in MySQL mode so your presentation never fails during a viva!

---

## 🧪 Testing Walkthrough for Your College Presentation

1. **Test Owner / Admin Portal:**
   - Go to `http://localhost:8080/CarRentalSystem/login`.
   - Click **👑 Owner / Admin** (or enter `admin` / `admin123`).
   - You land on the **Admin Operations Dashboard** showing total fleet, available fleet, active rentals, total revenue.
   - Go to **Fleet Inventory** (`/cars`): Click **+ Add New Car**, fill details, and see the car added to inventory.
   - Go to **All Bookings** (`/rentals`): Click **Return Car** on an active rental, pick a delayed return date, watch the system automatically apply a 1.5x late penalty, and settle the invoice.
   - Click **Logout**.

2. **Test Customer Portal & Security:**
   - Go to `http://localhost:8080/CarRentalSystem/login`.
   - Click **🚗 Customer (Aarav)** (or enter `aarav` / `customer123`).
   - You land on the **Customer Portal Dashboard** with a personalized greeting ("Hello, Aarav Sharma!"), personal trip stats, and a clean vehicle catalog.
   - Click **Rent This Car** on any available vehicle: The booking form automatically locks in Aarav's name and driver's license. Pick dates to watch live price calculation, then submit.
   - Go to **My Bookings** (`/customer/bookings`): Notice you only see Aarav's personal bookings.
   - **Security Test:** In the browser URL bar, manually type `http://localhost:8080/CarRentalSystem/cars`. Press Enter. Notice that access is immediately blocked with **"Access Denied! You do not have permission to manage vehicle inventory."**!
