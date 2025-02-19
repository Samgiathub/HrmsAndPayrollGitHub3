
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_EMP_QUALIFICATION_DETAIL_IMPORT]	
	  @Row_ID numeric(18) output
	 ,@Cmp_ID numeric(18,0)
	 ,@Alpha_Emp_Code varchar(100)	
     ,@Qual_Name varchar(100)
     ,@Specialization varchar(100)
     ,@Year numeric(18,0)
     ,@Score varchar(20)
     ,@St_Date datetime
     ,@End_Date datetime
     ,@Comments  varchar(250)	    
	 ,@tran_type varchar(1)	 
	 ,@GUID		Varchar(2000) = '' --Added by Nilesh Patel on 17062016
 AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 

DECLARE @Emp_id numeric
DECLARE @Qual_ID numeric 
Set @Qual_ID = 0

select @Emp_id= emp_id  from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Alpha_Emp_Code  and Cmp_ID = @cmp_id
--select @Qual_ID=Qual_ID from T0040_QUALIFICATION_MASTER where upper(Qual_Name)=upper(@Qual_Name) and Cmp_ID=@Cmp_ID  

if Isnull(@Emp_id,0) = 0 
	Begin
		
		INSERT INTO dbo.T0080_Import_Log VALUES (@Qual_ID,@Cmp_Id,@Alpha_Emp_Code,'Employee Code Doest not Exists.Enter valid details',@Qual_Name,'Employee Code Doest not Exists.Enter valid details',GETDATE(),'QUALIFICATION Master',@GUID)  
		Return
	End



IF EXISTS(SELECT Qual_ID FROM T0040_QUALIFICATION_MASTER WITH (NOLOCK) WHERE upper(Qual_Name)=upper(@Qual_Name) AND Cmp_ID=@Cmp_ID)  
	BEGIN  
		select @Qual_ID=Qual_ID from T0040_QUALIFICATION_MASTER WITH (NOLOCK) where upper(Qual_Name)=upper(@Qual_Name) and Cmp_ID=@Cmp_ID  
	END  
ELSE  
	BEGIN    
		IF @Qual_Name <> ''
			BEGIN  
				EXEC P0040_QUALIFICATION_MASTER @Qual_ID OUTPUT,@Cmp_ID,@Qual_Name,'I',0,'',''  
			END  
		ELSE  
			BEGIN  
				INSERT INTO dbo.T0080_Import_Log VALUES (@Qual_ID,@Cmp_Id,@Alpha_Emp_Code,'Qualification Name is not Exist.Enter valid details',@Qual_Name,'Qualification Name is not Exist.Enter valid details',GETDATE(),'QUALIFICATION Master',@GUID)  
				Return
			END    
	END

if @St_Date = ''  
  SET @St_Date  = NULL
if @End_Date = ''  
  SET @End_Date  = NULL
if @Year = 0
	set @Year=NULL  
IF @Specialization = ''
	Set @Specialization = NULL	
if @Score = ''
	Set @Score = NULL	
If @Comments = ''
	Set @Comments = NULL


	--Added By Jimit 14032019
	If @St_Date > getdate() AND @St_Date IS NOT NULL
		BEGIN
			INSERT INTO dbo.T0080_Import_Log VALUES (@Qual_ID,@Cmp_Id,@Alpha_Emp_Code,'Fuuter Date is not allow as Qualification Start date.',@Qual_Name,'Enter Valid Qualification Start date.',GETDATE(),'QUALIFICATION Master',@GUID)  
		Return
		END
--Ended

--Commented by Mukti(17082017)start	
--if @Specialization is null
--	Begin
--		INSERT INTO dbo.T0080_Import_Log VALUES (@Qual_ID,@Cmp_Id,@Alpha_Emp_Code,'Qualification Specialization Details does not Exist.Enter valid details',@Qual_Name,'Qualification Specialization Details does not Exist.Enter valid details',GETDATE(),'QUALIFICATION Master',@GUID)  
--		Return
--	End
	
--IF @St_Date is null
--	Begin
--		INSERT INTO dbo.T0080_Import_Log VALUES (@Qual_ID,@Cmp_Id,@Alpha_Emp_Code,'Qualification Start Date does not Exist.Enter valid details',@Qual_Name,'Qualification Start Date does not Exist.Enter valid details',GETDATE(),'QUALIFICATION Master',@GUID)  
--		Return
--	End
	
--IF @End_Date is null
--	Begin
--		INSERT INTO dbo.T0080_Import_Log VALUES (@Qual_ID,@Cmp_Id,@Alpha_Emp_Code,'Qualification End Date does not Exist.Enter valid details',@Qual_Name,'Qualification End Date does not Exist.Enter valid details',GETDATE(),'QUALIFICATION Master',@GUID)  
--		Return
--	End
	
--IF @Year is null
--	Begin
--		INSERT INTO dbo.T0080_Import_Log VALUES (@Qual_ID,@Cmp_Id,@Alpha_Emp_Code,'Qualification Year Details does not Exist.Enter valid details',@Qual_Name,'Qualification Year Details does not Exist.Enter valid details',GETDATE(),'QUALIFICATION Master',@GUID)  
--		Return
--	End
	
--if @Score is null
--	Begin
--		INSERT INTO dbo.T0080_Import_Log VALUES (@Qual_ID,@Cmp_Id,@Alpha_Emp_Code,'Qualification Score Details does not Exist.Enter valid details',@Qual_Name,'Qualification Score Details does not Exist.Enter valid details',GETDATE(),'QUALIFICATION Master',@GUID)  
--		Return
--	End
	
--if @Comments is null
--	Begin
--		INSERT INTO dbo.T0080_Import_Log VALUES (@Qual_ID,@Cmp_Id,@Alpha_Emp_Code,'Comments Details does not Exist.Enter valid details',@Qual_Name,'Comments Details does not Exist.Enter valid details',GETDATE(),'QUALIFICATION Master',@GUID)  
--		Return
--	End
--Commented by Mukti(17082017)end

If @tran_type ='I'		
		Begin
			If Exists(select  Row_ID from T0090_EMP_QUALIFICATION_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID and Qual_ID = @Qual_ID and Specialization = @Specialization and T0090_EMP_QUALIFICATION_DETAIL.Year = @Year and Score = @Score and St_Date = @St_Date and End_Date = @End_Date and  Comments = @Comments)
					Begin 
						set @Row_ID = 0
						Return
					End
							
				select @Row_ID = isnull(max(Row_ID),0)+1 from T0090_EMP_QUALIFICATION_DETAIL WITH (NOLOCK)
			
				INSERT INTO T0090_EMP_QUALIFICATION_DETAIL
						 (Emp_ID,Row_ID,Cmp_ID,Qual_ID, Specialization, Year, Score, St_Date, End_Date, Comments)
				VALUES     (@Emp_ID,@row_id,@Cmp_ID,@Qual_ID,@Specialization,@Year,@Score,@St_Date,@End_Date,@Comments)
		End
		
RETURN




