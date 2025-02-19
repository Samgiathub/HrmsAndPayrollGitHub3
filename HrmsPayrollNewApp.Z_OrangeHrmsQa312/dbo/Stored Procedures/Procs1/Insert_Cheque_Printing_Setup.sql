


---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Insert_Cheque_Printing_Setup] 
 @Company_ID		as numeric
,@Bank_ID	as numeric
,@Date_Top		as numeric(20,2)
,@Date_Left		as numeric(20,2)
,@Name_Top		as numeric(20,2)
,@Name_Left		as numeric(20,2)
,@Amount_Top	as numeric(20,2)
,@Amount_Left	as numeric(20,2)
,@AmtWords_Top	as numeric(20,2)
,@AmtWords_Left as numeric(20,2)
,@AmtWords_Top2 as numeric(20,2)
,@AmtWords_Left2 as numeric(20,2)
,@Cmp_Flag		as char(1)
,@Sing_Flag		as char(1)
,@Cmp_Top		as numeric(18,2)
,@Cmp_Left		as numeric(18,2)
,@Sing_Top		as numeric(18,2)
,@Sing_left		as numeric(18,2)
,@Cmp_Name		as varchar(120)
,@Payee_Flag	as	char(1)
,@Payee_Top		as numeric(18,2)
,@Payee_Left	as numeric(18,2)
,@AcNO_Flag		as char(1)
,@AcNo_Top		as numeric(18,2)
,@AcNo_Left		as numeric(18,2)
,@OverThan_Flag	as char(1)
,@OverThan_Top	as numeric(18,2)
,@OverThan_Left	as numeric(18,2)
,@Director_Flag	as char(1)
,@Director_Top	as numeric(18,2)
,@Director_Left	as numeric(18,2)
,@Director_Name	as varchar(100)
,@Bearer_Flag	as char(1)
,@Bearer_Top	as numeric(18,2)
,@Bearer_Left	as numeric(18,2)
,@User_ID as numeric --  180707
,@FormName as varchar(50) -- 230707
As
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
if exists (Select * from Cheque_Printing_Setup Where Company_ID = @Company_ID and Bank_ID= @Bank_ID) 
			begin
				Update Cheque_Printing_Setup
				set Date_Top=@Date_Top
					,Date_Left=@Date_Left
					,Name_Top=@Name_Top
					,Name_Left=@Name_Left 
                    ,Amount_Top=@Amount_Top
					,Amount_Left=@Amount_Left
					,AmtWords_Top=@AmtWords_Top
					,AmtWords_Left=@AmtWords_Left
					,AmtWords_Top2=@AmtWords_Top2
					,AmtWords_Left2=@AmtWords_Left2
					,Cmp_Flag=@Cmp_Flag
					,Sing_Flag=@Sing_Flag
					,Cmp_Top=@Cmp_Top
					,Cmp_Left=@Cmp_Left
					,Sing_Top=@Sing_Top
					,Sing_left=@Sing_left
					,Cmp_Name=@Cmp_Name
					,Payee_Flag=@Payee_Flag
					,Payee_Top=@Payee_Top
					,Payee_Left=@Payee_Left
					,AcNO_Flag=@AcNO_Flag
					,AcNo_Top=@AcNo_Top
					,AcNo_Left=@AcNo_Left
					,OverThan_Flag=@OverThan_Flag
					,OverThan_Top=@OverThan_Top
					,OverThan_Left=@OverThan_Left
					,Director_Flag=@Director_Flag
					,Director_Top=@Director_Top
					,Director_Left=@Director_Left
					,Director_Name=@Director_Name
					,Bearer_Flag=@Bearer_Flag
					,Bearer_Top=@Bearer_Top
					,Bearer_Left=@Bearer_Left
					,User_ID =@USer_ID
					where Company_ID=@Company_ID and Bank_ID=@Bank_ID
			end 
else
	begin
		insert into Cheque_Printing_Setup
		(Company_ID,Bank_ID,Date_Top,Date_Left,Name_Top,Name_Left,Amount_Top,Amount_Left,
		AmtWords_Top,AmtWords_Left,AmtWords_Top2,AmtWords_Left2,Cmp_Flag,Sing_Flag,Cmp_Top,Cmp_Left,
		Sing_Top,Sing_left,Cmp_Name
		,Payee_Flag,Payee_Top,Payee_Left,AcNO_Flag,AcNo_Top,AcNo_Left
		,OverThan_Flag,OverThan_Top,OverThan_Left,Director_Flag
		,Director_Top,Director_Left,Director_Name,Bearer_Flag,Bearer_Top,Bearer_Left,User_ID,FormName)	
		values
		(@Company_ID,@Bank_ID,@Date_Top,@Date_Left,@Name_Top,@Name_Left,@Amount_Top,@Amount_Left,
		@AmtWords_Top,@AmtWords_Left,@AmtWords_Top2,@AmtWords_Left2,@Cmp_Flag,@Sing_Flag,@Cmp_Top,@Cmp_Left,
		@Sing_Top,@Sing_left,@Cmp_Name
		,@Payee_Flag,@Payee_Top,@Payee_Left,@AcNO_Flag,@AcNo_Top,@AcNo_Left
		,@OverThan_Flag,@OverThan_Top,@OverThan_Left,@Director_Flag
		,@Director_Top,@Director_Left,@Director_Name,@Bearer_Flag,@Bearer_Top,@Bearer_Left,@User_ID,@FormName)	
	end

	RETURN



