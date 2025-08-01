defmodule CcSpendingApi.Shared.Errors do
  defmodule DomainError do
    defexception [:message, :code]
  end

  defmodule ValidationError do
    defexception [:message, :field, :value]
  end

  defmodule NotFoundError do
    defexception [:message, :resource]
  end

  defmodule AuthenticationError do
    defexception [:message]
  end
end
