# Deploying to Render (Free Tier)

This guide walks you through deploying the Virtual Classroom application to Render's free tier. Since Render does not offer a free managed MySQL database, we will use a free external provider (like Aiven) for the database.

## Prerequisites

1.  A GitHub account (where this repo is pushed).
2.  A [Render](https://render.com/) account.
3.  A MySQL database provider account (we recommend [Aiven](https://aiven.io/) for their free tier).

---

## Step 1: Set up a Free MySQL Database

1.  **Sign up/Login** to [Aiven](https://aiven.io/).
2.  **Create a Service**:
    -   Select **MySQL**.
    -   Choose the **Free Plan** (e.g., Hobbyist).
    -   Select a cloud provider and region close to you.
    -   Click **Create Service**.
3.  **Get Connection Details**:
    -   Once the service is running, find the **Connection URI** (it looks like `mysql://user:password@host:port/defaultdb?ssl-mode=REQUIRED`).
    -   Note down the:
        -   **Host**
        -   **Port**
        -   **User**
        -   **Password**
        -   **Database Name** (usually named `defaultdb`, you can create a new one named `project` or just use the default).

---

## Step 2: Initialize the Database

Since the app needs specific tables, you must run the SQL script manually on your new database.

1.  Use a tool like **MySQL Workbench**, **DBeaver**, or the command line.
2.  Connect to your new Aiven database using the credentials from Step 1.
3.  Open the `project_DB.sql` file from this repository.
4.  **Important**: If your database name is different from `project`, edit the script:
    -   Remove `CREATE DATABASE project;`
    -   Remove `USE project;`
    -   Just run the `CREATE TABLE` and `INSERT` statements.
5.  Execute the script to create the `admin`, `student`, `faculty`, and `enroll_for` tables.

---

## Step 3: Deploy to Render

1.  **Login** to the [Render Dashboard](https://dashboard.render.com/).
2.  Click **New +** and select **Web Service**.
3.  **Connect GitHub**:
    -   Connect your GitHub account if you haven't already.
    -   Search for and select your **Virtual-Classroom-Master** repository.
4.  **Configure Service**:
    -   **Name**: Give it a name (e.g., `virtual-classroom`).
    -   **Region**: Choose one close to your database.
    -   **Branch**: `main`.
    -   **Runtime**: Select **Docker**.
    -   **Instance Type**: **Free**.
5.  **Environment Variables**:
    -   Scroll down to the "Environment Variables" section and add the following keys with the values from your Aiven database:

    | Key | Value |
    | :--- | :--- |
    | `DB_URL` | `jdbc:mysql://<HOST>:<PORT>/<DATABASE_NAME>?ssl-mode=REQUIRED` |
    | `DB_USER` | `<YOUR_DB_USER>` |
    | `DB_PASSWORD` | `<YOUR_DB_PASSWORD>` |

    > **Note**: Replace `<HOST>`, `<PORT>`, `<DATABASE_NAME>`, etc., with your actual values.
    > Example URL: `jdbc:mysql://mysql-folder-do-user-123.a.db.ondigitalocean.com:25060/defaultdb?ssl-mode=REQUIRED`

6.  **Deploy**:
    -   Click **Create Web Service**.
    -   Render will start building your Docker image. This might take a few minutes.

## Step 4: Access the Application

Once the deployment is live, Render will provide a URL (e.g., `https://virtual-classroom.onrender.com`).

1.  Click the link to open your app.
2.  Login with the default admin credentials (found in `project_DB.sql` or the ones you inserted).

## Troubleshooting

-   **Database Connection Error**: Check your Environment Variables. Ensure the `DB_URL` is correct and includes `?ssl-mode=REQUIRED` if your provider requires SSL (Aiven usually does).
-   **Build Failure**: Check the logs in the Render dashboard.
