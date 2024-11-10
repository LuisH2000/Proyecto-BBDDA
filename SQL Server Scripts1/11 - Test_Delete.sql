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

--TIPO CLIENTE
--borrar un tipo de cliente (para la prueba lo usaremos en conjunto con clientes.cambiarClientesDeUnTipoAOtro ya que 
--para borrar un tipo de cliente ningun cliente debe pertenecer al mismo, para esto primero migraremos los clientes que pertenecen al tipo que 
--va a ser borrado y luego borraremos el tipo) 
--primero probamos un caso no valido pasando null
exec clientes.borrarTipoDeCliente null
--ahora pasemos un tipo de cliente que no existe
exec clientes.borrarTipoDeCliente 34323
--ahora intentamos borrar un tipo que aun tiene clientes asociados
exec clientes.borrarTipoDeCliente 1

--ahora un caso valido donde borramos el tipo de cliente con id 1 (ejecutar transaccion completa)
begin transaction
--vemos los tipos de cliente que existen
select * from clientes.TipoCliente
--migramos los clientes del tipo id 1 a otro tipo (2)
exec clientes.cambiarClientesDeUnTipoAOtro 1,2
--borramos el tipo de cliente 1
exec clientes.borrarTipoDeCliente 1
--vemos que se borro
select * from clientes.TipoCliente
--restauramos los datos a como estaban antes
rollback

--CLIENTE
--intentamos con parametros nulo
exec clientes.bajaCliente null
--intentamos con un cliente que no existe
exec clientes.bajaCliente -1
--damos de baja un cliente, el campo activo pasa a ser 0
begin transaction
	select * from clientes.Cliente where id = 1
	exec clientes.bajaCliente 1
	select * from clientes.Cliente where id = 1
rollback

--FACTURA
--intentamos con parametros nulos
exec ventas.anularFactura null
--intentamos con una factura inexistente
exec ventas.anularFactura -1
--intentamos con una factura pagada
exec ventas.anularFactura 1
--anulamos una factura
begin transaction
	insert into ventas.Factura(idFactura) values('111-11-1111')
	declare @id int = (select id from ventas.Factura where idFactura = '111-11-1111')
	select * from ventas.Factura where id = @id
	exec ventas.anularFactura @id
	select * from ventas.Factura where id = @id
rollback

--LINEA DE FACTURA
--intentamos con parametros nulos
exec ventas.anularLineaFactura null
--intentamos con una linea de factura que no existe
exec ventas.anularLineaFactura -1
--intentamos con una linea asociada a una factura pagada
exec ventas.anularLineaFactura 1
--anulamos una linea de factura
begin transaction
	insert into ventas.Factura(idFactura) values('111-11-1111')
	declare @idFa int = (select id from ventas.Factura where idFactura = '111-11-1111')
	insert into ventas.LineaDeFactura(idFactura) values (@idFa)
	declare @idLn int = (select id from ventas.LineaDeFactura where idFactura = @idFa)
	select * from ventas.LineaDeFactura where id = @idLn
	exec ventas.anularLineaFactura @idLn
	select * from ventas.LineaDeFactura where id = @idLn
rollback

--COMPROBANTE
--intentamos con parametros nulos
exec comprobantes.anularComprobante null
--intentamos con un comprobante que no existe
exec comprobantes.anularComprobante -1
--anulamos un comprobante
begin transaction
	declare @idFactura int = (select top 1 id from ventas.Factura)
	select * from ventas.Factura where id = @idFactura
	declare @idComprobante int = (select id from comprobantes.Comprobante where idFactura = @idFactura)
	select * from comprobantes.Comprobante where idFactura = @idFactura
	exec comprobantes.anularComprobante @idComprobante
	select * from ventas.Factura where id = @idFactura
	select * from comprobantes.Comprobante where idFactura = @idFactura
rollback