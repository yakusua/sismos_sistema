defmodule Csv do
  def crear_con_cabecera(file_path, titulos, contenido) do
    File.write(file_path, titulos <> contenido)
  end

  def anexar(file_path, contenido) do
    File.write(file_path, contenido, [:append])
  end

  def leer_csv(file_path, parser) do
    {validos, invalidos} =
      file_path
      |> File.stream!()
      |> Enum.drop(1)
      |> Enum.map(parser)
      |> Enum.split_with(fn resultado ->
        match?({:ok, _}, resultado)
      end)
    {{:ok, validos},{:error_parser, invalidos}}
  end

  def generar_mensaje_csv(data, parser) do
    data
    |> Enum.map(parser)
    |> Enum.join("\n")
  end
end
