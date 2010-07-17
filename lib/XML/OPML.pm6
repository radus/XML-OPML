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
    has $.docs is rw;
};

class XML::OPML::Outline {
    has %.attributes is rw;
    has @.outlines is rw;
    
    #Return the outline as a string representation
    #the argument &encode is a function used to encode the characters 
    method as_str(&encode) of Str {
        my Str $result ~= "<outline ";
        for %.attributes.sort(*.key) {
            $result ~= "$.key=\"" ~ encode($.value) ~ "\" ";
        } 
        if @.outlines {
            $result ~= ">\n";
            for @.outlines -> $outline {
                $result ~= $outline.as_str(&encode);
            }
            $result ~= "</outline>\n";
        } else {
            $result ~= "/>\n";
        }
        return $result;
    };
}

class XML::OPML {

    has XML::OPML::Head $.head is rw;
    has $.body is rw;
    has $.version is rw = "2.0";
    has Str $.encoding is rw = "UTF-8";
    has Bool $.encode-output = False;
    has XML::OPML::Outline @.outlines;

    method add_outline(XML::OPML::Outline $outline) {
        @.outlines.push($outline);
    }

    my method encode(Str $str ) of Str {
        return $str unless($.encode-output);
        
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
        $headStr ~= "<vertScrollState>" ~ self.encode($head.vertScrollState) ~ "</vertScrollState>\n";
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
        $body ~= "</body>\n";
        return $body;
    }
    
    method as_string() {
        my Str $output;
        $output ~= '<?xml version="1.0" encoding="' ~ $.encoding ~ '"?>' ~ "\n";
        $output ~= "<opml version=\"$.version\">\n";

        #Head
        $output ~= self.getHeadStr();
        $output ~= self.getBodyStr();
        $output ~= "</opml>\n";
        return $output;
    }
}

