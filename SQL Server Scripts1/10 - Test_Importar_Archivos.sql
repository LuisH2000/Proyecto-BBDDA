use Com5600G13
go

exec importar.configurarImportacionArchivosExcel

--1. Importamos las sucursales, esperamos que importe 3 registros
--2. Ejecutar dos veces el proc para verificar que no se inserten duplicados
exec importar.importarSucursal 'C:\TP_integrador_Archivos\Informacion_complementaria.xlsx'
select * from sucursales.Sucursal

--1. Importamos los empleados y los distintos cargos, esperamos 15 empleados y 3 cargos
--2. Ejecutar dos veces el proc para verificar que no se inserten duplicados
exec importar.importarEmpleados 'C:\TP_integrador_Archivos\Informacion_complementaria.xlsx'
select * from recursosHumanos.Cargo
select * from recursosHumanos.Empleado

--1. Importamos los medios de pago, esperamos 3 medios de pago
--2. Ejecutar dos veces el proc para verificar que no se inserten duplicados
exec importar.importarMediosDePago 'C:\TP_integrador_Archivos\Informacion_complementaria.xlsx'
select * from comprobantes.MedioDePago

--1. Importamos las lineas de producto y las categorias, esperamos 11 lineas de producto y 148 categorias
--2. Ejecutar dos veces el proc para verificar que no se inserten duplicados
exec importar.importarClasificacion 'C:\TP_integrador_Archivos\Informacion_complementaria.xlsx'
select * from catalogo.LineaProducto 
select * from catalogo.Categoria 

--1. Importamos el archivo catalogo.csv, esperamos 6045 productos de 6427 porque hay duplicados debido a que un producto
--	pruede tener varias categorias. Por lo que esperamos 6427 registros en la tabla PerteneceA, donde tiene en cada fila
--	el id del producto y el id de la categoria a la que pertenece
--2. Ejecutar dos veces el proc para verificar que no se inserten duplicados
exec importar.importarCatalogo 'C:\TP_integrador_Archivos\Productos\catalogo.csv'
select * from catalogo.Producto
select * from catalogo.PerteneceA
--3. Vaciamos las tablas para ver facilmente la cantidad de registros que se insertan con los siguentes catalogos
truncate table catalogo.PerteneceA
delete from catalogo.Producto;

--1. Importamos el archivo Electronic accessories.xlsx, esperamos 19 filas de 25 en Producto y PerteneceA 
--	porque hay productos duplicados
--	se agrega una nueva categoria 'electronica' a la tabla catalogo.Categorias
--	se agrega la linea 'Tecnologia' a la tabla catalogo.LineaProducto
--2. Ejecutar dos veces el proc para verificar que no se inserten duplicados
exec importar.importarAccesoriosElectronicos 'C:\TP_integrador_Archivos\Productos\Electronic accessories.xlsx'
select * from catalogo.Producto
select * from catalogo.PerteneceA

select * from catalogo.Categoria
select * from catalogo.LineaProducto 
--3. Vaciamos las tablas
truncate table catalogo.PerteneceA
delete from catalogo.Producto;

--1. Importamos el archivo Productos_importados.xlsx, esperamos 77 filas en Producto y PerteneceA
--	se agregan las categorias de los productos y catalogo.Categoria
--	a cada categoria se le asocia un id de linea de producto ya existente
--2. Ejecutar dos veces el proc para verificar que no se inserten duplicados
exec importar.importarProductosImportados 'C:\TP_integrador_Archivos\Productos\Productos_importados.xlsx'
select * from catalogo.Producto
select * from catalogo.PerteneceA

select * from catalogo.Categoria
select * from catalogo.LineaProducto 
--3. Vaciamos las tablas
truncate table catalogo.PerteneceA
delete from catalogo.Producto;

--1. Importamos el archivo Ventas_registradas.csv, esperamos 1000 filas en Factura, LineaDeFactura y Comprobante
--	se debe importar el archivo catalogo.csv
--2. Ejecutar dos veces el proc para verificar que no se inserten duplicados
--Necesitamos tener importado el catalogo.csv para poder importar las ventas
exec importar.importarCatalogo 'C:\TP_integrador_Archivos\Productos\catalogo.csv'

exec importar.importarVentas 'C:\TP_integrador_Archivos\Ventas_registradas.csv'
select * from ventas.Factura
select * from ventas.LineaDeFactura
select * from comprobantes.Comprobante
select * from clientes.Cliente
/*
use Com5600G13
go
exec importar.importarSucursal 'C:\TP_integrador_Archivos\Informacion_complementaria.xlsx'
exec importar.importarEmpleados 'C:\TP_integrador_Archivos\Informacion_complementaria.xlsx'
exec importar.importarMediosDePago 'C:\TP_integrador_Archivos\Informacion_complementaria.xlsx'
exec importar.importarClasificacion 'C:\TP_integrador_Archivos\Informacion_complementaria.xlsx'
exec importar.importarCatalogo 'C:\TP_integrador_Archivos\Productos\catalogo.csv'
exec importar.importarAccesoriosElectronicos 'C:\TP_integrador_Archivos\Productos\Electronic accessories.xlsx'
exec importar.importarProductosImportados 'C:\TP_integrador_Archivos\Productos\Productos_importados.xlsx'
exec importar.importarVentas 'C:\TP_integrador_Archivos\Ventas_registradas.csv'
*/