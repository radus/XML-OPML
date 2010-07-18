use v6;

grammar XML::OPML::Grammar {

    token TOP {
        ^
        <xmlHeader>
        <opml> 
        $
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
        '<opml' (\s+) <version> '>'
        <head>
        <body>
        '</' (\s*) 'opml' \s* '>'
    }

    token body {
        '<body>'
        <outline>+
        '</body>'
    }

    token outline {
       '<outline'  <attributeWithSpace>* \s* 
        [ '/>'
          | '>' <outline>* '</outline>'
        ]
    }

    token textAttribute {
        'text="' <text> '"'
    }

    #TODO: fix this token - the subtokens can be in any order, right now the order in our <head> is fixed
    token head {
        '<head>'
        <title>?
        <dateCreated>?
        <dateModified>?
        <ownerName>?
        <ownerEmail>?
        <ownerId>?
#        <docs>?
        <expansionState>?
        <vertScrollState>?
        <windowTop>?
        <windowLeft>?
        <windowBottom>?
        <windowRight>?
        '</head>'
    }

##Head Tokens

    token title {
        '<title>' <text> '</title>'
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
         $<text>=[(http|https) \:\/\/ <[a..zA..Z\-_]>+  (\.<[a..zA..Z\-_]>+)+ (<[a..zA..Z\-\.,@?^=%&amp;:/~\+#]>*<[a..zA..Z\-\@?^=%&amp;/~\+#]>)?  ]
        '</ownerId>'
    }

    token expansionState {
        '<expansionState>'
        $<text>=[(\s*\d+\s*\,)* (\s*\d+\s*)]
        '</expansionState>' 
    }

    token vertScrollState {
        '<vertScrollState>'
        $<text>=[\s*\d+\s*]
        '</vertScrollState>'
    }

    token windowTop {
        '<windowTop>'
        $<text>=[\s*\d+\s*]
        '</windowTop>'
    }

    token windowBottom {
        '<windowBottom>'
        $<text>=[\s*\d+\s*]
        '</windowBottom>'
    }
    
    token windowLeft {
        '<windowLeft>'
        $<text>=[\s*\d+\s*]
        '</windowLeft>'
    }

    token windowRight {
        '<windowRight>'
        $<text>=[\s*\d+\s*]
        '</windowRight>'
    }

##END Head Tokens

##Utility tokens 

    token attribute {
        $<name>=\w+ '="' $<value>=<-["<>]>* '"' 
    }
    
    token attributeWithSpace {
        \s+<attribute>
    }
    
    token text {  <-[<>&]>* };

}
