**Restaurant Management API (AsgardCuisines)**  
A robust RESTful API for modern restaurant management, built with Django and MySQL.

**Installation & Setup**  
Follow these steps to get the Restaurant Management API running on your local machine.

 1. Prerequisites
  - Python 3.12+
  - MySQL Server
  - Git

 2. Clone the Repository

```bash  
git clone https://github.com/ChukaOkeke/restaurant-management-api.git
cd restaurant-management-api  
```

 3. Set up Virtual Environment  
 It is recommended to use a virtual environment to manage dependencies

 ```bash
 # Create venv
 python3 -m venv venv

 # Activate venv (Linux)
 source venv/bin/activate
 ```

 4. Install Dependencies  
 Ensure your virtual environment is active before running this:

 ```bash
 pip install -r requirements.txt
 ```

 5. Environment Configuration  
 The project uses python-dotenv to manage sensitive information.  

  - Copy the template file:

 ```bash
 cp .env.example .env
 ```
  - Open .env and fill in your specific details:  
    SECRET_KEY: Your Django secret key.  
    DB_NAME: AsgardCuisines  
    DB_USER: Your MySQL username (usually root).  
    DB_PASSWORD: Your MySQL password.

 6. Database Initialization  
 Before running migrations, create the database in your MySQL terminal:

 ```sql
 CREATE DATABASE AsgardCuisines;
 ```

 Now apply the migrations to set up your tables:

 ```bash
 python3 manage.py migrate
 ```

 7. Run the Application

 ```bash
 python3 manage.py runserver
 ```

 The API will be available at http://127.0.0.1:8000/.

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
 python3 manage.py test
 ```

**5. Security**  
 Security was integrated into the development pipeline at several layers rather than added as an afterthought to protect against common web vulnerabilities:
 - Authentication & Authorization: Secured via **JWT (JSON Web Tokens)** for stateless, scalable session management. Used granular permissions to ensure only authorized users can interact with the table booking API. 
 - **Static Application Security Testing (SAST)**: Audited using Bandit to identify common Python security vulnerabilities (e.g., SQL injection risks, weak cryptography).  
  Run Audit:

 ```bash
 bandit -c pyproject.toml -r .
 ```

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

**Tech Stack**
 - Language: **Python**
 - Framework: **Django / Django REST Framework**
 - Database: **MySQL** 
 - Security Tools: **Bandit, JWT**

