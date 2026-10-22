# 🎓 Java Viva Voce Q&A Cheat Sheet
## 5th Semester B.Tech CSE — Car Rental Management System

---

### Q1: What is the Architecture of this Project?
**Answer:**
This project is built using the **MVC (Model-View-Controller)** design pattern:
- **Model:** Represents business logic and database entities (`Car.java`, `Customer.java`, `Rental.java`) and Data Access Objects (`CarDAO.java`, `CustomerDAO.java`, `RentalDAO.java`).
- **View:** User interface created using JavaServer Pages (`dashboard.jsp`, `cars.jsp`, `customers.jsp`, `rentals.jsp`, `book-car.jsp`, `return-car.jsp`), styled with responsive CSS and enhanced with JavaScript.
- **Controller:** Java Servlets (`DashboardServlet`, `CarServlet`, `CustomerServlet`, `RentalServlet`) that receive HTTP requests, process business logic via DAOs, update the Model, and forward results to the appropriate JSP view.

---

### Q2: What is JDBC and what are the 5 essential steps to connect to a Database?
**Answer:**
**JDBC (Java Database Connectivity)** is a Java API that enables Java programs to interact with relational databases.
The 5 standard steps:
1. **Load the JDBC Driver:** `Class.forName("com.mysql.cj.jdbc.Driver");`
2. **Establish the Connection:** `Connection conn = DriverManager.getConnection(url, user, password);`
3. **Create a Statement/PreparedStatement:** `PreparedStatement ps = conn.prepareStatement("SELECT * FROM cars WHERE car_id = ?");`
4. **Execute the Query:** `ResultSet rs = ps.executeQuery();` or `int rows = ps.executeUpdate();`
5. **Close Resources:** Close `ResultSet`, `Statement`, and `Connection` in a `finally` block or using try-with-resources.

---

### Q3: Why did you use `PreparedStatement` instead of `Statement`?
**Answer:**
1. **Prevents SQL Injection:** `PreparedStatement` uses parameter placeholders (`?`) where user inputs are safely escaped and treated strictly as literal values, never as executable SQL code.
2. **Better Performance:** The SQL query structure is pre-compiled and parsed by the database engine once, allowing repeated execution with different parameters efficiently.
3. **Strongly Typed Data Handling:** Offers type-safe setter methods like `ps.setInt()`, `ps.setString()`, `ps.setDate()`, and `ps.setDouble()`.

---

### Q4: Explain the Servlet Lifecycle.
**Answer:**
A Servlet's lifecycle is managed entirely by the Servlet Container (Apache Tomcat):
1. **Loading & Instantiation:** Container loads the servlet class and instantiates an object.
2. **Initialization (`init()` method):** Called **once** when the servlet is first loaded into memory. Used to initialize resources such as DAOs.
3. **Request Handling (`service()` -> `doGet()` / `doPost()`):** Called on **every request**. A new thread is allocated per request to handle the user's HTTP request.
4. **Destruction (`destroy()` method):** Called **once** when the container shuts down or the application is undeployed. Used to release open resources.

---

### Q5: What is the difference between `doGet()` and `doPost()` in your Servlets?
**Answer:**
- **`doGet()`:** Used for retrieving data from the server without modifying server state (e.g., viewing dashboard metrics, listing cars, showing the booking form). Parameters are sent in the URL query string.
- **`doPost()`:** Used for sending data to the server that modifies the database state (e.g., adding a car, registering a customer, booking a car, processing a vehicle return). Form data is passed in the HTTP request body, making it more secure and allowing large payloads.

---

### Q6: What is the difference between `RequestDispatcher.forward()` and `HttpServletResponse.sendRedirect()`?
**Answer:**
| Feature | `RequestDispatcher.forward()` | `HttpServletResponse.sendRedirect()` |
| :--- | :--- | :--- |
| **Execution** | Server-side transfer (internal) | Client-side transfer (2 round trips) |
| **URL in Browser** | Does not change (retains original URL) | Changes to the redirected target URL |
| **Request Scope Data** | Preserved (data set in `request.setAttribute` is accessible in the target JSP) | Lost (a completely new HTTP request is initiated by the browser) |
| **Usage in Project** | Used to forward data from Servlet to JSP (e.g. `carList` to `cars.jsp`) | Used after POST submissions (PRG pattern: Post-Redirect-Get) to avoid form re-submission on refresh |

---

### Q7: How did you implement Transaction Management (ACID) in your DAOs?
**Answer:**
In `RentalDAO.java`, both `bookCar()` and `returnCar()` require updating two tables simultaneously:
- When booking: insert a row into `rentals` AND update `cars` status to `'RENTED'`.
- When returning: update `rentals` (actual return date, charges, status) AND update `cars` status back to `'AVAILABLE'`.

To ensure **Atomicity** and **Consistency**:
```java
conn.setAutoCommit(false); // Disable auto-commit to begin transaction
// 1. Execute Rental SQL
// 2. Execute Car update SQL
conn.commit(); // Commit both operations together
```
If any error or exception occurs, `conn.rollback()` is invoked in the `catch` block so neither table is left in an inconsistent state.

---

### Q8: How does the Automatic Rental Charge and Late Fee calculation work?
**Answer:**
1. **On Booking:**
   - Duration is calculated: `days = (expectedReturnDate - rentalDate) in days`. Minimum charge is 1 day.
   - Initial Base Cost = `days * dailyRate`.
   - JavaScript also calculates this live on the client side for instant user feedback.
2. **On Return:**
   - The system checks if `actualReturnDate > expectedReturnDate`.
   - If delayed: `delayDays = actualReturnDate - expectedReturnDate`.
   - Late Fee Penalty = `delayDays * (dailyRateApplied * 1.5)` (a 50% penalty surcharge over the regular daily rate for overdue days).
   - Final Total Amount = `baseCost + lateFee`.

---

### Q9: How is Car Availability checked and enforced?
**Answer:**
1. The `cars` table has a `status` column (`'AVAILABLE'`, `'RENTED'`, `'MAINTENANCE'`).
2. `CarDAO.getAvailableCars()` executes `SELECT * FROM cars WHERE status = 'AVAILABLE'`.
3. In `book-car.jsp`, the car dropdown only populates cars returned by `getAvailableCars()`.
4. In `RentalServlet.processBooking()`, server-side validation verifies `car.isAvailable()` before executing the booking transaction to prevent double-booking.

---

### Q10: Why do Model classes implement `Serializable`?
**Answer:**
Implementing `java.io.Serializable` is a standard Java Bean convention. It allows Java objects (`Car`, `Customer`, `Rental`) to be converted into a byte stream. This is required if the objects are stored in an HTTP Session (`HttpSession`) that needs to be persisted to disk or replicated across clustered server nodes.

---

### Q11: What is `web.xml` and why is it needed?
**Answer:**
`web.xml` is the **Web Application Deployment Descriptor**. It configures:
1. Servlet registration (`<servlet>` and `<servlet-class>`).
2. URL mapping (`<servlet-mapping>` and `<url-pattern>`).
3. Default landing page (`<welcome-file-list>`).
4. Session timeout duration (`<session-timeout>`).

---

### Q12: What is the difference between `javax.servlet` and `jakarta.servlet`?
**Answer:**
- In Tomcat 9 and older (Java EE 8), servlets use the `javax.servlet.*` package.
- In Tomcat 10 and newer (Jakarta EE 9+), the namespace was renamed to `jakarta.servlet.*` after Oracle transferred Java EE to the Eclipse Foundation.
- Our project uses `javax.servlet`, which is the standard taught in university curricula and supported by Tomcat 8.5/9.0.
