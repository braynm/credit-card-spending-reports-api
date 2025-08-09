defmodule CcSpendingApi.Statements.Application.Commands.ListUserTransaction do
  @enforce_keys []
  defstruct [
    :cursor,
    :sort,
    :filters,
    :limit,
    :queryable
  ]

  @type t :: %__MODULE__{
          cursor: String.t() | nil,
          sort: [{atom(), :asc | :desc}],
          filters: map(),
          limit: pos_integer(),
          queryable: Ecto.Queryable.t()
        }

  @default_sort [sale_date: :desc, id: :desc]
  @default_limit 20
  @max_limit 50

  def new(queryable, opts \\ []) do
    with {:ok, validated_opts} <- validate_options(opts) do
      command = %__MODULE__{
        queryable: queryable,
        cursor: validated_opts[:cursor],
        sort: validated_opts[:sort],
        filters: validated_opts[:filters],
        limit: validated_opts[:limit]
      }

      {:ok, command}
    end
  end

  defp validate_options(opts) do
    cursor = Keyword.get(opts, :cursor)
    sort = Keyword.get(opts, :sort, @default_sort)
    filters = Keyword.get(opts, :filters, %{})
    limit = min(Keyword.get(opts, :limit, @default_limit), @max_limit)

    with :ok <- validate_sort(sort),
         :ok <- validate_filters(filters),
         :ok <- validate_limit(limit) do
      {:ok, [cursor: cursor, sort: sort, filters: filters, limit: limit]}
    end
  end

  defp validate_sort(sort) when is_list(sort) and length(sort) > 0 do
    if Enum.all?(sort, &valid_sort_field?/1), do: :ok, else: {:error, :invalid_sort}
  end

  defp validate_sort(_), do: {:error, :invalid_sort}

  defp valid_sort_field?({field, direction}) when is_atom(field) and direction in [:asc, :desc],
    do: true

  defp valid_sort_field?(_), do: false

  defp validate_filters(filters) when is_map(filters), do: :ok
  defp validate_filters(_), do: {:error, :invalid_filters}

  defp validate_limit(limit) when is_integer(limit) and limit > 0 and limit <= @max_limit, do: :ok
  defp validate_limit(_), do: {:error, :invalid_limit}
end
