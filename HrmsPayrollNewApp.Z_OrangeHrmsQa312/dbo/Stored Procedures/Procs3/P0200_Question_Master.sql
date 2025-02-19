




-- =============================================
-- Author:		Sneha
-- ALTER date: 25/02/2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0200_Question_Master]
    @Question_Id as numeric(18,0),
	@Cmp_Id as numeric(18,0),
	@Question as varchar(150),
	@Description as Varchar(100),
	@Is_Active as tinyint,
	@tran_type char(1)   
	,@User_Id numeric(18,0) = 0
    ,@IP_Address varchar(30)= '' --Add By Paras 12-10-2012
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

declare @OldValue as  varchar(max)
declare @OldQuestion as varchar(150)
declare @OldDescription as varchar(100)
declare @OldIsActive as varchar(1)

  set @OldValue = ''
  set @OldQuestion = ''
  set @OldDescription = ''
  set @OldIsActive = ''
  

BEGIN
	
		
	IF @Cmp_Id <> 0
		Begin
			 IF UPPER(@tran_type) = 'I'
				Begin
					If Exists(Select Question from T0200_Question_Master WITH (NOLOCK) where Cmp_Id = @Cmp_Id and Question = @Question)
						Begin
							RAISERROR ('This question already exists', 16, 2) 
							Select @@Error
						End
					Else
						Begin
							SELECT @Question_Id = ISNULL(MAX(question_id),0) +1 FROM T0200_Question_Master WITH (NOLOCK)
							
							 INSERT INTO T0200_Question_Master
							 (
								Question_Id,
								Cmp_Id,
								Question,
								Description,
								Is_Active
							 )VALUES
							(
								@Question_Id,
								@Cmp_Id,
								@Question,
								@Description,
								@Is_Active
							)
							
							set @OldValue = 'New Value' + '#'+ 'Question :' +ISNULL( @Question,'') + '#' + 'Discription :' + ISNULL( @Description,'') + '#' + 'Is Active :' + CAST(ISNULL(@Is_Active,0) AS VARCHAR(1)) + '#' 

						End
				End
			 Else IF UPPER(@tran_type) = 'U'
				--If Exists(Select Question from T0200_Question_Master where Cmp_Id = @Cmp_Id and Question = @Question)
				--	Begin
				--		RAISERROR ('This question already exists', 16, 2) 
				--		Select @@Error
				--	End
				--Else -commented by sneha on 31/10/2012 
					Begin
					select @OldQuestion  =ISNULL(Question,'') ,@OldDescription  =ISNULL(Description,''),@OldIsActive  =isnull(Is_Active,0)  From dbo.T0200_Question_Master WITH (NOLOCK) Where Cmp_Id = @Cmp_Id and Question_Id = @Question_Id
					
						Update T0200_Question_Master
						Set
						Question_Id = @Question_Id, 
						Question = @Question,
						Description = @Description,
						Is_Active = @Is_Active,
						Cmp_Id = @Cmp_Id
						where Cmp_Id= @Cmp_Id and Question_Id = @Question_Id
						
						    set @OldValue = 'old Value' + '#'+ 'Question :' + @OldQuestion  + '#' + 'Description :' + @OldDescription  + '#' + 'Is Active :' + @OldIsActive + '#' + 
                                          + 'New Value' + '#'+ 'Question :' +ISNULL( @Question,'') + '#' + 'Description :' + ISNULL( @Description,'') + '#' + 'Is Active:' + CAST(ISNULL(@Is_Active,0) AS VARCHAR(1)) + '#'
					End
					
					
		End	
		exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Question Master',@OldValue,@Question_Id,@User_Id,@IP_Address
END




