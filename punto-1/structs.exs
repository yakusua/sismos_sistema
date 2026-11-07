defmodule Ciudad do
  defstruct [:id, :nombre, :habitantes]

  def ciudad_parser(linea) do
    with [id, nombre, habitantes] <- campos(linea),
         true <- id != "" and nombre != "",
         {numero, ""} when numero > 0 <- Integer.parse(habitantes) do
      {:ok, %Ciudad{id: id, nombre: nombre, habitantes: numero}}
    else
      _ -> {:error, linea}
    end
  end

  defp campos(linea) do
    linea
    |> String.trim()
    |> String.split("@")
    |> Enum.map(&String.trim/1)
  end
end

defmodule Movimiento do
  defstruct [
    :codigo,
    :id_ciudad,
    :hora_inicio,
    :hora_final,
    :magnitud,
    :profundidad,
    :linea_original
  ]

  def movimiento_parser(linea) do
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
         profundidad: valor_profundidad,
         linea_original: linea
       }}
    else
      _ -> {:error, linea}
    end
  end

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
