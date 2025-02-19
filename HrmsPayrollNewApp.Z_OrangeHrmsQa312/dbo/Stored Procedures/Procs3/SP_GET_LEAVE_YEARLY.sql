
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_LEAVE_YEARLY]
	 @Cmp_ID 		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Emp_ID 		numeric
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON	

IF @Emp_ID = 0  
		set @Emp_ID = null

	Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	
			Insert Into @Emp_Cons values(@Emp_ID)
			
		 
		declare @Yearly_Leave Table 
			(
				Row_ID			numeric IDENTITY (1,1) not null,
				Cmp_ID			numeric ,
				Emp_Id			numeric ,
				Leave_Id		numeric,
				Month_1			numeric(12,2) default 0,
				Month_2			numeric(12,2) default 0,
				Month_3			numeric(12,2) default 0,
				Month_4			numeric(12,2) default 0,
				Month_5			numeric(12,2) default 0,
				Month_6			numeric(12,2) default 0,
				Month_7			numeric(12,2) default 0,
				Month_8			numeric(12,2) default 0,
				Month_9			numeric(12,2) default 0,
				Month_10		numeric(12,2) default 0,
				Month_11		numeric(12,2) default 0,
				Month_12		numeric(12,2) default 0,
				Total			numeric(12,2) default 0
			)
		
		
		------Added By Jimit 29122017------
		DECLARE @Gender as VARCHAR(10)
		DECLARE @Leave_Id_MLPL as NUMERIC(18,0) = 0
	       
		   SELECT	@Gender = Gender 
		   from		t0080_emp_Master WITH (NOLOCK)
		   where	emp_Id = @Emp_Id and Emp_Left <> 'Y'
	       
	       
		   SELECT	@Leave_Id_MLPL = Leave_ID 
		   from		t0040_Leave_Master WITH (NOLOCK)
		   where	Leave_type = (case when @Gender = 'M' THEN  'Maternity Leave' 
									  when @Gender = 'F' THEN  'Paternity Leave' 
								 end) and cmp_Id = @Cmp_Id
	------ended------
		
		insert into @Yearly_Leave (Cmp_ID,Emp_ID,Leave_ID)
			select @Cmp_ID,emp_ID,Leave_ID From @Emp_Cons ec cross join 
			t0040_Leave_Master lm WITH (NOLOCK)
			where lm.cmp_ID = @cmp_ID and isnull(lm.Default_Short_Name,'') <> 'COMP'  -- Changed By Gadriwala Muslim 01102014
				  and lm.Leave_ID <> @Leave_Id_MLPL --Added By Jimit 29122017
		
		
		declare @Temp_Date datetime
		Declare @count numeric 
		set @Temp_Date = @From_Date 
		set @count = 1 
		while @Temp_Date <=@To_Date 
			Begin
				if @count = 1 
					begin
						
						Update @Yearly_Leave 
						set Month_1 = leave_Used + Q.Back_Dated_Leave
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used 
									,ISNULL(SUM(Back_Dated_Leave),0) as Back_Dated_Leave  --added by jimit 01122016
							from t0140_leave_transaction WITH (NOLOCK) 
							Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
							group by emp_Id,leave_ID
							 )Q on ys.emp_Id = q.emp_ID 
							and ys.leave_Id = q.leave_ID  
					end
				else if @count = 2 
					begin
						
						Update @Yearly_Leave 
						set Month_2 = leave_Used + Q.Back_Dated_Leave
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used 
									,ISNULL(SUM(Back_Dated_Leave),0) as Back_Dated_Leave  --added by jimit 01122016
							from t0140_leave_transaction WITH (NOLOCK) 
							Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
							group by emp_Id,leave_ID
							 )Q on ys.emp_Id = q.emp_ID 
							and ys.leave_Id = q.leave_ID  
					end
				else if @count = 3
					begin
						
						Update @Yearly_Leave 
						set Month_3 = leave_Used + Q.Back_Dated_Leave
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used 
									,ISNULL(SUM(Back_Dated_Leave),0) as Back_Dated_Leave  --added by jimit 01122016
							from t0140_leave_transaction WITH (NOLOCK)
							Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
							group by emp_Id,leave_ID
							 )Q on ys.emp_Id = q.emp_ID 
							and ys.leave_Id = q.leave_ID  
					end
				else if @count = 4 
					begin
						
						Update @Yearly_Leave 
						set Month_4 = leave_Used + Q.Back_Dated_Leave
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used 
									,ISNULL(SUM(Back_Dated_Leave),0) as Back_Dated_Leave  --added by jimit 01122016
							from t0140_leave_transaction WITH (NOLOCK)
							Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
							group by emp_Id,leave_ID
							 )Q on ys.emp_Id = q.emp_ID 
							and ys.leave_Id = q.leave_ID  
					end
				else if @count = 5 
					begin
						
						Update @Yearly_Leave 
						set Month_5 = leave_Used + Q.Back_Dated_Leave
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used 
								,ISNULL(SUM(Back_Dated_Leave),0) as Back_Dated_Leave  --added by jimit 01122016
							from t0140_leave_transaction WITH (NOLOCK)
							Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
							group by emp_Id,leave_ID
							 )Q on ys.emp_Id = q.emp_ID 
							and ys.leave_Id = q.leave_ID  
					end
				else if @count = 6
					begin
						
						Update @Yearly_Leave 
						set Month_6 = leave_Used + Q.Back_Dated_Leave
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used 
									,ISNULL(SUM(Back_Dated_Leave),0) as Back_Dated_Leave  --added by jimit 01122016
							from t0140_leave_transaction WITH (NOLOCK)
							Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
							group by emp_Id,leave_ID
							 )Q on ys.emp_Id = q.emp_ID 
							and ys.leave_Id = q.leave_ID  
					end
				else if @count = 7 
					begin
						Update @Yearly_Leave 
						set Month_7 = leave_Used + Q.Back_Dated_Leave
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used 
								,ISNULL(SUM(Back_Dated_Leave),0) as Back_Dated_Leave  --added by jimit 01122016
							from t0140_leave_transaction WITH (NOLOCK)
							Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
							group by emp_Id,leave_ID
							 )Q on ys.emp_Id = q.emp_ID 
							and ys.leave_Id = q.leave_ID  
					end
				else if @count = 8
					begin
						
						Update @Yearly_Leave 
						set Month_8 = leave_Used+ Q.Back_Dated_Leave
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used 
								,ISNULL(SUM(Back_Dated_Leave),0) as Back_Dated_Leave  --added by jimit 01122016
							from t0140_leave_transaction WITH (NOLOCK)
							Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
							group by emp_Id,leave_ID
							 )Q on ys.emp_Id = q.emp_ID 
							and ys.leave_Id = q.leave_ID  
					end
				else if @count = 9 
					begin
						
						Update @Yearly_Leave 
						set Month_9 = leave_Used + Q.Back_Dated_Leave
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used 
									,ISNULL(SUM(Back_Dated_Leave),0) as Back_Dated_Leave  --added by jimit 01122016
							from t0140_leave_transaction WITH (NOLOCK)
							Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
							group by emp_Id,leave_ID
							 )Q on ys.emp_Id = q.emp_ID 
							and ys.leave_Id = q.leave_ID  
					end
				else if @count = 10 
					begin
						
						Update @Yearly_Leave 
						set Month_10 = leave_Used + Q.Back_Dated_Leave
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used 
									,ISNULL(SUM(Back_Dated_Leave),0) as Back_Dated_Leave  --added by jimit 01122016
							from t0140_leave_transaction WITH (NOLOCK)
							Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
							group by emp_Id,leave_ID
							 )Q on ys.emp_Id = q.emp_ID 
							and ys.leave_Id = q.leave_ID  
					end
				else if @count = 11 
					begin
						
						Update @Yearly_Leave 
						set Month_11 = leave_Used + Q.Back_Dated_Leave
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used 
								,ISNULL(SUM(Back_Dated_Leave),0) as Back_Dated_Leave  --added by jimit 01122016
							from t0140_leave_transaction WITH (NOLOCK)
							Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
							group by emp_Id,leave_ID
							 )Q on ys.emp_Id = q.emp_ID 
							and ys.leave_Id = q.leave_ID  
					end
				else if @count = 12
					begin
						
						Update @Yearly_Leave 
						set Month_12 = leave_Used + Q.Back_Dated_Leave
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used 
									,ISNULL(SUM(Back_Dated_Leave),0) as Back_Dated_Leave  --added by jimit 01122016
							from t0140_leave_transaction WITH (NOLOCK)
							Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
							group by emp_Id,leave_ID
							 )Q on ys.emp_Id = q.emp_ID 
							and ys.leave_Id = q.leave_ID  
					end

																																			
				set @Temp_Date = dateadd(m,1,@Temp_date)
				set @count = @count + 1  
			End
	
		UPDATE @Yearly_Leave
		SET TOTAL = MONTH_1 + MONTH_2 + MONTH_3 + MONTH_4 + MONTH_5 +MONTH_6 + MONTH_7 + MONTH_8 + MONTH_9	
					+ MONTH_10 + MONTH_11 + MONTH_12 
		
		select  Ys.*,Grd_NAme,Dept_Name,Comp_name,Branch_Address,Desig_Name,Branch_NAme,Type_NAme 
			,Cmp_NAme,Cmp_Address,Emp_Code,Emp_Full_Name ,LEAVE_NAME
			,@From_Date as P_From_Date , @To_Date as P_To_Date
		from @Yearly_Leave  Ys inner join 
		( select I.Emp_Id,Grd_ID,Type_ID,Desig_ID,Dept_ID,Branch_ID from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	)IQ on
				ys.emp_Id = iq.emp_Id inner join
					T0080_EMP_MASTER EM WITH (NOLOCK) ON YS.EMP_ID = EM.EMP_ID INNER JOIN 
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON IQ.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON IQ.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON IQ.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON IQ.Dept_Id = DM.Dept_Id Inner join 
					T0030_Branch_Master BM WITH (NOLOCK) on IQ.Branch_ID = BM.Branch_ID inner join 
					T0010_COMPANY_MASTER cm WITH (NOLOCK) on ys.cmp_Id = cm.cmp_Id INNER JOIN 
					T0040_LEAVE_MASTER LM WITH (NOLOCK) ON YS.LEAVE_ID =LM.LEAVe_iD
					where LM.lEAVE_TYPE <> 'Company Purpose' AND Ys.Leave_ID  in(					
		SELECT LT.LEAVE_ID FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN  
		( SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID,EMP_ID FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
			WHERE EMP_ID = @EMP_ID AND FOR_DATE <=@To_DATE
		GROUP BY EMP_ID,LEAVE_ID) Q ON LT.EMP_ID = Q.EMP_ID AND LT.LEAVE_ID = Q.LEAVE_ID AND 
		LT.FOR_DATE = Q.FOR_DATE INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID)
		order by ys.Emp_ID ,Row_ID 
			
					
	RETURN 




