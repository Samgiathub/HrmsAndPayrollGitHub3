

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[GET_TRAVEL_SETTLEMENT_EXPENSE_RESTRICTION]
	 @Cmp_ID		Numeric
	,@Expense_type_ID numeric(18,0)
	,@Travel_Approval_ID numeric(18,0)	
	,@From_Date		Datetime
	,@To_Date		Datetime
	,@DDL_ForDate   datetime	
	,@Emp_ID		Numeric(18,0)	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @Emp_ID_In as varchar(max)
declare @Emp_Name as varchar(200)
declare @Main_Emp_ID as numeric(18,0)

Create Table #Cons_Data
(
	Emp_ID numeric(18,0),
	Main_Emp_ID numeric(18,0),
	Emp_Name varchar(200)
)
declare Cur_Insert_Emp cursor for
	select Grp_Emp_ID,Ex.Emp_ID,(Emp_First_Name + ' ' +Emp_Last_Name) as Emp_Name from T0140_Travel_Settlement_Expense 
		EX WITH (NOLOCK) inner join T0080_EMP_MASTER Em WITH (NOLOCK) on EX.Emp_ID=EM.Emp_ID and Ex.Cmp_ID =Em.Cmp_ID
			where Ex.Cmp_ID=@Cmp_ID
			and Grp_Emp_ID is not null and Grp_Emp_ID<>'' and Expense_Type_ID=@Expense_type_ID and for_date=@DDL_ForDate
		Open Cur_Insert_Emp
			Fetch next from Cur_Insert_Emp into @Emp_ID_In,@Main_Emp_ID,@Emp_Name
				while @@FETCH_STATUS=0
					Begin	
					declare @EmpID as numeric(18,0)
					SELECT  @EmpID=CAST(data  AS NUMERIC) FROM dbo.Split (@Emp_ID_In,'#')	
							--select 	@EmpID
						INSERT INTO #Cons_Data(Emp_ID,Main_Emp_ID,Emp_Name)
						Values(@EmpID,@Main_Emp_ID,@Emp_Name)
			Fetch next from Cur_Insert_Emp into @Emp_ID_In,@Main_Emp_ID,@Emp_Name
					End
		close Cur_Insert_Emp
		deallocate Cur_Insert_Emp	
					

    select distinct * from #Cons_Data CD where Emp_ID in (@Emp_ID)
    
            
    	RETURN 


