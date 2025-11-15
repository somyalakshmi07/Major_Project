function loginPage() {
    const mainContent = document.getElementById('main-content');
    
    if (auth.isAuthenticated()) {
        mainContent.innerHTML = '<div class="container"><div class="alert alert-info">You are already logged in</div></div>';
        return;
    }

    mainContent.innerHTML = `
        <div class="container">
            <h1>Login</h1>
            <form id="login-form" onsubmit="handleLogin(event)">
                <div class="form-group">
                    <label for="email">Email</label>
                    <input type="email" id="email" required>
                </div>
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" required>
                </div>
                <button type="submit">Login</button>
                <p style="margin-top: 1rem;">Don't have an account? <a href="#" onclick="loadPage('register')">Register</a></p>
            </form>
        </div>
    `;
}

async function handleLogin(event) {
    event.preventDefault();
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;

    try {
        await auth.login(email, password);
        showAlert('Login successful', 'success');
        loadPage('home');
        updateCartCount();
    } catch (error) {
        showAlert('Login failed: ' + error.message, 'error');
    }
}

