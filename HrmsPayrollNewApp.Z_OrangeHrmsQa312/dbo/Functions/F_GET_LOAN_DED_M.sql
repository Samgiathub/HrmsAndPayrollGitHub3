




CREATE FUNCTION [DBO].[F_GET_LOAN_DED_M] 
	(
		@For_Date as datetime ,
		@Loan_Apr_Date as datetime,
		@Deduction_Type as varchar(20)
	)
RETURNS Varchar(max)
AS
		begin
			Declare @Ded_Str varchar(max)
			set @Ded_Str=''
			
			if @Deduction_Type='Quaterly'	
				Begin	
--Commented by Hardik 27/12/2011 and put Month Name				
/*					set @Ded_Str =  '#' + cast(Month(@Loan_Apr_Date) as varchar(5)) + '#'
					set @Ded_Str =   @Ded_Str + cast(Month(dateadd(m,3,@Loan_Apr_Date)) as varchar(5)) + '#'
					set @Ded_Str =   @Ded_Str + cast(Month(dateadd(m,6,@Loan_Apr_Date)) as varchar(5)) + '#'
					set @Ded_Str =   @Ded_Str + cast(Month(dateadd(m,9,@Loan_Apr_Date)) as varchar(5))  + '#'
*/		
					set @Ded_Str =  '#' + cast(Datename(m,@Loan_Apr_Date) as varchar(3)) + '#'
					set @Ded_Str =   @Ded_Str + cast(Datename(m,dateadd(m,3,@Loan_Apr_Date)) as varchar(3)) + '#'
					set @Ded_Str =   @Ded_Str + cast(Datename(m,dateadd(m,6,@Loan_Apr_Date)) as varchar(3)) + '#'
					set @Ded_Str =   @Ded_Str + cast(Datename(m,dateadd(m,9,@Loan_Apr_Date)) as varchar(3))  + '#'
				End
			else if @Deduction_Type='Half Yearly'
				Begin
/*					set @Ded_Str =  '#' + cast(Month(@Loan_Apr_Date) as varchar(5)) + '#'
					set @Ded_Str =   @Ded_Str + cast(Month(dateadd(m,6,@Loan_Apr_Date)) as varchar(5))  + '#'
*/					
					set @Ded_Str =  '#' + cast(Datename(m,@Loan_Apr_Date) as varchar(3)) + '#'
					set @Ded_Str =   @Ded_Str + cast(Datename(m,dateadd(m,6,@Loan_Apr_Date)) as varchar(3))  + '#'
				End
			else if @Deduction_Type='Yearly'	
				Begin
--					set @Ded_Str =  '#' + cast(Month(@Loan_Apr_Date) as varchar(5)) + '#'
					set @Ded_Str =  '#' + cast(Datename(m,@Loan_Apr_Date) as varchar(3)) + '#'
				End
			RETURN @Ded_Str 
		end




