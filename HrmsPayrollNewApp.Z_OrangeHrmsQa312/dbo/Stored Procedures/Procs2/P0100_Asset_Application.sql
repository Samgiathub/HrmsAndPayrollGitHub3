


---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_Asset_Application]
	@Asset_Application_ID numeric OUTPUT
	,@Cmp_ID numeric
	,@Emp_ID numeric
	,@Branch_ID numeric
	,@Application_date datetime
	,@Asset varchar(50)
	,@Remarks varchar(50)
	,@LoginId numeric
	,@Tran_type	CHAR(1)
	,@IP_Address varchar(30)= ''
	,@appltype numeric
	,@AssetM_Id varchar(50)
	,@Dept_ID numeric
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @OldValue as  varchar(max)
declare @OldEmp_ID numeric
declare @OldBranch_ID numeric
declare @OldApplication_date datetime
declare @OldAsset varchar(50)
declare @OldRemarks varchar(50)
declare @oldApplication_Status varchar(5)
declare @Application_code as varchar(50)


IF @Tran_type = 'I'
	BEGIN
		select @Asset_Application_ID = isnull(max(Asset_Application_ID),0) + 1  from T0100_Asset_Application WITH (NOLOCK)	
		 set @Application_Code = cast(@Asset_Application_ID as Varchar(20))  
		 --if exists(select * from T0100_Asset_Application where cmp_id=@cmp_id and Application_date=@Application_date and AssetM_Id=@AssetM_Id)
			--begin 
			--	return
			--end
		insert into T0100_Asset_Application (Asset_Application_ID,Cmp_ID,Emp_ID,Branch_ID,Application_date,Application_code,Asset_ID,Remarks,LoginId,System_date,application_status,application_Type,AssetM_Id,Dept_ID)
		Values(@Asset_Application_ID,@Cmp_ID,@Emp_ID,@Branch_ID,@Application_date,@Application_code,@Asset,@Remarks,@LoginId,GETDATE(),'P',@appltype,@AssetM_Id,@Dept_ID)
		
			--set @OldValue =	'New Value' + '#'+ 'Emp ID :' +ISNULL( @Emp_ID,0) 
			--+ '#' + 'Branch ID :' + ISNULL( @Branch_ID,0)
			--+ '#' + 'Application Date :' + ISNULL( @Application_date,'')
			--+ '#' + 'Asset :' + ISNULL( @Asset,'')
			--+ '#' + 'Remarks :' + ISNULL( @Remarks,'')
			--+ '#' + 'Application code :' + ISNULL( @Application_code,'') 
			--+ '#' + 'Application Status :' + ('P') + '#' 		
			set @OldValue =	'New Value' + '#'+ 'Emp ID :' + CONVERT(nvarchar(20),ISNULL(@Emp_ID,0))
			+ '#' + 'Branch ID :' + CONVERT(nvarchar(20),ISNULL(@Branch_ID,0))
			+ '#' + 'Application Date :' + CONVERT(nvarchar(20),@Application_date)
			+ '#' + 'Asset :' + CONVERT(nvarchar(20),ISNULL(@Asset,0))
			+ '#' + 'Remarks :' + @Remarks
			+ '#' + 'Application code :' +@Application_code
			+ '#' + 'Application Status :' + ('P') + '#' 		
			
	END		
else if @Tran_type = 'U'
	Begin 
		select @OldEmp_ID  =ISNULL(Emp_ID,0) ,@OldBranch_ID  =ISNULL(Branch_ID,0),@OldApplication_date  =ISNULL(Application_date,''),@OldAsset  =ISNULL(Asset_ID,''),@oldApplication_Status  =ISNULL(Application_status,'') From dbo.T0100_Asset_Application WITH (NOLOCK) Where Asset_Application_ID = @Asset_Application_ID And Cmp_ID = @Cmp_Id
		select @Application_Code = Application_code from T0100_Asset_Application WITH (NOLOCK) where Asset_Application_ID = @Asset_Application_ID And Cmp_ID = @Cmp_Id
		    update T0100_Asset_Application 
			set 
			Cmp_ID=@Cmp_ID,
			Emp_ID=@Emp_ID,
			Branch_ID=@Branch_ID,
			Application_date=@Application_date,
			Application_code=@Application_code,
			Asset_ID=@Asset,
			Remarks=@Remarks,
			LoginId=@LoginId,
			System_date=GETDATE(),
			application_Type=@appltype,
			AssetM_Id=@AssetM_Id,
			Dept_ID=@Dept_ID
			where Asset_Application_ID = @Asset_Application_ID And Cmp_ID = @Cmp_Id
			
		delete from T0110_Asset_Application_Details where Asset_Application_ID = @Asset_Application_ID And Cmp_ID = @Cmp_Id
			
			 set @OldValue = 'old Value' + '#'+ 'Emp ID :' + CONVERT(nvarchar(20),ISNULL( @OldEmp_ID,0)) 
			+ '#' + 'Branch ID :' +CONVERT(nvarchar(20), ISNULL( @OldBranch_ID,0))
			+ '#' + 'Application Date :' + CONVERT(nvarchar(20),ISNULL( @OldApplication_date,''))
			+ '#' + 'Asset :' +CONVERT(nvarchar(20), ISNULL( @OldAsset,''))
			+ '#' + 'Remarks :' + CONVERT(nvarchar(20),ISNULL( @OldRemarks,''))
			+ '#' + 'Application Status :' + CONVERT(nvarchar(20),ISNULL( @oldApplication_Status,''))
            + 'New Value' + '#'+ 'Emp ID :' +CONVERT(nvarchar(20),ISNULL( @Emp_ID,0))
			+ '#' + 'Branch ID :' + CONVERT(nvarchar(20),ISNULL(@Branch_ID,0))
			+ '#' + 'Application Date :' + CONVERT(nvarchar(20),@Application_date)
			+ '#' + 'Asset :' + CONVERT(nvarchar(20),ISNULL(@Asset,0))
			+ '#' + 'Remarks :' +CONVERT(nvarchar(20), @Remarks)
			--+ '#' + 'Application code :' +@Application_code
			
                           

	End
Else if @Tran_Type = 'D' 			
	Begin
	select @OldEmp_ID  =ISNULL(Emp_ID,0) ,@OldBranch_ID  =ISNULL(Branch_ID,0),@OldApplication_date  =ISNULL(Application_date,''),@OldAsset  =ISNULL(Asset_ID,''),@oldApplication_Status  =ISNULL(Application_status,'') From dbo.T0100_Asset_Application WITH (NOLOCK) Where Asset_Application_ID = @Asset_Application_ID And Cmp_ID = @Cmp_Id
	 --select @OldBrand_Name  = Brand_Name ,@OldBrand_Desc  = Brand_Desc From dbo.t0040_Brand_Master Where Cmp_ID = @Cmp_ID and Brand_ID = @Brand_ID
			
			Delete from T0110_Asset_Application_Details where Asset_Application_ID = @Asset_Application_ID
			Delete from T0100_Asset_Application where Asset_Application_ID = @Asset_Application_ID
			
			
			 set @OldValue = 'old Value' + '#'+ 'Emp ID :' +CONVERT(nvarchar(20),ISNULL( @OldEmp_ID,0)) 
			+ '#' + 'Branch ID :' +CONVERT(nvarchar(20), ISNULL( @OldBranch_ID,0))
			+ '#' + 'Application Date :' + CONVERT(nvarchar(20),ISNULL( @OldApplication_date,''))
			+ '#' + 'Asset :' +CONVERT(nvarchar(20), ISNULL( @OldAsset,''))
			+ '#' + 'Remarks :' + ISNULL( @OldRemarks,'')
			+ '#' + 'Application Status :' + ISNULL( @oldApplication_Status,'')	
			
	End			
	exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Asset Application',@OldValue,@Asset_Application_ID,@LoginId,@IP_Address

RETURN




