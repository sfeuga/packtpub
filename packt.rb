#! /usr/bin/env ruby

# frozen_string_literal: true

require "faraday"
require "json"
require "nokogiri"
require "open-uri"

packt_url = "https://www.packtpub.com/free-learning"
token = ENV["token"]
slack_url = "https://hooks.slack.com/services/#{token}"

unless token.nil?
  free_daily_ebook = Nokogiri::HTML(URI.open(packt_url))

  ebook = free_daily_ebook.css('div.product__info div.grid.product-info.main-product')

  author = ebook.css('span.product-info__author.free_learning__author').text.delete!("\r\n\\")
  cover_url = ebook.css("img.product-image").attr('src').to_s
  pages = ebook.css('div.free_learning__product_pages').text.delete!("\r\n\\")
  publication_date = ebook.css('div.free_learning__product_pages_date').text.delete!("\r\n\\")
  rating = ebook.css('div.product-info__rating span').map(&:text)
  summary = ebook.css('div.free_learning__product_description').text.delete!("\r\n\\")
  title = ebook.css('h3.product-info__title').text

  puts cover_url
  puts title

  message = {
    "blocks": [
      {
        "type": "header",
        "text": {
          "type": "plain_text",
          "text": "#{title}",
          "emoji": true
        }
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "#{author}\n#{summary}\n#{publication_date}, #{pages}\nRating: #{rating.first}/5 #{rating.last}\n<#{packt_url}|Read the ebook...>"
        },
        "accessory": {
          "type": "image",
          "image_url": cover_url,
          "alt_text": title
        }
      }
    ]
  }

  Faraday.new(:url => slack_url).post("", message.to_json)
else
  puts "no token provided"
end
