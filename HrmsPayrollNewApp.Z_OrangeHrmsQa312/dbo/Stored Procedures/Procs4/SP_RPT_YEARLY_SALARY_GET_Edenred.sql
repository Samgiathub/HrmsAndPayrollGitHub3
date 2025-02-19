

CREATE PROCEDURE [dbo].[SP_RPT_YEARLY_SALARY_GET_Edenred]
	 @Cmp_ID 		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID 	numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(MAX)
	,@Report_Call	varchar(20)='Net Salary'
	,@Salary_Cycle_id numeric = NULL
	,@Segment_Id  numeric = 0		 
	,@Vertical_Id numeric = 0		
	,@SubVertical_Id numeric = 0	
	,@SubBranch_Id numeric = 0		 
	               
AS
	Set Nocount on 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON
	
	
		IF @Branch_ID = 0  
		set @Branch_ID = null   
	 
	 If @Emp_ID = 0  
		set @Emp_ID = null  
	 If @Desig_ID = 0  
		set @Desig_ID = null  
     If @Dept_ID = 0  
		set @Dept_ID = null 
     If @Cat_ID = 0
        set @Cat_ID = null
        
     If @Type_id = 0
        set @Type_id = null
	IF @Emp_ID = 0  
		set @Emp_ID = null
		
	If @Segment_Id = 0		 -- Added By Gadriwala Muslim 21082013
		set @Segment_Id = null
	If @Vertical_Id = 0		 -- Added By Gadriwala Muslim 21082013
		set @Vertical_Id = null
	If @SubVertical_Id = 0	 -- Added By Gadriwala Muslim 21082013
		set @SubVertical_Id = null	
	If @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 21082013
		set @SubBranch_Id = null	
	IF @Grd_ID = 0  
		set @Grd_ID = null


	
	
	
	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   


	EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0 ,0 ,0,0,0,0,0,0,0,'' ,@With_Ctc = 1
	
	
		
		
		
		
	
		Declare @Month numeric 
		Declare @Year numeric  
		--if	exists (select 1 from [tempdb].dbo.sysobjects where name like '#Yearly_Salary' )	
		If Object_Id ('tempdb..#Emp_Yearly_Salary') Is not null
			begin
				drop table #Emp_Yearly_Salary 
			end
			
		--if exists(SELECT 1 FROM [tempdb].dbo.sysobjects where name LIKE '#Salary_Publish_Emp')
		If Object_Id ('tempdb..#Salary_Publish_Emp') Is not null
			begin
				drop TABLE #Salary_Publish_Emp
			End 
			
		Create Table #Salary_Publish_Emp
		(
			Cmp_ID numeric,
			Emp_ID numeric,
			P_Month Numeric,
			P_Year Numeric,
			Publish_Flag Numeric
		)
		Create Clustered index IX_Salary_Publish_Emp_Emp_ID_P_Month_P_Year_Publish_Flag on #Salary_Publish_Emp (Emp_ID,P_Month,P_Year,Publish_Flag)
		
		

		Insert into #Salary_Publish_Emp(Cmp_ID,Emp_ID,P_Month,P_Year,Publish_Flag)
		(Select ms.Cmp_ID,EC.Emp_ID,month(Ms.Month_End_Date),YEAR(ms.Month_End_Date),isnull(SPE.Is_Publish,0) FROM T0200_MONTHLY_SALARY Ms 
		left join T0250_SALARY_PUBLISH_ESS SPE on Ms.Emp_ID=SPE.Emp_ID and month(Ms.Month_End_Date) = SPE.MONTH and YEAR(ms.Month_End_Date) = SPE.Year AND SPE.Sal_Type='Salary'  --Mukti(30062016)added Sal_Type
		Inner Join #Emp_Cons EC on ms.Emp_ID = EC.Emp_ID)  -- Changed by rohit For if Salary Not Publish or Unpublish then its Not Shows in yearly Salary report- on 17122015
		

		select * from #Salary_Publish_Emp
		 --CREATE TABLE #Emp_Yearly_Salary
		 --(
			--CMP_ID NUMERIC(18,0),
			--EMP_ID NUMERIC(18,0),
			--Alpha_Emp_Code Varchar(50),
			--month_num VARCHAR(25),
			--Net_Amount NUMERIC(18,2),
			--StartDate datetime,
			--Branch_Id numeric(18,0)   
		 --)	 	
			
		select em.Alpha_Emp_Code as Emp_Id,ms.Net_Amount as Total_Salary,'' as Variable_Pay,@From_Date as From_Date,@To_Date as To_Date
		,MS.Absent_Days as Leave_Days,'' End_Of_service_Benefits,
		(case when em.Emp_Left_Date between @From_Date and @To_Date then em.Emp_Left_Date else '' end)as End_Of_Service_Date,
		em.Branch_ID,em.subBranch_ID,em.Vertical_ID,em.SubVertical_ID,em.Grd_ID,em.Desig_Id,em.Dept_ID,em.Type_ID
		into  #Emp_Yearly_Salary
		from 
		T0080_EMP_MASTER em 
		inner  join #Emp_Cons ec on ec.Emp_ID=em.Emp_ID 
		inner join T0200_MONTHLY_SALARY ms on ms.Emp_ID=em.Emp_ID
		inner join #Salary_Publish_Emp sb on sb.Emp_ID=em.Emp_ID
	
			select * from #Emp_Yearly_Salary	
	RETURN



