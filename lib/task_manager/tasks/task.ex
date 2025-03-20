defmodule TaskManager.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :title, :string
    field :description, :string
    field :status, :string, default: "pending"

    belongs_to(:user, TaskManager.Accounts.User)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :status, :user_id])
    |> validate_required([:title, :description, :status, :user_id])
    |> validate_inclusion(:status, ["pending", "completed"])
    |> validate_length(:title, min: 3, max: 50)
    |> validate_length(:description, min: 4, max: 50)
    |> foreign_key_constraint(:user_id)
  end
end
