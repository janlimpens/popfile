#! /usr/bin/env perl

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => 'POPFile',
    VERSION => '1.1.3',
    ABSTRACT => 'POPFile email classifier',
    AUTHOR => 'Jan Limpens <jan@limpens.com>',

    PREREQ_PM => {
        'DBI' => 0,
        'DBD::Pg' => 0,
        'HTTP::Daemon' => 0,
        'HTTP::Status' => 0,
        'LWP::UserAgent' => 0,
        'DBD::SQLite' => 0, #  (if you are using the default SQLite for the backend database)
            # IMPORTANT NOTE: There are two incompatible flavours of SQLite: 2.x and 3.x. POPFile 1.1.0 (or later) uses SQLite 3.x therefore it requires DBD::SQLite v1.00 or later (1.1.0 was tested using v1.13 and v1.14). POPFile 0.25.0 to 1.0.1 used SQLite 2.x and requires DBD::SQLite v0.31 which is the last version of DBD::SQLite based upon SQLite 2.x. (To use that old version, you will need to specify the full path when you install from CPAN, e.g., cpan> install M/MS/MSERGEANT/DBD-SQLite-0.31.tar.gz) More detail can be found here
        # 'DBD::SQLite2' => 0, #(if you are using any POPFile version between 0.22.5 and 1.0.1 or upgrading to 1.1.0 (or later) from 0.22.0, 0.22.1, 0.22.2, 0.22.3, 0.22.4, 0.22.5, 1.0.0 or 1.0.1)
        # 'DBD::mysql' => 0, #(if you are using MySQL for the backend database)
        'Digest::base' => 0,
        'Digest::MD5' => 0,
        'HTML::Tagset' => 0,
        'MIME::Base64' => 0,
        'MIME::QuotedPrint' => 0,
        'Date::Parse' => 0, # (all platforms except Windows)
        'HTML::Template' => 0,
        # 'Text::Kakasi' => 0, #(if you want Japanese language support)
        # 'Encode' => 0, #(if you want Japanese/Korean language support)
        # 'IO::Socket::Socks' => 0, # (if you want to use a SOCKS proxy)
        # 'IO::Socket::SSL' => 0, #(if you want to use SSL)
        # 'Net::SSLeay' => 0, # (if you want to use SSL)
        # 'TimeDate' => 0 , #(on Windows only)
        # 'SOAP::Lite' => 0, # (if you want to use XMLRPC)
        # 'XMLRPC::Lite' => 0, #(if you want to use XMLRPC on Windows)
        # 'File::Glob::Windows' => 0, # (if you want Japanese language support on Windows)
        # 'Win32::GUI' => 0,# (POPFile 1.1.0 or later on Windows only (which is used for Tray icon support) )
        'Sort::Key::Natural' => 0
    },

    # EXE_FILES    => ['bin/popfile'],
);
