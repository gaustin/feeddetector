require 'test/unit'
require 'feed_detector'

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
    feed_paths = FeedDetector.get_feed_paths(html)
    assert_equal([], feed_paths)
    
    # page containing a single atom feed
    html = make_html(single_atom_feed_html).join("\n")
    feed_paths = FeedDetector.get_feed_paths(html)
    assert_equal(['/feed/atom.xml'], feed_paths)
    
    # page containing a single rss feed
    html = make_html(single_rss_feed_html).join("\n")
    feed_paths = FeedDetector.get_feed_paths(html)
    assert_equal(['/feed/blog.xml'], feed_paths)

    # page containing several feeds
    html = make_html(multi_feed_html).join("\n")
    feed_paths = FeedDetector.get_feed_paths(html)    
    assert_equal(["http://ethandraws.blogspot.com/feeds/posts/default",
                  "http://www.blogger.com/feeds/21351008/posts/default",
                  "http://ethandraws.blogspot.com/feeds/posts/default?alt=rss",
                  "http://giftedslacker.com/feed/",
                  "/feed/atom.xml"], feed_paths)    
  end
  
  def test_get_feed_paths_with_only_detect
    # page containing no feeds w/rss
    html = make_html(nil_feed_html).join("\n")
    feed_paths = FeedDetector.get_feed_paths(html, :rss)
    assert_equal([], feed_paths)
    
    # page containing no feeds w/atom
    html = make_html(nil_feed_html).join("\n")
    feed_paths = FeedDetector.get_feed_paths(html, :atom)
    assert_equal([], feed_paths)
    
    # page containing a single feed w/rss
    html = make_html(single_rss_feed_html).join("\n")
    feed_paths = FeedDetector.get_feed_paths(html, :rss)
    assert_equal(['/feed/blog.xml'], feed_paths)
    
    # page containing a single feed w/atom
    html = make_html(single_atom_feed_html).join("\n")
    feed_paths = FeedDetector.get_feed_paths(html, :atom)
    assert_equal(['/feed/atom.xml'], feed_paths)

    # page containing several feeds w/rss
    html = make_html(multi_feed_html(:rss)).join("\n")
    feed_paths = FeedDetector.get_feed_paths(html, :rss)    
    assert_equal(["http://ethandraws.blogspot.com/feeds/posts/default?alt=rss",
                  "http://giftedslacker.com/feed/",
                  "/feed/blog.xml"], feed_paths)
                  
    # page containing several feeds w/atom
    html = make_html(multi_feed_html(:atom)).join("\n")
    feed_paths = FeedDetector.get_feed_paths(html, :atom)    
    assert_equal(["http://ethandraws.blogspot.com/feeds/posts/default",
                  "http://www.blogger.com/feeds/21351008/posts/default",
                  "/feed/atom.xml"], feed_paths)
  end
  
  def test_fetch_feed_urls
    #page containing a single feed pointer
    feed_paths = FeedDetector.fetch_feed_urls(@wordpress_single_feed_page_url)
    assert_equal([@wordpress_atom_url], feed_paths)
    feed_paths = FeedDetector.fetch_feed_urls(@wordpress_single_feed_page_url, :rss)
    assert_equal([@wordpress_atom_url], feed_paths)
    feed_paths = FeedDetector.fetch_feed_urls(@wordpress_single_feed_page_url, :atom)
    assert_equal([], feed_paths)
    
    #page containing several feed pointers    
    feed_paths = FeedDetector.fetch_feed_urls(@wordpress_several_feed_page_url)
    assert_equal(["http://www.hasmanydevelopers.com/atom.xml",
                  "http://www.hasmanydevelopers.com/rss.xml"], feed_paths)
    feed_paths = FeedDetector.fetch_feed_urls(@wordpress_several_feed_page_url, :rss)
    assert_equal(["http://www.hasmanydevelopers.com/rss.xml"], feed_paths)
    feed_paths = FeedDetector.fetch_feed_urls(@wordpress_several_feed_page_url, :atom)
    assert_equal(["http://www.hasmanydevelopers.com/atom.xml"], feed_paths)
  end
  
  #TODO: add tests for malformed urls

private  
  def multi_feed_html(spec)
    body = []
    body << '   <link rel="alternate" type="application/atom+xml" title="Ethan Draws - Atom" href="http://ethandraws.blogspot.com/feeds/posts/default" />'
    body << '   <link rel="service.post" type="application/atom+xml" title="Ethan Draws - Atom" href="http://www.blogger.com/feeds/21351008/posts/default" />'    
    body << '   <link rel="alternate" type="application/rss+xml" title="Ethan Draws - RSS" href="http://ethandraws.blogspot.com/feeds/posts/default?alt=rss" />'
    body << '   <link rel="alternate" type="application/rss+xml" title="Gifted Slacker RSS Feed" href="http://giftedslacker.com/feed/" />'
    if spec == :rss
      body << '   <link href="/feed/blog.xml" rel="alternate" type="application/rss+xml" />'
    else
      body << '   <link href="/feed/atom.xml" rel="alternate" type="application/atom+xml" />'    
    end
    body
  end
  
  def single_atom_feed_html
    body = []
    body << '   <link href="/feed/atom.xml" rel="alternate" type="application/atom+xml" />'
    body
  end
  
  def single_rss_feed_html
    body = []
    body << '   <link href="/feed/blog.xml" rel="alternate" type="application/rss+xml" />'
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