defmodule PhoenixLiveSensorsWeb.LiveSensors do
  use PhoenixLiveSensorsWeb, :live_view

  def mount(_params, _session, socket) do
    PhoenixLiveSensorsWeb.Endpoint.subscribe("sensor_topic")
    {:ok, assign(socket, cpu_status: 0, gpu_status: 0, cpu_color: "text-green-500", gpu_color: "text-green-500")}
  end

  # Handle parameters passed to the LiveView
  def handle_info(%{event: "new_message", payload: %{message: message}}, socket) do
    IO.puts("Received message")
    sensor_map = Jason.decode!(message)
    IO.inspect(sensor_map)
    {value, ""} = Float.parse(Map.get(sensor_map, "value"))
    color = case value do
      v when v > 200 and v < 500-> "text-yellow-500"
      v when v > 500 -> "text-red-500"
      _ -> "text-green-500"
    end
    case Map.get(sensor_map, "name") do
      "CPU Power" ->
        {:noreply, assign(socket, cpu_status: value, cpu_color: color)}
      "GPU Power" ->
        {:noreply, assign(socket, gpu_status: value, gpu_color: color)}
      _ ->
        {:noreply, socket}
    end
  end
end
