
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_NON_PF_EMPLOYEE_SALARY]  
  @Cmp_ID   numeric  
 ,@From_Date  datetime  
 ,@To_Date   datetime  
 ,@Branch_ID  numeric  
 ,@Cat_ID   numeric   
 ,@Grd_ID   numeric  
 ,@Type_ID   numeric  
 ,@Dept_ID   numeric  
 ,@Desig_ID   numeric  
 ,@Emp_ID   numeric  
 ,@constraint  varchar(MAX)  = ''
 ,@Order_By	varchar(30) = 'Code' --Added by Jaina 31-Jul-2015 (To sort by Code/Name/Enroll No)      

AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @Branch_ID = 0    
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

	CREATE table #Data
	(  
		For_Date datetime,  
		Increment_ID numeric(18,0),  
		Cmp_ID numeric(18,0),  
		Emp_Id numeric(18,0),  
		Grd_ID numeric(18,0),
		Desig_Id NUMERIC(18,0) DEFAULT 0 --added jimit 28/09/2015  
	)  
	Declare @Ad_id as Numeric
	Select @Ad_id = Ad_Id From T0050_AD_MASTER WITH (NOLOCK) Where AD_DEF_ID = 2 And CMP_ID = @Cmp_ID
				
		--Added By Jaina 15-10-2015 Start
		
		IF @Constraint <> ''
		BEGIN			
				
					Insert Into #Data  
					  select distinct Increment_Effective_Date,Increment_ID,@Cmp_ID,Emp_ID,Grd_ID,Desig_Id 
					  from dbo.V_Emp_Cons where 
					  cmp_id=@Cmp_ID 
					   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
				   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
				   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
				   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
				   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
				   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
				   and EXISTS (select Data from dbo.Split(@Constraint, '#') D Where cast(D.data as numeric)=Isnull(Emp_ID,0)) 
				   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
					  and Increment_Effective_Date <= @To_Date 
					  and 
							  ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
								or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
								or (Left_date is null and @To_Date >= Join_Date)      
								or (@To_Date >= left_date  and  @From_Date <= left_date )) 
					
								order by Emp_ID
		END
		ELSE  --Added By Jaina 15-10-2015 End
		Begin
		
					Insert Into #Data  
					  select distinct Increment_Effective_Date,Increment_ID,@Cmp_ID,Emp_ID,Grd_ID,Desig_Id 
					  from dbo.V_Emp_Cons where 
					  cmp_id=@Cmp_ID 
					   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
				   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
				   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
				   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
				   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
				   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
				   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
					  and Increment_Effective_Date <= @To_Date 
					  and 
							  ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
								or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
								or (Left_date is null and @To_Date >= Join_Date)      
								or (@To_Date >= left_date  and  @From_Date <= left_date )) 
					
								order by Emp_ID
		END
			
						
	delete  from #Data where Increment_ID not in (select max(Increment_ID) from dbo.T0095_Increment WITH (NOLOCK)
	where  Increment_effective_Date <= @to_date
	group by emp_ID)

			
			
	Declare @Sal_St_Date   Datetime    
	Declare @Sal_end_Date   Datetime  

	-- Comment and added By rohit on 11022013
	declare @manual_salary_period as numeric(18,0)
	set @manual_salary_period = 0
  
	If @Branch_ID is null
		Begin 
			select Top 1 @Sal_St_Date = Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)
		End
	Else
		Begin
			select @Sal_St_Date  =Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
		End    
	   
 if isnull(@Sal_St_Date,'') = ''    
	begin    
	   set @From_Date  = @From_Date     
	   set @To_Date = @To_Date    
	end     
 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)=1    
	begin    
	   set @From_Date  = @From_Date     
	   set @To_Date = @To_Date    
	end     
 else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
	begin    
	   if @manual_salary_period = 0   
			Begin
			   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
			   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
	   
			   Set @From_Date = @Sal_St_Date
			   Set @To_Date = @Sal_End_Date
			End
		Else
			Begin
				Select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@To_Date) and YEAR=year(@To_Date)
			   
				Set @From_Date = @Sal_St_Date
				Set @To_Date = @Sal_End_Date 
			End 
	End  

		SELECT ROW_NUMBER()  OVER (
		Order by CASE WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(E.Enroll_No AS VARCHAR), 21)  --Added by Jaina 31 July 2015 start
							WHEN @Order_By='Name' THEN E.Emp_Full_Name
							When @Order_By = 'Designation' then (CASE WHEN dgm.Desig_dis_No  = 0 THEN DGM.Desig_Name ELSE RIGHT(REPLICATE('0',21) + CAST(DGM.Desig_dis_No AS VARCHAR), 21)   END)      --added jimit 25092015
							--ELSE RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
						End,Case When IsNumeric(Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(E.Alpha_Emp_Code,'="',''),'"',''), 20)
								 When IsNumeric(Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','') + Replicate('',21), 20)
								 Else Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','') End
		--ORDER BY  RIGHT(REPLICATE(N' ', 500) + e.Alpha_Emp_Code, 500) 
		 ) As Sr_No,
			Case UPPER(Inc.Payment_Mode) 
			When 'BANK TRANSFER' THEN INC.Inc_Bank_AC_No 
			WHEN 'CASH' THEN 'CASH' 
			WHEN 'CHEQUE' THEN 'CHEQUE' 
			END AS Inc_Bank_AC_No, E.Emp_Full_Name, MS.Net_amount, 
			inc.Branch_ID,DGM.Desig_Dis_No,
			E.Alpha_Emp_Code,E.Enroll_No			
		FROM  #Data D 
			inner join T0050_AD_MASTER AM WITH (NOLOCK) on D.Cmp_ID=AM.Cmp_ID 
			inner join T0095_INCREMENT Inc WITH (NOLOCK) on inc.Increment_ID = D.Increment_ID  
			inner join T0080_EMP_MASTER E  WITH (NOLOCK) on D.Emp_ID=E.Emp_ID 
			Inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on D.Increment_ID = Ms.Increment_ID	
			LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) on DGM.Desig_ID = D.Desig_Id
		WHERE D.Increment_ID  NOT IN     
			(Select Increment_ID from T0100_EMP_EARN_DEDUCTION WITH (NOLOCK) where ad_id=@Ad_id And Cmp_ID = @Cmp_ID) and AM.ad_id=@Ad_ID 
			And Month_St_Date >= @From_Date And Month_End_Date <= @To_Date
		--Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
		--	When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
		--		Else e.Alpha_Emp_Code
		--	End
		
		--added jimit 28/09/2015
		Order by Sr_No
								 -- RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
		------------------				
		--ORDER BY RIGHT(REPLICATE(N' ', 500) + e.Alpha_Emp_Code, 500)  
RETURN  


