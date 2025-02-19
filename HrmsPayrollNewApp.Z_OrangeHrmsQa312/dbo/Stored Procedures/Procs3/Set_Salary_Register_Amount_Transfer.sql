




--Created By Falak On 10-SEP-2010
---19/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[Set_Salary_Register_Amount_Transfer]
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
,@Bank_id	   numeric = 0
,@Payment_mode varchar(100) = ''
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
	Declare @Basic_salary_Rate as numeric(22,2)
	Declare @Basic_salary as numeric(22,2)
	Declare @Total_Allow as numeric (22,2)
	declare @Value_String as varchar(250)
	Declare @Amount as numeric (22,2)

	Declare @OTher_Allow as numeric(22,2)
	Declare @CO_Amount as numeric(22,2)
	Declare @Total_Deduction as numeric(22,2)
	Declare @Late_Deduction as numeric(22,2)
	Declare @Other_Dedu as numeric(22,2)
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
	Declare @H_Days as numeric(22,2)   -- Added by Mihir 13042012
	Declare @W_Days as numeric(22,2)   -- Added by Mihir 13042012
	Declare @L_Days as numeric(22,2)   -- Added by Mihir 13042012
	DEclare @month_end as numeric(18,0)
	Declare @Year_end as numeric(18,0)
	Declare @Deficit_Amt Numeric(18,2) -- Added by Hardik 14/11/2013 for Pakistan
	
	CREATE table #Temp_report_Label
	(
	Row_ID  numeric(18, 0) NOt null,
	Label_Name  varchar(200) not null,
	Income_Tax_ID numeric(18, 0) null,
	Is_Active	varchar(1) null
	)
		
	CREATE table #Temp_Salary_Muster_Report		
	(
	Emp_ID numeric(18, 0) Not Null,
	Cmp_ID numeric(18, 0) Not Null,
	Transaction_ID numeric(18, 0) Not Null,
	Month numeric(18, 0) Not Null,
	Year numeric(18, 0) Not Null,
	Label_Name varchar(200) Not Null,
	Amount numeric(18, 2) null,
	Value_String varchar(250) Not Null,
	INCOME_TAX_ID numeric(18, 0)  Null,
	Row_id numeric(18, 0) Null
	
	)
		
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
		
	If @Bank_id = 0
		set @Bank_ID = null
		
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
 		
	
	--if @Payment_mode <> 'Bank Transfer'
	--	set @Bank_ID = 0	
	
	
	--Added by Mihir 13042012
	Declare @Sal_St_Date   Datetime    
	Declare @Sal_end_Date   Datetime  
	
 If @Branch_ID is null
		Begin 
			select Top 1 @Sal_St_Date  = Sal_st_Date 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Cmp_ID = @Cmp_ID)    
		End
	Else
		Begin
			select @Sal_St_Date  =Sal_st_Date 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
		End
   
 if isnull(@Sal_St_Date,'') = ''    
	  begin    
		   set @From_Date  = @From_Date     
		   set @To_Date = @To_Date    
		   
	  end     
 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)= 1    
	  begin    
		   set @From_Date  = @From_Date     
		   set @To_Date = @To_Date     
		   	         
	  end     
 else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
	  begin    
		   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
		   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
		   
		   
		   Set @From_Date = @Sal_St_Date
		   Set @To_Date = @Sal_End_Date    
	  end
	
	--End of Mihir 13042012
	set @month = month(@From_Date)
	set @Year = Year(@From_Date)
	
	set @month_end = month(@To_Date)
	set @Year_end = Year(@To_Date)
	  
	EXEC Set_Salary_Register_Lable_Transfer @Cmp_ID ,@month , @Year
	
	CREATE TABLE #Emp_Cons	-- Ankit 05092014 for Same Date Increment
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 
	
	 
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
	--		Insert Into #Emp_Cons

	--		select I.Emp_Id from T0095_Increment I inner join 
	--				( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
	--		Where Cmp_ID = @Cmp_ID 
	--		and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--		and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--		and Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--		and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--		and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--		and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--		and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 21082013
	--		and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 21082013
	--		and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 21082013
	--		and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 21082013
    
	--		and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--		and I.Emp_ID in 
	--			( select Emp_Id from
	--			(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--			where cmp_ID = @Cmp_ID   and  
	--			(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--			or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--			or Left_date is null and @To_Date >= Join_Date)
	--			or @To_Date >= left_date  and  @From_Date <= left_date ) 
	--	end
	
	
If @Payment_mode = ''
	Begin
		DECLARE CUR_EMP CURSOR FOR
		SELECT sg.EMP_ID  FROM T0200_MONTHLY_SALARY SG WITH (NOLOCK) INNER JOIN
		T0080_EMP_MASTER E WITH (NOLOCK) ON sg.EMP_ID =e.EMP_ID 
		INNER JOIN  #Emp_Cons ec on E.Emp_ID = Ec.Emp_ID 
		WHERE  sg.Cmp_ID = @Cmp_ID 
		AND Month(sg.Month_end_Date) = @MONTH_end AND Year(sg.Month_end_Date) = @YEAR_end And isnull(sg.is_FNF,0)=0
			--AND Payment_Mode LIKE isnull(@Payment_mode,Payment_Mode)
		order by E.Emp_First_Name
		OPEN  CUR_EMP
	End
Else If @Payment_mode <> 'Bank Transfer'
	Begin
		DECLARE CUR_EMP CURSOR FOR
		SELECT sg.EMP_ID  FROM T0200_MONTHLY_SALARY SG WITH (NOLOCK) INNER JOIN
		T0080_EMP_MASTER E WITH (NOLOCK) ON sg.EMP_ID =e.EMP_ID 
		INNER JOIN /*	EMP_OTHER_DETAIL eod ON e.EMP_ID = eod.EMP_ID Inner join*/ #Emp_Cons ec on E.Emp_ID = Ec.Emp_ID 
		WHERE  sg.Cmp_ID = @Cmp_ID 
		AND Month(sg.Month_end_Date) = @MONTH_end AND Year(sg.Month_end_Date) = @YEAR_end And isnull(sg.is_FNF,0)=0
			AND Payment_Mode LIKE isnull(@Payment_mode,Payment_Mode)
		order by E.Emp_First_Name
		OPEN  CUR_EMP
	End
Else
	Begin
		
		DECLARE CUR_EMP CURSOR FOR
		SELECT sg.EMP_ID  FROM T0200_MONTHLY_SALARY SG WITH (NOLOCK) INNER JOIN
		T0080_EMP_MASTER E WITH (NOLOCK) ON sg.EMP_ID =e.EMP_ID 
		INNER JOIN /*	EMP_OTHER_DETAIL eod ON e.EMP_ID = eod.EMP_ID Inner join*/ #Emp_Cons ec on E.Emp_ID = Ec.Emp_ID 
		WHERE  sg.Cmp_ID = @Cmp_ID 
		AND Month(sg.Month_end_Date) = @MONTH_end AND Year(sg.Month_end_Date) = @YEAR_end And isnull(sg.is_FNF,0)=0
		And I_Q.Bank_Id =Isnull(@Bank_Id, I_Q.Bank_Id)
			--AND Payment_Mode LIKE isnull(@PAYEMENT,Payment_Mode)
		order by E.Emp_First_Name
		OPEN  CUR_EMP
	End
	FETCH NEXT FROM CUR_EMP INTO @EMP_ID
	WHILE @@FETCH_STATUS = 0
		BEGIN
						
						SET @Allow_Name = ''
						SET @Row_id  = 0
						SET @Label_Name  = ''
						SET @Total_Allowance = 0
						SET @Is_Search = ''
						SET @Basic_salary = 0
						SET @Basic_salary_Rate = 0
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
						set @Transaction_ID = @Transaction_ID + 1
						set @H_Days=0 -- Added by Mihir 13042012
						set @W_Days=0 -- Added by Mihir 13042012
						set @L_Days=0 -- Added by Mihir 13042012
						Set @Deficit_Amt = 0
						
					If @Sal_Type = 0
						Begin
							--select @P_Days = Present_Days + Holiday_Days , @Basic_Salary = Salary_Amount from Salary_Generation where Emp_ID = @Emp_ID and Month = @Month and Year = @Year
							select @P_Days = isnull(Present_Days,0) ,@A_Days = isnull(Absent_Days,0),@TDS=isnull(M_IT_TAX,0), @Basic_Salary = Salary_Amount, @Act_Gross_salary = Actually_Gross_salary,@Settl = Settelement_Amount,@OTher_Allow = ISNULL(Other_Allow_Amount,0),@Total_Allowance = Allow_Amount
							from dbo.T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID = @Emp_ID and Month(Month_End_Date) = @month_end and Year(Month_End_Date) = @Year_end
						End
					Else
						Begin
							select @P_Days = isnull(S_Sal_Cal_Days,0) ,@A_Days = 0,@TDS=isnull(S_M_IT_TAX,0), @Basic_Salary = S_Salary_Amount, @Act_Gross_salary = S_Actually_Gross_salary,@Settl = 0,@OTher_Allow = ISNULL(S_Other_Allow_Amount,0),@Total_Allowance = S_Allow_Amount
							from dbo.T0201_MONTHLY_SALARY_SETT WITH (NOLOCK) where Emp_ID = @Emp_ID and Month(S_Month_End_Date) = @month_end and Year(S_Month_End_Date) = @Year_end 
						End
					
					select @Basic_salary_Rate = I.Basic_Salary  from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID
					Where I.Cmp_ID = @Cmp_ID and I.Emp_ID = @Emp_ID and I.Branch_ID = ISNULL(@Branch_ID ,I.Branch_Id) 
					
					INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'P Days', @P_Days,'',2)
					INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'A Days', @A_Days,'',3)
					
					---Added by Mihir 13042012
					INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'W Days', @W_Days,'',4)
					
					INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'H Days', @H_Days,'',5)
					
					INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'L Days', @L_Days,'',6)
					
					
					---- END of added by Mihir 13042012
					
				/*	INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Gross', @Act_Gross_salary,'',4)*/

					INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Basic Rate', @Basic_salary_Rate ,'',7)
					
					INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Basic', @Basic_Salary,'',8)
					
					INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Settl', @Settl,'',9)
					
					
					INSERT INTO #Temp_Salary_Muster_Report
					(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
					VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, 'Other', @OTher_Allow,'',10)


					Declare Cur_Label cursor for 
					SELECT Label_Name ,Row_ID FROM #TEMP_REPORT_LABEL where Row_ID > 10
					open Cur_label
					fetch next from Cur_label into @Label_Name ,@Row_ID
					while @@fetch_Status = 0
						begin
							INSERT INTO #Temp_Salary_Muster_Report
							(Emp_ID, Cmp_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
							VALUES     (@Emp_ID, @Cmp_ID, @Transaction_ID, @Month, @Year, @Label_Name, 0,'',@Row_ID)
							fetch next from Cur_label into @Label_Name,@Row_ID
						end
					close Cur_Label
					deallocate Cur_Label


					set @Label_Name  = ''
					
						declare Cur_Allow   cursor for
						select Ad_Sort_Name ,M_Ad_Amount from t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
							t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID
							and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
							and MAD.Emp_ID  = @Emp_ID
						where 
						MAD.Cmp_ID = @Cmp_ID and month(MAD.For_Date) =  @Month and Year(MAD.For_Date) = @Year
						and isnull(t0050_ad_master.Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 and AD_Flag = 'I'
						And Sal_Type = @sal_Type
					open cur_allow
					fetch next from cur_allow  into @Allow_Name ,@Amount
					while @@fetch_status = 0
						begin
							
							select @Row_ID = Row_ID from #Temp_report_label where Label_Name like @Allow_Name 

 							UPDATE    #Temp_Salary_Muster_Report
 							SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
 												  Amount = @Amount, Value_String = ''
 							where   Label_Name = @Allow_Name and Row_id = @row_Id                  
 									and Emp_ID = @Emp_ID  
							fetch next from cur_allow  into @Allow_Name,@Amount
						end
					close cur_Allow
					deallocate Cur_Allow
					
					

					declare CUR_REIMB   cursor for
 						SELECT DISTINCT RIMB_NAME FROM T0100_RIMBURSEMENT_DETAIL WITH (NOLOCK) INNER JOIN
						T0055_REIMBURSEMENT WITH (NOLOCK) ON T0055_REIMBURSEMENT.RIMB_ID = T0100_RIMBURSEMENT_DETAIL.RIMB_ID AND
						T0055_REIMBURSEMENT.Cmp_ID = T0055_REIMBURSEMENT.Cmp_ID
						WHERE T0100_RIMBURSEMENT_DETAIL.Cmp_ID =@Cmp_ID
						AND month(T0100_RIMBURSEMENT_DETAIL.For_Date) = @MONTH
						AND year(T0100_RIMBURSEMENT_DETAIL.For_Date) = @YEAR
						AND T0100_RIMBURSEMENT_DETAIL.EMP_ID = @EMP_ID
					open CUR_REIMB
					fetch next from CUR_REIMB into @Allow_Name
					while @@fetch_status = 0
						begin
							
							select @Row_ID = Row_ID from #Temp_report_label where Label_Name like @Allow_Name 

							UPDATE    #Temp_Salary_Muster_Report
							SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
											 Amount = @Amount, Value_String = '' 
							where   Label_Name = @Allow_Name and Row_id = @row_Id                    
									and Emp_ID = @Emp_ID
							fetch next from CUR_REIMB into @Allow_Name,@AMOUNT
						end
					close CUR_REIMB
					deallocate CUR_REIMB
						


						/*select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Oth A'		

						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Other_Allow, Value_String = ''
						where   Label_Name = 'Oth A' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID*/

						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'CO A'		

						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @CO_Amount, Value_String = ''
						where   Label_Name = 'CO A' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID
								
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Gross'

						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
											  Amount = @Total_Allowance+@Basic_Salary+isnull(@Settl,0)+ISNULL(@OTher_Allow,0)+isnull(@CO_Amount,0), Value_String = ''
						WHERE     (Label_Name = 'Gross') AND (Row_id = @Row_ID)
								  and Emp_ID = @Emp_ID

						/*select @Amount = M_Ad_Calculated_Amount From t0210_monthly_ad_detail where Emp_Id =@Emp_ID and Month(For_Date)=  @month and YEar(For_Date) = @Year and Ad_ID =2
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'PF Salary'	*/	
					
						
						/*UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Amount, Value_String = ''
						where   Label_Name = 'PF Salary' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID
								*/
						set @Amount =0

						/*select @Amount = M_AD_Calculated_Amount From t0210_monthly_ad_detail where Emp_Id = @Emp_ID and Month(For_Date)=  @month and YEar(For_Date) = @Year and Ad_ID =3 and M_Ad_Amount >0
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'ESIC Salary'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year,
											   Amount = @Amount, Value_String = ''
						where   Label_Name = 'ESIC Salary' and Row_id = @row_Id                    
								and Emp_ID = @Emp_ID*/

								
					declare Cur_Dedu   cursor for
						select Ad_Sort_Name ,M_Ad_Amount from t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
							t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID
							and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
							and MAD.Emp_ID  = @Emp_ID
						where 
						MAD.Cmp_ID = @Cmp_ID and Month(MAD.For_Date) =  @Month and Year(MAD.For_Date) = @Year
						and Ad_Active = 1 and AD_Flag = 'D' and isnull(t0050_ad_master.Ad_Not_Effect_Salary,0)=0
						And Sal_Type = @sal_Type
					open Cur_Dedu
					fetch next from cur_DEDU  into @Allow_Name ,@Amount
					while @@fetch_status = 0
						begin
							select @Row_ID = Row_ID from #Temp_report_label where Label_Name like @Allow_Name 
							
							UPDATE    #Temp_Salary_Muster_Report
							SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Amount, 
												  Value_String = ''
							WHERE     (Label_Name = @Allow_Name) AND (Row_id = @Row_ID)
									and Emp_ID = @Emp_ID
							fetch next from Cur_Dedu into @Allow_Name,@Amount
						end
					close Cur_Dedu
					deallocate Cur_Dedu

						If @Sal_Type = 0
							select @Total_Deduction = Total_Dedu_Amount ,@PT = PT_Amount ,@Loan =  ( Loan_Amount + Loan_Intrest_Amount ) 
									,@Advance =  Advance_Amount ,@Net_Salary = Net_Amount ,@Revenue_Amt =Revenue_amount,@LWF_Amt =LWF_Amount,@Other_Dedu=Other_Dedu_Amount,
									@Deficit_Amt = Deficit_Dedu_Amount
									,@Late_Deduction = Late_Dedu_Amount
							from T0200_Monthly_salary WITH (NOLOCK) where Emp_ID = @Emp_ID and Month(Month_St_Date) = @Month and Year(Month_St_Date) = @Year
						Else
							select @Total_Deduction = S_Total_Dedu_Amount ,@PT = S_PT_Amount ,@Loan =  (S_Loan_Amount + S_Loan_Intrest_Amount ) 
									,@Advance =  S_Advance_Amount ,@Net_Salary = S_Net_Amount ,@Revenue_Amt =S_Revenue_Amount,@LWF_Amt =S_LWF_Amount,@Other_Dedu=S_Other_Dedu_Amount
							from T0201_MONTHLY_SALARY_SETT WITH (NOLOCK) where Emp_ID = @Emp_ID and Month(S_Month_St_Date) = @Month and Year(S_Month_St_Date) = @Year
						--Select @Other_Dedu  = 0
						
					--	set @Loan = @Loan + @Advance

		--				select @Row_ID = Row_ID from Temp_report_label where Label_Name like 'Other Dedu'

		--				INSERT INTO Temp_Salary_Muster_Report


		--						   (Emp_ID, Company_ID, Transaction_ID, Month, Year, Label_Name, Amount, Value_String,Row_id)
		--				VALUES     (@Emp_ID, @Company_ID, @Transaction_ID, @Month, @Year, 'Other Dedu', @Other_Dedu,'',@Row_ID)
						
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'PT'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @PT, 
											  Value_String = ''
						WHERE     (Label_Name = 'PT') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Loan'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Loan, 
											  Value_String = ''
						WHERE     (Label_Name = 'Loan') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
								
								
								select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Advnc'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Advance, 
											  Value_String = ''
						WHERE     (Label_Name = 'Advnc') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
						
						
						if @Revenue_Amt >0
							begin
								select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Revenue'
								
								UPDATE    #Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Revenue_Amt, 
													  Value_String = ''
								WHERE     (Label_Name = 'Revenue') AND (Row_id = @Row_ID)
										and Emp_ID = @Emp_ID
							end
						if @LWF_amt > 0
							begin
								select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'LWF'
								
								UPDATE    #Temp_Salary_Muster_Report
								SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @lwf_Amt, 
													  Value_String = ''
								WHERE     (Label_Name = 'LWF') AND (Row_id = @Row_ID)
										and Emp_ID = @Emp_ID
							end							
								
					
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'TDS'
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @TDS, 
											  Value_String = ''
						WHERE     (Label_Name = 'TDS') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
						
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Oth De'
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Other_Dedu, 
											  Value_String = ''
						WHERE     (Label_Name = 'Oth De') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID

						select @Row_ID = Row_ID from dbo.#TEMP_REPORT_LABEL where Label_Name like 'Deficit Amt'
						UPDATE    dbo.#Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Deficit_Amt, 
											  Value_String = ''
						WHERE     (Label_Name = 'Deficit Amt') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID

						
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Dedu'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
											  Amount = @Total_Deduction, Value_String = ''
						WHERE     (Label_Name = 'Dedu') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID	
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Net'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, Amount = @Net_Salary, 
											  Value_String = ''
						WHERE     (Label_Name = 'Net') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
						
						--added by jimit 28072017
						select @Row_ID = Row_ID from #Temp_report_label where Label_Name like 'Late Dedu.'
						
						UPDATE    #Temp_Salary_Muster_Report
						SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Transaction_ID = @Transaction_ID, Month = @Month, Year = @Year, 
											  Amount = @Late_Deduction, Value_String = ''
						WHERE     (Label_Name = 'Late Dedu.') AND (Row_id = @Row_ID)
								and Emp_ID = @Emp_ID
						--ended		
								
			FETCH NEXT FROM CUR_EMP INTO @EMP_ID
		END
	Close Cur_Emp
	Deallocate Cur_emp	
	
	--Declare @T_Br_Name as varchar(100)
	--Declare @T_Br_Comp_Name as varchar(100)
	
	--select @T_Br_Comp_Name = Comp_Name ,@T_Br_Name = Branch_Name  from T0030_BRANCH_MASTER where Branch_ID = isnull(@Branch_ID ,0)
	
	
	
	if @Payment_mode = 'Bank Transfer'  and Isnull(@Bank_id,0) = 0
		begin
			-- Changed By Ali 22112013 EmpName_Alias	
			select #Temp_Salary_Muster_Report.* , ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_Full_Name,E.Emp_First_Name , Emp_code, Alpha_Emp_Code, E.Dept_ID,Cmp_Name,Cmp_Address,BM.Bank_Name as Bank_Name,Inc_Qry.Branch_ID as Branch_ID 
			--,@T_Br_Comp_Name as Comp_Name ,isnull(@T_Br_Name,'ALL') as Branch_Name,
			,BRM.Comp_Name,BRM.Branch_Address,BRM.Branch_Name
			,DENSE_RANK() OVER (PARTITION BY cast(BM.Bank_ID as varchar(200))  ORDER BY  RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)) as Sr_No
			,@Payment_mode As Payment_mode
			from #Temp_Salary_Muster_Report Inner join
			T0080_Emp_Master E WITH (NOLOCK) on #Temp_Salary_Muster_Report.Emp_Id = E.Emp_ID inner join
			( select I.Emp_Id ,Grd_ID,DEsig_ID ,Dept_ID,Bank_ID,Payment_Mode,Branch_ID    from t0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_ID) as Increment_ID, Emp_ID from t0095_Increment WITH (NOLOCK)	-- Ankit 05092014 for Same Date Increment
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID )Inc_Qry on 
			E.Emp_ID = Inc_Qry.Emp_ID left outer join t0040_department_Master WITH (NOLOCK)
			on Inc_Qry.dept_ID = t0040_department_Master.Dept_ID  inner join t0010_company_master CM WITH (NOLOCK) on E.cmp_id=CM.cmp_id
			Left outer join T0040_BANK_MASTER BM WITH (NOLOCK) on Inc_Qry.Bank_ID = BM.Bank_ID 
			Left Outer join T0030_BRANCH_MASTER BRM WITH (NOLOCK) on Inc_Qry.Branch_ID = BRM.Branch_ID --T0030_BRANCH_MASTER add by chetan 28-12-16					 
			/*
			Inner join 
			(Select e.Emp_ID,row_number() OVER (ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)) As Sr_No From T0080_Emp_Master e inner join 
				#Temp_Salary_Muster_Report t on e.Emp_ID = t.Emp_ID
			Group by RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500),e.Emp_ID) Qry1 on E.Emp_ID = Qry1.Emp_ID
			*/
			where Inc_Qry.Bank_ID = Isnull(@Bank_id,Inc_Qry.Bank_ID) and Inc_Qry .Payment_Mode = @Payment_mode 
			--order by E.Emp_Full_Name 
			ORDER BY   RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)
			
		end
	Else if @Payment_mode = 'Bank Transfer'  and Isnull(@Bank_id,0) <> 0
		begin
			-- Changed By Ali 22112013 EmpName_Alias
			select #Temp_Salary_Muster_Report.* , ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_Full_Name,E.Emp_First_Name , Emp_code, Alpha_Emp_Code, E.Dept_ID,Cmp_Name,Cmp_Address,BM.Bank_Name as Bank_Name,Inc_Qry.Branch_ID as Branch_ID 
			--,@T_Br_Comp_Name as Comp_Name ,isnull(@T_Br_Name,'ALL') as Branch_Name,
			,BRM.Comp_Name,BRM.Branch_Address,BRM.Branch_Name
			,DENSE_RANK() OVER (PARTITION BY cast(BM.Bank_ID as varchar(200))  ORDER BY  RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)) as Sr_No
			,@Payment_mode As Payment_mode
			from #Temp_Salary_Muster_Report Inner join
			T0080_Emp_Master E WITH (NOLOCK) on #Temp_Salary_Muster_Report.Emp_Id = E.Emp_ID inner join
			( select I.Emp_Id ,Grd_ID,DEsig_ID ,Dept_ID,Bank_ID,Payment_Mode,Branch_ID    from t0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_ID) as Increment_ID, Emp_ID from t0095_Increment WITH (NOLOCK)	-- Ankit 05092014 for Same Date Increment
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID )Inc_Qry on 
			E.Emp_ID = Inc_Qry.Emp_ID left outer join t0040_department_Master WITH (NOLOCK)
			on Inc_Qry.dept_ID = t0040_department_Master.Dept_ID  inner join t0010_company_master CM WITH (NOLOCK) on E.cmp_id=CM.cmp_id
			Left outer join T0040_BANK_MASTER BM WITH (NOLOCK) on Inc_Qry.Bank_ID = BM.Bank_ID 
			Left Outer join T0030_BRANCH_MASTER BRM WITH (NOLOCK) on Inc_Qry.Branch_ID = BRM.Branch_ID --T0030_BRANCH_MASTER add by chetan 28-12-16					 
			/*
			Inner join 
			(Select e.Emp_ID,row_number() OVER (ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)) As Sr_No From T0080_Emp_Master e inner join 
				#Temp_Salary_Muster_Report t on e.Emp_ID = t.Emp_ID
			Group by RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500),e.Emp_ID) Qry1 on E.Emp_ID = Qry1.Emp_ID
			*/
			where Inc_Qry.Bank_ID = @Bank_id and Inc_Qry .Payment_Mode = @Payment_mode 
			--order by E.Emp_Full_Name 
			ORDER BY   RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)
			
		end		
	Else if @Payment_mode = ''  and Isnull(@Bank_id,0) <> 0
		begin
			-- Changed By Ali 22112013 EmpName_Alias
			select #Temp_Salary_Muster_Report.* , ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_Full_Name,E.Emp_First_Name , Emp_code, Alpha_Emp_Code, E.Dept_ID,Cmp_Name,Cmp_Address,BM.Bank_Name as Bank_Name,Inc_Qry.Branch_ID as Branch_ID 
			--,@T_Br_Comp_Name as Comp_Name ,isnull(@T_Br_Name,'ALL') as Branch_Name,
			,BRM.Comp_Name,BRM.Branch_Address,BRM.Branch_Name
			,DENSE_RANK() OVER (PARTITION BY cast(BM.Bank_ID as varchar(200))  ORDER BY  RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)) as Sr_No
			,@Payment_mode As Payment_mode
			from #Temp_Salary_Muster_Report Inner join
			T0080_Emp_Master E WITH (NOLOCK) on #Temp_Salary_Muster_Report.Emp_Id = E.Emp_ID inner join
			( select I.Emp_Id ,Grd_ID,DEsig_ID ,Dept_ID,Bank_ID,Payment_Mode,Branch_ID    from t0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_ID) as Increment_ID, Emp_ID from t0095_Increment WITH (NOLOCK)-- Ankit 05092014 for Same Date Increment
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID )Inc_Qry on 
			E.Emp_ID = Inc_Qry.Emp_ID left outer join t0040_department_Master WITH (NOLOCK)
			on Inc_Qry.dept_ID = t0040_department_Master.Dept_ID  inner join t0010_company_master CM WITH (NOLOCK) on E.cmp_id=CM.cmp_id
			Inner join T0040_BANK_MASTER BM WITH (NOLOCK) on Inc_Qry.Bank_ID = BM.Bank_ID 
			Left Outer join T0030_BRANCH_MASTER BRM WITH (NOLOCK) on Inc_Qry.Branch_ID = BRM.Branch_ID --T0030_BRANCH_MASTER add by chetan 28-12-16					 
			/*
			Inner join 
			(Select e.Emp_ID,row_number() OVER (ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)) As Sr_No From T0080_Emp_Master e inner join 
				#Temp_Salary_Muster_Report t on e.Emp_ID = t.Emp_ID
			Group by RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500),e.Emp_ID) Qry1 on E.Emp_ID = Qry1.Emp_ID
			*/
			where Inc_Qry.Bank_ID = @Bank_id --and Inc_Qry .Payment_Mode = @Payment_mode 
			--order by E.Emp_Full_Name 
			ORDER BY   RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)
			
		end
	else if Isnull(@Bank_id,0) = 0 and @Payment_mode <> ''
	begin
	
		if @Payment_mode = 'Cheque'
		begin
			-- Changed By Ali 22112013 EmpName_Alias
			select #Temp_Salary_Muster_Report.* , ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_Full_Name,E.Emp_First_Name , Emp_code, Alpha_Emp_Code, E.Dept_ID,Cmp_Name,Cmp_Address,BM.Bank_Name as Bank_Name,Inc_Qry.Branch_ID as Branch_ID 
			--,@T_Br_Comp_Name as Comp_Name ,isnull(@T_Br_Name,'ALL') as Branch_Name ,
			,BRM.Comp_Name,BRM.Branch_Address,BRM.Branch_Name
			,DENSE_RANK() OVER (PARTITION BY cast(BM.Bank_ID as varchar(200))  ORDER BY  RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)) as Sr_No
			,@Payment_mode As Payment_mode --,RANK() OVER (PARTITION BY E.Emp_Id ORDER BY Row_id Asc) AS SrNo1
			from #Temp_Salary_Muster_Report Inner join
			T0080_Emp_Master E WITH (NOLOCK) on #Temp_Salary_Muster_Report.Emp_Id = E.Emp_ID inner join
			( select I.Emp_Id ,Grd_ID,DEsig_ID ,Dept_ID,Bank_ID ,Payment_Mode,Branch_ID  from t0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_ID) as Increment_ID, Emp_ID from t0095_Increment WITH (NOLOCK) -- Ankit 05092014 for Same Date Increment
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID )Inc_Qry on 
			E.Emp_ID = Inc_Qry.Emp_ID left outer join t0040_department_Master WITH (NOLOCK)
			on Inc_Qry.dept_ID = t0040_department_Master.Dept_ID  inner join t0010_company_master CM WITH (NOLOCK) on E.cmp_id=CM.cmp_id
			left outer join T0040_BANK_MASTER BM WITH (NOLOCK) on Inc_Qry .Bank_ID = BM.Bank_ID
			Left Outer join T0030_BRANCH_MASTER BRM WITH (NOLOCK) on Inc_Qry.Branch_ID = BRM.Branch_ID --T0030_BRANCH_MASTER add by chetan 28-12-16					 
			/*
			Inner join 
			(Select e.Emp_ID,row_number() OVER (ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)) As Sr_No From T0080_Emp_Master e inner join 
				#Temp_Salary_Muster_Report t on e.Emp_ID = t.Emp_ID
			Group by RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500),e.Emp_ID) Qry1 on E.Emp_ID = Qry1.Emp_ID
			*/	
			where  Inc_Qry .Payment_Mode = @Payment_mode 
			--order by E.Emp_Full_Name 
			ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)
				
		
		end
		
		if @Payment_mode = 'Cash'
		begin
			-- Changed By Ali 22112013 EmpName_Alias		
			select #Temp_Salary_Muster_Report.* , ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_Full_Name,E.Emp_First_Name , Emp_code,Alpha_Emp_Code, E.Dept_ID,Cmp_Name,Cmp_Address,BM.Bank_Name as Bank_Name,Inc_Qry.Branch_ID as Branch_ID
			-- ,@T_Br_Comp_Name as Comp_Name ,isnull(@T_Br_Name,'ALL') as Branch_Name ,
			,BRM.Comp_Name,BRM.Branch_Address,BRM.Branch_Name
			,DENSE_RANK() OVER (PARTITION BY cast(BM.Bank_ID as varchar(200))  ORDER BY  RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)) as Sr_No
			,@Payment_mode As Payment_mode-- ,ROW_NUMBER() OVER(ORDER BY E.Emp_ID Asc) AS SrNo
			from #Temp_Salary_Muster_Report Inner join
			T0080_Emp_Master E WITH (NOLOCK) on #Temp_Salary_Muster_Report.Emp_Id = E.Emp_ID inner join
			( select I.Emp_Id ,Grd_ID,DEsig_ID ,Dept_ID,Bank_ID,Payment_Mode,Branch_ID from t0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_ID) as Increment_ID, Emp_ID from t0095_Increment WITH (NOLOCK) -- Ankit 05092014 for Same Date Increment
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID )Inc_Qry on 
			E.Emp_ID = Inc_Qry.Emp_ID left outer join t0040_department_Master WITH (NOLOCK)
			on Inc_Qry.dept_ID = t0040_department_Master.Dept_ID  inner join t0010_company_master CM WITH (NOLOCK) on E.cmp_id=CM.cmp_id
			left outer join T0040_BANK_MASTER BM WITH (NOLOCK) on Inc_Qry .Bank_ID = BM.Bank_ID 
			Left Outer join T0030_BRANCH_MASTER BRM WITH (NOLOCK) on Inc_Qry.Branch_ID = BRM.Branch_ID --T0030_BRANCH_MASTER add by chetan 28-12-16					
			/*
			Inner join 
			(Select e.Emp_ID,row_number() OVER (ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)) As Sr_No From T0080_Emp_Master e inner join 
				#Temp_Salary_Muster_Report t on e.Emp_ID = t.Emp_ID
			Group by RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500),e.Emp_ID) Qry1 on E.Emp_ID = Qry1.Emp_ID
			*/
			where Inc_Qry .Payment_Mode = @Payment_mode
			--order by E.Emp_Full_Name 
			ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)
			
		end
	end
	else
	begin
		-- Changed By Ali 22112013 EmpName_Alias
		select #Temp_Salary_Muster_Report.* , ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_Full_Name,E.Emp_First_Name , Emp_code , Alpha_Emp_Code, E.Dept_ID,Cmp_Name,Cmp_Address,isnull(BM.Bank_Name,'') as Bank_Name,Inc_Qry.Branch_ID as Branch_ID
		 --,@T_Br_Comp_Name as Comp_Name ,isnull(@T_Br_Name,'ALL') as Branch_Name, comment by chetan 28-12-16
		,BRM.Comp_Name,BRM.Branch_Address,BRM.Branch_Name
		,DENSE_RANK() OVER (PARTITION BY cast(BM.Bank_ID as varchar(200))  ORDER BY  RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)) as Sr_No
		,@Payment_mode As Payment_mode  -- ,ROW_NUMBER() OVER(ORDER BY E.Emp_ID Asc) AS SrNo
		
		from #Temp_Salary_Muster_Report Inner join
			T0080_Emp_Master E WITH (NOLOCK) on #Temp_Salary_Muster_Report.Emp_Id = E.Emp_ID inner join
			( select I.Emp_Id ,Grd_ID,DEsig_ID ,Dept_ID,Bank_ID ,Payment_Mode ,Branch_ID from t0095_Increment I WITH (NOLOCK) inner join 
						( select max(Increment_ID) as Increment_ID, Emp_ID from t0095_Increment	 WITH (NOLOCK) -- Ankit 05092014 for Same Date Increment
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_ID
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID )Inc_Qry on 
			E.Emp_ID = Inc_Qry.Emp_ID left outer join t0040_department_Master WITH (NOLOCK)
			on Inc_Qry.dept_ID = t0040_department_Master.Dept_ID  inner join t0010_company_master CM WITH (NOLOCK) on E.cmp_id=CM.cmp_id
			left outer join T0040_BANK_MASTER BM WITH (NOLOCK) on Inc_Qry .Bank_ID = BM.Bank_ID 
			Left Outer join T0030_BRANCH_MASTER BRM WITH (NOLOCK) on Inc_Qry.Branch_ID = BRM.Branch_ID --T0030_BRANCH_MASTER add by chetan 28-12-16					
			/*
			Inner join 
			(Select e.Emp_ID,row_number() OVER (ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)) As Sr_No From T0080_Emp_Master e inner join 
				#Temp_Salary_Muster_Report t on e.Emp_ID = t.Emp_ID
			Group by RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500),e.Emp_ID) Qry1 on E.Emp_ID = Qry1.Emp_ID
			 */
			--order by E.Emp_Full_Name 
			ORDER BY RIGHT(REPLICATE(N' ', 500) + ALPHA_EMP_CODE, 500)
		 
	end
		
	--exec Set_Salary_Register_Amount_Transfer @Cmp_ID=2,@From_Date='2010-08-01 00:00:00',@To_Date='2010-08-31 00:00:00',@Branch_ID=5,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=0,@Constraint='',@Sal_Type=0,@Bank_id = 0,@Payment_mode = ''
	
	
	RETURN




