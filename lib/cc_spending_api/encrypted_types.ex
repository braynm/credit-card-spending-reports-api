defmodule CcSpendingApi.EncryptedTypes do
  @moduledoc """
  Custom Ecto types for encrypted fields
  """

  defmodule Binary do
    use Cloak.Ecto.Binary, vault: CcSpendingApi.Vault
  end

  defmodule Money do
    use Cloak.Ecto.Type, vault: CcSpendingApi.Vault

    def cast(value) when is_binary(value) do
      case Decimal.new(value) do
        %Decimal{} = decimal -> {:ok, decimal}
        _ -> :error
      end
    end

    def cast(%Decimal{} = value), do: {:ok, value}
    def cast(_), do: :error

    def dump(value) do
      case Decimal.to_string(value) do
        string when is_binary(string) -> {:ok, string}
        _ -> :error
      end
    end

    def load(value) do
      case Decimal.new(value) do
        %Decimal{} = decimal -> {:ok, decimal}
        _ -> :error
      end
    end
  end
end
