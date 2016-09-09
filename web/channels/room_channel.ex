defmodule PhoenixChat.RoomChannel do
  use PhoenixChat.Web, :channel
  require Logger

  # def join("room:lobby", payload, socket) do
  #   if authorized?(payload) do
  #     {:ok, socket}
  #   else
  #     {:error, %{reason: "unauthorized"}}
  #   end
  # end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  # def handle_in("ping", payload, socket) do
  #   {:reply, {:ok, payload}, socket}
  # end

  # # It is also common to receive messages from the client and
  # # broadcast to everyone in the current topic (room:lobby).
  # def handle_in("shout", payload, socket) do
  #   broadcast socket, "shout", payload
  #   {:noreply, socket}
  # end
  
  alias PhoenixChat.{Message, Repo}

  def join("room:" <> room_id, payload, socket) do
    authorize(payload, fn ->
      messages = room_id
        |> Message.latest_room_messages
        |> Repo.all
        |> Enum.map(&message_payload/1)
        |> Enum.reverse
      {:ok, %{messages: messages}, socket}
    end)
  end

  defp message_payload(message) do
    from = message.user_id || message.from
    %{body: message.body,
      timestamp: message.timestamp,
      room: message.room,
      from: from,
      id: message.id}
  end
  

  def handle_in("message", payload, socket) do
    payload = payload
      |> Map.put("user_id", socket.assigns.user_id)
      |> Map.put("from", socket.assigns[:uuid])
    changeset = Message.changeset(%Message{}, payload)

    case Repo.insert(changeset) do
      {:ok, message} ->
        payload = message_payload(message)
        broadcast! socket, "message", payload
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end
end
