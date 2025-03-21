# TaskManager

Real-time Collaborative Task Management Application built with Phoenix LiveView

## Video presentation

link

### Step 1: Clone the Repository

Clone the repository to your local machine:


```git clone https://github.com/potrap/task_manager```

### Step 2: Navigate to the Project Directory

Move into the project folder:

```сd task_manager/```

### Step 3: Start Postgres with Docker

Run the following command to start a Redis container using Docker Compose:

```docker-compose up -d```

### Step 4: Setup

Setup application

```mix setup```

### Step 5: Start the Phoenix Server

Run the Phoenix server:

```mix phx.server```

### Step 6: Access the application

Open http://localhost:4000 in your browser


## ✅ Core Functionality:
- Real-time task updates across all users (no page reloads)
- CRUD operations for tasks with Phoenix LiveView
- Form validation for create and update task in modals
- Task status filtering (All/Pending/Completed)
- Responsive mobile-first UI with Tailwind CSS
- User presence tracking with Phoenix.Presence
- Interactive delete confirmation modal

## Project Structure

- ├── lib/
- │ ├── task_manager
- │ │
- │ └── task_manager_web/ 
- │ ├── live/ 
- │ │ └── tasks_live.ex # Main LiveView process
- │ │ └── tasks_live.html.heex # Real-time tasks UI template