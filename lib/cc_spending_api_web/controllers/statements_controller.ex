defmodule CcSpendingApiWeb.StatementsController do
  use CcSpendingApiWeb, :controller

  alias CcSpendingApi.Statements

  def upload(conn, params) do
    case Statements.upload_and_save_transactions_from_attachment(params) do
      {:error, {:invalid_file_type, _}} ->
        json(conn, %{
          error: "Please only upload .pdf files"
        })

      {:error, {:max_size, _}} ->
        json(conn, %{
          error: "File is too large"
        })

      {:ok, _} ->
        json(conn, %{
          success: true
        })
    end
  end
end
