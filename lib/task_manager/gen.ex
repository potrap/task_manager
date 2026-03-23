defmodule Mongo.DateTimeGenerator do
  @moduledoc """
  Генерирует случайные даты:
  - Для частоты 24: от текущего времени до 18:00 текущего дня.
  - Для частоты 168: от текущего времени до 18:00 пятницы текущей недели.
  """

  @spec generate_random_datetime(24 | 168) :: DateTime.t()
  def generate_random_datetime(frequency) when frequency in [24, 168] do
    now = DateTime.utc_now()
    end_time = get_end_time(frequency, now)

    case DateTime.compare(now, end_time) do
      :gt ->
        end_time

      _ ->
        result = random_between(now, end_time)

        if frequency == 168 and not in_working_hours?(result) do
          generate_random_datetime(frequency)
        else
          result
        end
    end
  end

  defp get_end_time(24, now) do
    today = DateTime.to_date(now)
    DateTime.new!(today, ~T[18:00:00])
  end

  defp get_end_time(168, now) do
    current_date = DateTime.to_date(now)
    current_day = Date.day_of_week(current_date)
    current_time = DateTime.to_time(now)

    days_to_add =
      cond do
        current_day == 5 and Time.compare(current_time, ~T[18:00:00]) == :lt ->
          0
        current_day == 5 ->
          7
        true ->
          (5 - current_day + 7) |> rem(7)
      end

    next_friday = Date.add(current_date, days_to_add)
    DateTime.new!(next_friday, ~T[18:00:00])
  end

  defp random_between(start_time, end_time) do
    start_unix = DateTime.to_unix(start_time)
    end_unix = DateTime.to_unix(end_time)

    random_unix = Enum.random(start_unix..end_unix)
    DateTime.from_unix!(random_unix)
  end

  defp in_working_hours?(%DateTime{hour: hour}) do
    hour in 8..17
  end
end
