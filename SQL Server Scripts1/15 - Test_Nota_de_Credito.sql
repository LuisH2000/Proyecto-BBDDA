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
exec comprobantes.generarNotaDeCredito @factura='750-67-8428', @idProd=4149, @cantidadDevolver=2 --lo ejecutamos 4 veces, veremos que a la cuarta ya no nos va a dejar
--ya que se compraron 7 unidades del producto con id 4149, ejecutar 4 veces implicaria hacer 4 notas de credito donde el cliente devuelve cada vez 2 unidades
--al llegar a la cuarta se estaria intentando devolver ocho unidades cuando el cliente solo compro 7, por eso sale el mensaje que indica que no se puede.
--vemos que quedan generado las 3 notas junto con la cantidad de productos devueltos y el id
select c.id,c.tipoComprobante,c.idFactura,c.fecha,c.monto,pnc.idProd,pnc.cantProd,p.nombre from comprobantes.Comprobante c
inner join comprobantes.productoNotaDeCredito pnc
on c.id=pnc.idNotaCred
inner join catalogo.Producto p
on p.id=pnc.idProd
where idFactura = 1



