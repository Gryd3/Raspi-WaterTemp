#!/usr/bin/perl
#use strict;
#use warnings;
use sigtrap qw/handler signal_handler normal-signals/;

my $dir = '/srv/Raspi-WaterTemp';
my $is_celsius = 1; # set to 1 if using Celsius
my $relay_pin = 17; # which GPIO pin the relay is connected to
my $target_temp_filename = $dir . '/www/graphs/targettemp.txt';
my $modules = `cat /proc/modules`;

print "Testing modules...";
if ($modules =~ /w1_therm/ && $modules =~ /w1_gpio/){
	print "OK!\n";
}
else{
	print "Fail!\nInstalling modules\n";
	system("sudo modprobe w1-gpio");
	system("sudo modprobe w1-therm");
}

# The following lines allow this to run as a daemon
# Be sure to call this script from rc.local
print "Daemonizing...";
close(STDIN);
close(STDOU);
close(STDERR);
exit if (fork());
exit if (fork());

# Setting GPIO output.
#print "Setting GPIO\n";
system("echo " . $relay_pin . "> /sys/class/gpio/export");
system("echo out > /sys/class/gpio/gpio" . $relay_pin . "/direction");

#print "Set gpio\n";

my $targetTemp = 0;
my $timestamp = time();

# Master Loop
MAIN:while(1){
	my $temp = "";
	my $output = "";
	my $attempts = 0;

	POLL_PROBE:while ($output !~ /YES/g && $attempts < 5){
		# Poll Tempurature Probe
		$output = `sudo cat /sys/bus/w1/devices/28-*/w1_slave 2>&1`;
		if($output =~ /No such file or directory/){
			# Error and Exit Poll Loop
			#print "Could not find DS18B20\n";
			last;
		}
		elsif($output !~ /NO/g){
			$output =~ /t=(\d+)/i;
			$temp = ($is_celsius) ? ($1 / 1000) : ($1 / 1000) * 9/5 + 32;
#			$rrd = `/usr/bin/rrdtool update $dir/www/graphs/watertemp.rrd N:$temp:0`;
		}
		$attempts++;
	}

	#Read File
	$targetTemp = `cat $target_temp_filename`;
	
	#Update Relay
	if($targetTemp > $temp){
		#print("Turning on solid state relay\n");
		system("echo 1 > /sys/class/gpio/gpio" . $relay_pin . "/value");
	}
	else{
		#print("Turning off solid state relay\n");
		system("echo 0 > /sys/class/gpio/gpio" . $relay_pin . "/value");
	}	

	#Update RRD
	system("/usr/bin/rrdtool update " . $dir . "/www/graphs/watertemp.rrd N:" . $temp . ":" . $targetTemp);

	if(time() > $timestamp+5){ #Creates graphs every 5 Sec.
		system("bash '$dir'/daemon/create_graphs.sh");
		$timestamp = time();
	}

	select(undef, undef, undef, .75);
#	print `date +%s` . "Water Temp: $temp\n";
	$temp="NaN";
	$targetTemp="NaN";
}

sub signal_handler {
	system("echo " . $relay_pin . "> /sys/class/gpio/unexport");
	die "Caught a signal $!";
}
