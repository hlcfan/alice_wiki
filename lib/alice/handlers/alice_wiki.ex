require IEx;

defmodule Alice.Handlers.AliceWiki do
  @moduledoc """
  Documentation for AliceWiki.
  """

  use Alice.Router

  @url "https://en.wikipedia.org/w/api.php"

  route ~r/wiki\s+me\s+(?<term>.+)/i, :fetch_wiki

  def fetch_wiki(conn) do
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
    |> String.trim()
  end

  defp get_wiki(term) do
    term
    |> wiki_url
    |> HTTPoison.get
    |> handle_json
  end

  defp wiki_url(term) do
    URI.encode("#{@url}?search=#{term}&action=opensearch&format=json")
  end

  defp handle_json({:ok, %{status_code: 200, body: body}}) do
    {:ok, Poison.Parser.parse!(body)}
  end

  defp handle_json({_, %{status_code: _, body: body}}) do
    {:error, Poison.Parser.parse!(body)}
  end

  defp build_reply({_, body}) do
    # IEx.pry
    if entry_found?(body) do
      [
        link(body),
        "Others:\n#{other_links(body)}"
      ]
      |> Enum.join("\n")
    else
      "No Wikipedia entry found for '#{Enum.at(body, 0)}'"
    end
  end

  defp entry_found?(body) do
    body
    |> Enum.at(1)
    |> length
    |> Kernel.>(0)
  end

  defp link(body) do
    body
    |> Enum.at(3)
    |> hd
  end

  defp other_links(body) do
    body
    |> Enum.at(3)
    |> Enum.take(5)
    |> Enum.map(&process_link/1)
    |> Enum.join("\n")
  end

  def process_link(link) do
    link
    |> String.slice(8..-1)
  end
end
