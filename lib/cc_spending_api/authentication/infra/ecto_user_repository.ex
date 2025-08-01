defmodule CcSpendingApi.Authentication.Infra.EctoUserRepository do
  @behaviour CreditCardApi.Authentication.Domain.Repositories.UserRepository

  import Ecto.Query
  alias CcSpendingApi.Repo
  alias CcSpendingApi.Shared.{Result, Errors}
  alias CcSpendingApi.Authentication.Domain.Entities.User
  alias CcSpendingApi.Authentication.Domain.ValueObjects.Email
  alias CcSpendingApi.Authentication.Infra.Schemas.UserSchema
  alias CcSpendingApi.Authentication.Infra.Schemas.UserSchema

  def save(%User{id: nil} = user) do
    attrs = %{
      email: User.email_string(user),
      password_hash: user.password_hash
    }

    %UserSchema{}
    |> UserSchema.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, schema} -> Result.ok(to_domain(schema))
      {:error, changeset} -> Result.error(changeset_to_error(changeset))
    end
  end

  def get_by_email(email) when is_binary(email) do
    case Repo.get_by(UserSchema, email: email) do
      nil -> Result.error(%Errors.NotFoundError{message: "User not found", resource: :user})
      schema -> Result.ok(to_domain(schema))
    end
  end

  def get_by_id(id) when is_integer(id) do
    case Repo.get(UserSchema, id) do
      nil -> Result.error(%Errors.NotFoundError{message: "User not found", resource: :user})
      schema -> Result.ok(to_domain(schema))
    end
  end

  def email_exists?(email) when is_binary(email) do
    Repo.exists?(from u in UserSchema, where: u.email == ^email)
  end

  defp to_domain(%UserSchema{} = schema) do
    {:ok, email} = Email.new(schema.email)

    %User{
      id: schema.id,
      email: email,
      password_hash: schema.password_hash,
      created_at: schema.inserted_at,
      updated_at: schema.updated_at
    }
  end

  defp changeset_to_error(%Ecto.Changeset{errors: errors}) do
    {field, {message, _}} = List.first(errors)
    %Errors.ValidationError{message: message, field: field, value: nil}
  end
end
