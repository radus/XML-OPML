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

class XML::OPML::Outline {
    method as_str(&encode) of Str {
    };
}

class XML::OPML::EmbeddedOutline is XML::OPML::Outline {
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
    has XML::OPML::Outline @.outlines is rw;

    my method createEmbedded(&encode) of Str {
        my Str $result;
        for @.outlines -> $outline {
            $result ~= $outline.as_str(&encode);
        }
        return $result;
    }
    
    method as_str(&encode) of Str {
        my Str $result = "";
        my Str $embText = "";
        $embText ~= "dateAdded=\"$.dateAdded\" " if $.dateAdded;
        $embText ~= "dateDownloaded=\"$.dateDownloaded\" " if $.dateDownloaded ;
        $embText ~= "description=\"$.description\" " if $.description ;
        $embText ~= "email=\"$.email\" " if $.email ;
        $embText ~= "filename=\"$.filename\" " if $.filename ;
        $embText ~= "htmlUrl=\"$.htmlUrl\" " if $.htmlUrl ;
        $embText ~= "keywords=\"$.keywords\" " if $.keywords ;
        $embText ~= "text=\"$.text\" " if $.text ;
        $embText ~= "type=\"$.type\" " if $.type ;
        $embText ~= "title=\"$.title\" " if $.title ;
        $embText ~= "version=\"$.version\" " if $.version ;
        $embText ~= "xmlUrl=\"$.xmlUrl\" " if $.xmlUrl ;
        if $embText eq "" {
            $result ~= "<outline>\n";
        } else {
            $result ~= "<outline $embText>\n";
        } 
        $result ~= self.createEmbedded(&encode);
        $result ~= "</outline>\n";
        return $result;
    }
}

class XML::OPML::NormalOutline is XML::OPML::Outline {
    has %.attributes is rw;
    method as_str(&encode) of Str {
        my Str $str ~= "<outline ";
        my %attrs = %.attributes;
        %attrs.sort(*.key);
        for %attrs.kv -> $key, $value {
            $str ~= "$key=\"" ~ encode($value) ~ "\" ";
        } 
        $str ~= " />\n";
        return $str;
    }
}

class XML::OPML {

    has XML::OPML::Head $.head is rw;
    has $.body is rw;
    has $.version is rw;
    has Str $.encoding is rw = "UTF-8";
    has XML::OPML::Outline @.outlines;

    method add_outline(XML::OPML::Outline $outline) {
        @.outlines.push($outline);
    }

    my method encode(Str $str ) of Str {
        return $str;
    }
    
    my method getHeadStr() of Str {
        my Str $headStr;
        my XML::OPML::Head $head = $.head;
        $headStr ~= "<head>\n";
        $headStr ~= "<title>" ~ self.encode($head.title) ~ "</title>\n";
        $headStr ~= "<dateCreated>" ~ self.encode($head.dateCreated) ~ "</dateCreated>\n";
        $headStr ~= "<dateModified>" ~ self.encode($head.dateModified) ~ "</dateModified>\n";
        $headStr ~= "<ownerName>" ~ self.encode($head.ownerName) ~ "</ownerName>\n";
        $headStr ~= "<ownerEmail>" ~ self.encode($head.ownerEmail) ~ "</ownerEmail>\n";
        $headStr ~= "<expansionState>" ~ self.encode($head.expansionState) ~ "</expansionState>\n";
        $headStr ~= "<vertScrolLState>" ~ self.encode($head.vertScrollState) ~ "</vertScrollState>\n";
        $headStr ~= "<windowTop>" ~ self.encode($head.windowTop) ~ "</windowTop>\n";
        $headStr ~= "<windowLeft>" ~ self.encode($head.windowLeft) ~ "</windowLeft>\n";
        $headStr ~= "<windowBottom>" ~ self.encode($head.windowBottom) ~ "</windowBottom>\n";
        $headStr ~= "<windowRight>" ~ self.encode($head.windowRight) ~ "</windowRight>\n";
        $headStr ~= "</head>\n";
        return $headStr;
    }

    my method getBodyStr() of Str {
        my Str $body = "";
        $body ~= "<body>\n";
        for @.outlines -> $outline {
            $body ~= $outline.as_str({self.encode($_)});
        }
        return $body;
    }
    
    method as_opml_1_1() of Str {
        my Str $output;
        $output ~= '<?xml version="1.0" encoding="' ~ $.encoding ~ '"?>' ~ "\n";
        $output ~= '<opml version="1.1">' ~ "\n";

        #Head
        $output ~= self.getHeadStr();
        $output ~= self.getBodyStr();
        return $output;
    }
   
    method as_string() {
        return self.as_opml_1_1();    
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
my XML::OPML::NormalOutline $outline .= new(attributes => {
                 text => 'madghoul.com | the dark night of the soul',
                 description => 'madghoul.com, keep your nightmares in order with the one site that keeps you up to date on the dark night of the soul.',
                 title => 'madghoul.com | the dark night of the soul',
                 type => 'rss',
                 version => 'RSS',
                 htmlUrl => 'http://www.madghoul.com/ghoul/InsaneRapture/lunacy.mhtml',
                 xmlUrl => 'http://www.madghoul.com/cgi-bin/fearsome/fallout/index.rss10'}
                );
my XML::OPML::EmbeddedOutline $embOutline .= new();
$embOutline.outlines.push($outline);
#$opmlTest.add_outline($outline);
$opmlTest.add_outline($embOutline);

$opmlTest.as_string().say;

