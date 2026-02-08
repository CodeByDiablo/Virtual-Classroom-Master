# Virtual-Classroom

Teaching tool to assist each and every student to learn in an interactive manner in today’s situation of a pandemic.

## Docker Deployment

This application is containerized using Docker and can be easily run with Docker Compose.

### Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop) installed on your machine.

### How to Run

1.  Open a terminal in the project root directory.
2.  Run the following command to build and start the services:

    ```bash
    docker-compose up --build
    ```

3.  Wait for the containers to start. The `app` container will wait for the `db` container to be ready.
4.  Access the application at: [http://localhost:8080/](http://localhost:8080/)

### Configuration

The database configuration is handled via environment variables in the `docker-compose.yml` file:

-   `DB_URL`: JDBC URL for the MySQL database.
-   `DB_USER`: Database username.
-   `DB_PASSWORD`: Database password.

### Database Initialization

The `project_DB.sql` file is automatically imported into the MySQL database on the first run.
