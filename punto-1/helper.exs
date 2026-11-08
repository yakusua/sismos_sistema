defmodule Helper do
  @moduledoc """
  este modulo tiene funciones que pueden ayudar en diversas partes del codigo
  """
  @doc """
  esta funcion se puede usar en los structs, para el parser
  """
  def campos(linea) do
    linea
    |> String.trim()
    |> String.split("@")
    |> Enum.map(&String.trim/1)
  end

  @doc """
  # esta funcion es para parsear la hora y tener el formato como un time, y no simplemente texto
  """
  def parsear_hora(texto) do
    case Regex.run(~r/^(\d{2}):(\d{2}):(\d{2})$/, texto) do
      [_, h, m, s] -> Time.new(String.to_integer(h), String.to_integer(m), String.to_integer(s))
      nil -> :error
    end
  end

end
