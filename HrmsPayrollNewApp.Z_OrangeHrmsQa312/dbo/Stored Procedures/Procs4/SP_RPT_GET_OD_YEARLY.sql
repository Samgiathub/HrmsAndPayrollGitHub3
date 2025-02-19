




--created by Falak on 25-NOV-2010
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_GET_OD_YEARLY]
	 @Cmp_ID 		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID		Numeric   
	,@Cat_ID		Numeric  
	,@Grd_ID		Numeric  
	,@Type_ID		Numeric   
	,@Dept_Id		Numeric  
	,@Desig_Id		Numeric
	,@Emp_ID 		numeric
	,@Constraint	varchar(5000)   	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 
	 
	 if @Branch_ID = 0
		set @Branch_ID = null
	 if @Cat_ID = 0
		set @Cat_ID = null
		 
	 if @Type_ID = 0
		set @Type_ID = null
	 if @Dept_ID = 0
		set @Dept_ID = null
	 if @Grd_ID = 0
		set @Grd_ID = null
	 if @Emp_ID = 0
		set @Emp_ID = null
		
	 If @Desig_ID = 0
		set @Desig_ID = null
	
	 Declare @Emp_Cons Table
		(
			Emp_ID	numeric
		)
	
	 if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#')			
		end	
	 else 
		begin
			Insert Into @Emp_Cons

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date and  @From_Date <= left_date )
												
		End
		
				
		declare @Yearly_Leave Table 
			(
				Row_ID			numeric IDENTITY (1,1) not null,
				Cmp_ID			numeric ,
				Emp_Id			numeric ,
				Leave_Id		numeric,
				Month_1			numeric(12,1) default 0,
				Month_2			numeric(12,1) default 0,
				Month_3			numeric(12,1) default 0,
				Month_4			numeric(12,1) default 0,
				Month_5			numeric(12,1) default 0,
				Month_6			numeric(12,1) default 0,
				Month_7			numeric(12,1) default 0,
				Month_8			numeric(12,1) default 0,
				Month_9			numeric(12,1) default 0,
				Month_10		numeric(12,1) default 0,
				Month_11		numeric(12,1) default 0,
				Month_12		numeric(12,1) default 0,
				Total			numeric(12,1) default 0
			)
	
		insert into @Yearly_Leave (Cmp_ID,Emp_ID,Leave_ID)
			select @Cmp_ID,emp_ID,Leave_ID From @Emp_Cons ec cross join 
			t0040_Leave_Master lm WITH (NOLOCK) where lm.cmp_ID = @cmp_ID
		
				
		declare @Temp_Date datetime
		Declare @count numeric 
		set @Temp_Date = @From_Date 
		set @count = 1 
		while @Temp_Date <=@To_Date 
			Begin
				if @count = 1 
					begin
						
						Update @Yearly_Leave 
						set Month_1 = leave_Used
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used from t0140_leave_transaction WITH (NOLOCK) 
							Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
							group by emp_Id,leave_ID
							 )Q on ys.emp_Id = q.emp_ID 
							and ys.leave_Id = q.leave_ID  
					end
				else if @count = 2 
					begin
						
						Update @Yearly_Leave 
						set Month_2 = leave_Used
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used from t0140_leave_transaction WITH (NOLOCK)
							Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
							group by emp_Id,leave_ID
							 )Q on ys.emp_Id = q.emp_ID 
							and ys.leave_Id = q.leave_ID  
					end
				else if @count = 3
					begin
						
						Update @Yearly_Leave 
						set Month_3 = leave_Used
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used from t0140_leave_transaction WITH (NOLOCK)
							Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
							group by emp_Id,leave_ID
							 )Q on ys.emp_Id = q.emp_ID 
							and ys.leave_Id = q.leave_ID  
					end
				else if @count = 4 
					begin
						
						Update @Yearly_Leave 
						set Month_4 = leave_Used
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used from t0140_leave_transaction WITH (NOLOCK)
							Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
							group by emp_Id,leave_ID
							 )Q on ys.emp_Id = q.emp_ID 
							and ys.leave_Id = q.leave_ID  
					end
				else if @count = 5 
					begin
						
						Update @Yearly_Leave 
						set Month_5 = leave_Used
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used from t0140_leave_transaction WITH (NOLOCK)
							Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
							group by emp_Id,leave_ID
							 )Q on ys.emp_Id = q.emp_ID 
							and ys.leave_Id = q.leave_ID  
					end
				else if @count = 6
					begin
						
						Update @Yearly_Leave 
						set Month_6 = leave_Used
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used from t0140_leave_transaction WITH (NOLOCK)
							Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
							group by emp_Id,leave_ID
							 )Q on ys.emp_Id = q.emp_ID 
							and ys.leave_Id = q.leave_ID  
					end
				else if @count = 7 
					begin
						
						Update @Yearly_Leave 
						set Month_7 = leave_Used
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used from t0140_leave_transaction WITH (NOLOCK)
							Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
							group by emp_Id,leave_ID
							 )Q on ys.emp_Id = q.emp_ID 
							and ys.leave_Id = q.leave_ID  
					end
				else if @count = 8
					begin
						
						Update @Yearly_Leave 
						set Month_8 = leave_Used
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used from t0140_leave_transaction WITH (NOLOCK)
							Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
							group by emp_Id,leave_ID
							 )Q on ys.emp_Id = q.emp_ID 
							and ys.leave_Id = q.leave_ID  
					end
				else if @count = 9 
					begin
						
						Update @Yearly_Leave 
						set Month_9 = leave_Used
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used from t0140_leave_transaction WITH (NOLOCK)
							Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
							group by emp_Id,leave_ID
							 )Q on ys.emp_Id = q.emp_ID 
							and ys.leave_Id = q.leave_ID  
					end
				else if @count = 10 
					begin
						
						Update @Yearly_Leave 
						set Month_10 = leave_Used
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used from t0140_leave_transaction WITH (NOLOCK)
							Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
							group by emp_Id,leave_ID
							 )Q on ys.emp_Id = q.emp_ID 
							and ys.leave_Id = q.leave_ID  
					end
				else if @count = 11 
					begin
						
						Update @Yearly_Leave 
						set Month_11 = leave_Used
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used from t0140_leave_transaction WITH (NOLOCK)
							Where cmp_Id =@Cmp_ID and Month(FOR_DATE) = month(@Temp_Date) and Year(FOR_DATE) = Year(@Temp_datE)
							group by emp_Id,leave_ID
							 )Q on ys.emp_Id = q.emp_ID 
							and ys.leave_Id = q.leave_ID  
					end
				else if @count = 12
					begin
						
						Update @Yearly_Leave 
						set Month_12 = leave_Used
						From @Yearly_Leave  Ys  inner join 
						( select emp_ID,leave_Id,sum(leave_used) leave_Used from t0140_leave_transaction WITH (NOLOCK)
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
					where LM.lEAVE_TYPE = 'Company Purpose' AND Ys.Leave_ID  in(					
		SELECT LT.LEAVE_ID FROM T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) INNER JOIN  
		( SELECT MAX(FOR_dATE) FOR_DATE , LEAVE_ID FROM T0140_LEAVE_TRANSACTION WITH (NOLOCK)
			WHERE FOR_DATE <=@To_DATE
		GROUP BY LEAVE_ID) Q ON /*LT.EMP_ID = Q.EMP_ID AND*/ LT.LEAVE_ID = Q.LEAVE_ID AND 
		LT.FOR_DATE = Q.FOR_DATE INNER JOIN T0040_LEAVE_MASTER LM WITH (NOLOCK) ON LT.LEAVE_ID = LM.LEAVE_ID)
		and YS.Total > 0 order by ys.Emp_ID ,Row_ID
		
		
		
	RETURN




