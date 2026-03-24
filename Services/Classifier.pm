# POPFILE LOADABLE MODULE
package Services::Classifier;

#----------------------------------------------------------------------------
#
# This module provides a session-less facade over Classifier::Bayes.
# Proxy and UI modules use this instead of calling Bayes directly.
# The service manages its own admin session key and exposes every
# Bayes operation without requiring callers to track the session.
#
# Copyright (c) 2001-2011 John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify it
#   under the terms of version 2 of the GNU General Public License as
#   published by the Free Software Foundation.
#
#----------------------------------------------------------------------------

use Object::Pad;
use locale;

class Services::Classifier :isa(POPFile::Module) {

    BUILD {
        $self->{classifier__} = undef;
        $self->{history__}    = undef;
        $self->{session__}    = '';
        $self->name('classifier_service');
    }

    method start {
        $self->{session__} = $self->{classifier__}->get_session_key( 'admin', '' );
        return defined( $self->{session__} ) ? 1 : 0;
    }

    method stop {
        if ( $self->{session__} ne '' ) {
            $self->{classifier__}->release_session_key( $self->{session__} );
            $self->{session__} = '';
        }
    }

    # --- Classification ---

    method classify_message ($mail, $client, $nosave, $class, $slot, $echo, $crlf) {
        return $self->{classifier__}->classify_and_modify(
            $self->{session__}, $mail, $client, $nosave, $class, $slot, $echo, $crlf );
    }

    # --- Buckets ---

    method get_buckets          { $self->{classifier__}->get_buckets( $self->{session__} ) }
    method get_all_buckets      { $self->{classifier__}->get_all_buckets( $self->{session__} ) }
    method get_pseudo_buckets   { $self->{classifier__}->get_pseudo_buckets( $self->{session__} ) }
    method is_bucket ($b)       { $self->{classifier__}->is_bucket( $self->{session__}, $b ) }
    method is_pseudo_bucket ($b){ $self->{classifier__}->is_pseudo_bucket( $self->{session__}, $b ) }
    method create_bucket ($b)   { $self->{classifier__}->create_bucket( $self->{session__}, $b ) }
    method delete_bucket ($b)   { $self->{classifier__}->delete_bucket( $self->{session__}, $b ) }
    method rename_bucket ($old, $new) { $self->{classifier__}->rename_bucket( $self->{session__}, $old, $new ) }
    method clear_bucket ($b)    { $self->{classifier__}->clear_bucket( $self->{session__}, $b ) }

    # --- Bucket statistics ---

    method get_bucket_word_count ($b)       { $self->{classifier__}->get_bucket_word_count( $self->{session__}, $b ) }
    method get_bucket_unique_count ($b)     { $self->{classifier__}->get_bucket_unique_count( $self->{session__}, $b ) }
    method get_word_count                   { $self->{classifier__}->get_word_count( $self->{session__} ) }
    method get_unique_word_count            { $self->{classifier__}->get_unique_word_count( $self->{session__} ) }
    method get_bucket_word_list ($b, $pfx)  { $self->{classifier__}->get_bucket_word_list( $self->{session__}, $b, $pfx ) }
    method get_bucket_word_prefixes ($b)    { $self->{classifier__}->get_bucket_word_prefixes( $self->{session__}, $b ) }
    method get_count_for_word ($b, $w)      { $self->{classifier__}->get_count_for_word( $self->{session__}, $b, $w ) }

    # --- Bucket parameters / color ---

    method get_bucket_parameter ($b, $p)        { $self->{classifier__}->get_bucket_parameter( $self->{session__}, $b, $p ) }
    method set_bucket_parameter ($b, $p, $v)    { $self->{classifier__}->set_bucket_parameter( $self->{session__}, $b, $p, $v ) }
    method get_bucket_color ($b)                { $self->{classifier__}->get_bucket_color( $self->{session__}, $b ) }
    method set_bucket_color ($b, $c)            { $self->{classifier__}->set_bucket_color( $self->{session__}, $b, $c ) }

    # --- Training ---

    method add_message_to_bucket ($b, $file)    { $self->{classifier__}->add_message_to_bucket( $self->{session__}, $b, $file ) }
    method add_messages_to_bucket ($b, @files)  { $self->{classifier__}->add_messages_to_bucket( $self->{session__}, $b, @files ) }
    method remove_message_from_bucket ($b, $f)  { $self->{classifier__}->remove_message_from_bucket( $self->{session__}, $b, $f ) }

    # --- Magnets ---

    method get_buckets_with_magnets             { $self->{classifier__}->get_buckets_with_magnets( $self->{session__} ) }
    method get_magnet_types                     { $self->{classifier__}->get_magnet_types( $self->{session__} ) }
    method get_magnet_types_in_bucket ($b)      { $self->{classifier__}->get_magnet_types_in_bucket( $self->{session__}, $b ) }
    method get_magnets ($b, $t)                 { $self->{classifier__}->get_magnets( $self->{session__}, $b, $t ) }
    method create_magnet ($b, $t, $text)        { $self->{classifier__}->create_magnet( $self->{session__}, $b, $t, $text ) }
    method delete_magnet ($b, $t, $text)        { $self->{classifier__}->delete_magnet( $self->{session__}, $b, $t, $text ) }
    method clear_magnets                        { $self->{classifier__}->clear_magnets( $self->{session__} ) }
    method magnet_count                         { $self->{classifier__}->magnet_count( $self->{session__} ) }

    # --- Stopwords ---

    method get_stopword_list    { $self->{classifier__}->get_stopword_list( $self->{session__} ) }
    method add_stopword ($w)    { $self->{classifier__}->add_stopword( $self->{session__}, $w ) }
    method remove_stopword ($w) { $self->{classifier__}->remove_stopword( $self->{session__}, $w ) }

    # --- HTML coloring ---

    method get_html_colored_message ($file)             { $self->{classifier__}->get_html_colored_message( $self->{session__}, $file ) }
    method fast_get_html_colored_message ($f, $m, $i)   { $self->{classifier__}->fast_get_html_colored_message( $self->{session__}, $f, $m, $i ) }

    # --- Classify only (no modification) ---

    method classify ($file)     { $self->{classifier__}->classify( $self->{session__}, $file ) }

    # --- Direct access for XML-RPC and legacy callers ---

    method session              { $self->{session__} }
    method bayes                { $self->{classifier__} }
    method history_obj          { $self->{history__} }

    # --- Setters (called by POPFile::Loader::CORE_link_components) ---

    method classifier ($c = undef) {
        $self->{classifier__} = $c if defined $c;
    }

    method history ($h = undef) {
        $self->{history__} = $h if defined $h;
    }

} # end class Services::Classifier

1;
