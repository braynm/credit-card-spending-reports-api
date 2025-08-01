defmodule CcSpendingApiWeb.Guardian do
  use Guardian, otp_app: :cc_spending_api

  alias CcSpendingApi.Authentication.Infra.EctoUserRepository

  def subject_for_token(%{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    case EctoUserRepository.get_by_id(String.to_integer(id)) do
      {:ok, user} -> {:ok, user}
      {:error, _} -> {:error, :resource_not_found}
    end
  end

  def build_claims(claims, _user, opts) do
    # Add audience to claims for different client types
    audience = Keyword.get(opts, :audience, "web")
    expires_at = DateTime.add(DateTime.utc_now(), get_token_ttl(audience), :second)

    claims =
      claims
      |> Map.put("aud", audience)
      |> Map.put("exp", DateTime.to_unix(expires_at))

    {:ok, claims}
  end

  # 30 days for mobile
  defp get_token_ttl("mobile"), do: 30 * 24 * 3600
  # 7 days for web
  defp get_token_ttl("web"), do: 7 * 24 * 3600
  # 1 day default
  defp get_token_ttl(_), do: 24 * 3600

  def after_encode_and_sign(resource, claims, token, _options) do
    with {:ok, _} <- Guardian.DB.after_encode_and_sign(resource, claims["typ"], claims, token) do
      {:ok, token}
    end
  end

  def on_verify(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_verify(claims, token) do
      {:ok, claims}
    end
  end

  def on_refresh({old_token, old_claims}, {new_token, new_claims}, _options) do
    with {:ok, _, _} <- Guardian.DB.on_refresh({old_token, old_claims}, {new_token, new_claims}) do
      {:ok, {old_token, old_claims}, {new_token, new_claims}}
    end
  end

  def on_revoke(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_revoke(claims, token) do
      {:ok, claims}
    end
  end
end
