#!/usr/bin/perl

# Usage: zap [-signal] pattern

# Configuration parameters.

$sig = 'TERM';

$BSD = -f '/vmunix';
$pscmd = $BSD ? "ps -auxww" : "ps -ef";

open(TTYIN, "</dev/tty") || die "can't read /dev/tty: $!";
open(TTYOUT, ">/dev/tty") || die "can't write /dev/tty: $!";
select(TTYOUT);
$| = 1;
select(STDOUT);
$SIG{'INT'} = 'cleanup';

if ($#ARGV >= $[ && $ARGV[0] =~ /^-/) {
    if ($ARGV[0] =~ /-(\w+)$/) {
	$sig = $1;
    } else {
	print STDERR "$0: illegal argument $ARGV[0] ignored\n";
    }
    shift;
}

if ($BSD) {
    system "stty cbreak </dev/tty >/dev/tty 2>&1";
}
else {
    system "stty", 'cbreak',
    system "stty", 'eol', '^A';
}

open(PS, "$pscmd|") || die "can't run $pscmd: $!";
$title = <PS>;
print TTYOUT $title;

# Catch any errors with eval.  A bad pattern, for instance.

eval <<'EOF';
while ($cand = <PS>) {
    chop($cand);
    ($user, $pid) = split(' ', $cand);
    next if $pid == $$;
    $found = !@ARGV;
    foreach $pat (@ARGV) {
	$found = 1 if $cand =~ $pat;
    }
    next if (!$found);
    print TTYOUT "$cand? ";
    read(TTYIN, $ans, 1);
    print TTYOUT "\n" if ($ans ne "\n");
    if ($ans =~ /^y/i) { kill $sig, $pid; }
    if ($ans =~ /^q/i) { last; }
}
EOF
&cleanup;

sub cleanup {
    if ($BSD) {
	system "stty -cbreak </dev/tty >/dev/tty 2>&1";
    }
    else {
	system "stty", 'icanon';
	system "stty", 'eol', '^@';
    }
    print "\n";
    exit;
}
