

-- =============================================
-- Create by:	Nilesh Patel
-- Create date: 10102014
-- Description:	For New Report of FNF Register Details 
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================

CREATE PROCEDURE [dbo].[Rpt_FNF_Register_Export]  
	 @Company_id		numeric  
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric	
	,@Grade_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@Constraint	varchar(max)
	,@Cat_ID        numeric = 0
	,@is_column		tinyint = 0
	,@Salary_Cycle_id  NUMERIC  = 0
	,@Segment_ID Numeric = 0 
	,@Vertical Numeric = 0 
	,@SubVertical Numeric = 0 
	,@subBranch Numeric = 0 
	,@Order_By		varchar(30) = 'Code' --Added by Jimit 28/9/2015 (To sort by Code/Name/Enroll No)
	,@Show_Hidden_Allowance  bit = 0   --Added by Jaina 11-05-2017            

AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	set @Show_Hidden_Allowance = 0
	
	Declare @Actual_From_Date datetime
	Declare @Actual_To_Date datetime
	
	Declare @P_Days as numeric(22,2)
	Declare @Arear_Days as Numeric(18,2)
	Declare @Basic_Salary As Numeric(22,2)
	Declare @TDS As Numeric(22,2)
	Declare @Settl As Numeric(22,2)
	Declare @OTher_Allow As Numeric(22,2)
	Declare @Total_Allowance As Numeric(22,2)
	Declare @CO_Amount As Numeric(22,2)
	Declare @Total_Deduction As Numeric(22,2)
	Declare @PT As Numeric(22,2)
	Declare @Loan As Numeric(22,2)
	Declare @Advance As Numeric(22,2)	
	Declare @Net_Salary As Numeric(22,2)	
	Declare @Revenue_Amt As Numeric(22,2)	
	Declare @LWF_Amt As Numeric(22,2)	
	Declare @Other_Dedu As Numeric(22,2)	
	
	
	Declare @Absent_Day numeric(18,2)
	Declare @Holiday_Day numeric(18,2)
	Declare @WeekOff_Day numeric(18,2)
	--Declare @Leave_Day numeric(18,2) -- Added By Ali 18122013
	Declare @Working_Day numeric(18,2)
	Declare @OT_Hours numeric(18,2)
	Declare @OT_Amount numeric(18,2)
	Declare @OT_Rate Numeric(18,2)
	Declare @Fix_OT_Shift_Hours varchar(40)
	Declare @Fix_OT_Shift_seconds numeric(18,2)
	DECLARE @Leave_Salary_Amount numeric(18,2)  --Added By Ramiz on 02/06/2016
	
	DECLARE @Uniform_Installment_Amount numeric(18,2) --Mukti(20062017)
	DECLARE @Uniform_Refund_Amount numeric(18,2)  --Mukti(20062017)
	DECLARE @Arear_Month numeric(18,0)--Mukti(22052018)
	DECLARE @Sal_Cal_Days numeric(18,0)--Mukti(22052018)
	
	set @Actual_From_Date = @From_Date
	set @Actual_To_Date = @To_Date
	
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
     If @Cat_ID = 0
        set @Cat_ID = null
        
     If @Type_id = 0
        set @Type_id = null
        
        
     if @Salary_Cycle_id   = 0
		set @Salary_Cycle_id = null
		
	if @Segment_ID = 0 
		set @Segment_ID = NULL
		
	if @Vertical = 0 
		set @Vertical = NULL
		
	if @SubVertical = 0 
		set @SubVertical = NULL
	
	if @subBranch  = 0 
		set @subBranch = NULL

   
    Declare @Sal_St_Date   Datetime    
	 Declare @Sal_end_Date   Datetime   
	
	 declare @manual_salary_period as numeric(18,0)
	 set @manual_salary_period = 0
	 


	 If @Branch_ID is null
			Begin 
				select Top 1 @Sal_St_Date  = Sal_st_Date,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
				  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @Company_id    
				  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Cmp_ID = @Company_id)    
			End
		Else
			Begin
				select @Sal_St_Date  =Sal_st_Date,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
				  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @Company_id and Branch_ID = @Branch_ID    
				  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Company_id)    
			End
			
		
   
	 if isnull(@Sal_St_Date,'') = ''    
		  begin    
			   set @From_Date  = @From_Date     
			   set @To_Date = @To_Date  
		  end     
	 else if day(@Sal_St_Date) =1   
		  begin    
			   set @From_Date  = @From_Date     
			   set @To_Date = @To_Date   	         
		  end        
    
 Declare @Emp_Cons Table
	(
		Emp_ID	numeric ,     
		Branch_ID NUMERIC,
		Increment_ID NUMERIC 
	)
	
	
		
	if @Constraint <> ''
		begin
			INSERT INTO @Emp_Cons(Emp_ID, Branch_ID, Increment_ID)
			SELECT	T.Emp_ID,I.Branch_ID,I.Increment_ID
			FROM	(SELECT Cast(Data As Numeric) as Emp_ID 
					 FROM	dbo.Split (@Constraint,'#') T 
					 WHERE	Data <> ''
					 ) T 
					 INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON T.EMP_ID=I.EMP_ID	
					 INNER JOIN (SELECT	I1.EMP_ID, MAX(I1.Increment_ID) As Increment_ID
								 FROM	T0095_INCREMENT I1 WITH (NOLOCK)
										INNER JOIN (SELECT	I2.EMP_ID, MAX(I2.Increment_Effective_Date) As Increment_Effective_Date
													FROM	T0095_INCREMENT I2 WITH (NOLOCK)
													WHERE	I2.Increment_Effective_Date < @To_date
													GROUP BY I2.Emp_ID) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_Effective_Date=I2.Increment_Effective_Date
								GROUP BY I1.Emp_ID) I1 ON I.Emp_ID=I.Emp_ID And I.Increment_ID=I1.Increment_ID
		END
	ELSE
		BEGIN
		
		
		INSERT INTO @Emp_Cons

			SELECT DISTINCT V.emp_id,branch_id,V.Increment_ID 
			FROM V_Emp_Cons V 
			  Inner Join
						dbo.T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MS.Emp_ID = V.Emp_ID 
			LEFT OUTER JOIN (SELECT DISTINCT ESC.SalDate_id,ESC.emp_id AS eid 
									FROM T0095_Emp_Salary_Cycle ESC WITH (NOLOCK)
										INNER JOIN (SELECT MAX(Effective_date) AS Effective_date,emp_id 
														FROM T0095_Emp_Salary_Cycle WITH (NOLOCK)
														WHERE Effective_date <= @To_Date
														GROUP BY emp_id
													) Qry ON Qry.Effective_date = ESC.Effective_date AND Qry.Emp_id = ESC.Emp_id
								) AS QrySC ON QrySC.eid = V.Emp_ID
			WHERE 
		      V.cmp_id=@Company_id 				
		       AND ISNULL(Cat_ID,0) = ISNULL(@Cat_ID ,ISNULL(Cat_ID,0))          
		       AND Branch_ID = ISNULL(@Branch_ID ,Branch_ID)      
		   AND Grd_ID = ISNULL(@Grade_ID ,Grd_ID)      
		   AND ISNULL(Dept_ID,0) = ISNULL(@Dept_ID ,ISNULL(Dept_ID,0))      
		   AND ISNULL(TYPE_ID,0) = ISNULL(@Type_ID ,ISNULL(TYPE_ID,0))      
		   AND ISNULL(Desig_ID,0) = ISNULL(@Desig_ID ,ISNULL(Desig_ID,0))
		   AND ISNULL(QrySC.SalDate_id,0) = ISNULL(@Salary_Cycle_id ,ISNULL(QrySC.SalDate_id,0))     
		   And ISNULL(Segment_ID,0) = ISNULL(@Segment_ID,IsNull(Segment_ID,0))
		   And ISNULL(Vertical_ID,0) = ISNULL(@Vertical,IsNull(Vertical_ID,0))
		   And ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical,IsNull(SubVertical_ID,0))
		   And ISNULL(subBranch_ID,0) = ISNULL(@subBranch,IsNull(subBranch_ID,0)) -- Added on 06082013
		   and month(ms.Month_End_Date)  = month(@To_Date) and year(ms.Month_End_Date)  = year(@To_Date)
		   and ms.Is_FNF = 0
		   AND V.Emp_Id = ISNULL(@Emp_Id,V.Emp_Id) 
		      AND Increment_Effective_Date <= @To_Date 
		      AND 
                       ( (@From_Date  >= join_Date  AND  @From_Date <= left_date )      
						OR ( @To_Date  >= join_Date  AND @To_Date <= left_date )      
						OR (Left_date IS NULL AND @To_Date >= Join_Date)      
						OR (@To_Date >= left_date  AND  @From_Date <= left_date )
						OR 1=(case when ( (left_date <= @To_Date) and (dateadd(mm,1,Left_Date) > @From_Date ))  then 1 else 0 end)
						)
			 
			ORDER BY Emp_ID
						
			DELETE  FROM @Emp_Cons WHERE Increment_ID NOT IN (SELECT MAX(Increment_ID) FROM T0095_Increment WITH (NOLOCK)
				WHERE  Increment_effective_Date <= @to_date
				GROUP BY emp_ID )
			
		end
	

		CREATE table #CTCMast
		(
			Cmp_ID			numeric(18,0)
			,Emp_ID			numeric(18,0) primary key
			,Emp_code		numeric(18,0)
			,Alpha_Emp_Code	varchar(50)
			,Emp_Full_Name	varchar(250)
			,Branch			nvarchar(100)
			,Deptartment		nvarchar(100)
			,Designation		nvarchar(100)
			,Grade			nvarchar(100)
			,TypeName		nvarchar(100)
			,Branch_Id       Numeric(18,0)
			,Bank_Ac_No		Varchar(50)
			,Secondary_AC_No Varchar(20)
			,Primary_IFSC_Code Varchar(50)
			,Secondary_IFSC_Code Varchar(50)
			,Pan_No			Varchar(50)
			,Date_of_Join    datetime
			,Emp_Left_DT     datetime
			,reg_Date        datetime
			,reg_Acpt_Date   datetime
			,Present_Day		numeric(18,2)
			,Arear_Day		Numeric(18,2)
			,Arear_Month	 Numeric(18,0) --Mukti(22052018)
			,Absent_Day		numeric(18,2)
			,Holiday_Day		numeric(18,2)
			,WeekOff_Day		numeric(18,2)
			,Working_Day		numeric(18,2)
			,Actual_CTC		Numeric(18,0)
			--,Other_Allow		Numeric(18,2) 
			--,Shortfall_Amount Numeric(18,2)
			,Shortfall_Days Numeric(18,2)
			,Is_terminate   Numeric(18,0)
			--,Basic_Salary	numeric(18,2)
			--,Settl_Salary	Numeric(18,2)
			,Desig_dis_No    numeric(18,0) DEFAULT 0  --added jimit 28/9/2015
			,Enroll_No       VARCHAR(50)	DEFAULT ''	--added jimit 28/9/2015	
		)
	
		Declare @Columns nvarchar(4000)
		Declare @Leave_Columns nvarchar(Max)
		Declare @Leave_Name nvarchar(30)
		set @Leave_Columns = ''
		Set @Columns = '#'
		declare @count_leave as numeric(18,2)
		set @count_leave = 0
		
		INSERT	INTO #CTCMast 
		SELECT	E.Cmp_ID,E.Emp_ID,E.Emp_code,E.Alpha_Emp_Code,ISNULL(E.EmpName_Alias_Salary,E.Emp_Full_Name),
				BM.Branch_Name,dm.Dept_Name,dnm.Desig_Name,ga.Grd_Name,tm.Type_Name,BM.Branch_ID,
				Case Upper(Payment_Mode) 
						When 'BANK TRANSFER' THEN '="' + Inc_Bank_AC_No + '"'  
						When 'CASH' Then 'CASH' 
						Else 'CHEQUE' 
				End Bank_Ac_No,'="' + Inc_Bank_AC_No_Two + '"',E.Ifsc_Code,E.Ifsc_Code_Two,Pan_No,E.Date_Of_Join,E.Emp_Left_Date,lE.reg_Date,lE.Reg_Accept_Date,0,0,0,0,0,0,0,0,0,
				LE.Is_Terminate,dnm.Desig_Dis_No,E.Enroll_No  --added jimit 28/09/2015
		FROM	T0080_EMP_MASTER E	WITH (NOLOCK)
				INNER JOIN @Emp_Cons EC ON E.Emp_ID = EC.Emp_ID 
				INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON EC.Increment_ID = I.Increment_ID
				INNER JOIN T0100_LEFT_EMP LE WITH (NOLOCK) ON E.EMP_ID = LE.EMP_ID 
				LEFT OUTER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) on I.Branch_ID = bm.Branch_ID
				LEFT OUTER JOIN T0040_GRADE_MASTER GA WITH (NOLOCK) on I.Grd_ID = ga.Grd_ID
				LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on I.Dept_ID = dm.Dept_Id
				LEFT OUTER JOIN T0040_DESIGNATION_MASTER DNM WITH (NOLOCK) on I.Desig_Id = dnm.Desig_ID
				LEFT OUTER JOIN T0040_TYPE_MASTER tm WITH (NOLOCK) ON I.Type_ID = TM.Type_ID

	Declare @CTC_CMP_ID numeric(18,0)
	Declare @CTC_EMP_ID numeric(18,0)
	Declare @CTC_BASIC numeric(18,2)
	
	Declare @AD_NAME_DYN nvarchar(100)
	declare @val nvarchar(500)
	
	
	DECLARE Leave_Cursor CURSOR FOR
			Select Leave_Name
				 from T0120_Leave_Approval la WITH (NOLOCK) 
				 inner join @Emp_cons ec on la.emp_ID = ec.emp_ID 
				 Inner join  T0130_Leave_Approval_Detail Lad WITH (NOLOCK) on la.Leave_Approval_ID = lad.Leave_Approval_ID 
				 inner join T0080_Emp_Master e WITH (NOLOCK) on la.emp_ID= e.emp_ID 
				 inner join T0040_Leave_Master LM WITH (NOLOCK) on LM.Leave_ID = Lad.Leave_ID
				 inner join ( select I.Emp_Id ,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
							( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
									where Increment_Effective_date <= @To_Date
									and Cmp_ID = @Company_id
									group by emp_ID  ) Qry on
									I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date	 ) I_Q on E.Emp_ID = I_Q.Emp_ID  
				where  la.cmp_ID=@Company_id  and ((lad.From_Date >=@From_Date and lad.From_Date <=@To_Date	) or 	(lad.to_Date >=@From_Date and lad.to_Date <=@To_Date	))				  
				group by Leave_Name
		OPEN Leave_Cursor
			fetch next from Leave_Cursor into @Leave_Name
			while @@fetch_status = 0
				Begin
					
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@Leave_Name)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
					
					Set @val = 'Alter table   #CTCMast Add ' + REPLACE(@AD_NAME_DYN,' ','_') + ' numeric(18,2) default 0 not null'
					
					exec (@val)	
					Set @val = ''
					
					
					Set @Leave_Columns = @Leave_Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
					
					fetch next from Leave_Cursor into @Leave_Name
				End
		close Leave_Cursor	
		deallocate Leave_Cursor
		
		Set @val = 'Alter table  #CTCMast Add Total_Paid_Leave_Days numeric(18,2) default 0'
		exec (@val)	   
			   
		Set @val = 'Alter table  #CTCMast Add Total_Leave_Days numeric(18,2) default 0'
		exec (@val)	   
		
		Set @val = 'Alter table  #CTCMast Add Total_Paid_Days numeric(18,2) default 0' --Added by Mukti(22052018)Sal_Cal_Days
		exec (@val)	   
		
		Set @val = 'Alter table  #CTCMast Add Basic_Salary	numeric(18,2) default 0'
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add Settl_Salary	Numeric(18,2) default 0'
		exec (@val)
		
		Set @val = 'Alter table  #CTCMast Add Gratuity	Numeric(18,2) default 0'
		exec (@val)		
		
		Set @val = 'Alter table  #CTCMast Add Shortfall_Amount_Earning Numeric(18,2) default 0'
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add Leave_Encash_Amount numeric(18,2) default 0 not null'		--Added By Ramiz on 02/06/2016
		exec (@val)
		
		DECLARE Allow_Dedu_Cursor CURSOR FOR
	
		Select AD_NAME from T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK) Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		Where M_AD_Amount <> 0 And T.Cmp_ID = @Company_Id 
				--and T.For_Date between @From_Date and @To_Date  -- Commented by Hardik 19/02/2016
				and Month(T.To_date) = Month(@To_Date) And Year(T.To_date) = Year(@To_Date)
				and (CASE WHEN @Show_Hidden_Allowance = 0  and  A.Hide_In_Reports = 1  and a.AD_NOT_EFFECT_SALARY = 1 THEN 0 else 1 END )=1  --Change By Jaina 11-05-2017
				 /*and T.FOR_FNF = 1*/ and A.AD_Flag = 'I' AND T.M_AD_NOT_EFFECT_SALARY = 0
		Group by AD_NAME 
		OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				Begin
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','_')
					Set @val = 'Alter table   #CTCMast Add ' + REPLACE(@AD_NAME_DYN,' ','_') + ' numeric(18,2) default 0 not null'
					
					exec (@val)	
					Set @val = ''
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
				End
		close Allow_Dedu_Cursor	
		deallocate Allow_Dedu_Cursor
		
		Set @val = 'Alter table  #CTCMast Add Basic_Arrear numeric(18,2) default 0 not null'
		exec (@val)	
		
		Declare Arrear_Earn_Cursor CURSOR FOR
		
		Select AD_NAME from T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK) Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		Where M_AD_Amount <> 0 And T.Cmp_ID = @Company_Id and A.AD_Flag = 'I' AND T.M_AD_NOT_EFFECT_SALARY = 0
				--and T.For_Date between @From_Date and @To_Date  -- Commented by Hardik 19/02/2016
				and Month(T.To_date) = Month(@To_Date) And Year(T.To_date) = Year(@To_Date)
				and M_AREAR_AMOUNT <> 0
		Group by AD_NAME  
		OPEN Arrear_Earn_Cursor
			fetch next from Arrear_Earn_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				Begin
					
				--	Set @AD_NAME_DYN = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')  --comment by hasmukh & add below line 20062014
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
					
					Set @val = 'Alter table   #CTCMast Add ' + REPLACE(@AD_NAME_DYN+'_'+ 'Arrear',' ','_') + ' numeric(18,2) default 0 not null'
					
					exec (@val)	
					Set @val = ''
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN+'_'+'Arrear')),' ','_') + '#'
					
				fetch next from Arrear_Earn_Cursor into @AD_NAME_DYN
				End
	   close Arrear_Earn_Cursor	
	   deallocate Arrear_Earn_Cursor

		--Set @val = 'Alter table  #CTCMast Add Earning_Arear_Amount numeric(18,2) default 0 not null'
		--exec (@val)			
		Set @val = 'Alter table  #CTCMast Add Uniform_Refund_Amount numeric(18,2) default 0 not null'
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add Gross_Salary numeric(18,2) default 0 not null'
		exec (@val)	
	
		Set @val = 'Alter table  #CTCMast Add PT_Amount numeric(18,2) default 0 not null'
		exec (@val)	
	
		Set @val = 'Alter table  #CTCMast Add Loan_Amount numeric(18,2) default 0 not null'
		exec (@val)	

		Set @val = 'Alter table  #CTCMast Add Advance_Amount numeric(18,2) default 0 not null'
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add Uniform_Installment_Amount numeric(18,2) default 0 not null'
		exec (@val)
		--Set @val = 'Alter table  #CTCMast Add OT_Rate numeric(18,2) default 0 not null'
		--exec (@val)	
		
		--Set @val = 'Alter table  #CTCMast Add OT_Hours numeric(18,2) default 0 not null'
		--exec (@val)	
	
		--Set @val = 'Alter table  #CTCMast Add OT_Amount numeric(18,2) default 0 not null'
		--exec (@val)	
		
		Declare Allow_Dedu_Cursor CURSOR FOR
		
		Select AD_NAME from T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK) Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		Where M_AD_Amount <> 0 And T.Cmp_ID = @Company_Id  /*and T.FOR_FNF = 1 */ and A.AD_Flag = 'D' AND T.M_AD_NOT_EFFECT_SALARY = 0
				--and T.For_Date between @From_Date and @To_Date --Commented by Hardik 19/02/2016
				and Month(T.To_date) = Month(@To_Date) And Year(T.To_date) = Year(@To_Date)
		Group by AD_NAME  
		OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				Begin
					
				--	Set @AD_NAME_DYN = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')  --comment by hasmukh & add below line 20062014
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
					
					Set @val = 'Alter table   #CTCMast Add ' + REPLACE(@AD_NAME_DYN,' ','_') + ' numeric(18,2) default 0 not null'
					
					exec (@val)	
					Set @val = ''
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
					
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
				End
	   close Allow_Dedu_Cursor	
	   deallocate Allow_Dedu_Cursor
	
		--Set @val = 'Alter table  #CTCMast Add Deduction_Arear_Amount numeric(18,2) default 0 not null'
		--exec (@val)	
	   	Declare Arrear_Ded_Cursor CURSOR FOR
		
		Select AD_NAME from T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK) Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
		Where M_AD_Amount <> 0 And T.Cmp_ID = @Company_Id and A.AD_Flag = 'D' AND T.M_AD_NOT_EFFECT_SALARY = 0
				--and T.For_Date between @From_Date and @To_Date ---Commented by Hardik 19/02/2016
				and Month(T.To_date) = Month(@To_Date) And Year(T.To_date) = Year(@To_Date)
				and M_AREAR_AMOUNT <> 0
		Group by AD_NAME  
		OPEN Arrear_Ded_Cursor
			fetch next from Arrear_Ded_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				Begin
					
				--	Set @AD_NAME_DYN = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')  --comment by hasmukh & add below line 20062014
					Set @AD_NAME_DYN = Replace(Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@AD_NAME_DYN)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_'),'/','')
					
					Set @val = 'Alter table   #CTCMast Add ' + REPLACE(@AD_NAME_DYN+'_'+ 'Arrear',' ','_') + ' numeric(18,2) default 0 not null'
					
					exec (@val)	
					Set @val = ''
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN+'_'+'Arrear')),' ','_') + '#'
					
				fetch next from Arrear_Ded_Cursor into @AD_NAME_DYN
				End
	   close Arrear_Ded_Cursor	
	   deallocate Arrear_Ded_Cursor
			
		Set @val = 'Alter table  #CTCMast Add Revenue_Amount numeric(18,2) default 0 not null'
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add Shortfall_Amount_Deduction Numeric(18,2) default 0'
		exec (@val)

		Set @val = 'Alter table  #CTCMast Add LWF_Amount numeric(18,2) default 0  not null'
		exec (@val)	

		Set @val = 'Alter table  #CTCMast Add Other_Dedu numeric(18,2) default 0 not null'
		exec (@val)	

		Set @val = 'Alter table  #CTCMast Add Total_Deduction numeric(18,2) default 0 not null'
		exec (@val)	

		Set @val = 'Alter table  #CTCMast Add Net_Amount numeric(18,2) default 0 not null'
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add Round_Value numeric(18,2) default 0 not null'
		exec (@val)	
		
		Set @val = 'Alter table  #CTCMast Add Net_Amount_Payable numeric(18,2) default 0 not null'
		exec (@val)	
		
		
		Declare CTC_UPDATE CURSOR FOR
		select Cmp_Id,Emp_Id,Basic_Salary from #CTCMast
	OPEN CTC_UPDATE
	fetch next from CTC_UPDATE into @CTC_CMP_ID,@CTC_EMP_ID,@CTC_BASIC
	while @@fetch_status = 0
		Begin	
			
		--Hardik for Arear Calculation on 27/07/2012
		Declare @Arear_Basic As Numeric(22,6)
		Declare @Arear_Earn_Amount as Numeric(22,6)
		Declare @Arear_Dedu_Amount as Numeric(22,6)
		Declare @Arear_Net As Numeric(22,6)
		Declare @ShortFall_Amount As Numeric(18,6)
		Declare @ShortFall_Day As Numeric(18,6)
		Declare @Round_vaule As Numeric(18,6)
		Declare @Net_Amt_Payable As Numeric(18,6)
		Declare @Gross_Salary As Numeric(18,6)
		Declare @Is_Terminate As Numeric(18,6)
		Declare @Basic_Arrear As Numeric(18,6)
		Declare @Gratuity As Numeric(18,6)

		Set @Arear_Basic = 0 
		Set @Arear_Earn_Amount = 0
		Set @Arear_Dedu_Amount = 0
		Set @Arear_Net = 0
		Set @Is_Terminate = 0
		SET @Basic_Arrear = 0   --added by Jimit 29072017 as It won't Allow Null to be insert in table
		
		Select @Arear_Earn_Amount = Isnull(SUM(M_Arear_Amount),0) From T0210_MONTHLY_AD_DETAIL  T WITH (NOLOCK) Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
			Where Emp_ID = @CTC_EMP_ID 
			--And For_Date >= @From_Date And To_Date <= @To_Date --Commented by Hardik 19/02/2016
			and Month(T.To_date) = Month(@To_Date) And Year(T.To_date) = Year(@To_Date)
			And M_AD_Flag = 'I' and (isnull(A.Ad_Not_Effect_Salary,0) = 0 )  /*OR ISNULL(T.ReimShow,0) = 1*/

		Select @Arear_Dedu_Amount = Isnull(SUM(M_Arear_Amount),0) From T0210_MONTHLY_AD_DETAIL T WITH (NOLOCK) Inner Join T0050_AD_MASTER A WITH (NOLOCK) on T.AD_ID = A.AD_ID And T.Cmp_ID = A.CMP_ID
			Where Emp_ID = @CTC_EMP_ID 
			--And For_Date >= @From_Date And To_Date <= @To_Date --Commented by Hardik 19/02/2016
			and Month(T.To_date) = Month(@To_Date) And Year(T.To_date) = Year(@To_Date)
			And M_AD_Flag = 'D' and (isnull(A.Ad_Not_Effect_Salary,0) = 0 OR ISNULL(T.ReimShow,0) = 1)
			
		Select @Arear_Basic = Isnull(Arear_Basic,0),@Arear_Month=ISNULL(Arear_Month,0),@Sal_Cal_Days=ISNULL(Sal_Cal_Days,0) From T0200_MONTHLY_SALARY T WITH (NOLOCK)
			Where Emp_ID = @CTC_EMP_ID 
			--And Month_St_Date >= @From_Date And Month_End_Date <= @To_Date --Commented by Hardik 19/02/2016
			and Month(T.Month_End_Date) = Month(@To_Date) And Year(T.Month_End_Date) = Year(@To_Date)
		
		Set @Arear_Net = (@Arear_Basic + @Arear_Earn_Amount)
		
	    select @Basic_Arrear = ISNULL(Arear_Basic,0)
			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =@CTC_EMP_ID
			and  Month(Month_End_Date) = Month(@To_Date) and YEAR(Month_End_Date) = YEAR(@To_Date) and isnull(IS_FNF,0) =1
			
			Set @P_Days =0 
			Set @Basic_Salary =0
			Set @TDS = 0
			Set @Settl  = 0
			Set @OTher_Allow  = 0
			Set @Total_Allowance  = 0
			Set @CO_Amount  = 0
			Set @Total_Deduction  = 0
			Set @PT  = 0
			Set @Loan  = 0
			Set @Advance  = 0	
			Set @Net_Salary  = 0	
			Set @Revenue_Amt  = 0	
			Set @LWF_Amt  = 0	
			Set @Other_Dedu  = 0	

			Set @Absent_Day = 0 
			Set @Holiday_Day = 0
			Set @WeekOff_Day = 0
			Set @Working_Day = 0
						
			
			set @OT_Hours = 0
			set @OT_AMount = 0
			Set @OT_Rate = 0
			set @Fix_OT_Shift_Hours = ''
			Set @Fix_OT_Shift_seconds = 0
			Set @ShortFall_Amount = 0
		    Set @ShortFall_Day = 0
		    Set @Round_vaule = 0
		    Set @Net_Amt_Payable = 0
		    Set @Gross_Salary = 0
		    Set @Gratuity = 0
		    Set @Leave_Salary_Amount = 0
			
			set @Uniform_Installment_Amount = 0
			set @Uniform_Refund_Amount = 0
			
			Declare @CTC_COLUMNS nvarchar(100)
			Declare @CTC_AD_FLAG varchar(1)
			Declare @Allow_Amount numeric(18,2)
			Declare @Arrear_Amount numeric(18,2)
			
			declare @total_paid_leave_cur numeric(18,2)
            set @total_paid_leave_cur = 0
            
         
					select @Fix_OT_Shift_Hours = ot_fix_shift_hours from T0040_GENERAL_SETTING WITH (NOLOCK) where Cmp_ID = @CTC_CMP_ID and Branch_ID = (select Branch_ID from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID =@CTC_EMP_ID and Cmp_ID = @CTC_CMP_ID)
					 select @Fix_OT_Shift_seconds = dbo.F_Return_Sec(isnull(@Fix_OT_Shift_Hours,'00:00')) 
				
						SELECT @Is_Terminate = LE.Is_Terminate
                        from T0080_EMP_MASTER e	WITH (NOLOCK) inner join @Emp_Cons ec on e.Emp_ID = ec.Emp_ID INNER JOIN 
	                    T0100_LEFT_EMP LE WITH (NOLOCK) ON E.EMP_ID = LE.EMP_ID where e.Emp_ID = @CTC_EMP_ID
	                    
							
						if abs(datediff(m,@To_Date,@from_date)) > 1
						begin
							select @Basic_Salary = sum(Salary_Amount),@P_Days=sum(Present_Days),@Absent_Day=sum(Absent_Days),@Holiday_Day=sum(Holiday_Days),@WeekOff_Day=sum(Weekoff_Days)
							,@Working_Day=sum(Working_Days),@TDS=sum(isnull(M_IT_TAX,0)),
							@Settl = sum(Isnull(Settelement_Amount,0))
							,@OTher_Allow = sum(ISNULL(Allow_Amount,0)),
							@Total_Allowance = sum(Isnull(Allow_Amount,0))
							,@OT_Hours = sum(isnull(OT_Hours,0)),@OT_Amount=sum(isnull(OT_Amount,0)) ,
							@OT_Rate = 0
							,@total_paid_leave_cur = sum(isnull((Paid_Leave_Days + OD_Leave_Days),0))
							,@ShortFall_Amount = sum(ISNULL(Short_Fall_Dedu_Amount,0))
		                    ,@ShortFall_Day =  sum(ISNULL(Short_Fall_Days,0))
		                    ,@Gratuity = SUM(isnull(Gratuity_Amount,0))
		                    ,@Gross_Salary = Sum(ISNULL(Gross_Salary,0))
		                    ,@Leave_Salary_Amount =  SUM(isnull(Leave_Salary_Amount,0))
							from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @CTC_EMP_ID 
							--and Month_st_date between @From_Date and @To_Date --Commented by Hardik 19/02/2016
							and Month(Month_End_Date) = Month(@To_Date) And Year(Month_End_Date) = Year(@To_Date)
							group by Emp_ID
						end
					else
						begin
							select @Basic_Salary = sum(Salary_Amount),@P_Days=sum(Present_Days),@Absent_Day=sum(Absent_Days),@Holiday_Day=sum(Holiday_Days),@WeekOff_Day=sum(Weekoff_Days)
							
							,@Working_Day=sum(Working_Days),@TDS=sum(isnull(M_IT_TAX,0)),
							@Settl = sum(Isnull(Settelement_Amount,0))
							,@OTher_Allow = sum(ISNULL(Allow_Amount,0)),
							@Total_Allowance = sum(Isnull(Allow_Amount,0))
							,@OT_Hours = sum(isnull(OT_Hours,0)),@OT_Amount=sum(isnull(OT_Amount,0)) ,
							@OT_Rate = case when isnull(@Fix_OT_Shift_seconds,0) = 0 then Hour_Salary else isnull(Day_Salary,0)* 3600/@Fix_OT_Shift_seconds end
							,@total_paid_leave_cur = sum(isnull((Paid_Leave_Days + OD_Leave_Days),0))
							,@ShortFall_Amount = sum(ISNULL(Short_Fall_Dedu_Amount,0))
		                    , @ShortFall_Day =  sum(ISNULL(Short_Fall_Days,0))
		                    ,@Gratuity = SUM(isnull(Gratuity_Amount,0))
		                    ,@Gross_Salary = Sum(Gross_Salary)
		                     ,@Leave_Salary_Amount =  SUM(isnull(Leave_Salary_Amount,0))
							from T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @CTC_EMP_ID
							--and Month_st_date between @From_Date and @To_Date --Commented by Hardik 19/02/2016
							and Month(Month_End_Date) = Month(@To_Date) And Year(Month_End_Date) = Year(@To_Date)
							group by Emp_ID,Hour_Salary,Day_Salary
						end
					
					select @Total_Deduction = sum(Total_Dedu_Amount) ,@PT = sum(PT_Amount) ,@Loan =  sum(( Loan_Amount + Loan_Intrest_Amount ) )
							,@Advance =  sum(Isnull(Advance_Amount,0)) ,@Net_Salary = sum(Net_Amount) ,@Revenue_Amt = sum(Isnull(Revenue_amount,0)),@LWF_Amt =sum(Isnull(LWF_Amount,0)),@Other_Dedu= sum(Isnull(Other_Dedu_Amount,0)) + Sum(Isnull(Late_Dedu_Amount,0))
							,@Arear_Days = Sum(Isnull(Arear_Day,0))
							,@Round_vaule = sum(ISNULL(Net_Salary_Round_Diff_Amount,0))
		                    ,@Net_Amt_Payable =  sum(Net_Amount)  + sum(ISNULL(Net_Salary_Round_Diff_Amount,0))
		                    ,@Uniform_Installment_Amount=sum(isnull(Uniform_Dedu_Amount,0)),@Uniform_Refund_Amount=sum(ISNULL(Uniform_Refund_Amount,0)) --Mukti(20062017)		                   
					from T0200_Monthly_salary WITH (NOLOCK) where Emp_ID = @CTC_EMP_ID 
							--and Month_st_date between @From_Date and @To_Date --Commented by Hardik 19/02/2016
							and Month(Month_End_Date) = Month(@To_Date) And Year(Month_End_Date) = Year(@To_Date)
							group by Emp_ID
							
									
					update  #CTCMast set Basic_Salary = @Basic_Salary,Present_Day=Present_Day + @P_Days, Absent_Day= Absent_Day + @Absent_Day,Holiday_Day= Holiday_Day + @Holiday_Day,WeekOff_Day=WeekOff_Day + @WeekOff_Day
					    
					    ,working_day=working_day + @Working_Day,Settl_Salary = @Settl,
						--Other_Allow = Other_Allow + @OTher_Allow, 
						--Gross_Salary =  CASE when @Is_Terminate = 1 then Gross_Salary + (@Total_Allowance+isnull(@Settl,0)+isnull(@CO_Amount,0)+isnull(@ShortFall_Amount,0)+ISNULL(@Basic_Salary,0) + ISNULL(@Arear_Net,0) + ISNULL(@Gratuity,0))
						--					ELSE Gross_Salary + (@Total_Allowance+isnull(@Settl,0)+isnull(@CO_Amount,0)+ISNULL(@Basic_Salary,0) + ISNULL(@Arear_Net,0) + ISNULL(@Gratuity,0) ) End,
						Gross_Salary =  @Gross_Salary,
						Total_Deduction = Total_Deduction + @Total_Deduction, PT_Amount = PT_Amount + @PT,
						Loan_Amount = Loan_Amount +  @Loan, Advance_Amount = Advance_Amount + @Advance, Revenue_Amount = Revenue_Amount + @Revenue_Amt, LWF_Amount =LWF_Amount + @LWF_Amt,
						Other_Dedu =Other_Dedu + @Other_Dedu, Net_Amount =Net_Amount + @Net_Salary--,Total_Allowance = @Total_Allowance
						,Arear_Day = @Arear_Days
						--, Earning_Arear_Amount = @Arear_Net
						--,Deduction_Arear_Amount = @Arear_Dedu_Amount
						--,OT_Hours=@OT_Hours,OT_Amount=@OT_Amount,OT_Rate=@OT_Rate
						,Shortfall_Amount_Earning = case when @Is_Terminate = 1 then @ShortFall_Amount ELSE 0 end
						,Shortfall_Amount_Deduction = case when @Is_Terminate = 0 then @ShortFall_Amount ELSE 0 end
						,Gratuity = @Gratuity
						,Shortfall_Days = @ShortFall_Day
						,Round_Value = @Round_vaule
						,Net_Amount_Payable = @Net_Amt_Payable
						,Basic_Arrear = @Basic_Arrear
						,Leave_Encash_Amount = @Leave_Salary_Amount   --Added By Ramiz on 02/06/2016
						,Uniform_Installment_Amount=@Uniform_Installment_Amount
						,Uniform_Refund_Amount=@Uniform_Refund_Amount
						,Arear_Month=@Arear_Month
						,TOTAL_PAID_DAYS=@Sal_Cal_Days
					where #CTCMast.Cmp_ID = @CTC_CMP_ID and #CTCMast.Emp_ID = @CTC_EMP_ID
					
					
					Declare CRU_COLUMNS CURSOR FOR
						Select data from Split(@Columns,'#') where data <> ''
					OPEN CRU_COLUMNS
							fetch next from CRU_COLUMNS into @CTC_COLUMNS
							while @@fetch_status = 0
								Begin					
										begin
												Set @CTC_COLUMNS = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@CTC_COLUMNS)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
																						
												begin
														
													select @Allow_Amount=sum(ded.M_AD_Amount),@CTC_AD_FLAG=ded.M_AD_Flag from T0210_MONTHLY_AD_DETAIL  ded WITH (NOLOCK)
														inner join T0050_AD_MASTER ad WITH (NOLOCK) on ded.AD_Id = ad.AD_Id
														WHere  Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(ad.AD_NAME)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')  = @CTC_COLUMNS 
														and ded.CMP_ID = @CTC_CMP_ID and ded.EMP_ID = @CTC_EMP_ID
														and ded.For_Date between @From_Date and @To_Date /*and ded.FOR_FNF = 1 */ AND ded.M_AD_NOT_EFFECT_SALARY = 0
														group by ded.M_AD_Flag , ded.EMP_ID , ded.AD_Id
													
													Set @val = 	'update  #CTCMast set ' + @CTC_COLUMNS + ' = ' + @CTC_COLUMNS + ' + ' + convert(nvarchar,isnull(@Allow_Amount,0)) + ' where #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)
													EXEC (@val)		
													
																   
												end
												
												Set @Allow_Amount = 0
												
										end
										
									fetch next from CRU_COLUMNS into @CTC_COLUMNS
								End
					close CRU_COLUMNS	
					deallocate CRU_COLUMNS
					
					
					Declare Arrear_COLUMNS CURSOR FOR
						Select data from Split(@Columns,'#') where data <> ''
					OPEN Arrear_COLUMNS
							fetch next from Arrear_COLUMNS into @CTC_COLUMNS
							while @@fetch_status = 0
								Begin					
										begin
												Set @CTC_COLUMNS = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(@CTC_COLUMNS)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
																						
												begin
														
													select @Arrear_Amount=sum(ded.M_AREAR_AMOUNT),@CTC_AD_FLAG=ded.M_AD_Flag from T0210_MONTHLY_AD_DETAIL  ded WITH (NOLOCK)
														inner join T0050_AD_MASTER ad WITH (NOLOCK) on ded.AD_Id = ad.AD_Id
														WHere  Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(Replace(Replace(Replace(Replace(ltrim(rtrim(ad.AD_NAME)),'+','_'),'''','_'),',','_'),'.','_'),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')+'_'+'Arrear'  = @CTC_COLUMNS 
														and ded.CMP_ID = @CTC_CMP_ID and ded.EMP_ID = @CTC_EMP_ID /*and ded.M_AD_Flag = 'I'*/
														and ded.For_Date between @From_Date and @To_Date /*and ded.FOR_FNF = 1 */ AND ded.M_AD_NOT_EFFECT_SALARY = 0 and ded.M_AREAR_AMOUNT<> 0
														group by ded.M_AD_Flag , ded.EMP_ID , ded.AD_Id
													
													Set @val = 	'update  #CTCMast set ' + @CTC_COLUMNS  + ' = ' + @CTC_COLUMNS + ' + ' + convert(nvarchar,isnull(@Arrear_Amount,0)) + ' where #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)
													EXEC (@val)		
																   
												end
												
												Set @Arrear_Amount = 0
												
										end
										
									fetch next from Arrear_COLUMNS into @CTC_COLUMNS
								End
					close Arrear_COLUMNS	
					deallocate Arrear_COLUMNS
					
					
					
					Set @val = 	'update  #CTCMast set Total_Paid_Leave_Days  = ' + convert(nvarchar,isnull(@total_paid_leave_cur,0)) + ' where #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)																														
										
		exec (@val)
				
		declare @leave_total numeric(18,2)		
		declare @leave_name_temp nvarchar(100)	
		
		
		
		set @count_leave = 0
		DECLARE Leave_Cursor CURSOR FOR
			Select data from Split(@Leave_Columns,'#') where data <> ''
		OPEN Leave_Cursor
			fetch next from Leave_Cursor into @Leave_Name
				while @@fetch_status = 0
					Begin
						
						set @leave_total = 0
						
						select @leave_total = SUM(isnull(lt.Leave_Used,0)) from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) inner join
						T0040_LEAVE_MASTER LM WITH (NOLOCK) on LM.Leave_ID = LT.Leave_ID 
						where LM.cmp_ID=@Company_id  and LT.For_Date  >=@From_Date and LT.For_Date  <=@To_Date and REPLACE(rtrim(ltrim(Leave_Name)),' ','_') = @Leave_Name
								and LT.emp_id = @CTC_EMP_ID
						group by Leave_Name
										
						
						Set @val = 'update #CTCMast set ' + @Leave_Name + ' = ' +  convert(nvarchar,@leave_total) + ' Where emp_id = ' + convert(nvarchar,@CTC_EMP_ID )
						EXEC (@val)
						
					
						
						set @count_leave = @count_leave + @leave_total
						
						fetch next from Leave_Cursor into @Leave_Name
					End
		close Leave_Cursor
		deallocate Leave_Cursor
						
		Set @val = 'update #CTCMast set Total_Leave_Days = ' +  convert(nvarchar,isnull(@count_leave,0)) + ' Where emp_id = ' + convert(nvarchar,@CTC_EMP_ID )
		EXEC (@val)
					
	
	fetch next from CTC_UPDATE into @CTC_CMP_ID,@CTC_EMP_ID,@CTC_BASIC
				End
	close CTC_UPDATE	
	deallocate CTC_UPDATE
	
	
	Select CM.* from #CTCMast CM
	inner join t0080_emp_master em WITH (NOLOCK) on cm.emp_id = em.emp_id
	--inner join t0095_increment Inc WITH (NOLOCK) on em.increment_id = inc.increment_id -- Commented by Hardik 26/02/2021 for Vivo Raj Redmine case #16840
	--Order by CM.Emp_code
	ORDER BY CASE WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(Cm.Enroll_No AS VARCHAR), 21)  --Added by Jaina 31 July 2015 start
							WHEN @Order_By='Name' THEN CM.Emp_Full_Name
							When @Order_By = 'Designation' then (CASE WHEN CM.Desig_dis_No  = 0 THEN CM.Designation ELSE RIGHT(REPLICATE('0',21) + CAST(CM.Desig_dis_No AS VARCHAR), 21)   END)   
							--ELSE RIGHT(REPLICATE(N' ', 500) + CM.Alpha_Emp_Code, 500) 
						End,Case When IsNumeric(Replace(Replace(CM.Alpha_Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(CM.Alpha_Emp_Code,'="',''),'"',''), 20)
								 When IsNumeric(Replace(Replace(CM.Alpha_Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(CM.Alpha_Emp_Code,'="',''),'"','') + Replicate('',21), 20)
								 Else Replace(Replace(CM.Alpha_Emp_Code,'="',''),'"','') End 
						--RIGHT(REPLICATE(N' ', 500) + CM.Alpha_Emp_Code, 500) 
Return




