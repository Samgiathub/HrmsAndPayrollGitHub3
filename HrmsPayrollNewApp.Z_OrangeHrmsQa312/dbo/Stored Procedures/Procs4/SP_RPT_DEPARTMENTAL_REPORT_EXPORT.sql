



---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_DEPARTMENTAL_REPORT_EXPORT]  
	@Company_Id		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric	
	,@Grade_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@Constraint	varchar(max)
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
declare @Shift_Tran_ID as numeric
declare @shift_ID as numeric
declare @for_date as datetime
Declare @Shift_Name as varchar(40)
Declare @Shift_Type_Id as Numeric
Declare @Shift_Type_Name as varchar(20)
declare @temp_todate as datetime

 
 	IF @Branch_ID = 0  
		set @Branch_ID = null   
	 If @Grade_ID = 0  
		 set @Grade_ID = null  
	 If @Emp_ID = 0  
		set @Emp_ID = null  
	 If @Desig_ID = 0  
		set @Desig_ID = null  
     If @Dept_ID = 0  
		set @Dept_ID = null 
	 If @Type_ID = 0  
		set @Type_ID = null 	
 
     
   
 Declare @Emp_Cons Table
	(
		Emp_ID	numeric
	)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons(Emp_ID)
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
		
			Insert Into @Emp_Cons

				select I.Emp_Id from dbo.T0095_INCREMENT I WITH (NOLOCK) inner join 
						( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_INCREMENT WITH (NOLOCK)
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Company_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	 Inner join
						dbo.T0080_EMP_MASTER E WITH (NOLOCK) on i.emp_ID = E.Emp_ID
					Where E.CMP_ID = @Company_ID 
					and i.BRANCH_ID = isnull(@BRANCH_ID ,i.BRANCH_ID)
					and isnull(i.Type_ID,0) = isnull(@Type_ID ,isnull(i.Type_ID,0))-- Added by Mitesh on 06/09/2011
					and isnull(i.Grd_ID,0) = isnull(@Grade_ID ,isnull(i.Grd_ID,0))
					and isnull(i.Dept_ID,0) = isnull(@Dept_ID ,isnull(i.Dept_ID,0))			
					and Isnull(i.Desig_ID,0) = isnull(@Desig_ID ,Isnull(i.Desig_ID,0))			
					and ISNULL(I.Emp_ID,0) = isnull(@Emp_ID ,ISNULL(I.Emp_ID,0))
					and Date_Of_Join <= @To_Date and I.emp_id in(
						select e.Emp_Id from
						(select e.emp_id, e.cmp_id, Date_Of_Join, isnull(Emp_left_Date, @To_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
						where cmp_id = @Company_id   and  
						(( @From_Date  >= Date_Of_Join  and  @From_Date <= Emp_left_date ) 
						or ( @to_Date  >= Date_Of_Join  and @To_Date <= Emp_left_date )
						or Emp_left_date is null and @To_Date >= Date_Of_Join)
						or @To_Date >= Emp_left_date  and  @From_Date <= Emp_left_date )  
			
		end
---------------------  

	

CREATE table #temp 
(
	Emp_ID numeric,
	Shift_id numeric,
	From_Date datetime,
	To_Date datetime,
	Shift_Name varchar(40),
	Shift_Type_Id Numeric,
	Shift_Type_Name varchar(20),
	Day_Count Numeric(18,2)
)

CREATE table #temp1
(
	Emp_ID numeric
)

				
		DECLARE Allow_Dedu_Cursor1 CURSOR FOR
			Select Shift_Tran_ID,ESD.Shift_ID,ESD.Emp_ID,For_Date,Shift_Name,STM.Shift_Type_Id,STM.Shift_Type From T0100_EMP_SHIFT_DETAIL ESD WITH (NOLOCK) Inner Join
				T0040_Shift_Master SM WITH (NOLOCK) on ESD.Shift_Id = SM.Shift_Id Left Outer Join
				T0040_Shift_Type_Master STM WITH (NOLOCK) on SM.Shift_Type_Id = STM.Shift_Type_Id Inner Join 
				@Emp_Cons EC on ESD.Emp_Id = EC.Emp_Id
			Order By For_Date
		OPEN Allow_Dedu_Cursor1
			fetch next from Allow_Dedu_Cursor1 into @Shift_Tran_ID,@shift_ID,@Emp_ID,@for_date,@Shift_Name,@Shift_Type_Id,@Shift_Type_Name
			while @@fetch_status = 0
				Begin
					If @From_Date > @for_date
						Set @for_date = @From_Date
				
					if exists (select 1 from  T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) where Emp_ID=@Emp_ID and For_Date >@for_date)
						Begin
							select top 1 @temp_todate=For_Date from T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) where Emp_ID=@Emp_ID and For_Date >@for_date order by For_Date 
							
							if @for_date <> @temp_todate  
								Begin
									set @temp_todate=dateadd(d,-1,@temp_todate)
								End
						End
					else
						Begin
							set @temp_todate= @To_Date 
						End
						
						insert into #temp
						select @Emp_ID,@shift_ID,@for_date,@temp_todate,@Shift_Name,@Shift_Type_Id,@Shift_Type_Name, DATEDIFF(D,@for_date,@temp_todate)+1 
					
				fetch next from Allow_Dedu_Cursor1 into @Shift_Tran_ID,@shift_ID,@Emp_ID,@for_date,@Shift_Name,@Shift_Type_Id,@Shift_Type_Name
				End
		close Allow_Dedu_Cursor1	
		deallocate Allow_Dedu_Cursor1

	Insert Into #temp1
		Select distinct Emp_ID From #temp


	------------------------
		Declare @test as varchar(max)
		
		DECLARE Allow_Dedu_Cursor2 CURSOR FOR
			Select Shift_Type From T0040_Shift_Type_Master WITH (NOLOCK) Where Cmp_Id = 1
		OPEN Allow_Dedu_Cursor2
			fetch next from Allow_Dedu_Cursor2 into @Shift_Type_Name
			while @@fetch_status = 0
				Begin
					
					Set @test ='alter table  #Temp1 ADD ['+ @Shift_Type_Name +'_Date] varchar(max)'
					exec(@test)	
					set @test=''
					
					Set @test ='alter table  #Temp1 ADD ['+ @Shift_Type_Name +'_Days] Numeric(18,2) Default 0'
					exec(@test)	
					set @test=''

				fetch next from Allow_Dedu_Cursor2 into @Shift_Type_Name
				End
		close Allow_Dedu_Cursor2
		deallocate Allow_Dedu_Cursor2
		
		Set @test ='alter table  #Temp1 ADD [UnApr_Leave_Date] varchar(max)'
		exec(@test)	
		set @test=''
		
		Set @test ='alter table  #Temp1 ADD [UnApr_Leave_Days]  Numeric(18,2) Default 0'
		exec(@test)	
		set @test=''

		Declare @Emp_Id1 As Numeric
		Declare @From_Date1 As Datetime
		Declare @To_Date1 as Datetime
		Declare @Shift_Type_Name1 as Varchar(30)
		Declare @Day_Count as varchar(5)
		Declare @Column1 as varchar(20)
		Declare @Column2 as varchar(20)
		Declare @Period as varchar(100)
		declare @returnedname as varchar(max)
		declare @returnedday as numeric(18,2)
		declare @returnedname1 as varchar(max)
		declare @returnedday1 as numeric(18,2)
		set @returnedname=''
		Set @returnedname1 =''
		
		DECLARE Allow_Dedu_Cursor3 CURSOR FOR
			Select Emp_Id,From_Date,To_Date,Shift_Type_Name,Day_Count From #Temp
		OPEN Allow_Dedu_Cursor3
			fetch next from Allow_Dedu_Cursor3 into @Emp_Id1,@From_Date1,@To_Date1,@Shift_Type_Name1,@Day_Count
			while @@fetch_status = 0
				Begin
					set @returnedname=null
					set @returnedname1=null
					Set @Column1 = @Shift_Type_Name1 + '_Date'
					Set @Column2 = @Shift_Type_Name1 + '_Days'
					Set @Period = Convert(varchar(11),@From_Date1,103) + ' to ' + Convert(varchar(11),@To_Date1,103)
					Select @returnedname= COALESCE(@returnedname + ', ', '') + Convert(varchar(11),From_Date,103) + ' to ' + Convert(varchar(11),To_Date,103) from #temp where Emp_ID = @Emp_Id1 and shift_type_name = @Shift_Type_Name1
					select @returnedday=sum(day_count) from #temp where Emp_ID = @Emp_Id1 and shift_type_name = @Shift_Type_Name1
					
					
					Select @returnedname1= COALESCE(@returnedname1 + ', ', '') + Convert(varchar(11),From_Date,103) + ' to ' + Convert(varchar(11),To_Date,103)
					from T0120_LEAVE_APPROVAL LA WITH (NOLOCK) Inner Join
						T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID Inner Join
						T0040_Leave_Master LM WITH (NOLOCK) on LAD.Leave_id = LM.Leave_Id
					Where Approval_Status = 'A' And Leave_Paid_Unpaid <> 'P' And Emp_ID = @Emp_ID
					
					Select @returnedday1 =SUM(Leave_Period)
					from T0120_LEAVE_APPROVAL LA WITH (NOLOCK) Inner Join
						T0130_LEAVE_APPROVAL_DETAIL LAD WITH (NOLOCK) on LA.Leave_Approval_ID = LAD.Leave_Approval_ID Inner Join
						T0040_Leave_Master LM WITH (NOLOCK) on LAD.Leave_id = LM.Leave_Id
					Where Approval_Status = 'A' And Leave_Paid_Unpaid <> 'P' And Emp_ID = @Emp_Id1
					

					Set @test ='Update #temp1 set ' + @Column1 + ' = ''' + @returnedname + ''',' + @Column2 + '=' + cast(@returnedday as varchar(5)) + ', UnApr_Leave_Date = ''' + @returnedname1 + ''', UnApr_Leave_Days = ' + Cast(@returnedday1 As varchar(5)) +' Where Emp_Id = '+Cast(@emp_id1 As Varchar(50))
					print @test
					exec (@test)

					fetch next from Allow_Dedu_Cursor3 into @Emp_Id1,@From_Date1,@To_Date1,@Shift_Type_Name1,@Day_Count
				End
		close Allow_Dedu_Cursor3
		deallocate Allow_Dedu_Cursor3

		
--select * from #temp1
--select * from #temp

      
   SELECT Alpha_Emp_Code,Emp_Full_Name,BM.Branch_Name,GM.Grd_Name,DM.Desig_Name,TM.Type_Name,CM.Cat_Name,DT.Dept_Name,
			tmp.*,
		   isnull(ccm.Center_Name,'-') as Cost_Center_Name
      FROM dbo.T0080_EMP_MASTER E  WITH (NOLOCK) INNER JOIN @Emp_cons EC on e.emp_id = Ec.emp_ID INNER JOIN   
      ( select T0095_INCREMENT.Emp_Id ,cat_id,Grd_ID,Dept_ID,Desig_Id,Branch_Id,Type_id,Bank_id,Curr_id,Wages_Type,Salary_Basis_on,Basic_salary,Gross_salary
		,Inc_Bank_Ac_No,Emp_OT,Emp_Late_Mark,Emp_Full_PF,Emp_PT,Emp_Fix_Salary,Emp_Part_time,Late_Dedu_Type,Emp_Childran,Center_ID
      from T0095_INCREMENT WITH (NOLOCK) inner join   
      ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_INCREMENT WITH (NOLOCK)  
      where Increment_Effective_date <= @To_Date and Cmp_ID = @Company_ID Group by emp_ID  ) Qry  
     on T0095_INCREMENT.Emp_ID = Qry.Emp_ID and  
     Increment_Effective_date   = Qry.For_date   
     where cmp_id = @Company_ID ) Inc_Qry on   
      e.Emp_ID = Inc_Qry.Emp_ID inner join  
      T0040_GRADE_MASTER GM WITH (NOLOCK) ON Inc_Qry.Grd_Id = GM.Grd_Id INNER JOIN
      T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Inc_Qry.Branch_ID = BM.Branch_Id Inner join       
      T0040_DESIGNATION_MASTER DM WITH (NOLOCK) ON Inc_Qry.Desig_Id = DM.Desig_Id LEFT OUTER JOIN
      T0040_BANK_MASTER BN WITH (NOLOCK) On Inc_Qry.Bank_id = BN.Bank_Id Left Outer join
      T0040_TYPE_MASTER TM WITH (NOLOCK) On Inc_Qry.Type_Id = TM.Type_Id Left Outer Join
      T0030_CATEGORY_MASTER CM WITH (NOLOCK) On Inc_Qry.Cat_id = CM.Cat_Id Left Outer Join
      T0040_DEPARTMENT_MASTER DT WITH (NOLOCK) ON Inc_Qry.Dept_Id = DT.Dept_Id Inner JOIN        
      #temp1 Tmp on inc_Qry.Emp_id = Tmp.Emp_id       left outer join
      T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) on CCM.Center_ID = Inc_Qry.Center_ID       
     WHERE e.Cmp_ID = @Company_ID   
Order by e.Emp_code

drop table #temp
drop table #temp1
    
      
 RETURN   


