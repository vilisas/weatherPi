#!/usr/bin/perl
#
# aprx weather beacon packet generator V1.0
#
# This reads pressure from bmp180 and temperature from 1wire DS18B20 sensors, generates aprs weather packet and prints it to file
# for use with aprx (aprx raw beacon) or broadcasts using shell command 'beacon'
#
#
#
#
# LY3FF, 2018
# http://sutemos.lt

use strict;
use POSIX qw(strftime);

my $USE_APRS_BEACON=0;		# 0 - print packet to stdout for aprx use, 1 - send packet to rf using 'beacon' command

my $elevation = 158; # sensor elevation above sea level in meters

my $pressure_path = "/sys/class/i2c-adapter/i2c-1/1-0077/iio\:device0/in_pressure_input";
my $w1_sensor_path = "/sys/bus/w1/devices/28-00000680d7b9/w1_slave";


#
# I - symbol table
# # - igate symbol
#
# /----Table
# | /--Symbol
# T S
# / _ - weather station symbol  (WX)
# I # - iGate symbol (green I star)


my $aprs_table = "I";
my $aprs_symbol = "#"; # Weather stations use symbol "_", but as we are I-Gate, we use symbol "#"

my $aprs_port	 = "ax0";			# ax25 port ax0 or sm0 for sound modem... or callsign associated to port
my $aprs_beacon_soft = "/usr/sbin/beacon -s";
my $aprs_location="5442.30N". $aprs_table . "02515.19E";		# NOTE: / is APRS symbol
my $aprs_software="XRPi";			# X - X-APRS (Linux), RPi - 2-4 symbols / software name
my $packet_output_file = "/tmp/aprx_weather_packet.txt";
#$packet_output_file = "/dev/stdout";
#
# From APRS docs:
#
#Note: The weather report must include at least the MDHM date/timestamp,
#wind direction, wind speed, gust and temperature, but the remaining
#parameters may be in a different order (or may not even exist).
#Note: Where an item of weather data is unknown or irrelevant, its value may
#be expressed as a series of dots or spaces. For example, if there is no wind
#speed/direction/gust sensor, the wind values could be expressed as:
# c...s...g... 
#
# timestamp: MMDDhhmm

#
# timestamp: DDhhmm
# ilgis - 7 simboliai, formatas DDHHMM + sufixas (z) arba HHMMSS + sufixas (h)
# naudojam DDHHMMz, pagal pavyzdi is protokolo aprasymo

my $aprs_timestamp = strftime "%d%H%Mz", gmtime;

open(PRESS,"<", $pressure_path) or die "Can't read pressure sensor data from $pressure_path";
my $hpa = <PRESS>;
chomp($hpa);
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

my $tempF =( $temperature * 1.8 + 32);
my $aprs_tempF = sprintf("%03.0f", $tempF);
# skaiciuojam juros lygio slegi
my $a = 16000 + 64 * $temperature;
my $pressure = $hpa * ( ($a + $elevation) / ($a - $elevation));
#$pressure  = sprintf "%05.01f", $pressure;
my $aprs_pressure = sprintf( "%05d", ($pressure * 10));

#my $aprs_msg = $msg_prefix . "\@". $aprs_timestamp . $aprs_location."_c...s...g...t". $aprs_tempF ."b". $aprs_pressure . $aprs_software;
my $aprs_msg = "\@". $aprs_timestamp . $aprs_location. $aprs_symbol . "c...s...g...t". $aprs_tempF ."b". $aprs_pressure . $aprs_software;

# beacon weather packet to RF (and iGate if any)
if ($USE_APRS_BEACON == 1) {
  my $result = `$aprs_beacon_soft $aprs_port '$aprs_msg' >/dev/null`;
} else {
    open (PF,">", $packet_output_file);
    print PF "$aprs_msg\n";
    close PF;
}
