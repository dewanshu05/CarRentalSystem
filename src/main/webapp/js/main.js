/**
 * Car Rental Management System - Frontend JavaScript
 * Provides real-time pricing calculations, search filtering, and UI helpers.
 */

document.addEventListener("DOMContentLoaded", function () {
    // 1. Initialize Auto Dismiss for Alerts
    const alerts = document.querySelectorAll(".alert");
    alerts.forEach(function (alert) {
        setTimeout(function () {
            alert.style.transition = "opacity 0.5s ease";
            alert.style.opacity = "0";
            setTimeout(function () { alert.remove(); }, 500);
        }, 5000);
    });

    // 2. Initialize Booking Real-Time Price Calculator
    setupBookingCalculator();

    // 3. Initialize Return & Late Fee Calculator
    setupReturnCalculator();

    // 4. Initialize Client-Side Table Search
    setupTableSearch("carSearchInput", "carsTable");
    setupTableSearch("customerSearchInput", "customersTable");
    setupTableSearch("rentalSearchInput", "rentalsTable");
});

/**
 * Live Price Calculation on Car Booking Form
 */
function setupBookingCalculator() {
    const carSelect = document.getElementById("carSelect");
    const rentalDateInput = document.getElementById("rentalDate");
    const returnDateInput = document.getElementById("expectedReturnDate");

    const calcDailyRateEl = document.getElementById("calcDailyRate");
    const calcDaysEl = document.getElementById("calcDays");
    const calcTotalCostEl = document.getElementById("calcTotalCost");

    if (!carSelect || !rentalDateInput || !returnDateInput) return;

    function recalculate() {
        const selectedOption = carSelect.options[carSelect.selectedIndex];
        const dailyRate = selectedOption ? parseFloat(selectedOption.getAttribute("data-rate")) || 0 : 0;

        const rentalDateVal = rentalDateInput.value;
        const returnDateVal = returnDateInput.value;

        let days = 1;

        if (rentalDateVal && returnDateVal) {
            const start = new Date(rentalDateVal);
            const end = new Date(returnDateVal);

            if (end >= start) {
                const diffTime = Math.abs(end - start);
                const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                days = diffDays === 0 ? 1 : diffDays;
            } else {
                days = 0;
            }
        }

        const totalCost = days * dailyRate;

        if (calcDailyRateEl) calcDailyRateEl.textContent = "₹" + dailyRate.toFixed(2);
        if (calcDaysEl) calcDaysEl.textContent = days + (days === 1 ? " Day" : " Days");
        if (calcTotalCostEl) calcTotalCostEl.textContent = "₹" + totalCost.toFixed(2);
    }

    carSelect.addEventListener("change", recalculate);
    rentalDateInput.addEventListener("change", recalculate);
    returnDateInput.addEventListener("change", recalculate);

    // Initial calculation on load
    recalculate();
}

/**
 * Live Late Fee and Final Bill Calculation on Return Form
 */
function setupReturnCalculator() {
    const actualReturnDateInput = document.getElementById("actualReturnDate");
    const expectedReturnDateEl = document.getElementById("expectedReturnDateHidden");
    const dailyRateEl = document.getElementById("dailyRateHidden");
    const baseCostEl = document.getElementById("baseCostHidden");

    const calcDelayDaysEl = document.getElementById("calcDelayDays");
    const calcLateFeeEl = document.getElementById("calcLateFee");
    const calcFinalTotalEl = document.getElementById("calcFinalTotal");

    if (!actualReturnDateInput || !expectedReturnDateEl || !dailyRateEl || !baseCostEl) return;

    const expectedDate = new Date(expectedReturnDateEl.value);
    const dailyRate = parseFloat(dailyRateEl.value) || 0;
    const baseCost = parseFloat(baseCostEl.value) || 0;

    function recalculateReturn() {
        const actualDateVal = actualReturnDateInput.value;
        if (!actualDateVal) return;

        const actualDate = new Date(actualDateVal);
        let lateDays = 0;

        if (actualDate > expectedDate) {
            const diffTime = actualDate - expectedDate;
            lateDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        }

        // Penalty is 1.5x daily rate per delayed day
        const lateFee = lateDays * (dailyRate * 1.5);
        const finalTotal = baseCost + lateFee;

        if (calcDelayDaysEl) {
            calcDelayDaysEl.textContent = lateDays > 0 ? lateDays + " Days Late" : "On Time (0 Days)";
            calcDelayDaysEl.style.color = lateDays > 0 ? "#dc2626" : "#059669";
        }
        if (calcLateFeeEl) calcLateFeeEl.textContent = "₹" + lateFee.toFixed(2);
        if (calcFinalTotalEl) calcFinalTotalEl.textContent = "₹" + finalTotal.toFixed(2);
    }

    actualReturnDateInput.addEventListener("change", recalculateReturn);
    recalculateReturn();
}

/**
 * Instant Client-Side Table Search / Filter
 */
function setupTableSearch(inputId, tableId) {
    const searchInput = document.getElementById(inputId);
    const table = document.getElementById(tableId);

    if (!searchInput || !table) return;

    searchInput.addEventListener("input", function () {
        const filter = searchInput.value.toLowerCase().trim();
        const rows = table.getElementsByTagName("tbody")[0].getElementsByTagName("tr");

        for (let i = 0; i < rows.length; i++) {
            const text = rows[i].textContent.toLowerCase();
            if (text.indexOf(filter) > -1) {
                rows[i].style.display = "";
            } else {
                rows[i].style.display = "none";
            }
        }
    });
}

/**
 * Confirm deletion dialog helper
 */
function confirmDelete(itemType) {
    return confirm("Are you sure you want to delete this " + itemType + "? This action cannot be undone.");
}
