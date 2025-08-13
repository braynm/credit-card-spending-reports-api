defmodule CcSpendingApiWeb.StatementsController do
  use CcSpendingApiWeb, :controller

  alias CcSpendingApi.Statements

  def list_txns(conn, params) do
    user = Guardian.Plug.current_resource(conn)

    # convert map to keyword list with atom keys 
    params = Enum.map(Map.to_list(params), fn {k, v} -> {String.to_atom(k), v} end)

    case Statements.list_user_transaction(user.id, params) do
      {:ok, %{metadata: metadata, entries: entries}} ->
        json(conn, %{
          success: true,
          metadata: Map.from_struct(metadata),
          entries: Enum.map(entries, &Map.from_struct/1)
        })

      {:error, :invalid_cursor} ->
        conn
        |> put_status(400)
        |> json(%{
          success: false,
          error: "Invalid paginated page"
        })
    end
  end

  def upload(conn, params) do
    user = Guardian.Plug.current_resource(conn)
    params = Map.put(params, "user_id", user.id)

    # TODO: Standardize structure of errors
    case Statements.upload_and_save_transactions_from_attachment(params) do
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

      {:error, :malformed_extracted_text} ->
        json(conn, %{error: "There is a problem parsing the .pdf statement"})

      {:error, error} ->
        json(conn, %{error: error})
    end
  end
end
