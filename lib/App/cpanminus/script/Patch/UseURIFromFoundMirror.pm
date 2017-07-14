package App::cpanminus::script::Patch::UseURIFromFoundMirror;

# DATE
# VERSION

use 5.010001;
use strict;
no warnings;

use Module::Patch 0.12 qw();
use base qw(Module::Patch);

my $_search_module = sub {
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
