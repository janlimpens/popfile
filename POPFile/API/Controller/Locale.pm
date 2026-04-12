use Object::Pad;

class POPFile::API::Controller::Locale :isa(Mojolicious::Controller);

use File::Spec;

method _lang_dir() {
    File::Spec->catdir($ENV{POPFILE_ROOT} // '.', 'languages')
}

method _read_msg_file($file) {
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

method list_locales() {
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

method get_locale() {
    my $name = $self->param('locale');
    $name =~ s/[^A-Za-z0-9_\-]//g;
    my $file = $self->_lang_dir() . "/$name.msg";
    return $self->render(status => 404, json => { error => 'locale not found' })
        unless -f $file;
    my %strings = $self->_read_msg_file($file);
    $self->render(json => \%strings)
}

method list_languages() {
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
