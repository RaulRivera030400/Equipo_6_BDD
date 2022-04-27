USE AdventureWorks2019
GO

--Stored Procedure para insert en Sales.OrderDetail
ALTER PROCEDURE sp_insert_OrderDetail(
@ProductID varchar(20),
@OrderQty varchar(20),
@Salida varchar(20) OUTPUT,--Regresa el @SalesOrderID si no hay errores, si los hay regresa el tipo de error
@Salida_2 varchar(20) OUTPUT,--Regresar el precio del producto
@SalesOrderID  int /* -1 Nueva Orden, 0 Misma Orden */
)
AS
	CREATE TABLE #temp( --Tabla temporal para acceder a los datos de la consulta
		Existe int
	)

	DECLARE @UnitPriceDiscount float
	DECLARE @SpecialOfferID int

	IF (@SalesOrderID = -1) -- Se genera un nuevo SalesOrderID
	BEGIN 
		SET @SalesOrderID =  (SELECT IDENT_CURRENT ('[Sales].[SalesOrderHeader]') AS Current_Identity)
		SET @SalesOrderID = @SalesOrderID+1
	END
	ELSE --Misma Orden
	BEGIN
		SET @SalesOrderID =  (SELECT IDENT_CURRENT ('[Sales].[SalesOrderHeader]') AS Current_Identity)
		SET @SalesOrderID = @SalesOrderID+1
	END 
	
	--CONSULTA MySQL para verificar si existe el articulo y la cantidad es suficiente
	DECLARE @Sql VARCHAR(8000)
	SET @Sql = 'SELECT EXISTS(SELECT * FROM AdventureWorks2019.PRODUCTInventory WHERE ProductID = '+ @ProductID +' AND Quantity >= '+@OrderQty +' LIMIT 1 ) as "EXISTE?"'
	SET @Sql = 'SELECT * FROM OPENQUERY(MYSQL, ''' + REPLACE(@Sql, '''', '''''') + ''')'

	INSERT INTO #temp EXEC(@Sql) 

	DECLARE @flag INT;
	SELECT @flag = Existe FROM #temp -- Obtener si existe o no el producto con cantidad suficiente
		-- Si existe, se puede hacer la insercion, antes verifica si existe descuentos segun la cantidad de productos

	IF @flag = 1 --Existe
	-- SI EXISTE EL PRODUCTO Y HAY CANTIDAD SUFICIENTE
    BEGIN
        --Verificar si el producto tiene promocion
		IF 0 <= @OrderQty AND @OrderQty <=10 --No hay descuento
		BEGIN
			SET @UnitPriceDiscount=0.00;
			SET @SpecialOfferID=1;
		END
		ELSE IF 11 <= @OrderQty AND @OrderQty <=14 --Descuento de 11 a 14 piezas -> 0.02
		BEGIN
			SET @UnitPriceDiscount=0.02;
			SET @SpecialOfferID=2;
		END
		ELSE IF 15 <= @OrderQty AND @OrderQty <=24 --Descuento de 15 a 24 piezas -> 0.05
		BEGIN
			SET @UnitPriceDiscount=0.05;
			SET @SpecialOfferID=3;
		END
		ELSE IF 25 <= @OrderQty AND @OrderQty <=40 --Descuento de 25 a 40 piezas -> 0.10
		BEGIN
			SET @UnitPriceDiscount=0.10;
			SET @SpecialOfferID=4;
		END
		ELSE IF 41 <= @OrderQty AND @OrderQty <=60 --Descuento de 41 a 60 piezas -> 0.15
		BEGIN
			SET @UnitPriceDiscount=0.15;
			SET @SpecialOfferID=5;
		END
		ELSE IF 61 <= @OrderQty --Descuento mas de 60 piezas -> 0.20
		BEGIN
			SET @UnitPriceDiscount=0.20;
			SET @SpecialOfferID=6;
		END
		ELSE --No hay descuento
		BEGIN
			SET @UnitPriceDiscount=0.00;
			SET @SpecialOfferID=1;
		END

		/*INSERT SalesOrderDetail*/
		DECLARE @rowguid VARCHAR(8000)
		SET @rowguid = NEWID()
		DECLARE @rowguid_2 VARCHAR(8000)
		SET @rowguid_2 = NEWID()

		IF NOT EXISTS (SELECT * FROM SALES.SpecialOfferProduct WHERE SpecialOfferID = @SpecialOfferID AND ProductID = @ProductID) 
		BEGIN --NO existe oferta,se hace la insercion a Special Product
			
			INSERT INTO sales.SpecialOfferProduct(SpecialOfferID,ProductID,rowguid,ModifiedDate) VALUES (@SpecialOfferID,@ProductID,@rowguid,SYSDATETIME())
		END
		ELSE 
		BEGIN --Se tiene que hacer un update a Special Product dependiendo la cantidad ingresada 
			UPDATE sales.SpecialOfferProduct
			SET SpecialOfferID = @SpecialOfferID, ProductID = @ProductID, rowguid = @rowguid, ModifiedDate= SYSDATETIME()
			WHERE ProductID = @ProductID;
		END

        /*Obtener el precio del producto*/
		CREATE TABLE #temp_StandarCost(
			Existe float
		)

		DECLARE @Sql_StandarCost VARCHAR(8000)
		--CONSULTA MySQL para obtener el StandarCost del producto
		SET @Sql_StandarCost = 'SELECT ListPrice FROM Adventureworks2019.product WHERE ProductID = '+ @ProductID +' LIMIT 1'
		SET @Sql_StandarCost = 'SELECT * FROM OPENQUERY(MYSQL, ''' + REPLACE(@Sql_StandarCost, '''', '''''') + ''')'

		INSERT INTO #temp_StandarCost EXEC(@Sql_StandarCost) 
		SELECT * FROM #temp_StandarCost
		SELECT @Salida_2 = Existe FROM #temp_StandarCost  --Obtener StandarCost obtenido en la consulta
		
        
        /*      INSERT SalesOrderDetail     */
		INSERT INTO SALES.SalesOrderDetail(SalesOrderID,CarrierTrackingNumber,OrderQty,ProductID,SpecialOfferID,UnitPrice,UnitPriceDiscount,rowguid,ModifiedDate)VALUES
		(@SalesOrderID,'4911-403C-98',@OrderQty,@ProductID,@SpecialOfferID,@Salida_2,@UnitPriceDiscount,@rowguid_2,SYSDATETIME())
		
		Set @Salida = @SalesOrderID --Variable de salida para tener el ID del insert 	  
	END;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ELSE --NO EXISTE EL PRODUCTO O NO HAY CANTIDAD SUFICIENTE
    BEGIN	
		CREATE TABLE #temp2(
			Existe int
		)
		DECLARE @Sql_verificarProducto VARCHAR(8000)

--CONSULTA MySQL para verificar si existe el articulo 
		SET @Sql_verificarProducto = 'SELECT EXISTS(SELECT * FROM AdventureWorks2019.PRODUCTInventory WHERE ProductID = '+ @ProductID +') as "EXISTE?"'
		SET @Sql_verificarProducto = 'SELECT * FROM OPENQUERY(MYSQL, ''' + REPLACE(@Sql_verificarProducto, '''', '''''') + ''')'

		INSERT INTO #temp2 EXEC(@Sql_verificarProducto) 

		DECLARE @flag2 INT;
		SELECT @flag2 = Existe FROM #temp2 --Obtener los datos de la consulta


		IF (@flag2 = 1) --EL ARTICULO EXISTE
		BEGIN	
			SET @Salida = -1;

			CREATE TABLE #temp3(
				Existe int
			)
			DECLARE @Sql_verificarCantidad VARCHAR(8000)
            --CONSULTA MySQL para verificar si la cantidad es suficiente 
			SET @Sql_verificarCantidad = 'SELECT EXISTS(SELECT * FROM AdventureWorks2019.PRODUCTInventory WHERE ProductID = '+ @ProductID +' AND Quantity >= '+@OrderQty +' LIMIT 1 ) as "EXISTE?"'
			SET @Sql_verificarCantidad = 'SELECT * FROM OPENQUERY(MYSQL, ''' + REPLACE(@Sql_verificarCantidad, '''', '''''') + ''')'

			INSERT INTO #temp3 EXEC(@Sql_verificarCantidad) 

			DECLARE @flag3 INT; 
			SELECT @flag3 = Existe FROM #temp3 --Obtener los datos de la consulta
			IF (@flag3 = 1)
			BEGIN
				SET @Salida = -2;
			END
			ELSE --CANTIDAD INSUFICIENTE
			BEGIN
				SET @Salida = -3;
			END
		END 
		ELSE IF(@flag2 = 0) --EL PRODUCTO NO EXISTE
		BEGIN
			SET @Salida = -4;
		END 
		ELSE --HAY UN ERROR
		BEGIN
			SET @Salida = -5;
		END 		
		SET @Salida_2 = -1;
	END;
GO

--Stored Procedure para insert en Sales.OrderHeader
ALTER PROCEDURE sp_insert_OrderHeader(
@SalesOrderID int,
@Salida_2 varchar(20) OUTPUT
)
AS
BEGIN
	DECLARE @SubTotal_cal float
	SET @SubTotal_cal = ((SELECT SUM(SALES.SalesOrderDetail.LineTotal) FROM Sales.SalesOrderDetail where Sales.SalesOrderDetail.SalesOrderID = @SalesOrderID))

	INSERT INTO SALES.SalesOrderHeader (RevisionNumber,OrderDate,DueDate,ShipDate,Status,OnlineOrderFlag,
		CustomerID,BillToAddressID,ShipToAddressID,ShipMethodID,SubTotal,TaxAmt,Freight,rowguid,ModifiedDate)VALUES
	(8,SYSDATETIME(),SYSDATETIME(),SYSDATETIME(),5,1,27918,21592,21592,5,
	@SubTotal_cal,	@SubTotal_cal*.08, @SubTotal_cal*.08*0.3125,NEWID(),SYSDATETIME())
	
	--Verificar si se hizo el insert
	IF EXISTS (SELECT SalesOrderID FROM SALES.SalesOrderHeader WHERE SalesOrderID = @SalesOrderID) 
	BEGIN 
		SET @Salida_2 = 1 --Insert realizado correctamente 
	END
	ELSE --No existe -> No se realizo la insercion
	BEGIN
		SET @Salida_2 = -1
		--DELETE FROM Sales.SalesOrderDetail where SalesOrderID = @SalesOrderID
	END
END
GO



/*PRUEBAS STORED PROCEDURES*/
/*

DECLARE @res varchar(20)
DECLARE @res_2 varchar(20)
EXECUTE sp_insert_OrderDetail 921,1,@res output,@res_2 output,-1
GO

DECLARE @res varchar(20)
EXECUTE sp_insert_OrderHeader 75136,@res output
go

*/