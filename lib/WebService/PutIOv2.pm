package WebService::PutIOv2;

use 5.006;
use strict;
use warnings FATAL => 'all';

use LWP::UserAgent;                # From CPAN
use LWP::Protocol::https;
use JSON qw( decode_json );     # From CPAN
use Data::Dumper;

=head1 NAME

WebService::PutIOv2 - Perl Module for the put.io API version 2.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use WebService::PutIOv2;

    my $foo = WebService::PutIOv2->new();
    ...

=head1 SUBROUTINES/METHODS



=head2 function1

=cut

our $PUTIO_BASE_URL = "https://api.put.io/v2";

sub new {
    # Check for common user mistake
    Carp::croak("Options to WebService::PutIOv2 should be key/value pairs, not hash reference")
        if ref($_[1]) eq 'HASH'; 

	my ($class,%params) = @_;
	my $self = {};
	$self->{'access_token'} = delete $params{'access_token'};

	my $ua = LWP::UserAgent->new();
	$ua->timeout(10);
	$ua->env_proxy;
	#$ua->proxy(['http', 'https'], 'http://localhost:8888');
	$self->{'ua'} = $ua;
	bless $self, $class;
}

sub _makeRequest {
	my ($self, $url, $isget, $recursive_count, %params) = @_;
	my $ua = $self->{"ua"};
	my $resp;
	my $uri;
	
	if ($recursive_count > 5) {
		die "Endless redirect to location: " . $url;
	}
	if ($isget) {
		$uri = URI->new($PUTIO_BASE_URL . $url);
		$params{'oauth_token'} = $self->{'access_token'};
		$uri->query_form(%params);
		$resp = $ua->get($uri);
	} else {
		$uri = $PUTIO_BASE_URL . $url."?oauth_token=". $self->{'access_token'};
		$resp = $ua->post($uri, {%params});
	}
	
	if (!$resp->is_success && !$resp->is_redirect) {
		 print "Request $uri failed: " . $resp->status_line;
		 return;
	}
	
	my $json = decode_json( $resp->content );
	
	if ($json->{"status"} eq "ERROR") {
		print "ERROR! Request failed for url $url:" . $json->{'error_message'} . "\n";
		return;
	}
	return $json;
}

sub getFilesList {
	my ($self, $folderID) = @_;
	my $json_files=$self->_makeRequest("/files/list",1,0,parent_id => $folderID);
	return unless ($json_files);
	return @{$json_files->{files}};
}

sub getFileInfo {
	my ($self, $fileId) = @_;
	my $json_files=$self->_makeRequest("/files/".$fileId,1,0);
	return unless ($json_files);
	return $json_files->{file};
}

sub getDownloadUrl {
	my ($self, $fileID) = @_;
	return $self->_makeRequest("/files/".$fileID."/download",1,0);
}

sub deleteFile {
	my ($self, $folderID) = @_;
	my $status = $self->_makeRequest("/files/delete",0,0,file_ids => $folderID);
	return unless ($status);
	return $status->{"status"} eq "OK";
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Stefan Profanter, C<< <profanter at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-webservice-putiov2 at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WebService-PutIOv2>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WebService::PutIOv2


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WebService-PutIOv2>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WebService-PutIOv2>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WebService-PutIOv2>

=item * Search CPAN

L<http://search.cpan.org/dist/WebService-PutIOv2/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Stefan Profanter.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of WebService::PutIOv2
