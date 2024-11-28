use Com5600G13
go

--generar datos de prueba (nota, los archivos deben haberse cargado previamente para que este testeo funcione) (ejecutar bloque completo)
declare @tablaProv tablaProductosIdCant
insert into @tablaProv
values (1,2),(2,4),(3,1)
exec ventas.insertarFactura '999-93-9993','A',257020,1, @tablaProv
exec comprobantes.insertarComprobante '9999-2222-1111',1,'999-93-9993'

--vemos que se generaron los datos de prueba (ejecutar bloque completo)
declare @idFac int
select * from ventas.Factura where idFactura='999-93-9993'
select * from comprobantes.comprobante where idPago='9999-2222-1111'
set @idFac= (select top 1 id from ventas.Factura order by id desc)
select * from ventas.LineaDeFactura where idFactura=@idFac

--Se compraron 2 unidades del producto con id 1, 4un del prod 2 y 1un del prod 3

--intentamos generar Nota con productos que no estan en la factura (ejecutar bloque completo)
declare @tabla tablaProductosIdCant
insert into @tabla
values (1406,1)
exec comprobantes.generarNotaDeCredito '999-93-9993',@tabla

--ahora intentamos generar una nota con cantidades invalidas (ejecutar bloque completo)
declare @tabla tablaProductosIdCant
insert into @tabla
values (1,0)
exec comprobantes.generarNotaDeCredito '999-93-9993',@tabla

--ahora intentamos con cantidades que excedan aquellas de la factura (ejecutar bloque completo)
declare @tabla tablaProductosIdCant
insert into @tabla
values (1,92),(2,1),(3,1)
exec comprobantes.generarNotaDeCredito '999-93-9993',@tabla

--ahora intentamos un caso valido (ejecutar bloque completo)
declare @tabla tablaProductosIdCant
insert into @tabla
values (1,1),(2,1),(3,1)
exec comprobantes.generarNotaDeCredito '999-93-9993',@tabla

--vemos que se generaron los datos correspondientes (ejecutar bloque completo)
declare @idNotaCred int
set @idNotaCred = (select top 1 id from comprobantes.Comprobante where tipoComprobante='Nota de credito' order by id desc)
select * from comprobantes.Comprobante where tipoComprobante='Nota de credito'
select * from comprobantes.LineaDeNotaDeCredito where idNotaCred=@idNotaCred

--intentamos ejecutar nuevamente, deberia fallar ya que se estaria intentando devolver una unidad mas del producto 3 cuando en la factura solo se habia comprado uno. 
--(ejecutar bloque completo)
declare @tabla tablaProductosIdCant
insert into @tabla
values (1,1),(2,1),(3,1)
exec comprobantes.generarNotaDeCredito '999-93-9993',@tabla

--ahora intentamos generar otra nota de credito para la misma factura pero un caso valido donde solo devolvemos una unidad mas del producto 1 y el 2. (ejecutar bloque completo)
declare @tabla tablaProductosIdCant
insert into @tabla
values (1,1),(2,1)
exec comprobantes.generarNotaDeCredito '999-93-9993',@tabla

--vemos que se generaron los datos correspondientes: tanto la nota de credito nueva, como las lineas nuevas, se muestran tanto las nuevas como las viejas para ver
--el total de productos devueltos. Ejecutar bloque completo
declare @idNotaCred int
declare @idNotaCredViej int
set @idNotaCred = (select top 1 id from comprobantes.Comprobante where tipoComprobante='Nota de credito' order by id desc)
set @idNotaCredViej = (
    select id
    from (
        select id, ROW_NUMBER() over (order by id desc) as row_num
        from comprobantes.Comprobante
        where tipoComprobante = 'Nota de credito'
    ) AS numbered
    where row_num = 2
);
select * from comprobantes.Comprobante where tipoComprobante='Nota de credito'
select * from comprobantes.LineaDeNotaDeCredito where idNotaCred=@idNotaCred or idNotaCred=@idNotaCredViej
go

--En conclusion, el SP crea notas de credito, tiene en cuenta que no se excedan las cantidades de la factura original y realiza las verificaciones necesarias.

/* Ignorar, este bloque sirve para resetear el caso de prueba y volver a ejecutarlo de ser necesario, borra todos los datos que el testeo crea.
declare @idFac int
set @idFac= (select id from ventas.factura where idFactura='999-93-9993')
delete from comprobantes.lineadeNotaDeCredito
delete from ventas.LineaDeFactura where idFactura=@idFac
delete from comprobantes.Comprobante where idFactura=@idFac
delete from ventas.Factura
where idFactura='999-93-9993'*/

