defmodule CcSpendingApi.Authentication.Domain.Repositories.UserRepository do
  alias CcSpendingApi.Authentication.Domain.Entities.User
  alias CcSpendingApi.Shared.Result

  @type t :: module()

  @callback save(User.t()) :: Result.t(User.t())
  @callback get_by_email(String.t()) :: Result.t(User.t())
  @callback get_by_id(integer()) :: Result.t(User.t())
  @callback email_exists?(String.t()) :: boolean()
end
