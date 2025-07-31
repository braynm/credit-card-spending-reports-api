defmodule CcSpendingApi.Statements do
  alias CcSpendingApi.Statements.PdfExtractor
  alias CcSpendingApi.Statements.Infra.Parsers.RcbcParser
  alias CcSpendingApi.Statements.Domain.ValueObjects.FileChecksum
  alias CcSpendingApi.Statements.Application.Services.FileProcessor
  alias CcSpendingApi.Statements.Application.Services.DuplicateChecker
  alias CcSpendingApi.Statements.Application.Services.SaveStatementService

  def upload_and_save_transactions_from_attachment(params) do
    with %Plug.Upload{path: tmp_path, filename: filename} <- params["file"],
         {:ok, binary_file} <- FileProcessor.read_and_validate(params["file"]),
         {:ok, checksum} <- FileChecksum.new(binary_file),
         :ok <- DuplicateChecker.check_duplicate(11, checksum),
         {:ok, extracted_texts} <-
           PdfExtractor.extract_texts(tmp_path, params["pdf_pw"]),
         # {:ok, txns} <- RcbcParser.parse(extracted_texts) do
         {:ok, txns} <- txn_parse(params["bank"], extracted_texts),
         {:ok, saved_statement} <-
           SaveStatementService.save_statement_and_transaction(%{
             "filename" => filename,
             "file_checksum" => checksum,
             "user_id" => params["user_id"]
           }) do
      {:ok, txns}
    end
  end

  defp txn_parse(bank, extracted_texts) do
    case bank do
      "rcbc" -> RcbcParser.parse(extracted_texts)
      _ -> {:error, :unsupported_bank}
    end
  end
end
