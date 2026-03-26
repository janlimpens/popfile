# POPFile dependency manifest
# Install with: cpanm --installdeps .

requires 'perl', '5.038';

# Core runtime dependencies
requires 'DBI',               '1.643';
requires 'DBD::SQLite',       '1.00';
requires 'Date::Format',      '0';
requires 'Date::Parse',       '0';
requires 'Digest::MD5',       '0';
requires 'HTML::Tagset',      '0';
requires 'HTML::Template',    '0';
requires 'MIME::Base64',      '0';
requires 'MIME::QuotedPrint', '0';
requires 'Log::Any',          '1.7';
requires 'Object::Pad',       '0.800';
requires 'Sort::Key::Natural','0';
requires 'Mojolicious',       '9.0';
requires 'Cpanel::JSON::XS',  '0';
requires 'JSON',              '0';
requires 'JSON::XS',          '0';
requires 'IO::Socket::SSL',    '0';
requires 'Net::SSLeay',        '0';
requires 'IO::Socket::Socks',  '0';
requires 'Net::DNS::Native',   '0';
requires 'EV',                 '0';

# Optional: alternative database backends
recommends 'DBD::mysql', '0';
recommends 'DBD::Pg',    '0';

# Optional: XML-RPC interface
recommends 'SOAP::Lite', '0';

# Optional: Japanese language support
recommends 'Text::Kakasi', '0';
recommends 'Encode::Guess', '0';

# Word stemming, multilingual stopwords, and language detection
requires 'Lingua::Stem::Snowball', '0';
requires 'Lingua::StopWords',      '0';
requires 'Lingua::Identify',       '0';

# Development and testing
on 'test' => sub {
    requires 'Test2::V0', '0';
};

on 'develop' => sub {
    requires 'Test2::V0',       '0';
    requires 'Test::MockObject', '0';
};
