

---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_RPT_MONTHLY_PAYMENT_SLIP_ProcessType_Claim]  
  @CMP_ID   NUMERIC  
 ,@FROM_DATE  DATETIME  
 ,@TO_DATE   DATETIME  
 --,@BRANCH_ID  NUMERIC  
 ,@BRANCH_ID  VARCHAR(MAX)  
 ,@CAT_ID   VARCHAR(MAX)   
 ,@GRD_ID   VARCHAR(MAX)  
 ,@TYPE_ID   VARCHAR(max)  
 ,@Dept_ID   varchar(max)  
 ,@Desig_ID   varchar(max)  
 ,@Emp_ID   numeric  
 ,@constraint  varchar(max)  
 ,@Sal_Type  numeric = 0  
 ,@Bank_ID  numeric = 0  
 ,@Payment_mode varchar(20) =''  
 ,@salary_status  varchar(50) = 'All'
 ,@Director_details tinyint = 0   
 ,@Salary_Cycle_id numeric = NULL
 ,@Segment_Id  numeric = 0		 
 ,@Vertical_Id varchar(max) = ''
 ,@SubVertical_Id varchar(max) = ''	 
 ,@SubBranch_Id varchar(max) = ''
 ,@process_type varchar(500) = 'Salary'
 ,@ad_Id numeric = 0
 ,@process_type_id numeric(18,0) = 0		 
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON   
    
    
 IF @Branch_ID = '0' or @Branch_ID = ''
		set @Branch_ID = null
		
	IF @Cat_ID = '0'  or @Cat_ID = '' 
		set @Cat_ID = null

	IF @Grd_ID = '0'  or @Grd_ID = ''
		set @Grd_ID = null

	IF @Type_ID = '0'  or @Type_ID = ''  
		set @Type_ID = null

	IF @Dept_ID = '0'  or @Dept_ID = ''
		set @Dept_ID = null

	IF @Desig_ID = '0' or @Desig_ID = ''  
		set @Desig_ID = null
	
	If @Vertical_Id = '0' or @Vertical_Id = ''
	set @Vertical_Id = null
	If @SubVertical_Id = '0'	or @SubVertical_Id = ''
	set @SubVertical_Id = null	
  
 IF @Emp_ID = 0    
  set @Emp_ID = null  
    
 if @Bank_ID =0  
  set @Bank_ID = null  
  IF @Salary_Cycle_id = 0	
	set @Salary_Cycle_id = null	
	If @Segment_Id = 0		
	set @Segment_Id = null
		
	
	If @SubBranch_Id = 0	
	set @SubBranch_Id = null	

if @process_type = '' 
 begin
 	set @ad_Id=null
 end
 

  if @process_type = 'Salary' or  @process_type = 'Bonus' or  @process_type = 'Leave Encashment'
  begin
	set @ad_Id=0
  end
  
  
 CREATE table #Emp_Cons 
 (      
   Emp_ID numeric ,     
   Branch_ID numeric,
   Increment_ID numeric    
 )    
   
 --EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 
exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,@Segment_Id,@Vertical_Id,@SubVertical_Id,@SubBranch_ID,0,0,0,'0',0,0               





 if @Payment_mode = 'Transfer'  
  set @Payment_mode = 'Bank Transfer' 
  
  if @Payment_mode =''
	set @Payment_mode = null 

if @process_type_id > 9000
	Begin
	 print @process_type_id ---mansi
		set @process_type_id = null;
	End
 Else
	Begin
		set @ad_Id=NULL;
	End

 	Select  E.Emp_ID,Emp_full_Name,Branch_Address,branch_name,Comp_name,Grd_Name,DAteName(M,MS.For_date)as Month,YEar(MS.For_date)as Year ,Branch_NAme,Comp_Name  
			   ,Alpha_Emp_Code as EMP_CODE,Type_Name,Dept_Name,Desig_Name,PAN_no,DAte_of_Birth,Date_of_Join,
			   SSN_No as PF_No
			   ,SIN_No as ESIC_No 
			   ,Bank_Name ,CMP_NAME,CMP_ADDRESS, cm.Image_name as Cmp_Image_Name
			   
			   ,Branch_Code,DATE_OF_JOIN,BK.Bank_Ac_No As Cmp_Acc_No,ISNULL(Ms.Emp_Bank_AC_No,I_Q.Inc_Bank_Ac_no) as Inc_Bank_Ac_no,I_Q.Inc_Bank_Ac_no as Inc_Bank_Ac_no1
			   ,ms.Payment_mode  as Payment_Mode,bk.Bank_ID,bk.Bank_Address 
			   ,E.Ifsc_Code,BM.Branch_ID,cast(e.Alpha_Emp_Code as nvarchar(50)) as Alpha_Emp_Code , 
			   MS.Net_Amount As Net_Amt,
			   dbo.F_Number_TO_Word( MS.Net_Amount) as Net_Amount_In_Word
			   ,ms.process_type,ms.ad_id,ms.For_date,ms.payment_Date,MS.Status 
			   --,isnull(ENS.Amount,0) as Amount
			   ,case when isnull(ENS.Amount,0) = 0 then MS.Net_Amount else isnull(ENS.Amount,0) end  as Amount
			   ,isnull(ENS.Esic,0) as Esic,isnull(ENS.Comp_Esic,0) as Comp_Esic ,isnull(ENS.TDS,0) as TDS,isnull(Ens.Hours,0) as Hours ,ens.Modify_Date
			   ,cm.cmp_logo as cmp_logo,VM.Vertical_Name,SVM.SubVertical_Name,SBM.SubBranch_Name,Isnull(ENS.Loan_Amount,0) as Loan_Amount
			   ,CRD.Payment_Process_ID,cl.Claim_Name,CRD.claim_app_Ttl_Amount
			   --,sum(crd.claim_app_Ttl_Amount)
	From MONTHLY_EMP_BANK_PAYMENT MS WITH (NOLOCK)
	left join T0130_CLAIM_APPROVAL_DETAIL CRD with(NOLOCK) on CRD.Payment_Process_ID = MS.process_type_id 
	Inner join  T0080_EMP_MASTER E WITH (NOLOCK) on MS.emp_ID = E.emp_ID 
	inner join  #Emp_Cons EC on MS.Emp_ID = EC.Emp_ID 
	inner join  T0095_Increment I_Q WITH (NOLOCK) on E.Increment_ID = I_Q.Increment_ID 
	left join   T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
	LEFT OUTER JOIN  T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
	LEFT OUTER JOIN  T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
	LEFT OUTER JOIN  T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
	Inner join		T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID 
	Left outer Join   T0040_Vertical_Segment VM WITH (NOLOCK) on I_Q.Vertical_ID = Vm.Vertical_ID  
	left outer Join   T0050_SubVertical  SVM WITH (NOLOCK) on I_Q.SubVertical_ID = SVM.SubVertical_ID  
	left outer Join   T0050_SubBranch  SBM WITH (NOLOCK) on I_Q.subBranch_ID = SBM.SubBranch_ID  
	left outer Join   T0040_Bank_master bk WITH (NOLOCK) on i_Q.Bank_ID = Bk.Bank_ID 
	inner join   T0010_COMPANY_MASTER CM WITH (NOLOCK) ON MS.CMP_ID = CM.CMP_ID 
	--left join T0130_CLAIM_APPROVAL_DETAIL CRD with(NOLOCK) on CRD.Emp_ID=ms.Emp_ID 
	left join T0040_CLAIM_MASTER CL with(Nolock) on cl.Claim_ID=crd.Claim_ID
	left join	T0210_ESIC_On_Not_Effect_on_Salary ENS WITH (NOLOCK) on MS.Emp_ID = ENS.Emp_Id and ms.Ad_Id = ENS.Ad_Id and month(ms.For_Date) = MONTH(ENS.For_Date) and year(ms.For_Date) = YEAR(ENS.For_Date)
	WHERE E.Cmp_ID = @Cmp_Id   
	and isnull(i_Q.Bank_ID,0) = isnull(@Bank_ID,isnull(i_Q.Bank_ID,0))
	and I_q.Payment_mode = isnull(@Payment_mode,I_q.Payment_mode)  
	and MS.For_Date >=@From_Date and MS.For_Date  <=@To_Date 
	--and ms.ad_id = isnull(@ad_id,ms.ad_id)
	and CASE WHEN Process_Type <> 'Bond' then ms.ad_id else 0 end = isnull(@ad_id,ms.ad_id)
	and 1 = (case when ms.Process_Type = @process_type  then 1 when @ad_Id > 0 then 1 else 0 end)
	and 1=(case when (MS.Status = @salary_status) or (@salary_status = 'All') then 1 else 0 end )
	 --and isnull(CRD.Payment_Process_ID,0) > 0  
	-- group by 
	-- E.Emp_ID,Emp_full_Name,Branch_Address,branch_name,Comp_name,Grd_Name,
	--MS.For_date,Branch_NAme,Comp_Name,Alpha_Emp_Code,Dept_Name,Desig_Name,PAN_no,
	--DAte_of_Birth,Date_of_Join,
	--		   SSN_No 
	--		   ,SIN_No 
	--		   ,Bank_Name ,CMP_NAME,CMP_ADDRESS,
	--		   Branch_Code,DATE_OF_JOIN,BK.Bank_Ac_No,Ms.Emp_Bank_AC_No
	--		   ,ms.Payment_mode,bk.Bank_ID,bk.Bank_Address 
	--		   ,E.Ifsc_Code,BM.Branch_ID,e.Alpha_Emp_Code , 
	--		   MS.Net_Amount
	--		   ,ms.process_type,ms.ad_id,ms.For_date,ms.payment_Date,MS.Status
	--		   ,ENS.Amount
	--		   ,ENS.Esic,ENS.Comp_Esic,ENS.TDS,ens.Modify_Date
	--		   --,cm.cmp_logo
	--		   ,VM.Vertical_Name,SVM.SubVertical_Name,SBM.SubBranch_Name,ENS.Loan_Amount
	--		   ,crd.Payment_Process_ID,cl.Claim_Name,crd.claim_app_Ttl_Amount
 RETURN   
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  












