#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use IO::Select;
use IO::Socket::INET;
 
my $opt_input;
my $opt_output;
my $opt_port;

GetOptions(
	"input|i=s"	=> \$opt_input,
	"output|o=s"	=> \$opt_output,
	"port|p=i"	=> \$opt_port,
	);

my $input = \*STDIN;
my $output = \*STDOUT;
my $port = '9527';

if ($opt_input) {
	# open INPUT as read/write to avoid being blocked by a FIFO
	open(INPUT, "+<", $opt_input) or die("Failed to open $opt_input: $!\n");

	$input = \*INPUT;
}

if ($opt_output) {
	# open OUTPUT as read/write to avoid being blocked by a FIFO
	open(OUTPUT, "+>", $opt_output) or die("Failed to open $opt_output: $!\n");

	$output = \*OUTPUT;
	$output->autoflush(1);
}

$port = $opt_port if ($opt_port);

# creating a listening socket
my $socket = new IO::Socket::INET (
	LocalHost => '0.0.0.0',
	LocalPort => $port,
	Proto => 'tcp',
	Listen => 5,
	Reuse => 1
);
die "cannot create socket $!\n" unless $socket;
 
my $client_socket = -1;
my $client_address;
my $client_port;
my $data;

my $select = IO::Select->new();
$select->add($socket);
$select->add($input);

my $autoreply = '';

my @ready;
while(@ready = $select->can_read) {
	foreach my $fh (@ready) {
		if ($fh == $socket) {
			my $incomming = $socket->accept();

			if ($client_socket != -1) {
				$incomming->send("ERROR server in use\n");
				shutdown($incomming, 2);
				next;
			}

			$client_socket = $incomming;

			$client_socket->autoflush(1);
			$client_address = $client_socket->peerhost();
			$client_port = $client_socket->peerport();

			$select->add($client_socket);

			print $output "CONNECT $client_address $client_port\n";

		} elsif ($fh == $client_socket) {
			if (!$client_socket->connected ||
			    $client_socket->sysread($data, 1024) == 0) {
				# Client disconnected
				$select->remove($client_socket);

				shutdown($client_socket, 2);
				$client_socket = -1;

				print $output "DISCONNECT $client_address $client_port\n";
				next;
			}

			if ($autoreply eq '') {
				print $output $data;
			} else {
				$client_socket->send($autoreply);
			}

		} elsif ($fh == $input) {
			my $response;
			$input->sysread($response, 1024);

			if ($response =~ /^AUTO /) {
				$autoreply = substr($response, length("AUTO "));
				next;
			} elsif ($response =~ /^NOAUTO/) {
				$autoreply = '';
				next;
			} elsif ($client_socket == -1) {
				print $output "ERROR no connected client\n";
				next;
			}

			$client_socket->send($response);
		}
	}
}

$socket->close();

close(INPUT) if ($opt_input);
close(OUTPUT) if ($opt_output);
