defmodule TaskManager.TasksTest do
  use TaskManager.DataCase

  alias TaskManager.Tasks
  alias TaskManager.TasksFixtures
  alias TaskManager.AccountsFixtures

  describe "list_tasks" do
    test "returns all tasks ordered by updated_at desc" do
      TasksFixtures.task_fixture(%{id: 1, updated_at: ~U[2025-01-01 00:00:00Z]})
      task2 = TasksFixtures.task_fixture(%{id: 2, updated_at: ~U[2025-01-02 00:00:00Z]})

      [first_task | _] = Tasks.list_tasks()

      assert first_task.id == task2.id
    end
  end

  describe "list_tasks_by_status/1" do
    test "with 'all' returns all tasks" do
      TasksFixtures.task_fixture(%{status: "pending"})
      TasksFixtures.task_fixture(%{status: "completed"})

      assert tasks = Tasks.list_tasks_by_status("all")
      assert length(tasks) == 2
    end

    test "filters tasks by status" do
      completed_task = TasksFixtures.task_fixture(%{status: "completed"})

      assert [found] = Tasks.list_tasks_by_status("completed")
      assert found.id == completed_task.id
    end
  end

  describe "create_task/1" do
    test "with valid data creates a task" do
      valid_attrs = TasksFixtures.valid_task_attributes()

      assert {:ok, %TaskManager.Task{} = task} = Tasks.create_task(valid_attrs)
      assert String.contains?(task.title, "Task")
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_task(%{title: nil})
    end
  end

  describe "get_task/1" do
    test "returns task with given id" do
      task = TasksFixtures.task_fixture()
      result = Tasks.get_task(task.id)
      assert result.id == task.id
    end

    test "returns nil for non-existent id" do
      refute Tasks.get_task(-1)
    end
  end

  describe "update_task/2" do
    setup do
      task = TasksFixtures.task_fixture(%{title: "Original"})
      %{task: task}
    end

    test "with valid data updates the task", %{task: task} do
      assert {:ok, updated} = Tasks.update_task(task.id, %{title: "Updated"})
      assert updated.title == "Updated"
    end

    test "with invalid data returns error changeset", %{task: task} do
      assert {:error, %Ecto.Changeset{}} = Tasks.update_task(task.id, %{title: nil})
      assert "Original" == Tasks.get_task(task.id).title
    end

    test "returns not_found error for invalid id" do
      assert {:error, :not_found} = Tasks.update_task(-1, %{title: "New"})
    end
  end

  describe "delete_task/1" do
    test "deletes the task" do
      task = TasksFixtures.task_fixture()
      assert {:ok, _} = Tasks.delete_task(task)
      refute Tasks.get_task(task.id)
    end
  end

  describe "changeset" do
    test "returns a valid changeset for existing task" do
      task = TasksFixtures.task_fixture()
      changeset = Tasks.changeset(task)
      assert %Ecto.Changeset{} = changeset
      assert changeset.valid?
    end

    test "returns valid changeset for new task" do
      attrs = TasksFixtures.valid_task_attributes()
      changeset = Tasks.changeset(attrs)
      assert %Ecto.Changeset{} = changeset
      assert changeset.valid?
    end
  end

  describe "empty_changeset/0" do
    test "returns changeset with default values" do
      cs = Tasks.empty_changeset()

      assert cs.changes == %{
               title: "",
               description: "",
               user_id: 0
             }
    end
  end

  describe "validation" do
    test "rejects short titles" do
      attrs = TasksFixtures.valid_task_attributes(%{title: "ab"})
      {:error, changeset} = Tasks.create_task(attrs)
      assert "should be at least 3 character(s)" in errors_on(changeset).title
    end

    test "rejects invalid status" do
      attrs = TasksFixtures.valid_task_attributes(%{status: "invalid"})
      {:error, changeset} = Tasks.create_task(attrs)
      assert "is invalid" in errors_on(changeset).status
    end
  end
end
