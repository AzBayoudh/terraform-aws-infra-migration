async function updateCounter() {
   
        const response = await fetch("https://pg6x3fakjymykbkgpydf7ngpoy0aajzp.lambda-url.us-east-1.on.aws/");
        const data = await response.text();
        document.getElementById("view-count").innerText = views;
}

updateCounter();

document.addEventListener("DOMContentLoaded", function () {
        const themeToggle = document.getElementById("theme-toggle");
        const body = document.body;
    
        // Check for saved theme in localStorage
        if (localStorage.getItem("theme") === "dark") {
            body.classList.add("dark-mode");
            themeToggle.textContent = "☀️"; // Change to sun icon
        }
    
        themeToggle.addEventListener("click", function () {
            body.classList.toggle("dark-mode");
            if (body.classList.contains("dark-mode")) {
                localStorage.setItem("theme", "dark");
                themeToggle.textContent = "☀️"; // Sun icon for light mode
            } else {
                localStorage.setItem("theme", "light");
                themeToggle.textContent = "🌙"; // Moon icon for dark mode
            }
        });
    });
