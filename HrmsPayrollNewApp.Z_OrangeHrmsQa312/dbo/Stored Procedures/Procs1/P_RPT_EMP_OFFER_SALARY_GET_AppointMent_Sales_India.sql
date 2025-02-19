
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_RPT_EMP_OFFER_SALARY_GET_AppointMent_Sales_India]
		
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric   = 0
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(5000) = ''
	,@Letter		varchar(30)='Offer'
    ,@PBranch_ID varchar(200) = '0'
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
 declare @Year_End_Date as datetime  
 Declare @User_type varchar(30)  
   
 
 	IF @Branch_ID = 0  
		set @Branch_ID = null   
	 If @Grd_ID = 0  
		 set @Grd_ID = null  
	 If @Emp_ID = 0  
		set @Emp_ID = null  
	 If @Desig_ID = 0  
		set @Desig_ID = null  
     If @Dept_ID = 0  
		set @Dept_ID = null 
 
    
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
			if @PBranch_ID <> '0' and isnull(@Branch_ID,0) = 0
		   Begin
			Insert Into @Emp_Cons
               
				select I.Emp_Id from dbo.T0095_INCREMENT I WITH (NOLOCK) inner join 
						( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_INCREMENT WITH (NOLOCK)
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	 Inner join
						dbo.T0080_EMP_MASTER E WITH (NOLOCK) on i.emp_ID = E.Emp_ID
					Where E.CMP_ID = @Cmp_ID 
					--and i.BRANCH_ID = isnull(@BRANCH_ID ,i.BRANCH_ID)
					and i.Branch_ID in (select cast(isnull(data,0) as numeric) from dbo.Split(@PBranch_ID,'#'))
					and i.Grd_ID = isnull(@Grd_ID ,i.Grd_ID)
					and isnull(i.Dept_ID,0) = isnull(@Dept_ID ,isnull(i.Dept_ID,0))			
					and Isnull(i.Desig_ID,0) = isnull(@Desig_ID ,Isnull(i.Desig_ID,0))			
					and ISNULL(I.Emp_ID,0) = isnull(@Emp_ID ,ISNULL(I.Emp_ID,0))
					and Date_Of_Join <= @To_Date and I.emp_id in(
						select e.Emp_Id from
						(select e.emp_id, e.cmp_id, Date_Of_Join, isnull(Emp_left_Date, @To_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
						where cmp_id = @Cmp_ID   and  
						(( @From_Date  >= Date_Of_Join  and  @From_Date <= Emp_left_date ) 
						or ( @to_Date  >= Date_Of_Join  and @To_Date <= Emp_left_date )
						or Emp_left_date is null and @To_Date >= Date_Of_Join)
						or @To_Date >= Emp_left_date  and  @From_Date <= Emp_left_date )  
		   End
		 else
		   Begin
		     Insert Into @Emp_Cons
               
				select I.Emp_Id from dbo.T0095_INCREMENT I WITH (NOLOCK) inner join 
						( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_INCREMENT WITH (NOLOCK)
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	 Inner join
						dbo.T0080_EMP_MASTER E WITH (NOLOCK) on i.emp_ID = E.Emp_ID
					Where E.CMP_ID = @Cmp_ID 
					and i.BRANCH_ID = isnull(@BRANCH_ID ,i.BRANCH_ID)
					and i.Grd_ID = isnull(@Grd_ID ,i.Grd_ID)
					and isnull(i.Dept_ID,0) = isnull(@Dept_ID ,isnull(i.Dept_ID,0))			
					and Isnull(i.Desig_ID,0) = isnull(@Desig_ID ,Isnull(i.Desig_ID,0))			
					and ISNULL(I.Emp_ID,0) = isnull(@Emp_ID ,ISNULL(I.Emp_ID,0))
					and Date_Of_Join <= @To_Date and I.emp_id in(
						select e.Emp_Id from
						(select e.emp_id, e.cmp_id, Date_Of_Join, isnull(Emp_left_Date, @To_Date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry
						where cmp_id = @Cmp_ID   and  
						(( @From_Date  >= Date_Of_Join  and  @From_Date <= Emp_left_date ) 
						or ( @to_Date  >= Date_Of_Join  and @To_Date <= Emp_left_date )
						or Emp_left_date is null and @To_Date >= Date_Of_Join)
						or @To_Date >= Emp_left_date  and  @From_Date <= Emp_left_date ) 
		   End  
			
		end
---------------------  
	
	CREATE table #CTCMast
	(
		
				Tran_ID		numeric IDENTITY(1,1), 	
				Cmp_ID		numeric,
				Emp_ID		numeric,
				Def_ID		numeric,
				Label_Head	varchar(100),
				Monthly_Amt	numeric(18,2),
				Yearly_Amt	numeric(18,2),
				AD_ID		numeric,
				AD_Flag		char(1),
				AD_DEF_ID	numeric ,
				Allowance_Type	CHAR(1) DEFAULT '',  --added jimit 03032016
				Wages_Type   Varchar(10) DEFAULT '',  --added jimit 11082016
				Group_Name   varchar(30) DEFAULT '',    --added by jimit 24102016
				Seq_No		 Numeric(18,2) DEFAULT 0,	--added by jimit 24102016
				Salary_Group varchar(100) DEFAULT ''	--added by jimit 24102016
				
	)
	
	----------------------------------------------------------------
		
	Declare @Columns nvarchar(2000)
	Declare @CTC_CMP_ID numeric(18,0)
	Declare @CTC_EMP_ID numeric(18,0)
	Declare @CTC_BASIC numeric(18,2)
	Declare @AD_NAME_DYN nvarchar(100)
	Declare @val nvarchar(500)
	DECLARE @Allowance_Type	char(1)
	
	Set @Columns = '#'
	
	
	DECLARE Allow_Dedu_Cursor CURSOR FOR
		select AD_NAME from T0050_AD_MASTER WITH (NOLOCK) where Cmp_id = @Cmp_ID and ad_part_of_ctc = 1 and AD_NOT_EFFECT_SALARY = 0 and AD_FLAG = 'I' and  isnull(Allowance_Type,'A')='A' order by AD_Level
	OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				Begin
										
					Set @AD_NAME_DYN = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(@AD_NAME_DYN)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
				
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
				
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor
	
	----------------------------------------------------------------
			
	--Set @Columns = @Columns +  'GROSS_SALARY#'
	
	----------------------------------------------------------------
	
	
	
	set @Columns = 	@Columns + 'TOTAL_EARNINGS#'
	----------------------------------------------------------------
	
	--Set @Columns = @Columns +  'CTC#'
	
	----------------------------------------------------------------
	
	Declare Allow_Dedu_Cursor CURSOR FOR
		select AD_NAME from T0050_AD_MASTER WITH (NOLOCK) where Cmp_id = @Cmp_ID and AD_NOT_EFFECT_SALARY = 0 and AD_FLAG = 'D' order by AD_Level
	OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				Begin
					
										
					Set @AD_NAME_DYN = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(@AD_NAME_DYN)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
															
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
					
					
					
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor

	----------------------------------------------------------------
	
	Set @Columns = @Columns +  'PT#'
	Set @Columns = @Columns +  'TOTAL_DEDUCTION#'
	--Set @Columns = @Columns +  'NET_TAKE_HOME#'
	Set @Columns = @Columns +  'NET_SALARY#'
	
	Declare Allow_Dedu_Cursor CURSOR FOR
		select AD_NAME from T0050_AD_MASTER WITH (NOLOCK) where Cmp_id = @Cmp_ID and ad_part_of_ctc = 1 and AD_NOT_EFFECT_SALARY = 1 and AD_FLAG = 'I' and (isnull(Allowance_Type,'A') <> 'R') order by AD_Level
	OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				Begin
					
									
					Set @AD_NAME_DYN = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(@AD_NAME_DYN)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
					
					
					
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor
	
	
	Declare Allow_Dedu_Cursor CURSOR FOR
		select AD_NAME from T0050_AD_MASTER WITH (NOLOCK) where Cmp_id = @Cmp_ID and ad_part_of_ctc = 1 and AD_NOT_EFFECT_SALARY = 1 and AD_FLAG = 'I' and (isnull(Allowance_Type,'A')='R') order by AD_Level
	OPEN Allow_Dedu_Cursor
			fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
			while @@fetch_status = 0
				Begin
					
									
					Set @AD_NAME_DYN = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(@AD_NAME_DYN)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
					
					Set @Columns = @Columns +  REPLACE(rtrim(ltrim(@AD_NAME_DYN)),' ','_') + '#'
					
					
					
				fetch next from Allow_Dedu_Cursor into @AD_NAME_DYN
				End
	close Allow_Dedu_Cursor	
	deallocate Allow_Dedu_Cursor
	
	Set @Columns = @Columns +  'TOTAL_REIMBURSEMENT#'
	Set @Columns = @Columns +  'TOTAL_STATUTORY_EARNING#'
	Set @Columns = @Columns +  'CTC#'
	
	
	
	----------------------------------------------------------------
			
			
				
	set @CTC_CMP_ID = @Cmp_ID

	
	Declare CTC_UPDATE CURSOR FOR
		select Emp_Id from @Emp_Cons
	OPEN CTC_UPDATE
	fetch next from CTC_UPDATE into @CTC_EMP_ID
	while @@fetch_status = 0
		Begin	
		
			Declare @Count numeric
			set @Count = 1
			
			
			
			-------------------------------------------------------------------------------------------------
			-- Annually Salry will be calulated till current date from date of Joining or Starting of year --
			-------------------------------------------------------------------------------------------------
			
			Declare @CTC_DOJ datetime
			Declare @CTC_NEW_DOJ datetime
			Declare @CTC_NEW_DOJ2 datetime
			Declare @CTC_PRV_MON_DOJ numeric
			--Declare @CTC_TOT_YEAR numeric
			Declare @CTC_TOT_MON numeric
			--Declare @CTC_CUR_MON_DAY numeric
			
			select @CTC_DOJ = Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where Cmp_ID = @CTC_CMP_ID and Emp_ID = @CTC_EMP_ID
			
			
			
			SET @CTC_NEW_DOJ = CONVERT(datetime,dbo.GET_MONTH_ST_DATE(MONTH(@CTC_DOJ),YEAR(@CTC_DOJ)))
			
			Set @CTC_NEW_DOJ2 = CONVERT(datetime, DATEADD(YEAR, 1, @CTC_NEW_DOJ)-1)
			
			
			--select @CTC_NEW_DOJ,@CTC_NEW_DOJ2
			
			SET @CTC_TOT_MON = DATEDIFF(mm,@CTC_NEW_DOJ,@CTC_NEW_DOJ2) + 1
			
			--select @CTC_TOT_MON
			
			if @CTC_TOT_MON > 12
				begin	
					set @CTC_TOT_MON  = 12
				end
			
			
						
			Declare @CTC_COLUMNS nvarchar(100)
			Declare @CTC_GROSS numeric(18,2)
			Declare @Total_Ear numeric(18,2)
			Declare @Total_Ded numeric(18,2)
			Declare @CTC_AD_FLAG varchar(1)
			Declare @CTC_PT numeric(18,2)
			Declare @Inc_ID  numeric
			Declare @Allow_Amount numeric(18,2)
			Declare @numTmpCal numeric(18,2)
			DECLARE @Allowance_Column char(1)
			Declare @Wages_Type Varchar(10) 
			Declare @Total_statutory_Earnings as numeric(18,2)
			declare	@Total_Reimbursement as numeric(18,2)
			
			set @numTmpCal = 0
			Set @CTC_PT = 0
			Set @CTC_GROSS = 0
			Set @Total_Ear = 0
			Set @Total_Ded = 0
			Set @Wages_Type = ''
			set @Total_statutory_Earnings = 0
			set @Total_Reimbursement = 0
			--------------------------------------------------------------------------------------
			
			--Select @CTC_BASIC= isnull(Basic_Salary,0) from T0080_EMP_MASTER where Emp_ID = @CTC_EMP_ID and Cmp_ID = @Cmp_ID
			
			select @CTC_BASIC=Basic_Salary,@Wages_Type = Wages_Type  from T0095_INCREMENT WITH (NOLOCK) where CMP_ID = @Cmp_Id and EMP_ID = @CTC_EMP_ID and Increment_Effective_Date <= @To_Date and Increment_Type<>'Transfer' --Added by SUmit on 12092016
			
			--print @CTC_BASIC
			--if @CTC_TOT_YEAR = 0
			--	if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0
		--	Set @numTmpCal = (@CTC_BASIC/(DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ))))) * @CTC_PRV_MON_DOJ
																
			Set @numTmpCal = @numTmpCal + (@CTC_BASIC * @CTC_TOT_MON)
			
		--	Set @numTmpCal = @numTmpCal + ((@CTC_BASIC/(DaY(dbo.GET_MONTH_END_DATE(MONTH(GETDATE()),YEAR(GETDATE()))))) * @CTC_CUR_MON_DAY)
									
			
			insert into #CTCMast (Cmp_ID,Emp_ID,Def_ID,Label_Head,Monthly_Amt,Yearly_Amt,AD_ID,AD_Flag,AD_DEF_ID,Allowance_Type,Wages_Type,Group_Name,Seq_No,Salary_Group)
				values
			(@CTC_CMP_ID,@CTC_EMP_ID,@Count,'Basic Salary',@CTC_BASIC,@numTmpCal,NULL,'I',NULL,'A',@Wages_Type,'Salary',1,'Basic Salary')
			
			Set @Count = @Count + 1
								
								
			Declare CRU_COLUMNS CURSOR FOR
				Select data from Split(@Columns,'#')  where data <> ''
			OPEN CRU_COLUMNS
					fetch next from CRU_COLUMNS into @CTC_COLUMNS
					while @@fetch_status = 0
						Begin					
								--------------------------------------------
								
								select @Inc_Id=MAX(INCREMENT_ID) from T0095_INCREMENT WITH (NOLOCK) where CMP_ID = @CTC_CMP_ID and EMP_ID = @CTC_EMP_ID and Increment_Effective_Date <= @To_Date and Increment_Type<>'Transfer' --Added by SUmit on 12092016
								
								if @Inc_ID > 0
								begin
										
										Set @CTC_COLUMNS = Replace(Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(@CTC_COLUMNS)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_'),'__','_')
										
										
										set @numTmpCal = 0
										
										--IF @CTC_COLUMNS = 'GROSS_SALARY'
										IF @CTC_COLUMNS = 'TOTAL_EARNINGS'
											begin											
												
												
												
												SET @CTC_GROSS = isnull(@CTC_BASIC,0) + isnull(@Total_Ear,0) 
												
												if @CTC_GROSS > 0
													begin
												
												--print @CTC_GROSS
												
													--added jimit 03032016	
													select @Allowance_Type = Allowance_Type 
													from   T0050_AD_MASTER WITH (NOLOCK)  
													 WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
													and CMP_ID = @CTC_CMP_ID 
													--ended
														--if @CTC_TOT_YEAR = 0
														--	if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0
														--Set @numTmpCal = (@CTC_GROSS/(DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ))))) * @CTC_PRV_MON_DOJ
																
														Set @numTmpCal = @numTmpCal + (@CTC_GROSS * @CTC_TOT_MON)
														
													--	Set @numTmpCal = @numTmpCal + ((@CTC_GROSS/(DaY(dbo.GET_MONTH_END_DATE(MONTH(GETDATE()),YEAR(GETDATE()))))) * @CTC_CUR_MON_DAY)
														
														insert into #CTCMast (Cmp_ID,Emp_ID,Def_ID,Label_Head,Monthly_Amt,Yearly_Amt,AD_ID,AD_Flag,AD_DEF_ID,Allowance_Type,Wages_Type,Group_Name,Seq_No,Salary_Group)
															values
														(@CTC_CMP_ID,@CTC_EMP_ID,@Count,Replace(@CTC_COLUMNS,'_',' '),@CTC_GROSS,(@numTmpCal),NULL,'I',NULL,@Allowance_Type,@Wages_Type,'Earnings(1)',11,'Earnings')
													
														Set @Count = @Count + 1
													end
												
											end																	
										
										else if @CTC_COLUMNS = 'PT'	
											begin
												
												select @CTC_PT=Emp_PT_Amount from T0095_INCREMENT WITH (NOLOCK) where Increment_ID=@Inc_ID
												if @CTC_PT > 0
													begin
													--added jimit 03032016	
													select @Allowance_Type = Allowance_Type 
													from   T0050_AD_MASTER WITH (NOLOCK) 
													 WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
													and CMP_ID = @CTC_CMP_ID 
													--ended
														Set @numTmpCal = @numTmpCal + (@CTC_PT * @CTC_TOT_MON)
														
														insert into #CTCMast (Cmp_ID,Emp_ID,Def_ID,Label_Head,Monthly_Amt,Yearly_Amt,AD_ID,AD_Flag,AD_DEF_ID,Allowance_Type,Wages_Type,Group_Name,Seq_No,Salary_Group)
															values
														(@CTC_CMP_ID,@CTC_EMP_ID,@Count,@CTC_COLUMNS,@CTC_PT, @numTmpCal ,NULL,'D',NULL,@Allowance_Type,@Wages_Type,'Deduction',11,'F-Deduction')
															
														Set @Count = @Count + 1
														
														Set @Total_Ded = @Total_Ded + isnull(@CTC_PT,0)
													end		
													
											end
										else if @CTC_COLUMNS = 'TOTAL_DEDUCTION'	
											begin
												
												
												if  @Total_Ded > 0
													begin
														
														--if @CTC_TOT_YEAR = 0
														--	if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0
														--if @CTC_PRV_MON_DOJ > 0
														--	Set @numTmpCal = @Total_Ded
													--added jimit 03032016	
													select @Allowance_Type = Allowance_Type 
													from   T0050_AD_MASTER WITH (NOLOCK) 
													 WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
													and CMP_ID = @CTC_CMP_ID 
													--ended		
														Set @numTmpCal = @numTmpCal + (@Total_Ded * @CTC_TOT_MON)
														
														--Set @numTmpCal = @numTmpCal + @Total_Ded
																												
														insert into #CTCMast (Cmp_ID,Emp_ID,Def_ID,Label_Head,Monthly_Amt,Yearly_Amt,AD_ID,AD_Flag,AD_DEF_ID,Allowance_Type,Wages_Type,Group_Name,Seq_No,Salary_Group)
															values
														(@CTC_CMP_ID,@CTC_EMP_ID,@Count,Replace(@CTC_COLUMNS,'_',' '),@Total_Ded,@numTmpCal,NULL,'D',NULL,@Allowance_Type,@Wages_Type,'TOTAL DEDUCTION(2)',11,'F-Deductions')
														
														Set @Count = @Count + 1
														
													end
												
											end
											else if @CTC_COLUMNS = 'NET_SALARY'	
											begin
												Set @numTmpCal = (isnull(@CTC_GROSS,0)  - isnull(@Total_Ded,0))
												if  @numTmpCal > 0
													begin
													--added jimit 03032016	
													select @Allowance_Type = Allowance_Type 
													from   T0050_AD_MASTER WITH (NOLOCK)  
													 WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
													and CMP_ID = @CTC_CMP_ID 
													--ended
														Declare @numTempCal3 numeric(18,2)
														set @numTempCal3 = 0
														
														--if @CTC_TOT_YEAR = 0
														--	if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0
																--Set @numTempCal3 = (@numTmpCal/(DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ))))) * @CTC_PRV_MON_DOJ
																
														Set @numTempCal3 = @numTempCal3 + (@numTmpCal * @CTC_TOT_MON)
														
														--Set @numTempCal3 = @numTempCal3 + ((@numTmpCal/(DaY(dbo.GET_MONTH_END_DATE(MONTH(GETDATE()),YEAR(GETDATE()))))) * @CTC_CUR_MON_DAY)
															
															
														insert into #CTCMast (Cmp_ID,Emp_ID,Def_ID,Label_Head,Monthly_Amt,Yearly_Amt,AD_ID,AD_Flag,AD_DEF_ID,Allowance_Type,Wages_Type,Group_Name,Seq_No,Salary_Group)
															values
														(@CTC_CMP_ID,@CTC_EMP_ID,@Count,Replace(@CTC_COLUMNS,'_',' '),@numTmpCal,@numTempCal3,NULL,'M',NULL,@Allowance_Type,@Wages_Type,'Net Salary(1-2)',11,'Net Salary')	
													
												
														Set @Count = @Count + 1
													end
												
											end
										
										else
											begin
												declare @CTC_AD_ID numeric
												Declare @ALlow_Amount_Net as numeric(18,2)
												Declare @AD_NOT_EFFECT_SALARY as numeric(18,2)
												
												
												
												select @Allow_Amount=E_AD_AMOUNT,@CTC_AD_FLAG=E_AD_FLAG,@CTC_AD_ID=ad.AD_Id,@Allowance_Type =ad.Allowance_Type,@AD_NOT_EFFECT_SALARY = AD_NOT_EFFECT_SALARY from T0100_EMP_EARN_DEDUCTION  ded WITH (NOLOCK)
													inner join T0050_AD_MASTER ad WITH (NOLOCK) on ded.AD_Id = ad.AD_Id
													WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(ad.Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS and ded.CMP_ID = @CTC_CMP_ID and ded.EMP_ID = @CTC_EMP_ID and ded.INCREMENT_ID = @Inc_Id 
															and ad_part_of_ctc = 1 and AD_NOT_EFFECT_SALARY = 1 and ded.E_AD_FLAG = 'I'
															
												
												
												if @Allow_Amount > 0 and @Allowance_Type <> 'R' and  @CTC_AD_FLAG = 'I'  
													begin										
														
														set @ALlow_Amount_Net = 0
														
														--if @CTC_TOT_YEAR = 0
														--	if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0
														--if @CTC_PRV_MON_DOJ > 0
														--	Set @ALlow_Amount_Net = @Allow_Amount
																
														Set @ALlow_Amount_Net = @ALlow_Amount_Net + (@Allow_Amount * @CTC_TOT_MON)
														
														--Set @ALlow_Amount_Net = @ALlow_Amount_Net + @Allow_Amount
														set @Total_statutory_Earnings = @Total_statutory_Earnings + @Allow_Amount
														
														insert into #CTCMast (Cmp_ID,Emp_ID,Def_ID,Label_Head,Monthly_Amt,Yearly_Amt,AD_ID,AD_Flag,AD_DEF_ID,Allowance_Type,Wages_Type,Group_Name,Seq_No,Salary_Group)
															values
														(@CTC_CMP_ID,@CTC_EMP_ID,NULL,Replace(@CTC_COLUMNS,'_',' '),isnull(@Allow_Amount,0),@ALlow_Amount_Net ,@CTC_AD_ID,@CTC_AD_FLAG,NULL,@Allowance_Type,@Wages_Type,'Company Contribution',11,'Z-Cost to the Company')			
														
														--Set @Count = @Count + 1
													end
													
												
												
												if @Allow_Amount > 0 and @Allowance_Type = 'R' and  @CTC_AD_FLAG = 'I'
													begin
																									
														set @ALlow_Amount_Net = 0
														
														--if @CTC_TOT_YEAR = 0
														--	if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0
														--if @CTC_PRV_MON_DOJ > 0
														--	Set @ALlow_Amount_Net = @Allow_Amount
																
														Set @ALlow_Amount_Net = @ALlow_Amount_Net + (@Allow_Amount * @CTC_TOT_MON)
														
														--Set @ALlow_Amount_Net = @ALlow_Amount_Net + @Allow_Amount
															
														set @Total_Reimbursement = @Total_Reimbursement + @Allow_Amount
														
														insert into #CTCMast (Cmp_ID,Emp_ID,Def_ID,Label_Head,Monthly_Amt,Yearly_Amt,AD_ID,AD_Flag,AD_DEF_ID,Allowance_Type,Wages_Type,Group_Name,Seq_No,Salary_Group)
															values
														(@CTC_CMP_ID,@CTC_EMP_ID,NULL,Replace(@CTC_COLUMNS,'_',' '),isnull(@Allow_Amount,0),@ALlow_Amount_Net ,@CTC_AD_ID,@CTC_AD_FLAG,NULL,@Allowance_Type,@Wages_Type,'Reimbursement',11,'Reimbursement')			
														
														--Set @Count = @Count + 1
													end											
													
																	   
												
												select @Allow_Amount=E_AD_AMOUNT,@CTC_AD_FLAG=E_AD_FLAG,@CTC_AD_ID=ad.AD_Id,@Allowance_Type =ad.Allowance_Type,@AD_NOT_EFFECT_SALARY = AD_NOT_EFFECT_SALARY from T0100_EMP_EARN_DEDUCTION  ded WITH (NOLOCK)
													inner join T0050_AD_MASTER ad WITH (NOLOCK) on ded.AD_Id = ad.AD_Id
													WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(ad.Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS and ded.CMP_ID = @CTC_CMP_ID and ded.EMP_ID = @CTC_EMP_ID and ded.INCREMENT_ID = @Inc_Id 
															 and ad_part_of_ctc = 1 and AD_NOT_EFFECT_SALARY = 0 and ded.E_AD_FLAG = 'I'
															
												
												
												if @Allow_Amount > 0 and @Allowance_Type = 'A' and  @CTC_AD_FLAG = 'I' and @AD_NOT_EFFECT_SALARY = 0
													begin
																									
														set @ALlow_Amount_Net = 0
														
														--if @CTC_TOT_YEAR = 0
														--	if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0
														--if @CTC_PRV_MON_DOJ > 0
														--	Set @ALlow_Amount_Net = @Allow_Amount
																
														Set @ALlow_Amount_Net = @ALlow_Amount_Net + (@Allow_Amount * @CTC_TOT_MON)
														
														--Set @ALlow_Amount_Net = @ALlow_Amount_Net + @Allow_Amount
														
														
														insert into #CTCMast (Cmp_ID,Emp_ID,Def_ID,Label_Head,Monthly_Amt,Yearly_Amt,AD_ID,AD_Flag,AD_DEF_ID,Allowance_Type,Wages_Type,Group_Name,Seq_No,Salary_Group)
															values
														(@CTC_CMP_ID,@CTC_EMP_ID,NULL,Replace(@CTC_COLUMNS,'_',' '),isnull(@Allow_Amount,0),@ALlow_Amount_Net ,@CTC_AD_ID,@CTC_AD_FLAG,NULL,@Allowance_Type,@Wages_Type,'Earning',11,'Earning')			
														
														--Set @Count = @Count + 1
													end	
													
													select @Allow_Amount=E_AD_AMOUNT,@CTC_AD_FLAG=E_AD_FLAG,@CTC_AD_ID=ad.AD_Id,@Allowance_Type =ad.Allowance_Type from T0100_EMP_EARN_DEDUCTION  ded WITH (NOLOCK)
													inner join T0050_AD_MASTER ad WITH (NOLOCK) on ded.AD_Id = ad.AD_Id
													WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(ad.Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS and ded.CMP_ID = @CTC_CMP_ID and ded.EMP_ID = @CTC_EMP_ID and ded.INCREMENT_ID = @Inc_Id 
															and AD_NOT_EFFECT_SALARY = 0 --and ded.E_AD_FLAG = 'D'
															
												
												
												if @Allow_Amount > 0 and @CTC_AD_FLAG = 'D'
													begin
																									
														set @ALlow_Amount_Net = 0
														
														--if @CTC_TOT_YEAR = 0
														--	if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0
														--if @CTC_PRV_MON_DOJ > 0
														--	Set @ALlow_Amount_Net = @Allow_Amount
																
														Set @ALlow_Amount_Net = @ALlow_Amount_Net + (@Allow_Amount * @CTC_TOT_MON)
														
														--Set @ALlow_Amount_Net = @ALlow_Amount_Net + @Allow_Amount
															
														
														insert into #CTCMast (Cmp_ID,Emp_ID,Def_ID,Label_Head,Monthly_Amt,Yearly_Amt,AD_ID,AD_Flag,AD_DEF_ID,Allowance_Type,Wages_Type,Group_Name,Seq_No,Salary_Group)
															values
														(@CTC_CMP_ID,@CTC_EMP_ID,NULL,Replace(@CTC_COLUMNS,'_',' '),isnull(@Allow_Amount,0),@ALlow_Amount_Net ,@CTC_AD_ID,@CTC_AD_FLAG,NULL,@Allowance_Type,@Wages_Type,'Deduction',11,'F-Deduction')			
														
														--Set @Count = @Count + 1
													end	
															
												if @Allow_Amount > 0 and @CTC_AD_FLAG = 'M'
												  begin 
														set @ALlow_Amount_Net = 0
														
														--if @CTC_TOT_YEAR = 0
														--	if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0
														--if @CTC_PRV_MON_DOJ > 0
														--	Set @ALlow_Amount_Net = @Allow_Amount
																
														Set @ALlow_Amount_Net = @ALlow_Amount_Net + (@Allow_Amount * @CTC_TOT_MON)
														
														--Set @ALlow_Amount_Net = @ALlow_Amount_Net + @Allow_Amount
															
														
														insert into #CTCMast (Cmp_ID,Emp_ID,Def_ID,Label_Head,Monthly_Amt,Yearly_Amt,AD_ID,AD_Flag,AD_DEF_ID,Allowance_Type,Wages_Type,Group_Name,Seq_No,Salary_Group)
															values
														(@CTC_CMP_ID,@CTC_EMP_ID,NULL,Replace(@CTC_COLUMNS,'_',' '),isnull(@Allow_Amount,0),@ALlow_Amount_Net ,@CTC_AD_ID,@CTC_AD_FLAG,NULL,@Allowance_Type,@Wages_Type,'Net Salary',11,'Net Salary')			
														
												  END				
												
											end
										if @CTC_AD_FLAG = 'I'
											begin
												Set @Total_Ear = @Total_Ear + isnull(@Allow_Amount,0)																		
											end
										else if @CTC_AD_FLAG = 'D'
											begin
												Set @Total_Ded = @Total_Ded + isnull(@Allow_Amount,0)											
											end
										
										
										
										if @CTC_COLUMNS = 'TOTAL_REIMBURSEMENT'
											begin 
											  
											  	Set @numTmpCal =  IsNull(@Total_Reimbursement,0)
												if @numTmpCal > 0 
													begin
													--added jimit 03032016	
													select @Allowance_Type = Allowance_Type 
													from   T0050_AD_MASTER WITH (NOLOCK) 
													 WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
													and CMP_ID = @CTC_CMP_ID 
													--ended
														Declare @numTempCal5 numeric(18,2)
														set @numTempCal5 = 0
														
														--if @CTC_TOT_YEAR = 0
														--	if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0
														--Set @numTempCal2 = (@numTmpCal/(DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ))))) * @CTC_PRV_MON_DOJ
																
														Set @numTempCal5 = @numTempCal5 + (@numTmpCal * @CTC_TOT_MON)
														
														--Set @numTempCal2 = @numTempCal2 + ((@numTmpCal/(DaY(dbo.GET_MONTH_END_DATE(MONTH(GETDATE()),YEAR(GETDATE()))))) * @CTC_CUR_MON_DAY)
														
														insert into #CTCMast (Cmp_ID,Emp_ID,Def_ID,Label_Head,Monthly_Amt,Yearly_Amt,AD_ID,AD_Flag,AD_DEF_ID,Allowance_Type,Wages_Type,Group_Name,Seq_No,Salary_Group)
															values
														(@CTC_CMP_ID,@CTC_EMP_ID,@Count, Replace(@CTC_COLUMNS,'_',' '),@numTmpCal,@numTempCal5,NULL,'I',NULL,@Allowance_Type,@Wages_Type,'TOTAL_REIMBURSEMENT',11,'TOTAL_REIMBURSEMENT')
													
														Set @Count = @Count + 1
														
													end
											end
										
										if @CTC_COLUMNS = 'CTC'
											begin 
											  
											  	Set @numTmpCal =  @CTC_GROSS + IsNull(@Total_statutory_Earnings,0) + IsNull(@Total_Reimbursement,0)
												if @numTmpCal > 0 
													begin
													--added jimit 03032016	
													select @Allowance_Type = Allowance_Type 
													from   T0050_AD_MASTER WITH (NOLOCK)  
													 WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
													and CMP_ID = @CTC_CMP_ID 
													--ended
														Declare @numTempCal2 numeric(18,2)
														set @numTempCal2 = 0
														
														--if @CTC_TOT_YEAR = 0
														--	if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0
														--Set @numTempCal2 = (@numTmpCal/(DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ))))) * @CTC_PRV_MON_DOJ
																
														Set @numTempCal2 = @numTempCal2 + (@numTmpCal * @CTC_TOT_MON)
														
														--Set @numTempCal2 = @numTempCal2 + ((@numTmpCal/(DaY(dbo.GET_MONTH_END_DATE(MONTH(GETDATE()),YEAR(GETDATE()))))) * @CTC_CUR_MON_DAY)
														
														insert into #CTCMast (Cmp_ID,Emp_ID,Def_ID,Label_Head,Monthly_Amt,Yearly_Amt,AD_ID,AD_Flag,AD_DEF_ID,Allowance_Type,Wages_Type,Group_Name,Seq_No,Salary_Group)
															values
														(@CTC_CMP_ID,@CTC_EMP_ID,@Count, @CTC_COLUMNS,@numTmpCal,@numTempCal2,NULL,'I',NULL,@Allowance_Type,@Wages_Type,'CTC',11,'Z-CTC')
													
														Set @Count = @Count + 1
														
													end
											end
										
										if @CTC_COLUMNS = 'TOTAL_STATUTORY_EARNING'
											begin 
											  
											  	Set @numTmpCal =  IsNull(@Total_statutory_Earnings,0)
												if @numTmpCal > 0
													begin
													--added jimit 03032016	
													select @Allowance_Type = Allowance_Type 
													from   T0050_AD_MASTER WITH (NOLOCK) 
													 WHere Replace(Replace(REPLACE(Replace(REPLACE(Replace(REPLACE(replace(ltrim(rtrim(Ad_Name)),'  ',' '),'%',''),'-',' '),'@',''),'(',''),')',''),' ','_'),'__','_') = @CTC_COLUMNS 
													and CMP_ID = @CTC_CMP_ID 
													--ended												
													
														Declare @numTempCal4 numeric(18,2)
														set @numTempCal4 = 0
														
														--if @CTC_TOT_YEAR = 0
														--	if (DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ)))) > 0
														--Set @numTempCal2 = (@numTmpCal/(DaY(dbo.GET_MONTH_END_DATE(MONTH(@CTC_NEW_DOJ),YEAR(@CTC_NEW_DOJ))))) * @CTC_PRV_MON_DOJ
																
														Set @numTempCal4 = @numTempCal4 + (@numTmpCal * @CTC_TOT_MON)
														
														--Set @numTempCal2 = @numTempCal2 + ((@numTmpCal/(DaY(dbo.GET_MONTH_END_DATE(MONTH(GETDATE()),YEAR(GETDATE()))))) * @CTC_CUR_MON_DAY)
														
														insert into #CTCMast (Cmp_ID,Emp_ID,Def_ID,Label_Head,Monthly_Amt,Yearly_Amt,AD_ID,AD_Flag,AD_DEF_ID,Allowance_Type,Wages_Type,Group_Name,Seq_No,Salary_Group)
															values
														(@CTC_CMP_ID,@CTC_EMP_ID,@Count, Replace(@CTC_COLUMNS,'_',' '),@numTmpCal,@numTempCal4,NULL,'I',NULL,@Allowance_Type,@Wages_Type,'TOTAL STATUTORY EARNING',11,'Z-Cost to the Company1')
													
														Set @Count = @Count + 1
														
													end
											end
										
										
										set @Inc_Id = 0
										Set @Allow_Amount = 0
										
								end
								
								--------------------------------------------
								
							fetch next from CRU_COLUMNS into @CTC_COLUMNS
						End
			close CRU_COLUMNS	
			deallocate CRU_COLUMNS
					
	
			fetch next from CTC_UPDATE into @CTC_EMP_ID
	End
	close CTC_UPDATE	
	deallocate CTC_UPDATE
	
	----------------------------------------------------------------
		
	select * from #CTCMast  
	order by Emp_ID ,Tran_ID
	
	
	drop table #CTCMast
	
	RETURN




