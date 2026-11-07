defmodule Ciudad do
  defstruct [:id, :nombre, :habitantes]


  def ciudad_parser(linea) do
    with [id, nombre, habitantes] <- String.trim(linea) |> String.split("@"),
         {id_num, ""} <- Integer.parse(id),
         {hab_num, ""} <- Integer.parse(habitantes) do
      {:ok,
       %Ciudad{
         id: id_num,
         nombre: nombre,
         habitantes: hab_num
       }}
    else
      _ -> {:error_parser, linea}
    end
  end

end

defmodule Movimiento do
  defstruct [:codigo, :id_ciudad, :hora_inicio, :hora_final, :magnitud, :profundidad]

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
         profundidad: valor_profundidad
       }}
    else
    else
      _ -> {:error_parser, linea}
    end
  end
end
