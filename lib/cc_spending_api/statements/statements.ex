defmodule CcSpendingApi.Statements do
  alias CcSpendingApi.Statements.Domain.ValueObjects.FileChecksum
  alias CcSpendingApi.Statements.Application.Services.FileProcessor

  def upload_and_save_transactions_from_attachment(params) do
    with {:ok, binary_file} <- FileProcessor.read_and_validate(params["file"]),
         {:ok, checksum} <- FileChecksum.new(binary_file) do
      {:ok, binary_file}
    end
  end
end
