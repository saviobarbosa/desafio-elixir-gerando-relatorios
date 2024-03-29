defmodule GenReport do
  alias GenReport.{Merger, Parser}

  def build(filename) do
    {:ok, result} =
      filename
      |> Parser.parse_file()

    Enum.reduce(result, initial_acc(), fn line, report ->
      organize_data(line, report)
    end)
  end

  defp organize_data(
         [name, hour, _day, month, year],
         %{
           :all_hours => all_hours,
           :hours_per_month => hours_per_month,
           :hours_per_year => hours_per_year
         }
       ) do
    all_hours = Merger.merge(all_hours, %{name => hour})

    hours_per_month = Merger.merge_two_levels(hours_per_month, %{name => %{month => hour}})

    hours_per_year = Merger.merge_two_levels(hours_per_year, %{name => %{year => hour}})

    %{"all_hours" => all_hours, "hours_per_month" => %{}, "hours_per_year" => %{}}

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp initial_acc() do
    build_report(%{}, %{}, %{})
  end

  defp build_report(all_hours, hours_per_month, hours_per_year) do
    %{
      :all_hours => all_hours,
      :hours_per_month => hours_per_month,
      :hours_per_year => hours_per_year
    }
  end
end
