package App::cpanminus::script::Patch::UseURIFromFoundMirror;

# DATE
# VERSION

use 5.010001;
use strict;
no warnings;

use Module::Patch 0.12 qw();
use base qw(Module::Patch);

my $_search_module = sub {
    my($self, $module, $version) = @_;
    if ($self->{mirror_index}) {
        $self->mask_output( chat => "Searching $module on mirror index $self->{mirror_index} ...\n" );
        my $pkg = $self->search_mirror_index_file($self->{mirror_index}, $module, $version);
        return $pkg if $pkg;
        unless ($self->{cascade_search}) {
            $self->mask_output( diag_fail => "Finding $module ($version) on mirror index $self->{mirror_index} failed." );
            return;
        }
    }
    unless ($self->{mirror_only}) {
        my $found = $self->search_database($module, $version);
        return $found if $found;
    }
  MIRROR: for my $mirror (@{ $self->{mirrors} }) {
        $self->mask_output( chat => "Searching $module on mirror $mirror ...\n" );
        my $name = '02packages.details.txt.gz';
        my $uri  = "$mirror/modules/$name";
        my $gz_file = $self->package_index_for($mirror) . '.gz';
        unless ($self->{pkgs}{$uri}) {
            $self->mask_output( chat => "Downloading index file $uri ...\n" );
            $self->mirror($uri, $gz_file);
            $self->generate_mirror_index($mirror) or next MIRROR;
            $self->{pkgs}{$uri} = "!!retrieved!!";
        }
        {
            # only use URI from the found mirror
            local $self->{mirrors} = [$mirror];
            my $pkg = $self->search_mirror_index($mirror, $module, $version);
            return $pkg if $pkg;
        }
        $self->mask_output( diag_fail => "Finding $module ($version) on mirror $mirror failed." );
    }
    return;
};

sub patch_data {
    return {
        v => 3,
        patches => [
            {
                action      => 'replace',
                sub_name    => 'search_module',
                code        => $_search_module,
            },
        ],
   };
}

1;
# ABSTRACT: Only use URI from mirror where we found the module

=for Pod::Coverage ^(patch_data)$

=head1 SYNOPSIS

In the command-line:

 % perl -MModule::Load::In::INIT=App::cpanminus::script::Patch::UseURIFromFoundMirror `which cpanm` ...


=head1 DESCRIPTION

This is
L<https://github.com/perlancar/operl-App-cpanminus/commit/09fc2da14bc19da508375b8c75a0156e39f5931c>
in patch form, so it can be used with stock L<cpanm>.


=head1 SEE ALSO

=cut
