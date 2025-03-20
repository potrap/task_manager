defmodule TaskManager.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias TaskManager.Repo
  alias TaskManager.Task

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks do
    Repo.all(Task)
    |> Repo.preload(:user)
    |> Enum.sort_by(& &1.id, :desc)
  end

  @doc """
  Returns the list of tasks filtered by status.

  ## Parameters
    - "all": returns all tasks
    - status: string representing task status ("pending", "in_progress", "done")

  ## Examples
      iex> list_tasks_by_status("pending")
      [%Task{status: "pending"}, ...]
  """
  def list_tasks_by_status("all"), do: list_tasks()

  def list_tasks_by_status(status) do
    Task
    |> where(status: ^status)
    |> Repo.all()
    |> Repo.preload(:user)
    |> Enum.sort_by(& &1.id, :desc)
  end

  @doc """
  Gets a single task by ID.

  Returns nil if the task does not exist.

  ## Examples
      iex> get_task(123)
      %Task{}
      iex> get_task(456)
      nil
  """
  def get_task(id), do: Repo.get(Task, id)

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a task.

  ## Examples
      iex> update_task(task.id, %{title: "New title"})
      {:ok, %Task{}}

      iex> update_task(-1, %{title: "New title"})
      {:error, :not_found}

      iex> update_task(task.id, %{title: nil})
      {:error, %Ecto.Changeset{}}
  """
  def update_task(id, attrs) do
    case get_task(id) do
      nil ->
        {:error, :not_found}

      task ->
        task
        |> Task.changeset(attrs)
        |> Repo.update()
    end
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Returns a task changeset for tracking changes.

  ## Examples
      iex> changeset(%Task{})
      %Ecto.Changeset{data: %Task{}}

      iex> changeset(%{title: "Task 1"})
      %Ecto.Changeset{data: %Task{}}
  """
  def changeset(%Task{} = task), do: Task.changeset(task, %{})
  def changeset(attrs), do: Task.changeset(%Task{}, attrs)

  @doc """
  Creates an empty task changeset with default values.

  ## Examples
      iex> empty_changeset()
      %Ecto.Changeset{
        data: %Task{},
        changes: %{
          title: "",
          description: "",
          status: "pending",
          user_id: 0
        }
      }
  """
  def empty_changeset() do
    %Task{}
    |> Ecto.Changeset.change(%{title: "", description: "", status: "pending", user_id: 0})
  end
end
