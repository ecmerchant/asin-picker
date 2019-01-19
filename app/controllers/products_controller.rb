class ProductsController < ApplicationController

  require 'open-uri'
  require 'nokogiri'
  require 'uri'


  def search
  end

  def update
    begin
      yahoo_url = params[:data][:text]
      ip_address = request.remote_ip

      html = OpenURI.open_uri(yahoo_url).read
      doc = Nokogiri::HTML.parse(html)

      info = Array.new

      doc.xpath('//td[@class="a1"]').each do |node|

        logger.debug("---------------------")
        buffer = Array.new

        parent = node.parent
        title = node.css('a')[0].inner_text
        page = node.css('a')[0].attribute('href').value
        id = /auction\/([\s\S]*?)$/.match(page)[1]
        image = parent.xpath('./td[@class="i"]//a').css('img')[0].attribute('src').value
        price = parent.xpath('./td[@class="pr1"]/text()')

        url = "https://www.amazon.co.jp/s/ref=nb_sb_noss?__mk_ja_JP=カタカナ&url=search-alias%3Daps&field-keywords=" + title.to_s
        url = URI.encode(url)

        logger.debug(url)
        user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36"


        begin
          amazon_html = open(url, "User-Agent" => user_agent) do |f|
            f.read
          end

          amazon_doc = Nokogiri::HTML.parse(amazon_html)
          target = amazon_doc.xpath('//li[@id="result_0"]')
          target = target.first

          if target == nil then
            asin = "該当なし"
            amazon_title = ""
            amazon_image = ""
            amazon_price = ""
          else
            asin = target.xpath('@data-asin').text
            amazon_title = target.xpath('.//a').css('img')[0].attribute('alt').value
            amazon_image = target.xpath('.//a').css('img')[0].attribute('src').value
            amazon_price = target.xpath('.//span[@class="a-size-base a-color-price s-price a-text-bold"]')[0]
            if amazon_price != nil then
              amazon_price = amazon_price.inner_text
            else
              amazon_price = target.xpath('.//span[@class="a-size-base a-color-price a-text-bold"]')[0].inner_text
            end
          end
        rescue => e
          asin = "エラー"
          amazon_title = ""
          amazon_image = ""
          amazon_price = ""
        end

        logger.debug(asin)
        logger.debug(amazon_title)
        logger.debug(amazon_image)
        logger.debug(amazon_price)

        buffer = [image, id, title, price, amazon_image, asin, amazon_title, amazon_price]
        info.push(buffer)
      end

      results = { :result => info}
      render partial: 'ajax_partial', locals: { :results => results }
    rescue => e

    end
  end

end
