defmodule CcSpendingApi.Authentication.Application.Commands.LoginUser do
  @type t :: %__MODULE__{
          email: String.t(),
          password: String.t()
        }

  defstruct [:email, :password]

  # def new(attrs) do
  #   %__MODULE__{
  #     email: attrs[:email],
  #     password: attrs[:password]
  #   }
  # end

  defmodule Validator do
    use Ecto.Schema
    import Ecto.Changeset

    @derive {Jason.Encoder, only: [:email, :password]}

    @primary_key false
    embedded_schema do
      field :email, :string
      field :password, :string
    end

    def changeset(params) do
      %__MODULE__{}
      |> cast(params, [:email, :password])
      |> validate_required([:email, :password])
      |> validate_length(:email, min: 3, max: 255)
      |> validate_length(:password, min: 1)
      |> validate_format(:email, ~r/\S+@\S+\.\S+/, message: "must be a valid email")
    end
  end

  def new(params) do
    case Validator.changeset(params) do
      %Ecto.Changeset{valid?: true} = changeset ->
        validated_data = Ecto.Changeset.apply_changes(changeset)

        command = %__MODULE__{
          email: validated_data.email,
          password: validated_data.password
        }

        {:ok, command}

      %Ecto.Changeset{valid?: false} = changeset ->
        {:error, first_errors_by_field(changeset)}
    end
  end

  def first_error(changeset) do
    changeset.errors
  end

  def first_errors_by_field(changeset) do
    changeset.errors
    |> Enum.reduce(%{}, fn {field, error}, acc ->
      case Map.has_key?(acc, field) do
        # Skip if we already have an error for this field
        true -> acc
        false -> Map.put(acc, field, format_error(error))
      end
    end)
  end

  defp format_error({message, opts}) do
    Enum.reduce(opts, message, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  defp format_error(message) when is_binary(message), do: message
end
