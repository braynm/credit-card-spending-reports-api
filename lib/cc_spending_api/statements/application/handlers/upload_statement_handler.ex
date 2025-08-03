defmodule CcSpendingApi.Statements.Application.Handlers.UploadStatementHandler do
  alias CcSpendingApi.Repo
  alias CcSpendingApi.Statements.Domain.CardStatementRepo
  alias CcSpendingApi.Statements.Domain.TransactionRepo
  alias CcSpendingApi.Statements.PdfExtractor
  alias CcSpendingApi.Statements.Infra.Parsers.RcbcParser
  alias CcSpendingApi.Statements.Domain.Services.FileProcessor
  alias CcSpendingApi.Statements.Domain.Services.DuplicateChecker
  alias CcSpendingApi.Statements.Domain.Services.SaveStatementService
  alias CcSpendingApi.Statements.Domain.ValueObjects.FileChecksum
  alias CcSpendingApi.Statements.Application.Commands.UploadStatementTransaction

  @type deps :: %{
          card_repository: CardStatementRepo.t(),
          txn_repository: TransactionRepo.t(),
          transaction_fn: function() | nil
        }

  def handle(%UploadStatementTransaction{} = command, deps) do
    transaction_fn = deps[:transaction_fn] || (&default_transaction/1)

    {:ok, txns} =
      transaction_fn.(fn ->
        with %Plug.Upload{path: tmp_path, filename: filename} <- command.file,
             {:ok, binary_file} <- FileProcessor.read_and_validate(command.file),
             {:ok, checksum} <- FileChecksum.new(binary_file),
             :ok <- DuplicateChecker.check_duplicate(command.user_id, checksum),
             {:ok, extracted_texts} <-
               PdfExtractor.extract_texts(tmp_path, command.pdf_pw),
             {:ok, extracted_txns} <- txn_parse(command.bank, extracted_texts),
             {:ok, {_, saved_txns}} <-
               save_statement_and_transaction(
                 extracted_txns,
                 command.user_id,
                 filename,
                 checksum
               ) do
          {:ok, saved_txns}
        end
      end)

    txns
  end

  defp save_statement_and_transaction(txns, user_id, filename, checksum) do
    SaveStatementService.save_statement_and_transaction(%{
      "filename" => filename,
      "file_checksum" => checksum,
      "user_id" => user_id,
      "txns" => txns
    })
  end

  defp txn_parse(bank, extracted_texts) do
    case bank do
      "rcbc" -> RcbcParser.parse(extracted_texts)
      _ -> {:error, :unsupported_bank}
    end
  end

  defp default_transaction(fun) do
    Repo.transaction(fun)
  end
end
