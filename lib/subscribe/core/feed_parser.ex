defmodule Subscribe.FeedParser do
  import SweetXml, except: [parse: 1, parse: 2]

  def parse(xml) do
    with channel <- xpath(xml, ~x"//channel"e) do
      podcast_fields(channel)
    end
  end

  def podcast_fields(channel) do
    %{
      title: xpath(channel, ~x"title/text()"s),
      link: xpath(channel, ~x"link/text()"s),
      language: xpath(channel, ~x"language/text()"s),
      copyright: xpath(channel, ~x"copyright/text()"s),
      description: xpath(channel, ~x"description/text()"s),
      itunes_summary: xpath(channel, ~x"itunes:summary/text()"s),
      itunes_subtitle: xpath(channel, ~x"itunes:subtitle/text()"s),
      itunes_author: xpath(channel, ~x"itunes:author/text()"s),
      itunes_owner_email: xpath(channel, ~x"itunes:owner/itunes:email/text()"s),
      itunes_owner_name: xpath(channel, ~x"itunes:owner/itunes:name/text()"s),
      image: xpath(channel, ~x"itunes:image/@href"s)
    }
  end
end
