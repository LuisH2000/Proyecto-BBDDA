--Seleccionar la BD
use [Com5600G13]
go
--CARGA INICIAL DE DATOS (ejecutar el SP, solo hace falta hacerlo una vez, si ya lo ejecuto previamente ignore este paso)
exec testing.crearDatosDePrueba
--SUCURSAL
--Dar de baja sucursal que no existe
exec sucursales.bajaSucursalId 5
--Vemos que al dar de baja la sucursal, sigue en la tabla pero deja de estar activo
select * from sucursales.Sucursal where id = 2
exec sucursales.bajaSucursalId 2
select * from sucursales.Sucursal where id = 2
--volvemos a dar de alta la sucursal
exec sucursales.darAltaSucursalEnBaja 2
select * from sucursales.Sucursal where id = 2

--EMPLEADO
--Dar de baja empleado que no existe
exec recursosHumanos.bajaEmpleado 5
--Vemos que al dar de baja el empleado, sigue en la tabla pero deja de estar activo
select * from recursosHumanos.Empleado where legajo = 1
exec recursosHumanos.bajaEmpleado 1
select * from recursosHumanos.Empleado where legajo = 1
--volvemos a dar de alta al empleado
exec recursosHumanos.darDeAltaEmpleadoPorLegajo 1
select * from recursosHumanos.Empleado where legajo = 1

--CARGO
--Eliminar cargo que no existe (caso no valido)
exec recursosHumanos.eliminarCargoId 123
--Eliminar cargo con empleados con ese cargo (caso no valido)
exec recursosHumanos.eliminarCargoId 1
--Eliminar un cargo sin empleados (caso valido)
--insertamos un cargo nuevo sin empleados asociados
exec recursosHumanos.insertarCargo 'Mago'
select * from recursosHumanos.cargo
--lo damos de baja (ejecutar bloque completo)
declare @idMago int
set @idMago=(select id from recursosHumanos.cargo where cargo='Mago')
exec recursosHumanos.eliminarCargoId @idMago
--vemos que se elimino
select * from recursosHumanos.cargo

--LINEAPRODUCTO
--Eliminar linea de producto que no existe
exec catalogo.eliminarLineaProductoId -1
--Eliminar linea de producto con categoria con esa linea
exec catalogo.eliminarLineaProductoId 1
--Eliminar una linea de producto sin categoria, insertamos una nueva linea de producto
exec catalogo.insertarLineaProducto 'Fantasia'
select * from catalogo.LineaProducto where lineaProd = 'Fantasia'
--Lo eliminamos
declare @idFantasia int
set @idFantasia=(select id from catalogo.LineaProducto where lineaProd='Fantasia')
exec catalogo.eliminarLineaProductoId @idFantasia
--vemos que se elimino
select * from catalogo.LineaProducto where lineaProd = 'Fantasia'

--PRODUCTO
--Dar de baja producto que no existe
exec catalogo.bajaProductoId -1
--Dar de baja producto, el campo activo pasa a ser 0
select * from catalogo.Producto where id = 1
exec catalogo.bajaProductoId 1
select * from catalogo.Producto where id = 1
--volvemos a poner el producto en alta
exec catalogo.darAltaProductoEnBaja 1
select * from catalogo.Producto where id = 1

--CATEGORIA
--Eliminar categoria que no existe
exec catalogo.eliminarCategoriaId -1
--Eliminar categoria con productos con esa categoria
exec catalogo.eliminarCategoriaId 1
--Eliminar categoria sin productos con esa categoria, insertamos una categoria nueva
exec catalogo.insertarLineaProductoYCategoria 'Bazar','Lamparas_Funshwei'
select * from catalogo.Categoria where categoria = 'Lamparas_Funshwei'
--Eliminamos la categoria insertada
declare @idLamparas int
set @idLamparas=(select id from catalogo.Categoria where categoria='Lamparas_Funshwei')
exec catalogo.eliminarCategoriaId @idLamparas
--vemos que se elimino (select vacio)
select * from catalogo.Categoria where categoria = 'Lamparas_Funshwei'

--PERTENECEA
--Eliminar la categoria que pertenece un producto inexistente y categoria inexistente
exec catalogo.eliminarProductoDeUnaCategoria -1, null
--Eliminar la categoria al que no pertenece el producto
select * from catalogo.PerteneceA where idProd = 1 --vemos que el producto pertenece a la categoria 1
exec catalogo.eliminarProductoDeUnaCategoria @idProd = 1, @idCat = 2
--Eliminar la categoria a la que pertenece un producto (ejecutar transaccion completa, ver que el primer select muestra el producto y el segundo ya no porque se borro)
begin transaction
select * from catalogo.PerteneceA where idProd=1 and idCategoria=1
exec catalogo.eliminarProductoDeUnaCategoria @idProd = 1, @idCat = 1
select * from catalogo.PerteneceA where idProd = 1 and idCategoria=1 
rollback


--MEDIODEPAGO
--Dar de baja medio de pago que no existe
exec comprobantes.bajaMedioPagoId -1
--Dar de baja medio de pago
select * from comprobantes.MedioDePago where id = 1
exec comprobantes.bajaMedioPagoId 1
select * from comprobantes.MedioDePago where id = 1
--lo damos de alta denuevo
exec comprobantes.darAltaMedioDePagoEnBaja 1
select * from comprobantes.MedioDePago where id = 1

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
select * from ventas.Factura -- vemos que se encontraba pagada
--anulamos una factura (ejecutar transaccion completa)
begin transaction
	insert into ventas.Factura(idFactura) values('555-55-5555') --insertamos una factura nueva (no va a tener comprobante asociado asi que va a estar impaga)
	--nota: usamos un insert en vez del sp correspondiente porque para los propositos de esta prueba hacer esto es mas simple y directo...
	declare @id int = (select id from ventas.Factura where idFactura = '555-55-5555') 
	select * from ventas.Factura where id = @id
	exec ventas.anularFactura @id --lo borramos
	select * from ventas.Factura where id = @id
rollback

--LINEA DE FACTURA
--intentamos con parametros nulos
exec ventas.anularLineaFactura null
--intentamos con una linea de factura que no existe
exec ventas.anularLineaFactura -1
--intentamos con una linea asociada a una factura pagada
exec ventas.anularLineaFactura 1
--anulamos una linea de factura (vemos que pasa de salir en el select a ya no salir)
begin transaction
	insert into ventas.Factura(idFactura) values('555-55-5555') --insertamos una factura sin comprobante para que quede en estado impagada
	declare @idFa int = (select id from ventas.Factura where idFactura = '555-55-5555') 
	insert into ventas.LineaDeFactura(idFactura) values (@idFa) --le insertamos una linea de producto
	declare @idLn int = (select id from ventas.LineaDeFactura where idFactura = @idFa)
	select * from ventas.LineaDeFactura where id = @idLn
	exec ventas.anularLineaFactura @idLn --anulamos la linea
	select * from ventas.LineaDeFactura where id = @idLn
	--nota: usamos inserts en vez de los sp correspondientes porque para los propositos de esta prueba el insert es mas simple y directo..
rollback

--COMPROBANTE
--intentamos con parametros nulos
exec comprobantes.anularComprobante null
--intentamos con un comprobante que no existe
exec comprobantes.anularComprobante -1
--anulamos un comprobante (ejecutar transaccion completa)
begin transaction
	declare @idFactura int = (select top 1 id from ventas.Factura)
	--vemos la factura
	select * from ventas.Factura where id = @idFactura
	declare @idComprobante int = (select id from comprobantes.Comprobante where idFactura = @idFactura)
	--vemos su comprobante
	select * from comprobantes.Comprobante where idFactura = @idFactura
	exec comprobantes.anularComprobante @idComprobante
	--vemos que como se anulo su comprobante la factura pasa a estar impaga denuevo y ademas el comprobante ya no sale en el select
	select * from ventas.Factura where id = @idFactura
	select * from comprobantes.Comprobante where idFactura = @idFactura
rollback