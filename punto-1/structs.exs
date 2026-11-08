defmodule Ciudad do
  defstruct [:id, :nombre, :habitantes]
  def parsear_ciudad(linea) do
    with [id, nombre, habitantes] <- Helper.campos(linea),
         true <- id != "" and nombre != "",
         {numero, ""} when numero > 0 <- Integer.parse(habitantes) do
      {:ok, %Ciudad{id: id, nombre: nombre, habitantes: numero}}
    else
      _ -> :error
    end
  end
end

defmodule Movimiento do
  defstruct [:codigo, :id_ciudad, :hora_inicio, :hora_final, :magnitud, :profundidad]

  def parsear_movimiento(linea) do
    with [codigo, id_ciudad, inicio, final, magnitud, profundidad] <- campos(linea),
         true <- codigo != "" and id_ciudad != "",
         {:ok, hora_inicio} <- Helper.parsear_hora(inicio),
         {:ok, hora_final} <- Helper.parsear_hora(final),
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
end
