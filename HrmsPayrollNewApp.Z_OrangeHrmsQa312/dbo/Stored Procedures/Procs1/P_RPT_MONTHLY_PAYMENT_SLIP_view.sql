
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_RPT_MONTHLY_PAYMENT_SLIP_view]  
  @CMP_ID   NUMERIC  
 ,@EMP_ID   NUMERIC  
 ,@PROCESS_TYPE VARCHAR(500) = 'SALARY'
 ,@AD_ID NUMERIC = 0
 ,@PAYMENT_PROCESS_ID NUMERIC(18,0) = 0
 ,@PROCESS_TYPE_ID NUMERIC(18,0) = 0
 ,@CONSTRAINT  varchar(max)=''
 ,@From_Date  datetime =null
 ,@To_Date   datetime  =null
 ,@Branch_ID  varchar(max) = '0'
 ,@Cat_ID  varchar(max) = '0'
 ,@Grd_ID   varchar(max) = '0'
 ,@Type_ID varchar(max) = '0'
 ,@Dept_ID   varchar(max) = '0'
 ,@Desig_ID   varchar(max) = '0' 
 ,@Sal_Type  numeric = 0  
 ,@Salary_Cycle_id numeric = NULL
 ,@Segment_Id  varchar(max) = '0'	 
 ,@Vertical_Id varchar(max) = '0'	 
 ,@SubVertical_Id varchar(max) = '0' 
 ,@SubBranch_Id varchar(max) = '0'
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	 CREATE table #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_ID,0,0,0,'0',0,0               



 if @process_type = '' 
 begin
 	set @ad_Id=null
 end
 if @payment_process_id = 0
	Begin
		set @payment_process_id=null;
	End
if @process_type_ID = 0
	Begin
		set @process_type_ID=null;
	End	
	
  if @process_type = 'Salary' or  @process_type = 'Bonus' or  @process_type = 'Leave Encashment' --or @process_type = 'Allowance'
  begin
	set @ad_Id=0
  end
  
 --if @process_type = 'Allowance'
	--Begin
	--	set @process_type=null;
	--End
 if @process_type_id > 9000
	Begin
		--set @process_type_id = 0;
		set @process_type_id = NULL;
	End
 Else
	Begin
		set @ad_Id = NULL;  --Change by Jaina 08-09-2017
	End		
	
 -- commeneted and changed by rohit for bonus slip on 07112016
 --	Select E.Emp_ID,Emp_full_Name,DAteName(M,MS.For_date)as Month,YEar(MS.For_date)as Year 
	--		   ,Alpha_Emp_Code as EMP_CODE,PAN_no,DAte_of_Birth,Date_of_Join,
	--		   SSN_No as PF_No
	--		   ,SIN_No as ESIC_No ,
	--		   DATE_OF_JOIN,ms.Payment_mode  as Payment_Mode,
	--		   E.Ifsc_Code,cast(e.Alpha_Emp_Code as nvarchar(50)) as Alpha_Emp_Code , 
	--		   MS.Net_Amount As Net_Amt,
	--		   ms.process_type as process_type,
	--		   --case when isnull(Am.ad_name,'')<>'' then Am.ad_name else ms.process_type end as Ad_name
	--		   case when isnull(Am.ad_name,'')<>'' then Am.ad_name when isnull(LM.Loan_name,'')<>'' then Lm.Loan_Name when isnull(LMM.Leave_name,'')<>'' then LMM.Leave_name   else ms.process_type end as Ad_name -- Added by rohit for loan and leave on 06012016
	--		   ,ms.ad_id,ms.For_date,ms.payment_Date,MS.Status 
	--		   ,case when PD.Amount is not null then PD.Amount else case when ENS.Amount is not null then isnull(ENS.Amount,0)else MS.Net_Amount  end end as Amount
	--		   ,case when PD.Amount is not null then PD.Esic else  isnull(ENS.Esic,0) end as Esic,
	--		   case when PD.Amount is not null then PD.comp_esic else isnull(ENS.Comp_Esic,0) end as Comp_Esic ,
	--		    case when PD.Amount is not null then PD.TDS else isnull(ENS.TDS,0) end as TDS,
	--		   isnull(Ens.Hours,0) as Hours ,
	--		   ens.Modify_Date
			   
	--			From MONTHLY_EMP_BANK_PAYMENT MS Inner join   
	--			T0080_EMP_MASTER E on MS.emp_ID = E.emp_ID inner join   
	--			T0010_COMPANY_MASTER CM ON MS.CMP_ID = CM.CMP_ID left join
	--			T0210_ESIC_On_Not_Effect_on_Salary ENS on MS.Emp_ID = ENS.Emp_Id and ms.Ad_Id = ENS.Ad_Id 
	--			and month(ms.For_Date) = MONTH(ENS.For_Date) and year(ms.For_Date) = YEAR(ENS.For_Date)
	--			inner join #Emp_Cons Ec on Ec.Emp_ID=Ms.Emp_ID left join 
	--			t0302_process_detail PD on MS.payment_process_id = Pd.payment_process_id 
	--			left join T0050_AD_MASTER Am on Pd.Ad_id = Am.Ad_Id 
	--			left join T0040_LOAN_MASTER LM on Pd.Loan_Id = LM.Loan_Id 
	--			left join T0040_LEAVE_MASTER LMM on Pd.leave_id= LMM.leave_id
	--			WHERE E.Cmp_ID = @Cmp_Id   
	--			--and ms.ad_id = isnull(@ad_id,ms.ad_id)
	--			--and ms.Emp_ID=@Emp_ID
				
	--			--and ms.Process_Type=ISNULL(@process_type,ms.Process_Type)
	--			and ms.payment_process_id = isnull(@payment_process_id,ms.payment_process_id)
	--			and ms.process_type_id = isnull(@process_type_id,ms.process_type_id)
	--			and MS.for_date  >= isnull(@From_Date,ms.For_Date) and MS.for_date  <= isnull(@To_Date,ms.For_Date)
	--			and ms.Ad_Id=ISNULL(@ad_Id,ms.Ad_Id)
	--			--and 1 = (case when ms.Process_Type = @process_type  then 1 when @ad_Id >0 then 1 else 0 end)
 --RETURN   

IF OBJECT_ID('tempdb..#Process_Detail') IS NULL
	BEGIN
		CREATE TABLE #Process_Detail(
			[tran_id] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
			[cmp_id] [numeric](18, 0) NOT NULL,
			[emp_id] [numeric](18, 0) NOT NULL,
			[For_Date] [datetime] NOT NULL,
			[process_type_id] [numeric](18, 0) NOT NULL,
			[payment_process_id] [numeric](18, 0) NOT NULL,
			[Ad_id] [numeric](18, 0) NOT NULL,
			[Amount] [numeric](18, 2) NOT NULL,
			[Esic] [numeric](18, 2) NOT NULL,
			[Comp_Esic] [numeric](18, 2) NOT NULL,
			[Net_Amount] [numeric](18, 2) NOT NULL,
			[modify_date] [datetime] NOT NULL,
			[TDS] [numeric](18, 2) NOT NULL,
			[Loan_Id] [numeric](18, 2) NOT NULL,
			[Leave_Id] [numeric](18, 2) NOT NULL,
			[Hours] [numeric](18,0) null,
			[Punja] [numeric](18,2) not null default(0),
			[Intrim_Bonus] [Numeric](18,2) not null default(0),
			[mis_deduction] [numeric] (18,2) not null default(0), 
			[Income_Tax] [numeric](18,2) not null default(0),
			[Ad_Name] [varchar](100),
			[Loan_Amount] [Numeric](18,2) not null default(0)
		 )	
	END

	
if @process_type = 'Bonus' 
	BEGIN
		INSERT INTO #PROCESS_DETAIL -- For Bonus Amount 
			(cmp_id,emp_id,For_Date,process_type_id,payment_process_id,Ad_id,Amount,Esic,Comp_Esic,Net_Amount,modify_date,TDS,Loan_Id,Leave_Id,Hours,Punja,Intrim_Bonus,mis_deduction,Income_Tax,Ad_Name)
		SELECT MS.Cmp_ID,MS.Emp_ID,For_Date,process_type_id,payment_process_id,Ad_id,b.Bonus_Amount ,0,0,Net_Amount,GETDATE(),0,0,0,0,Punja_other_cust_bonus_paid,Intrime_advance_bonus_paid,Deduction_mis_Amount,Income_Tax_on_Bonus,'Bonus'
		FROM MONTHLY_EMP_BANK_PAYMENT MS WITH (NOLOCK)
			INNER JOIN T0180_BONUS B WITH (NOLOCK) on ms.Emp_ID = B.Emp_ID and Process_Type='Bonus' and ms.For_Date = dbo.GET_MONTH_END_DATE(B.Bonus_Effect_Month,B.Bonus_Effect_Year) and b.Bonus_Effect_on_Sal = 0
			inner join #Emp_Cons E on Ms.Emp_ID = E.Emp_ID
		WHERE ms.Cmp_ID = @Cmp_Id   
			and ms.payment_process_id = isnull(@payment_process_id,ms.payment_process_id)
			and ms.process_type_id = isnull(@process_type_id,ms.process_type_id)
			and MS.for_date  >= isnull(@From_Date,ms.For_Date) and MS.for_date  <= isnull(@To_Date,ms.For_Date)
			and isnull(B.Bonus_Amount,0) >0 
		
		INSERT INTO #PROCESS_DETAIL -- FOR EXGRATIA
			(cmp_id,emp_id,For_Date,process_type_id,payment_process_id,Ad_id,Amount,Esic,Comp_Esic,Net_Amount,modify_date,TDS,Loan_Id,Leave_Id,Hours,Punja,Intrim_Bonus,mis_deduction,Income_Tax,Ad_name)
		SELECT MS.Cmp_ID,MS.Emp_ID,For_Date,process_type_id,payment_process_id,Ad_id,b.Ex_Gratia_Bonus_Amount ,0,0,Net_Amount,GETDATE(),0,0,0,0,
		case when isnull(B.bonus_amount,0)> 0 then 0 else Punja_other_cust_bonus_paid end as punja,case when isnull(B.bonus_amount,0)> 0 then 0 else Intrime_advance_bonus_paid end as Intrim_Bonus,case when isnull(B.bonus_amount,0)> 0 then 0 else Deduction_mis_Amount end as mis_deduction,case when isnull(B.bonus_amount,0)> 0 then 0 else Income_Tax_on_Bonus end as Income_Tax 
		--0,0,0,0
		,'Exgratia - Bonus'
		FROM MONTHLY_EMP_BANK_PAYMENT MS WITH (NOLOCK) inner join T0180_BONUS B WITH (NOLOCK)
			on ms.Emp_ID = B.Emp_ID and Process_Type='Bonus' and ms.For_Date = dbo.GET_MONTH_END_DATE(B.Bonus_Effect_Month,B.Bonus_Effect_Year) 
			and b.Bonus_Effect_on_Sal = 0
			inner join #Emp_Cons E on Ms.Emp_ID = E.Emp_ID
		WHERE ms.Cmp_ID = @Cmp_Id   
		and ms.payment_process_id = isnull(@payment_process_id,ms.payment_process_id)
		and ms.process_type_id = isnull(@process_type_id,ms.process_type_id)
		and MS.for_date  >= isnull(@From_Date,ms.For_Date) and MS.for_date  <= isnull(@To_Date,ms.For_Date)
		and isnull(B.Ex_Gratia_Bonus_Amount,0) >0
	END
ELSE
	BEGIN		
	
			INSERT INTO #PROCESS_DETAIL 
				(cmp_id,emp_id,For_Date,process_type_id,payment_process_id,Ad_id,Amount,Esic,Comp_Esic,Net_Amount,modify_date,TDS,Loan_Id,Leave_Id,Hours,Punja,Intrim_Bonus,mis_deduction,Income_Tax,Ad_name,Loan_Amount)
			SELECT  COALESCE(pd.cmp_id,ED.cmp_id,MS.Cmp_ID) as cmp_id
					,COALESCE(pd.Emp_Id,ED.Emp_Id,MS.Emp_ID)  as Emp_Id 
					, COALESCE(pd.For_Date,ED.For_Date,MS.For_Date) as For_date ,
					isnull(MS.process_type_id,0) as process_type_id 
					,ISNULL(MS.payment_process_id ,0) as payment_process_id,
					COALESCE(pd.Ad_id,ED.Ad_id,MS.Ad_Id) as Ad_id					
					--,COALESCE(PD.Amount,ED.Amount,MS.Net_Amount) as Amount
					,COALESCE(PD.Amount,0,0) as Amount
					,COALESCE(pd.Esic,ED.Esic,0) as Esic
					,COALESCE(pd.Comp_Esic,ED.Comp_Esic,0) as Comp_Esic 
					,COALESCE(pd.Net_Amount,ED.Net_Amount,MS.Net_Amount) 
					,COALESCE(pd.modify_date,ED.modify_date,MS.for_date) as Modify_Date
					--,COALESCE(pd.TDS,ED.TDS,0) as TDS 
					,COALESCE(pd.TDS,ED.TDS,0) as TDS 
					,isnull(pd.Loan_Id,0)
					,isnull(pd.Leave_Id,0),Hours,0,0,0,0,
					CASE WHEN isnull(Am.ad_name,'')<>'' 
							THEN Am.ad_name 
						WHEN isnull(LM.Loan_name,'')<>'' 
							THEN Lm.Loan_Name
						WHEN isnull(LMM.Leave_name,'')<>'' 
							THEN LMM.Leave_name
						WHEN isnull(BM.Bond_Name,'') <>'' 
							THEN BM.Bond_Name
						ELSE 
							ms.process_type 
					END AS Ad_name,Isnull(ED.Loan_Amount,0)
			FROM MONTHLY_EMP_BANK_PAYMENT MS WITH (NOLOCK)
				LEFT JOIN T0210_ESIC_On_Not_Effect_on_Salary ED WITH (NOLOCK) on MS.Emp_ID = ED.Emp_Id and ms.Ad_Id = ED.Ad_Id and month(ms.For_Date) = MONTH(ED.For_Date) and year(ms.For_Date) = YEAR(ED.For_Date)
				INNER JOIN #Emp_Cons Ec on Ec.Emp_ID=Ms.Emp_ID 
				LEFT JOIN t0302_process_detail PD WITH (NOLOCK) on MS.payment_process_id = Pd.payment_process_id 
				LEFT JOIN T0050_AD_MASTER Am WITH (NOLOCK) on Pd.Ad_id = Am.Ad_Id 
				LEFT JOIN T0040_LOAN_MASTER LM WITH (NOLOCK) on Pd.Loan_Id = LM.Loan_Id 
				LEFT JOIN T0040_LEAVE_MASTER LMM WITH (NOLOCK) on Pd.leave_id= LMM.leave_id
				--LEFT JOIN T0120_BOND_APPROVAL BA WITH (NOLOCK) ON MS.Payment_Process_ID = BA.Payment_Process_ID
				LEFT JOIN T0120_BOND_APPROVAL BA WITH (NOLOCK) ON MS.process_type_id = BA.Payment_Process_ID --Change by ronakk 05112022
				LEFT JOIN T0040_BOND_MASTER BM WITH (NOLOCK) ON BM.Bond_ID = BA.Bond_Id
			WHERE MS.Cmp_ID = @Cmp_Id   --and Process_Type = @process_type   --added by ronakk 20102022
					and ms.payment_process_id = isnull(@payment_process_id,ms.payment_process_id)
					and ms.process_type_id = isnull(@process_type_id,ms.process_type_id)
					and MS.for_date  >= isnull(@From_Date,ms.For_Date) and MS.for_date  <= isnull(@To_Date,ms.For_Date)
					--and CASE WHEN Process_Type <> 'Bond' then ms.ad_id else 0 end = isnull(@ad_id,ms.ad_id)
					--and ms.Ad_Id=ISNULL(@ad_Id,ms.Ad_Id)
					and ms.Status <> 'Hold'
	
--	select 11, * from #PROCESS_DETAIL			
	END		


	IF @Sal_Type <> 999
 		Select Distinct  E.Emp_ID,Emp_full_Name,DAteName(M,MS.For_date)as Month,YEar(MS.For_date)as Year 
				   ,Alpha_Emp_Code as EMP_CODE,PAN_no,DAte_of_Birth,Date_of_Join,
				   SSN_No as PF_No
				   ,SIN_No as ESIC_No ,
				   DATE_OF_JOIN,ms.Payment_mode  as Payment_Mode,
				   E.Ifsc_Code,cast(e.Alpha_Emp_Code as nvarchar(50)) as Alpha_Emp_Code , 
				   MS.Net_Amount As Net_Amt,
				   ms.process_type as process_type,
				   --case when isnull(Am.ad_name,'')<>'' then Am.ad_name else ms.process_type end as Ad_name
				  -- case when isnull(Am.ad_name,'')<>'' then Am.ad_name when isnull(LM.Loan_name,'')<>'' then Lm.Loan_Name when isnull(LMM.Leave_name,'')<>'' then LMM.Leave_name   else ms.process_type end as Ad_name -- Added by rohit for loan and leave on 06012016
				   pd.Ad_Name as Ad_name
				   ,ms.ad_id,ms.For_date,ms.payment_Date,MS.Status 
				   --,case when PD.Amount is not null then PD.Amount else case when ENS.Amount is not null then isnull(ENS.Amount,0)else MS.Net_Amount  end end as Amount
				  -- ,isnull(PD.Amount,isnull(ENS.Amount,MS.Net_Amount)) as Amount
				   ,PD.amount
				   ,pd.Esic as Esic,
				   PD.Comp_Esic as Comp_Esic ,
				   pd.TDS as TDS,
				   pd.Hours as Hours ,
				   pd.modify_date,
				   pd.Punja,
				   pd.Intrim_Bonus,
				   pd.mis_deduction,
				   pd.Income_Tax,
				   PD.Loan_Amount
					From MONTHLY_EMP_BANK_PAYMENT MS WITH (NOLOCK) Inner join   
					T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID inner join   
					T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID inner join
					#Process_Detail PD on ms.payment_process_id = PD.payment_process_id
					--T0210_ESIC_On_Not_Effect_on_Salary ENS on MS.Emp_ID = ENS.Emp_Id and ms.Ad_Id = ENS.Ad_Id 
					--and month(ms.For_Date) = MONTH(ENS.For_Date) and year(ms.For_Date) = YEAR(ENS.For_Date)
					--inner join #Emp_Cons Ec on Ec.Emp_ID=Ms.Emp_ID left join 
					--t0302_process_detail PD on MS.payment_process_id = Pd.payment_process_id 
					--left join T0050_AD_MASTER Am on Pd.Ad_id = Am.Ad_Id 
					--left join T0040_LOAN_MASTER LM on Pd.Loan_Id = LM.Loan_Id 
					--left join T0040_LEAVE_MASTER LMM on Pd.leave_id= LMM.leave_id
					--WHERE E.Cmp_ID = @Cmp_Id   
					----and ms.ad_id = isnull(@ad_id,ms.ad_id)
					----and ms.Emp_ID=@Emp_ID
					----and ms.Process_Type=ISNULL(@process_type,ms.Process_Type)
					--and ms.payment_process_id = isnull(@payment_process_id,ms.payment_process_id)
					--and ms.process_type_id = isnull(@process_type_id,ms.process_type_id)
					--and MS.for_date  >= isnull(@From_Date,ms.For_Date) and MS.for_date  <= isnull(@To_Date,ms.For_Date)
					--and ms.Ad_Id=ISNULL(@ad_Id,ms.Ad_Id)
					--and 1 = (case when ms.Process_Type = @process_type  then 1 when @ad_Id >0 then 1 else 0 end)

 RETURN   
