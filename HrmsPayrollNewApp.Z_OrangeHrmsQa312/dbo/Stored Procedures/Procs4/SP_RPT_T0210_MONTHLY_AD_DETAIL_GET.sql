
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_T0210_MONTHLY_AD_DETAIL_GET]
	 @Cmp_ID 		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID 	varchar(max)=''  --Added By Jaina 2-11-2015 Start
	,@Cat_ID 		varchar(max)='' 
	,@Grd_ID 		varchar(max)=''
	,@Type_ID 		varchar(max)=''
	,@Dept_ID 		varchar(max)=''
	,@Desig_ID 		varchar(max)='' --Added By Jaina 2-11-2015 End
	,@Emp_ID 		numeric
	,@constraint 	varchar(max)
	,@AD_ID			numeric = 0
	,@Salary_Cycle_id numeric = NULL
	,@Segment_Id  varchar(max)=''  --Added By Jaina 2-11-2015 Start		 
	,@Vertical_Id varchar(max)=''		 
	,@SubVertical_Id varchar(max)=''	 
	,@SubBranch_Id varchar(max)=''	--Added By Jaina 2-11-2015 End
	,@Show_Hidden_Allowance  bit = 0   --Added by Jaina 16-05-2017 
	,@for_UnCovered  bit = 0   --Added by Jaina 16-05-2017            
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 
	--set @Show_Hidden_Allowance = 0
	 
	IF @Branch_ID = '0' or @Branch_ID=''
		set @Branch_ID = null
		
	IF @Cat_ID = '0' or @Cat_ID=''  
		set @Cat_ID = null

	IF @Grd_ID = '0' or @Grd_ID=''  
		set @Grd_ID = null

	IF @Type_ID = '0'  or @Type_ID=''
		set @Type_ID = null

	IF @Dept_ID = '0' or @Dept_ID=''
		set @Dept_ID = null

	IF @Desig_ID = '0' or @Desig_ID=''
		set @Desig_ID = null

	IF @Emp_ID = 0   
		set @Emp_ID = null

	IF @AD_ID = 0
		set @AD_ID = null
		
	IF @Salary_Cycle_id = 0	 -- Added By Gadriwala Muslim 21082013
	set @Salary_Cycle_id = null	
	If @Segment_Id = '0' or @Segment_Id=''		 -- Added By Gadriwala Muslim 21082013
	set @Segment_Id = null
	If @Vertical_Id = '0' or @Vertical_Id=''		 -- Added By Gadriwala Muslim 21082013
	set @Vertical_Id = null
	If @SubVertical_Id = '0' or @SubVertical_Id=''	 -- Added By Gadriwala Muslim 21082013
	set @SubVertical_Id = null	
	If @SubBranch_Id = '0' or @SubBranch_Id=''	 -- Added By Gadriwala Muslim 21082013
	set @SubBranch_Id = null	
	
		
	CREATE table #Emp_Cons 
	(
		Emp_ID	numeric,
		Branch_ID numeric,  --Added By Jaina 2-11-2015
		Increment_ID numeric --Added By Jaina 2-11-2015    
	)
	
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,@Salary_Cycle_id,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_Id,0,0,0,'',0,0    	
	
	  Declare @Sal_St_Date   Datetime    
	  Declare @Sal_end_Date   Datetime  
	  declare @manual_salary_Period as numeric(18,0) -- Comment and added By rohit on 11022013 
				  
		If @Branch_ID is null
			Begin 
			
				select Top 1 @Sal_St_Date  = Sal_st_Date,@manual_salary_Period= isnull(manual_salary_Period ,0) 
				  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
				  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
			End
		Else
			Begin
		
				select @Sal_St_Date  =Sal_st_Date ,@manual_salary_Period= isnull(manual_salary_Period ,0)
				  from T0040_GENERAL_SETTING As G1 WITH (NOLOCK)
				  inner JOIN (Select Cast(data as numeric) as Branch_ID FROM dbo.Split(@Branch_ID,'#')) T ON T.Branch_ID=G1.Branch_ID 
				  where cmp_ID = @cmp_ID 
				  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING G2 WITH (NOLOCK)
				  inner JOIN (Select Cast(data as numeric) as Branch_ID FROM dbo.Split(@Branch_ID,'#')) T1 ON T1.Branch_ID=G2.Branch_ID 
				   where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
				  
				
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
	   	   if @manual_salary_Period =0 
			Begin
			   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
			   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
			   Set @From_Date = @Sal_St_Date
			   Set @To_Date = @Sal_End_Date  
			 end
		else
			begin
				select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@From_Date) and YEAR=year(@From_Date)							   
			     Set @From_Date = @Sal_St_Date
			   Set @To_Date = @Sal_End_Date    
			End	  

	IF @for_UnCovered = 0	--This will show the Amount that is deducted in Salary.
		BEGIN
			SELECT  MAD.*,ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_full_Name,Grd_Name,Alpha_Emp_Code as EMP_CODE,Type_Name,Dept_Name,Desig_Name,AD_Name,AD_LEVEL
					,cmp_Name,Cmp_Address,Branch_Address,Comp_name,branch_name
					,@from_Date as P_From_Date , @To_date as P_To_Date,BM.Branch_ID,E.Pan_No,I_Q.Basic_Salary
					,E.Emp_First_Name,E.Alpha_Emp_Code,E.SSN_No,(CASE When ADM.AD_DEF_ID IN(2,14,15,16) Then 1 ELSE 0 END) as Flag  --added Nilesh Patel on 24112015
					,MADI.Amount As Import_Amount,MADI.Comments As Import_Comments , @for_UnCovered as for_UnCovered
					, 0 as UnCovered_Amt
			FROM T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK)
				INNER JOIN	T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID
				INNER JOIN	T0200_MONTHLY_SALARY MS WITH (NOLOCK) ON MS.Sal_Tran_ID = MAD.Sal_Tran_ID
				INNER JOIN	T0080_EMP_MASTER E WITH (NOLOCK) on MAD.emp_ID = E.emp_ID
				INNER  JOIN #EMP_CONS EC ON E.EMP_ID = EC.EMP_ID
				INNER JOIN	T0095_INCREMENT I_Q		WITH (NOLOCK)	ON EC.Increment_ID = I_Q.Increment_ID AND EC.EMP_ID = I_Q.EMP_ID
				INNER JOIN		T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID
				LEFT OUTER JOIN	T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
				LEFT OUTER JOIN	T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
				LEFT OUTER JOIN	T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
				INNER JOIN 		T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  
				INNER JOIN		T0010_company_Master cm WITH (NOLOCK) on MAD.Cmp_ID = cm.cmp_ID 
				LEFT OUTER JOIN	T0190_MONTHLY_AD_DETAIL_IMPORT MADI WITH (NOLOCK) ON MAD.Emp_ID = MADI.Emp_ID AND MAD.AD_ID = MADI.AD_ID --add by chetan 300517 for import report
								AND Month(MAD.For_Date)= MADI.[Month] AND Year(MAD.For_Date) = MADI.[Year]
				WHERE E.Cmp_ID = @Cmp_Id and mad.For_date >=@From_Date and MAD.For_date <=@To_Date
						and  mad.AD_ID = isnull(@AD_ID,Mad.AD_ID) and MAD.M_AD_Amount <> 0
						and S_Sal_Tran_ID is null and L_Sal_Tran_ID is null
						and MS.Is_FNF <> 1 --Ankit 06072015
						AND (CASE WHEN @SHOW_HIDDEN_ALLOWANCE = 0  AND  ADM.HIDE_IN_REPORTS = 1 AND ADM.AD_NOT_EFFECT_SALARY=1 THEN 0 ELSE 1 END )=1  --CHANGE BY JAINA 16-05-2017
		END
	ELSE					--This will show the Amount that are not deducted in Salary , due to Salary going Negative
		BEGIN
			SELECT  MAD.*,ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_full_Name,Grd_Name,Alpha_Emp_Code as EMP_CODE,Type_Name,Dept_Name,Desig_Name,AD_Name,AD_LEVEL
					,cmp_Name,Cmp_Address,Branch_Address,Comp_name,branch_name
					,@from_Date as P_From_Date , @To_date as P_To_Date,BM.Branch_ID,E.Pan_No,I_Q.Basic_Salary
					,E.Emp_First_Name,E.Alpha_Emp_Code,E.SSN_No,(CASE When ADM.AD_DEF_ID IN(2,14,15,16) Then 1 ELSE 0 END) as Flag
					,MADI.Amount As Import_Amount,MADI.Comments As Import_Comments 
					, @for_UnCovered as for_UnCovered
					, CASE WHEN ISNULL(MADI.AMOUNT,0) > 0 THEN (MADI.AMOUNT - MAD.M_AD_AMOUNT) ELSE (MAD.M_AD_Actual_Per_Amount - M_AD_Amount) END AS UnCovered_Amt
			FROM T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK)
				INNER JOIN		T0050_AD_MASTER ADM		WITH (NOLOCK) 	ON MAD.AD_ID = ADM.AD_ID
				INNER JOIN		T0200_MONTHLY_SALARY MS	WITH (NOLOCK)	ON MS.Sal_Tran_ID = MAD.Sal_Tran_ID
				INNER JOIN		T0080_EMP_MASTER E		WITH (NOLOCK)	ON MAD.emp_ID = E.emp_ID
				INNER JOIN		#EMP_CONS EC				ON E.EMP_ID = EC.EMP_ID
				INNER JOIN		T0095_INCREMENT I_Q		WITH (NOLOCK)	ON EC.Increment_ID = I_Q.Increment_ID AND EC.EMP_ID = I_Q.EMP_ID
				INNER JOIN		T0040_GRADE_MASTER GM	WITH (NOLOCK)	ON I_Q.Grd_ID = GM.Grd_ID
				INNER JOIN 		T0030_BRANCH_MASTER BM	WITH (NOLOCK)	on I_Q.Branch_ID = BM.Branch_ID  
				INNER JOIN		T0010_COMPANY_MASTER CM		WITH (NOLOCK) on MAD.Cmp_ID = cm.cmp_ID 
				LEFT OUTER JOIN	T0040_TYPE_MASTER ETM	WITH (NOLOCK)	ON I_Q.Type_ID = ETM.Type_ID 
				LEFT OUTER JOIN	T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
				LEFT OUTER JOIN	T0040_DEPARTMENT_MASTER DM WITH (NOLOCK)	ON I_Q.Dept_Id = DM.Dept_Id 
				LEFT OUTER JOIN	T0190_MONTHLY_AD_DETAIL_IMPORT MADI WITH (NOLOCK) ON MAD.Emp_ID = MADI.Emp_ID AND MAD.AD_ID = MADI.AD_ID
								AND Month(MAD.For_Date)= MADI.[Month] AND Year(MAD.For_Date) = MADI.[Year]
				WHERE E.Cmp_ID = @Cmp_Id and MAD.For_date >=@From_Date and MAD.For_date <=@To_Date
						and  MAD.AD_ID = isnull(@AD_ID,Mad.AD_ID)
						and S_Sal_Tran_ID is null and L_Sal_Tran_ID is null
						and MS.Is_FNF <> 1
						AND (CASE WHEN @SHOW_HIDDEN_ALLOWANCE = 0  AND  ADM.HIDE_IN_REPORTS = 1 AND ADM.AD_NOT_EFFECT_SALARY=1 THEN 0 ELSE 1 END )=1  --CHANGE BY JAINA 16-05-2017
						
				
		END			
			
	RETURN 




