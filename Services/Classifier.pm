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
    field $classifier :writer(set_classifier) = undef;
    field $history :writer(set_history) = undef;
    field $session = '';

    BUILD {
        $self->set_name('classifier_service');
    }

    method start {
        $session = $classifier->get_session_key( 'admin', '' );
        return defined( $session ) ? 1 : 0;
    }

    method stop {
        if ( $session ne '' ) {
            $classifier->release_session_key( $session );
            $session = '';
        }
    }

=head1 METHODS

=head2 Classification

Methods that classify or modify messages using the Bayes engine.

=cut

    method classify_message ($mail, $client, $nosave, $class, $slot, $echo, $crlf) {
        return $classifier->classify_and_modify(
            $session, $mail, $client, $nosave, $class, $slot, $echo, $crlf );
    }

    # --- Classify only (no modification) ---

    method classify ($file)     { $classifier->classify( $session, $file ) }

=head2 Buckets

Methods to query and manage classification buckets.

=cut

    method get_buckets          { $classifier->get_buckets( $session ) }
    method get_all_buckets      { $classifier->get_all_buckets( $session ) }
    method get_pseudo_buckets   { $classifier->get_pseudo_buckets( $session ) }
    method is_bucket ($b)       { $classifier->is_bucket( $session, $b ) }
    method is_pseudo_bucket ($b){ $classifier->is_pseudo_bucket( $session, $b ) }
    method create_bucket ($b)   { $classifier->create_bucket( $session, $b ) }
    method delete_bucket ($b)   { $classifier->delete_bucket( $session, $b ) }
    method rename_bucket ($old, $new) { $classifier->rename_bucket( $session, $old, $new ) }
    method clear_bucket ($b)    { $classifier->clear_bucket( $session, $b ) }

    # --- Bucket statistics ---

    method get_bucket_word_count ($b)       { $classifier->get_bucket_word_count( $session, $b ) }
    method get_bucket_unique_count ($b)     { $classifier->get_bucket_unique_count( $session, $b ) }
    method get_word_count                   { $classifier->get_word_count( $session ) }
    method get_unique_word_count            { $classifier->get_unique_word_count( $session ) }
    method get_bucket_word_list ($b, $pfx)  { $classifier->get_bucket_word_list( $session, $b, $pfx ) }
    method get_bucket_word_prefixes ($b)    { $classifier->get_bucket_word_prefixes( $session, $b ) }
    method get_count_for_word ($b, $w)      { $classifier->get_count_for_word( $session, $b, $w ) }

    # --- Bucket parameters / color ---

    method get_bucket_parameter ($b, $p)        { $classifier->get_bucket_parameter( $session, $b, $p ) }
    method set_bucket_parameter ($b, $p, $v)    { $classifier->set_bucket_parameter( $session, $b, $p, $v ) }
    method get_bucket_color ($b)                { $classifier->get_bucket_color( $session, $b ) }
    method set_bucket_color ($b, $c)            { $classifier->set_bucket_color( $session, $b, $c ) }

    # --- Training ---

    method add_message_to_bucket ($b, $file)    { $classifier->add_message_to_bucket( $session, $b, $file ) }
    method add_messages_to_bucket ($b, @files)  { $classifier->add_messages_to_bucket( $session, $b, @files ) }
    method remove_message_from_bucket ($b, $f)  { $classifier->remove_message_from_bucket( $session, $b, $f ) }

=head2 Magnets

Methods to query and manage magnets (forced-classification rules).

=cut

    method get_buckets_with_magnets             { $classifier->get_buckets_with_magnets( $session ) }
    method get_magnet_types                     { $classifier->get_magnet_types( $session ) }
    method get_magnet_types_in_bucket ($b)      { $classifier->get_magnet_types_in_bucket( $session, $b ) }
    method get_magnets ($b, $t)                 { $classifier->get_magnets( $session, $b, $t ) }
    method create_magnet ($b, $t, $text)        { $classifier->create_magnet( $session, $b, $t, $text ) }
    method delete_magnet ($b, $t, $text)        { $classifier->delete_magnet( $session, $b, $t, $text ) }
    method clear_magnets                        { $classifier->clear_magnets( $session ) }
    method magnet_count                         { $classifier->magnet_count( $session ) }

=head2 Stopwords

Methods to query and manage the stopword list.

=cut

    method get_stopword_list    { $classifier->get_stopword_list( $session ) }
    method add_stopword ($w)    { $classifier->add_stopword( $session, $w ) }
    method remove_stopword ($w) { $classifier->remove_stopword( $session, $w ) }

    # --- HTML coloring ---

    method get_html_colored_message ($file)             { $classifier->get_html_colored_message( $session, $file ) }
    method fast_get_html_colored_message ($f, $m, $i)   { $classifier->fast_get_html_colored_message( $session, $f, $m, $i ) }

=head2 Setters

Called by C<POPFile::Loader::CORE_link_components> to inject dependencies.

=cut


=head2 Accessors

Direct access to internal objects for XML-RPC and legacy callers.

=cut

    method session      { $session }
    method bayes        { $classifier }
    method history_obj  { $history }

} # end class Services::Classifier

1;
