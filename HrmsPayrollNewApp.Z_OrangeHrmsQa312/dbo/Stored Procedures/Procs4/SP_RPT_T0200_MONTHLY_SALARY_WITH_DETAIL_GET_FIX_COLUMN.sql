
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_T0200_MONTHLY_SALARY_WITH_DETAIL_GET_FIX_COLUMN]
  @Cmp_ID     Numeric          
 ,@From_Date  Datetime          
 ,@To_Date    Datetime          
 ,@Branch_ID  Numeric          
 ,@Cat_ID     Numeric           
 ,@Grd_ID     Numeric          
 ,@Type_ID    Numeric          
 ,@Dept_ID    Numeric          
 ,@Desig_ID   Numeric          
 ,@Emp_ID     Numeric          
 ,@constraint Varchar(MAX)          
 ,@Sal_Type   Numeric = 0
 ,@Bank_id	   numeric = 0
 ,@Payment_mode varchar(100) = ''
 ,@Salary_Cycle_id numeric = 0	-- Added By Gadriwala Muslim 21082013	
 ,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 21082013
 ,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013
 ,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 21082013	
 ,@SubBranch_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013	
 ,@Order_By   varchar(30) = 'Code' --Added by Jimit 28/09/2015 (To sort by Code/Name/Enroll No)       
AS          
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	                      
	 IF @Branch_ID = 0            
	   Set @Branch_ID = null          
	            
	 IF @Cat_ID = 0            
		Set @Cat_ID =  null          
	          
	 IF @Grd_ID = 0            
		Set @Grd_ID = null          
	          
	 IF @Type_ID = 0            
		Set @Type_ID = null          
	          
	 IF @Dept_ID = 0            
		Set @Dept_ID = null          
	          
	 IF @Desig_ID = 0            
		Set @Desig_ID = null          
	          
	 IF @Emp_ID = 0            
		Set @Emp_ID = null      
		
	if @Salary_Cycle_id = 0		-- Added By Gadriwala Muslim 21082013
		set @Salary_Cycle_id = NULL
			
			
	If @Segment_Id = 0		 -- Added By Gadriwala Muslim 21082013
		set @Segment_Id = null
	If @Vertical_Id = 0		 -- Added By Gadriwala Muslim 21082013
		set @Vertical_Id = null
	If @SubVertical_Id = 0	 -- Added By Gadriwala Muslim 21082013
		set @SubVertical_Id = null	
	If @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 21082013
		set @SubBranch_Id = null	


	--Hardik 12/06/2013 for Next Month Advance Show
	Declare @Next_Month_End_Date as Datetime


	Declare @Sal_St_Date   Datetime    
	Declare @Sal_end_Date   Datetime  
	declare @manual_salary_period as numeric(18,0)

  
  
	SET @manual_salary_period = 0

	/*Commented by Nimesh 29-May-2015		  
	If @Branch_ID is null
		Begin 
			select Top 1 @Sal_St_Date  = Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
			  from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@To_Date and Cmp_ID = @Cmp_ID)    
		End
	Else
		Begin
			select @Sal_St_Date  =Sal_st_Date ,@manual_salary_period=isnull(Manual_Salary_Period ,0) 
			  from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
		End    
	
	
	 if isnull(@Sal_St_Date,'') = ''   And @manual_salary_period = 0    
		begin    
		   set @From_Date  = @From_Date     
		   set @To_Date = @To_Date    
		   set @Next_Month_End_Date = dateadd(d,-1,dateadd(m,2,@From_Date)) 
		end     
	 else if day(@Sal_St_Date) = 1 And @manual_salary_period = 0    --and month(@Sal_St_Date)=1    
		begin    
		   set @From_Date  = @From_Date     
		   set @To_Date = @To_Date    
		   set @Next_Month_End_Date = dateadd(d,-1,dateadd(m,2,@From_Date)) 
		end     
	 else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) >= 1  
		Begin
		   if @manual_salary_period = 0    
				Begin
					
				   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
				   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
				
				   Set @From_Date = @Sal_St_Date
				   Set @To_Date = @Sal_End_Date
				   set @Next_Month_End_Date = dateadd(d,-1,dateadd(m,2,@From_Date)) 
				End
			Else
				Begin
						print 1
					Declare @Temp_Month_End_Date as Datetime
					Set @Temp_Month_End_Date = dateadd(d,-1,dateadd(m,1,@To_Date)) 
					
					Select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@To_Date) and YEAR=year(@To_Date)
					
					Select @Next_Month_End_Date= end_date from salary_period where month= month(@Temp_Month_End_Date) and YEAR=year(@Temp_Month_End_Date)
					
					Set @From_Date = @Sal_St_Date
					Set @To_Date = @Sal_End_Date 

				End 
				
		End
		
	*/
		  
	  
	DECLARE @is_salary_cycle_emp_wise AS TINYINT -- added by mitesh on 03072013
	SET @is_salary_cycle_emp_wise = 0

	--Updated by Nimesh 29-May-2015 (Code taken from SP_RPT_SALARY_MUSTER_WITH_DYNAMIC_COLUMNS)
	SELECT	@is_salary_cycle_emp_wise = ISNULL(Setting_Value,0) 
	FROM	T0040_SETTING WITH (NOLOCK)
	WHERE	Cmp_ID = @Cmp_ID and Setting_Name = 'Salary Cycle Employee Wise'


	IF @is_salary_cycle_emp_wise = 1 AND ISNULL(@Salary_Cycle_id,0) > 0 BEGIN
		SELECT	@Sal_St_Date = SALARY_ST_DATE 
		FROM	T0040_SALARY_CYCLE_MASTER WITH (NOLOCK)
		WHERE	tran_id = @Salary_Cycle_id
	END ELSE 
		BEGIN
		IF @Branch_ID IS NULL BEGIN 
			SELECT	TOP 1 @Sal_St_Date  = Sal_st_Date,@manual_salary_period=isnull(Manual_Salary_Period ,0)
			FROM	T0040_GENERAL_SETTING WITH (NOLOCK)
			WHERE cmp_ID = @cmp_ID    
				  AND For_Date=( 
								SELECT	MAX(For_Date) 
								FROM	T0040_GENERAL_SETTING WITH (NOLOCK)
								WHERE	For_Date <=@From_Date AND Cmp_ID = @Cmp_ID
								)    
		END ELSE BEGIN
			SELECT	@Sal_St_Date=Sal_st_Date,@manual_salary_period=ISNULL(Manual_Salary_Period ,0) -- Comment and added By rohit on 11022013
			FROM	T0040_GENERAL_SETTING WITH (NOLOCK)
			WHERE	cmp_ID = @cmp_ID AND Branch_ID = @Branch_ID
					AND For_Date = (
									SELECT	MAX(For_Date)
									FROM	T0040_GENERAL_SETTING WITH (NOLOCK)
									WHERE	For_Date <=@From_Date AND Branch_ID = @Branch_ID AND Cmp_ID = @Cmp_ID
									)    
		END
	END

	   
	IF isnull(@Sal_St_Date,'') = '' BEGIN    
		SET	@From_Date  = @From_Date     
		SET	@To_Date = @To_Date    
	END ELSE IF day(@Sal_St_Date) = 1 BEGIN --and month(@Sal_St_Date)=1    	    
		SET	@From_Date  = @From_Date     
		SET	@To_Date = @To_Date    
	END ELSE IF @Sal_St_Date <> '' AND day(@Sal_St_Date) > 1 BEGIN    
		IF @manual_salary_period = 0 BEGIN
			SET	@Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@To_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@To_Date) )as varchar(10)) as smalldatetime)    
			SET	@Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date)) 
			SET	@From_Date = @Sal_St_Date
			SET	@To_Date = @Sal_End_Date
		END ELSE BEGIN
			SELECT	@Sal_St_Date=from_date,@Sal_End_Date=end_date
			FROM	salary_period 
			WHERE	MONTH=MONTH(@To_Date) AND YEAR=YEAR(@To_Date)

			SET	@From_Date = @Sal_St_Date
			SET	@To_Date = @Sal_End_Date 
		End    
	End
	--End of Update Nimesh 29-May-2015

	CREATE TABLE #Emp_Cons -- Ankit 11092014 for Same Date Increment
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 

          
	--Declare #Emp_Cons Table          
	--	(          
	--		Emp_ID numeric          
	--	)          
           
	-- if @Constraint <> ''          
	--	begin          
	--		Insert Into #Emp_Cons          
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#')           
	--	end          
	-- else          
	--	begin          
	--		Insert Into #Emp_Cons          
	--		select I.Emp_Id from dbo.T0095_Increment I inner join           
	--				( select max(Increment_effective_Date) as For_Date , Emp_ID from dbo.T0095_Increment          
	--				where Increment_Effective_date <= @To_Date          
	--				and Cmp_ID = @Cmp_ID          
	--				group by emp_ID  ) Qry on          
	--			I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date           
	--		Where Cmp_ID = @Cmp_ID           
	--			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))          
	--			and Branch_ID = isnull(@Branch_ID ,Branch_ID)          
	--			and Grd_ID = isnull(@Grd_ID ,Grd_ID)          
	--			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))          
	--			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))          
	--			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))    
	--			and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 21082013
	--			and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 21082013
	--			and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 21082013
	--			and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 21082013
                   
	--			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)           
	--			and I.Emp_ID in           
	--				( select Emp_Id from          
	--				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from dbo.T0110_EMP_LEFT_JOIN_TRAN) qry          
	--				where cmp_ID = @Cmp_ID   and            
	--			(( @From_Date  >= join_Date  and  @From_Date <= left_date )           
	--			or ( @To_Date  >= join_Date  and @To_Date <= left_date )          
	--			or Left_date is null and @To_Date >= Join_Date)          
	--			or @To_Date >= left_date  and  @From_Date <= left_date )           
	--	end          
             
  Declare @Emp_Salary Table          
  (    
   Cmp_ID    numeric,          
   Emp_ID    numeric,          
   Sal_Tran_ID   numeric,          
   Increment_ID  numeric,          
   Sal_Month   numeric,          
   Sal_Year   Numeric,          
   Salary_Amount  numeric(18,2),          
   Incentive   numeric(18,2),
   Incentive_Actual Numeric(18,2),          
   Gross_Salary  numeric(18,2),          
   PF_Calc_On_Amount numeric(18,2),          
   ESIC_Calc_On_Amount numeric(18,2),          
   PF_Amount   numeric(18,2),          
   ESIC_Amount   Numeric(18,2),          
   PT_Amount   numeric(18,2),          
   TDS_Amount  Numeric(18,2),
   Adv_Amount   numeric(18,2),          
   Loan_Amount   numeric(18,2),           
   Loan_Advance_Amount Numeric(18,2),
   Net_Amount   numeric (18,2),          
   Sal_cal_Days  numeric(12,1),          
   Total_Dedu_Amount numeric (18,2) ,        
   P_Day numeric(5,2),        
   Ab_Day numeric(5,2),        
   Holiday numeric(5,2),        
   Weekoff_Day numeric(5,2),        
   Total_Leave_Days numeric(5,2),
   Mobile_JV numeric(18,2),
   Voucher Numeric(18,2),
   Mediclaim Numeric(18,2),
   Accident_Policy Numeric(18,2),
   Payment_Mode varchar(15),
   Next_Month_Adv_Amount numeric(18,2),   
    Ot_Hours Numeric(18,2),
   Ot_Amount Numeric(18,2),
   Paid_Leave Numeric(18,3),
   Other_Total Numeric(18,2),
   DA		  Numeric(18,2) default 0, --Added By Gadriwala Muslim 280420115
   Employee_Retention NUMERIC(18,2) DEFAULT 0 --added by jimit 09122016
  )            
            
         
      
  Insert into @Emp_Salary (Cmp_ID,Emp_ID,Sal_Tran_ID,Increment_ID,Sal_Month,Sal_Year,Salary_Amount,Incentive,Incentive_Actual,
         Gross_Salary,PF_Calc_On_Amount,ESIC_Calc_On_Amount,PF_Amount,ESIC_Amount,PT_Amount, TDS_Amount,          
         Adv_Amount,Loan_Amount,Loan_Advance_Amount, Net_Amount,Sal_cal_Days,Total_Dedu_Amount,
         P_Day,Ab_Day,Holiday,Weekoff_Day,Total_Leave_Days,Mobile_JV,Voucher,Mediclaim,Accident_Policy,Payment_Mode,Next_Month_Adv_Amount,Employee_Retention)          
          
  Select @cmp_ID,Emp_ID,null,null,month(@To_date),Year(@To_date),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',0,0
  from #Emp_Cons                


	
--select @From_Date,@To_Date,@Temp_Month_End_Date
          
	if @Sal_Type = 0  or @Sal_Type=1        
		begin
			If @Payment_mode = ''            
				Begin
					
						
					Update  @Emp_Salary          
						set Increment_ID = ms.Increment_ID,          
						Sal_Month  =  Month(ms.Month_end_Date),          
						Sal_Year  =  Year(ms.Month_end_Date),          
						Salary_Amount =  ms.Salary_Amount,          
						Gross_Salary =  ms.Gross_Salary,          
						PT_Amount  =  ms.PT_Amount ,          
						Adv_Amount  =  ms.Advance_Amount,          
						Loan_Amount  =  ms.Loan_Amount,          
						Loan_Advance_Amount = ISNULL(Ms.Loan_Amount,0) + ISNULL(ms.Advance_Amount,0) ,
						TDS_Amount = ISNULL(Ms.M_IT_Tax,0),
						Net_Amount    = ms.Net_Amount,          
						Sal_cal_Days   = ms.Sal_cal_Days,          
						Total_Dedu_Amount = ms.Total_Dedu_Amount ,        
						P_Day =   ms.Present_Days,        
						Ab_Day =ms.Absent_Days,        
						Holiday =ms.Holiday_Days,        
						Weekoff_Day =ms.Weekoff_Days,        
						Total_Leave_Days =ms.Total_Leave_Days,
						Payment_Mode = I.Payment_Mode
						--Next_Month_Adv_Amount = AP.Adv_Amount
						,Ot_Hours=isnull(MS.Ot_Hours,0)
						,Ot_Amount = isnull(Ms.Ot_Amount,0)
						,Paid_Leave = ISNULL(ms.Paid_Leave_Days,0)
					From @Emp_Salary es Inner join 
						dbo.T0200_MONTHLY_SALARY ms on es.emp_ID =ms.emp_ID and 
							Sal_month = month(ms.Month_end_Date)and Sal_Year = Year(ms.Month_end_Date) Inner Join
						dbo.T0095_INCREMENT I on Ms.Increment_ID = I.Increment_ID 
					Where ms.Cmp_ID = @Cmp_Id           
						and ms.Salary_Amount >0    And Isnull(IS_FNF,0)=0         
						and month(ms.Month_End_Date)= Month(@To_Date) and Year(ms.Month_End_Date) = YEAR(@To_Date)    
					
					Update @Emp_Salary Set Next_Month_Adv_Amount = A.Adv_Amount 
					From @Emp_Salary E Inner Join T0100_ADVANCE_PAYMENT A on
						E.Emp_ID = A.Emp_ID
					Where E.Cmp_ID = @Cmp_ID And For_Date = DATEADD(d,1,@To_Date) And Adv_Comments like '%Negative%'
				
						
				End
			Else if @Payment_mode <> 'Bank Transfer'
				Begin
					Update  @Emp_Salary          
						set Increment_ID = ms.Increment_ID,          
						Sal_Month  =  Month(ms.Month_end_Date),          
						Sal_Year  =  Year(ms.Month_end_Date),          
						Salary_Amount =  ms.Salary_Amount,          
						Gross_Salary =  ms.Gross_Salary,          
						PT_Amount  =  ms.PT_Amount ,          
						Adv_Amount  =  ms.Advance_Amount,          
						Loan_Amount  =  ms.Loan_Amount,          
						Loan_Advance_Amount = ISNULL(Ms.Loan_Amount,0) + ISNULL(ms.Advance_Amount,0) ,
						TDS_Amount = ISNULL(Ms.M_IT_Tax,0),
						Net_Amount    = ms.Net_Amount,          
						Sal_cal_Days   = ms.Sal_cal_Days,          
						Total_Dedu_Amount = ms.Total_Dedu_Amount ,        
						P_Day =   ms.Present_Days,        
						Ab_Day =ms.Absent_Days,        
						Holiday =ms.Holiday_Days,        
						Weekoff_Day =ms.Weekoff_Days,        
						Total_Leave_Days =ms.Total_Leave_Days,
						Payment_Mode = I.Payment_Mode
						--Next_Month_Adv_Amount = AP.Adv_Amount
						,Ot_Hours=isnull(MS.Ot_Hours,0)
						,Ot_Amount = isnull(Ms.Ot_Amount,0)
						,Paid_Leave = ISNULL(ms.Paid_Leave_Days,0)
					From @Emp_Salary es Inner join 
						dbo.T0200_MONTHLY_SALARY ms on es.emp_ID =ms.emp_ID and 
							Sal_month = month(ms.Month_end_Date)and Sal_Year = Year(ms.Month_end_Date) Inner Join
						dbo.T0095_INCREMENT I on Ms.Increment_ID = I.Increment_ID 
						
					Where ms.Cmp_ID = @Cmp_Id           
						and ms.Salary_Amount >0    And Isnull(IS_FNF,0)=0         
						and month(ms.Month_End_Date)= Month(@To_Date) and Year(ms.Month_End_Date) = YEAR(@To_Date)   
						AND I.Payment_Mode LIKE isnull(@Payment_mode,I.Payment_Mode)

					Update @Emp_Salary Set Next_Month_Adv_Amount = A.Adv_Amount 
					From @Emp_Salary E Inner Join T0100_ADVANCE_PAYMENT A on
						E.Emp_ID = A.Emp_ID
					Where E.Cmp_ID = @Cmp_ID And For_Date = DATEADD(d,1,@To_Date) And Adv_Comments like '%Negative%'
						
				End
			Else
				Begin
					Update  @Emp_Salary          
						set Increment_ID = ms.Increment_ID,          
						Sal_Month  =  Month(ms.Month_end_Date),          
						Sal_Year  =  Year(ms.Month_end_Date),          
						Salary_Amount =  ms.Salary_Amount,          
						Gross_Salary =  ms.Gross_Salary,          
						PT_Amount  =  ms.PT_Amount ,          
						Adv_Amount  =  ms.Advance_Amount,          
						Loan_Amount  =  ms.Loan_Amount,          
						Loan_Advance_Amount = ISNULL(Ms.Loan_Amount,0) + ISNULL(ms.Advance_Amount,0) ,
						TDS_Amount = ISNULL(Ms.M_IT_Tax,0),
						Net_Amount    = ms.Net_Amount,          
						Sal_cal_Days   = ms.Sal_cal_Days,          
						Total_Dedu_Amount = ms.Total_Dedu_Amount ,        
						P_Day =   ms.Present_Days,        
						Ab_Day =ms.Absent_Days,        
						Holiday =ms.Holiday_Days,        
						Weekoff_Day =ms.Weekoff_Days,        
						Total_Leave_Days =ms.Total_Leave_Days,
						Payment_Mode = I.Payment_Mode
						--Next_Month_Adv_Amount = AP.Adv_Amount
						,Ot_Hours=isnull(MS.Ot_Hours,0)
						,Ot_Amount = isnull(Ms.Ot_Amount,0)
						,Paid_Leave = ISNULL(ms.Paid_Leave_Days,0)
					From @Emp_Salary es Inner join 
						dbo.T0200_MONTHLY_SALARY ms on es.emp_ID =ms.emp_ID and 
							Sal_month = month(ms.Month_end_Date)and Sal_Year = Year(ms.Month_end_Date) Inner Join
						dbo.T0095_INCREMENT I on Ms.Increment_ID = I.Increment_ID 
						
					Where ms.Cmp_ID = @Cmp_Id           
						and ms.Salary_Amount >0    And Isnull(IS_FNF,0)=0         
						and month(ms.Month_End_Date)= Month(@To_Date) and Year(ms.Month_End_Date) = YEAR(@To_Date)   
						And I.Bank_Id =Isnull(@Bank_Id, I.Bank_Id)   

					Update @Emp_Salary Set Next_Month_Adv_Amount = A.Adv_Amount 
					From @Emp_Salary E Inner Join T0100_ADVANCE_PAYMENT A on
						E.Emp_ID = A.Emp_ID
					Where E.Cmp_ID = @Cmp_ID And For_Date = DATEADD(d,1,@To_Date) And Adv_Comments like '%Negative%'
						       
				End
							
				
		end           
	--else if @sal_Type =1             
	--	begin              
	--		Update  @Emp_Salary          
	--			set Increment_ID = ms.Increment_ID,          
	--			Salary_Amount =  Salary_Amount + ms.S_Salary_Amount,          
	--			Gross_Salary =  Gross_Salary + ms.S_Allow_Amount,          
	--			PT_Amount  =  PT_Amount + ms.s_PT_Amount ,          
	--			Adv_Amount  =  Adv_Amount + ms.s_Advance_Amount,          
	--			Loan_Amount  =  Loan_Amount  + ms.s_Loan_Amount,          
	--			Loan_Advance_Amount = ISNULL(Ms.S_Loan_Amount,0) + ISNULL(ms.S_Advance_Amount ,0) ,
	--			Net_Amount    = Net_Amount + ms.s_Net_Amount,          
	--			Sal_cal_Days   = Sal_cal_Days + ms.S_M_Present_Days,          
	--			Total_Dedu_Amount = Total_Dedu_Amount + ms.s_Total_Dedu_Amount
	--		From @Emp_Salary es Inner join 
	--			dbo.T0201_MONTHLY_SALARY_SETT ms on es.emp_ID =ms.emp_ID and 
	--			Sal_month = month(ms.s_Month_end_Date)and Sal_YEar = Year(ms.s_Month_end_Date)          
	--		Where ms.Cmp_ID = @Cmp_Id           
	--			and ms.S_Net_Amount >0          
	--			and ms.s_Month_St_Date >=@From_Date and ms.s_Month_End_Date <=@To_Date          
	--	end          
	else if @Sal_Type =2           
		begin          
			Update  @Emp_Salary          
				set Increment_ID  = ms.Increment_ID,          
				Salary_Amount  =   Salary_Amount + ms.L_Salary_Amount,          
				Gross_Salary  =   Gross_Salary + ms.l_Allow_Amount,          
				PT_Amount   =   PT_Amount + ms.l_PT_Amount ,          
				Adv_Amount   =   Adv_Amount + ms.L_Advance_Amount,    
				Loan_Amount   =   Loan_Amount  + ms.L_Loan_Amount,          
				Loan_Advance_Amount = ISNULL(Ms.L_Loan_Amount,0) + ISNULL(ms.L_Advance_Amount,0) ,
				Net_Amount   =   Net_Amount + ms.L_Net_Amount,          
				Sal_cal_Days  =   Sal_cal_Days + ms.L_Sal_cal_Days,          
				Total_Dedu_Amount =   Total_Dedu_Amount + ms.L_Total_Dedu_Amount
			From @Emp_Salary es Inner join 
				dbo.T0200_MONTHLY_SALARY_LEAVE ms on es.emp_ID =ms.emp_ID and 
					Sal_month = month(ms.L_Month_end_Date)and Sal_Year = Year(ms.L_Month_end_Date)          
			Where ms.Cmp_ID = @Cmp_Id           
				and ms.L_Salary_Amount >0          
				and month(ms.L_Month_End_Date)= Month(@To_Date) and Year(ms.L_Month_End_Date) = YEAR(@To_Date)   

		end          
	else          
		begin          
			Update  @Emp_Salary          
				set Increment_ID = ms.Increment_ID,          
				Sal_Month  =  Month(ms.Month_end_Date),          
				Sal_Year  =  Year(ms.Month_end_Date),          
				Salary_Amount =  ms.Salary_Amount,          
				Gross_Salary =  ms.Gross_Salary,          
				PT_Amount  =  ms.PT_Amount ,          
				Adv_Amount  =  ms.Advance_Amount,          
				Loan_Amount  =  ms.Loan_Amount,          
				Loan_Advance_Amount = ISNULL(Ms.Loan_Amount,0) + ISNULL(ms.Advance_Amount,0) ,
				TDS_Amount = ISNULL(Ms.M_IT_Tax,0),
				Net_Amount    = ms.Net_Amount,          
				Sal_cal_Days   = ms.Sal_cal_Days,          
				Total_Dedu_Amount = ms.Total_Dedu_Amount,
				Payment_Mode = I.Payment_Mode
				--Next_Month_Adv_Amount = AP.Adv_Amount
			From @Emp_Salary es Inner join 
				dbo.T0200_MONTHLY_SALARY ms on es.emp_ID =ms.emp_ID and 
					Sal_month = month(ms.Month_end_Date)and Sal_Year = Year(ms.Month_end_Date) Inner Join
				dbo.T0095_INCREMENT I on Ms.Increment_ID = I.Increment_ID 
				
			Where ms.Cmp_ID = @Cmp_Id           
				and ms.Salary_Amount >0          
				and month(ms.Month_End_Date)= Month(@To_Date) and Year(ms.Month_End_Date) = YEAR(@To_Date)   

			Update @Emp_Salary Set Next_Month_Adv_Amount = A.Adv_Amount 
			From @Emp_Salary E Inner Join T0100_ADVANCE_PAYMENT A on
				E.Emp_ID = A.Emp_ID
			Where E.Cmp_ID = @Cmp_ID And For_Date = DATEADD(d,1,@To_Date) And Adv_Comments like '%Negative%'

			     
			Update  @Emp_Salary          
				set Increment_ID = ms.Increment_ID,          
				Salary_Amount =  Salary_Amount + ms.S_Salary_Amount,          
				Gross_Salary =  Gross_Salary + ms.s_Allow_Amount,          
				PT_Amount  =  PT_Amount + ms.s_PT_Amount ,          
				Adv_Amount  =  Adv_Amount + ms.s_Advance_Amount,          
				Loan_Amount  =  Loan_Amount  + ms.s_Loan_Amount,          
				Loan_Advance_Amount = ISNULL(Ms.S_Loan_Amount,0) + ISNULL(ms.S_Advance_Amount,0) ,
				Net_Amount    = Net_Amount + ms.s_Net_Amount,          
				Sal_cal_Days   = Sal_cal_Days + ms.S_M_Present_Days,          
				Total_Dedu_Amount = Total_Dedu_Amount + ms.s_Total_Dedu_Amount
			From @Emp_Salary es Inner join 
				dbo.T0201_MONTHLY_SALARY_SETT ms on es.emp_ID =ms.emp_ID and 
					Sal_month = month(ms.s_Month_end_Date)and Sal_Year = Year(ms.s_Month_end_Date)
			Where ms.Cmp_ID = @Cmp_Id           
			and ms.S_Net_Amount >0          
			and month(ms.s_Month_End_Date)= Month(@To_Date) and Year(ms.s_Month_End_Date) = YEAR(@To_Date)   
			  
			Update  @Emp_Salary          
				set Increment_ID  = ms.Increment_ID,          
				Salary_Amount  =   Salary_Amount + Isnull(ms.L_Salary_Amount,0),          
				Gross_Salary  =   Gross_Salary + Isnull(ms.l_Allow_Amount,0),          
				PT_Amount   =   PT_Amount + Isnull(ms.l_PT_Amount,0) ,          
				Adv_Amount   =   Adv_Amount + Isnull(ms.L_Advance_Amount,0),          
				Loan_Amount   =   Loan_Amount  + Isnull(ms.L_Loan_Amount,0),          
				Loan_Advance_Amount = ISNULL(Ms.L_Loan_Amount,0) + ISNULL(ms.L_Advance_Amount,0) ,
				Net_Amount   =   Net_Amount + Isnull(ms.L_Net_Amount,0),          
				Sal_cal_Days  =   Sal_cal_Days + Isnull(ms.L_Sal_cal_Days,0),          
				Total_Dedu_Amount =   Total_Dedu_Amount + Isnull(ms.L_Total_Dedu_Amount,0)
			From @Emp_Salary es Inner join 
				dbo.T0200_MONTHLY_SALARY_LEAVE ms on es.emp_ID =ms.emp_ID and 
				Sal_month = month(ms.L_Month_end_Date)and Sal_year = Year(ms.L_Month_end_Date)          
			Where ms.Cmp_ID = @Cmp_Id           
			and ms.L_Salary_Amount >0          
			and month(ms.L_Month_End_Date)= Month(@To_Date) and Year(ms.L_Month_End_Date) = YEAR(@To_Date)   
		end          
           
	--if @Sal_Type = 1           
	--	begin          
	--		Update  @Emp_Salary          
	--		set  Incentive = M_AD_Amount           
	--		from @Emp_Salary es inner join           
	--		(select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  dbo.T0210_monthly_AD_detail mad Inner join           
	--		#Emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type in (@sal_Type,2) Inner join           
	--		T0050_AD_Master am on mad.AD_ID = AM.AD_ID           
	--		Where Mad.Cmp_ID = @Cmp_ID and AD_NAME like '%Incentive%' and For_Date >=@From_DAte and For_Date <=@To_Date          
	--		group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year          

	--		Update  @Emp_Salary          
	--		set  Mobile_JV = M_AD_Amount           
	--		from @Emp_Salary es inner join           
	--		(select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  dbo.T0210_monthly_AD_detail mad Inner join           
	--		#Emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type in (@sal_Type,2) Inner join           
	--		T0050_AD_Master am on mad.AD_ID = AM.AD_ID           
	--		Where Mad.Cmp_ID = @Cmp_ID and AD_NAME like '%Mobile%' and For_Date >=@From_DAte and For_Date <=@To_Date          
	--		group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year          

	--		Update  @Emp_Salary          
	--		set  Voucher = M_AD_Amount           
	--		from @Emp_Salary es inner join           
	--		(select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  dbo.T0210_monthly_AD_detail mad Inner join           
	--		#Emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type in (@sal_Type,2) Inner join           
	--		T0050_AD_Master am on mad.AD_ID = AM.AD_ID           
	--		Where Mad.Cmp_ID = @Cmp_ID and AD_NAME like '%Voucher%' and For_Date >=@From_DAte and For_Date <=@To_Date          
	--		group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year          

	--		Update  @Emp_Salary          
	--		set  Mediclaim = M_AD_Amount           
	--		from @Emp_Salary es inner join           
	--		(select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  dbo.T0210_monthly_AD_detail mad Inner join           
	--		#Emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type in (@sal_Type,2) Inner join           
	--		T0050_AD_Master am on mad.AD_ID = AM.AD_ID           
	--		Where Mad.Cmp_ID = @Cmp_ID and AD_NAME like '%Mediclaim%' and For_Date >=@From_DAte and For_Date <=@To_Date          
	--		group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year          

	--		Update  @Emp_Salary          
	--		set  Accident_Policy = M_AD_Amount           
	--		from @Emp_Salary es inner join           
	--		(select mad.Emp_ID ,Month(For_Date)M_Month ,Year(For_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  dbo.T0210_monthly_AD_detail mad Inner join           
	--		#Emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type in (@sal_Type,2) Inner join           
	--		T0050_AD_Master am on mad.AD_ID = AM.AD_ID           
	--		Where Mad.Cmp_ID = @Cmp_ID and AD_NAME like '%Accident%' and For_Date >=@From_DAte and For_Date <=@To_Date          
	--		group by mad.Emp_ID ,Month(For_Date),Year(For_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year          
			
	--	end    
	 Declare @Temp_Sal_Type tinyint
	     
	 if @Sal_Type = 0 or @Sal_Type=1
		begin   
								       
			Update  @Emp_Salary          
			set  Incentive = M_AD_Amount           
			from @Emp_Salary es inner join           
			(select mad.Emp_ID ,Month(To_Date)M_Month ,Year(To_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  dbo.T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join           
			#Emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type in (0) Inner join           
			T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID           
			Where Mad.Cmp_ID = @Cmp_ID and (AD_NAME like '%Incentive%' or AD_NAME Like '%Other Allowance%')  and month(To_Date) = month(@To_Date) and year(To_Date)= Year(@To_Date)          
			group by mad.Emp_ID ,Month(To_Date),Year(To_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year          

			--For Kataria: Incentive Allowance is used to display amount
			Update  @Emp_Salary          
			Set  Incentive_Actual = EED.E_AD_AMOUNT           
			from @Emp_Salary es inner join  
			T0100_EMP_EARN_DEDUCTION EED on es.Emp_ID = EED.EMP_ID
			Inner Join T0095_INCREMENT I On I.Increment_ID = EED.INCREMENT_ID Inner Join
			(Select MAX(Increment_ID)Increment_ID,Emp_Id	-- Ankit 05092014 for Same Date Increment
				From T0095_INCREMENT WITH (NOLOCK) Where Cmp_ID = @Cmp_ID And Increment_Effective_Date <= @To_Date
				Group by Emp_ID) Qry On I.Increment_ID = Qry.Increment_ID 
			And I.Emp_ID = Qry.Emp_ID Inner Join
			T0050_AD_MASTER AM WITH (NOLOCK) on EED.AD_ID = AM.AD_ID
			Where AD_NAME like '%Incentive%'

			--For Atul: Other Allowance is used to display amount
			Update  @Emp_Salary          
			Set  Incentive_Actual = EED.E_AD_AMOUNT           
			from @Emp_Salary es inner join  
			T0100_EMP_EARN_DEDUCTION EED on es.Emp_ID = EED.EMP_ID
			Inner Join T0095_INCREMENT I On I.Increment_ID = EED.INCREMENT_ID Inner Join
			(Select MAX(Increment_ID)Increment_ID,Emp_Id	-- Ankit 05092014 for Same Date Increment
				From T0095_INCREMENT WITH (NOLOCK) Where Cmp_ID = @Cmp_ID And Increment_Effective_Date <= @To_Date
				Group by Emp_ID) Qry On I.Increment_ID = Qry.Increment_ID 
			And I.Emp_ID = Qry.Emp_ID Inner Join
			T0050_AD_MASTER AM  WITH (NOLOCK) on EED.AD_ID = AM.AD_ID
			Where AD_NAME like '%Other%'
		 
		--Added by Gadriwala Muslim 28042015 - Start
			Update  @Emp_Salary          
			Set  DA = EED.E_AD_AMOUNT           
			from @Emp_Salary es inner join  
			T0100_EMP_EARN_DEDUCTION EED on es.Emp_ID = EED.EMP_ID
			Inner Join T0095_INCREMENT I On I.Increment_ID = EED.INCREMENT_ID Inner Join
			(Select MAX(Increment_ID)Increment_ID,Emp_Id	
				From T0095_INCREMENT WITH (NOLOCK) Where Cmp_ID = @Cmp_ID And Increment_Effective_Date <= @To_Date
				Group by Emp_ID) Qry On I.Increment_ID = Qry.Increment_ID 
			And I.Emp_ID = Qry.Emp_ID Inner Join
			T0050_AD_MASTER AM WITH (NOLOCK) on EED.AD_ID = AM.AD_ID
			Where AD_DEF_ID = 11    -- Dearness Allowance (DA) 
		--Added by Gadriwala Muslim 28042015 - End
		   Update  @Emp_Salary          
		   set PF_Amount = M_AD_Amount,PF_Calc_On_Amount = M_AD_Calculated_Amount
		   from @Emp_Salary es inner join           
		   (select mad.Emp_ID ,Month(To_Date)M_Month ,Year(To_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount,SUM(M_AD_Calculated_Amount)M_AD_Calculated_Amount
		    From  T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join           
			#Emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and isnull(Sal_Type,0) = 0 Inner join           
			T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID           
		   Where Mad.Cmp_ID = @Cmp_ID and AD_Def_ID = 2 and month(To_Date) = month(@to_date) and Year(To_Date)= Year(@To_Date)          
		   group by mad.Emp_ID ,Month(To_Date),Year(To_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year       

		   Update  @Emp_Salary          
		   set ESIC_Amount = M_AD_Amount,ESIC_Calc_On_Amount = M_AD_Calculated_Amount
		   from @Emp_Salary es inner join           
		   (select mad.Emp_ID ,Month(To_Date)M_Month ,Year(To_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount,sum(M_AD_Calculated_Amount) M_AD_Calculated_Amount 
		   From  T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join           
			#Emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and isnull(Sal_Type,0) = 0 Inner join           
			T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID           
		   Where Mad.Cmp_ID = @Cmp_ID and AD_Def_ID = 3 and month(To_Date) = month(@to_date) and Year(To_Date)= Year(@To_Date)          
		   group by mad.Emp_ID ,Month(To_Date),Year(To_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year       

			Update  @Emp_Salary          
			set  Mobile_JV = M_AD_Amount           
			from @Emp_Salary es inner join           
			(select mad.Emp_ID ,Month(To_Date)M_Month ,Year(To_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  dbo.T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join           
			#Emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type = 0 Inner join           
			T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID           
			Where Mad.Cmp_ID = @Cmp_ID and AD_NAME like '%Mobile%' and month(To_Date) = month(@to_date) and Year(To_Date)= Year(@To_Date)          
			group by mad.Emp_ID ,Month(To_Date),Year(To_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year          

			Update  @Emp_Salary          
			set  Voucher = M_AD_Amount           
			from @Emp_Salary es inner join           
			(select mad.Emp_ID ,Month(To_Date)M_Month ,Year(To_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  dbo.T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join           
			#Emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type = 0 Inner join           
			T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID           
			Where Mad.Cmp_ID = @Cmp_ID and AD_NAME like '%Voucher%' and month(To_Date) = month(@to_date) and Year(To_Date)= Year(@To_Date)          
			group by mad.Emp_ID ,Month(To_Date),Year(To_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year          

			Update  @Emp_Salary          
			set  Mediclaim = M_AD_Amount           
			from @Emp_Salary es inner join           
			(select mad.Emp_ID ,Month(To_Date)M_Month ,Year(To_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  dbo.T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join           
			#Emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type = 0 Inner join           
			T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID           
			Where Mad.Cmp_ID = @Cmp_ID and AD_NAME like '%Mediclaim%' and month(To_Date) = month(@to_date) and Year(To_Date)= Year(@To_Date)          
			group by mad.Emp_ID ,Month(To_Date),Year(To_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year          

			Update  @Emp_Salary          
			set  Accident_Policy = M_AD_Amount           
			from @Emp_Salary es inner join           
			(select mad.Emp_ID ,Month(To_Date)M_Month ,Year(To_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  dbo.T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join           
			#Emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type = 0 Inner join           
			T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID           
			Where Mad.Cmp_ID = @Cmp_ID and AD_NAME like '%Accident%' and month(To_Date) = month(@to_date) and Year(To_Date)= Year(@To_Date)          
			group by mad.Emp_ID ,Month(To_Date),Year(To_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year         
			
			Update  @Emp_Salary          
			set  Other_Total  = M_AD_Amount           
			from @Emp_Salary es inner join           
			(select mad.Emp_ID ,Month(To_Date)M_Month ,Year(To_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  dbo.T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join           
			#Emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type = 0 Inner join           
			T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID           
			Where Mad.Cmp_ID = @Cmp_ID and month(To_Date) = month(@to_date) and Year(To_Date)= Year(@To_Date)and Am.AD_ACTIVE =1 and isnull(Am.AD_NOT_EFFECT_SALARY,0) = 1         
			group by mad.Emp_ID ,Month(To_Date),Year(To_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year    
			
			
			--added by jimit 09122016 for Atul 
			UPDATE  @EMP_SALARY
			SET		EMPLOYEE_RETENTION = M_AD_AMOUNT
			FROM	@EMP_SALARY ES INNER JOIN
					(SELECT		MAD.EMP_ID ,MONTH(TO_DATE)M_MONTH ,YEAR(TO_DATE)M_YEAR,ISNULL(SUM(M_AD_AMOUNT),0)M_AD_AMOUNT 
					 FROM		T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) INNER JOIN
								#EMP_CONS EC ON EC.EMP_ID = MAD.EMP_ID AND SAL_TYPE = 0 INNER JOIN
								T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID 
					WHERE		MAD.CMP_ID = @CMP_ID AND UPPER(AD_NAME) LIKE '%EMPLOYEE RETENTION%' AND MONTH(TO_DATE) = MONTH(@TO_DATE) AND YEAR(TO_DATE) = YEAR(@TO_DATE) 
					GROUP BY	MAD.EMP_ID,MONTH(TO_DATE),YEAR(TO_DATE))Q ON ES.EMP_ID = Q.EMP_ID AND SAL_MONTH = M_MONTH AND SAL_YEAR = M_YEAR
			--ended
			
			
		end          
	else          
		begin          
			If @Sal_Type =3          
				set @Sal_Type = null          
			
			Update  @Emp_Salary          
			set  Incentive = M_AD_Amount           
			from @Emp_Salary es inner join           
			(select mad.Emp_ID ,Month(To_Date)M_Month ,Year(To_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  dbo.T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join           
			#Emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and isnull(Sal_Type,0) = isnull(@Sal_Type,isnull(Sal_Type,0))Inner join           
			T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID           
			Where Mad.Cmp_ID = @Cmp_ID and (AD_NAME like '%Incentive%' or AD_NAME Like '%Other Allowance%') and month(To_Date) = month(@to_date) and Year(To_Date)= Year(@To_Date)          
			group by mad.Emp_ID ,Month(To_Date),Year(To_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year          

			Update  @Emp_Salary          
			set  Mobile_JV = M_AD_Amount           
			from @Emp_Salary es inner join           
			(select mad.Emp_ID ,Month(To_Date)M_Month ,Year(To_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  dbo.T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join           
			#Emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type in (@sal_Type,0) Inner join           
			T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID           
			Where Mad.Cmp_ID = @Cmp_ID and AD_NAME like '%Mobile%' and month(To_Date) = month(@to_date) and Year(To_Date)= Year(@To_Date)          
			group by mad.Emp_ID ,Month(To_Date),Year(To_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year          

			Update  @Emp_Salary          
			set  Voucher = M_AD_Amount           
			from @Emp_Salary es inner join           
			(select mad.Emp_ID ,Month(To_Date)M_Month ,Year(To_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  dbo.T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join           
			#Emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type in (@sal_Type,0) Inner join           
			T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID           
			Where Mad.Cmp_ID = @Cmp_ID and AD_NAME like '%Voucher%' and month(To_Date) = month(@to_date) and Year(To_Date)= Year(@To_Date)          
			group by mad.Emp_ID ,Month(To_Date),Year(To_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year          

			Update  @Emp_Salary          
			set  Mediclaim = M_AD_Amount           
			from @Emp_Salary es inner join           
			(select mad.Emp_ID ,Month(To_Date)M_Month ,Year(To_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  dbo.T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join           
			#Emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type in (@sal_Type,0) Inner join           
			T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID           
			Where Mad.Cmp_ID = @Cmp_ID and AD_NAME like '%Mediclaim%' and month(To_Date) = month(@to_date) and Year(To_Date)= Year(@To_Date)          
			group by mad.Emp_ID ,Month(To_Date),Year(To_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year          

			Update  @Emp_Salary          
			set  Accident_Policy = M_AD_Amount           
			from @Emp_Salary es inner join           
			(select mad.Emp_ID ,Month(To_Date)M_Month ,Year(To_Date)M_Year,Sum(M_AD_Amount)M_AD_Amount From  dbo.T0210_monthly_AD_detail mad WITH (NOLOCK) Inner join           
			#Emp_Cons ec on MAD.Emp_ID= EC.Emp_ID and Sal_Type in (@sal_Type,0) Inner join           
			T0050_AD_Master am WITH (NOLOCK) on mad.AD_ID = AM.AD_ID           
			Where Mad.Cmp_ID = @Cmp_ID and AD_NAME like '%Accident%' and month(To_Date) = month(@to_date) and Year(To_Date)= Year(@To_Date)          
			group by mad.Emp_ID ,Month(To_Date),Year(To_Date) )Q on es.emp_Id =Q.emp_ID and Sal_Month =M_Month and sal_Year =M_Year          
		       
		    --added by jimit 09122016 for Atul
		    
		     
			UPDATE  @EMP_SALARY
			SET		EMPLOYEE_RETENTION = M_AD_AMOUNT
			FROM	@EMP_SALARY ES INNER JOIN
					(SELECT		MAD.EMP_ID ,MONTH(TO_DATE)M_MONTH ,YEAR(TO_DATE)M_YEAR,ISNULL(SUM(M_AD_AMOUNT),0)M_AD_AMOUNT 
					 FROM		T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)  INNER JOIN
								#EMP_CONS EC ON EC.EMP_ID = MAD.EMP_ID AND SAL_TYPE = 0 INNER JOIN
								T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.AD_ID = AM.AD_ID 
					WHERE		MAD.CMP_ID = @CMP_ID AND UPPER(AM.AD_NAME) LIKE '%EMPLOYEE RETENTION%' AND MONTH(TO_DATE) = MONTH(@TO_DATE) AND YEAR(TO_DATE) = YEAR(@TO_DATE) 
					GROUP BY	MAD.EMP_ID,MONTH(TO_DATE),YEAR(TO_DATE))Q ON ES.EMP_ID = Q.EMP_ID AND SAL_MONTH = M_MONTH AND SAL_YEAR = M_YEAR
			--ended
			   
		          
		end
		
		                 
		if @Sal_Type=0
			begin				
				-- Changed By Ali 22112013 EmpName_Alias
				Select ROW_NUMBER()  OVER (ORDER BY  MS.Emp_Id) As SrNo, MS.*
					--,Emp_First_Name + ' ' + Emp_Second_Name + ' ' + Emp_Last_Name as Emp_full_Name
					,ISNULL(EmpName_Alias_Salary,Emp_First_Name + ' ' + Emp_Second_Name + ' ' + Emp_Last_Name) as Emp_full_Name
					,Grd_Name, Branch_Address, Comp_name, Branch_Name          
					,Alpha_Emp_Code as EMP_CODE, Type_Name, Dept_Name, Desig_Name, Inc_Bank_Ac_no, PAN_no, Date_Of_Birth, Date_of_Join,
					SSN_No as PF_No, SIN_No as ESIC_No, dbo.F_Number_TO_Word(ms.Net_Amount) as Net_Amount_In_Word          
					,Bank_Name, CMP_NAME, CMP_ADDRESS--, Sal_St_Date
					,Branch_Name, I_Q.Gross_Salary as CTC, I_Q.Basic_Salary as Basic, BM.Branch_ID,Vs.Vertical_Name
					,DGM.Desig_Dis_No                 --added jimit 28082015
				From @Emp_Salary MS Inner join           
					T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID INNER  JOIN           
					#Emp_Cons EC ON E.EMP_ID = EC.EMP_ID inner join           
					dbo.T0095_Increment I_Q WITH (NOLOCK) on ms.emp_id = I_Q.emp_id INNER JOIN   
					(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
				Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) Qry on I_Q.Increment_Id = Qry.Increment_Id INNER JOIN
					        
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN          
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN          
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN          
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id left outer join  
					
					T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID Left outer Join           
					T0040_Bank_master bk WITH (NOLOCK) on i_Q.Bank_ID = Bk.Bank_ID inner join           
					T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID  left join 
					T0040_Vertical_Segment VS WITH (NOLOCK) on I_Q.Vertical_ID = Vs.Vertical_ID
					
				WHERE E.Cmp_ID = @Cmp_Id and ms.Salary_Amount >0 Order By Emp_Code
			End
		else 
			begin


				Select ROW_NUMBER()  OVER (Order by CASE WHEN @Order_By='Enroll_No' THEN RIGHT(REPLICATE('0',21) + CAST(E.Enroll_No AS VARCHAR), 21)  --Added by Jaina 31 July 2015 start
							WHEN @Order_By='Name' THEN E.Emp_Full_Name
							When @Order_By = 'Designation' then (CASE WHEN dgm.Desig_dis_No  = 0 THEN dgm.Desig_Name ELSE RIGHT(REPLICATE('0',21) + CAST(dgm.Desig_dis_No AS VARCHAR), 21)   END)      --added jimit 25092015
							--ELSE RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
						End,Case When IsNumeric(Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','')) = 1 then Right(Replicate('0',21) + Replace(Replace(E.Alpha_Emp_Code,'="',''),'"',''), 20)
								 When IsNumeric(Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','')) = 0 then Left(Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','') + Replicate('',21), 20)
								 Else Replace(Replace(E.Alpha_Emp_Code,'="',''),'"','') End--ORDER BY  RIGHT(REPLICATE(N' ', 500) + e.Alpha_Emp_Code, 500)
			)
			 As Sr_No
			 ,e.Alpha_Emp_Code as Employee_Code, 
					DGM.Desig_Name as Designation,
					GM.Grd_Name as Grade_Name,
					E.SSN_No as PF_AC_Number,
					Case Upper(MS.Payment_Mode)
						When 'BANK TRANSFER' Then Inc_Bank_AC_No  
						When 'CASH' Then 'CASH' 
						Else 'CHEQUE' End As Bank_AC_No,
					Emp_First_Name + ' ' + Emp_Second_Name + ' ' + Emp_Last_Name as Employee_Name,
					I_Q.Basic_Salary as Basic,
					I_Q.Gross_Salary,MS.Incentive,MS.PF_Amount as PF,MS.PT_Amount as Prof_Tax,MS.TDS_Amount as TDS,Ms.DA as DA,MS.Loan_Advance_Amount as Loan_Advance,MS.ESIC_Amount as ESI,MS.Net_Amount as Net_Salary
					,Vs.Vertical_Name
					,BM.Branch_ID
				From @Emp_Salary MS Inner join           
					T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID INNER  JOIN           
					#Emp_Cons EC ON E.EMP_ID = EC.EMP_ID inner join           
					dbo.T0095_Increment I_Q WITH (NOLOCK) on Ms.Emp_id = I_Q.Emp_id inner join
						(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
				Where TI.Increment_effective_Date <= @to_date group by ti.emp_id) 
				Qry on I_Q.Increment_Id = Qry.Increment_Id 
				
					
					INNER JOIN           
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN          
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN          
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN          
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id left outer join  --Inner join        
					--T0040_General_setting GS on I_Q.Branch_ID =GS.Branch_ID left outer join  
					T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID Left outer Join           
					T0040_Bank_master bk WITH (NOLOCK) on i_Q.Bank_ID = Bk.Bank_ID inner join           
					T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID     left join 
					T0040_Vertical_Segment VS WITH (NOLOCK) on I_Q.Vertical_ID = Vs.Vertical_ID    
				WHERE E.Cmp_ID = @Cmp_Id and ms.Salary_Amount >0 and PF_Amount > 0
			--	Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			--When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
			--	Else e.Alpha_Emp_Code
			--End
			Order by Sr_No
						 --RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 
				--Order By RIGHT(REPLICATE(N' ', 500) + e.Alpha_Emp_Code, 500)
			End
		
 RETURN           



