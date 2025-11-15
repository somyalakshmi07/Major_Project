function registerPage() {
    const mainContent = document.getElementById('main-content');
    
    if (auth.isAuthenticated()) {
        mainContent.innerHTML = '<div class="container"><div class="alert alert-info">You are already logged in</div></div>';
        return;
    }

    mainContent.innerHTML = `
        <div class="container">
            <h1>Register</h1>
            <form id="register-form" onsubmit="handleRegister(event)">
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" required>
                </div>
                <div class="form-group">
                    <label for="email">Email</label>
                    <input type="email" id="email" required>
                </div>
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" required minlength="6">
                </div>
                <button type="submit">Register</button>
                <p style="margin-top: 1rem;">Already have an account? <a href="#" onclick="loadPage('login')">Login</a></p>
            </form>
        </div>
    `;
}

async function handleRegister(event) {
    event.preventDefault();
    const username = document.getElementById('username').value;
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;

    try {
        await auth.register({ username, email, password, role: 'user' });
        showAlert('Registration successful', 'success');
        loadPage('home');
        updateCartCount();
    } catch (error) {
        showAlert('Registration failed: ' + error.message, 'error');
    }
}

