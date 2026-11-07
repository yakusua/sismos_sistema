Code.require_file("structs.exs", __DIR__)
Code.require_file("archivos.exs", __DIR__)
Code.require_file("reporte.exs", __DIR__)
Code.require_file("coordinador.exs", __DIR__)

defmodule Servidor do
  @ruta_ciudades Path.join(__DIR__, "resources/ciudades.txt")
  @ruta_movimientos Path.join(__DIR__, "resources/movimientos.txt")

  def iniciar do
    Process.register(self(), :servicio_sismos)
    esperar_solicitudes()
  end

  defp esperar_solicitudes do
    receive do
      {destino, {:reporte_ciudad, id_ciudad}} ->
        responder(destino, fn ciudades, _rech_c, movimientos, _rech_m ->
          Reporte.generar_ciudad(id_ciudad, ciudades, movimientos)
        end)

        esperar_solicitudes()

      {destino, :reporte_general} ->
        responder(destino, fn ciudades, rech_c, movimientos, rech_m ->
          Reporte.generar_general(ciudades, rech_c, movimientos, rech_m)
        end)

        esperar_solicitudes()

      {destino, :fin} ->
        send(destino, :fin)
        esperar_solicitudes()
    end
  end

  defp responder(destino, generar) do
    respuesta =
      case Coordinador.leer_archivos(@ruta_ciudades, @ruta_movimientos) do
        {:ok, ciudades, rech_c, movimientos, rech_m} ->
          generar.(ciudades, rech_c, movimientos, rech_m)

        {:error, errores} ->
          Archivos.mensaje_errores(errores)
      end

    send(destino, respuesta)
  end
end

Servidor.iniciar()
