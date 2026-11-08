defmodule Archivos do
  @moduledoc """
  este modulo esta encargado de contener las funciones necesarias y a utilizar, para el manejo de los archivos, osea leerlos y
  convertirlos en structs de elixir, separarlas lineas incorrectas etc
  """


  @doc """
  esta funcion, con la otra leer_movimiento, llaman a leer, con los parcers especificos de cada estructura
  """
  def leer_ciudades(ruta) do
    leer(ruta, &Ciudad.parsear_ciudad/1)
  end

  # lee los movimientos usando el parser de movimiento y usa la funcion leer
  def leer_movimientos(ruta) do
    leer(ruta, &Movimiento.parsear_movimiento/1)
  end
  @doc """
  se utiliza para darle estructura a los errores, que suelen suceder al momento de parsea
  """
  def mensaje_errores(errores) do
    errores
    |> Enum.map(fn {archivo, razon} ->
      "Error al leer #{nombre_archivo(archivo)}: #{:file.format_error(razon)}"
    end)
    |> Enum.join("\n")
  end
  @doc """
  se utiliza internamente, aunque tambien se mensionen en el main, para poder hacer distincion del nombre del archivo en vez de la ubicacion completa
  """
  defp nombre_archivo(:ciudades), do: "ciudades.txt"
  defp nombre_archivo(:movimientos), do: "movimientos.txt"

  @doc """
  se usa para leer el archivo, resive ruta y parser, el parser se ejecuta en procesar linea, si el file.read devuelve :ok, osea que el archivo existe y se puede leer
  """
  defp leer(ruta, parser) do
    case File.read(ruta) do
      {:ok, contenido} -> procesar_lineas(contenido, parser)
      {:error, razon} -> {:error, razon}
    end
  end
  @doc """
  separa los validos de los invalidos, ejecutando el parser en cada linea /n o /r del texto, devuelve solo el numero de los invalidos
  """
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

end
