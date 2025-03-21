defmodule TaskManager.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TaskManager.Tasks` context.
  """

  alias TaskManager.Tasks
  alias TaskManager.AccountsFixtures

  @valid_statuses ["pending", "completed"]

  def unique_task_title, do: "Task #{System.unique_integer()}"
  def valid_task_description, do: "Test task description"

  def valid_task_attributes(attrs \\ %{}) do
    user = attrs[:user] || AccountsFixtures.user_fixture()

    Enum.into(attrs, %{
      title: unique_task_title(),
      description: valid_task_description(),
      status: Enum.random(@valid_statuses),
      user_id: user.id
    })
  end

  def task_fixture(attrs \\ %{}) do
    attrs
    |> valid_task_attributes()
    |> then(fn attrs ->
      case attrs do
        %{user: user} -> %{attrs | user_id: user.id}
        _ -> attrs
      end
    end)
    |> then(&({:ok, _task} = Tasks.create_task(&1)))
    |> elem(1)
  end

  def task_list_fixture(count \\ 3) do
    user = AccountsFixtures.user_fixture()

    for _ <- 1..count do
      task_fixture(%{
        user_id: user.id,
        title: unique_task_title(),
        status: Enum.random(@valid_statuses)
      })
    end
  end
end
