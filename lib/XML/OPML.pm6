use v6;

# use XML::OPML::Grammar;



class XML::OPML::Head {
    has $.title is rw;
    has $.dateCreated is rw;
    has $.dateModified is rw;
    has $.ownerName is rw;
    has $.ownerEmail is rw;
    has $.ownerId is rw;
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
    has Str $text is rw;
    has XML::OPML::Outline @.outlines is rw;
    
    #Return the outline as a string representation
    #the argument &encode is a function used to encode the characters 
    method as_str(&encode) of Str {
        my Str $result ~= "<outline ";
        for %.attributes.sort(*.key) {
            #$.key refers to the object, not the current $_. Is this correct?
            $result ~= $_.key ~ "=\"" ~ encode($_.value) ~ "\" ";
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
    has $.version is rw = "2.0";
    has Str $.encoding is rw = "UTF-8";
    has Bool $.encode-output = False;
    has XML::OPML::Outline @.outlines;

    method add_outline(XML::OPML::Outline $outline) {
        @.outlines.push($outline);
    }

    method add_outlines(@outlines) {
        for @outlines {
            @.outlines.push($_);
        }
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

    #create a XML::OPML object from a opml string text
    method parse(Str $opmlText) {
    }
}

#class for declaring actions associated with XML::OPML::Grammar rules
class XML::OPML::Actions {
    method TOP($/) {
        # make ($<opml>)>>.ast;
        make $<opml>.ast;
    }

    method opml($/) {
        my $head = $<head>.ast;
        my @outlines = $<body>.ast.flat;
        my XML::OPML $mainObj .= new();
        $mainObj.head = $head;
        $mainObj.add_outlines(@outlines); 
        make $mainObj;
    }
    
    method body($/) {
       #make ($<outline>)>>.ast;    
        my @outlines;
        for @($<outline>) {
            @outlines.push($_.ast);
        }
        make @outlines; 
    }

    method outline($/) {
        my %attributes;  
        for @($<attributeWithSpace>) { 
            %attributes{$_<attribute><name>.Str} = $_<attribute><value>.Str;
        }
        my XML::OPML::Outline $currentObj .= new();
        $currentObj.attributes = %attributes;
        for @($<outline>) {
            $currentObj.outlines.push($_.ast);
        }
        make $currentObj;
    }

    method head($/) {
       make XML::OPML::Head.new(
            title           => $<title>.elems ?? $<title>[0]<text>.Str !! '',
            dateCreated     => $<dateCreated>.elems ?? $<dateCreated>[0]<text>.Str !! '',
            dateModified    => $<dateModified>.elems ?? $<dateModified>[0]<text>.Str !! '',
            ownerName       => $<ownerName>.elems ?? $<ownerName>[0]<text>.Str !! '',
            ownerEmail      => $<ownerEmail>.elems ?? $<ownerEmail>[0]<text>.Str !! '',
            ownerId         => $<ownerId>.elems ?? $<ownerId>[0]<text>.Str !! '',
            expansionState  => $<expansionState>.elems ?? $<expansionState>[0]<text>.Str !! '',
            vertScrollState  => $<vertScrollState>.elems ?? $<vertScrollState>[0]<text>.Str !! '',
            windowTop  => $<windowTop>.elems ?? $<windowTop>[0]<text>.Str !! '',
            windowBottom  => $<windowBottom>.elems ?? $<windowBottom>[0]<text>.Str !! '',
            windowLeft  => $<windowLeft>.elems ?? $<windowLeft>[0]<text>.Str !! '',
            windowRight  => $<windowRight>.elems ?? $<windowRight>[0]<text>.Str !! ''
        )
    }
}
