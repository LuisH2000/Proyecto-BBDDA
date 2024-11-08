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
Por otra parte, se requiere que los datos de los empleados se encuentren encriptados, dado 
que los mismos contienen información personal.
*/

use Com5600G13
go

alter table recursosHumanos.Empleado
	add legajoCifrado varbinary(256),
		nombreCifrado varbinary(256),
		apellidoCifrado varbinary(256),
		dniCifrado varbinary(256),
		direccionCifrado varbinary(256),
		emailPerCifrado varbinary(256),
		emailEmpCifrado varbinary(256),
		cuilCifrado varbinary(256),
		cargoCifrado varbinary(256),
		idSucursalCifrado varbinary(256),
		turnoCifrado varbinary(256),
		activoCifrado varbinary(256)
go

declare @FraseClave nvarchar(128);  
set @FraseClave = 'QuieroMiPanDanes'; 

update recursosHumanos.Empleado
SET 
	legajoCifrado = EncryptByPassPhrase(@FraseClave, convert(varchar(100), legajo), 1, convert(varbinary, legajo)),
    nombreCifrado = EncryptByPassPhrase(@FraseClave, nombre, 1, convert(varbinary, legajo)),
    apellidoCifrado = EncryptByPassPhrase(@FraseClave, apellido, 1, convert(varbinary, legajo)),
    dniCifrado = EncryptByPassPhrase(@FraseClave, convert(varchar(100), dni), 1, convert(varbinary, legajo)),
    direccionCifrado = EncryptByPassPhrase(@FraseClave, direccion, 1, convert(varbinary, legajo)),
    emailPerCifrado = EncryptByPassPhrase(@FraseClave, emailPer, 1, convert(varbinary, legajo)),
    emailEmpCifrado = EncryptByPassPhrase(@FraseClave, emailEmp, 1, convert(varbinary, legajo)),
    cuilCifrado = EncryptByPassPhrase(@FraseClave, convert(varchar(100), cuil), 1, convert(varbinary, legajo)),
    cargoCifrado = EncryptByPassPhrase(@FraseClave, convert(varchar(3), cargo), 1, convert(varbinary, legajo)),
    idSucursalCifrado = EncryptByPassPhrase(@FraseClave, convert(varchar(3), idSucursal), 1, convert(varbinary, legajo)),
    turnoCifrado = EncryptByPassPhrase(@FraseClave, turno, 1, convert(varbinary, legajo)),
    activoCifrado = EncryptByPassPhrase(@FraseClave, convert(varchar(100), activo), 1, convert(varbinary, legajo));

select * from recursosHumanos.Empleado