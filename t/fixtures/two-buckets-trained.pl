{
    buckets => [qw(inbox spam)],
    train   => {
        inbox => [ ('ham.eml')  x 5 ],
        spam  => [ ('spam.eml') x 5 ],
    },
}
