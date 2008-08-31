require 'test/unit'
require 'feed_detector'

class FeedDetectorTest < Test::Unit::TestCase
  def setup
    @body = []
    make_default_html
    @default_feed_url = 'http://giftedslacker.com/feed/'
    @default_page_url = 'http://giftedslacker.com/'
  end
  
  def test_wordpress_detect
    # page containing a feed pointer
    feed_path = FeedDetector.detect(@default_page_url)
    assert_equal(@default_feed_url, feed_path)
    feed_path = FeedDetector.detect(@default_page_url, :rss)
    assert_equal(@default_feed_url, feed_path)
    feed_path = FeedDetector.detect(@default_page_url, :atom)
    assert_equal(nil, feed_path)
    
    # the feed itself
    feed_path = FeedDetector.detect(@default_feed_url)
    assert_equal(@default_feed_url, feed_path)
    feed_path = FeedDetector.detect(@default_feed_url, :atom)
    assert_equal(@default_feed_url, feed_path)
    feed_path = FeedDetector.detect(@default_feed_url, :rss)
    assert_equal(nil, feed_path)
  end
  def test_wordpress_only_detect
    make_wordpress_html
    feed_path = FeedDetector.get_feed_path(@body.join("\n"), :atom)
    assert_equal(nil, feed_path)
    feed_path = FeedDetector.get_feed_path(@body.join("\n"), :rss)
    assert_equal(@default_feed_url, feed_path)
  end
  
  def test_wordpress
    make_wordpress_html
    feed_path = FeedDetector.get_feed_path(@body.join("\n"))   
    assert_equal(@default_feed_url, feed_path)
  end
  
  def test_wordpress_only_detect_net
    feed_path = FeedDetector.fetch_feed_url(@default_page_url, :atom)
    assert_equal(nil, feed_path)
    feed_path = FeedDetector.fetch_feed_url(@default_page_url, :rss)
    assert_equal(@default_feed_url, feed_path)
  end
  
  def test_wordpress_net
    feed_path = FeedDetector.fetch_feed_url(@default_page_url)
    assert_equal(@default_feed_url, feed_path)
  end
  
  #TODO: add tests for malformed urls and pages without a feed
  
private

  def make_wordpress_html
    @body = []
    @body << ' <html>'
    @body << '  <head>'
    @body << '   <link href="/super.css" rel="alternate" type="text/css"/>'
    @body << '   <link rel="alternate" type="application/rss+xml" title="Gifted Slacker RSS Feed" href="http://giftedslacker.com/feed/" />'
    @body << '  </head>'
    @body << ' </html>'
  end
  
  def make_default_html
    @body = []
    @body << ' <html>'
    @body << '  <head>'
    @body << '   <link href="/super.css" rel="alternate" type="text/css"/>'
    @body << '   <link href="/feed/atom.xml" rel="alternate" type="application/atom+xml" />'
    @body << '  </head>'
    @body << ' </html>'
  end
end