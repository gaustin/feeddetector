require 'open-uri'

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
  
  def self.fetch_feed_url(page_url, only_detect=nil)
    
    @html = open(self.url_from_string(page_url)).read
    feed_url = self.get_feed_path(@html, only_detect)

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
    

    flatted_matches = matches.inject([]) do |acum,match_array| 
    
      match_array.each {|match| acum << match}
      acum
    
    end
    
    flatted_matches
  
  end

  def self.detect(url, only_detect=nil)

    feed_url = self.fetch_feed_url(url, only_detect) || self.fetch_feed_from_xml(@html, only_detect)
    feed_url

  end
  
end
