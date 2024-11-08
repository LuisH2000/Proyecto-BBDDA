use master
go	

--creamos un login supervisor
create login supervisor
	with password = 'supervisor123',
	default_database = Com5600G13,
	CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
go

use Com5600G13	
go
--creamos un usuario para el login supervisor.
--creamos el role SupervisorRol y agregamos el usuario supervisor1 al rol
create user supervisor1 for login supervisor
create role SupervisorRol
alter role SupervisorRol add member supervisor1

--le damos permisos a los Supervisores para poder ver las facturas, sus productos y los comprobantes
--para que pueda generar las notas de credito
grant select on ventas.Factura to SupervisorRol
grant select on ventas.LineaDeFactura to SupervisorRol
grant select on comprobantes.Comprobante to SupervisorRol
grant execute
	on object::comprobantes.generarNotaDeCredito
	to SupervisorRol;
