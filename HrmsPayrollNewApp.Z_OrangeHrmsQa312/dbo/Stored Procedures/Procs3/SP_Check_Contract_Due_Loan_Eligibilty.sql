CREATE Procedure [dbo].[SP_Check_Contract_Due_Loan_Eligibilty]
@Loan_ID int ,
@Emp_id int
As 
Begin

Declare @Iscontr int 
Declare @ContraDue int
select @Iscontr =  IsContractDue, @ContraDue = ContractDueDays from T0040_LOAN_MASTER where Loan_ID=@Loan_ID

IF @Iscontr = 1
Begin
    If Not Exists (select 1 from T0090_EMP_CONTRACT_DETAIL where Emp_ID =@Emp_id)
	Begin  
			Select '@@Contract is not available with employee@@'
			RETURN   
	End
	Else
	Begin
	
		Declare @ConExp int 
		select @ConExp = datediff(Day,Getdate(),max(End_Date)) from T0090_EMP_CONTRACT_DETAIL where Emp_ID =@Emp_id 
		
		IF @ConExp < 0
		Begin
				select  '@@Contract is Expired@@'
				RETURN   
		End
		else IF @ContraDue > @ConExp
		Begin
				select  '@@Contract is Expiring '+ (select cast(@ConExp as varchar(100))) +' in days@@'
				RETURN   
		End	
	End

End



End