defmodule CcSpendingApi.CcSpendingApi.StatementsTest do
  use ExUnit.Case, async: true

  import Double

  alias CcSpendingApi.Repo
  alias CcSpendingApi.Statements
  alias CcSpendingApi.Test.Doubles

  alias CcSpendingApi.Shared.{Result, Errors}

  alias CcSpendingApi.Statements.Domain.Entities.Transaction
  alias CcSpendingApi.Statements.Application.Commands.UploadStatementTransaction
  alias CcSpendingApi.Statements.Domain.Services.StatementProcessingServices

  alias CcSpendingApi.Statements.PdfExtractor
  alias CcSpendingApi.Statements.Domain.Services.DuplicateChecker

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

      assert {:ok, list} =
               Statements.upload_and_save_transactions_from_attachment(
                 params,
                 Doubles.statement_process_double()
               )

      assert length(list) == 3

      assert [
               %Transaction{
                 sale_date: "2025-06-08",
                 posted_date: "2025-06-08",
                 details: "BONCHON MAKILING CALAMBA PH",
                 amount: "605.00"
               },
               %Transaction{
                 sale_date: "2025-06-13",
                 posted_date: "2026-06-16",
                 details: "MERCURYDRUGCORP1016 CALAMBA PH",
                 amount: "105.00"
               },
               %Transaction{
                 sale_date: "2025-06-13",
                 posted_date: "2026-06-16",
                 details: "GOLDILOCKS WATLERMART LAGUNA PH",
                 amount: "220.00"
               }
             ] = list
    end

    @tag :statements
    test "fails upload on invalid params" do
      params = %{}

      assert {:error,
              %{
                file: "PDF statement attachment is required",
                user_id: "can't be blank",
                bank: "can't be blank",
                pdf_pw: "can't be blank"
              }} =
               Statements.upload_and_save_transactions_from_attachment(
                 params,
                 Doubles.statement_process_double()
               )
    end

    @tag :statements
    test "fails upload on invalid file" do
      params = %{
        "bank" => "rcbc",
        "file" =>
          valid_upload_file()
          |> Map.put(:filename, "test.json"),
        "pdf_pw" => "123123",
        "user_id" => 11
      }

      assert {:error, %{file: "Unsupported file type. Supported files (.pdf)"}} =
               Statements.upload_and_save_transactions_from_attachment(
                 params,
                 Doubles.statement_process_double()
               )
    end

    @tag :statements
    test "fails upload on duplicate import statement" do
      params = %{
        "bank" => "rcbc",
        "file" => valid_upload_file(),
        "pdf_pw" => "123123",
        "user_id" => 11
      }

      assert {:error, {:duplicate_statement, card_id: "test"}} =
               Statements.upload_and_save_transactions_from_attachment(
                 params,
                 Doubles.statement_process_double(
                   duplicate_checker:
                     DuplicateChecker
                     |> stub(:check_duplicate, fn _, _ ->
                       {:error, {:duplicate_statement, card_id: "test"}}
                     end)
                 )
               )
    end

    @tag :statements
    test "fails upload on incorrect password" do
      params = %{
        "bank" => "rcbc",
        "file" => valid_upload_file(),
        "pdf_pw" => "123123",
        "user_id" => 11
      }

      assert {:error, ~c"Incorrect password"} =
               Statements.upload_and_save_transactions_from_attachment(
                 params,
                 Doubles.statement_process_double(
                   pdf_extractor:
                     PdfExtractor
                     |> stub(:extract_texts, fn _, _ ->
                       {:error, ~c"Incorrect password"}
                     end)
                 )
               )
    end
  end

  @tag :statements
  test "fails upload on malformed extracted_texts" do
    params = %{
      "bank" => "rcbc",
      "file" => valid_upload_file(),
      "pdf_pw" => "123123",
      "user_id" => 11
    }

    assert {:error, :malformed_extracted_text} =
             Statements.upload_and_save_transactions_from_attachment(
               params,
               Doubles.statement_process_double(
                 pdf_extractor:
                   PdfExtractor
                   |> stub(:extract_texts, fn _, _ ->
                     {:error, :malformed_extracted_text}
                   end)
               )
             )
  end

  defp valid_upload_file do
    %Plug.Upload{
      path: "/tmp/test.pdf",
      filename: "rcbc_statement_2024.pdf"
    }
    |> Map.put(:size, 4000)
  end
end
