# Virtual Classroom

A comprehensive teaching tool designed to facilitate interactive learning during the pandemic and beyond. This platform connects Admins, Faculty, and Students in a seamless virtual environment.

## 🚀 Features

### 👨‍💼 Admin
-   **Dashboard**: Overview of system status.
-   **User Management**: Manage Student and Faculty records.
-   **Request Handling**: Approve or reject registration requests from Students and Faculty.

### 👩‍🏫 Faculty
-   **Dashboard**: Personalized workspace.
-   **Classroom Management**: Upload video lectures and study materials.
-   **Q/A Forum**: Answer student doubts and engage in discussions.

### 👨‍🎓 Student
-   **Dashboard**: Access to enrolled courses.
-   **Learning**: Watch video lectures and access study materials.
-   **Interaction**: Ask questions in the Q/A forum.

## 🛠️ Tech Stack

-   **Backend**: Java (JSP/Servlet), JDBC
-   **Frontend**: HTML, CSS, Bootstrap, JavaScript
-   **Database**: MySQL
-   **Containerization**: Docker, Docker Compose
-   **Server**: Apache Tomcat

## 🐳 Docker Deployment

Run the entire application stack with a single command:

1.  **Prerequisites**: Ensure [Docker Desktop](https://www.docker.com/products/docker-desktop) is installed.
2.  **Start the App**:
    ```bash
    docker-compose up --build
    ```
3.  **Access**: Open [http://localhost:8080/](http://localhost:8080/) in your browser.

> **Note**: The database is automatically initialized with the schema from `project_DB.sql` on the first run.

## 🔑 Default Credentials

-   **Admin Login**:
    -   *Security*: Password is verified against a SHA1 hash in the database.
    -   See `project_DB.sql` for initial data setup.
