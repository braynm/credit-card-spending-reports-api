defmodule CcSpendingApi.Statements do
  alias CcSpendingApi.Statements.PdfExtractor
  alias CcSpendingApi.Statements.Infra.Parsers.RcbcParser
  alias CcSpendingApi.Statements.Domain.ValueObjects.FileChecksum
  alias CcSpendingApi.Statements.Application.Services.FileProcessor
  alias CcSpendingApi.Statements.Application.Services.DuplicateChecker

  def upload_and_save_transactions_from_attachment(params) do
    # %Plug.Upload{path: tmp_path} = params["file"]

    # with {:ok, binary_file} <- FileProcessor.read_and_validate(params["file"]),
    file = "/Users/brymadrid/Downloads/eStatement_VISA PLATINUM_JUL 01 2025_8006.pdf"

    with {:ok, binary_file} <- File.read(file),
         {:ok, checksum} <- FileChecksum.new(binary_file),
         :ok <- DuplicateChecker.check_duplicate(11, checksum),
         {:ok, extracted_texts} <-
           PdfExtractor.extract_texts(file, params["pdf_pw"]) do
      # {:ok, items} <- RcbcParser.parse(extracted_texts) do
      IO.inspect(extracted_texts, limit: :infinity)
      {:ok, extracted_texts}
    end
  end
end
