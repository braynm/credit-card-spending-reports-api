defmodule CcSpendingApi.CcSpendingApi.Authentication.AuthenticationTest do
  use ExUnit.Case, async: true
  # use ExUnit.Case

  alias CcSpendingApi.Authentication
  alias CcSpendingApi.Test.Doubles

  import Double

  # setup do
  #   # Set to shared mode for this test
  #   Ecto.Adapters.SQL.Sandbox.mode(CcSpendingApi.Repo, {:shared, self()})
  #
  #   on_exit(fn ->
  #     Ecto.Adapters.SQL.Sandbox.mode(CcSpendingApi.Repo, :manual)
  #   end)
  #
  #   :ok
  # end

  @tag :authentication
  describe "register/4" do
    test "successfully registers user and returns session" do
      mock_transaction = fn fun ->
        case fun.() do
          {:ok, result} -> {:ok, result}
          {:error, _} = error -> error
        end
      end

      deps = %{
        user_repository: Doubles.user_repository_double(),
        session_repository: Doubles.session_repository_double(),
        transaction: fn _ -> {:ok, :hello} end
      }

      assert {:ok, %{user: user, session: session, token: token}} =
               Authentication.register("test@example.com", "password123", "web", deps)
    end
  end
end
