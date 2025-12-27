use strict;
use warnings;
use Text::CSV;
use utf8;
binmode(STDOUT, ":encoding(utf8)");

my @files = (
    'Lotro Instances - Seasonal.csv',
    'Lotro Instances - Instances.csv',
    'Lotro Instances - Other.csv',
    'Lotro Instances - Raids.csv',
);

my @entries;
my %index;
my $csv = Text::CSV->new({ binary => 1, sep_char => ',' });

sub split_abbr {
    my $abbr = shift // '';
    return [grep { $_ ne '' } map { s/^\s+|\s+$//gr } split(/,| or |\//i, $abbr)];
}

sub split_group {
    my $group = shift // '';
    return [grep { $_ ne '' } map { s/^\s+|\s+$//gr } split(/\s*[,\/]\s*/, $group)];
}

sub split_level {
    my $level = shift // '';
    if ($level =~ /^(\d+)-(\d+)$/) {
        return ($1+0, $2+0);
    } elsif ($level =~ /^(\d+)$/) {
        return ($1+0, undef);
    }
    return (undef, undef);
}

sub significant_keywords {
    my $name = shift // '';
    my @words = grep { length($_) > 2 && $_ !~ /^(the|of|and|in|at|on|to|for|with|by|from)$/i }
        split(/\W+/, $name);
    return @words;
}

for my $file (@files) {
    open my $fh, '<:encoding(utf8)', $file or die "Can't open $file: $!";
    my $header = $csv->getline($fh);
    my %col;
    @col{@$header} = (0..$#$header);

    while (my $row = $csv->getline($fh)) {
        my %data;
        @data{@$header} = @$row;

        my ($level_lower, $level_upper) = split_level($data{'Level'});
        my $abbrs = split_abbr($data{'Abbr.'});
        my $groups = split_group($data{'Group'});

        my $type = 'other';
        if ($file =~ /Raid/i) {
            $type = 'raid';
        } elsif ($file =~ /Instance/i) {
            $type = 'instance';
        } elsif ($file =~ /Seasonal/i) {
            $type = 'seasonal';
        }

        my $entry = {
            category    => $data{'Category'},
            name        => $data{'Name'},
            abbr        => $abbrs,
            region      => $data{'Region'},
            level_lower => $level_lower,
            level_upper => $level_upper,
            tiers       => (defined $data{'Tiers'} && $data{'Tiers'} =~ /^\d+$/ ? $data{'Tiers'}+0 : undef),
            group       => $groups,
            type        => $type
        };
        push @entries, $entry;

        my $idx = scalar(@entries);
        for my $abbr (@$abbrs) {
            $index{$abbr} ||= [];
            push @{$index{$abbr}}, $idx;
        }
        for my $kw (significant_keywords($data{'Name'})) {
            $index{$kw} ||= [];
            push @{$index{$kw}}, $idx;
        }
    }
    close $fh;
}

# Output Lua table
print "LFFBoardData = {\n";
for my $e (@entries) {
    print "    {\n";
    print "        category = " . lua_str($e->{category}) . ",\n";
    print "        name = " . lua_str($e->{name}) . ",\n";
    print "        abbr = " . lua_array($e->{abbr}) . ",\n";
    print "        region = " . lua_str($e->{region}) . ",\n";
    print "        level_lower = " . ($e->{level_lower} // 'nil') . ",\n";
    print "        level_upper = " . (defined $e->{level_upper} ? $e->{level_upper} : 'nil') . ",\n";
    print "        tiers = " . ($e->{tiers} // 'nil') . ",\n";
    print "        group = " . lua_array($e->{group}) . "\n";
    print "    },\n";
}
print "}\n\n";

# Output Lua index
# print "LFFBoardIndex = {\n";
# for my $k (sort keys %index) {
#     print "    [", lua_str($k), "] = {", join(",", @{$index{$k}}), "},\n";
# }
# print "}\n";

sub lua_str {
    my $s = shift // '';
    $s =~ s/"/\\"/g;
    return '"' . $s . '"';
}

sub lua_array {
    my $arr = shift // [];
    return '{' . join(',', map { lua_str($_) } @$arr) . '}';
}
