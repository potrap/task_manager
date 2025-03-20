defmodule TaskManagerWeb.TasksLive do
  use TaskManagerWeb, :live_view
  alias TaskManager.Tasks
  alias TaskManagerWeb.Presence

  on_mount {TaskManagerWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      user_id = socket.assigns.current_user.id
      Presence.track(self(), "users", user_id, %{})
      Phoenix.PubSub.subscribe(TaskManager.PubSub, "users")
      Phoenix.PubSub.subscribe(TaskManager.PubSub, "tasks")
    end

    {:ok,
     assign(socket,
       tasks: Tasks.list_tasks_by_status("all"),
       form: to_form(Tasks.empty_changeset()),
       create_modal_is_open: false,
       update_modal_is_open: false,
       delete_modal_is_open: false,
       status_filter: "all",
       online_viewers_count: Presence.list("users") |> Enum.count()
     )}
  end

  @impl true
  def handle_event("validate_task", %{"task" => params}, socket) do
    {:noreply, assign(socket, form: validate_params(params, socket))}
  end

  def handle_event("open_create_modal", _params, socket) do
    {:noreply,
     assign(socket,
       create_modal_is_open: true,
       form: to_form(Tasks.empty_changeset())
     )}
  end

  def handle_event("close_create_modal", _params, socket) do
    {:noreply, assign(socket, create_modal_is_open: false)}
  end

  def handle_event("open_update_modal", %{"value" => id}, socket) do
    task = Tasks.get_task(id)

    form =
      Tasks.changeset(task)
      |> to_form()

    {:noreply,
     assign(socket,
       update_modal_is_open: true,
       selected_task: task,
       form: form
     )}
  end

  def handle_event("close_update_modal", _params, socket) do
    {:noreply,
     assign(socket,
       update_modal_is_open: false,
       selected_task: nil
     )}
  end

  def handle_event("update_task", %{"task" => params}, socket) do
    socket.assigns.selected_task.id
    |> Tasks.update_task(params)

    broadcast_task_update()
    socket = put_flash(socket, :info, "Task updated")

    {:noreply,
     assign(socket,
       update_modal_is_open: false,
       selected_task: nil
     )}
  end

  def handle_event("change_status", %{"value" => id}, socket) do
    task = Tasks.get_task(id)
    new_status = ("pending" != task.status && "pending") || "completed"

    Tasks.update_task(task.id, %{"status" => new_status})

    broadcast_task_update()

    {:noreply, socket}
  end

  def handle_event("create_task", %{"task" => params}, socket) do
    form = validate_params(params, socket)

    if form.source.valid? do
      user_id = socket.assigns.current_user.id

      Map.put(params, "user_id", user_id)
      |> Tasks.create_task()

      broadcast_task_update()
      socket = put_flash(socket, :info, "Task created")

      {:noreply,
       assign(socket,
         create_modal_is_open: false,
         form: Tasks.empty_changeset()
       )}
    else
      {:noreply, assign(socket, form: form)}
    end
  end

  def handle_event("open_delete_modal", %{"value" => id}, socket) do
    {:noreply,
     assign(socket,
       delete_modal_is_open: true,
       selected_task: Tasks.get_task(id)
     )}
  end

  def handle_event("close_delete_modal", _params, socket) do
    {:noreply,
     assign(socket,
       delete_modal_is_open: false,
       selected_task: nil
     )}
  end

  def handle_event("delete_task", _value, socket) do
    socket.assigns.selected_task
    |> Tasks.delete_task()

    broadcast_task_update()
    socket = put_flash(socket, :info, "Task deleted")

    {:noreply,
     assign(socket,
       delete_modal_is_open: false,
       selected_task: nil
     )}
  end

  def handle_event("filter_tasks", %{"status_filter" => status}, socket) do
    tasks = Tasks.list_tasks_by_status(status)

    {:noreply,
     assign(socket,
       status_filter: status,
       tasks: tasks
     )}
  end

  @impl true
  def handle_info(:tasks, socket) do
    tasks =
      socket.assigns.status_filter
      |> Tasks.list_tasks_by_status()

    {:noreply, assign(socket, tasks: tasks)}
  end

  @impl true
  def handle_info(%{event: "presence_diff"}, socket) do
    online_viewers_count = Presence.list("users") |> Enum.count()
    {:noreply, assign(socket, online_viewers_count: online_viewers_count)}
  end

  defp validate_params(params, socket) do
    user_id = socket.assigns.current_user.id

    Map.put(params, "user_id", user_id)
    |> Tasks.changeset()
    |> Map.put(:action, :insert)
    |> to_form()
  end

  defp broadcast_task_update do
    Phoenix.PubSub.broadcast(
      TaskManager.PubSub,
      "tasks",
      :tasks
    )
  end
end
