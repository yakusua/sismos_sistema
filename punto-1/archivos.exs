defmodule Archivos do
  # ---------- Lectura de archivos ----------

  def leer_ciudades(ruta) do
    leer(ruta, &Ciudad.ciudad_parser/1)
  end

  def leer_movimientos(ruta) do
    leer(ruta, &Movimiento.movimiento_parser/1)
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

  defp parsear_ciudad(linea) do
    with [id, nombre, habitantes] <- campos(linea),
         true <- id != "" and nombre != "",
         {numero, ""} when numero > 0 <- Integer.parse(habitantes) do
      {:ok, %Ciudad{id: id, nombre: nombre, habitantes: numero}}
    else
      _ -> :error
    end
  end

  defp parsear_movimiento(linea) do
    with [codigo, id_ciudad, inicio, final, magnitud, profundidad] <- campos(linea),
         true <- codigo != "" and id_ciudad != "",
         {:ok, hora_inicio} <- parsear_hora(inicio),
         {:ok, hora_final} <- parsear_hora(final),
         {valor_magnitud, ""} <- Float.parse(magnitud),
         {valor_profundidad, ""} when valor_profundidad >= 0 <- Float.parse(profundidad) do
      {:ok,
       %Movimiento{
         codigo: codigo,
         id_ciudad: id_ciudad,
         hora_inicio: hora_inicio,
         hora_final: hora_final,
         magnitud: valor_magnitud,
         profundidad: valor_profundidad
       }}
    else
      _ -> :error
    end
  end

  defp parsear_hora(texto) do
    case Regex.run(~r/^(\d{2}):(\d{2}):(\d{2})$/, texto) do
      [_, h, m, s] -> Time.new(String.to_integer(h), String.to_integer(m), String.to_integer(s))
      nil -> :error
    end
  end
end
