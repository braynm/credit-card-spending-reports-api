defmodule CcSpendingApi.Repo do
  use Ecto.Repo,
    otp_app: :cc_spending_api,
    adapter: Ecto.Adapters.Postgres
end
