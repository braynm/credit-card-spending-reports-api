defmodule CcSpendingApi.Statements.Application.Commands.UploadStatementTransaction do
  alias CcSpendingApi.Shared.Result
  alias CcSpendingApi.Utils.ValidatorFormatter

  import Ecto.Changeset

  @type t :: %__MODULE__{
          user_id: integer(),
          bank: String.t(),
          pdf_pw: String.t(),
          file: Plug.Upload.t()
        }

  defstruct [:user_id, :bank, :pdf_pw, :file]

  defmodule Validator do
    use Ecto.Schema
    import Ecto.Changeset

    @supported_banks ["rcbc"]
    @derive {Jason.Encoder, only: [:user_id, :bank, :pdf_pw, :file]}

    @max_file_size Application.compile_env(
                     :cc_spending_api,
                     [:file_upload, :max_file_size],
                     10_000_000
                   )

    @allowed_extensions Application.compile_env(
                          :cc_spending_api,
                          [:file_upload, :allowed_extensions],
                          [".pdf"]
                        )
    @primary_key false
    embedded_schema do
      field :file, :any, virtual: true
      field :bank, :string
      field :user_id, :integer
      field :pdf_pw, :string
    end

    def changeset(params) do
      %__MODULE__{}
      |> cast(params, [:file, :bank, :user_id, :pdf_pw])
      |> validate_required([:file, :bank, :user_id, :pdf_pw])
      |> validate_bank()
      |> validate_file()
    end

    defp validate_file(%{changes: %{file: %Plug.Upload{} = file}} = changeset) do
      changeset
      |> validate_file_type(file)
      |> validate_file_size(file)
    end

    defp validate_file(changeset) do
      add_error(
        changeset,
        :file,
        "PDF statement attachment is required"
      )
    end

    defp validate_file_size(changeset = %Ecto.Changeset{}, %{content_type: _, size: size})
         when size > @max_file_size do
      add_error(
        changeset,
        :file,
        "File too large, max size: #{@max_file_size} file size: #{size}"
      )
    end

    defp validate_file_size(changeset, _), do: changeset

    defp validate_bank(%Ecto.Changeset{valid?: true, changes: changes} = changeset) do
      if String.downcase(changes.bank) in @supported_banks do
        changeset
      else
        add_error(
          changeset,
          :bank,
          "Unsupported bank. Please contact the admin to request bank support."
        )
      end
    end

    defp validate_bank(changeset), do: changeset

    defp validate_file_type(changeset, %{filename: filename}) do
      extension = Path.extname(filename) |> String.downcase()

      if extension in @allowed_extensions do
        changeset
      else
        add_error(
          changeset,
          :file,
          "Unsupported file type. Supported files (.pdf)"
        )
      end
    end
  end

  def new(params) do
    case Validator.changeset(params) do
      %Ecto.Changeset{valid?: true} = changeset ->
        validated_data = Ecto.Changeset.apply_changes(changeset)

        command = %__MODULE__{
          file: validated_data.file,
          bank: validated_data.bank,
          user_id: validated_data.user_id,
          pdf_pw: validated_data.pdf_pw
        }

        Result.ok(command)

      %Ecto.Changeset{valid?: false} = changeset ->
        Result.error(ValidatorFormatter.first_errors_by_field(changeset))
    end
  end
end
