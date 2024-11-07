use [Com5600G13]
go

--SUCURSAL
exec sucursales.darAltaSucursalEnBaja 4
select * from sucursales.Sucursal

exec sucursales.modificarDireccionSucursal 4, 'AV. Don Bosco 123', 'Moron'
select * from sucursales.Sucursal
--Probamos cambiar la direccion a una que tiene otra sucursal
exec sucursales.modificarDireccionSucursal 1, 'AV. Don Bosco 123', 'Moron'

exec sucursales.modificarHorarioSucursal 4, 'L a V 8-10; S y D 10-12'
select * from sucursales.Sucursal

--Probamos un telefono invalido
exec sucursales.modificarTelefonoSucursal 4, '12'
exec sucursales.modificarTelefonoSucursal 4, '2222-2222'
select * from sucursales.Sucursal


--EMPLEADO

--CAMBIAR NOMBRE DE EMPLEADO USANDO SU LEGAJO
--intentamos insertar un legajo y nombre nulo
exec recursosHumanos.cambiarNombreEmpleadoPorLegajo null,null
--ahora un legajo inexistente
exec recursosHumanos.cambiarNombreEmpleadoPorLegajo 1,'Roberto'
select * from recursosHumanos.Empleado
--ahora un caso valido
select nombre from recursosHumanos.Empleado where legajo=257020
--Vemos que originalmente se llama Romina Alejandra, la cambiamos por Romina Abigail
exec recursosHumanos.cambiarNombreEmpleadoPorLegajo 257020,'Romina Abigail'
--Vemos que los cambios se efectuaron
select nombre from recursosHumanos.Empleado where legajo=257020
--deshacemos los cambios
exec recursosHumanos.cambiarNombreEmpleadoPorLegajo 257020,'Romina Alejandra'

--Existe otra version de este SP, funciona exactamente igual pero identifica al
--empleado usando su dni en vez de legajo:
select nombre from recursosHumanos.Empleado where dni=36383025
--Vemos que originalmente se llama Romina Alejandra, la cambiamos por Romina Abigail
exec recursosHumanos.cambiarNombreEmpleadoPorDni 36383025,'Romina Abigail'
--Vemos que los cambios se efectuaron
select nombre from recursosHumanos.Empleado where dni=36383025
--deshacemos los cambios
exec recursosHumanos.cambiarNombreEmpleadoPorDni 36383025,'Romina Alejandra'

--CAMBIAR APELLIDO DE UN EMPLEADO
--usando legajo
--intentamos insertar parametros nulos
exec recursosHumanos.cambiarApellidoEmpleadoPorLegajo null,null
--ahora un caso valido (ejecuta todo el bloque)
declare @legajo int
declare @apellidoOri varchar(50)
set @legajo=(select top 1 legajo from recursosHumanos.empleado)
set @apellidoOri=(select apellido from recursosHumanos.Empleado where legajo=@legajo)
select * from recursosHumanos.Empleado where legajo=@legajo
exec recursosHumanos.cambiarApellidoEmpleadoPorLegajo @legajo,'Ramirez'
select * from recursosHumanos.Empleado where legajo=@legajo
exec recursosHumanos.cambiarApellidoEmpleadoPorLegajo @legajo,@apellidoOri
select * from recursosHumanos.Empleado where legajo=@legajo
go
--usando dni (ejecuta todo el bloque)
DECLARE @dni INT
DECLARE @apellidoOri VARCHAR(50)
SET @dni = (SELECT TOP 1 dni FROM recursosHumanos.Empleado)
SET @apellidoOri = (SELECT apellido FROM recursosHumanos.Empleado WHERE dni = @dni)
SELECT * FROM recursosHumanos.Empleado WHERE dni = @dni
EXEC recursosHumanos.cambiarApellidoEmpleadoPorDni @dni, 'Ramirez'
SELECT * FROM recursosHumanos.Empleado WHERE dni = @dni
EXEC recursosHumanos.cambiarApellidoEmpleadoPorDni @dni, @apellidoOri
select * from recursosHumanos.Empleado where dni =@dni
go

--CAMBIAR DIRECCION DE UN EMPLEADO
--usando legajo
--intentamos insertar con un legajo inexistente y una direccion vacia
exec recursosHumanos.cambiarDireccionEmpleadoPorLegajo 29320,'       '
--ahora probamos un caso valido (ejecutar bloque entero)
declare @legajo int
declare @direccionOri varchar(100)
set @legajo=(select top 1 legajo from recursosHumanos.empleado)
set @direccionOri=(select direccion from recursosHumanos.Empleado where legajo=@legajo)
select * from recursosHumanos.Empleado where legajo=@legajo
exec recursosHumanos.cambiarDireccionEmpleadoPorLegajo @legajo,'Avenida SiempreViva 747, Springfield, USA'
select * from recursosHumanos.Empleado where legajo=@legajo
exec recursosHumanos.cambiarDireccionEmpleadoPorLegajo @legajo,@direccionOri
select * from recursosHumanos.Empleado where legajo=@legajo
go

--usando dni
--intentamos un caso de dni inexistente junto con direccion vacio
exec recursosHumanos.cambiarDireccionEmpleadoPorDni 2932,'   '
--Ahora un caso valido (ejecutar el bloque entero)
DECLARE @dni INT
DECLARE @direccionOri VARCHAR(100)
SET @dni = (SELECT TOP 1 dni FROM recursosHumanos.empleado)
SET @direccionOri = (SELECT direccion FROM recursosHumanos.Empleado WHERE dni = @dni)
SELECT * FROM recursosHumanos.Empleado WHERE dni = @dni
EXEC recursosHumanos.cambiarDireccionEmpleadoPorDni @dni, 'Avenida SiempreViva 747, Springfield, USA'
SELECT * FROM recursosHumanos.Empleado WHERE dni = @dni
EXEC recursosHumanos.cambiarDireccionEmpleadoPorDni @dni, @direccionOri
SELECT * FROM recursosHumanos.Empleado WHERE dni = @dni
GO

--CAMBIAR EMAIL PERSONAL DE UN EMPLEADO
--usando legajo
--intentamos insertar un correo vacio con un legajo inexistente
exec recursosHumanos.cambiarMailPersonalEmpleadoPorLegajo 2392,''
--ahora intentamos ingresar un correo que ya existe
exec recursosHumanos.cambiarMailPersonalEmpleadoPorLegajo 2392,'Emilce_MAIDANA@gmail.com'



--ahora vamos con un caso valido (ejecutar bloque completo)
declare @legajo int
declare @correoPerOri varchar(60)
set @legajo=(select top 1 legajo from recursosHumanos.empleado)
set @correoPerOri=(select emailPer from recursosHumanos.Empleado where legajo=@legajo)
select * from recursosHumanos.Empleado where legajo=@legajo
exec recursosHumanos.cambiarMailPersonalEmpleadoPorLegajo @legajo,'losBroncosaurios@gmail.com'
select * from recursosHumanos.Empleado where legajo=@legajo
exec recursosHumanos.cambiarMailPersonalEmpleadoPorLegajo @legajo,@correoPerOri
select * from recursosHumanos.Empleado where legajo=@legajo
go

--usando dni
--intentamos insertar un correo vacio con un dni inexistente
exec recursosHumanos.cambiarMailPersonalEmpleadoPorDni 2392,''
--ahora intentamos ingresar un correo que ya existe
exec recursosHumanos.cambiarMailPersonalEmpleadoPorDni 2392,'Romina Alejandra_ALIAS@gmail.com'


--ahora un caso valido (ejecutar bloque completo)
declare @dni int
declare @correoPerOri varchar(60)
set @dni=(select top 1 dni from recursosHumanos.empleado)
set @correoPerOri=(select emailPer from recursosHumanos.Empleado where dni=@dni)
select * from recursosHumanos.Empleado where dni=@dni
exec recursosHumanos.cambiarMailPersonalEmpleadoPorDni @dni,'losBroncosaurios@gmail.com'
select * from recursosHumanos.Empleado where dni=@dni
exec recursosHumanos.cambiarMailPersonalEmpleadoPorDni @dni,@correoPerOri
select * from recursosHumanos.Empleado where dni=@dni
go

--CAMBIAR CORREO EMPRESARIAL DE UN EMPLEADO
--usando legajo
--intentamos insertar un correo vacio con un legajo inexistente
exec recursosHumanos.cambiarMailEmpresarialEmpleadoPorLegajo 2392,''
--ahora intentamos ingresar un correo que ya existe
exec recursosHumanos.cambiarMailEmpresarialEmpleadoPorLegajo 2392,'Romina Alejandra.ALIAS@superA.com'

--ahora un caso valido (ejecutar bloque completo)
declare @legajo int
declare @correoEmpOri varchar(60)
set @legajo=(select legajo from recursosHumanos.Empleado where REPLACE(emailEmp, CHAR(9), ' ')='Romina Alejandra.ALIAS@superA.com')
set @correoEmpOri=(select emailEmp from recursosHumanos.Empleado where legajo=@legajo)
select * from recursosHumanos.Empleado where legajo=@legajo
exec recursosHumanos.cambiarMailEmpresarialEmpleadoPorLegajo @legajo,'Romina Alejandra.ALIAS@losPollosHermanos.com'
select * from recursosHumanos.Empleado where legajo=@legajo
exec recursosHumanos.cambiarMailEmpresarialEmpleadoPorLegajo @legajo,'Romina Alejandra.ALIAS@superA.com'
select * from recursosHumanos.Empleado where legajo=@legajo
go

--usando dni
--intentamos insertar un correo vacio con un legajo inexistente
exec recursosHumanos.cambiarMailEmpresarialEmpleadoPorDni 2392,''
--ahora intentamos ingresar un correo que ya existe
exec recursosHumanos.cambiarMailEmpresarialEmpleadoPorDni 2392,'Romina Alejandra.ALIAS@superA.com'

--ahora un caso valido (ejecutar bloque completo)
declare @dni int
declare @correoEmpOri varchar(60)
set @dni = (select dni from recursosHumanos.Empleado where REPLACE(emailEmp, CHAR(9), ' ') = 'Romina Alejandra.ALIAS@superA.com')
set @correoEmpOri = (select emailEmp from recursosHumanos.Empleado where dni = @dni)
select * from recursosHumanos.Empleado where dni = @dni
exec recursosHumanos.cambiarMailEmpresarialEmpleadoPorDni @dni, 'Romina Alejandra.ALIAS@losPollosHermanos.com'
select * from recursosHumanos.Empleado where dni = @dni
exec recursosHumanos.cambiarMailEmpresarialEmpleadoPorDni @dni, @correoEmpOri
select * from recursosHumanos.Empleado where dni = @dni
go


--CAMBIAR CARGO DE UN EMPLEADO
--usando legajo
--intentamos meter datos nulos
exec recursosHumanos.cambiarCargoEmpleadoPorLegajo null,null
--intentamos meter un cargo que no existe
exec recursosHumanos.cambiarCargoEmpleadoPorLegajo null,'Barrendero'

--ahora un caso valido (ejecutar bloque completo)
declare @legajo int
declare @cargoOriCod int
declare @cargoOri varchar(20)
set @legajo=(select top 1 legajo from recursosHumanos.Empleado where cargo<>2)
set @cargoOriCod=(select cargo from recursosHumanos.Empleado where legajo=@legajo)
set @cargoOri=(select cargo from recursosHumanos.cargo where id=@cargoOriCod)
select e.legajo,e.nombre,c.cargo from recursosHumanos.Empleado e inner join recursosHumanos.cargo c on e.cargo=c.id where legajo=@legajo
exec recursosHumanos.cambiarCargoEmpleadoPorLegajo @legajo,'Gerente de sucursal'
select e.legajo,e.nombre,c.cargo from recursosHumanos.Empleado e inner join recursosHumanos.cargo c on e.cargo=c.id where legajo=@legajo
exec recursosHumanos.cambiarCargoEmpleadoPorLegajo @legajo,@cargoOri
select e.legajo,e.nombre,c.cargo from recursosHumanos.Empleado e inner join recursosHumanos.cargo c on e.cargo=c.id where legajo=@legajo
go

--usando dni
--intentamos meter datos nulos
exec recursosHumanos.cambiarCargoEmpleadoPorDni null,null
--intentamos meter un cargo que no existe
exec recursosHumanos.cambiarCargoEmpleadoPorDni 2832,'Barrendero'

--ahora un caso valido (ejecutar bloque completo)
declare @dni int
declare @cargoOriCod int
declare @cargoOri varchar(20)
set @dni = (select top 1 dni from recursosHumanos.Empleado where cargo <> 2)
set @cargoOriCod = (select cargo from recursosHumanos.Empleado where dni = @dni)
set @cargoOri = (select cargo from recursosHumanos.cargo where id = @cargoOriCod)
select e.dni, e.nombre, c.cargo from recursosHumanos.Empleado e inner join recursosHumanos.cargo c on e.cargo = c.id where dni = @dni
exec recursosHumanos.cambiarCargoEmpleadoPorDni @dni, 'Gerente de sucursal' 
select e.dni, e.nombre, c.cargo from recursosHumanos.Empleado e inner join recursosHumanos.cargo c on e.cargo = c.id where dni = @dni
exec recursosHumanos.cambiarCargoEmpleadoPorDni @dni, @cargoOri
select e.dni, e.nombre, c.cargo from recursosHumanos.Empleado e inner join recursosHumanos.cargo c on e.cargo = c.id where dni = @dni
go

--CAMBIAR SUCURSAL DE UN EMPLEADO
select * from sucursales.sucursal
select * from recursosHumanos.empleado
--por legajo
--intentamos ingresar datos nulos
exec recursosHumanos.cambiarSucursalEmpleadoPorLegajo null,null

--intentamos ingresar un legajo que no existe y una sucursal que tampoco existe
exec recursosHumanos.cambiarSucursalEmpleadoPorLegajo 1,29392

--ahora un caso valido (ejecutar bloque completo)
declare @idSucursalNuevo int
declare @idSucursalOri int
declare @legajo int
set @legajo=(select top 1 legajo from recursosHumanos.empleado)
set @idSucursalNuevo=(select top 1 id from sucursales.sucursal)
set @idSucursalOri=(select idSucursal from recursosHumanos.empleado where legajo=@legajo and idSucursal<>@idSucursalNuevo)
select e.legajo,e.nombre,e.idSucursal,s.ciudad,s.direccion from recursosHumanos.empleado e inner join sucursales.sucursal s
on e.idSucursal=s.id where legajo=@legajo
exec recursosHumanos.cambiarSucursalEmpleadoPorLegajo @legajo,@idSucursalNuevo
select e.legajo,e.nombre,e.idSucursal,s.ciudad,s.direccion from recursosHumanos.empleado e inner join sucursales.sucursal s
on e.idSucursal=s.id where legajo=@legajo
exec recursosHumanos.cambiarSucursalEmpleadoPorLegajo @legajo,@idSucursalOri
select e.legajo,e.nombre,e.idSucursal,s.ciudad,s.direccion from recursosHumanos.empleado e inner join sucursales.sucursal s
on e.idSucursal=s.id where legajo=@legajo
go

--usando dni
--intentamos ingresar datos nulos
exec recursosHumanos.cambiarSucursalEmpleadoPorDni null,null

--intentamos ingresar un legajo que no existe y una sucursal que tampoco existe
exec recursosHumanos.cambiarSucursalEmpleadoPorDni 1,29392

--ahora un caso valido (ejecutar bloque completo)
declare @idSucursalNuevo int
declare @idSucursalOri int
declare @dni int
set @dni=(select top 1 dni from recursosHumanos.empleado)
set @idSucursalNuevo=(select top 1 id from sucursales.sucursal)
set @idSucursalOri=(select idSucursal from recursosHumanos.empleado where dni=@dni and idSucursal<>@idSucursalNuevo)
select e.dni,e.nombre,e.idSucursal,s.ciudad,s.direccion from recursosHumanos.empleado e inner join sucursales.sucursal s
on e.idSucursal=s.id where dni=@dni
exec recursosHumanos.cambiarSucursalEmpleadoPorDni @dni,@idSucursalNuevo
select e.dni,e.nombre,e.idSucursal,s.ciudad,s.direccion from recursosHumanos.empleado e inner join sucursales.sucursal s
on e.idSucursal=s.id where dni=@dni
exec recursosHumanos.cambiarSucursalEmpleadoPorDni @dni,@idSucursalOri
select e.dni,e.nombre,e.idSucursal,s.ciudad,s.direccion from recursosHumanos.empleado e inner join sucursales.sucursal s
on e.idSucursal=s.id where dni=@dni
go


--CAMBIAR TURNO DE UN EMPLEADO
--usando legajo
--intentamos ingresar datos nulos
exec recursosHumanos.cambiarTurnoEmpleadoPorLegajo null,null
--intentamos ingresar un turno que no existe con un legajo que no existe
exec recursosHumanos.cambiarTurnoEmpleadoPorLegajo 29,'Jornada nocturna'

--ahora un caso valido (ejecutar bloque completo)
declare @legajo int
declare @turnoViejo varchar(20)
set @legajo=(select top 1 legajo from recursosHumanos.empleado)
set @turnoViejo=(select top 1 turno from recursosHumanos.empleado where turno<>'TM' and legajo=@legajo)
select * from recursosHumanos.empleado where legajo=@legajo
exec recursosHumanos.cambiarTurnoEmpleadoPorLegajo @legajo,'TM'
select * from recursosHumanos.empleado where legajo=@legajo
exec recursosHumanos.cambiarTurnoEmpleadoPorLegajo @legajo,@turnoViejo
select * from recursosHumanos.empleado where legajo=@legajo
go

--intentamos ingresar datos nulos
exec recursosHumanos.cambiarTurnoEmpleadoPorDni null,null
--intentamos ingresar un turno que no existe con un legajo que no existe
exec recursosHumanos.cambiarTurnoEmpleadoPorDni 29,'Jornada nocturna'

--ahora un caso valido (ejecutar bloque completo)
declare @dni int
declare @turnoViejo varchar(20)
set @dni=(select top 1 dni from recursosHumanos.empleado)
set @turnoViejo=(select top 1 turno from recursosHumanos.empleado where turno<>'TM' and dni=@dni)
select * from recursosHumanos.empleado where dni=@dni
exec recursosHumanos.cambiarTurnoEmpleadoPorDni @dni,'TM'
select * from recursosHumanos.empleado where dni=@dni
exec recursosHumanos.cambiarTurnoEmpleadoPorDni @dni,@turnoViejo
select * from recursosHumanos.empleado where dni=@dni
go

--DAR DE ALTA UN EMPLEADO
--con legajo
--pasamos un legajo nulo
exec recursosHumanos.darDeAltaEmpleadoPorLegajo null
--ahora uno que no existe
exec recursosHumanos.darDeAltaEmpleadoPorLegajo 2

--Ahora un caso valido (ejecutar bloque completo)
select legajo,nombre,activo from recursosHumanos.empleado where legajo=257020
--la damos de baja
update recursosHumanos.Empleado
set activo=0
where legajo=257020

select legajo,nombre,activo from recursosHumanos.empleado where legajo=257020
--la damos de alta usando el sp
exec recursosHumanos.darDeAltaEmpleadoPorLegajo 257020
select legajo,nombre,activo from recursosHumanos.empleado where legajo=257020


--con dni
--pasamos un dni nulo
exec recursosHumanos.darDeAltaEmpleadoPorDni null
--ahora uno que no existe
exec recursosHumanos.darDeAltaEmpleadoPorDni 2
select * from recursosHumanos.Empleado
--Ahora un caso valido (ejecutar bloque completo)
select legajo,nombre,activo from recursosHumanos.empleado where dni=36383025
--la damos de baja
update recursosHumanos.Empleado
set activo=0
where dni=36383025

select legajo,nombre,activo from recursosHumanos.empleado where dni=36383025
--la damos de alta usando el sp
exec recursosHumanos.darDeAltaEmpleadoPorDni 36383025
select legajo,nombre,activo from recursosHumanos.empleado where dni=36383025










