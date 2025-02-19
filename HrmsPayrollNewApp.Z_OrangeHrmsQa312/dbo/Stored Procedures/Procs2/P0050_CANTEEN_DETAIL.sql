

-- =============================================
-- Author:		Nimesh Parmar
-- Create date: 2015-05-12
-- Description:	For insert or update canteen detail
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0050_CANTEEN_DETAIL] 
	@Cmp_ID Numeric(18,0),
	@Cnt_ID Numeric(18,0) Output,
	@XmlDetail xml
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	SELECT	ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS Row_ID,
			CanteenDetail.detail.value('(Tran_Id/text())[1]', 'Numeric(18,0)') As Tran_Id,
			CanteenDetail.detail.value('(Effective_Date/text())[1]', 'datetimeoffset') As Effective_Date,
			CanteenDetail.detail.value('(Amount/text())[1]', 'Numeric(18,2)') As Amount
	INTO	#Tmp
	FROM	@XmlDetail.nodes('/dsDetail/tblDetail') As CanteenDetail(detail)
	
		
	--Update all records which is exist in database
	IF EXISTS(SELECT 1 FROM T0050_CANTEEN_DETAIL D WITH (NOLOCK) INNER JOIN #Tmp T ON D.Effective_Date=T.Effective_Date AND
					D.Tran_Id<>T.Tran_Id WHERE D.Cmp_Id=@Cmp_ID AND D.Cnt_Id=@Cnt_ID) BEGIN
		--Two different rates should not be allowed for the same effective date.
		
		SET @Cnt_ID=0;
		RETURN;
	END
	
	UPDATE	T0050_CANTEEN_DETAIL SET Effective_Date=T.Effective_Date, Amount=T.Amount
	FROM	#Tmp T
	WHERE	T0050_CANTEEN_DETAIL.Tran_ID=T.Tran_Id And T0050_CANTEEN_DETAIL.Cmp_Id=@Cmp_ID AND T0050_CANTEEN_DETAIL.Cnt_Id=@Cnt_ID
	--End Update
	
	--Deleting all entries which are not exist in temp table.
	DELETE	FROM T0050_CANTEEN_DETAIL 
	WHERE	T0050_CANTEEN_DETAIL.Cmp_Id=@Cmp_ID AND T0050_CANTEEN_DETAIL.Cnt_Id=@Cnt_ID AND
			T0050_CANTEEN_DETAIL.Tran_ID NOT IN (Select Tran_Id FROM #Tmp)
	--End Delete
	
	--Inserting Records which is not exist in database
	DECLARE @Row_ID BigInt,
			@Tran_ID Numeric(18,0),
			@Effective_Date DateTime,
			@Amount Numeric(18,2), 
			@Temp_Row_ID BigInt;
	
	SELECT Top 1 @Row_ID=Row_ID,@Effective_Date=Effective_Date,@Amount=Amount FROM #Tmp Where Tran_ID=0 Order By Row_ID
	WHILE (@Row_ID IS NOT NULL) BEGIN
		SELECT @Tran_ID=ISNULL((SELECT MAX(Tran_ID) FROM T0050_CANTEEN_DETAIL D WITH (NOLOCK) WHERE D.Cmp_ID=@Cmp_ID AND D.Cnt_Id=@Cnt_ID),0)+1
		
		--If the records are exist for same effective date then it should be skipped.
		IF NOT EXISTS(SELECT 1 FROM T0050_CANTEEN_DETAIL D WITH (NOLOCK) WHERE D.Cmp_Id=@Cmp_ID AND D.Cnt_Id=@Cnt_ID AND D.Effective_Date=@Effective_Date) BEGIN
			INSERT	INTO T0050_CANTEEN_DETAIL(Cmp_Id,Cnt_Id,Tran_Id,Effective_Date,Amount)
			VALUES	(@Cmp_ID,@Cnt_ID,@Tran_ID,@Effective_Date,@Amount)
		END
		
		SET @Temp_Row_ID = @Row_ID
		SET @Row_ID = NULL;
		SELECT Top 1 @Row_ID=Row_ID,@Effective_Date=Effective_Date,@Amount=Amount FROM #Tmp WHERE Tran_ID=0 AND Row_ID > @Row_ID Order By Row_ID
	END
	--End Insert
	
	
	SET NOCOUNT OFF;
END

