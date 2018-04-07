# WeatherPi

Scripts to send temperature and pressure info to wunderground and/or APRS


Keletas skriptų, skirtų naudoti su raspberry Pi. Jų pagalba siųsim sensorių duomenis į wunderground ir APRS.
Naudojami sensoriai - bmp180 slėgio matavimui ir 1 Wire DS18B20 lauko temperatūrai. 
Bmp180 taip pat turi temperatūros sensorių, bet jis geičiausiai bus šalia procesoriaus, tai jo parodymai netinka. 
Jį galima naudoti raspberry Pi aplinkos temperatūros stebėjimui.

failus wunderground.pl ir aprx_weather_packet.pl prieš naudojant reikia pasikoreguoti. Juose reikia nurodyti sensorių vietas,
o wunderground.pl ir prisijungimo informaciją.
Skriptų vieta by default /etc/scripts. Dedant kitur reikia pasikoreguoti cron.d esančius failus.


```
+-------+
|       |
|DS18B20|
|1  2  3|
+-------+
 |  |  |
 |  |  |
 |  |  |
 |  |  +---+
 |  | 4k7  |
 |  +-/\/\-+--> 3.3V (pin1)
 |  |
 |  +--------> GPIO4 (pin7)
 +-----------> GND   (pin9)

```
Mano atveju sensorius prilituotas prie poros metrų ekranuoto dvigyslio laido, varža šalia raspberry Pi, sensorius įkištas
į termovamzdelį ir vamzdelio galai apklijuoti klijais.
Temperatūros sensorius turi būti lauke, pavėsyje, geriausia šiaurinėje pusėje.

[1 Wire temperature sensor](http://www.wurst-wasser.net/wiki/index.php/RaspberryPi_Temperature_Sensor)
[bmp180 sensor](https://thepihut.com/blogs/raspberry-pi-tutorials/18025084-sensors-pressure-temperature-and-altitude-with-the-bmp180)


```
wunderground.pl 	- nusiunčia slėgio ir temperatūros sensorių informaciją į wunderground serverius
aprx_weather_packet.pl	- sugeneruoja failą su sensorių parodymais APRS weather formate arba šią informaciją ištransliuoja į eterį.
cron.d			- šiame kataloge esančius failus reikia padėti i /etc/cron.d
rc.local		- /etc/rc.local pavyzdys, jis pasileidžia įjungus raspberry pi
```


mano stotelė: https://www.wunderground.com/personal-weather-station/dashboard?ID=IVILNIUS190


Vilius / LY3FF
