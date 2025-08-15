defmodule CcSpendingApi.Utils.DateTimezone do
  @manila "Asia/Manila"

  # assumes all bank uses manila timezone
  def from_pdf(naive_datetime_iso8601) when is_binary(naive_datetime_iso8601) do
    naive_datetime_iso8601
    |> NaiveDateTime.from_iso8601!()
    |> DateTime.from_naive!(@manila)
    |> DateTime.shift_zone!("Etc/UTC")
  end
end
