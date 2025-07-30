defmodule CcSpendingApi.Statements do
  alias CcSpendingApi.Statements.Domain.ValueObjects.FileChecksum
  alias CcSpendingApi.Statements.Application.Services.FileProcessor
  alias CcSpendingApi.Statements.Application.Services.DuplicateChecker

  def upload_and_save_transactions_from_attachment(params) do
    with {:ok, binary_file} <- FileProcessor.read_and_validate(params["file"]),
         {:ok, checksum} <- FileChecksum.new(binary_file),
         :ok <- DuplicateChecker.check_duplicate(11, checksum) do
      {:ok, checksum}
    end
  end
end
