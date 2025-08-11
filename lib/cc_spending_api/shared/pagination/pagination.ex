defmodule CcSpendingApi.Shared.Pagination do
  import Ecto.Query
  alias CcSpendingApi.Repo

  alias CcSpendingApi.Shared.Result
  alias CcSpendingApi.Shared.Pagination.Cursor
  alias CcSpendingApi.Shared.Pagination.Metadata

  defmodule PaginationParams do
    @enforce_keys [:queryable]
    defstruct [
      :queryable,
      :cursor,
      :sort,
      :filters,
      :limit
    ]

    @type t :: %__MODULE__{
            cursor: String.t() | nil,
            filters: map(),
            limit: pos_integer(),
            queryable: Ecto.Queryable.t(),
            sort: [{atom(), :asc | :desc}]
          }

    @default_sort [inserted_at: :desc, id: :desc]
    @default_limit 20
    @max_limit 100

    def new(queryable, opts \\ []) do
      with {:ok, validated_opts} <- validate_options(opts) do
        params = %__MODULE__{
          cursor: validated_opts[:cursor],
          filters: validated_opts[:filters],
          limit: validated_opts[:limit],
          queryable: queryable,
          sort: validated_opts[:sort]
        }

        {:ok, params}
      end
    end

    defp validate_options(opts) do
      cursor = Keyword.get(opts, :cursor)
      sort = Keyword.get(opts, :sort, @default_sort)
      filters = Keyword.get(opts, :filters, %{})
      limit = min(Keyword.get(opts, :limit, @default_limit), @max_limit)

      with :ok <- validate_sort(sort),
           :ok <- validate_filters(filters) do
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
  end

  def paginate(%PaginationParams{} = command) do
    with {:ok, cursor_position} <- Cursor.decode(command.cursor),
         {:ok, query} <- paginate_query(command, cursor_position),
         result <- Repo.all(query),
         {:ok, entries, metadata} <-
           build_result(result, command) do
      {:ok,
       %{
         entries: entries,
         metadata: metadata
       }}
    end
  end

  defp build_result(records, command) do
    metadata = Metadata.new(records, command.limit, command.sort)

    entries =
      if length(records) > command.limit do
        Enum.take(records, command.limit)
      else
        records
      end

    {:ok, entries, metadata}
  end

  defp paginate_query(%PaginationParams{} = command, cursor_position) do
    query =
      command.queryable
      # |> apply_filters(command.filters)
      |> apply_cursor_conditions(cursor_position, command.sort)
      |> apply_ordering(command.sort)
      |> limit(^(command.limit + 1))

    Result.ok(query)
  end

  defp apply_filters(query, filters) when filters == %{}, do: query

  defp apply_filters(query, filters) do
    Enum.reduce(filters, query, fn {field, value}, acc ->
      where(acc, [r], field(r, ^field) == ^value)
    end)
  end

  defp apply_cursor_conditions(query, nil, _sort), do: query

  defp apply_cursor_conditions(query, position, sort_fields) do
    conditions = build_cursor_filter(position, sort_fields)
    where(query, ^conditions)
  end

  defp build_cursor_filter(position, sort_fields) do
    Enum.reduce(sort_fields, dynamic(true), fn
      {cursor_field, :asc}, acc ->
        cursor_value = Map.get(position, cursor_field)
        dynamic([t], ^acc and field(t, ^cursor_field) > ^cursor_value)

      {cursor_field, :desc}, acc ->
        cursor_value = Map.get(position, cursor_field)
        dynamic([t], ^acc and field(t, ^cursor_field) < ^cursor_value)
    end)
  end

  defp apply_ordering(query, sort_fields) do
    Enum.reduce(sort_fields, query, fn {field, direction}, acc ->
      order_by(acc, [r], [{^direction, field(r, ^field)}])
    end)
  end
end
