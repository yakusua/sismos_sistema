Code.require_file("structs.exs", __DIR__)
Code.require_file("persistencia.exs", __DIR__)
Code.require_file("archivos.exs", __DIR__)
Code.require_file("reporte.exs", __DIR__)
Code.require_file("coordinador.exs", __DIR__)

defmodule Principal do
  @ruta_ciudades Path.join(__DIR__, "resources/ciudades.txt")
  @ruta_movimientos Path.join(__DIR__, "resources/movimientos.txt")
  @ruta_reporte Path.join(__DIR__, "resources/reporte_sismos.txt")

  def ejecutar do
    Coordinador.leer_archivos(@ruta_ciudades, @ruta_movimientos)
    |> procesar_resultado()
  end

  defp procesar_resultado(
         {:ok, ciudades, rechazadas_ciudades, movimientos, rechazados_movimientos}
       ) do
    reporte =
      Reporte.generar_general(
        ciudades,
        rechazadas_ciudades,
        movimientos,
        rechazados_movimientos
      )

    IO.puts(reporte)
    guardar_reporte(reporte)
  end

  defp procesar_resultado({:error, errores}) do
    IO.puts(Archivos.mensaje_errores(errores))
  end

  defp guardar_reporte(reporte) do
    case File.write(@ruta_reporte, reporte <> "\n") do
      :ok -> :ok
      {:error, razon} -> IO.puts("Error al guardar el reporte: #{:file.format_error(razon)}")
    end
  end
end

Principal.ejecutar()
