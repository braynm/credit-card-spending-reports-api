defmodule CcSpendingApi.Statements.Infra.Parsers.RcbcParser do
  @moduledoc """
  RCBC-specific PDF parser implementation
  All amounts are treated as PHP currency

  This parser processes RCBC credit card statements that have been extracted from PDF format.
  The parser expects extracted text in a nested list format where:
  - First level: Pages
  - Second level: Rows per page  
  - Third level: Words/tokens per row

  Example input structure:
  [
    [["RCBC", "STATEMENT"], ["ACCOUNT", "123456"]],  # Page 1
    [["PREVIOUS", "STATEMENT", "BALANCE"], ["01/15", "01/16", "GROCERY", "1,234.56-"]]  # Page 2
  ]
  """

  @behaviour CcSpendingApi.Statements.Domain.BankParser

  # Markers used to identify the start and end of transaction data in RCBC statements
  @txn_start_marker ["PREVIOUS", "STATEMENT", "BALANCE"]
  @txn_end_marker ["BALANCE", "END"]

  @doc """
  Main parsing function that orchestrates the entire RCBC statement parsing process.

  Takes extracted text from PDF and returns structured transaction data.
  The parsing pipeline follows these steps:
  1. Converts charlists to strings for all text elements
  2. Find the page containing transactions
  3. Extract the transaction rows between markers
  4. Normalize each transaction row into a structured format

  ## Parameters
  - extracted_texts: List of pages, each containing rows of tokenized text

  ## Returns
  - List of transaction maps with keys: :sale_date, :post_date, :desc, :amount
  - {:error, :malformed_extracted_text} if input is not a list
  """
  def parse(extracted_texts) when is_list(extracted_texts) do
    txns =
      extracted_texts
      |> charlist_to_sigil()
      |> find_transaction_page()
      |> find_transaction_list()
      |> normalize_row()

    {:ok, txns}
  end

  def parse(_), do: {:error, :malformed_extracted_text}

  @doc """
  Converts charlists to strings for all text elements.

  This function is currently commented out in the main pipeline but may be needed
  if the PDF extraction library returns charlists instead of strings.

  ## Parameters
  - extracted_texts: Nested list structure potentially containing charlists

  ## Returns
  - Same structure but with all charlists converted to strings
  """
  defp charlist_to_sigil(extracted_texts) do
    Enum.map(extracted_texts, fn page ->
      Enum.map(page, fn row -> Enum.map(row, &to_string/1) end)
    end)
  end

  @doc """
  Locates the page containing transaction data within the PDF.

  RCBC statements may span multiple pages, but transactions are typically on
  a specific page marked by the presence of "PREVIOUS STATEMENT BALANCE" row.

  ## Parameters
  - extracted_texts: List of pages (each page is a list of rows)

  ## Returns
  - Single page (list of rows) that contains the transaction data
  - nil if no page contains the transaction start marker
  """
  defp find_transaction_page(extracted_texts) when is_list(extracted_texts) do
    index =
      Enum.find_index(extracted_texts, fn page ->
        Enum.find(page, fn row -> row == @txn_start_marker end)
      end)

    Enum.at(extracted_texts, index)
  end

  @doc """
  Extracts the actual transaction rows from the page.

  RCBC statements have transaction data between specific markers:
  - Start: "PREVIOUS STATEMENT BALANCE" (skip 2 rows after this)
  - End: "BALANCE END" (stop 1 row before this)

  The 2-row offset after start marker accounts for:
  1. Header row (e.g., "DATE", "DESCRIPTION", "AMOUNT")
  2. Previous balance row

  ## Parameters
  - extracted_texts: Single page containing rows of transaction data

  ## Returns
  - List of raw transaction rows (each row is a list of tokens)
  """
  defp find_transaction_list(extracted_texts) do
    start_marker = Enum.find_index(extracted_texts, &(&1 == @txn_start_marker)) + 2
    end_marker = Enum.find_index(extracted_texts, &(&1 == @txn_end_marker)) - 1

    result = Enum.slice(extracted_texts, start_marker, end_marker - start_marker)
  end

  @doc """
  Transforms raw transaction rows into structured transaction maps.

  Each raw transaction row from RCBC follows this format:
  [sale_date, post_date, description_word1, description_word2, ..., amount]

  This function:
  1. Extracts the first two elements as dates
  2. Joins all middle elements as the description
  3. Takes the last element as the amount
  4. Normalizes the amount format

  ## Parameters
  - result: List of raw transaction rows

  ## Returns
  - List of transaction maps with standardized structure
  """
  defp normalize_row(result) do
    Enum.map(result, fn txn ->
      [sale_date, post_date | rest] = txn
      {desc, [amt]} = Enum.split(rest, -1)

      # TODO: convert to txn value object
      %{
        sale_date: to_iso8601(sale_date),
        posted_date: to_iso8601(post_date),
        encrypted_details: Enum.join(desc, " "),
        encrypted_amount: normalize_amt(amt)
      }
    end)
  end

  @doc """
  Normalizes RCBC amount format to standard decimal representation.

  RCBC uses a trailing dash "-" to indicate negative amounts (debits) instead
  of a leading negative sign. This function converts:
  - "1,234.56-" → "-1,234.56" (debit/charge)
  - "1,234.56"  → "1,234.56"  (credit/payment - rare in CC statements)

  ## Parameters
  - amt: Raw amount string from RCBC statement

  ## Returns
  - Normalized amount string with standard negative sign placement

  ## Examples
      iex> normalize_amt("1,234.56-")
      "-1,234.56"
      
      iex> normalize_amt("500.00")
      "500.00"
  """
  defp normalize_amt(amt) do
    amt = String.trim(amt)

    if String.ends_with?(amt, "-") do
      "-#{String.trim_trailing(amt, "-")}"
    else
      amt
    end
  end

  def to_iso8601(date_str) do
    [mm, dd, yy] = String.split(date_str, "/")
    full_year = "20" <> yy

    {:ok, date} =
      Date.new(String.to_integer(full_year), String.to_integer(mm), String.to_integer(dd))

    {:ok, datetime} = DateTime.new(date, ~T[00:00:00], "Etc/UTC")
    datetime
  end
end
