
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0065_EMP_LICENSE_DETAIL_APP] 
		 @Row_ID int output
		,@Emp_Tran_ID bigint
		,@Emp_Application_ID int
		,@Cmp_ID int
		,@Lic_ID int 
		,@Lic_St_Date datetime
		,@Lic_End_Date datetime
		,@Lic_Comments varchar(250) 
		,@Lic_For varchar(50)  = ''		
		,@Lic_number varchar(20) = ''	
		,@Is_Expired tinyint = 0		
		,@tran_type varchar(1)
		,@Approved_Emp_ID int
		,@Approved_Date datetime = Null
	    ,@Rpt_Level int 
 AS
 SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		if @Lic_ID= 0 
			set @Lic_ID = null
		if @tran_type ='I' 
			begin
				
				select @Row_ID = isnull(max(Row_ID),0) +1   from T0065_EMP_LICENSE_DETAIL_APP WITH (NOLOCK)
								
				INSERT INTO T0065_EMP_LICENSE_DETAIL_APP
				                      (Row_ID,Emp_Tran_ID,Emp_Application_ID,Cmp_ID, Lic_ID, Lic_St_Date, Lic_End_Date, Lic_Comments,Lic_For,Lic_number,Is_Expired,Approved_Emp_ID,Approved_Date,Rpt_Level)
				VALUES     (@Row_ID,@Emp_Tran_ID,@Emp_Application_ID,@Cmp_ID,@Lic_ID,@Lic_St_Date,@Lic_End_Date,@Lic_Comments,@Lic_For,@Lic_number,@Is_Expired,@Approved_Emp_ID,@Approved_Date,@Rpt_Level)
							
				end 
	Else If @tran_type ='U' 
				begin
					UPDATE    T0065_EMP_LICENSE_DETAIL_APP
					SET              Cmp_ID = @Cmp_ID, Lic_ID = @Lic_ID, Lic_St_Date = @Lic_St_Date, Lic_End_Date = @Lic_End_Date, Lic_Comments = @Lic_Comments,Lic_For = @Lic_For,lic_number = @Lic_number,is_expired = @Is_Expired,
									 Approved_Emp_ID=@Approved_Emp_ID,Approved_Date=@Approved_Date,Rpt_Level=@Rpt_Level
				    where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID and Row_ID = @Row_ID
				end
	Else If @tran_type ='D'
					delete  from T0065_EMP_LICENSE_DETAIL_APP where Row_ID = @Row_ID
	RETURN


