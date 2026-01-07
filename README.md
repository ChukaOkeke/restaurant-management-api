**Restaurant Management API (AsgardCuisines)**  
A secure, containerized RESTful API for modern restaurant management, built with Django, MySQL, and Docker.

**Installation & Setup**  
Follow these steps to get the AsgardCuisines API running using Docker.

 1. Prerequisites
  - Docker Desktop (or Docker Engine on Linux)
  - Git

 2. Clone the Repository

```bash  
git clone https://github.com/ChukaOkeke/restaurant-api-docker.git
cd restaurant-api-docker  
```

 3. Environment Configuration  
 The project uses a .env file to manage sensitive database credentials  
  - Copy the template file:
```bash  
cp .env.example .env
```

  - Open .env and verify the settings:  
     DB_NAME=restaurant_db  
     DB_USER=asgard_admin  
     DB_PASSWORD=your_secure_password  
     MYSQL_ROOT_PASSWORD=your_super_secret_root_password  

 4. Launch the infrastructure  
 Build the custom API image and start the MySQL database in the background. 

 ```bash
 docker compose up -d --build
 ```

  Note: On the first run, the database initialization on WSL2 may take 3-5 minutes. The API service is configured to wait until the database is officially healthy before starting.  
  If the API service does not start alongside the database service, run:
 
 ```bash
 docker compose restart web
 ```

 5. Apply Database Migrations  
 Once the containers are running and healthy, create the necessary database tables:

 ```bash
 docker compose exec web python manage.py migrate
 ```

 6. Access the Application  
 The API will be available at http://127.0.0.1:8000/ or http://localhost:8000/.

**API Endpoints**  
The API supports the following endpoints for managing menu items and table bookings.

### API Endpoints

| **Method** | **Endpoint** | **Description** | **Authentication** |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/menu-items/` | List all menu items | Public |
| `POST` | `/api/menu-items/` | Create a new menu item | Admin Only |
| `GET` | `/api/menu-items/<id>/` | Get details of a specific item | Public |
| `PUT/PATCH` | `/api/menu-items/<id>/` | Update a menu item | Admin Only |
| `DELETE` | `/api/menu-items/<id>/` | Remove an item | Admin Only |
| `GET` | `/api/booking/tables/` | View all active bookings | Authenticated |
| `POST` | `/api/booking/tables/` | Create a new table reservation | Authenticated |
| `DELETE` | `/api/booking/tables/<id>/` | Cancel a reservation | Owner/Staff |
| `GET` | `/auth/users/` | List all registered users | Admin Only |
| `POST` | `/auth/users/` | Register a new user | Public |
| `POST` | `/auth/token/login` | Generate an auth token for session access | Public |
| `POST` | `/auth/users/logout` | Logout the user | Public |

**1. Requirement Analysis**  
 **Problem Statement**: Independent restaurants often struggle with fragmented data between front-of-house orders and back-of-house inventory.  
 **Solution**: This API centralizes the restaurant lifecycle -- from menu management to secure customer table reservations.  
  **Core Features**:
   - Role-based Access (Manager vs. Customer)
   - Menu management
   - Order booking

**2. Design & Architecture**  
 **High-Level System Architecture**  

 ![System Architecture](./assets/architecture-diagram.png)  
 
 AsgardCuisines utilizes a decoupled architecture to ensure independent scalability of the data and application layers
 - Frontend: Interacts with the backend via RESTful endpoints.
 - Application Layer: Managed by Django, handling business logic and request routing.
 - Data Persistence: A MySQL instance ensures ACID-compliant transactions for all menu and booking data.
 - Communication: The Client interacts with the Django application via stateless HTTPS requests, exchanging data in JSON format to ensure compatibility with modern frontend frameworks.
 - Abstraction: The Django ORM is utilized to abstract complex MySQL queries into Pythonic code, ensuring rapid development without sacrificing the data integrity of a relational database.

 **Database Schema (ERD)**  

 ![AsgardCuisines ERD](./assets/database-erd.png)
   - Key Entities: MenuItem, Booking.

**3. Implementation**  
 This phase focused on building a modular, scalable codebase.
  - Technology Choice: Chose Django for its robustness and security as a python-based web framework. Chose MySQL for its ACID compliance, ensuring that order transactions are never lost or duplicated.
  - Logic Highlights: Used Django Rest Framework (DRF) to create APIs for Menu and Booking. Used DRF's djoser library to easily implement token authentication for user registration, login, and logout.

**4. Testing & Quality Assurance**  
 Quality was ensured through a comprehensive testing suite:
  - Unit Tests: Validating individual model methods, views, and serializers.
  - Integration Tests: End-to-end testing of API endpoints using the Insomnia REST client. 
  - Execution:

 ```bash
 pip install -r requirements-dev.txt && python3 manage.py test
 ```

**5. Security**  
 Security was integrated into the development pipeline at several layers rather than added as an afterthought to protect against common web vulnerabilities:
 - Authentication & Authorization: Secured via **JWT (JSON Web Tokens)** for stateless, scalable session management. Used granular permissions to ensure only authorized users can interact with the table booking API. 
 - **Static Application Security Testing (SAST)**: Audited using Bandit to identify common Python security vulnerabilities (e.g., SQL injection risks, weak cryptography).  
  Run Audit:

 ```bash
 pip install -r requirements-dev.txt && bandit -c pyproject.toml -r .
 ```
Bandit results:  
![Bandit results](./assets/bandit-result.png)

 - Protection Against SQL Injection:  
   Django ORM: We avoid writing raw SQL queries. By using Django's Object-Relational Mapper (ORM), all input is automatically parameterized.  
   Input Validation: All data entering the API is validated through Django Rest Framework Serializers, ensuring only the expected data types (integers for prices, strings for names) reach the database.
 - Cross-Site Scripting (XSS) Defense:  
   Automatic Escaping: Django's template engine (used for the home page) automatically escapes HTML-sensitive characters like < and >, preventing malicious scripts from being executed in the browser.  
   Content Type Enforcement: The API strictly communicates via application/json. Browsers do not execute JSON as HTML/JavaScript, which significantly reduces the XSS attack surface.
 - Cross-Site Request Forgery (CSRF) Defense:  
   Token-Based Authentication: Because this API uses Token Authentication rather than cookies/sessions, it is inherently resistant to CSRF attacks. Since the browser does not automatically send the token (unlike a cookie), an attacker cannot trick a user's browser into making an unauthorized request to our API.  
   Requirement of Authorization Header: Every sensitive request requires a valid Authorization: Token <key> header, which must be manually included by the client application.
 - Secure Environment Management: Sensitive keys (Database passwords, Django SECRET_KEY) are never stored in the source code. They are managed via .env files and excluded from version control using .gitignore.

**6. Containerization**  
Docker/Docker Compose was used for the single-host multi-environment containerization (Django API in one container, MySQL database in another) and orchestration. The official MySQL image was pulled from DockerHub, and the API image was subsequently built successfully.  
I encountered a timing and networking issue during the multi-container orchestration using Docker Compose. MySQL 8.0 on WSL2 takes some time (~ 3 mins) to initialize its internal system files on first run. So, the database service kept being declared 'unhealthy' by Docker, and refused to start and establish connection with the API service. To resolve this, I added a 'healthcheck' attribute for the database service in the compose.yaml file

**Tech Stack**
 - Backend: **Python / Django**
 - Database: **MySQL** 
 - Containerization: **Docker / Docker Compose**
 - Security: **Bandit / JWT**
 - API Tools: **Insomnia**


