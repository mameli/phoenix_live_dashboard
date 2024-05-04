defmodule PhoenixLiveSensorsWeb.LiveSensors do
  use PhoenixLiveSensorsWeb, :live_view

  def mount(_params, _session, socket) do
    PhoenixLiveSensorsWeb.Endpoint.subscribe("topic")
    {:ok, assign(socket, cpu_status: 0, gpu_status: 0)}
  end

  # Handle parameters passed to the LiveView
  def handle_info(%{event: "new_message", payload: %{message: message}}, socket) do
    IO.puts("Received message")
    sensor_map = Jason.decode!(message)
    IO.inspect(sensor_map)
    case Map.get(sensor_map, "name") do
      "CPU Power" ->
        {:noreply, assign(socket, cpu_status: Map.get(sensor_map, "value"))}
      "GPU Power" ->
        {:noreply, assign(socket, gpu_status: Map.get(sensor_map, "value"))}
      _ ->
        {:noreply, socket}
    end
  end

  # Render function to display messages in the LiveView
  def render(assigns) do
    ~L"""
    <div>
      <h1>LiveView</h1>
      <p>CPU Power: <%= @cpu_status %></p>
      <p>GPU Power: <%= @gpu_status %></p>
    </div>
    """
  end
end
