use [Com5600G13]
go

--SUCURSAL
--Dar de baja sucursal que no existe
exec sucursales.bajaSucursalId 5
--Vemos que al dar de baja la sucursal, sigue en la tabla pero deja de estar activo
select * from sucursales.Sucursal where id = 3
exec sucursales.bajaSucursalId 3
select * from sucursales.Sucursal where id = 3

update sucursales.Sucursal set activo = 1 where id = 3

--EMPLEADO
--Dar de baja empleado que no existe
exec recursosHumanos.bajaEmpleado 5
--Vemos que al dar de baja el empleado, sigue en la tabla pero deja de estar activo
select * from recursosHumanos.Empleado where legajo = 257020
exec recursosHumanos.bajaEmpleado 257020
select * from recursosHumanos.Empleado where legajo = 257020

update recursosHumanos.Empleado set activo = 1 where legajo = 257020

--CARGO
--Eliminar cargo que no existe
exec recursosHumanos.eliminarCargoId 123
--Eliminar cargo con empleados con ese cargo
exec recursosHumanos.eliminarCargoId 1
--Eliminar un cargo sin empleados
insert into recursosHumanos.Cargo values('Manager')
select * from recursosHumanos.Cargo
exec recursosHumanos.eliminarCargoId 4

--LINEAPRODUCTO
--Eliminar linea de producto que no existe
exec catalogo.eliminarLineaProductoId -1
--Eliminar linea de producto con categoria con esa linea
exec catalogo.eliminarLineaProductoId 1
--Eliminar una linea de producto sin categoria, insertamos una nueva linea de producto
insert into catalogo.LineaProducto values('Fantasia')
select * from catalogo.LineaProducto where lineaProd = 'Fantasia'
--Lo eliminamos
exec catalogo.eliminarLineaProductoId 13
select * from catalogo.LineaProducto where lineaProd = 'Fantasia'

--PRODUCTO
--Dar de baja producto que no existe
exec catalogo.bajaProductoId -1
--Dar de baja producto, el campo activo pasa a ser 0
select * from catalogo.Producto where id = 1
exec catalogo.bajaProductoId 1
select * from catalogo.Producto where id = 1

update catalogo.Producto set activo = 1 where id = 1

--CATEGORIA
--Eliminar categoria que no existe
exec catalogo.eliminarCategoriaId -1
--Eliminar categoria con productos con esa categoria
exec catalogo.eliminarCategoriaId 1
--Eliminar categoria sin productos con esa categoria, insertamos una categoria nueva
insert into catalogo.Categoria(categoria, idLineaProd) values('Peluches', 1)
select * from catalogo.Categoria where categoria = 'Peluches'
--Eliminamos la categoria insertada
exec catalogo.eliminarCategoriaId 158
select * from catalogo.Categoria where categoria = 'Peluches'

--PERTENECEA
--Eliminar la categoria que pertenece un producto inexistente y categoria inexistente
exec catalogo.eliminarProductoDeUnaCategoria -1, null
--Eliminar la categoria al que no pertenece el producto
select * from catalogo.PerteneceA where idProd = 1
exec catalogo.eliminarProductoDeUnaCategoria @idProd = 1, @idCat = 1
--Eliminar la categoria a la que pertenece un producto
exec catalogo.eliminarProductoDeUnaCategoria @idProd = 1, @idCat = 90
select * from catalogo.PerteneceA where idProd = 1

insert into catalogo.PerteneceA(idCategoria, idProd) values(90,1)

--MEDIODEPAGO
--Dar de baja medio de pago que no existe
exec comprobantes.bajaMedioPagoId -1
--Dar de baja medio de pago
select * from comprobantes.MedioDePago where id = 1
exec comprobantes.bajaMedioPagoId 1
select * from comprobantes.MedioDePago where id = 1

update comprobantes.MedioDePago set activo = 1 where id = 1