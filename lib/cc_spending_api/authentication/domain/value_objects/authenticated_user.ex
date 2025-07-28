defmodule CcSpendingApi.Authentication.Domain.ValueObjects.AuthenticatedUser do
  alias CcSpendingApi.Shared.Result
  alias CcSpendingApi.Shared.Errors
  alias CcSpendingApi.Authentication.Domain.Entities.User

  @type t :: %__MODULE__{id: integer(), email: String.t()}
  defstruct [:id, :email]

  def new(%User{} = user) do
    %__MODULE__{
      id: user.id,
      email: user.email
    }
  end

  def to_string(%__MODULE__{email: value}), do: value
end
