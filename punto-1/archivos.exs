defmodule Archivos do
  # ---------- Lectura de archivos ----------

  def leer_ciudades(ruta) do
    leer(ruta, &Ciudad.parsear_ciudad/1)
  end

  def leer_movimientos(ruta) do
    leer(ruta, &Movimiento.parsear_movimiento/1)
  end

  def mensaje_errores(errores) do
    errores
    |> Enum.map(fn {archivo, razon} ->
      "Error al leer #{nombre_archivo(archivo)}: #{:file.format_error(razon)}"
    end)
    |> Enum.join("\n")
  end

  defp nombre_archivo(:ciudades), do: "ciudades.txt"
  defp nombre_archivo(:movimientos), do: "movimientos.txt"

  defp leer(ruta, parser) do
    case File.read(ruta) do
      {:ok, contenido} -> procesar_lineas(contenido, parser)
      {:error, razon} -> {:error, razon}
    end
  end

  defp procesar_lineas(contenido, parser) do
    {validos, invalidos} =
      contenido
      |> String.split(~r/\r?\n/)
      |> Enum.reject(fn linea -> String.trim(linea) == "" end)
      |> Enum.map(parser)
      |> Enum.split_with(fn resultado -> match?({:ok, _}, resultado) end)

    registros = Enum.map(validos, fn {:ok, registro} -> registro end)
    {:ok, registros, length(invalidos)}
  end

  # ---------- Validación de registros ----------

  defp campos(linea) do
    linea
    |> String.trim()
    |> String.split("@")
    |> Enum.map(&String.trim/1)
  end

  defp parsear_hora(texto) do
    case Regex.run(~r/^(\d{2}):(\d{2}):(\d{2})$/, texto) do
      [_, h, m, s] -> Time.new(String.to_integer(h), String.to_integer(m), String.to_integer(s))
      nil -> :error
    end
  end
end
