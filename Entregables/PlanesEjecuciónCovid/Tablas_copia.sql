	
	--Creación de tablas copia
	SELECT *INTO COPIA_ENTI FROM dbo.datoscovid		-- Se crea tabla copia con nombre COPIA_ENTI
	SELECT *INTO COPIA_CLASIF FROM dbo.datoscovid	-- Se crea tabla copia 2 con nombre COPIA_CLASIF
	
	--Creacion indices agrupados sobre las tablas copia
	CREATE CLUSTERED INDEX COPIA_ENTI ON dbo.COPIA_CLASIF(ENTIDAD_RES)	--Crea indice agrupado a partir de la columna ENTIDAD_RES
	CREATE CLUSTERED INDEX COPIA_CLASIF ON dbo.COPIA_CLASIF(CLASIFICACION_FINAL)--Crea indice agrupado a partir de la columna CLASIFICACION_FINAL
	
	--Creacion indices no agrupados sobre tabla copia 2
	CREATE NONCLUSTERED INDEX COPIA_DEFUNCION ON dbo.COPIA_CLASIF(FECHA_DEF)	-- Crea un indice no agrupado a partir de FECHA_DEF
	CREATE NONCLUSTERED INDEX COPIA_UBICACION ON dbo.COPIA_CLASIF(ENTIDAD_RES,MUNICIPIO_RES) --Crea un indice no agrupado a partir de ENTIDAD_RES y MUNICIPIO_RES
