defmodule CcSpendingApiWeb.StatementsController do
  use CcSpendingApiWeb, :controller
  alias CcSpendingApi.Statements.Application.Services.FileProcessor

  alias CcSpendingApi.Authentication
  alias CcSpendingApiWeb.Guardian

  def upload(conn, params) do
    case FileProcessor.read_and_validate(params["file"]) do
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
