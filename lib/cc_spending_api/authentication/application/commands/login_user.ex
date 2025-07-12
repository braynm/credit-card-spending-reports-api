defmodule CcSpendingApi.Authentication.Application.Commands.LoginUser do
  @type t :: %__MODULE__{
          email: String.t(),
          password: String.t()
        }

  defstruct [:email, :password]

  def new(attrs) do
    %__MODULE__{
      email: attrs[:email],
      password: attrs[:password]
    }
  end
end
