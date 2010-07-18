use v6;

BEGIN {
    unshift @*INC, "/home/radu/work_area/XML-OPML/lib";
}

use Test;

use XML::OPML;
use XML::OPML::Grammar;


     my $xmlHeaderTest = '<?xml version="1.0" encoding="ISO-8859-1"?>' ~
'<opml version="2.0">' ~
	'<head>' ~
		'<title>workspace.userlandsamples.doSomeUpstreaming</title>' ~
		'<dateCreated>Mon, 11 Feb 2002 22:48:02 GMT</dateCreated>' ~
		'<dateModified>Sun, 30 Oct 2005 03:30:17 GMT</dateModified>' ~
		'<ownerName>Dave Winer</ownerName>' ~
		'<ownerEmail>dwiner@yahoo.com</ownerEmail>' ~
		'<expansionState>1, 2, 4</expansionState>' ~
		'<vertScrollState>1</vertScrollState>' ~
		'<windowTop>74</windowTop>' ~
		'<windowLeft>41</windowLeft>' ~
		'<windowBottom>314</windowBottom>' ~
		'<windowRight>475</windowRight>' ~
		'</head>' ~
	'<body>' ~
		'<outline text="Changes" isComment="true">' ~
			'<outline text="1/3/02; 4:54:25 PM by DW">' ~
				'<outline text="Change &quot;playlist&quot; to &quot;radio&quot;."/>' ~
				'</outline>' ~
			'<outline text="2/12/01; 1:49:33 PM by DW" isComment="true">' ~
				'<outline text="Test upstreaming by sprinkling a few files in a nice new test folder."/>' ~
				'</outline>' ~
			'</outline>' ~
		'<outline text="on writetestfile (f, size)">' ~
			'<outline text="file.surefilepath (f)" isBreakpoint="true"/>' ~
			'<outline text="file.writewholefile (f, string.filledstring (&quot;x&quot;, size))"/>' ~
			'</outline>' ~
		'<outline text="local (folder = user.radio.prefs.wwwfolder + &quot;test\\largefiles\\&quot;)"/>' ~
		'<outline text="for ch = \'a\' to \'z\'">' ~
			'<outline text="writetestfile (folder + ch + &quot;.html&quot;, random (1000, 16000))"/>' ~
			'</outline>' ~
		'</body>' ~
	'</opml>';

{
    my $result = XML::OPML::Grammar.parse($xmlHeaderTest);
    is($result.Bool, True);
}

{

    my $actions = XML::OPML::Actions.new();
    my $result = XML::OPML::Grammar.parse($xmlHeaderTest, :actions($actions)).ast;
    $result.as_string().say;
}
    
    
