use v6;

use Test;

BEGIN {
    @*INC.push("/home/radu/work_area/XML-OPML/lib");
}

use XML::OPML;

{
my Str $expectedString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" ~
                            "<opml version=\"2.0\">\n" ~
                            "<head>\n" ~
                            "<title>mySubscription</title>\n" ~
                            "<dateCreated>Mon, 16 Feb 2004 11:35:00 GMT</dateCreated>\n" ~
                            "<dateModified>Mon, 16 Feb 2004 11:35:00 GMT</dateModified>\n" ~
                            "<ownerName>michael szul</ownerName>\n" ~
                            "<ownerEmail>michael\@madghoul.com</ownerEmail>\n" ~
                            "<expansionState></expansionState>\n" ~
                            "<vertScrolLState></vertScrollState>\n" ~
                            "<windowTop></windowTop>\n" ~
                            "<windowLeft></windowLeft>\n" ~
                            "<windowBottom></windowBottom>\n" ~
                            "<windowRight></windowRight>\n" ~
                            "</head>\n" ~
                            "<body>\n" ~
                            "<outline >\n" ~
                            "<outline description=\"madghoul.com, keep your nightmares in order with the one site that keeps you up to date on the dark night of the soul.\" htmlUrl=\"http://www.madghoul.com/ghoul/InsaneRapture/lunacy.mhtml\" text=\"madghoul.com | the dark night of the soul\" version=\"RSS\"  title=\"madghoul.com | the dark night of the soul\" type=\"rss\" xmlUrl=\"http://www.madghoul.com/cgi-bin/fearsome/fallout/index.rss10\"   />\n" ~
                            "</outline>\n" ~
                            "</body>\n" ~
                            "</opml>\n"; 

my XML::OPML $opmlTest .= new(version => '2.0');
$opmlTest.head = XML::OPML::Head.new(title => 'mySubscription',
                         dateCreated => 'Mon, 16 Feb 2004 11:35:00 GMT',
                         dateModified => 'Mon, 16 Feb 2004 11:35:00 GMT',
                         ownerName => 'michael szul',
                         ownerEmail => 'michael@madghoul.com',
                         expansionState => '',
                         vertScrollState => '',
                         windowTop => '',
                         windowLeft => '',
                         windowBottom => '',
                         windowRight => '',
                    );
my XML::OPML::Outline $outline .= new(attributes => {
                 text => 'madghoul.com | the dark night of the soul',
                 description => 'madghoul.com, keep your nightmares in order with the one site that keeps you up to date on the dark night of the soul.',
                 title => 'madghoul.com | the dark night of the soul',
                 type => 'rss',
                 version => 'RSS',
                 htmlUrl => 'http://www.madghoul.com/ghoul/InsaneRapture/lunacy.mhtml',
                 xmlUrl => 'http://www.madghoul.com/cgi-bin/fearsome/fallout/index.rss10'}
                );
my XML::OPML::Outline $embOutline .= new();
$embOutline.outlines.push($outline);
$opmlTest.add_outline($embOutline);

is $opmlTest.as_string(), $expectedString, "everything is ok";
}
