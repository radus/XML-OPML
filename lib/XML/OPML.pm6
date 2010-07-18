use v6;

#TODO: separate grammar to a different file
#       the problem is that if i do this and then 'use XML::OPML::Grammar', 
#       i get a XML::OPML module redefined error

#TODO: the grammar doesn't support xml commentaries inside the document
grammar XML::OPML::Grammar {

    token TOP {
        ^ \s*
        <xmlHeader> \s*
        <comment>* \s*
        <opml> \s*
#        $
    }
    
    #TODO: xmlHeader should always contain a version attribute
    token xmlHeader {
        '<?xml'  (\s+<attribute>)* #\s+ 'version=' #\"?\d+\.?\d+\"?\s+ <attribute>* 
        \s* '?>'
    }

    token version {
        'version="' (\d+\.\d+) '"'
    }
    
    token opml {
        '<opml' (\s+) <version> '>' \s*
        <head> \s*
        <body> \s*
        #'</' (\s*) 'opml' \s* '>'
    }

    token body {
        '<body>' \s*
         <outlineWithSpace>+ 
         #'</body>'
    }

    #TODO: This token is not really needed, but if I use something like:
    #           $<var>=(<attribute>\s*)+
    #           i get some proxy object, which i have no idea how to use
    token outlineWithSpace {
        <outline> \s*
    }

    token outline {
       '<outline'  <attributeWithSpace>* \s* 
        [  '/>'
          | ['>'  \s* <outlineWithSpace>* \s* '</outline>']
        ]
    }

    token textAttribute {
        'text="' <text> '"'
    }

    #TODO: this is very slow, maybe some optimizations can be done
    token head {
        '<head>' \s*
        [
        <title> \s* |
        <dateCreated> \s* |
        <dateModified> \s* |
        <ownerName> \s* |
        <ownerEmail> \s* |
        <ownerId> \s* |
####        <docs> \s* |
        <expansionState>  \s* |
        <vertScrollState> \s* |
        <windowTop> \s* |
        <windowLeft> \s* |
        <windowBottom> \s* |
        <windowRight> \s* 
        ]*
        '</head>'
    } 

##Head Tokens

    token title {
        '<title>'   <text> '</title>'
    } 

    token dateCreated {
        '<dateCreated>' <text> '</dateCreated>'
    }

    token dateModified {
        '<dateModified>' <text> '</dateModified>'
    }
    token ownerName {
        '<ownerName>' <text> '</ownerName>'
    }

    #TODO: use a reg expression for a correct email address
    token ownerEmail {
        '<ownerEmail>' $<text>=[<[a..zA..Z\.\-]>+  '@' <[a..zA..Z\-]>+ '.' \w+] '</ownerEmail>'
        # ([\w\-]+\.)+  ([\w\-]+  | ([a-zA-Z]{1})) | [\w-]{2,})) '@' 
    }

    #this should be a http address
    #TODO: correct this regular expression
    token ownerId {
        '<ownerId>' 
         $<text>=[(http|https) \:\/\/ <[a..zA..Z\-_0..9]>+  (\.<[0..9a..zA..Z\-_]>+)+ (<[0..9a..zA..Z\-\.,@?^\=%&amp;:\/~\+#]>*)] 
         # <[0..9a..zA..Z\-\@?^\=%&amp;\/~\+#]>)?  ]
        '</ownerId>'
    }

    token expansionState {
        '<expansionState>'
        $<text>=[(\s*\d+\s*\,)* (\s*\d+\s*)]*
        '</expansionState>' 
    }

    token vertScrollState {
        '<vertScrollState>'
        $<text>=[\s*\d+\s*]*
        '</vertScrollState>'
    }

    token windowTop {
        '<windowTop>'
        $<text>=[\s*\d+\s*]*
        '</windowTop>'
    }

    token windowBottom {
        '<windowBottom>'
        $<text>=[\s*\d+\s*]*
        '</windowBottom>'
    }
    
    token windowLeft {
        '<windowLeft>'
        $<text>=[\s*\d+\s*]*
        '</windowLeft>'
    }

    token windowRight {
        '<windowRight>'
        $<text>=[\s*\d+\s*]*
        '</windowRight>'
    }

##END Head Tokens

##Utility tokens 

    token attribute {
        $<name>=\w+ '="' $<value>=<-["<>]>* '"' 
    }
    
    #TODO: This token is not really needed, but if I use something like:
    #           $<var>=(\s+<attribute>)+
    #           i get some proxy object, which i have no idea how to use
    token attributeWithSpace {
        \s+<attribute>
    }
    
    token text {  <-[<>&]>* };

    token comment {
        '<!--' .*? '-->'
    }

}

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

#class for declaring actions associated with XML::OPML::Grammar rules
class XML::OPML::Actions {
    method TOP($/) {
        make $<opml>.ast;
    }

    method opml($/) {
        my $head = $<head>.ast;

        # why do we need to flatten the object????
        my @outlines = $<body>.ast.flat;
        my ::XML::OPML $mainObj .= new();
        $mainObj.head = $head;
        $mainObj.add_outlines(@outlines); 
        make $mainObj;
    }
    
    method body($/) {
       #make ($<outline>)>>.ast;    
        my @outlines;
        for @($<outlineWithSpace>) {
            @outlines.push($_.ast);
        }
        make @outlines; 
    }

    method outlineWithSpace($/) {
        make $<outline>.ast;
    }

    method outline($/) {
        my %attributes;  
        for @($<attributeWithSpace>) { 
            %attributes{$_<attribute><name>.Str} = $_<attribute><value>.Str;
        }
        my XML::OPML::Outline $currentObj .= new();
        $currentObj.attributes = %attributes;
        for @($<outlineWithSpace>) {
            $currentObj.outlines.push($_<outline>.ast);
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

class XML::OPML {

    has XML::OPML::Head $.head is rw;
    has $.version is rw = "2.0";
    has Str $.encoding is rw = "UTF-8";
    has Bool $.encode-output is rw = True;
    has XML::OPML::Outline @.outlines;

    method add_outline(XML::OPML::Outline $outline) {
        @.outlines.push($outline);
    }

    method add_outlines(@outlines) {
        for @outlines {
            @.outlines.push($_);
        }
    }

    my method encode(Str $str is copy) of Str {
        return $str unless($.encode-output);
        my %charmap = (
                '>' => '&gt;',
                '<' => '&lt;',
                '"' => '&quot;',
                '&' => '&amp;',
            )
            ;
        $str.subst( rx/ <[<>&"]> /, -> $x { %charmap{~$x} }, :g);
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
        my XML::OPML $result = XML::OPML::Grammar.parse($opmlText, :actions(XML::OPML::Actions.new())).ast;
        $result.encode-output = False;
        return $result;
    }

    method read(Str $path) {
        return XML::OPML.parse(slurp($path)); 
    }

    #print the contents of the XML::OPML object to a file
    method write(Str $path) {
        my $fh = open($path, :w) or die $!;
        $fh.print(self.as_string());
        $fh.close();
    }
}

