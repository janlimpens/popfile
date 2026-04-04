# SPDX-License-Identifier: GPL-3.0-or-later
package Classifier::Bucket;

use Object::Pad;

class Classifier::Bucket {
    field %props;
    field $prior = 0;

    method new_from_db ($row) {
        my $b = Classifier::Bucket->new();
        $b->set_property('name', $row->{name});
        $b->set_property('color', $row->{color});
        $b->set_property('count', $row->{count});
        return $b
    }

    method get_property ($key) {
        return $props{$key}
    }

    method set_property ($key, $value) {
        $props{$key} = $value;
        return $self
    }

    method prior() { return $prior }

    method set_prior ($v) { $prior = $v }
}
