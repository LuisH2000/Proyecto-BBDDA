/*
Fecha de Entrega: 29/11/2024
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

--vemos los datos antes de encriptar
select * from recursosHumanos.Empleado

--agregamos las columnas donde guardamos los datos encriptados
alter table recursosHumanos.Empleado
	add
		nombreCifrado varbinary(256),
		apellidoCifrado varbinary(256),
		dniCifrado varbinary(256),
		direccionCifrado varbinary(256),
		emailPerCifrado varbinary(256),
		emailEmpCifrado varbinary(256),
		cuilCifrado varbinary(256)
go

--frase que usamos para encriptar
declare @FraseClave nvarchar(128);  
set @FraseClave = 'QuieroMiPanDanes'; 

--encriptamos los datos
update recursosHumanos.Empleado
SET 
    nombreCifrado = EncryptByPassPhrase(@FraseClave, nombre, 1, convert(varbinary, legajo)),
    apellidoCifrado = EncryptByPassPhrase(@FraseClave, apellido, 1, convert(varbinary, legajo)),
    dniCifrado = EncryptByPassPhrase(@FraseClave, convert(varchar(100), dni), 1, convert(varbinary, legajo)),
    direccionCifrado = EncryptByPassPhrase(@FraseClave, direccion, 1, convert(varbinary, legajo)),
    emailPerCifrado = EncryptByPassPhrase(@FraseClave, emailPer, 1, convert(varbinary, legajo)),
    emailEmpCifrado = EncryptByPassPhrase(@FraseClave, emailEmp, 1, convert(varbinary, legajo)),
    cuilCifrado = EncryptByPassPhrase(@FraseClave, convert(varchar(100), cuil), 1, convert(varbinary, legajo))
go

--descartamos las columnas sin encriptar y cambiamos los nombres de las columnas encriptadas
alter table recursosHumanos.Empleado
drop column nombre

alter table recursosHumanos.Empleado
drop column apellido

alter table recursosHumanos.Empleado
drop constraint UQ_DNI
alter table recursosHumanos.Empleado
drop column dni

alter table recursosHumanos.Empleado
drop column direccion

alter table recursosHumanos.Empleado
drop constraint UQ_EmailPer
alter table recursosHumanos.Empleado
drop column emailPer

alter table recursosHumanos.Empleado
drop constraint UQ_EmailEmp
alter table recursosHumanos.Empleado
drop column emailEmp

alter table recursosHumanos.Empleado
drop column cuil
go

EXEC sp_rename 'recursosHumanos.Empleado.nombreCifrado', 'nombre', 'COLUMN';
EXEC sp_rename 'recursosHumanos.Empleado.apellidoCifrado', 'apellido', 'COLUMN';
EXEC sp_rename 'recursosHumanos.Empleado.dniCifrado', 'dni', 'COLUMN';
EXEC sp_rename 'recursosHumanos.Empleado.direccionCifrado', 'direccion', 'COLUMN';
EXEC sp_rename 'recursosHumanos.Empleado.emailPerCifrado', 'emailPer', 'COLUMN';
EXEC sp_rename 'recursosHumanos.Empleado.emailEmpCifrado', 'emailEmp', 'COLUMN';
EXEC sp_rename 'recursosHumanos.Empleado.cuilCifrado', 'cuil', 'COLUMN';
go

--vemos los datos encriptados
select * from recursosHumanos.Empleado

declare @FraseClave nvarchar(128);  
set @FraseClave = 'QuieroMiPanDanes'; 
--vemos los datos desencriptados
select 
	legajo,
	CONVERT(VARCHAR(50), DecryptByPassPhrase(@FraseClave, nombre, 1, CONVERT(VARBINARY, legajo))) as nombre,
	CONVERT(VARCHAR(50), DecryptByPassPhrase(@FraseClave, apellido, 1, CONVERT(VARBINARY, legajo))) as apellido,
	CONVERT(varchar(50), DecryptByPassPhrase(@FraseClave, dni, 1, CONVERT(VARBINARY, legajo))) as dni,
	CONVERT(varchar(100), DecryptByPassPhrase(@FraseClave, direccion, 1, CONVERT(VARBINARY, legajo))) as direccion,
	CONVERT(varchar(60), DecryptByPassPhrase(@FraseClave, emailPer, 1, CONVERT(VARBINARY, legajo))) as emailPer,
	CONVERT(varchar(60), DecryptByPassPhrase(@FraseClave, emailEmp, 1, CONVERT(VARBINARY, legajo))) as emailEmp,
	CONVERT(char(13), DecryptByPassPhrase(@FraseClave, cuil, 1, CONVERT(VARBINARY, legajo))) as cuil,
	cargo,
	idSucursal,
	turno,
	activo
from recursosHumanos.Empleado
