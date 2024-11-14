use Com5600G13
go

--Probamos una factura inexistente
exec comprobantes.generarNotaDeCredito @factura='31-2-3', @idProd=41, @cantidadDevolver=3
--Probamos con una factura existente pero con un producto que no esta en la factura
exec comprobantes.generarNotaDeCredito @factura='750-67-8428', @idProd=41, @cantidadDevolver=3
--Probamos intentando devolver mas de lo que se compro
exec comprobantes.generarNotaDeCredito @factura='750-67-8428', @idProd=4149, @cantidadDevolver=8
--Probamos crear una nota para una factura impaga
declare @tablaProds tablaProductosIdCant
insert into @tablaProds
values(1,2),(2,2)
exec ventas.insertarFactura @idFactura = '980-23-2932',@tipoFactura = 'A',@empleadoLeg = 257020, @idCliente = 1, @prodsId = @tablaProds

exec comprobantes.generarNotaDeCredito @factura='980-23-2932', @idProd=1, @cantidadDevolver=2
--Creamos una nota de credito
exec comprobantes.generarNotaDeCredito @factura='750-67-8428', @idProd=4149, @cantidadDevolver=2
select * from comprobantes.Comprobante where idFactura = 1
