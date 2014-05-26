#!/usr/bin/perl

@userinput = <STDIN>;
#$X = 0;

#$datetime = strftime( "%B-%d-%Y (%H:%M)", localtime(time()) );
#print "// Generated by javatoheader.pl on $datetime\n";

#%funcnames = ();  #store each $classname_$funcname with value count - this helps us deal with overloaded functions

foreach $line (@userinput) {
    if($line =~ /Header\sfor\sclass/) {
	$_ = $line;
#	print "Found line: $line\n";
	/Header\sfor\sclass\s(\S+)\s/;
	$class = $1;
	$class =~ s/\_/\./g; 
	print "$class\n";
    }
}
