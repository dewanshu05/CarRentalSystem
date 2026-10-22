package com.carrental.controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.carrental.dao.CarDAO;
import com.carrental.model.Car;

/**
 * Controller: CarServlet
 * Endpoint: /cars
 * Handles all Car management CRUD requests.
 */
@WebServlet(name = "CarServlet", urlPatterns = {"/cars"})
public class CarServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private CarDAO carDAO;

    @Override
    public void init() {
        carDAO = new CarDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Security Check: Admin / Owner only
        if (!isAdmin(request, response)) return;

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "new":
                showNewForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteCar(request, response);
                break;
            case "list":
            default:
                listCars(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Security Check: Admin / Owner only
        if (!isAdmin(request, response)) return;

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "insert":
                insertCar(request, response);
                break;
            case "update":
                updateCar(request, response);
                break;
            default:
                listCars(request, response);
                break;
        }
    }

    private boolean isAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        javax.servlet.http.HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=" + 
                    URLEncoder.encode("Please log in with Owner credentials.", "UTF-8"));
            return false;
        }
        com.carrental.model.User user = (com.carrental.model.User) session.getAttribute("currentUser");
        if (!user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/customer/dashboard?error=" + 
                    URLEncoder.encode("Access Denied! You do not have permission to manage vehicle inventory.", "UTF-8"));
            return false;
        }
        return true;
    }

    // List all cars
    private void listCars(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Car> carList = carDAO.getAllCars();
        request.setAttribute("carList", carList);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/cars.jsp");
        dispatcher.forward(request, response);
    }

    // Show empty form for adding a car
    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RequestDispatcher dispatcher = request.getRequestDispatcher("/car-form.jsp");
        dispatcher.forward(request, response);
    }

    // Show form pre-populated with existing car data
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int carId = Integer.parseInt(request.getParameter("id"));
            Car existingCar = carDAO.getCarById(carId);
            if (existingCar != null) {
                request.setAttribute("car", existingCar);
                RequestDispatcher dispatcher = request.getRequestDispatcher("/car-form.jsp");
                dispatcher.forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/cars?error=" + URLEncoder.encode("Car not found", "UTF-8"));
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/cars?error=" + URLEncoder.encode("Invalid car ID", "UTF-8"));
        }
    }

    // Insert new car
    private void insertCar(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            String carModel = request.getParameter("carModel");
            String brand = request.getParameter("brand");
            String category = request.getParameter("category");
            String registrationNumber = request.getParameter("registrationNumber");
            double dailyRate = Double.parseDouble(request.getParameter("dailyRate"));
            String status = request.getParameter("status");
            int seatingCapacity = Integer.parseInt(request.getParameter("seatingCapacity"));
            String fuelType = request.getParameter("fuelType");

            Car newCar = new Car(carModel, brand, category, registrationNumber, dailyRate, status, seatingCapacity, fuelType);
            boolean success = carDAO.addCar(newCar);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/cars?msg=" + URLEncoder.encode("Car added successfully!", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/cars?error=" + URLEncoder.encode("Failed to add car. Registration number might already exist.", "UTF-8"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/cars?error=" + URLEncoder.encode("Error processing car data: " + e.getMessage(), "UTF-8"));
        }
    }

    // Update existing car
    private void updateCar(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int carId = Integer.parseInt(request.getParameter("carId"));
            String carModel = request.getParameter("carModel");
            String brand = request.getParameter("brand");
            String category = request.getParameter("category");
            String registrationNumber = request.getParameter("registrationNumber");
            double dailyRate = Double.parseDouble(request.getParameter("dailyRate"));
            String status = request.getParameter("status");
            int seatingCapacity = Integer.parseInt(request.getParameter("seatingCapacity"));
            String fuelType = request.getParameter("fuelType");

            Car car = new Car();
            car.setCarId(carId);
            car.setCarModel(carModel);
            car.setBrand(brand);
            car.setCategory(category);
            car.setRegistrationNumber(registrationNumber);
            car.setDailyRate(dailyRate);
            car.setStatus(status);
            car.setSeatingCapacity(seatingCapacity);
            car.setFuelType(fuelType);

            boolean success = carDAO.updateCar(car);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/cars?msg=" + URLEncoder.encode("Car updated successfully!", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/cars?error=" + URLEncoder.encode("Failed to update car.", "UTF-8"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/cars?error=" + URLEncoder.encode("Error updating car: " + e.getMessage(), "UTF-8"));
        }
    }

    // Delete car
    private void deleteCar(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int carId = Integer.parseInt(request.getParameter("id"));
            boolean success = carDAO.deleteCar(carId);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/cars?msg=" + URLEncoder.encode("Car deleted successfully!", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/cars?error=" + URLEncoder.encode("Cannot delete car! It is associated with existing rental history.", "UTF-8"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/cars?error=" + URLEncoder.encode("Invalid car ID for deletion.", "UTF-8"));
        }
    }
}
