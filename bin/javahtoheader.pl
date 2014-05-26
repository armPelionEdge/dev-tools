#!/usr/bin/perl

use POSIX qw/strftime/;

#if ($#ARGV != 1) {
#    print "usage: javahtoheader.pl \n";
#    exit;
#}

@userinput = <STDIN>;
$X = 0;

$datetime = strftime( "%B-%d-%Y (%H:%M)", localtime(time()) );
print "// Generated by javatoheader.pl on $datetime\n";

%funcnames = ();  #store each $classname_$funcname with value count - this helps us deal with overloaded functions
$innerclz = ""; # inner class flag

foreach $line (@userinput) {
#    print "$X - $line";
#    $_ = $line;
    if(!($line =~ /^\}.*/)) {
	if($line =~ /class\s.*\{/ || $line =~ /interface\s.*\{/) {
#	print $_;
	    $workline = $line;
#	$_ = $line;
#	print $line;
	    $thisclass = "";
	    $isinterface = "";
	    $innerclz = "";
	    $_ = $workline;
	    /class\s(\S+\.\S+[\.\S+]*)\s.*/;
	    $thisclass = $1;
	    if(!defined $thisclass) {
		$_ = $workline;
		/interface\s(\S+\.\S+[\.\S+]*)\{\s.*/;
		$thisclass = $1;
		if($thisclass ne "") {
		    $isinterface = "1";
		    print "// Interface: $line";
		}
	    } else {
		print "// Class: $line";
	    }
#	    print "MeoClass: $thisclass\n";
	    $classobj = $thisclass;
	    $classobj =~ s/(\S+\.)+(\S+)/$2/;
#	$_ = $thisclass;
	    $thisclass =~ s/\./\//g;
	    if($classobj =~ /\$/) {
		$innerclz = "y";
		$classobj =~ s/\$/\_/g;
	    }
	    if($isinterface ne "") {
		print "#define JAVA_IF_$classobj \"$thisclass\"\n";
	    } else {
		if($innerclz ne "") {
		    print "#define JAVA_ICLASS_$classobj \"$thisclass\"\n";
		} else {
		    print "#define JAVA_CLASS_$classobj \"$thisclass\"\n";
		}
	    }
	} 
	elsif ($line =~ /^\s+Signature\:.*/) {
	    if ($line =~ /^\s+Signature\:\s\(.*/) {
# it was a function
		if($lastfield =~ /^\S+\.\S+.*/) {
		    chomp($line);  # static block, looks like: static {};
		    print "// Constructutor: $lastfield\n";
		    print "// Signature: $line\n";
		    print "// ----------\n";
		} elsif($lastfield =~ /^static\s+\{/) {
		    chomp($line);  # constructor...
		    print "// Static block: $lastfield\n";
		    print "// Signature: $line\n";
		    print "// ----------\n";
		} else {           # normal function...
		    print "// Func: $lastfield \n";
		    chomp($line);
		    print "//$line\n";
		    if ($lastfield ne "") {
			$lastfield =~ s/\s*(\S+\s+)*(\S*)(\(\S*(\s\S+)*\))\;/$2/;
			$lastfield =~ s/\./_/g; # don't want any '.'s - so replace with underscores... (used in some constructors)

			$postfix=0;
			# the hash table is used to deal with overloaded functions: adds a _vN on the #define, where N is an
			# incrementing values for each overloaded function
			if(exists $funcnames{$lastfield}) {
			    $postfix = $funcnames{$lastfield};
			}
			$postfix++;
			$funcnames{$lastfield} = $postfix;
			$signature = $line;
			chomp($signature);
			$signature =~ s/^\s+Signature\:\s(\S+)/$1/;
			$pline = "#define JAVA_FUNC_$classobj";
			$deffield = $lastfield;
			$deffield =~ s/\$/\_/g; #don't like '$' either (but do need them in the signature)..
			$pline = $pline . "_$deffield";
			if($postfix > 1) {
			    $pline = $pline . "_v$postfix";
			}

			$pline = $pline . " \"$lastfield\"\n";
			print $pline;
			$pline = "#define JAVA_FUNC_SIG_$classobj";
			$pline = $pline . "_$deffield";
			if($postfix > 1) {
			    $pline = $pline . "_v$postfix";
			}
			$pline = $pline . " \"$signature\"\n";
			print $pline;
		    }
		}
	    } else {
# it was a field
		# signature line
		if ($lastfield ne "") {
		    print "// Field: $lastfield\n";
		    $lastfield =~ s/\s*(\S+\s+)*(\S+)\;/$2/;
		    $pline = "#define JAVA_FIELD_$classobj";
		    $deffield = $lastfield;
		    $deffield =~ s/\$/\_/g; #don't like '$' ...
		    $pline = $pline . "_$deffield \"$lastfield\"\n";
		    print $pline;

		    $signature = $line;
		    chomp($signature);
		    $signature =~ s/^\s+Signature\:\s(\S+)/$1/;
		    $pline = "#define JAVA_FIELD_SIG_$classobj";
		    $pline = $pline . "_$deffield \"$signature\"\n";
		    print $pline;
		}	    
	    }
	} else {
	    $lastfield = $line;
	    chomp($lastfield);
	}
    } else {
	print "// } End of class: $classobj\n";
    }
    $X++;
}




