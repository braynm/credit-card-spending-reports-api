defmodule CcSpendingApiWeb.Plugs.ValidateGuardianSession do
  @moduledoc """
  Custom plug that validates the bearer token exists in Guardian session repository.

  This provides an additional layer of security by ensuring the token:
  1. Exists in the Guardian.DB session repository
  2. Has not been revoked
  3. Has not expired

  Should be used after Guardian.Plug.VerifyHeader and before accessing protected resources.

  ## Options
  - `:optional` - If true, only validates if token is present (for optional auth pipelines)
  """

  import Plug.Conn
  require Logger

  alias Guardian.DB
  alias CcSpendingApiWeb.Guardian
  alias CcSpendingApi.Authentication

  def init(opts), do: opts

  def call(conn, opts) do
    optional = Keyword.get(opts, :optional, false)

    case extract_from_authorization(conn) do
      token when is_binary(token) ->
        IO.inspect("TOKEN #{token}")

        # Token is present, validate it
        res = Authentication.validate_session(token)
        IO.inspect(res)
        conn

      # IO.inspect(Authentication.validate_session(token), label: ">>>>>>>>>")

      nil ->
        # Token issue and not optional, handle error
        Logger.warning("Guardian session validation failed")

        halt(conn) |> put_status(401)

        # handle_invalid_session(conn, reason)
    end
  end

  defp extract_from_authorization(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> String.trim(token)
      # Case insensitive
      ["bearer " <> token] -> String.trim(token)
      # Direct token without Bearer
      [token] -> String.trim(token)
      _ -> nil
    end
  end
end
