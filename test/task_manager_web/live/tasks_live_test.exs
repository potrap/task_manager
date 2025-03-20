defmodule TaskManagerWeb.TasksLiveTest do
  use TaskManagerWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Phoenix.ConnTest
  alias TaskManager.Tasks
  alias TaskManager.TasksFixtures

  setup %{conn: conn} do
    {:ok, user} = AccountsFixtures.login()
    valid_attrs = TasksFixtures.valid_task_attributes()
    {:ok, task} = Tasks.create_task(valid_attrs)

    {:ok, conn: log_in_user(conn, user), user: user, task: task}
  end

  test "renders Tasks live page with correct content", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    assert html =~ "Create"
    assert html =~ "Delete"
    assert html =~ "Update"
    assert html =~ "Viewers"
  end

  test "open the create modal", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> element("button", "Create")
    |> render_click()

    assert render(view) =~ "Create new task"
    assert render(view) =~ "Close"
  end

  test "open the update modal", %{conn: conn, task: task} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> element("button[value=#{task.id}]", "Update")
    |> render_click()

    assert render(view) =~ "Close"
    assert render(view) =~ "Update task"
    assert render(view) =~ "Task"
    assert render(view) =~ "Test task description"
  end

  test "open the delete modal", %{conn: conn, task: task} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> element("button[value=#{task.id}]", "Delete")
    |> render_click()

    assert render(view) =~ "Close"
    assert render(view) =~ "Delete"
    assert render(view) =~ "Task"
    assert render(view) =~ "Are you sure that you want to delete task"
  end

  test "filters tasks by status", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> element("form[phx-change=filter_tasks]")
    |> render_change(%{"status_filter" => "completed"})

    refute has_element?(view, "td", "pending")

    view
    |> element("form[phx-change=filter_tasks]")
    |> render_change(%{"status_filter" => "pending"})

    refute has_element?(view, "td", "completed")
  end

  test "create a new task and show it on the page", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    form_attrs = %{
      "task[title]" => "New Task",
      "task[description]" => "New Test Description",
      "task[status]" => "pending"
    }

    view
    |> element("button", "Create")
    |> render_click()

    view
    |> form("#create-task-modal form", form_attrs)
    |> render_submit()

    assert render(view) =~ "New Task"
    assert render(view) =~ "New Test Description"
  end
end
