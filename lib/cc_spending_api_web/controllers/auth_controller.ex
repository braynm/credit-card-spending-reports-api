defmodule CcSpendingApiWeb.AuthController do
  use CcSpendingApiWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def logout(conn, %{"token" => token}) do
  end
end
