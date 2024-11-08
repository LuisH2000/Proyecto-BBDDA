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