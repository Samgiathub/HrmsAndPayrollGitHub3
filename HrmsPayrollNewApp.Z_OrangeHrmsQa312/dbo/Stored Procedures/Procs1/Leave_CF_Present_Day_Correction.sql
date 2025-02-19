

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Leave_CF_Present_Day_Correction]
	@Cmp_ID as Numeric
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @Cur_Leave_ID Numeric
	DECLARE @Cur_Cmp_ID Numeric
	DECLARE @Cur_Effective_Date datetime
	DECLARE @Cur_Leave_PDays Numeric(18,2)
	DECLARE @Cur_Leave_Get_Against_PDays Numeric(18,2)
	DECLARE @Tran_ID Numeric
	
	IF OBJECT_ID('tempdb..#Leave_detais') IS NOT NULL
		Begin
			DROP TABLE #Leave_detais
		End  
	
	IF OBJECT_ID('tempdb..#Leave_Effective_date') IS NOT NULL
		Begin
			DROP TABLE #Leave_Effective_date
		End  
	
	CREATE Table #Leave_detais
	(
		Leave_ID Numeric(18,0),
		Leave_PDays Numeric(18,2),
		Leave_Get_Against_PDays Numeric(18,2),
		Cmp_ID Numeric
	)
	
	CREATE Table #Leave_Effective_date
	(
		Leave_ID Numeric(18,0),
		TYPEID Numeric,
		Effective_Date Datetime
	)


	
	INSERT into #Leave_detais SELECT Leave_ID,Leave_PDays,Leave_Get_Against_PDays,@Cmp_ID FROM T0040_LEAVE_MASTER WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Leave_PDays <> 0 
	

	DECLARE Leave_Cur Cursor 
	For Select Leave_ID,Cmp_ID,Leave_PDays,Leave_Get_Against_PDays From #Leave_detais
	OPEN Leave_Cur
				Fetch Next From Leave_Cur into @Cur_Leave_ID,@Cur_Cmp_ID,@Cur_Leave_PDays,@Cur_Leave_Get_Against_PDays
					WHILE @@Fetch_Status = 0 
						Begin
							insert into #Leave_Effective_date
							
							Select c.Leave_ID,c.Type_ID,c.Effective_Date from T0050_CF_EMP_TYPE_DETAIL c WITH (NOLOCK)
							inner join (Select MAX(Effective_Date) Effective_Date,Leave_ID from T0050_CF_EMP_TYPE_DETAIL WITH (NOLOCK) where Cmp_Id=@Cur_Cmp_ID and Leave_ID=@Cur_Leave_ID group by Leave_ID) qry 
							on c.Leave_ID=qry.Leave_ID and c.Effective_Date=qry.Effective_Date
							where c.Cmp_ID=@Cur_Cmp_ID and isnull(c.Leave_ID,@Cur_Leave_ID)=@Cur_Leave_ID AND qry.Effective_Date IS NOT null  AND c.CF_Type_ID = 1
										
							Fetch Next From Leave_Cur into @Cur_Leave_ID,@Cur_Cmp_ID,@Cur_Leave_PDays,@Cur_Leave_Get_Against_PDays
						End 
	CLOSE Leave_Cur
	DEALLOCATE  Leave_Cur
	
	
	Select @Tran_ID = isnull(MAX(Tran_ID),0) From T0050_LEAVE_CF_Present_Day WITH (NOLOCK)
	
	Insert INTO T0050_LEAVE_CF_Present_Day SELECT (ROW_NUMBER() OVER (ORDER BY #Leave_detais.Leave_ID)) + @Tran_ID AS Row,Cmp_ID,Effective_Date,TYPEID,#Leave_detais.Leave_ID,Leave_PDays,Leave_Get_Against_PDays FROM #Leave_Effective_date Left outer JOIN  #Leave_detais on #Leave_Effective_date.Leave_ID = #Leave_detais.Leave_ID 
	SELECT * FROM T0050_LEAVE_CF_Present_Day WITH (NOLOCK)
	
	
   
END

