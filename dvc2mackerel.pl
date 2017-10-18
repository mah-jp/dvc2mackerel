#!/usr/bin/env perl

# dvc2mackerel.pl (Ver.20171018) by Masahiko OHKUBO
# usage: dvc2mackerel.pl [-i INIFILE] [-u URL] [-c CHARSET] [-n CARDNUMBER] [-p PASSWORD] [-v]

use strict;
use warnings;
use lib '/home/mah/perl5/lib/perl5';
use HTML::TagParser;
use Encode;
use Config::Tiny;
use Getopt::Std;

my %opt;
Getopt::Std::getopts('i:u:c:n:p:j', \%opt);
my $file_ini = $opt{'i'} || 'dvc2mackerel.ini';
my $config = Config::Tiny->new;
$config = Config::Tiny->read($file_ini);
my $card_url = $opt{'u'} || $config->{'card'}->{'url'};
my $card_charset = $opt{'c'} || $config->{'card'}->{'charset'};
my $card_no = $opt{'n'} || $config->{'card'}->{'no'};
my $card_password = $opt{'p'} || $config->{'card'}->{'password'};
$card_no =~ s/\D//g;

my ($value, $point) = &GET_VALUES($card_url, $card_charset, $card_no, $card_password);
if (defined($opt{'j'})) {
	printf ('%s', &MAKE_JSON($config->{'json'}->{'key_value'}, $value, $config->{'json'}->{'key_point'}, $point, $config->{'json'}->{'key_total'}));
} else {
	printf ('%d, %d' . "\n", $value, $point);
}
exit;

# parser (Ver.20171017)
sub GET_VALUES {
	my ($card_url, $card_charset, $card_no, $card_password) = @_;
	my (@card_no) = (substr($card_no, -16, 4), substr($card_no, -12, 4), substr($card_no, -8, 4), substr($card_no, -4, 4));
	my $postdata = sprintf('hid_login=ON&CUSTNUM01=%04d&CUSTNUM02=%04d&CUSTNUM03=%04d&CUSTNUM04=%04d&PASSWORD=%s', @card_no, $card_password);
	my $response = Encode::decode($card_charset, `curl -s -b -c -L -X POST --data '$postdata' $card_url`);
	my $html;
	my ($value, $point) = ('undefined', 'undefined');
	eval { $html = HTML::TagParser->new($response); };
	if (!($@)) {
		my @elem = $html->getElementsByClassName('zipcode');
		if (@elem) {
			$value = &EXTRACT_NUMBER($elem[1]->innerText);
			$point = &EXTRACT_NUMBER($elem[3]->innerText);
		}
	} else {
		printf('ERROR: %s' . "\n", $@);
		exit 1;
	}
	return($value, $point);
}

sub EXTRACT_NUMBER {
	my($text) = @_;
	$text =~ s/\s*([\d|,]+)(.*)$/$1/;
	$text =~ s/,//g;
	return($text);
}

sub MAKE_JSON {
	my($key_value, $value, $key_point, $point, $key_total) = @_;
	my $time = time;
	my $json = sprintf(
		'[ {"name": "%s", "time": %d, "value": %d}, {"name": "%s", "time": %d, "value": %d}, {"name": "%s", "time": %d, "value": %d} ]',
		$key_value, $time, $value, $key_point, $time, $point, $key_total, $time, $value + $point );
	return($json);
}
