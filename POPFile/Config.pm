# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
package POPFile::Config;

use Object::Pad;
use POPFile::Features;

class POPFile::Config;

my $instance;

field %store;

my $SCHEMA = {
    type => 'object',
    properties => {
        version => { const => 2 },
        api => {
            type => 'object',
            additionalProperties => false,
            properties => {
                port => { type => 'integer', minimum => 0, maximum => 65535 },
                password => { type => 'string' },
                static_dir => { type => 'string' },
                local => { type => 'boolean' },
                page_size => { type => 'integer', minimum => 1 },
                word_page_size => { type => 'integer', minimum => 1 },
                session_dividers => { type => 'boolean' },
                wordtable_format => { type => 'string' },
                locale => { type => 'string' },
                open_browser => { type => 'boolean' },
            },
        },
        bayes => {
            type => 'object',
            additionalProperties => false,
            properties => {
                database => { type => 'string' },
                dbconnect => { type => 'string' },
                dbuser => { type => 'string' },
                dbauth => { type => 'string' },
                corpus => { type => 'string' },
                sqlite_backup => { type => 'boolean' },
                sqlite_fast_writes => { type => 'boolean' },
                unclassified_weight => { type => 'integer' },
                subject_mod_pos => { type => 'boolean' },
                subject_mod_left => { type => 'string' },
                subject_mod_right => { type => 'string' },
                xpl_angle => { type => 'boolean' },
                stopword_ratio => { type => 'integer' },
                hostname => { type => 'string' },
                localhostname => { type => 'string' },
                bayes_magnets_enabled => { type => 'boolean' },
                nihongo_parser => { type => 'string' },
                locale => { type => 'string' },
                message_cutoff => { type => 'integer' },
            },
        },
        GLOBAL => {
            type => 'object',
            additionalProperties => false,
            properties => {
                timeout => { type => 'integer', minimum => 1 },
                msgdir => { type => 'string' },
                message_cutoff => { type => 'integer', minimum => 1 },
                debug => { type => 'integer', minimum => 0, maximum => 3 },
            },
        },
        history => {
            type => 'object',
            additionalProperties => false,
            properties => {
                history_days => { type => 'integer', minimum => 0 },
                archive => { type => 'boolean' },
                archive_classes => { type => 'integer', minimum => 0 },
                archive_dir => { type => 'string' },
            },
        },
        imap => {
            type => 'object',
            additionalProperties => false,
            properties => {
                hostname => { type => 'string' },
                port => { type => 'integer', minimum => 1, maximum => 65535 },
                login => { type => 'string' },
                password => { type => 'string' },
                use_ssl => { type => 'boolean' },
                enabled => { type => 'boolean' },
                training_mode => { type => 'boolean' },
                expunge => { type => 'boolean' },
                update_interval => { type => 'integer', minimum => 0 },
                training_limit => { type => 'integer', minimum => 0 },
                watched_folders => { type => 'string' },
                bucket_folder_mappings => { type => 'string' },
            },
        },
        logger => {
            type => 'object',
            additionalProperties => false,
            properties => {
                logdir => { type => 'string' },
                level => { type => 'integer', minimum => 0, maximum => 4 },
                log_to_stdout => { type => 'boolean' },
                log_sql => { type => 'boolean' },
                format => { type => 'string' },
            },
        },
        pop3 => {
            type => 'object',
            additionalProperties => false,
            properties => {
                port => { type => 'integer', minimum => 1, maximum => 65535 },
                secure_port => { type => 'integer', minimum => 1, maximum => 65535 },
                local => { type => 'boolean' },
                secure_server => { type => 'string' },
                toptoo => { type => 'boolean' },
                separator => { type => 'string' },
                enabled => { type => 'boolean' },
            },
        },
        smtp => {
            type => 'object',
            additionalProperties => false,
            properties => {
                port => { type => 'integer', minimum => 1, maximum => 65535 },
                chain_server => { type => 'string' },
                chain_port => { type => 'integer', minimum => 1, maximum => 65535 },
                local => { type => 'boolean' },
                enabled => { type => 'boolean' },
            },
        },
        nntp => {
            type => 'object',
            additionalProperties => false,
            properties => {
                port => { type => 'integer', minimum => 1, maximum => 65535 },
                local => { type => 'boolean' },
                headtoo => { type => 'boolean' },
                separator => { type => 'string' },
                enabled => { type => 'boolean' },
            },
        },
        wordmangle => {
            type => 'object',
            additionalProperties => false,
            properties => {
                stemming => { type => 'boolean' },
                auto_detect_language => { type => 'boolean' },
            },
        },
    },
};

method instance :common () {
    return $instance
        if $instance;
    $instance = POPFile::Config->new();
    my $path = POPFile::Config->resolve_path();
    $instance->load_file($path);
    return $instance
}

method resolve_path :common () {
    return $ENV{POPFILE_PATH}
        if $ENV{POPFILE_PATH};
    my $xdg = $ENV{XDG_CONFIG_HOME} // ($ENV{HOME} ? "$ENV{HOME}/.config" : undef);
    die "POPFile::Config: cannot resolve config path"
        unless $xdg;
    require File::Path;
    File::Path::make_path("$xdg/popfile")
        unless -d "$xdg/popfile";
    return "$xdg/popfile/config.json"
}

method load_file($path) {
    return
        unless -e $path;
    require POPFile::ConfigFile;
    my $data = POPFile::ConfigFile->new()->load($path);
    $self->_coerce_types($data, $SCHEMA->{properties});
    my $result = $self->_validate($data);
    die "POPFile::Config: invalid $path\n" . join("\n", $result->@*)
        unless $result->@* == 0;
    delete $data->{version};
    %store = $data->%*;
}

method _coerce_types($node, $schema_node) {
    require JSON::PP;
    return
        unless ref $node eq 'HASH' && ref $schema_node eq 'HASH';
    for my $key (keys $node->%*) {
        my $prop_schema = $schema_node->{$key};
        next
            unless $prop_schema;
        my $val = $node->{$key};
        if (ref $val eq 'HASH' && ref $prop_schema->{properties} eq 'HASH') {
            $self->_coerce_types($val, $prop_schema->{properties});
        } elsif (!ref $val && defined $val) {
            my $type = $prop_schema->{type};
            next
                unless defined $type;
            if ($type eq 'boolean') {
                $node->{$key} = $val ? JSON::PP::true() : JSON::PP::false();
            } elsif ($type eq 'integer' && $val =~ /^-?\d+$/) {
                $node->{$key} = 0 + $val;
            }
        }
    }
}

method _validate($data) {
    require JSON::Schema::Modern;
    my $js = JSON::Schema::Modern->new();
    my $result = $js->evaluate($data, $SCHEMA);
    return []
        if $result->{valid};
    my @messages;
    for my $e ($result->{errors}->@*) {
        push @messages, $e->{instanceLocation} . ': ' . $e->{error};
    }
    return \@messages
}

=head2 validate_doc

    my @errors = POPFile::Config->validate_doc($data)->@*;

Class method for validating a config hash against the schema.
Used by the API controller before saving config changes.

=cut

method validate_doc :common ($data) {
    my $doc = +{version => 2, %{ $data // {} }};
    my $tmp = POPFile::Config->new();
    $tmp->_coerce_types($doc, $SCHEMA->{properties});
    my $result = $tmp->_validate($doc);
    die "POPFile::Config: invalid config\n" . join("\n", $result->@*)
        unless $result->@* == 0;
    return
}

method get($ns, $key) {
    $store{$ns}{$key}
}

1;
