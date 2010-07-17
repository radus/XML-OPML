use v6;

grammar XML::OPML::Grammar {

    token TOP {
       <xmlHeader>
        <opml> 
        #$
    }

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
       '<outline'  (\s+<attribute>)* \s* 
        [ | ('/>')
          | ('>' <outline>* '</outline>')
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
        '<title>'  <text> '</title>'
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
        '<ownerEmail>' <[a..zA..Z\.\-]>+  '@' <[a..zA..Z\-]>+ '.' \w+ '</ownerEmail>'
        # ([\w\-]+\.)+  ([\w\-]+  | ([a-zA-Z]{1})) | [\w-]{2,})) '@' 
    }

    #this should be a http address
    #TODO: correct this regular expression
    token ownerId {
        '<ownerId>' 
         (http|https) \:\/\/ <[a..zA..Z\-_]>+  (\.<[a..zA..Z\-_]>+)+ (<[a..zA..Z\-\.,@?^=%&amp;:/~\+#]>*<[a..zA..Z\-\@?^=%&amp;/~\+#]>)?
        '</ownerId>'
    }

    token expansionState {
        '<expansionState>'
        (\s*\d+\s*\,)* (\s*\d+\s*)
        '</expansionState>' 
    }

    token vertScrollState {
        '<vertScrollState>'
        \s*\d+\s*
        '</vertScrollState>'
    }

    token windowTop {
        '<windowTop>'
        \s*\d+\s*
        '</windowTop>'
    }

    token windowBottom {
        '<windowBottom>'
        \s*\d+\s*
        '</windowBottom>'
    }
    
    token windowLeft {
        '<windowLeft>'
        \s*\d+\s*
        '</windowLeft>'
    }

    token windowRight {
        '<windowRight>'
        \s*\d+\s*
        '</windowRight>'
    }

##END Head Tokens

##Utility tokens 

    token attribute {
        \w+ '="' <-["<>]>* \"
    }
    
    token text {  <-[<>&]>* };

}
