require 'rubygems'
require 'open-uri'
require 'rfeedparser'

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
      "http://#{page_url}"
    end
  end
  
  def self.fetch_feed_url(page_url, only_detect=nil)
    @html = open(self.url_from_string(page_url)).read
    
    feed_url = self.get_feed_path(@html, only_detect)
    feed_url = feed_url unless !feed_url || feed_url =~ /^http:\/\// 
    feed_url
  end

  def self.fetch_feed_from_xml(xml, only_detect)
      feed = FeedParser.parse(@html)
      feed_url = feed.url if feed.version =~ /^#{only_detect}\d*/ 
  end

  ##
  # get the feed href from an HTML document
  # for example:
  # ...
  # <link href="/feed/atom.xml" rel="alternate" type="application/atom+xml" />
  # ...
  # => /feed/atom.xml
  # only_detect can force detection of :rss or :atom
  def self.get_feed_path(html, only_detect=nil)
    unless only_detect && only_detect != :atom
      md ||= /<link.*href=['"]*([^\s'"]+)['"]*.*application\/atom\+xml.*>/.match(html) 
      md ||= /<link.*application\/atom\+xml.*href=['"]*([^\s'"]+)['"]*.*>/.match(html) 
    end
    unless only_detect && only_detect != :rss
      md ||= /<link.*href=['"]*([^\s'"]+)['"]*.*application\/rss\+xml.*>/.match(html) 
      md ||= /<link.*application\/rss\+xml.*href=['"]*([^\s'"]+)['"]*.*>/.match(html) 
    end
    md && md[1]
  end

  def self.detect(url, only_detect=nil)
    feed_url = self.fetch_feed_url(url, only_detect) || self.fetch_feed_from_xml(@html, only_detect)
    feed_url
  end
end
