defmodule CcSpendingApiWeb.StatementsController do
  use CcSpendingApiWeb, :controller

  alias CcSpendingApi.Statements

  def upload(conn, params) do
    # TODO: Standardize structure of errors
    case Statements.upload_and_save_transactions_from_attachment(params) |> IO.inspect() do
      {:ok, data} ->
        json(conn, %{
          success: true,
          data: Enum.map(data, &Map.from_struct(&1))
        })

      {:error, {:invalid_file_type, _}} ->
        json(conn, %{error: "Please only upload .pdf files"})

      {:error, {:duplicate_statement, _}} ->
        json(conn, %{error: "Transactions already exists"})

      {:error, {:max_size, _}} ->
        json(conn, %{error: "File is too large"})

      {:error, ~c"Incorrect password"} ->
        json(conn, %{error: "Incorrect statement .pdf password"})

      {:error, error} ->
        json(conn, %{error: error})
    end
  end
end
