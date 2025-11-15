class AuthService {
    constructor() {
        this.user = null;
        this.loadUser();
    }

    loadUser() {
        const token = localStorage.getItem('token');
        if (token) {
            api.setToken(token);
            this.getCurrentUser().catch(() => {
                this.logout();
            });
        }
    }

    async getCurrentUser() {
        try {
            this.user = await api.getCurrentUser();
            this.updateUI();
            return this.user;
        } catch (error) {
            this.user = null;
            this.updateUI();
            throw error;
        }
    }

    isAuthenticated() {
        return this.user !== null;
    }

    isAdmin() {
        return this.user && this.user.role === 'admin';
    }

    async login(email, password) {
        const response = await api.login(email, password);
        api.setToken(response.token);
        this.user = response.user;
        this.updateUI();
        return response;
    }

    async register(data) {
        const response = await api.register(data);
        api.setToken(response.token);
        this.user = response.user;
        this.updateUI();
        return response;
    }

    logout() {
        api.setToken(null);
        this.user = null;
        this.updateUI();
        window.location.hash = '#home';
    }

    updateUI() {
        const authLink = document.getElementById('auth-link');
        const logoutLink = document.getElementById('logout-link');
        const adminLink = document.getElementById('admin-link');

        if (this.isAuthenticated()) {
            if (authLink) authLink.style.display = 'none';
            if (logoutLink) logoutLink.style.display = 'block';
            if (adminLink && this.isAdmin()) {
                adminLink.style.display = 'block';
            }
        } else {
            if (authLink) authLink.style.display = 'block';
            if (logoutLink) logoutLink.style.display = 'none';
            if (adminLink) adminLink.style.display = 'none';
        }
    }
}

const auth = new AuthService();

