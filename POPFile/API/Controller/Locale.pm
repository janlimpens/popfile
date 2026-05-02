package POPFile::API::Controller::Locale;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub _lang_dir($self) { $self->popfile_lang_dir }

sub _read_msg_file($self, $file) {
    my %data;
    open my $fh, '<:encoding(UTF-8)', $file or return %data;
    while (my $line = <$fh>) {
        chomp $line;
        next if $line =~ /^#/ || $line !~ /\S/;
        if ($line =~ /^(\S+)\s+(.+)/) {
            $data{$1} = $2;
        }
    }
    close $fh;
    return %data
}

sub list_locales($self) {
    my $dir = $self->_lang_dir();
    my @locales;
    for my $file (sort glob "$dir/*.msg") {
        my $name = $file;
        $name =~ s|.*/||;
        $name =~ s|\.msg$||;
        my %data = $self->_read_msg_file($file);
        push @locales, {
            name => $name,
            code => $data{LanguageCode} // 'en',
            direction => $data{LanguageDirection} // 'ltr' };
    }
    $self->render(json => \@locales)
}

sub get_locale($self) {
    my $name = $self->param('locale');
    $name =~ s/[^A-Za-z0-9_\-]//g;
    my $file = $self->_lang_dir() . "/$name.msg";
    return $self->render(status => 404, json => { error => 'locale not found' })
        unless -f $file;
    my %strings = $self->_read_msg_file($file);
    $self->render(json => \%strings)
}

sub list_languages($self) {
    my $dir = $self->_lang_dir();
    my @languages;
    for my $file (sort glob "$dir/*.msg") {
        my $code = $file;
        $code =~ s|.*/||;
        $code =~ s|\.msg$||;
        my %data = $self->_read_msg_file($file);
        push @languages, { code => $code, name => $data{Language_Name} // $code };
    }
    @languages = sort { $a->{name} cmp $b->{name} } @languages;
    $self->render(json => \@languages)
}

1;
