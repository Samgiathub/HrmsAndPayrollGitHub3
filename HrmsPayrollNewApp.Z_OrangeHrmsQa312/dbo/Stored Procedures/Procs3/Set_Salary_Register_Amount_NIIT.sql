
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[Set_Salary_Register_Amount_NIIT]
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
,@Constraint	varchar(MAX) = ''
,@Sal_Type    numeric
,@PBranch_ID    varchar(MAX) = '0'
,@Salary_Cycle_id numeric = 0
,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 21082013
,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013
,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 21082013	
,@SubBranch_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013	


AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	Declare @Payement varchar(50) 
	Declare @Transaction_ID Numeric
	
	set @Payement = ''
	set @Transaction_ID=0
	
	 if isnull(@Payement,'') = ''
		set  @Payement = ''
	Declare @Row_id as numeric
	Declare @Label_Name as varchar(100)
	Declare @Total_Allowance as numeric(22,2) 
	Declare @Is_Search as varchar(30)
	Declare @Basic_salary as numeric(22,2)
	Declare @Total_Allow as numeric (22,2)
	declare @Value_String as varchar(250)
	Declare @Amount as numeric (22,2)

	Declare @OTher_Allow as numeric(22,2)
	Declare @CO_Amount as numeric(22,2)
	Declare @Total_Deduction as numeric(22,2)
	Declare @Other_Dedu as numeric(22,2)
	Declare @Late_Deduction as numeric(22,2)
	Declare @Loan as numeric(22,2)
	Declare @Advance as numeric(22,2)
	Declare @Net_Salary as numeric(22,2)
	Declare @Revenue_amt numeric(10)
	Declare @Lwf_amt numeric(10)
	Declare @PT as numeric(22,2)
	Declare @LWF as numeric(22,2)
	Declare @Revenue as numeric(22,2)
	Declare @Allow_Name as varchar(100)
	Declare @P_Days as numeric(22,2)
	Declare @A_Days as numeric(22,2)
	Declare @Act_Gross_salary as numeric(18,2)
	DEclare @month as numeric(18,0)
	Declare @Year as numeric(18,0)
	DEclare @TDS numeric(18,2)
	Declare @Settl numeric(22,2)
	Declare @Deficit_Amt Numeric(18,2) -- Added by Hardik 14/11/2013 for Pakistan
	Declare @Claim_Amount as numeric(18,2) --Mukti(28062017)
	
	IF	EXISTS (SELECT * FROM [tempdb].dbo.sysobjects where name like '#Temp_report_Label')		
			BEGIN
				DROP TABLE #Temp_report_Label
			END
		IF	EXISTS (SELECT * FROM [tempdb].dbo.sysobjects where name like '#Temp_Salary_Muster_Report')		
			BEGIN
				DROP TABLE #Temp_Salary_Muster_Report
			END
				
			
	
	CREATE table #Temp_report_Label
	(
	Row_ID  numeric(18, 0) NOt null,
	Label_Name  varchar(200) collate SQL_Latin1_General_CP1_CI_AS not null,
	Income_Tax_ID numeric(18, 0) null,
	Is_Active	varchar(1) collate SQL_Latin1_General_CP1_CI_AS null
	)
	
	--ALTER index idx_1 on #Temp_report_Label (Row_ID)
	Create CLUSTERED INDEX ind_temp ON #Temp_report_Label(Row_ID)
	Create NONCLUSTERED INDEX ind_temp6 ON #Temp_report_Label(Label_Name)

		
	CREATE table #Temp_Salary_Muster_Report		
	(
		Emp_ID numeric(18, 0) Not Null,
		Cmp_ID numeric(18, 0) Not Null,
		Transaction_ID numeric(18, 0) Not Null,
		Month numeric(18, 0) Not Null,
		Year numeric(18, 0) Not Null,
		Label_Name varchar(200) collate SQL_Latin1_General_CP1_CI_AS Not Null,
		Amount numeric(18, 2) null,
		Value_String varchar(250)collate SQL_Latin1_General_CP1_CI_AS Not Null,
		INCOME_TAX_ID numeric(18, 0)  Default 0,
		Row_id numeric(18, 0) Null,
		M_AD_Flage char(1)collate SQL_Latin1_General_CP1_CI_AS
	)
	Create CLUSTERED INDEX ind_temp1	ON #Temp_Salary_Muster_Report(Row_id)
	Create NONCLUSTERED INDEX ind_temp2 ON #Temp_Salary_Muster_Report(Emp_ID)
	Create NONCLUSTERED INDEX ind_temp3 ON #Temp_Salary_Muster_Report(Cmp_ID)
	Create NONCLUSTERED INDEX ind_temp4 ON #Temp_Salary_Muster_Report(Label_Name)
	Create NONCLUSTERED INDEX ind_temp5 ON #Temp_Salary_Muster_Report(Value_String)
		
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
		
	if @Salary_Cycle_id = 0
		set @Salary_Cycle_id = NULL
	If @Segment_Id = 0		 -- Added By Gadriwala Muslim 21082013
	set @Segment_Id = null
	If @Vertical_Id = 0		 -- Added By Gadriwala Muslim 21082013
	set @Vertical_Id = null
	If @SubVertical_Id = 0	 -- Added By Gadriwala Muslim 21082013
	set @SubVertical_Id = null	
	If @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 21082013
	set @SubBranch_Id = null	
	
	

		  Declare @Sal_St_Date   Datetime    
		  Declare @Sal_end_Date   Datetime  
		  
			If @Branch_ID is null
				Begin 
					select Top 1 @Sal_St_Date  = Sal_st_Date 
					  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
					  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
				End
			Else
				Begin
					select @Sal_St_Date  =Sal_st_Date 
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
			   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
			   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
			   set @From_Date = @Sal_St_Date
			   Set @To_Date = @Sal_end_Date   
			End
		
		
	set @month = month(@To_Date)
	set @Year = Year(@To_Date)
	  
	EXEC Set_Salary_Register_Lable @Cmp_ID ,@month , @Year
	
	 CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id,0,0,2,@PBranch_ID 
	      
	
	--Declare #Emp_Cons Table
	--	(
	--		Emp_ID	numeric
	--	)
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into #Emp_Cons
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
	--	end
	--else 
	--	begin
	--		if @PBranch_ID <> '0' and isnull(@Branch_ID,0) = 0  -- added by mitesh on 02042012
	--			begin
				
	--				Insert Into #Emp_Cons
					
	--				select I.Emp_Id from dbo.T0095_Increment I inner join 
	--						( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment
	--						where Increment_Effective_date <= @To_Date
	--						and Cmp_ID = @Cmp_ID
	--						group by emp_ID  ) Qry on
	--						I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID
	--				Where Cmp_ID = @Cmp_ID 
	--				and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--				--and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--				and Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--				and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--				and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--				and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--				and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 21082013
	--				and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 21082013
	--			    and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 21082013
	--		        and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 21082013
   
	--				and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--				and Branch_ID in (select cast(data as numeric) from dbo.Split(@PBranch_ID,'#'))
	--				and I.Emp_ID in 
	--					( select Emp_Id from
	--					(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--					where cmp_ID = @Cmp_ID   and  
	--					(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--					or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--					or Left_date is null and @To_Date >= Join_Date)
	--					or @To_Date >= left_date  and  @From_Date <= left_date ) 
	--			end
	--		else
	--			begin
				
	--				Insert Into #Emp_Cons

	--				select I.Emp_Id from dbo.T0095_Increment I inner join 
	--						( select max(Increment_ID) as Increment_ID , Emp_ID from dbo.T0095_Increment
	--						where Increment_Effective_date <= @To_Date
	--						and Cmp_ID = @Cmp_ID
	--						group by emp_ID  ) Qry on
	--						I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID
	--				Where Cmp_ID = @Cmp_ID 
	--				and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--				and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--				and Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--				and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--				and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--				and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--				and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 21082013
	--				and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 21082013
	--			    and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 21082013
	--		        and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 21082013
   
	--				and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--				and I.Emp_ID in 
	--					( select Emp_Id from
	--					(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--					where cmp_ID = @Cmp_ID   and  
	--					(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--					or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--					or Left_date is null and @To_Date >= Join_Date)
	--					or @To_Date >= left_date  and  @From_Date <= left_date ) 
	--			end
			
	--	end
	
	
	DECLARE CUR_EMP CURSOR FOR
	SELECT sg.EMP_ID  FROM dbo.T0200_MONTHLY_SALARY SG WITH (NOLOCK) INNER JOIN
	T0080_EMP_MASTER E WITH (NOLOCK) ON sg.EMP_ID =e.EMP_ID 
	INNER JOIN /*	EMP_OTHER_DETAIL eod ON e.EMP_ID = eod.EMP_ID Inner join*/ #Emp_Cons ec on E.Emp_ID = Ec.Emp_ID 
	Inner join ( select dbo.T0095_Increment.Emp_Id ,Type_ID ,Grd_ID,Dept_ID,Desig_Id,Branch_ID,Cat_ID,Payment_Mode from t0095_Increment WITH (NOLOCK) inner join 
									( select max(Increment_ID) as Increment_ID , Emp_ID from t0095_Increment WITH (NOLOCK)
									where Increment_Effective_date <= @To_Date
									and Cmp_ID = @Cmp_ID
									group by emp_ID  ) Qry
									on t0095_Increment.Emp_ID = Qry.Emp_ID and
									t0095_Increment.Increment_ID   = Qry.Increment_ID	
							where Cmp_ID = @Cmp_ID ) I_Q on 
					e.Emp_ID = I_Q.Emp_ID
	WHERE  sg.Cmp_ID = @Cmp_ID 
	AND Month(sg.Month_End_Date) = @MONTH AND Year(sg.Month_End_Date) = @YEAR And isnull(sg.is_FNF,0)=0
		--AND Payment_Mode LIKE isnull(@PAYEMENT,Payment_Mode)
	OPEN  CUR_EMP
	FETCH NEXT FROM CUR_EMP INTO @EMP_ID
	WHILE @@FETCH_STATUS = 0
		BEGIN
						
						SET @Allow_Name = ''
						SET @Row_id  = 0
						SET @Label_Name  = ''
						SET @Total_Allowance = 0
						SET @Is_Search = ''
						SET @Basic_salary = 0
						SET @Total_Allow = 0
						SET @Value_String = ''
						SET @Amount = 0 
						SET @OTher_Allow =0
						set @CO_Amount = 0
						SET @Total_Deduction =0
						SET @Late_Deduction = 0
						SET @Other_Dedu =0
						SET @Loan =0
						SET @Advance =0
						SET @Net_Salary =0
						SET @PT =0
						SET @LWF =0
						SET @Revenue = 0
						set @P_Days = 0
						Set @A_Days=0
						set @Revenue_amt =0
						set @Lwf_amt  =0
						set @Act_Gross_salary = 0
						set @TDS=0
						set @Settl=0
						Set @Deficit_Amt = 0
						set @Claim_Amount = 0
						
						Declare @GatePass_Deduct_Days numeric(18,2) -- Added by Gadriwala Muslim 09012015
						Declare @GatePass_Amount numeric(18,2) -- Added by Gadriwala Muslim 09012015
						set @GatePass_Deduct_Days = 0
						set @GatePass_Amount = 0
						
					If @Sal_Type = 0
						Begin
							--select @P_Days = Present_Days + Holiday_Days , @Basic_Salary = Salary_Amount from Salary_Generation where Emp_ID = @Emp_ID and Month = @Month and Year = @Year
							select @P_Days = isnull(Present_Days,0) ,@A_Days = isnull(Absent_Days,0),@TDS=isnull(M_IT_TAX,0), @Basic_Salary = Salary_Amount, @Act_Gross_salary = Actually_Gross_salary,@Settl = Settelement_Amount,@OTher_Allow = ISNULL(Other_Allow_Amount,0),@Total_Allowance = Allow_Amount,@GatePass_Deduct_Days = ISNULL(GatePass_Deduct_Days,0),@GatePass_Amount = ISNULL(GatePass_Amount,0) -- Added by Gadriwala Muslim 10112014
							,@Claim_Amount=Total_Claim_Amount
							from dbo.T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @Emp_ID and Month(Month_End_date) = @Month and Year(Month_End_date) = @Year 
						End
					Else
						Begin
							select @P_Days = isnull(S_Sal_Cal_Days,0) ,@A_Days = 0,@TDS=isnull(S_M_IT_TAX,0), @Basic_Salary = S_Salary_Amount, @Act_Gross_salary = S_Actually_Gross_salary,@Settl = 0,@OTher_Allow = ISNULL(S_Other_Allow_Amount,0),@Total_Allowance = S_Allow_Amount
							from dbo.T0201_MONTHLY_SALARY_SETT WITH (NOLOCK) where Emp_ID = @Emp_ID and Month(S_Month_End_date) = @Month and Year(S_Month_End_date) = @Year 
						End
						
					
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'P Days', @P_Days,'',2,'P')
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'A Days', @A_Days,'',3,'P')
					
				/*	INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Gross', @Act_Gross_salary,'',4)*/

					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year,'Basic', @Basic_Salary,'',5,'I')
					
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Settl', @Settl,'',6,'I')
					
					
					INSERT INTO dbo.#Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Other', @OTher_Allow,'',7,'I')


					Declare Cur_Label cursor for 
					SELECT Label_Name ,Row_ID FROM dbo.#TEMP_REPORT_LABEL where Row_ID > 7
					open Cur_label
					fetch next from Cur_label into @Label_Name ,@Row_ID
					while @@fetch_Status = 0
						begin
							INSERT INTO dbo.#Temp_Salary_Muster_Report
							(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id,M_AD_Flage)
							VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, @Label_Name, 0,'',@Row_ID,'')
							fetch next from Cur_label into @Label_Name,@Row_ID
						end
					close Cur_Label
					deallocate Cur_Label

					  Update  #Temp_Salary_Muster_Report
					  set M_AD_Flage ='I' from #Temp_Salary_Muster_Report E1
					  inner join T0050_AD_MASTER AD
					  on AD.AD_SORT_NAME =E1.Label_Name and ad.cmp_id = e1.cmp_id--Falak,Hardik,Nikunj 16-05-2011
					  where E1.Emp_ID =@Emp_ID and E1.Cmp_ID=@Cmp_ID
					   and AD.AD_Flag ='I'  		

					Declare @AD_Flage as char(1)
					set @Label_Name  = ''
					
						declare Cur_Allow   cursor for
						select Ad_Sort_Name ,M_Ad_Amount,t0050_ad_master.AD_Flag from t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
							t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID
							and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
							and MAD.Emp_ID  = @Emp_ID
						where 
						MAD.Cmp_ID = @Cmp_ID and month(MAD.To_date) =  @Month and Year(MAD.To_date) = @Year
						and isnull(t0050_ad_master.Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 and AD_Flag = 'I'
						And Sal_Type = @Sal_Type
					open cur_allow
					fetch next from cur_allow  into @Allow_Name ,@Amount,@AD_Flage
					while @@fetch_status = 0
						begin
							
							select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like @Allow_Name 

 							UPDATE    dbo.#Temp_Salary_Muster_Report
 							SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
 												  Amount = @Amount, Value_String = '',M_AD_Flage=@AD_Flage
 							where   Label_Name = @Allow_Name and Row_id = @row_Id                  
 									and Emp_ID = @Emp_ID  
							fetch next from cur_allow  into @Allow_Name,@Amount,@AD_Flage
						end
					close cur_Allow
					deallocate Cur_Allow
					
					

						/*select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Oth A'		

						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Other_Allow, Value_String = ''
						where   Label_Name = 'Oth A' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID*/

						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'CO A'		

						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @CO_Amount, Value_String = '',M_AD_Flage='I'
						where   Label_Name = 'CO A' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID
						
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Claim Amt' --Mukti(28012017)		

						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Claim_Amount, Value_String = '',M_AD_Flage='I'
						where   Label_Name = 'Claim Amt' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID
										
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Gross'

						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
											  Amount = @Total_Allowance+@Basic_Salary+isnull(@Settl,0)+ISNULL(@OTher_Allow,0)+isnull(@CO_Amount,0), Value_String = '',M_AD_Flage='I'
						WHERE     (Label_Name = 'Gross') AND (Row_id = @Row_ID)
								  and Emp_ID = @Emp_ID

						/*select @Amount = M_Ad_Calculated_Amount From t0210_monthly_ad_detail where Emp_Id =@Emp_ID and Month(For_Date)=  @month and YEar(For_Date) = @Year and Ad_ID =2
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'PF Salary'	*/	
					
						
						/*UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Amount, Value_String = ''
						where   Label_Name = 'PF Salary' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID
								*/
						set @Amount =0

						/*select @Amount = M_AD_Calculated_Amount From t0210_monthly_ad_detail where Emp_Id = @Emp_ID and Month(For_Date)=  @month and YEar(For_Date) = @Year and Ad_ID =3 and M_Ad_Amount >0
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'ESIC Salary'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Amount, Value_String = ''
						where   Label_Name = 'ESIC Salary' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID*/
						/*	select Ad_Sort_Name ,M_Ad_Amount,MAd.Emp_Id from t0210_monthly_ad_detail MAD inner join
							t0050_ad_master on MAD.Ad_Id = t0050_ad_master.Ad_ID left outer join #Temp_Salary_Muster_Report---Left Outer Forgot by Nilay put by nikunj 27-04-2011
							on MAD.Emp_Id = #Temp_Salary_Muster_Report.Emp_ID 
							and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
							and MAD.Emp_ID  = @Emp_ID
						where 
						MAD.Cmp_ID = @Cmp_ID and Month(MAD.For_Date) =  @Month and Year(MAD.For_Date) = @Year
						and Ad_Active = 1 and AD_Flag = 'D' and isnull(t0050_ad_master.Ad_Not_Effect_Salary,0)=0 */
								
					declare Cur_Dedu   cursor for
						select Ad_Sort_Name ,M_Ad_Amount,t0050_ad_master.AD_Flag from t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
							t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID 							
							and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
							and MAD.Emp_ID  = @Emp_ID
						where 
						MAD.Cmp_ID = @Cmp_ID and Month(MAD.To_date) =  @Month and Year(MAD.To_date) = @Year
						and Ad_Active = 1 and AD_Flag = 'D' and isnull(t0050_ad_master.Ad_Not_Effect_Salary,0)=0
						And Sal_Type = @Sal_Type
					open Cur_Dedu
					fetch next from cur_DEDU  into @Allow_Name ,@Amount,@AD_Flage
					while @@fetch_status = 0
						begin
							select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like @Allow_Name 
							
							UPDATE    dbo.#Temp_Salary_Muster_Report
							SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Amount, 
												  Value_String = '',M_AD_Flage=@AD_Flage
							WHERE     (Label_Name = @Allow_Name) AND (Row_id = @Row_ID)
									and Emp_ID = @Emp_ID
							fetch next from Cur_Dedu into @Allow_Name,@Amount,@AD_Flage
						end
					close Cur_Dedu
					deallocate Cur_Dedu

					 Update  #Temp_Salary_Muster_Report
					  set M_AD_Flage ='D' from #Temp_Salary_Muster_Report E1
					  inner join T0210_MONTHLY_AD_DETAIL E on E1.Emp_ID =E.Emp_ID inner join T0050_AD_MASTER AD
					  on AD.AD_ID =E.AD_ID where E1.Emp_ID =@Emp_ID and E1.Cmp_ID=@Cmp_ID
					   and E1.M_AD_Flage ='' 
					
					  Update  #Temp_Salary_Muster_Report
					  set M_AD_Flage =AD_Flag from #Temp_Salary_Muster_Report E1
					  inner join T0050_AD_MASTER AD
					  on AD.Ad_Sort_Name =E1.Label_Name where E1.Emp_ID =@Emp_ID and E1.Cmp_ID=@Cmp_ID
					   and E1.M_AD_Flage ='' 

						select @Total_Deduction = Total_Dedu_Amount ,@PT = PT_Amount ,@Loan =  ( Loan_Amount + Loan_Intrest_Amount ) 
								,@Advance =  Advance_Amount ,@Net_Salary = Net_Amount ,@Revenue_Amt =Revenue_amount,@LWF_Amt =LWF_Amount,@Other_Dedu=Other_Dedu_Amount,
								@Deficit_Amt = Isnull(Deficit_Dedu_Amount,0)
								,@Late_Deduction = Late_Dedu_Amount
						from T0200_Monthly_salary WITH (NOLOCK) where Emp_ID = @Emp_ID and Month(Month_End_date) = @Month and Year(Month_End_date) = @Year
						--Select @Other_Dedu  = 0
						
					--	set @Loan = @Loan + @Advance

		--				select @Row_ID = Row_ID from Temp_report_label where Label_Name like 'Other Dedu'

		--				INSERT INTO Temp_Salary_Muster_Report


		--						   (Emp_ID, Company_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
		--				VALUES     (@Emp_ID, @Company_ID, @Transaction_ID, @Month, @Year, 'Other Dedu', @Other_Dedu,'',@Row_ID)
						
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'PT'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @PT, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'PT') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Loan'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Loan, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'Loan') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								
								
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Advnc'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Advance, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'Advnc') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
						
						
						if @Revenue_Amt >0
							begin
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Revenue'
								
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Revenue_Amt, 
													  Value_String = '',M_AD_Flage='D'
								WHERE     (Label_Name = 'Revenue') AND (Row_id = @Row_ID)
										and Emp_ID = @Emp_ID
							end
						if @LWF_amt > 0
							begin
								select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'LWF'
								
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @lwf_Amt, 
													  Value_String = '',M_AD_Flage='D'
								WHERE     (Label_Name = 'LWF') AND (Row_id = @Row_ID)
										and Emp_ID = @Emp_ID
							end							
						--Added by gadriwala Muslim 09012015 - Start		
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Gate Pass'
								UPDATE    dbo.#Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @GatePass_Amount, 
											  Value_String = '',M_AD_Flage='D'
								WHERE     (Label_Name = 'Gate Pass') AND (Row_id = @Row_ID)
									and Emp_ID = @Emp_ID
									
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'TDS'
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @TDS, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'TDS') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
						
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Oth De'
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Other_Dedu, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'Oth De') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID

						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Deficit Amt'
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Deficit_Amt, 
											  Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'Deficit Amt') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID

						
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Dedu'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
											  Amount = @Total_Deduction, Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'Dedu') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID	
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Net'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Net_Salary, 
											  Value_String = '',M_AD_Flage='N'
						WHERE     (Label_Name = 'Net') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								
								
						---added by jimit 28072017
						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Late Dedu.'
						
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
											  Amount = @Late_Deduction, Value_String = '',M_AD_Flage='D'
						WHERE     (Label_Name = 'Late Dedu.') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
						--ended
								
								
			FETCH NEXT FROM CUR_EMP INTO @EMP_ID
		END
	Close CUR_EMP
	Deallocate CUR_EMP	
	
	Update dbo.#Temp_Salary_Muster_Report Set Month = MONTH(@To_Date), Year = YEAR(@To_Date)
	
	-- Changed By Ali 22112013 EmpName_Alias
	select dbo.#Temp_Salary_Muster_Report.* , E.Emp_Code, E.Alpha_Emp_Code, E.Emp_First_Name
	--,cast( E.Alpha_Emp_Code as varchar) + ' - '+E.Emp_Full_Name as Emp_Full_Name
	,ISNULL(E.EmpName_Alias_Salary,cast(E.Alpha_Emp_Code as varchar) + ' - '+ E.Emp_Full_Name) as Emp_Full_Name
	,GM.Grd_name,ETM.Type_name,DGM.Desig_Name,DM.Dept_Name,BM.Branch_Name,
	E.Dept_ID,Cmp_Name,Cmp_Address,Inc_Qry.Inc_Bank_Ac_no ,BM.comp_name,BM.Branch_Address--added by Falak on 14-MAR-2011
	,DGM.Desig_Dis_No     --added jimit 24082015
	from dbo.#Temp_Salary_Muster_Report Inner join
		T0080_Emp_Master E WITH (NOLOCK) on dbo.#Temp_Salary_Muster_Report.Emp_Id = E.Emp_ID inner join
		( select I.Emp_Id ,Grd_ID,DEsig_ID ,Dept_ID,Inc_Bank_Ac_no,Branch_ID,Type_ID from t0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID, Emp_ID from t0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID )Inc_Qry on 
		E.Emp_ID = Inc_Qry.Emp_ID left outer join t0040_department_Master WITH (NOLOCK)
		on Inc_Qry.dept_ID = t0040_department_Master.Dept_ID LEFT OUTER JOIN
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON Inc_Qry.Grd_ID = GM.Grd_ID				LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON Inc_Qry.Type_ID = ETM.Type_ID			LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Inc_Qry.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Inc_Qry.Dept_Id = DM.Dept_Id		INNER JOIN 
					T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Inc_Qry.BRANCH_ID = BM.BRANCH_ID		inner join 
					t0010_company_master CM WITH (NOLOCK) on E.cmp_id=CM.cmp_id
					Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
		--order by Row_ID
		
		--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500),Row_ID


	--Added by hardik on 16/03/2012 for recordset -- Labels
	Select Distinct Label_name,Row_ID,M_AD_Flage  from dbo.#Temp_Salary_Muster_Report  
	where M_AD_Flage <> ''
	order by Row_ID	

	--Added by hardik on 16/03/2012 for recordset -- Totals
	Select Sum(Amount) as Amount ,Row_ID,Label_Name,M_AD_Flage from dbo.#Temp_Salary_Muster_Report
	where M_AD_Flage <> ''
	Group by Label_Name,Row_ID,M_AD_Flage 
	order by Row_ID
		
	DROP TABLE #Temp_report_Label		
	DROP TABLE #Temp_Salary_Muster_Report
	
	RETURN




