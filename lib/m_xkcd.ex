ExTwitter.configure(
   consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
   consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
   access_token: System.get_env("TWITTER_ACCESS_TOKEN"),
   access_token_secret: System.get_env("TWITTER_ACCESS_SECRET")
)

defmodule MXkcd do
  @url "http://xkcd.com/info.0.json"
  @user_agent {"User-Agent", "Elixir mxkcd@oho.io"}
  alias HTTPoison.Response

  def main do
    @url
      |> get_cached
      |> handle_response
      |> decode_json
      |> build_tweet
      |> tweet
  end

  defp tweet(nil), do: nil
  defp tweet(text) do
    # IO.inspect(ExTwitter.user_timeline([count: 5]))
    IO.puts(text)
  end

  defp handle_response(%Response{status_code: 304}) do
    IO.puts "No new comic strip"
    nil
  end
  defp handle_response(%Response{body: body, status_code: 200, headers: %{"Last-Modified" => last_modified}}) do
    :ok = File.write(cachefile, body)
    timestamp = last_modified |> Timex.DateFormat.parse!("{RFC1123}") |> Timex.Date.Convert.to_erlang_datetime
    :ok = File.touch(cachefile, timestamp)
    body
  end

  defp decode_json(nil), do: nil
  defp decode_json(body), do: Poison.decode!(body)

  defp build_tweet(nil), do: nil
  defp build_tweet(json) do
    "#{json["safe_title"]} #{json["img"]} #{mobile_link(json["num"])} #xkcd"
  end

  defp mobile_link(num) when is_number(num), do: "http://m.xkcd.com/#{num}"

  defp get_cached(url) do
    HTTPoison.get(url, headers)
  end

  defp headers do
    if File.exists? cachefile do
      [@user_agent, {"If-Modified-Since", last_modified_timestamp(cachefile)}]
    else
      [@user_agent]
    end
  end

  defp last_modified_timestamp(filename) do
    File.stat!(filename).mtime
      |> Timex.Date.from("GMT")
      |> Timex.DateFormat.format!("{RFC1123}")
  end

  defp cachefile do
    "_cache/#{Path.basename(@url)}"
  end
end
