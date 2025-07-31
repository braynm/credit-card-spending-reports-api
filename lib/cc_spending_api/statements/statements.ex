defmodule CcSpendingApi.Statements do
  alias CcSpendingApi.Statements.PdfExtractor
  alias CcSpendingApi.Statements.Infra.Parsers.RcbcParser
  alias CcSpendingApi.Statements.Domain.ValueObjects.FileChecksum
  alias CcSpendingApi.Statements.Application.Services.FileProcessor
  alias CcSpendingApi.Statements.Application.Services.DuplicateChecker

  def upload_and_save_transactions_from_attachment(params) do
    %Plug.Upload{path: tmp_path} = params["file"]

    # file = "/Users/brymadrid/Downloads/eStatement_VISA PLATINUM_JUL 01 2025_8006.pdf"

    with {:ok, binary_file} <- FileProcessor.read_and_validate(params["file"]),
         # with {:ok, binary_file} <- File.read(file),
         {:ok, checksum} <- FileChecksum.new(binary_file),
         :ok <- DuplicateChecker.check_duplicate(11, checksum),
         # PdfExtractor.extract_texts(tmp_path, params["pdf_pw"]) do
         {:ok, extracted_texts} <-
           PdfExtractor.extract_texts(tmp_path, params["pdf_pw"]),
         # {:ok, txns} <- RcbcParser.parse(extracted_texts) do
         {:ok, txns} <- txn_parse(params["bank"], extracted_texts) do
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
