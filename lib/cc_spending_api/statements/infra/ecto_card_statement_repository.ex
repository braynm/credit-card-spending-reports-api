defmodule CcSpendingApi.Statements.Infra.EctoCardStatementRepository do
  @behaviour CcSpendingApi.Statements.Domain.CardStatementRepo

  import Ecto.Query
  alias CcSpendingApi.Repo
  alias CcSpendingApi.Statements.Infra.Schemas.CardStatement

  def find_by_checksum(user_id, checksum) do
    query =
      from(q in CardStatement,
        where: q.user_id == ^user_id and
            q.file_checksum == ^checksum
      )

    Repo.one(query)
  end
end
