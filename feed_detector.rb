require 'open-uri'
require 'timeout'

class FeedDetector
  ##
  # return the feed url for a url
  # for example: http://blog.dominiek.com/ => http://blog.dominiek.com/feed/atom.xml
  # only_detect can force detection of :rss or :atom
  # if nil is returned the has no discernible feed url -- perhaps because it's the feed url

  def self.url_from_string(url)
    if url =~ /^http:\/\//
      url
    else
      "http://#{url}"
    end
  end

  ## converts relative urls to absolute urls
  def self.to_absolute_url(page_url,feed_url)
    if feed_url =~ /^http:\/\// ## if its absolute
      feed_url
    elsif feed_url =~ /^\//  ## relative to the host root ## '/some_dir_from_root/feed.xml'
      "http://#{URI.parse(page_url).host.to_s + feed_url}"
    else  ## relative to the page path ## 'feed.xml'
      feed_path = page_url.scan(/^(http:\/\/[^\/]+)((?:\/[^\/]+)+(?=\/))?\/?(?:[^\/]+)?$/i).to_s
      feed_path +'/'+ feed_url
    end
  end
  
  def self.fetch_feed_urls(page_url, only_detect=nil)
    retries = 3 ## default retries
    begin
      Timeout::timeout(5){ ## default timeout 5 secs
        html = open(self.url_from_string(page_url)).read
      }
    rescue Timeout::Error
      retries -= 1
      if retries > 0
        sleep 0.42 and retry
      else
        raise
      end
    end
    feed_urls = self.get_feed_paths(html, only_detect)
    feed_urls.map { |feed_url| self.to_absolute_url(page_url, feed_url) }
  end

  ##
  # get the feed href from an HTML document
  # for example:
  # ...
  # <link href="/feed/atom.xml" rel="alternate" type="application/atom+xml" />
  # ...
  # => /feed/atom.xml
  # only_detect can force detection of :rss or :atom
  def self.get_feed_paths(html, only_detect=nil)
    matches =[]

    unless only_detect && only_detect != :atom
      matches |= html.scan(/<link.*href=['"]*([^\s'"]+)['"]*.*application\/atom\+xml.*>/)
      matches |= html.scan(/<link.*application\/atom\+xml.*href=['"]*([^\s'"]+)['"]*.*>/)
      #matches |=  atom_feed
    end
    
    unless only_detect && only_detect != :rss  
      matches |= html.scan(/<link.*href=['"]*([^\s'"]+)['"]*.*application\/rss\+xml.*>/)
      matches |= html.scan(/<link.*application\/rss\+xml.*href=['"]*([^\s'"]+)['"]*.*>/)
    #  matches |= rss_feed
    end

    flattened_matches = matches.flatten
    flattened_matches
  end
  
end
