defmodule CcSpendingApi.Authentication.Domain.Services.UserRegistrationService do
  alias CcSpendingApi.Authentication.Domain.Entities.User
  alias CcSpendingApi.Shared.{Result, Errors}

  def register_user(email, password, deps) do
    with :ok <- check_email_availability(email, deps),
         {:ok, user} <- create_user(email, password),
         {:ok, saved_user} <- save_user(user, deps) do
      {:ok, saved_user}
    end
  end

  defp check_email_availability(email, deps) do
    if deps.user_repository.email_exists?(email) do
      Result.error(%Errors.ValidationError{
        message: "Email already exists",
        field: :email,
        value: email
      })
    else
      :ok
    end
  end

  defp save_user(user, deps) do
    deps.user_repository.save(user)
  end

  defp create_user(email, password) do
    User.new(%{email: email, password: password})
  end
end
