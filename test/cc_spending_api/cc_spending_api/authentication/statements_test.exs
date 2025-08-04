defmodule CcSpendingApi.CcSpendingApi.StatementsTest do
  use ExUnit.Case, async: true

  alias CcSpendingApi.Repo
  alias CcSpendingApi.Statements
  alias CcSpendingApi.Test.Doubles

  alias CcSpendingApi.Shared.{Result, Errors}

  alias CcSpendingApi.Statements.Application.Commands.UploadStatementTransaction
  alias CcSpendingApi.Statements.Domain.Services.StatementProcessingServices

  setup _ do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  @tag :statements
  describe "Statements.upload_and_save_transactions_from_attachment/2" do
    @tag :statements
    test "successfully uploads and save transactions" do
      params = %{
        "bank" => "rcbc",
        "file" => valid_upload_file(),
        "pdf_pw" => "123123",
        "user_id" => 11
      }

      assert {:ok, _} =
               Statements.upload_and_save_transactions_from_attachment(
                 params,
                 Doubles.statement_process_double()
               )
    end
  end

  defp valid_upload_file do
    %Plug.Upload{
      path: "/tmp/test.pdf",
      filename: "rcbc_statement_2024.pdf"
    }
    |> Map.put(:size, 4000)
  end

  defp valid_command do
    UploadStatementTransaction.new(%{
      file: valid_upload_file(),
      bank: "rcbc",
      user_id: 11,
      pdf_pw: "valid_pw"
    })
  end
end
