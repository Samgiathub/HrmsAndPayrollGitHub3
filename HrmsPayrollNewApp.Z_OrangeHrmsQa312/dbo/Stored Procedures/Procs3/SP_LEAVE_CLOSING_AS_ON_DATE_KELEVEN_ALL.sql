
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_LEAVE_CLOSING_AS_ON_DATE_KELEVEN_ALL]
	@CMP_ID		NUMERIC ,
	@EMP_ID		NUMERIC ,
	@FOR_DATE	DATETIME = null,
	@Leave_ID   numeric = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @Max_Date As DateTime
 
		 Select @Max_date=Max(For_Date) From Dbo.T0140_Leave_Transaction WITH (NOLOCK) Where Emp_Id=@Emp_Id and cmp_Id=@cmp_Id and YEAR(For_Date) = YEAR(GETDATE()) 
	
	Declare @Emp_leave Table
	(
		leave_name nvarchar(50),
		leave_code nvarchar(10),
		leave_opening numeric(5,2),
		leave_credit numeric(5,2),
		leave_used	numeric(5,2),
		leave_remain numeric(5,2),
		Leave_id numeric
	)
	 
	declare @leaveid numeric
		
	declare @leave_name nvarchar(50)
	declare @leave_code nvarchar(10)
	declare @leave_opening numeric(5,2)
	declare @leave_remain numeric(5,2)
	declare @leave_used	numeric(5,2)
	declare @leave_credit nvarchar(50)

	declare @Max_ForDate datetime  
				
	set @leave_name	= 0
	set @leave_code	= 0
	set @leave_opening	= 0
	set @leave_remain	= 0
	set @leave_used	= 0
	set @leave_credit = 0
	
	declare @Grade_Id numeric
		
		
		select @Grade_Id = grd_id from t0080_emp_master WITH (NOLOCK) where emp_id = @EMP_ID and cmp_id = @CMP_ID 
		
		declare Cur_Allow   cursor for
		select lt.leave_id,lt.emp_id from T0140_LEave_Transaction lt WITH (NOLOCK) inner join t0040_leave_master lm WITH (NOLOCK) on lt.Leave_Id=lm.Leave_Id
		where  lt.cmp_id=@Cmp_ID and YEAR(FOR_DATE) = YEAR(GETDATE()) and lm.Display_leave_balance =1 and lt.Emp_ID = @EMP_ID group by lt.Leave_ID,emp_id
		
		open cur_allow
		fetch next from cur_allow  into @leaveid,@Emp_ID
		while @@fetch_status = 0
			begin
			
				select @leave_used = SUM(leave_used) ,@leave_credit =SUM(Leave_Credit) from T0140_LEave_Transaction WITH (NOLOCK) where Emp_ID = @Emp_ID and Year(For_Date) = year(@FOR_DATE ) AND FOR_DATE <= @FOR_DATE  and leave_id = @leaveid 
				select top 1 @leave_opening = Leave_Opening from T0140_LEave_Transaction WITH (NOLOCK) where Emp_ID = @Emp_ID AND YEAR(FOR_DATE) = YEAR(GETDATE()) and leave_id = @leaveid order by For_Date
					
				insert into @Emp_leave
				select  @leave_name,@leave_code,@leave_opening,isnull(@leave_credit,0),isnull(@leave_used,0),@leave_remain,@leaveid
				set @leave_credit = 0
				set @leave_used = 0
				
				fetch next from cur_allow  into @leaveid,@Emp_ID
			end
		close cur_Allow
		deallocate Cur_Allow
		
			SELECT   dbo.f_lower_round(isnull(EL.Leave_Opening,0.00),LT.Cmp_ID) as Leave_Opening ,dbo.f_lower_round(Lt.Leave_Closing,LT.Cmp_ID) as Leave_Closing,
				LM.LEAVE_CODE,LM.LEAVE_NAME,LT.LEAVE_ID,dbo.f_lower_round(isnull(EL.leave_credit,0.00),LT.Cmp_ID) as Leave_Credit,dbo.f_lower_round(isnull(EL.leave_used,0.00),LT.Cmp_Id)as Leave_Used,
			case when lm.Apply_Hourly = 1 then 'hour(s)' else 'day(s)'  end as Leave_Type FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN   -- Changed by Gadriwala Muslim 11062015
				(SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
				WHERE EMP_ID = @EMP_ID AND FOR_DATE <=@FOR_DATE AND LEAVE_ID in (Select Leave_ID from V0040_LEAVE_DETAILS Where Grd_ID=@Grade_Id) 
				GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND 
				LT.FOR_DATE = Q.FOR_DATE INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID 
				left outer join  @Emp_leave EL on LT.Leave_ID = EL.Leave_id
				WHERE (isnull(LM.Default_Short_Name,'') <> 'COMP' and isnull(LM.Default_Short_Name,'') <> 'COPH' and isnull(LM.Default_Short_Name,'') <> 'COND')
	RETURN



