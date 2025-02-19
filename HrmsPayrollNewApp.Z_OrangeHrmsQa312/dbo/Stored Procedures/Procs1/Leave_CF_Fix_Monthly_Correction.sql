

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Leave_CF_Fix_Monthly_Correction]
	@Cmp_ID as Numeric
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @Tran_ID Numeric
	DECLARE @Cur_Leave_ID Numeric
	DECLARE @Cur_Cmp_ID Numeric

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
		Cmp_ID Numeric
	)
	CREATE Table #Leave_Effective_date
	(
		Leave_ID Numeric(18,0),
		TYPEID Numeric,
		Effective_Date Datetime
	)

	INSERT into #Leave_detais SELECT Leave_ID,Cmp_Id FROM T0050_LEAVE_CF_MONTHLY_SETTING WITH (NOLOCK) Where Cmp_Id = @Cmp_ID GROUP BY Leave_ID,Cmp_Id
	
	
	DECLARE Leave_Cur Cursor 
	For Select Leave_ID,Cmp_ID From #Leave_detais
	OPEN Leave_Cur
				Fetch Next From Leave_Cur into @Cur_Leave_ID,@Cur_Cmp_ID
					WHILE @@Fetch_Status = 0 
						Begin
							insert into #Leave_Effective_date
							
							Select c.Leave_ID,c.Type_ID,c.Effective_Date from T0050_CF_EMP_TYPE_DETAIL c WITH (NOLOCK)
							inner join (Select MAX(Effective_Date) Effective_Date,Leave_ID from T0050_CF_EMP_TYPE_DETAIL WITH (NOLOCK) where Cmp_Id=@Cur_Cmp_ID and Leave_ID=@Cur_Leave_ID group by Leave_ID) qry 
							on c.Leave_ID=qry.Leave_ID and c.Effective_Date=qry.Effective_Date
							where c.Cmp_ID=@Cur_Cmp_ID and isnull(c.Leave_ID,@Cur_Leave_ID)=@Cur_Leave_ID AND qry.Effective_Date IS NOT null  AND c.CF_Type_ID = 2 
										
							Fetch Next From Leave_Cur into @Cur_Leave_ID,@Cur_Cmp_ID
						End 
	CLOSE Leave_Cur
	DEALLOCATE  Leave_Cur
	
	Update CF Set Type_ID = qry.TYPEID
	From T0050_LEAVE_CF_MONTHLY_SETTING CF INNER Join (Select MIN(TYPEID) as TYPEID ,Effective_Date,Leave_ID From #Leave_Effective_date GROUP BY Effective_Date,Leave_ID) qry ON
	qry.Effective_Date = CF.Effective_Date AND qry.Leave_ID = CF.Leave_ID
	
	Select @Tran_ID = isnull(MAX(Leave_Tran_ID),0) From T0050_LEAVE_CF_MONTHLY_SETTING WITH (NOLOCK)
	
	Insert INTO T0050_LEAVE_CF_MONTHLY_SETTING
	SELECT (ROW_NUMBER() OVER (ORDER BY #Leave_Effective_date.TYPEID)) + @Tran_ID AS Row ,T0050_LEAVE_CF_MONTHLY_SETTING.Leave_ID,T0050_LEAVE_CF_MONTHLY_SETTING.For_Date,T0050_LEAVE_CF_MONTHLY_SETTING.Cmp_Id,T0050_LEAVE_CF_MONTHLY_SETTING.CF_M_Days,#Leave_Effective_date.Effective_Date,#Leave_Effective_date.TYPEID  FROM #Leave_Effective_date Left outer JOIN T0050_LEAVE_CF_MONTHLY_SETTING WITH (NOLOCK) on #Leave_Effective_date.Leave_ID = T0050_LEAVE_CF_MONTHLY_SETTING.Leave_ID AND #Leave_Effective_date.TYPEID <> T0050_LEAVE_CF_MONTHLY_SETTING.Type_ID  where Cmp_Id IS not null ORDER by #Leave_Effective_date.TYPEID,T0050_LEAVE_CF_MONTHLY_SETTING.For_Date
	
	SELECT * FROM T0050_LEAVE_CF_MONTHLY_SETTING WITH (NOLOCK) order BY Leave_Tran_ID
END

