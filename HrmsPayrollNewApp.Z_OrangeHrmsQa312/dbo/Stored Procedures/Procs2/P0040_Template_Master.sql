

CREATE PROCEDURE [dbo].[P0040_Template_Master]
	   @T_ID			int Output
      ,@Cmp_ID				numeric(18,0)
      ,@Template_Title		Nvarchar(100)
      ,@Template_Instruction	nvarchar(500)
      ,@tran_type		 varchar(1) 
	  ,@User_Id		 int = 0
	  ,@Branch_ID			int =0
      ,@Template_EmpId		varchar(max)='' 
	  ,@Is_Active int
	  ,@IP_Address	 varchar(30)= ''
	  ,@Desig_ID varchar(max)=''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	if @Branch_ID = 0
		set @Branch_ID= null
	if @Template_EmpId  = ''
		set @Template_EmpId = null
If Upper(@tran_type) ='I'
	Begin
	
		If Exists (Select T_ID  from T0040_Template_Master WITH (NOLOCK) Where Cmp_Id=@Cmp_Id and 
		Template_Title = @Template_Title)
		begin
			set @T_ID = 0
			return
		end

		select @T_ID = isnull(max(T_ID),0) + 1 from T0040_Template_Master  WITH (NOLOCK)
		Insert Into T0040_Template_Master
		(
			   T_ID
			  ,Cmp_ID
			  ,Template_Title
			  ,Template_Instruction
			  ,Branch_ID
			  ,EmpId
			  ,Createdby
			  ,CreatedDate
			  ,Is_Active
			  ,Desig_ID
			  
		)
		Values
		(
			   @T_ID
			  ,@Cmp_ID
			  ,@Template_Title
			  ,@Template_Instruction
			  ,@Branch_ID
			  ,@Template_EmpId
			  ,@User_Id
			  ,getdate()
			  ,@Is_Active
			  ,@Desig_ID
		)
		
	End
Else If  Upper(@tran_type) ='U' 
	Begin
	select 123
			UPDATE    T0040_Template_Master
			SET     
					   Template_Title		=   @Template_Title
					  ,Template_Instruction	=	@Template_Instruction	
					  ,Branch_ID			=	@Branch_ID
					  ,EmpId				=	@Template_EmpId	
					  ,Updateby				=	@User_Id
					  ,UpdateDate			=	GETDATE()
					  ,Is_Active = @Is_Active
					  ,Desig_ID				=	@Desig_ID
			WHERE T_ID = @T_ID and cmp_Id=@Cmp_ID			

		
	End
Else If  Upper(@tran_type) ='D'
	Begin	
		If Exists (Select T_ID  from T0100_Employee_Template_Response WITH (NOLOCK) Where Cmp_Id=@Cmp_Id and 
		T_Id = @T_ID)
		begin
			set @T_ID = 0
			return
		end
		Delete from T0100_Employee_Template_Response where T_ID = @T_ID
		Delete from T0050_Template_Field_Master where T_ID = @T_ID
		Delete from  T0040_Template_Master where T_ID = @T_ID
		Delete from  T0010_Email_Format_Setting where T_ID = @T_ID and Cmp_ID = @Cmp_ID
	End
	exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Template','',@T_ID,@User_Id,@IP_Address
END

