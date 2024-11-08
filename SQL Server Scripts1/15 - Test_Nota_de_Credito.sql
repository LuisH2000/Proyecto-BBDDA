use Com5600G13
go

select * from ventas.Factura f join ventas.LineaDeFactura l on f.id = l.idFactura where f.id = 1

declare @tablaProds tablaProductosIdCant
insert into @tablaProds
values(1,2),(2,2)
exec ventas.insertarFactura @idFactura = '980-23-2932',@tipoFactura = 'A',@empleadoLeg = 257020, @ciudadCliente = 'San Justo', @genero = 'Female', @tipoCliente = 'Normal', @prodsId = @tablaProds

--Probamos una factura inexistente
exec comprobantes.generarNotaDeCredito @factura='31-2-3', @idProd=41, @cantidadDevolver=3
--Probamos con una factura existente pero con un producto que no esta en la factura
exec comprobantes.generarNotaDeCredito @factura='750-67-8428', @idProd=41, @cantidadDevolver=3
--Probamos intentando devolver mas de lo que se compro
exec comprobantes.generarNotaDeCredito @factura='750-67-8428', @idProd=4149, @cantidadDevolver=8
--Probamos crear una nota para una factura impaga
exec comprobantes.generarNotaDeCredito @factura='980-23-2932', @idProd=1, @cantidadDevolver=2
--Creamos una nota de credito
exec comprobantes.generarNotaDeCredito @factura='750-67-8428', @idProd=4149, @cantidadDevolver=2
select * from comprobantes.Comprobante where idFactura = 1
