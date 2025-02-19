


---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Rpt_Payment_Register_Export]  
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
	,@Summary varchar(max)=''
	,@Order_By varchar(50) ='Code'
	,@process_type_id varchar(max) =''
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

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
	Declare @Sal_Cal_Day numeric(18,2)
	Declare @OT_Hours numeric(18,2)
	Declare @OT_Amount numeric(18,2)
	Declare @OT_Rate Numeric(18,2)
	declare @Fix_OT_Shift_Hours varchar(40)
	declare @Fix_OT_Shift_seconds numeric(18,2)
    Declare @Net_Round As Numeric(22,2)
   
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
			Insert Into @Emp_Cons
			select CAST(DATA  AS NUMERIC),CAST(DATA  AS NUMERIC),CAST(DATA  AS NUMERIC) from dbo.Split (@Constraint,'#') 
		end
	else
		begin
		
		
		INSERT INTO @Emp_Cons

			SELECT DISTINCT V.emp_id,branch_id,V.Increment_ID FROM V_Emp_Cons V 
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
	   ,Department		nvarchar(100)
	   ,Designation		nvarchar(100)
	   ,Grade			nvarchar(100)
	   ,TypeName		nvarchar(100)
	   ,Cat_Name		nvarchar(100)
	   ,Division		nvarchar(100)
	   ,sub_vertical	nvarchar(100)
	   ,sub_branch		nvarchar(100)	   
	   ,Branch_Id       Numeric(18,0)
	   ,Bank_Ac_No		Varchar(50)
	   ,Pan_No			Varchar(50)
	   ,Segment_Name	nvarchar(100)
	   ,Center_Code     Varchar(50)
	)
	
	Declare @Columns nvarchar(4000)
	Declare @Leave_Columns nvarchar(Max)
	Declare @Leave_Name nvarchar(30)
	set @Leave_Columns = ''
	Set @Columns = '#'
	declare @count_leave as numeric(18,2)
	set @count_leave = 0
	
	declare @String as varchar(max)
	set @string=''
	
	Insert Into #CTCMast 
	SELECT e.Cmp_ID,e.Emp_ID,e.Emp_code,e.Alpha_Emp_Code,
		ISNULL(e.EmpName_Alias_Salary,e.Emp_Full_Name)
		,bm.Branch_Name,dm.Dept_Name,dnm.Desig_Name,ga.Grd_Name,tm.Type_Name,CT.Cat_Name,VT.Vertical_Name,ST.SubVertical_Name,SB.SubBranch_Name,
		 BM.Branch_ID, 
		Case Upper(Payment_Mode) When 'BANK TRANSFER' THEN 'BANK TRANSFER'
		When 'CASH' Then 'CASH' Else 'CHEQUE' End Bank_Ac_No,Pan_No,BSG.Segment_Name
		,CC.Center_Code 
		from T0080_EMP_MASTER e	WITH (NOLOCK) inner join
		( select I.Emp_id,I.Basic_Salary,I.CTC,I.Inc_Bank_AC_No,Payment_Mode,I.Branch_ID,I.Grd_ID,I.Dept_ID,I.Desig_Id,I.Type_ID,I.Cat_ID,I.Vertical_ID,I.SubVertical_ID,I.subBranch_ID,I.Segment_ID,I.Center_ID from T0095_Increment I WITH (NOLOCK) inner join 
			( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment  WITH (NOLOCK)
			where Increment_Effective_date <= @To_Date
			and cmp_id = @Company_id
			group by emp_ID  ) Qry on
			I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id )Inc_Qry on 
		E.Emp_ID = Inc_Qry.Emp_ID 
	inner join @Emp_Cons ec on e.Emp_ID = ec.Emp_ID
	left outer join T0030_BRANCH_MASTER bm WITH (NOLOCK) on Inc_Qry.Branch_ID = bm.Branch_ID
	left outer join T0040_GRADE_MASTER ga WITH (NOLOCK) on Inc_Qry.Grd_ID = ga.Grd_ID
	left outer join T0040_DEPARTMENT_MASTER dm WITH (NOLOCK) on Inc_Qry.Dept_ID = dm.Dept_Id
	left outer join T0040_DESIGNATION_MASTER dnm WITH (NOLOCK) on Inc_Qry.Desig_Id = dnm.Desig_ID
	left outer join T0040_TYPE_MASTER tm WITH (NOLOCK) on Inc_Qry.Type_ID = tm.Type_ID
	left outer join T0030_CATEGORY_MASTER CT WITH (NOLOCK) on CT.Cat_ID=Inc_Qry.Cat_Id
	left outer join T0040_Vertical_Segment VT WITH (NOLOCK) on VT.Vertical_ID=Inc_Qry.Vertical_ID
	left outer join T0050_SubVertical ST WITH (NOLOCK) on ST.SubVertical_ID=Inc_Qry.SubVertical_ID
	left outer join T0050_SubBranch SB WITH (NOLOCK) on SB.SubBranch_ID=Inc_Qry.subBranch_ID 
	left outer join T0040_Business_Segment BSG WITH (NOLOCK) on BSG.Segment_ID=Inc_Qry.Segment_ID
	left outer join T0040_Cost_Center_Master CC WITH (NOLOCK) on CC.Center_ID = Inc_Qry.Center_ID
	
	inner join (select distinct Emp_id from ( select (9000 +tran_id) as tran_id ,Payment_Process_name ,99999 as sort_id from T0301_Payment_Process_Type WITH (NOLOCK) where is_active=1  and Payment_Process_name <> 'Allowance'
				union 
				select distinct cast(PTM.Process_Type_Id as varchar(10)) as tran_id,PTM.Process_Type,PTM.Sort_id  from T0301_Process_Type_Master PTM WITH (NOLOCK)
				where PTM.cmp_id=@Company_Id 
				) ASP 
				inner join monthly_emp_bank_payment MS WITH (NOLOCK) on 
				--ASP.tran_id = ms.process_type_id and 
				for_date>=@From_Date and for_date<= @to_date and ASp.Payment_Process_name = Ms.Process_Type
			 where  1 = ( case when @process_type_id <> '' and Tran_id in( select CAST(DATA  AS NUMERIC) from dbo.Split (@process_type_id,',') ) then 1 when  @process_type_id = '' then 1 else 0 end ) ) MSP on ec.Emp_ID= MSP.emp_id
	
		
	
	Declare @CTC_CMP_ID numeric(18,0)
	Declare @CTC_EMP_ID numeric(18,0)
	Declare @CTC_BASIC numeric(18,2)

	
	Declare @AD_NAME_DYN nvarchar(100)
	declare @val nvarchar(500)
	Declare @tran_id numeric(18,0)
	

	Declare @AD_LEVEL Numeric
	set @AD_LEVEL = 0
	declare @Ad_name_multi as varchar(max)
	declare @Loan_name_multi as varchar(max)
	declare @Leave_name_multi as varchar(max)

	
	DECLARE Allow_Dedu_Cursor CURSOR FOR
			select tran_id ,payment_process_name ,sort_id from  ( select (9000 + tran_id ) as tran_id ,Payment_Process_name ,99999 as sort_id from T0301_Payment_Process_Type WITH (NOLOCK) where is_active=1  and Payment_Process_name <> 'Allowance'
			union 
			select distinct cast(PTM.Process_Type_Id as varchar(10)) as tran_id,PTM.Process_Type,PTM.Sort_id  from T0301_Process_Type_Master PTM WITH (NOLOCK)
			inner join monthly_emp_bank_payment MS WITH (NOLOCK) on PTM.process_type_id = ms.process_type_id and for_date>=@From_Date and for_date<= @to_date
			where PTM.cmp_id=@Company_Id 
			 ) ASP 
			 where  1 = ( case when @process_type_id <> '' and Tran_id in( select CAST(DATA  AS NUMERIC) from dbo.Split (@process_type_id,',') ) then 1 when  @process_type_id = '' then 1 else 0 end ) 
			 order by sort_id
		
		OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @tran_id,@AD_NAME_DYN,@AD_LEVEL
			while @@fetch_status = 0
				Begin
					
					if @tran_id <9000
					begin 
					
					DECLARE Allow_Dedu CURSOR FOR
					
					select CAST(DATA  AS varchar(500)) from dbo.Split((select Ad_name_multi from T0301_Process_Type_Master WITH (NOLOCK) where process_type_id = @tran_id),'#') where isnull(data ,'')<>''
		
					OPEN Allow_Dedu
						fetch next from Allow_Dedu into @Ad_name_multi
						while @@fetch_status = 0
							Begin
							
								Set @Ad_name_multi = '[' + @Ad_name_multi + ']'
							
								Set @val = 'Alter table   #CTCMast Add ' + @Ad_name_multi + ' numeric(18,2) default 0 not null'
								exec (@val)
									
								Set @val = ''
							Set @Columns = @Columns + @Ad_name_multi + '#'	
							
							
							fetch next from Allow_Dedu into @Ad_name_multi
							End
							close Allow_Dedu
							deallocate Allow_Dedu

						-- Added by rohit  fro Loan and leave on 06012016
						DECLARE Cur_Loan CURSOR FOR

						select CAST(DATA  AS varchar(500)) from dbo.Split((select Loan_name_multi from T0301_Process_Type_Master WITH (NOLOCK) where process_type_id = @tran_id),'#') where isnull(data ,'')<>''

						OPEN Cur_Loan
						fetch next from Cur_Loan into @Loan_name_multi
						while @@fetch_status = 0
							Begin
							
								Set @Loan_name_multi = '[' + @Loan_name_multi + ']'
							
								Set @val = 'Alter table   #CTCMast Add ' + @Loan_name_multi + ' numeric(18,2) default 0 not null'
								exec (@val)
									
								Set @val = ''
							Set @Columns = @Columns + @Loan_name_multi + '#'	
							
							
							fetch next from Cur_Loan into @Loan_name_multi
							End
							close Cur_Loan
							deallocate Cur_Loan		

							DECLARE Cur_Leave CURSOR FOR

							select CAST(DATA  AS varchar(500)) from dbo.Split((select Leave_name_multi from T0301_Process_Type_Master WITH (NOLOCK) where process_type_id = @tran_id),'#') where isnull(data ,'')<>''
							
							OPEN Cur_Leave
							fetch next from Cur_Leave into @Leave_name_multi
							while @@fetch_status = 0
								Begin
								
									Set @Leave_name_multi = '[' + @Leave_name_multi + ']'
								
									Set @val = 'Alter table   #CTCMast Add ' + @Leave_name_multi + ' numeric(18,2) default 0 not null'
									exec (@val)
										
									Set @val = ''
								Set @Columns = @Columns + @Leave_name_multi + '#'	
								
								
								fetch next from Cur_Leave into @Leave_name_multi
								End
								close Cur_Leave
								deallocate Cur_Leave
								
								-- Ended by rohit on 06012016

					-- Commenetd by rohit as per instruct by maitry on 10122015
						--Set @AD_NAME_DYN = '[' + @AD_NAME_DYN + ']'
						--Set @val = 'Alter table   #CTCMast Add ' + @AD_NAME_DYN + ' numeric(18,2) default 0 not null'
						--exec (@val)	
						--Set @val = ''
						--Set @Columns = @Columns +  @AD_NAME_DYN + '#'
					end
					
					else
					begin
						
						Set @AD_NAME_DYN =  '[' + @AD_NAME_DYN + ']'
						
						Set @val = 'Alter table   #CTCMast Add ' + @AD_NAME_DYN + ' numeric(18,2) default 0 not null'
						exec (@val)	
						Set @val = ''
						
						Set @Columns = @Columns +  @AD_NAME_DYN + '#'
					end
					
				fetch next from Allow_Dedu_Cursor into @tran_id,@AD_NAME_DYN,@AD_LEVEL
				End
		close Allow_Dedu_Cursor	
		deallocate Allow_Dedu_Cursor

	declare @sum_of_allownaces_deduct as varchar(Max)
	set @sum_of_allownaces_deduct=''
	SET @AD_LEVEL = 0
	
	
		Set @val = 'Alter table   #CTCMast Add [Net Payable] numeric(18,2) default 0 not null'
		exec (@val)	
		Set @val = ''

		DECLARE @AD_NAME_DYN_CTC nvarchar(100)
		DECLARE @Sum_Of_Allownaces_Earning_CTC as varchar(Max)
		DECLARE @Sum_Of_Allownaces_Earning_CTC_Total as varchar(Max)
		
		SET @AD_NAME_DYN_CTC = ''
		SET @Sum_Of_Allownaces_Earning_CTC = ''
		SET @Sum_Of_Allownaces_Earning_CTC_Total = ''
		
		Declare @Net_payble Numeric(18,2)
		set @Net_payble=0
			
	Declare CTC_UPDATE CURSOR FOR
		select Cmp_Id,Emp_Id from #CTCMast
	OPEN CTC_UPDATE
	fetch next from CTC_UPDATE into @CTC_CMP_ID,@CTC_EMP_ID
	while @@fetch_status = 0
		Begin	
			
	
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
		    Set @Sal_Cal_Day = 0
			set @Net_Round = 0
			
			set @OT_Hours = 0
			set @OT_AMount = 0
			Set @OT_Rate = 0
			set @Fix_OT_Shift_Hours = ''
			Set @Fix_OT_Shift_seconds = 0
			
			Declare @CTC_COLUMNS nvarchar(100)
			Declare @CTC_AD_FLAG varchar(1)
			Declare @Allow_Amount numeric(18,2)
			
					Declare CRU_COLUMNS CURSOR FOR
						Select data from Split(@Columns,'#') where data <> ''
					OPEN CRU_COLUMNS
							fetch next from CRU_COLUMNS into @CTC_COLUMNS
							while @@fetch_status = 0
								Begin					
										begin
												begin
												
												if exists(select 1 	from T0302_Process_Detail  ded WITH (NOLOCK)
														inner join T0050_AD_MASTER ad WITH (NOLOCK) on ded.AD_Id = ad.AD_Id
														WHere  
														'[' + ad.Ad_Name + ']' = @CTC_COLUMNS 
														and ded.CMP_ID = @CTC_CMP_ID and ded.EMP_ID = @CTC_EMP_ID
														and ded.For_Date >= @From_Date and ded.For_Date <= @To_Date
														and payment_process_id > 0 )
												begin	
													
													select @Allow_Amount=Sum(Net_Amount)
													from T0302_Process_Detail  ded WITH (NOLOCK)
														inner join T0050_AD_MASTER ad WITH (NOLOCK) on ded.AD_Id = ad.AD_Id
														WHere  
														'[' + ad.Ad_Name + ']' = @CTC_COLUMNS 
														and ded.CMP_ID = @CTC_CMP_ID and ded.EMP_ID = @CTC_EMP_ID
														and ded.For_Date >= @From_Date and ded.For_Date <= @To_Date
														and payment_process_id > 0
													
													Set @val = 	'update  #CTCMast set ' + @CTC_COLUMNS + ' = '  + convert(nvarchar,isnull(@Allow_Amount,0)) + ' where #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)
													EXEC (@val)	
													set @val =''
													set @Net_payble = isnull(@Net_payble,0) + isnull(@Allow_Amount,0)
													
												end	
												else if exists(select 1 	from T0302_Process_Detail  ded WITH (NOLOCK)
														inner join T0040_LOAN_MASTER ad WITH (NOLOCK) on ded.Loan_Id = ad.Loan_id
														WHere  
														'[' + ad.Loan_Name + ']' = @CTC_COLUMNS 
														and ded.CMP_ID = @CTC_CMP_ID and ded.EMP_ID = @CTC_EMP_ID
														and ded.For_Date >= @From_Date and ded.For_Date <= @To_Date
														and payment_process_id > 0 )
												begin	
													
													select @Allow_Amount=Sum(Net_Amount)
													from T0302_Process_Detail  ded WITH (NOLOCK)
														inner join T0040_LOAN_MASTER ad WITH (NOLOCK) on ded.Loan_id = ad.Loan_Id
														WHere  
														'[' + ad.Loan_Name + ']' = @CTC_COLUMNS 
														and ded.CMP_ID = @CTC_CMP_ID and ded.EMP_ID = @CTC_EMP_ID
														and ded.For_Date >= @From_Date and ded.For_Date <= @To_Date
														and payment_process_id > 0
													
													Set @val = 	'update  #CTCMast set ' + @CTC_COLUMNS + ' = '  + convert(nvarchar,isnull(@Allow_Amount,0)) + ' where #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)
													EXEC (@val)	
													set @val =''
													set @Net_payble = isnull(@Net_payble,0) + isnull(@Allow_Amount,0)
													
												end	
												else if exists(select 1 from T0302_Process_Detail  ded WITH (NOLOCK)
														inner join T0040_LEAVE_MASTER ad WITH (NOLOCK) on ded.Leave_Id = ad.Leave_Id
														WHere  
														'[' + ad.Leave_Name + ']' = @CTC_COLUMNS 
														and ded.CMP_ID = @CTC_CMP_ID and ded.EMP_ID = @CTC_EMP_ID
														and ded.For_Date >= @From_Date and ded.For_Date <= @To_Date
														and payment_process_id > 0 )
												begin	
													
													select @Allow_Amount=Sum(Net_Amount)
													from T0302_Process_Detail  ded WITH (NOLOCK)
														inner join T0040_LEAVE_MASTER ad WITH (NOLOCK) on ded.leave_id = ad.leave_id
														WHere  
														'[' + ad.Leave_Name + ']' = @CTC_COLUMNS 
														and ded.CMP_ID = @CTC_CMP_ID and ded.EMP_ID = @CTC_EMP_ID
														and ded.For_Date >= @From_Date and ded.For_Date <= @To_Date
														and payment_process_id > 0
													
													Set @val = 	'update  #CTCMast set ' + @CTC_COLUMNS + ' = '  + convert(nvarchar,isnull(@Allow_Amount,0)) + ' where #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)
													EXEC (@val)	
													set @val =''
													set @Net_payble = isnull(@Net_payble,0) + isnull(@Allow_Amount,0)
													
												end	
												else
												begin	
													select @Allow_Amount=sum(Net_Amount) 
													from MONTHLY_EMP_BANK_PAYMENT  ded
														WHere  
														'[' + ded.process_type + ']' = @CTC_COLUMNS 
														and ded.CMP_ID = @CTC_CMP_ID and ded.EMP_ID = @CTC_EMP_ID
														and ded.For_Date >= @From_Date and ded.For_date <= @To_Date
													
													
														
													set @Net_payble = isnull(@Net_payble,0) + isnull(@Allow_Amount,0)
													Set @val = 	'update  #CTCMast set ' + @CTC_COLUMNS + ' = ' + convert(nvarchar,isnull(@Allow_Amount,0)) + ' where #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)
													EXEC (@val)
													set @val =''		
												end	
												end
												Set @Allow_Amount = 0
												
										end
										
									fetch next from CRU_COLUMNS into @CTC_COLUMNS
								End
					close CRU_COLUMNS	
					deallocate CRU_COLUMNS
					
					Set @val = 	'update  #CTCMast set [Net Payable] = ' + convert(nvarchar,isnull(@Net_payble,0)) + ' where #CTCMast.Cmp_ID = ' + convert(nvarchar,@CTC_CMP_ID) + ' and #CTCMast.Emp_ID = ' + convert(nvarchar,@CTC_EMP_ID)
					EXEC (@val)		
					set @val =''
					set @Net_payble=0
	fetch next from CTC_UPDATE into @CTC_CMP_ID,@CTC_EMP_ID
				End
	close CTC_UPDATE	
	deallocate CTC_UPDATE
	
	Update #CTCMast set Alpha_Emp_Code = '="' + Alpha_Emp_Code + '"'    
	  
	Select CM.*, '="' + inc.inc_bank_ac_No + '"' as inc_bank_ac_No from #CTCMast CM
	inner join t0080_emp_master em WITH (NOLOCK) on cm.emp_id = em.emp_id
	inner join t0095_increment Inc WITH (NOLOCK) on em.increment_id = inc.increment_id	
	Order by CM.Emp_code
	
Return

