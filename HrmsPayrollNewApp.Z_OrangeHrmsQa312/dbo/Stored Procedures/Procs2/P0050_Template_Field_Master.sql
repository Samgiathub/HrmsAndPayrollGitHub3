
CREATE PROCEDURE [dbo].[P0050_Template_Field_Master]
	   @F_Id		int Output
	  ,@Cmp_Id					int
	  ,@T_Id				int
	  ,@Field_Name			nvarchar(500)
	  ,@Field_Type				Nvarchar(50)
	  ,@Option			Nvarchar(800)
	  ,@Sorting_No				int
	  ,@tran_type		 varchar(1) 
	  ,@User_Id		 numeric(18,0) = 0
	  ,@Is_Required	tinyint=1
	  ,@Is_Enable tinyint=1
	  ,@Is_Numeric tinyint=1
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	if @Option <> ''
		Begin
			IF Right(@Option,1) = '#'
			  Begin
				Set @Option = LEFT(@Option, LEN(@Option) - 1)
			  End
		End

	If Upper(@tran_type) ='I'
		BEGIN

			If Exists(select 1 From T0050_Template_Field_Master WITH (NOLOCK) Where cmp_ID = @cmp_id and Field_Name =@Field_Name and T_ID=@T_Id)
				Begin
						set @F_Id = 0
					RAISERROR ('This field already exists', 16, 2)
					Return 
				end

			select @F_Id = isnull(max(F_ID),0) + 1 from T0050_Template_Field_Master WITH (NOLOCK)

			Insert Into T0050_Template_Field_Master
			(
				F_Id
			   ,Cmp_Id
			   ,T_Id
			   ,Field_Name
			   ,Field_Type
			   ,Options
			   ,Sorting_No
			   ,Is_Required
			   ,Is_Enable
			   ,Is_Numeric
			)
			Values
			(
				 @F_Id
				,@Cmp_Id
				,@T_Id
				,@Field_Name
				,@Field_Type
				,@Option
				,@Sorting_No
				,@Is_Required
				,@Is_Enable
				,@Is_Numeric
			)	
				
		END
	Else If  Upper(@tran_type) ='U' 
		Begin
			
			If Exists(select 1 From T0050_Template_Field_Master WITH (NOLOCK)  Where cmp_ID = @cmp_id and @F_Id<>@F_Id and Sorting_No =@Sorting_No and T_Id=@T_Id)
					Begin
						set @F_Id = 0
						RAISERROR ('This sorting number is allocated', 16, 2)
						Return 
					end
				If Exists(select 1 From T0050_Template_Field_Master WITH (NOLOCK)  Where cmp_ID = @cmp_id and @F_Id<>@F_Id and Field_Name =@Field_Name and T_Id=@T_Id)
					Begin
							set @F_Id = 0
						RAISERROR ('This field already exists', 16, 2)
						Return 
					end
			
				UPDATE    T0050_Template_Field_Master
				SET        Field_Name		=	@Field_Name
						  ,Field_Type			=	@Field_Type
						  ,Sorting_No			=	@Sorting_No
						  ,Options		=	@Option
						  ,Is_Required         =   @Is_Required	
						  ,Is_Enable = @Is_Enable
						  ,Is_Numeric = @Is_Numeric
				WHERE F_ID = @F_Id and cmp_Id=@Cmp_ID
			
			End	
	Else If  Upper(@tran_type) ='D'
		Begin
			Delete from  T0050_Template_Field_Master where F_ID = @F_Id
		End

END
