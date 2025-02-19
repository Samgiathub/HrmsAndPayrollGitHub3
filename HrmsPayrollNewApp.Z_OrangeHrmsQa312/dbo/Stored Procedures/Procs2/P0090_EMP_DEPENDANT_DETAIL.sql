
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_EMP_DEPENDANT_DETAIL]
	 @Row_ID numeric(18,0) output
	,@Emp_ID numeric(18,0)
    ,@Cmp_ID numeric(18,0)
    ,@Name varchar(100)
    ,@RelationShip varchar(20)
    ,@BirthDate datetime
    ,@D_Age numeric(18,1)
    ,@tran_type char(1)
    ,@Address varchar(1000)
    ,@Share numeric(18,2)
    ,@Is_Resi  numeric(1,0) -- Change by Falak on 01-OCT-2010 -- added new field
    ,@NomineeFor Varchar(30) = ''
    ,@Login_Id numeric(18,0)=0 -- Rathod '18/04/2012'
    ,@Pan_Card_No Varchar(20) = ''  --Added By Jimit 13022018
    ,@Adhar_Card_No Varchar(20) = ''  --Added By Jimit 13022018	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

  IF @BIRTHDATE = '1900-01-01'  
	 SET @BIRTHDATE  = NULL					 
  
  DECLARE @AGE NUMERIC(18,2)
    
  --set @Age= datediff(year,@BirthDate,getdate())
  
  SELECT @AGE = DBO.F_GET_AGE(@BIRTHDATE,GETDATE(),'Y','')  --added by jimit 09012016
  
	If @tran_type  = 'I'
		Begin
				If exists(select Row_ID from T0090_EMP_DEPENDANT_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_ID And RelationShip=@RelationShip And BirthDate = @BirthDate And Name=@Name)
				BEgin 
					Set @Row_ID = 0
					return
				End
				select @Row_ID = Isnull(max(Row_ID),0) + 1 	From T0090_EMP_DEPENDANT_DETAIL WITH (NOLOCK)
				
				INSERT INTO T0090_EMP_DEPENDANT_DETAIL
				                      (Emp_ID, Row_ID, Cmp_ID, Name, RelationShip, BirthDate,D_Age,Address,Share,Is_Resi,NomineeFor,Pan_Card_No,Adhar_Card_No)
				VALUES (@Emp_ID,@Row_ID,@Cmp_ID,@Name,@RelationShip,@BirthDate,@Age,@Address,@Share ,@Is_Resi,@NomineeFor,@Pan_Card_No,@Adhar_Card_No)
				
				INSERT INTO T0090_EMP_DEPENDANT_DETAIL_Clone
				                      (Emp_ID, Row_ID, Cmp_ID, Name, RelationShip, BirthDate,D_Age,Address,Share,Is_Resi,NomineeFor,System_Date,Login_Id)
				VALUES (@Emp_ID,@Row_ID,@Cmp_ID,@Name,@RelationShip,@BirthDate,@Age,@Address,@Share ,@Is_Resi,@NomineeFor,GETDATE(),@Login_Id)
						
								
		End
	Else if @Tran_Type = 'U'
		begin
				If exists(select Row_ID from T0090_EMP_DEPENDANT_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_ID And RelationShip=@RelationShip And BirthDate = @BirthDate And Name=@Name And Row_ID <> @Row_ID)
				BEgin 
					Set @Row_ID = 0
					return
				End
		UPDATE    T0090_EMP_DEPENDANT_DETAIL
		SET              Cmp_ID = @Cmp_ID, Name = @Name, RelationShip = @RelationShip, BirthDate = @BirthDate,D_Age=@Age,
					Address =@Address,Share = @Share ,Is_Resi =@Is_Resi,NomineeFor=@NomineeFor
				  ,Pan_Card_No = @Pan_Card_No,Adhar_Card_No = @Adhar_Card_No
		WHERE     (Emp_ID = @Emp_ID) AND (Row_ID = @Row_ID)
		
		INSERT INTO T0090_EMP_DEPENDANT_DETAIL_Clone
				(Emp_ID, Row_ID, Cmp_ID, Name, RelationShip, BirthDate,D_Age,Address,Share,Is_Resi,NomineeFor,System_Date,Login_Id)
		VALUES (@Emp_ID,@Row_ID,@Cmp_ID,@Name,@RelationShip,@BirthDate,@Age,@Address,@Share ,@Is_Resi,@NomineeFor,GETDATE(),@Login_Id)
				
		   end
	Else if @Tran_Type = 'D'
		begin
			
			DELETE FROM T0090_EMP_DEPENDANT_DETAIL
			WHERE     (Row_ID = @Row_ID)
		end

	RETURN




