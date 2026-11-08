Code.require_file("helper.exs", __DIR__)

defmodule Ciudad do
  @doc """
  este modulo maneja la logica que estructura lo que es la ciudad
  """

  @doc """
  se definen los campos
  """
  defstruct [:id, :nombre, :habitantes]

  @doc """
  el parser, para convertir una linea de texto en un objeto ciudad
  """
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
  @moduledoc """
  este define la logica que avarca el movimiento.
  """

  @doc """
  define los campos de movimiento
  """
  defstruct [:codigo, :id_ciudad, :hora_inicio, :hora_final, :magnitud, :profundidad]

  @doc """
  se usa para convertir una linea de texto en una estructura movimiento
  """
  def parsear_movimiento(linea) do
    with [codigo, id_ciudad, inicio, final, magnitud, profundidad] <- Helper.campos(linea),
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
