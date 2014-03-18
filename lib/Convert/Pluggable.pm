package Convert::Pluggable;

use 5.006;
use strict;
use warnings FATAL => 'all';

use Scalar::Util qw/looks_like_number/;
use Data::Float qw/float_is_infinite float_is_nan/;

use Exporter qw(import);
 
our @EXPORT_OK = qw(convert);

=head1 NAME

Convert::Pluggable - convert between various units of measurement

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head2 new

=cut
sub new {
    my $class = shift;
    my $self = bless {}, $class;

    return $self;
}


=head1 SYNOPSIS
    convert between various units of measurement

    use Convert::Pluggable;

    ...

=head1 EXPORT

convert

=head1 SUBROUTINES/METHODS
    =item new 
    =item convert_temperatures
    =item convert
    =item get_matches 
    =item get_units
=cut

my @types = @{get_units()};

=head2 convert_temperatures
    convert between temperature units: fahrenheit, rankine, etc.
=cut
sub convert_temperatures {
    # ##
    # F  = (C * 1.8) + 32            # celsius to fahrenheit
    # F  = 1.8 * (K - 273.15) + 32   # kelvin  to fahrenheit
    # F  = R - 459.67                # rankine to fahrenheit
    # F  = (Ra * 2.25) + 32          # reaumur to fahrenheit
    #
    # C  = (F - 32) * 0.555          # fahrenheit to celsius
    # K  = (F + 459.67) * 0.555      # fahrenheit to kelvin
    # R  = F + 459.67                # fahrenheit to rankine
    # Ra = (F - 32) * 0.444          # fahrenheit to reaumur
    # ##

    my $from = shift;
    my $to = shift;
    my $factor = shift;
    
    # convert $from to fahrenheit:
    if    ($from =~ /fahrenheit|f/i) { $factor = $factor;                       }
    elsif ($from =~ /celsius|c/i)    { $factor = ($factor * 1.8) + 32;          }
    elsif ($from =~ /kelvin|k/i)     { $factor = 1.8 * ($factor - 273.15) + 32; }
    elsif ($from =~ /rankine|r/i)    { $factor = $factor - 459.67;              }
    else                             { $factor = ($factor * 2.25) + 32;         }    # reaumur 
    
    # convert fahrenheit $to:
    if    ($to   =~ /fahrenheit|f/i) { $factor = $factor;                       }
    elsif ($to   =~ /celsius|c/i)    { $factor = ($factor - 32) * 0.555;        }
    elsif ($to   =~ /kelvin|k/i)     { $factor = ($factor + 459.67) * 0.555;    }
    elsif ($to   =~ /rankine|r/i)    { $factor = $factor + 459.67;              }
    else                             { $factor = ($factor - 32) * 0.444;        }    # reaumur 

    return $factor;
}

=head2 get_matches
       helper function:
           [1] get factors for later calculating conversion
           [2] get trigger 'types' to determine if we can perform a calculation in the first place
           [3] get canoncial units for massaging output
           [4] determine if a unit may be negative 
=cut
sub get_matches {
    my $matches = shift;
    my @matches = @{$matches};

    $matches[0] =~ s/"/inches/; 
    $matches[0] =~ s/'/feet/; 
    $matches[1] =~ s/"/inches/; 
    $matches[1] =~ s/'/feet/; 
    
    # often a choke point, so leaving this in:
    #use Data::Dumper; print STDERR Dumper(\@matches);
    
    my @match_types = ();
    my @factors = ();
    my @units = ();
    my @can_be_negative = ();
    
    foreach my $match (@matches) {
        foreach my $type (@types) {
            if ($match eq $type->{'unit'} || grep { $_ eq $match } @{$type->{'aliases'}}) {
                push(@match_types, $type->{'type'});
                push(@factors, $type->{'factor'});
                push(@units, $type->{'unit'});
                push(@can_be_negative, $type->{'can_be_negative'} || '0');
            }
        }
    }
   
    return if scalar(@match_types) != 2; 
    return if scalar(@factors) != 2;
    return if scalar(@units) != 2;
    return if scalar(@can_be_negative) != 2;
    
    my %matches = (
        'type_1'            => $match_types[0],
        'type_2'            => $match_types[1],
        'factor_1'          => $factors[0],
        'factor_2'          => $factors[1],
        'from_unit'         => $units[0],
        'to_unit'           => $units[1],
        'can_be_negative_1' => $can_be_negative[0],
        'can_be_negative_2' => $can_be_negative[1],
    );

    return \%matches;
}


=head2 convert
    C< my $result = $c->convert( { 'factor' => '5', 'fromUnit' => 'feet', 'toUnit' => 'inches', 'precision' => '3', } ); >
=cut
sub convert {
    my $self = shift;

    my $conversion = shift;     

    my $matches = get_matches([$conversion->{'fromUnit'}, $conversion->{'toUnit'}]);  
   
    if (looks_like_number($conversion->{'factor'})) {
        # looks_like_number thinks 'Inf' and 'NaN' are numbers:
        return if float_is_infinite($conversion->{'factor'}) || float_is_nan($conversion->{'factor'});

        return if $conversion->{'factor'} < 0 && !($matches->{'can_be_negative_1'} && $matches->{'can_be_negative_2'}); 
    }
    else {
        # if it doesn't look like a number, and it contains a number (e.g., '6^2'):
        return if $conversion->{'factor'} =~ /\d/;
    }
    
    return if $conversion->{'factor'} =~ /[[:alpha:]]/;

    # for rounding to match input precision:
    my $nearest = '1';
    for my $i (1 .. $conversion->{'precision'} - 1) {
        $nearest = '0' . $nearest;
    }   # e.g., if requested (input) precision is 3 => $nearest = '001'
    $nearest = '.' . $nearest;
    
    # matches must be of the same type (e.g., can't convert mass to length):
    return if ($matches->{'type_1'} ne $matches->{'type_2'});

    # run the conversion:
    # temperatures don't have 1:1 conversions, so they get special treatment:
    if ($matches->{'type_1'} eq 'temperature') {
        return sprintf("%.$conversion->{'precision'}f", convert_temperatures($matches->{'from_unit'}, $matches->{'to_unit'}, $conversion->{'factor'}));
    }

    my $result = $conversion->{'factor'} * ($matches->{'factor_2'} / $matches->{'factor_1'});
    
    return sprintf("%.$conversion->{'precision'}f", $result);
};

=head1 AUTHOR

bradley andersen, C<< <bradley at pvnp.us> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-convert::pluggable at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Convert::Pluggable>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Convert::Pluggable

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Convert::Pluggable>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Convert::Pluggable>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Convert::Pluggable>

=item * Search CPAN

L<http://search.cpan.org/dist/Convert::Pluggable/>

=back

=head1 ACKNOWLEDGEMENTS
    Special thanks to @mintsoft and @jagtalon

=head1 LICENSE AND COPYRIGHT

Copyright 2014 bradley andersen.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

=head2 get_units
    this is where the unit definitions come from.  if you want to add new unit types, do so here.
=cut
sub get_units {
    # metric ton is base unit for mass
    # known SI units and aliases / plurals
    my @mass = (
        {
            'unit'    => 'metric ton',
            'factor'  => '1',
            'aliases' => ['tonne', 't', 'mt', 'te', 'metric tons', 'tonnes', 'ts', 'mts', 'tes'],
            'type'    => 'mass',
        },
        {
            'unit'    => 'ounce',
            'factor'  => '35274',
            'aliases' => ['oz', 'ounces', 'ozs'],
            'type'    => 'mass',
        },
        {
            'unit'    => 'pound',
            'factor'  => '2204.62',
            'aliases' => ['lb', 'lbm', 'pound mass', 'pounds', 'lbs', 'lbms', 'pounds mass'],
            'type'    => 'mass',
        },
        {
            'unit'    => 'stone',
            'factor'  => '157.473',
            'aliases' => ['st', 'stones', 'sts'],
            'type'    => 'mass',
        },
        {
            'unit'    => 'long ton',
            'factor'  => '0.984207',
            'aliases' => ['weight ton', 'imperial ton', 'long tons', 'weight tons', 'imperial tons'],
            'type'    => 'mass',
        },
        {
            'unit'    => 'microgram',
            'factor'  => '1000000000',
            'aliases' => ['mcg', 'micrograms', 'mcgs'],
            'type'    => 'mass',
        },
        {
            'unit'    => 'kilogram',
            'factor'  => '1000',
            'aliases' => ['kg', 'kilo', 'kilogramme', 'kilograms', 'kgs', 'kilos', 'kilogrammes'],
            'type'    => 'mass',
        },
        {
            'unit'    => 'gram',
            'factor'  => '1000000',
            'aliases' => ['g', 'gm', 'gramme', 'grams', 'gs', 'gms', 'grammes'],
            'type'    => 'mass',
        },
        {
            'unit'    => 'milligram',
            'factor'  => '1000000000',
            'aliases' => ['mg', 'milligrams', 'mgs'],
            'type'    => 'mass',
        },
        {
            'unit'    => 'ton',
            'factor'  => '1.10231',
            'aliases' => ['short ton', 'short tons', 'tons'],
            'type'    => 'mass',
        },
    );

    # meter is the base unit for length
    # known SI units and aliases / plurals
    my @length = (
        {
            'unit'      => 'meter',
            'factor'    => '1',
            'aliases'   => ['meters', 'metre', 'metres', 'm', 'ms'],
            'type'      => 'length',
        },
        {
            'unit'      => 'kilometer',
            'factor'    => '0.001',
            'aliases'   => ['kilometers', 'kilometre', 'kilometres', 'km', 'kms', 'klick', 'klicks'],
            'type'      => 'length',
        },
        {
            'unit'      => 'centimeter',
            'factor'    => '100',
            'aliases'   => ['centimeters', 'centimetre', 'centimetres', 'cm', 'cms'],
            'type'      => 'length',
        },
        {
            'unit'      => 'millimeter',
            'factor'    => '1000',
            'aliases'   => ['millimeters', 'millimetre', 'millimetres', 'mm', 'mms'],
            'type'      => 'length',
        },
        {
            'unit'      => 'mile',
            'factor'    => '0.000621371',
            'aliases'   => ['miles', 'statute mile', 'statute miles', 'land mile', 'land miles'],
            'type'      => 'length',
        },
        {
            'unit'      => 'yard',
            'factor'    => '1.09361',
            'aliases'   => ['yards', 'yd', 'yds', 'yrds'],
            'type'      => 'length',
        },
        {
            'unit'      => 'foot',
            'factor'    => '3.28084',
            'aliases'   => ['feet', 'ft', 'international foot', 'international feet', 'survey foot', 'survey feet'],
            'type'      => 'length',
        },
        {
            'unit'      => 'inch',
            'factor'    => '39.3701',
            'aliases'   => ['inches', 'in', 'ins'],
            'type'      => 'length',
        },
        {
            'unit'      => 'nautical mile',
            'factor'    => '0.000539957',
            'aliases'   => ['nautical miles', 'n', 'ns', 'nm', 'nms', 'nmi', 'nmis'],
            'type'      => 'length',
        },
        {
            'unit'      => 'furlong',
            'factor'    => (1/201.168),
            'aliases'   => ['furlongs'],
            'type'      => 'length',
        },
        {
            'unit'      => 'chain',
            'factor'    => (1/20.1168),
            'aliases'   => ["gunter's chains", 'chains'],
            'type'      => 'length',
        },
        {
            'unit'      => 'link',
            'factor'    => (1/0.201168),
            'aliases'   => ["gunter's links", 'links'],
            'type'      => 'length',
        },
        {
            'unit'      => 'rod',
            'factor'    => 1/(5.0292),
            'aliases'   => ['rods'],
            'type'      => 'length',
        },
        {
            'unit'      => 'fathom',
            'factor'    => 1/(1.853184),
            'aliases'   => ['fathoms', 'ftm', 'ftms'],
            'type'      => 'length',
        },
        {
            'unit'      => 'league',
            'factor'    => 1/(4828.032),
            'aliases'   => ['leagues'],
            'type'      => 'length',
        },
        {
            'unit'      => 'cable',
            'factor'    => 1/(185.3184),
            'aliases'   => ['cables'],
            'type'      => 'length',
        },
        {
            'unit'      => 'light year',
            'factor'    => (1/9460730472580800),
            'aliases'   => ['light years', 'ly', 'lys'],
            'type'      => 'length',
        },
        {
            'unit'      => 'parsec',
            'factor'    => (1/30856776376340067),
            'aliases'   => ['parsecs', 'pc', 'pcs'],
            'type'      => 'length',
        },
        {
            'unit'      => 'astronomical unit',
            'factor'    => (1/149597870700),
            'aliases'   => ['astronomical units', 'au', 'aus'],
            'type'      => 'length',
        },
    );

    # day is base unit for time
    # known SI units and aliases / plurals
    my @time = (
        {
            'unit'      => 'day',
            'factor'    => '1',
            'aliases'   => ['days', 'dy', 'dys', 'd'],
            'type'      => 'duration',
        },
        {
            'unit'      => 'second',
            'factor'    => '86400',
            'aliases'   => ['seconds', 'sec', 's'],
            'type'      => 'duration',
        },
        {
            'unit'      => 'millisecond',
            'factor'    => '86400000',
            'aliases'   => ['milliseconds', 'millisec', 'millisecs', 'ms'],
            'type'      => 'duration',
        },
        {
            'unit'      => 'microsecond',
            'factor'    => '86400000000',
            'aliases'   => ['microseconds', 'microsec', 'microsecs', 'us'],
            'type'      => 'duration',
        },
        {
            'unit'      => 'minute',
            'factor'    => '1440',
            'aliases'   => ['minutes', 'min', 'mins'],
            'type'      => 'duration',
        },
        {
            'unit'      => 'hour',
            'factor'    => '24',
            'aliases'   => ['hours', 'hr', 'hrs', 'h'],
            'type'      => 'duration',
        },
        {
            'unit'      => 'week',
            'factor'    => 1/7,
            'aliases'   => ['weeks', 'wks', 'wk'],
            'type'      => 'duration',
        },
        {
            'unit'      => 'fortnight',
            'factor'    => 1/14,
            'aliases'   => [],
            'type'      => 'duration',
        },
        {    # a month being defined as an average earth month (30.42)
            'unit'      => 'month',
            'factor'    => 1/30.42,
            'aliases'   => ['months', 'mons', 'mns', 'mn'],
            'type'      => 'duration',
        },
        {
            'unit'      => 'year',
            'factor'    => 1/365,
            'aliases'   => ['years', 'yr', 'yrs'],
            'type'      => 'duration',
        },
        {
            'unit'      => 'leap year',
            'factor'    => 1/366,
            'aliases'   => ['leap years', 'leapyear', 'leapyr', 'leapyrs'],
            'type'      => 'duration',
        },
    );

    # pascal is base unit for pressure
    # known SI units and aliases / plurals
    my @pressure = (
        {
            'unit'      => 'pascal',
            'factor'    => 1,
            'aliases'   => ['pascals', 'pa', 'pas'],
            'type'      => 'pressure',
        },
        {
            'unit'      => 'kilopascal',
            'factor'    => (1/1000),
            'aliases'   => ['kilopascals', 'kpa', 'kpas'],
            'type'      => 'pressure',
        },
        {
            'unit'      => 'megapascal',
            'factor'    => (1/1_000_000),
            'aliases'   => ['megapascals', 'megapa', 'megapas'],
            'type'      => 'pressure',
        },
        {
            'unit'      => 'gigapascal',
            'factor'    => (1/1_000_000_000),
            'aliases'   => ['gigapascals', 'gpa', 'gpas'],
            'type'      => 'pressure',
        },
        {
            'unit'      => 'bar',
            'factor'    => 1/(100_000),
            'aliases'   => ['bars', 'pa', 'pas'],
            'type'      => 'pressure',
        },
        {
            'unit'      => 'atmosphere',
            'factor'    => 1/(101_325),
            'aliases'   => ['atmospheres', 'atm', 'atms'],
            'type'      => 'pressure',
        },
        {
            'unit'      => 'pounds per square inch',
            'factor'    => 1/6894.8,
            'aliases'   => ['psis', 'psi', 'lbs/inch^2', 'p.s.i.', 'p.s.i'],
            'type'      => 'pressure',
        },
    );

    # joule is base unit for energy
    # known SI units and aliases / plurals
    my @energy = (
        {
            'unit'      => 'joule',
            'factor'    => 1,
            'aliases'   => ['joules', 'j', 'js'],
            'type'      => 'energy',
        },
        {
            'unit'      => 'watt-second',
            'factor'    => (1),
            'aliases'   => ['watt second', 'watt seconds', 'ws'],
            'type'      => 'energy',
        },
        {
            'unit'      => 'watt-hour',
            'factor'    => (1/3600),
            'aliases'   => ['watt hour', 'watt hours', 'wh'],
            'type'      => 'energy',
        },
        {
            'unit'      => 'kilowatt-hour',
            'factor'    => (1/3_600_000),
            'aliases'   => ['kilowatt hour', 'kilowatt hours', 'kwh'],
            'type'      => 'energy',
        },
        {
            'unit'      => 'erg',
            'factor'    => (1/10_000_000),
            'aliases'   => ['ergon', 'ergs', 'ergons'],
            'type'      => 'energy',
        },
        {
            'unit'      => 'electron volt',
            'factor'    => (6.2415096e+18),
            'aliases'   => ['electronvolt', 'electron volts', 'ev', 'evs'],
            'type'      => 'energy',
        },
        {
            'unit'      => 'thermochemical gram calorie',
            'factor'    => (1/4.184),
            'aliases'   => ['small calories', 'thermochemical gram calories', 'chemical calorie', 'chemical calories'],
            'type'      => 'energy',
        },
        {
            'unit'      => 'large calorie',
            'factor'    => (1/4184),
            'aliases'   => ['large calories', 'food calorie', 'food calories', 'kcals', 'kcal'],
            'type'      => 'energy',
        },
        {
            'unit'      => 'british thermal unit',
            'factor'    => (1/1054.5),
            'aliases'   => ['british thermal units', 'btu', 'btus'],
            'type'      => 'energy',
        },
        {
            'unit'      => 'ton of TNT',
            'factor'    => (1/4.184e+9),
            'aliases'   => ['tnt equivilent', 'tonnes of tnt', 'tnt', 'tons of tnt'],
            'type'      => 'energy',
        }
    );

    # watt is base unit for power
    # known SI units and aliases / plurals
    my @power = (
        {
            'unit'      => 'watt',
            'factor'    => 1,
            'aliases'   => ['watts', 'w'],
            'type'      => 'power',
        },
        {
            'unit'      => 'kilowatt',
            'factor'    => 1/1000,
            'aliases'   => ['kilowatts', 'kw'],
            'type'      => 'power',
        },
        {
            'unit'      => 'megawatt',
            'factor'    => 1/1_000_000,
            'aliases'   => ['megawatts', 'mw'],
            'type'      => 'power',
        },
        {
            'unit'      => 'gigawatt',
            'factor'    => 1/1_000_000_000,
            'aliases'   => ['gigawatts', 'jiggawatts', 'gw'],
            'type'      => 'power',
        },
        {
            'unit'      => 'terawatt',
            'factor'    => 1/1_000_000_000_000,
            'aliases'   => ['terawatts', 'tw'],
            'type'      => 'power',
        },
        {
            'unit'      => 'petawatt',
            'factor'    => 1/1_000_000_000_000_000,
            'aliases'   => ['petawatts', 'pw'],
            'type'      => 'power',
        },
        {
            'unit'      => 'milliwatt',
            'factor'    => 1000,
            'aliases'   => ['milliwatts'],
            'type'      => 'power',
        },
        {
            'unit'      => 'microwatt',
            'factor'    => 1_000_000,
            'aliases'   => ['microwatts'],
            'type'      => 'power',
        },
        {
            'unit'      => 'nanowatt',
            'factor'    => 1_000_000_000,
            'aliases'   => ['nanowatts', 'nw'],
            'type'      => 'power',
        },
        {
            'unit'      => 'picowatt',
            'factor'    => 1_000_000_000_000,
            'aliases'   => ['picowatts', 'pw'],
            'type'      => 'power',
        },
        {
            'unit'      => 'metric horsepower',
            'factor'    => (1/735.49875),
            'aliases'   => ['metric horsepowers', 'mhp', 'hp', 'ps', 'cv', 'hk', 'ks', 'ch'],
            'type'      => 'power',
        },
        {
            'unit'      => 'horsepower',
            'factor'    => (1/745.69987158227022),
            'aliases'   => ['mechnical horsepower', 'horsepower', 'hp', 'hp', 'bhp'],
            'type'      => 'power',
        },
        {
            'unit'      => 'electical horsepower',
            'factor'    => (1/746),
            'aliases'   => ['electical horsepowers', 'hp', 'hp'],
            'type'      => 'power',
        },
    );

    # degree is base unit for angles
    # known SI units and aliases / plurals
    my @angle = (
        {
            'unit'      => 'degree',
            'factor'    => 1,
            'aliases'   => ['degrees', 'deg', 'degs'],
            'type'      => 'angle',
        },
        {
            'unit'      => 'radian',
            'factor'    => 3.14159265358979323/180,
            'aliases'   => ['radians', 'rad', 'rads'],
            'type'      => 'angle',
        },
        {
            'unit'      => 'gradian',
            'factor'    => 10/9,
            'aliases'   => ['gradians', 'grad', 'grads', 'gon', 'gons', 'grade', 'grades'],
            'type'      => 'angle',
        },
        {
            'unit'      => 'quadrant',
            'factor'    => 1/90,
            'aliases'   => ['quadrants', 'quads', 'quad'],
            'type'      => 'angle',
        },
        {
            'unit'      => 'semi-circle',
            'factor'    => 1/180,
            'aliases'   => ['semi circle', 'semicircle','semi circles', 'semicircles', 'semi-circles'],
            'type'      => 'angle',
        },
        {
            'unit'      => 'revolution',
            'factor'    => 1/360,
            'aliases'   => ['revolutions', 'circle', 'circles', 'revs'],
            'type'      => 'angle',
        },
    );

    # newton is base unit for force
    # known SI units and aliases / plurals
    my @force = (
        {
            'unit'      => 'newton',
            'factor'    => 1,
            'aliases'   => ['newtons', 'n'],
            'type'      => 'force',
        },
        {
            'unit'      => 'kilonewton',
            'factor'    => 1/1000,
            'aliases'   => ['kilonewtons', 'kn'],
            'type'      => 'force',
        },
        {
            'unit'      => 'meganewton',
            'factor'    => 1/1_000_000,
            'aliases'   => ['meganewtons', 'mn'],
            'type'      => 'force',
        },
        {
            'unit'      => 'giganewton',
            'factor'    => 1/1_000_000_000,
            'aliases'   => ['giganewtons', 'gn'],
            'type'      => 'force',
        },
        {
            'unit'      => 'dyne',
            'factor'    => 1/100000,
            'aliases'   => ['dynes'],
            'type'      => 'force',
        },
        {
            'unit'      => 'kilodyne',
            'factor'    => 1/100,
            'aliases'   => ['kilodynes'],
            'type'      => 'force',
        },
        {
            'unit'      => 'megadyne',
            'factor'    => 10,
            'aliases'   => ['megadynes'],
            'type'      => 'force',
        },
        {
            'unit'      => 'pounds force',
            'factor'    => 1/4.4482216152605,
            'aliases'   => ['lbs force', 'pounds force'],
            'type'      => 'force',
        },
        {
            'unit'      => 'poundal',
            'factor'    => 1/0.138254954376,
            'aliases'   => ['poundals', 'pdl'],
            'type'      => 'force',
        },
    );

    # fahrenheit is base unit for temperature
    # known SI units and aliases / plurals
    my @temperature = (
        {   
            'unit'            => 'fahrenheit',
            'factor'          => 1,           # all '1' because un-used
            'aliases'         => ['f'],     
            'type'            => 'temperature',
            'can_be_negative' => 1,
        },
        {   
            'unit'            => 'celsius',
            'factor'          => 1,           
            'aliases'         => ['c'],
            'type'            => 'temperature',
            'can_be_negative' => 1,
        },
        {
            'unit'            => 'kelvin',
            'factor'          => 1,
            'aliases'         => ['k'],       # be careful ... other units could use 'K'
            'type'            => 'temperature',       
        },
        {
            'unit'            => 'rankine',
            'factor'          => 1,
            'aliases'         => ['r'],    
            'type'            => 'temperature',
        },
        {
            'unit'            => 'reaumur',
            'factor'          => 1,
            'aliases'         => ['re'],      # also can be 'R', but that's being used for rankine    
            'type'            => 'temperature',
            'can_be_negative' => 1,
        },
    );  

    # build the keys:
    my @types = (@mass, @length, @time, @pressure, @energy, @power, @angle, @force, @temperature);    # unit types available for conversion
    
    return \@types;
}

=head1 TODO
    =item can add DDG massaging later if useful
    =item need better error handling
    =item add complete test suite
    =item all args to functions should be hash refs!
    =item store units data in a file?
    =item add more unit types (digital, cooking, etc.)
=cut



1;
