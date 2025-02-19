

---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_HRMS_RESUME_BANK_aswini-25092023]
	 @Resume_Bank_Id	numeric(18, 0)	output
	,@Cmp_ID	numeric(18, 0)	
	,@Resume_ID	numeric(18, 0)	
	,@Bank_Id	varchar(20)	
	,@IFSC_Code	varchar(20)	
	,@Account_No	varchar(20)	
	,@Branch_Name varchar(100)	
	,@Tran_Type varchar(1)
	,@User_Id numeric(18,0) = 0
	,@IP_Address varchar(100)= ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	If @Tran_Type   = 'I'
		Begin
				If Exists(Select Resume_Bank_Id From T0090_HRMS_RESUME_BANK WITH (NOLOCK)  Where Cmp_ID = @Cmp_ID and Resume_Bank_Id = @Resume_Bank_Id)
				
					begin
						set @Resume_Bank_Id = 0
					Return 
				end
				
				select @Resume_Bank_Id= Isnull(max(Resume_Bank_Id),0) + 1 	From T0090_HRMS_RESUME_BANK WITH (NOLOCK)
				
				INSERT INTO T0090_HRMS_RESUME_BANK
				                      (Resume_Bank_Id
										,Cmp_ID
										,Resume_ID
										,Bank_Id
										,IFSC_Code
										,Account_No
										,Branch_Name
										)
				VALUES					(@Resume_Bank_Id
										,@Cmp_ID
										,@Resume_ID
										,@Bank_Id
										,@IFSC_Code
										,@Account_No
										,@Branch_Name)
		End
	Else if @Tran_Type  = 'U'
		begin
				If Exists(Select Resume_Bank_Id From T0090_HRMS_RESUME_BANK WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Resume_Bank_Id = @Resume_Bank_Id and Resume_ID = @Resume_ID)
				
					begin
						set @Resume_Bank_Id = 0
						Return 
					end

				Update T0090_HRMS_RESUME_BANK
				set 
					Bank_Id=@Bank_Id
					,IFSC_Code=@IFSC_Code
					,Account_No=@Account_No
					,Branch_Name=@Branch_Name
   				where Resume_Bank_Id = @Resume_Bank_Id
				
		end
	Else if @Tran_Type  = 'D'
		begin
				Delete From T0090_HRMS_RESUME_BANK Where Resume_Bank_Id = @Resume_Bank_Id
		end

RETURN




