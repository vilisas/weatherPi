#!/usr/bin/perl
#
# Wunderground data uploader script 1.0
#
# This reads pressure from bmp180 and temperature from 1wire DS18B20 sensors and uploads it to wunderground service.
#
# Check $elevation, $station_ID, $station_KEY, $pressure_path, $w1_sensor_path values
# you must have wget installed (apt-get install wget)
#
# Vlz, 2016-2018.
# http://sutemos.lt
#
#
#


my $elevation = 158; # sensoriaus aukstis virs juros lygio metrais

my $station_ID	="IDSTATION555";
my $station_KEY	="pa55word";


#my $pressure_path="/sys/class/i2c-adapter/i2c-1/1-0077/pressure0_input";
my $pressure_path="/sys/class/i2c-adapter/i2c-1/1-0077/iio:device0/in_pressure_input";
my $w1_sensor_path = "/sys/bus/w1/devices/28-00000680d7b9/w1_slave";

my $url_prefix	="https://weatherstation.wunderground.com/weatherstation/updateweatherstation.php?ID=$station_ID&PASSWORD=$station_KEY&dateutc=now&action=updateraw";
my $wget = "/usr/bin/wget -O - ";

open(PRESS,"<", $pressure_path) or die "Can't read pressure sensor data from $pressure_path";
my $hpa = <PRESS>;
chomp($hpa);
#$hpa = $hpa / 100;
$hpa = $hpa * 10;
close(PRESS);

open(W1,"<", $w1_sensor_path) or die "Can't read temperature sensor data from $pressure_path";
my $tmp = <W1>; # dummy read 1 line
   $tmp = <W1>; # we need this one
   chomp($tmp);
close(W1);
my $temperature=0;
my $hex;

($hex, $temperature) =  split(/\=/, $tmp);
$temperature = $temperature / 1000;

# wunderground accepts only imperial units, so we must do some conversions here

my $tempF =( $temperature * 1.8 + 32);

# skaiciuojam juros lygio slegi
my $a = 16000 + 64 * $temperature;
my $pressure = $hpa * ( ($a + $elevation) / ($a - $elevation));
$pressure  = sprintf "%.02f", $pressure;

$aprs_pressure = sprintf( "%05d", ($pressure* 10));		# desimtys milibaru, su nuliu prieky, jei reikia (5 zenklai)
#print "$aprs_pressure\n";
#exit;

my $baromin = (0.0295300 * $pressure);
my $url = $url_prefix . "&tempf=$tempF&baromin=$baromin";


########
# sending to wunderground
#
my $result = `$wget  '$url' 2>/dev/null`;
#######
#print $result;
#print "$url\n";
#print "hpa: $hpa,  pressure: $pressure,  baromin: $baromin\n";

