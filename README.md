"La Cosa" Medialab-Prado
======
<img src="http://medialab-prado.es/mmedia/14/14417/500_0.jpg" />
<img src="http://medialab-prado.es/mmedia/1/1459/350_0.jpg" />

¿Qué es?
--------
"La cosa" se proyecta como una solución para unir las dos naves que componen la Antigua Serrería Belga y actúa de nexo de unión y distribuidor de las diferentes estancias de lo que es ahora la sede de Medialab/Prado. Para destacar y dotar a esa estructura de una personalidad que la convirtiera en emblemática, los arquitectos decidieron usar la luz para que resaltara tanto para los que estuvieran fuera del edificio como dentro del mismo.

La colocación de tiras Led direccionables situadas entre una doble piel textil translúcida, conforman la estructura exterior y el revestimiento interior de "La cosa". En sí mismo forma una pantalla de baja  resolución con una geometría muy distinta de una pantalla convencional. Sus  propiedades estéticas desde  el exterior, y las capacidades inmersivas  en el interior, la hacen un  soporte único. A lo largo de toda la superficie  de paredes y techos en las tres plantas que conecta, se han dispuesto  aproximadamente 6000 leds.

+Documentación gráfica en el portfolio de <a href="https://www.cazurro.com/2013/02/27/philips-la-cosa-del-medialab-prado/"> Carlos Cazurro Burgos</a>

Proyecto "Simon dice Cosa" para Un año en un día 2017
<img alt="Gif del proyecto Simon dice para Un año en un da 2017" src="https://raw.githubusercontent.com/edumo/lacosa/master/docs/simon_fuera.gif"/>


¿Cómo funciona?
---------

Se ha indicado que las tiras de leds distrubuidas por las paredes de la cosa son dirreccionables, esto significa que se podra controlar el color de cada pixel por separado, de igual modo que en una pantalla convencional. Para su control se dispone de una digitalizadora de Phillips que recibe una señal dvi a una resolución de 1024x768, a partir de esta imagen, se van a mapear los ciertos pixels de la matriz de la señal de dvi en los leds distrbuidos.

- Icolor
Tecnología usada en los soportes leds.
http://www.colorkinetics.com/ls/rgb/flexmx/

- Digitalizadora
Dispone de interfaz web para su gestión.
http://www.colorkinetics.com/ls/controllers/vsmpro/

- Software de configuracin y uso de vsmpro.
http://www.colorkinetics.com/support/vsm/

Proyecto "Simon dice Cosa" para Un año en un día 2017
<img src="https://raw.githubusercontent.com/edumo/lacosa/master/docs/simon_dentro.gif"/>

Geometría, entendiendo la cosa
------

La cosa está formada por 35 superficies llamemoslas "paneles", que cubren paredes, techos y suelos en el exterior. Cada uno de los paneles es una superficie plana que está compuesta de varias geometrías (llamemoslas "celdas"). En general las celdas son triángulos o cuadriláteros (ya sean romboides o rectángulos). A su vez, cada celda incluye un cierto número de leds en su perímetro.

El mapeo de la geometría bidimensional de la fuente de video, a la geometría tridimensional con la disposición de los leds en La Cosa, se realiza mediante un fichero de mapeo documentado en los enlaces anteriores. Esta configuracin es editable mediante un software también enlazado anteriormente. 

Planos de Langarita-Navarro
<img src="https://raw.githubusercontent.com/edumo/lacosa/master/docs/detalle.jpg"/>

Alcance actual 0.1
-------

-Se permite controlar la iluminación por paneles (35). 

-No existe ninguna infraestructura de interfaz de entrada para realizar interacciones (sensores de presencia, micrófonos, ...).

-Los paneles están numerados y se encuentran agrupados por plantas. 

Alcance actual 0.2
-------

-Se permite pintar por celdas!!.

-Las celdas son accesibles desde los paneles.
