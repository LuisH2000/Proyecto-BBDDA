/*
Fecha de Entrega: 15/11/2024
Comision: 5600
Grupo 13
Bases de Datos Aplicadas

Alumnos:
	- Diaz, Nicolas 41714473
	- Huang, Luis 43098142

**ENUNCIADO**
Cuando un cliente reclama la devolución de un producto se genera una nota de crédito por el 
valor del producto o un producto del mismo tipo. 
En el caso de que el cliente solicite la nota de crédito, solo los Supervisores tienen el permiso 
para generarla.  
Tener en cuenta que la nota de crédito debe estar asociada a una Factura con estado pagada. 
Asigne los roles correspondientes para poder cumplir con este requisito. 
Por otra parte, se requiere que los datos de los empleados se encuentren encriptados, dado 
que los mismos contienen información personal. 
La información de las ventas es de vital importancia para el negocio, por ello se requiere que 
se establezcan políticas de respaldo tanto en las ventas diarias generadas como en los 
reportes generados.  
Plantee una política de respaldo adecuada para cumplir con este requisito y justifique la 
misma. 
*/

/*
En el caso de que el cliente solicite la nota de crédito, solo los Supervisores tienen el permiso 
para generarla. 
*/

use master
go	

--creamos un login supervisor para generar la nota
if not exists (select 1 from sys.sql_logins where name = 'supervisor')
begin
	create login supervisor
		with password = 'supervisor123',
		default_database = Com5600G13,
		check_expiration = OFF, check_policy = OFF
end
go

--creamos un login cajero que no tenga permiso para generar la nota
if not exists (select 1 from sys.sql_logins where name = 'cajero')
begin
	create login cajero
		with password = 'cajero123',
		default_database = Com5600G13,
		check_expiration = OFF, check_policy = OFF
end
go

use Com5600G13	
go
---***SUPERVISOR***
--creamos un usuario para el login supervisor.
if not exists (select 1 from sys.database_principals where name = 'supervisor1')
begin
	create user supervisor1 for login supervisor
end
--creamos el role SupervisorRol y agregamos el usuario supervisor1 al rol
if not exists (select 1 from sys.database_principals where type = 'R' AND name = 'SupervisorRol')
begin
	create role SupervisorRol
end

alter role SupervisorRol add member supervisor1

--le damos permisos a los Supervisores para poder ver las facturas, sus productos y los comprobantes
--para que pueda generar las notas de credito
grant select on ventas.Factura to SupervisorRol
grant select on ventas.LineaDeFactura to SupervisorRol
grant select on comprobantes.Comprobante to SupervisorRol
grant execute
	on object::comprobantes.generarNotaDeCredito
	to SupervisorRol;

---***CAJERO***
--creamos un usuario para el login cajero
if not exists (select 1 from sys.database_principals where name = 'cajero1')
begin
	create user cajero1 for login cajero
end
--creamos el role CajeroRol y agregamos el usuario cajero1 al rol
if not exists (select 1 from sys.database_principals where type = 'R' AND name = 'CajeroRol')
begin
	create role CajeroRol
end

alter role CajeroRol add member cajero1