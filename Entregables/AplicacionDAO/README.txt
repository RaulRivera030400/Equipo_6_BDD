En esta carpeta están los elementos necesarios para ejecutar el proyecto

AdventureWorks2019.bak se debe restablecer en SQLServer
AdventureWorks2019_MySQL.sql se debe restablecer en MySQL
Stored Procedure Inserts.sql contiene los Stored Procedure utilizados 

En el Stored Procedure sp_insert_OrderDetail se hacen consultas distribuidas por lo que se necesita un servidor vinculado,
en nuestro caso le llamamos MYSQL

Proyecto1 es la aplicación en Java, ahí se debe ajustar los datos de las instancias correspondientes 
a su equipo una vez se tengan las bases de datos en MySQL y SQLServer

Una vez ejecutado el proyecto se solicita el ProductID y la Cantidad, sp_insert_OrderDetail verificara que el producto exista y que haya 
cantidad suficiente, si es que se cumplen esas condiciones, se obtiene el descuento dependiendo de la cantidad solicitada, posteriormente
obtiene el precio del producto y finalmente hace la inserción a la tabla SalesOrderDetail.

Se pregunta si el habrá más inserciones, si es así, se repite el procedimiento anterior.

Cuando ya no se hagan más inserciones a salesOrderDetail, se hace la inserción a SalesOrderHeader

Finalmente se muestran los datos insertados en consola
