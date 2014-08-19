defmodule MXkcd do
  @url "http://xkcd.com/info.0.json"
  @user_agent %{"User-agent" => "Elixir mxkcd@oho.io"}
  alias HTTPotion.Response

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
  def handle_response(%Response{body: body, status_code: 200}) do
    :ok = File.write(Path.basename(@url), body)
    body
  end

  def decode_json(body), do: JSEX.decode!(body)

  def build_tweet(json) do
    "#{json["safe_title"]} #{json["img"]} #{mobile_link(json["num"])} #xkcd"
  end

  def mobile_link(num) when is_number(num), do: "http://m.xkcd.com/#{num}"

  def get_cached(url) do
    HTTPotion.get(url, header(url))
  end

  def header(url) do
    basename = Path.basename(url)
    if File.exists? basename do
      Map.put(@user_agent, "If-Modified-Since", last_modified_timestamp(basename))
    else
      @user_agent
    end
  end

  def last_modified_timestamp(filename) do
    File.stat!(filename).mtime
      |> Timex.Date.from(:local)
      |> Timex.DateFormat.format!("{RFC822}")
  end
end
