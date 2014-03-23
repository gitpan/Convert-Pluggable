use Test::More tests => 58;

BEGIN { use_ok('Convert::Pluggable') };

my $c = new Convert::Pluggable();
isa_ok($c, 'Convert::Pluggable');

my $result;

$result = $c->convert( { 'factor' => '5', 'fromUnit' => 'oz', 'toUnit' => 'g', 'precision' => '3', } );
is($result, '141.747', 'OK');

$result = $c->convert( { 'factor' => '1', 'fromUnit' => 'ton', 'toUnit' => 'long ton', 'precision' => '3', } );
is($result, '0.893', 'OK');

$result = $c->convert( { 'factor' => '158', 'fromUnit' => 'ounce', 'toUnit' => 'lbm', 'precision' => '3', } );
is($result, '9.875', 'OK');

$result = $c->convert( { 'factor' => '0.111', 'fromUnit' => 'stone', 'toUnit' => 'pound', 'precision' => '3', } );
is($result, '1.554', 'OK');

$result = $c->convert( { 'factor' => '3', 'fromUnit' => 'kilogramme', 'toUnit' => 'pound', 'precision' => '3', } );
is($result, '6.614', 'OK');

$result = $c->convert( { 'factor' => '1.3', 'fromUnit' => 'tonnes', 'toUnit' => 'ton', 'precision' => '3', } );
is($result, '1.433', 'OK');

$result = $c->convert( { 'factor' => '2', 'fromUnit' => 'tons', 'toUnit' => 'kg', 'precision' => '3', } );
is($result, '1814.372', 'OK');

$result = $c->convert( { 'factor' => '1', 'fromUnit' => 'ton', 'toUnit' => 'kilos', 'precision' => '3', } );
is($result, '907.186', 'OK');

$result = $c->convert( { 'factor' => '3.9', 'fromUnit' => 'oz', 'toUnit' => 'grams', 'precision' => '3', } );
is($result, '110.563', 'OK');

$result = $c->convert( { 'factor' => '2', 'fromUnit' => 'miles', 'toUnit' => 'km', 'precision' => '3', } );
is($result, '3.219', 'OK');

$result = $c->convert( { 'factor' => '5', 'fromUnit' => 'feet', 'toUnit' => 'in', 'precision' => '3', } );
is($result, '60.000', 'OK');

$result = $c->convert( { 'factor' => '0.5', 'fromUnit' => 'nautical mile', 'toUnit' => 'klick', 'precision' => '3', } );
is($result, '0.926', 'OK');

$result = $c->convert( { 'factor' => '500', 'fromUnit' => 'miles', 'toUnit' => 'metres', 'precision' => '3', } );
is($result, '804672.249', 'OK');

$result = $c->convert( { 'factor' => '25', 'fromUnit' => 'cm', 'toUnit' => 'inches', 'precision' => '3', } );
is($result, '9.843', 'OK');

$result = $c->convert( { 'factor' => '1760', 'fromUnit' => 'yards', 'toUnit' => 'miles', 'precision' => '3', } );
is($result, '1.000', 'OK');

$result = $c->convert( { 'factor' => '3520', 'fromUnit' => 'yards', 'toUnit' => 'miles', 'precision' => '3', } );
is($result, '2.000', 'OK');

$result = $c->convert( { 'factor' => '1', 'fromUnit' => 'stone', 'toUnit' => 'lbs', 'precision' => '3', } );
is($result, '14.000', 'OK');

$result = $c->convert( { 'factor' => '30', 'fromUnit' => 'cm', 'toUnit' => 'in', 'precision' => '3', } );
is($result, '11.811', 'OK');

$result = $c->convert( { 'factor' => '36', 'fromUnit' => 'months', 'toUnit' => 'years', 'precision' => '3', } );
is($result, '3.000', 'OK');

$result = $c->convert( { 'factor' => '43200', 'fromUnit' => 'seconds', 'toUnit' => 'hours', 'precision' => '3', } );
is($result, '12.000', 'OK');

$result = $c->convert( { 'factor' => '4', 'fromUnit' => 'hours', 'toUnit' => 'minutes', 'precision' => '3', } );
is($result, '240.000', 'OK');

$result = $c->convert( { 'factor' => '5', 'fromUnit' => 'kelvin', 'toUnit' => 'fahrenheit', 'precision' => '3', } );
is($result, '-450.670', 'OK');

$result = $c->convert( { 'factor' => '1', 'fromUnit' => 'bar', 'toUnit' => 'pascal', 'precision' => '3', } );
is($result, '100000.000', 'OK');

$result = $c->convert( { 'factor' => '1', 'fromUnit' => 'kilopascal', 'toUnit' => 'psi', 'precision' => '3', } );
is($result, '0.145', 'OK');

$result = $c->convert( { 'factor' => '1', 'fromUnit' => 'atm', 'toUnit' => 'kpa', 'precision' => '3', } );
is($result, '101.325', 'OK');

$result = $c->convert( { 'factor' => '5', 'fromUnit' => 'yrds', 'toUnit' => 'km', 'precision' => '3', } );
is($result, '0.005', 'OK');

$result = $c->convert( { 'factor' => '12', 'fromUnit' => '"', 'toUnit' => 'cm', 'precision' => '3', } );
is($result, '30.480', 'OK');

$result = $c->convert( { 'factor' => '25', 'fromUnit' => 'inches', 'toUnit' => 'feet', 'precision' => '3', } );
is($result, '2.083', 'OK');

$result = $c->convert( { 'factor' => '42', 'fromUnit' => 'kilowatt hours', 'toUnit' => 'joules', 'precision' => '3', } );
is($result, '151200000.000', 'OK');

$result = $c->convert( { 'factor' => '2500', 'fromUnit' => 'kcal', 'toUnit' => 'tons of tnt', 'precision' => '3', } );
is($result, '0.003', 'OK');

$result = $c->convert( { 'factor' => '90', 'fromUnit' => 'ps', 'toUnit' => 'watts', 'precision' => '3', } );
is($result, '66194.888', 'OK');

$result = $c->convert( { 'factor' => '1', 'fromUnit' => 'gigawatt', 'toUnit' => 'horsepower', 'precision' => '3', } );
is($result, '1341022.090', 'OK');

$result = $c->convert( { 'factor' => '180', 'fromUnit' => 'degrees', 'toUnit' => 'radians', 'precision' => '3', } );
is($result, '3.142', 'OK');

$result = $c->convert( { 'factor' => '270', 'fromUnit' => 'degrees', 'toUnit' => 'quadrants', 'precision' => '3', } );
is($result, '3.000', 'OK');

$result = $c->convert( { 'factor' => '180', 'fromUnit' => 'degrees', 'toUnit' => 'grads', 'precision' => '3', } );
is($result, '200.000', 'OK');

$result = $c->convert( { 'factor' => '45', 'fromUnit' => 'newtons', 'toUnit' => 'pounds force', 'precision' => '3', } );
is($result, '10.116', 'OK');

$result = $c->convert( { 'factor' => '8', 'fromUnit' => 'poundal', 'toUnit' => 'newtons', 'precision' => '3', } );
is($result, '1.106', 'OK');

$result = $c->convert( { 'factor' => '5', 'fromUnit' => 'f', 'toUnit' => 'celsius', 'precision' => '3', } );
is($result, '-14.985', 'OK');

$result = $c->convert( { 'factor' => '6^2', 'fromUnit' => 'oz', 'toUnit' => 'grams', 'precision' => '3', } );
is($result, undef, 'OK');

$result = $c->convert( { 'factor' => 'NaN', 'fromUnit' => 'oz', 'toUnit' => 'stones', 'precision' => '3', } );
is($result, undef, 'OK');

$result = $c->convert( { 'factor' => '45x10', 'fromUnit' => 'oz', 'toUnit' => 'stones', 'precision' => '3', } );
is($result, undef, 'OK');

$result = $c->convert( { 'factor' => '-9', 'fromUnit' => 'g', 'toUnit' => 'ozs', 'precision' => '3', } );
is($result, undef, 'OK');

$result = $c->convert( { 'factor' => '5', 'fromUnit' => 'oz', 'toUnit' => 'yards', 'precision' => '3', } );
is($result, undef, 'OK');

$result = $c->convert( { 'factor' => 'Inf', 'fromUnit' => 'oz', 'toUnit' => 'stones', 'precision' => '3', } );
is($result, undef, 'OK');

$result = $c->convert( { 'factor' => '-5', 'fromUnit' => 'kelvin', 'toUnit' => 'fahrenheit', 'precision' => '3', } );
is($result, undef, 'OK');

$result = $c->convert( { 'factor' => 'use', 'fromUnit' => 'ton', 'toUnit' => 'stones', 'precision' => '3', } );
is($result, undef, 'OK');

$result = $c->convert( { 'factor' => 'shoot', 'fromUnit' => 'oneself', 'toUnit' => 'foot', 'precision' => '3', } );
is($result, undef, 'OK');

$result = $c->convert( { 'factor' => 'foot', 'fromUnit' => 'both', 'toUnit' => 'camps', 'precision' => '3', } );
is($result, undef, 'OK');

$result = $c->convert( { 'factor' => 'puff', 'fromUnit' => 'toke', 'toUnit' => 'kludge', 'precision' => '3', } );
is($result, undef, 'OK');
    
$result = $c->convert( { 'factor' => '10', 'fromUnit' => 'milligrams', 'toUnit' => 'tons', 'precision' => '3', } );
is($result, '0.000', '10 milligrams is 1.1e-08 tons');

$result = $c->convert( { 'factor' => '10000', 'fromUnit' => 'minutes', 'toUnit' => 'microseconds', 'precision' => '3', } );
is($result, '600000000000.000', '10000 minutes is 6e+11 microseconds');

$result = $c->convert( { 'factor' => '5', 'fromUnit' => 'bytes', 'toUnit' => 'bit', 'precision' => '3', } );
is($result, '40.000', '5 bytes is 40.000 bits');

$result = $c->convert( { 'factor' => '5', 'fromUnit' => 'GB', 'toUnit' => 'megabyte', 'precision' => '3', } );
is($result, '5000.000', '5 gigabytes is 5000.000 megabytes');

$result = $c->convert( { 'factor' => '0.013', 'fromUnit' => 'mb', 'toUnit' => 'bits', 'precision' => '3', } );
is($result, '104000.000', '0.013 megabytes is 104000.000 bits');

$result = $c->convert( { 'factor' => '1', 'fromUnit' => 'exabyte', 'toUnit' => 'pib', 'precision' => '3', } );
is($result, '888.178', '1 exabyte is 888.178 pebibytes');

$result = $c->convert( { 'factor' => '1', 'fromUnit' => 'yb', 'toUnit' => 'yib', 'precision' => '3', } );
is($result, '0.827', '1 yottabyte is 0.827 yobibytes');
