/*
Fecha de Entrega: 15/11/2024
Comision: 5600
Grupo 13
Bases de Datos Aplicadas

Alumnos:
	- Diaz, Nicolas 41714473
	- Huang, Luis 43098142
	- Rolleri Vilalba, Santino 46026386

**ENUNCIADO**
Genere store procedures para manejar la inserción, modificado, borrado (si corresponde, 
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla. 
Los nombres de los store procedures NO deben comenzar con “SP”.  
*/

use Com5600G13
go
--SUCURSAL
create or alter proc sucursales.bajaSucursalId 
	@id int
as
begin
	update sucursales.Sucursal 
	set activo = 0
	where id = @id
end
go

--EMPLEADO
--CARGO
--LINEAPRODUCTO
--PRODUCTO
--CATEGORIA
--TIPOCLIENTE
--FACTURA
--MEDIODEPAGO
--COMPROBANTE