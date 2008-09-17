require 'test/unit'
require 'feed_detector'

#GRANTTODO: Refactor this into something like a template method pattern.

class FeedDetectorTest < Test::Unit::TestCase
  def setup
    @body = []
    
    @wordpress_atom_url = 'http://giftedslacker.com/feed/' # the link says it's RSS, the XML is really ATOM
    @wordpress_single_feed_page_url = 'http://giftedslacker.com/'   
    @wordpress_several_feed_page_url = 'http://www.hasmanydevelopers.com/'  
    
    @blogger_atom_url = 'http://ethandraws.blogspot.com/feeds/posts/default'
    @blogger_other_atom_url = 'http://www.blogger.com/feeds/21351008/posts/default'
    @blogger_rss_url = 'http://ethandraws.blogspot.com/feeds/posts/default?alt=rss'
    @blogger_page_url = 'http://ethandraws.blogspot.com/'
    
    
  end
  
  def test_get_feed_path
    # page containing no feeds
    html = make_html(nil_feed_html).join("\n")
    feed_paths = FeedDetector.get_feed_path(html)
    assert_equal([], feed_paths)
    
    # page containing a single feed
    html = make_html(single_feed_html).join("\n")
    feed_paths = FeedDetector.get_feed_path(html)
    assert_equal(['/feed/atom.xml'], feed_paths)

    # page containing several feeds
    html = make_html(multi_feed_html).join("\n")
    feed_paths = FeedDetector.get_feed_path(html)    
    assert_equal(["http://ethandraws.blogspot.com/feeds/posts/default",
                  "http://www.blogger.com/feeds/21351008/posts/default",
                  "http://ethandraws.blogspot.com/feeds/posts/default?alt=rss",
                  "http://giftedslacker.com/feed/",
                  "/feed/atom.xml"], feed_paths)    
  end
  
  def test_fetch_feed_url
    #page containing a single feed pointer
    feed_paths = FeedDetector.fetch_feed_url(@wordpress_single_feed_page_url)
    assert_equal([@wordpress_atom_url], feed_paths)
    feed_paths = FeedDetector.fetch_feed_url(@wordpress_single_feed_page_url, :rss)
    assert_equal([@wordpress_atom_url], feed_paths)
    feed_paths = FeedDetector.fetch_feed_url(@wordpress_single_feed_page_url, :atom)
    assert_equal([], feed_paths)
    
    #page containing several feed pointers    
    feed_paths = FeedDetector.fetch_feed_url(@wordpress_several_feed_page_url)
    assert_equal(["http://www.hasmanydevelopers.com/atom.xml",
                  "http://www.hasmanydevelopers.com/rss.xml"], feed_paths)
    feed_paths = FeedDetector.fetch_feed_url(@wordpress_several_feed_page_url, :rss)
    assert_equal(["http://www.hasmanydevelopers.com/rss.xml"], feed_paths)
    feed_paths = FeedDetector.fetch_feed_url(@wordpress_several_feed_page_url, :atom)
    assert_equal(["http://www.hasmanydevelopers.com/atom.xml"], feed_paths)
  end
  
  def test_wordpress_detect

    
  end
  
  def test_wordpress_only_detect
    # make_head(make_wordpress_html)
        # feed_path = FeedDetector.fetch_feed_url(@body.join("\n"), :atom)
        #  assert_equal([], feed_path)
        #  feed_path = FeedDetector.fetch_feed_url(@body.join("\n"), :rss)
        #  assert_equal([@wordpress_atom_url], feed_path)
  end
  
  def test_wordpress
    # make_head(make_wordpress_html)
    # feed_path = FeedDetector.get_feed_path(@body.join("\n"))   
    # assert_equal(@wordpress_atom_url, feed_path)
  end
  
  def test_blogger
    # make_head(make_blogger_html)
    # feed_path = FeedDetector.get_feed_path(@body.join("\n"))
    # assert [@blogger_atom_url, @blogger_other_atom_url, @blogger_rss_url].include? feed_path 
  end
  
  def test_blogger_only_detect
    # make_head(make_blogger_html)
    # feed_path = FeedDetector.get_feed_path(@body.join("\n"), :atom)
    # assert [@blogger_atom_url, @blogger_other_atom_url].include? feed_path
    # feed_path = FeedDetector.get_feed_path(@body.join("\n"), :rss)
    # assert_equal(@blogger_rss_url, feed_path)
  end
  
  def test_wordpress_only_detect_net
    # feed_path = FeedDetector.fetch_feed_url(@wordpress_page_url, :atom)
    # assert_equal(nil, feed_path)
    # feed_path = FeedDetector.fetch_feed_url(@wordpress_page_url, :rss)
    # assert_equal(@wordpress_atom_url, feed_path)
  end
  
  def test_wordpress_net
    # feed_path = FeedDetector.fetch_feed_url(@wordpress_page_url)
    # assert_equal(@wordpress_atom_url, feed_path)
  end
  
  #TODO: add tests for malformed urls and pages without a feed

private  
  def multi_feed_html
    body = []
    body << '   <link rel="alternate" type="application/atom+xml" title="Ethan Draws - Atom" href="http://ethandraws.blogspot.com/feeds/posts/default" />'
    body << '   <link rel="service.post" type="application/atom+xml" title="Ethan Draws - Atom" href="http://www.blogger.com/feeds/21351008/posts/default" />'    
    body << '   <link rel="alternate" type="application/rss+xml" title="Ethan Draws - RSS" href="http://ethandraws.blogspot.com/feeds/posts/default?alt=rss" />'
    body << '   <link rel="alternate" type="application/rss+xml" title="Gifted Slacker RSS Feed" href="http://giftedslacker.com/feed/" />'
    body << '   <link href="/feed/atom.xml" rel="alternate" type="application/atom+xml" />'
    body
  end
  
  def single_feed_html
    body = []
    body << '   <link href="/feed/atom.xml" rel="alternate" type="application/atom+xml" />'
    body
  end
  
  def nil_feed_html
    []
  end
  
  def make_html(lines)
    @body = []
    @body << ' <html>'
    @body << '  <head>'
    @body << '   <link href="/super.css" rel="alternate" type="text/css"/>'
    lines.each { |line| @body << line }
    @body << '  </head>'
    @body << ' </html>'
  end
  
end