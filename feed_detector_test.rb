require 'test/unit'
require 'feed_detector'

class FeedDetectorTest < Test::Unit::TestCase
  def setup
    @body = []
    make_default_html
    
    @wordpress_atom_url = 'http://giftedslacker.com/feed/' # the link says it's RSS, the XML is really ATOM
    @wordpress_page_url = 'http://giftedslacker.com/'
  
    @blogger_atom_url = 'http://ethandraws.blogspot.com/feeds/posts/default'
    @blogger_other_atom_url = 'http://www.blogger.com/feeds/21351008/posts/default'
    @blogger_rss_url = 'http://ethandraws.blogspot.com/feeds/posts/default?alt=rss'
    @blogger_page_url = 'http://ethandraws.blogspot.com/'
  end
  
  def test_wordpress_detect
    # page containing a feed pointer
    feed_path = FeedDetector.detect(@wordpress_page_url)
    assert_equal(@wordpress_atom_url, feed_path)
    feed_path = FeedDetector.detect(@wordpress_page_url, :rss)
    assert_equal(@wordpress_atom_url, feed_path)
    feed_path = FeedDetector.detect(@wordpress_page_url, :atom)
    assert_equal(nil, feed_path)
   
    # the feed itself
    #feed_path = FeedDetector.detect(@wordpress_atom_url)
    #assert_equal(@wordpress_atom_url, feed_path)
    #feed_path = FeedDetector.detect(@wordpress_atom_url, :atom)
    #assert_equal(@wordpress_atom_url, feed_path)
    #feed_path = FeedDetector.detect(@wordpress_atom_url, :rss)
    #assert_equal(nil, feed_path)
  end
  
  def test_wordpress_only_detect
    make_head(make_wordpress_html)
    feed_path = FeedDetector.get_feed_path(@body.join("\n"), :atom)
    assert_equal(nil, feed_path)
    feed_path = FeedDetector.get_feed_path(@body.join("\n"), :rss)
    assert_equal(@wordpress_atom_url, feed_path)
  end
  
  def test_wordpress
    make_head(make_wordpress_html)
    feed_path = FeedDetector.get_feed_path(@body.join("\n"))   
    assert_equal(@wordpress_atom_url, feed_path)
  end
  
  def test_blogger
    make_head(make_blogger_html)
    feed_path = FeedDetector.get_feed_path(@body.join("\n"))
    assert [@blogger_atom_url, @blogger_other_atom_url, @blogger_rss_url, @blogger_page_url].include?(feed_path)
  end
  
  def test_wordpress_only_detect_net
    feed_path = FeedDetector.fetch_feed_url(@wordpress_page_url, :atom)
    assert_equal(nil, feed_path)
    feed_path = FeedDetector.fetch_feed_url(@wordpress_page_url, :rss)
    assert_equal(@wordpress_atom_url, feed_path)
  end
  
  def test_wordpress_net
    feed_path = FeedDetector.fetch_feed_url(@wordpress_page_url)
    assert_equal(@wordpress_atom_url, feed_path)
  end
  
  #TODO: add tests for malformed urls and pages without a feed
  
private

  def make_blogger_html
    body = []
    body << '   <link rel="alternate" type="application/atom+xml" title="Ethan Draws - Atom" href="http://ethandraws.blogspot.com/feeds/posts/default" />'
    body << '   <link rel="alternate" type="application/rss+xml" title="Ethan Draws - RSS" href="http://ethandraws.blogspot.com/feeds/posts/default?alt=rss" />'
    body << '   <link rel="service.post" type="application/atom+xml" title="Ethan Draws - Atom" href="http://www.blogger.com/feeds/21351008/posts/default" />'    
    body
  end
  
  def make_wordpress_html
    body = []
    body << '   <link rel="alternate" type="application/rss+xml" title="Gifted Slacker RSS Feed" href="http://giftedslacker.com/feed/" />'
    body
  end
  
  def make_default_html
    body = []
    body << '   <link href="/feed/atom.xml" rel="alternate" type="application/atom+xml" />'
    body
  end
  
  def make_head(lines)
    @body = []
    @body << ' <html>'
    @body << '  <head>'
    @body << '   <link href="/super.css" rel="alternate" type="text/css"/>'
    lines.each { |line| @body << line }
    @body << '  </head>'
    @body << ' </html>'
  end
  
end