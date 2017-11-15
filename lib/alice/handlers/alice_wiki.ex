require IEx;

defmodule Alice.Handlers.AliceWiki do
  @moduledoc """
  Documentation for AliceWiki.
  """

  use Alice.Router

  command ~r/wiki (?<term>.+)/i, :search
  route   ~r/wiki (?<term>.+)/i, :search

  def search(conn) do
    IO.puts "========"
    conn
    |> get_term()
    |> get_wiki()
    |> build_reply()
    |> reply(conn)
  end

  defp get_term(conn) do
    conn
    |> Alice.Conn.last_capture()
    |> String.downcase()
    |> String.replace(~r/[_\s]+/, "")
    |> String.trim()
  end

  defp get_wiki(term) do
    term
    |> wiki_url
    |> HTTPoison.get
    |> handle_json
  end

  defp wiki_url(term) do
    "https://en.wikipedia.org/w/api.php?search=#{term}&action=opensearch&format=json"
  end

  defp handle_json({:ok, %{status_code: 200, body: body}}) do
    {:ok, Poison.Parser.parse!(body)}
  end

  defp handle_json({_, %{status_code: _, body: body}}) do
    {:error, Poison.Parser.parse!(body)}
  end

  defp build_reply(post) do
    {_, body} = post
    # IEx.pry
    if length(Enum.at(body, 1)) > 0 do
    
      title = hd(Enum.at(body, 1))
      desc = hd(Enum.at(body, 2))
      link = hd(Enum.at(body, 3))
      other_links = Enum.join(Enum.take(Enum.at(body, 3), 5), "\n")

      [
        link,
        ">#{desc}",
        "Others:\n#{other_links}"
      ]
      |> Enum.join("\n")
    end
  end
  @doc """
  Hello world.

  ## Examples

      iex> AliceWiki.hello
      :world

  """
  def hello do
    :world
  end
end
