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
  alias CcSpendingApi.Statements.Domain.Services.StatementProcessingServices
  alias CcSpendingApi.Statements.Application.Commands.UploadStatementTransaction

  # @type deps :: %{
  #         card_repository: CardStatementRepo.t(),
  #         txn_repository: TransactionRepo.t(),
  #         transaction_fn: function() | nil
  #       }

  def handle(%UploadStatementTransaction{} = command, deps) do
    %StatementProcessingServices{
      duplicate_checker: duplicate_checker,
      pdf_extractor: pdf_extractor,
      save_statement_service: save_statement_service,
      txn_repository: txn_repository,
      txn_meta_repository: txn_meta_repository,
      transaction_fn: transaction_fn
    } = deps

    transaction_fn = transaction_fn || (&default_transaction/1)

    result =
      transaction_fn.(fn repo ->
        with %Plug.Upload{path: tmp_path, filename: filename} <- command.file,
             {:ok, binary_file} <- FileProcessor.read_and_validate(command.file),
             {:ok, checksum} <- FileChecksum.new(binary_file),
             :ok <- duplicate_checker.check_duplicate(command.user_id, checksum),
             {:ok, extracted_texts} <-
               pdf_extractor.extract_texts(tmp_path, command.pdf_pw),
             {:ok, extracted_txns} <- txn_parse(command.bank, extracted_texts),
             {:ok, saved_txns} <-
               save_statement_and_transaction(
                 save_statement_service,
                 extracted_txns,
                 command.user_id,
                 filename,
                 checksum
               ) do
          saved_txns
        else
          {:error, error} ->
            # something went wrong. Lets rollback.
            repo.rollback(error)
        end
      end)

    case result do
      {:ok, txns} -> {:ok, txns}
      {:error, error} -> {:error, error}
    end
  end

  defp save_statement_and_transaction(save_stmnt_service, txns, user_id, filename, checksum) do
    save_stmnt_service.save_statement_and_transaction(%{
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
