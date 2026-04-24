requires 'perl', '5.040';

requires 'Browser::Open', '0';
requires 'Cpanel::JSON::XS', '0';
requires 'Data::Page', '0';
requires 'Date::Parse', '0';
requires 'DBD::SQLite', '1.00';
requires 'DBI', '1.643';
requires 'Email::MIME', '0';
requires 'EV', '0';
requires 'CryptX', '0.080';
requires 'Future::AsyncAwait', '0.52';
requires 'Future::XS', '0';
requires 'HTML::Tagset', '0';
requires 'IO::Socket::Socks', '0';
requires 'IO::Socket::SSL', '0';
requires 'JSON', '0';
requires 'JSON::XS', '0';
requires 'Lingua::Identify', '0';
requires 'Lingua::Stem::Snowball', '0';
requires 'Lingua::StopWords', '0';
requires 'Log::Any', '1.7';
requires 'MIME::Base64', '0';
requires 'MIME::QuotedPrint', '0';
requires 'Mojo::SQLite', '3.009';
requires 'Mojolicious', '9.0';
requires 'Net::DNS::Native', '0';
requires 'Net::SSLeay', '0';
requires 'Object::Pad', '0.800';
requires 'Role::Tiny', '0';

# carton exec cpanm -L local --notest Module::Name
recommends 'DBD::mysql', '0';
recommends 'DBD::Pg', '0';
recommends 'Mojo::mysql', '1.25';
recommends 'Mojo::Pg', '4.27';

on 'test' => sub {
    requires 'Test2::V0', '0';
};

on 'develop' => sub {
    requires 'Mail::IMAPClient', '0';
    requires 'Test::MockObject', '0';
    requires 'Test2::V0', '0';
};
