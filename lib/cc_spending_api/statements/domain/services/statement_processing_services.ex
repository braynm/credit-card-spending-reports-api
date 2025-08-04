defmodule CcSpendingApi.Statements.Domain.Services.StatementProcessingServices do
  alias CcSpendingApi.Statements.PdfExtractor
  alias CcSpendingApi.Statements.Infra.EctoTransactionRepository
  alias CcSpendingApi.Statements.Infra.EctoTransactionMetaRepository
  alias CcSpendingApi.Statements.Domain.Services.DuplicateChecker
  alias CcSpendingApi.Statements.Domain.Services.SaveStatementService

  defstruct [
    :duplicate_checker,
    :pdf_extractor,
    :save_statement_service,
    :txn_repository,
    :txn_meta_repository,
    :transaction_fn
  ]

  def default do
    %__MODULE__{
      pdf_extractor: PdfExtractor,
      duplicate_checker: DuplicateChecker,
      save_statement_service: SaveStatementService,
      txn_repository: EctoTransactionRepository,
      txn_meta_repository: EctoTransactionMetaRepository,
      transaction_fn: nil
    }
  end
end
