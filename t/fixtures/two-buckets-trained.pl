# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
{
    buckets => [qw(inbox spam)],
    train => {
        inbox => [ ('ham.eml')  x 5 ],
        spam => [ ('spam.eml') x 5 ],
    },
}
