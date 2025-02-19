




---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_T0100_WEEKOFF_ADJ_GET_BK010824ROnakb]
	 @Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(max)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if	exists (select * from [tempdb].dbo.sysobjects where name like '#Weekoff_Report' )		
			begin
				drop table #Weekoff_Report 
			end	
	CREATE table #Weekoff_Report 
		(
			 Emp_ID		numeric ,
			 Day1		varchar(10), 
			 Day2		varchar(10),
			 Day3		varchar(10),
			 Day4		varchar(10) ,
			 Day5		varchar(10) ,
			 Day6		varchar(10) ,
			 Day7		varchar(10) ,
			 Day8		varchar(10) ,
			 Day9		varchar(10) ,
			 Day10		varchar(10) ,
			 Day11		varchar(10) ,
			 Day12		varchar(10) ,
			 Day13		varchar(10) ,
			 Day14		varchar(10) ,
			 Day15		varchar(10) ,
			 Day16		varchar(10) ,
			 Day17		varchar(10) ,
			 Day18		varchar(10) ,
			 Day19		varchar(10) ,
			 Day20		varchar(10) ,
			 Day21		varchar(10) ,
			 Day22		varchar(10) ,
			 Day23		varchar(10) ,
			 Day24		varchar(10) ,
			 Day25		varchar(10) ,
			 Day26		varchar(10) ,
			 Day27		varchar(10) ,
			 Day28		varchar(10) ,
			 Day29		varchar(10) ,
			 Day30		varchar(10) ,
			 Day31		varchar(10) 
			)

	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null



	if @Constraint <> ''
		begin
			Insert Into #Weekoff_Report(Emp_ID)
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
			Insert Into #Weekoff_Report(Emp_ID)
			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join       
     ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)     
     where Increment_Effective_date <= @To_Date      
     and Cmp_ID = @Cmp_ID      
     group by emp_ID  ) Qry on      
     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date      
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
    or @To_Date >= left_date  and  @From_Date <= left_date )      

		/*	select I.Emp_Id from T0095_Increment I inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment
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
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) */
			
		end

	CREATE table #Emp_Weekoff
	  (
			Emp_Id		numeric , 
			Cmp_ID		numeric,
			For_Date	datetime,
			W_Day		numeric(3,1)
	  )	  
		
			
			Declare cur_emp cursor for 
			select Emp_ID From #Weekoff_Report 
			open cur_emp
			fetch next from Cur_Emp into @Emp_ID 
			while @@fetch_Status = 0
				begin 
	/*				select 	@Branch_ID = Branch_ID From T0095_Increment I inner join 
							( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_ID
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
					Where I.Emp_ID = @Emp_ID

					select @Is_Cancel_Holiday = isnull(Is_Cancel_Holiday,0)  ,@Is_Cancel_Weekoff = isnull(Is_Cancel_Weekoff,0)
						
					from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID	and Branch_ID = @Branch_ID
					and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)
					*/
					Exec dbo.SP_EMP_WEEKOFF_DATE_GET  @Emp_Id,@Cmp_ID,@From_Date,@To_Date,null,null,9,'','',0,0,1  ---added 9 for weekoff not cancel by Hardik 06/04/2015
					fetch next from Cur_Emp into @Emp_ID 
				end 
			close cur_Emp
			Deallocate cur_Emp
		  
		Declare  @For_Date  Datetime
		Declare  @Sql_Query nvarchar(4000)
		Declare  @Var_Date	varchar(5)
		
		
		set @For_Date = @From_Date 
		while @For_Date <=@To_Date
			Begin		
					set @Var_Date = '-' + left(datename(dw,@For_Date),2)
					set @Sql_Query = 'Update #Weekoff_Report 
								   set Day' + cast(day(@For_Date) as varchar(3)) + ' = @Var_Date 
								    From #Weekoff_Report  ES inner Join #Emp_Weekoff ew on es.emp_ID =ew.Emp_ID 
								  and W_Day =0.5 and day(ew.For_Date)=' + cast(day(@For_Date) as varchar(3)) 
					
					 execute sp_executesql @Sql_Query ,N'@Var_Date varchar(5)',@Var_Date
					 
					 set @Sql_Query = 'Update #Weekoff_Report 
								   set Day' + cast(day(@For_Date) as varchar(3)) + ' = left(datename(dw,@For_Date),2)
								   From #Weekoff_Report  ES inner Join #Emp_Weekoff ew on es.emp_ID =ew.Emp_ID 
								  and W_Day =1 and day(ew.For_Date)=' + cast(day(@For_Date) as varchar(3)) 
								  
					execute sp_executesql @Sql_Query ,N'@For_Date Datetime',@For_Date
					Set @For_Date = dateadd(d,1,@For_Date)
			end	

	
		Select ES.* ,Emp_full_Name,Emp_Code,Comp_Name,Branch_Address,Branch_NAme,Grd_Name,Dept_NAme,Type_Name,Desig_NAme,E.Alpha_Emp_Code
		,Cmp_NAme,Cmp_Address ,@From_Date as P_From_date ,@To_Date as P_To_Date ,BM.Branch_ID --ADDED BY MIHIR TRIVEDI ON 30032012
		From #Weekoff_Report ES inner join T0080_Emp_master E WITH (NOLOCK) on Es.Emp_ID = E.Emp_ID inner join 
			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date  from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment	WITH (NOLOCK)-- Ankit 08092014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID) I_Q 
				on E.Emp_ID = I_Q.Emp_ID  inner join
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
					T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID Inner join 
					T0010_company_master cm WITH (NOLOCK) on e.cmp_Id = cm.cmp_ID and Emp_Left<>'Y'  
				Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
				When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
					Else e.Alpha_Emp_Code
				End
					
 	RETURN




