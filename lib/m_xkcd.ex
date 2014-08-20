defmodule MXkcd do
  @url "http://xkcd.com/info.0.json"
  @user_agent {"User-Agent", "Elixir mxkcd@oho.io"}
  alias HTTPoison.Response

  def foo do
    @url
      |> get_cached
      |> handle_response
      |> decode_json
      |> build_tweet
      |> tweet
  end

  def tweet(text), do: IO.puts(text)

  def handle_response(%Response{status_code: 304}) do
    IO.puts "No new comic strip"
    System.halt(0)
  end
  def handle_response(%Response{body: body, status_code: 200, headers: %{"Last-Modified" => last_modified}}) do
    :ok = File.write(Path.basename(@url), body)
    timestamp = last_modified |> Timex.DateFormat.parse!("{RFC1123}") |> Timex.Date.Convert.to_erlang_datetime
    :ok = File.touch(Path.basename(@url), timestamp)
    body
  end

  def decode_json(body), do: Poison.decode!(body)

  def build_tweet(json) do
    "#{json["safe_title"]} #{json["img"]} #{mobile_link(json["num"])} #xkcd"
  end

  def mobile_link(num) when is_number(num), do: "http://m.xkcd.com/#{num}"

  def get_cached(url) do
    h = header url
    resp = HTTPoison.get(url, h)
    resp
  end

  def header(url) do
    basename = Path.basename(url)
    if File.exists? basename do
      [@user_agent, {"If-Modified-Since", last_modified_timestamp(basename)}]
    else
      [@user_agent]
    end
  end

  def last_modified_timestamp(filename) do
    File.stat!(filename).mtime
      |> Timex.Date.from("GMT")
      |> Timex.DateFormat.format!("{RFC1123}")
  end
end
