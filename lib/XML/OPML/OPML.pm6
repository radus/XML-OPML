use v6;

class XML::OPML::Head {
    has $.title is rw;
    has $.dateCreated is rw;
    has $.dateModified is rw;
    has $.ownerName is rw;
    has $.ownerEmail is rw;
    has $.expansionState is rw;
    has $.vertScrollState is rw;
    has $.windowTop is rw;
    has $.windowLeft is rw;
    has $.windowBottom is rw;
    has $.windowRight is rw;
};

class XML::OPML::EmbeddedOutline {
    has Str $.opmlvalue is rw;
    has Str $.dateAdded is rw;
    has Str $.dateDownloaded is rw;
    has Str $.description is rw;
    has Str $.email is rw;
    has Str $.filename is rw;
    has Str $.htmlUrl is rw;
    has Str $.keywords is rw;
    has Str $.text is rw;
    has Str $.title is rw;
    has Str $.type is rw;
    has Str $.version is rw;
    has Str $.xmlUrl is rw;
}

class XML::OPML::Outline {
    has Str $.opmlvalue is rw;
    has %.attributes is rw;
    has XML::OPML::EmbeddedOutline @embeddedOutlines;
};

class XML::OPML {

    has XML::OPML::Head $.head is rw;
    has $.body is rw;
    has $.version is rw;
    has Str $.encoding is rw;
    has XML::OPML::Outline @.outlines;

    method add_outline(XML::OPML::Outline $outline) {
        @.outlines.push($outline);
    }
}

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
$opmlTest.add_outline($outline);

$opmlTest.outlines[0].attributes.perl.say;

