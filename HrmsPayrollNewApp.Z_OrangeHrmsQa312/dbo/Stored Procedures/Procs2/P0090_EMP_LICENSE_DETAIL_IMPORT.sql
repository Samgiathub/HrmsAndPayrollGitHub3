

---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_EMP_LICENSE_DETAIL_IMPORT] 
		 @Row_ID numeric output
	    ,@Cmp_ID numeric
		,@Alpha_Emp_Code varchar(100)
	    --,@Emp_Name	varchar(50)
		,@Lic_Name varchar(50) 
		,@Lic_St_Date datetime
		,@Lic_End_Date datetime
		,@Lic_Comments varchar(250) 
		,@Lic_For varchar(50)  = ''		
		,@Lic_number varchar(20) = ''	
		,@Is_Expired tinyint = 0	
		,@tran_type varchar(1)
		,@GUID Varchar(2000) = '' --Added By nilesh Patel on  16062016
 AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 
DECLARE @Emp_id numeric
Declare @License_ID numeric
Declare @License_ID1 numeric

Set @Emp_id = 0
select @Emp_id = isnull(emp_id,0)  from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Alpha_Emp_Code  and Cmp_ID = @cmp_id
	
  if Isnull(@Emp_id,0) = 0
	Begin
		INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code ,'Employee Doesn''t exists',@Alpha_Emp_Code,'Enter proper Employee Code',GetDate(),'License Detail',@GUID)			
		RETURN
	End
	
  if Isnull(@Lic_Name,'') = ''
	Begin
		INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code ,'License Name Doesn''t exists',@Alpha_Emp_Code,'Enter proper Employee License Name',GetDate(),'License Detail',@GUID)			
		RETURN
	End
	
 if @Lic_St_Date Is null
	Begin
		INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code ,'License Issue Date Doesn''t exists',@Alpha_Emp_Code,'Enter proper Employee License Issue Date',GetDate(),'License Detail',@GUID)			
		RETURN
	End

  if exists(select  Lic_ID from T0040_LICENSE_MASTER WITH (NOLOCK) where Lic_Name=@Lic_Name and Cmp_ID=@Cmp_ID)
			begin 
				select @License_ID1 = Lic_ID from T0040_LICENSE_MASTER WITH (NOLOCK) where Lic_Name=@Lic_Name and Cmp_ID=@Cmp_ID
			end
		else
			begin 
				select @License_ID1 = isnull(max(Lic_ID),0) + 1  from T0040_LICENSE_MASTER	WITH (NOLOCK)
				insert into T0040_LICENSE_MASTER (Lic_ID,Cmp_ID,Lic_Name,Lic_Comments)Values(@License_ID1,@Cmp_ID,@Lic_Name,'')
				select  @License_ID1 = Lic_ID   from T0040_LICENSE_MASTER WITH (NOLOCK) where Lic_Name = @Lic_Name  and Cmp_ID = @cmp_id
			end
			
		if @tran_type ='I' 
		if exists(select * from T0090_EMP_LICENSE_DETAIL WITH (NOLOCK) where Lic_Number=@Lic_number and Emp_ID=@Emp_id and LIC_ID=@License_ID1 and Lic_St_Date=@Lic_St_Date)
			begin
				UPDATE    T0090_EMP_LICENSE_DETAIL
					SET              Cmp_ID = @Cmp_ID, Lic_ID = @License_ID1, Lic_St_Date = @Lic_St_Date, Lic_End_Date = @Lic_End_Date, Lic_Comments = @Lic_Comments,Lic_For = @Lic_For,lic_number = @Lic_number,is_expired = @Is_Expired -- Added By Gadriwala 07022014
				    where  Lic_Number=@Lic_number and Emp_ID=@Emp_id and LIC_ID=@License_ID1 and Lic_St_Date=@Lic_St_Date
			end		
		else
			begin
			
				select @Row_ID = isnull(max(Row_ID),0) +1   from T0090_EMP_LICENSE_DETAIL WITH (NOLOCK)
								
				INSERT INTO T0090_EMP_LICENSE_DETAIL
				                      (Row_ID,Emp_ID, Cmp_ID, Lic_ID, Lic_St_Date, Lic_End_Date, Lic_Comments,Lic_For,Lic_number,Is_Expired)
				VALUES     (@Row_ID,@Emp_id,@Cmp_ID,@License_ID1,@Lic_St_Date,@Lic_End_Date,@Lic_Comments,@Lic_For,@Lic_number,@Is_Expired)	
							
			end 
	RETURN




