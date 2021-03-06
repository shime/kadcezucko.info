require 'nokogiri'

class Page
  attr_reader :schema

  def initialize(opts)
    @url = opts[:url] 

    @raw_content = raw_content(opts) 
    @content = Nokogiri::HTML(@raw_content)
    @xpath   = @content.xpath("//tbody//p")
  end

  def random_desktop_user_agent
    user_agents = [
      "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11",
      "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:16.0) Gecko/20100101 Firefox/16.0",
      "Mozilla/5.0 (Windows NT 6.1; rv:2.0b7pre) Gecko/20100921 Firefox/4.0b7pre",
      "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322)",
      "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:17.0) Gecko/17.0 Firefox/17.0",
      "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; TencentTraveler ; Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1) ; .NET CLR 2.0.50727)",
      "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.114 Safari/537.36",
      "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2) Gecko/20100115 Firefox/3.6",
      "Mozilla/5.0 (Windows NT 5.1; rv:17.0) Gecko/20100101 Firefox/17.0",
      "Mozilla/5.0 (Windows NT 5.1; rv:17.0) Gecko/20100101 Firefox/17.0"]
    user_agents.sample
  end

  def fetch_page
    open(@url, :proxy => ENV["PROXY_URL"],
         "User-Agent" => random_desktop_user_agent)
  rescue OpenURI::HTTPError, Errno::ECONNREFUSED
    puts "Proxy error, trying again..."
    retry
  end

  def get_chunk(position)
    Array(position).map do |position|
      @xpath[position].text.split(" ").map do |el|
        el.gsub(/\W+$/, "").gsub(/(,|\.)/, ":")
      end
    end.flatten
  end

  def get_title(position)
    Array(position).map do |position|
      normalize_raw_titles @xpath[position].text
    end
  end

  def css(*args, &blk)
    @content.css(*args, &blk)
  end

  private

    def raw_content(opts)
      if ENV["RACK_ENV"] == "test"
        return File.read("data/original.html")
      end

      if opts[:url] 
        fetch_page
      else
        File.read(opts[:path])
      end
    end

    def normalize_raw_titles(raw)
      raw.gsub(" ", "").gsub(/\b\W+\b/, " ").
        gsub(/\b\W+$/, "").downcase
    end
end
