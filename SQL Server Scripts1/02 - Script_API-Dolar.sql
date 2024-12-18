--Nico: le agregue un esquema al sp
use Com5600G13
go

EXEC sp_configure 'show advanced options', 1;	--Este es para poder editar los permisos avanzados.
RECONFIGURE;
EXEC sp_configure 'Ole Automation Procedures', 1;	-- Aqui habilitamos esta opcion avanzada
RECONFIGURE;
go

create or alter proc ventas.obtenerPrecioDolar @precio decimal(6,2) output
as 
begin
	DECLARE @url NVARCHAR(336) = 'https://dolarapi.com/v1/dolares/oficial'

	DECLARE @Object INT
	DECLARE @json TABLE(DATA NVARCHAR(MAX))
	DECLARE @respuesta NVARCHAR(MAX)

	EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT
	EXEC sp_OAMethod @Object, 'OPEN', NULL, 'GET', @url, 'FALSE'
	EXEC sp_OAMethod @Object, 'SEND'
	EXEC sp_OAMethod @Object, 'RESPONSETEXT', @respuesta OUTPUT, @json OUTPUT

	INSERT INTO @json 
		EXEC sp_OAGetProperty @Object, 'RESPONSETEXT'

	DECLARE @datos NVARCHAR(MAX) = (SELECT DATA FROM @json)

	SELECT @precio = compra FROM OPENJSON(@datos)
	WITH
	(
		[moneda] varchar(50) '$.moneda',
		[casa] varchar(50) '$.casa',
		[nombre] varchar(50) '$.nombre',
		[compra] decimal(6,2) '$.compra',
		[venta] decimal(6,2) '$.venta',
		[fecha] varchar(50) '$.fechaActualizacion'
	);
end