
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0065_EMP_DEPENDANT_DETAIL_APP]
	 @Row_ID int output
	,@Emp_Tran_ID bigint
	,@Emp_Application_ID int
    ,@Cmp_ID int
    ,@Name varchar(100)
    ,@RelationShip varchar(20)
    ,@BirthDate datetime
    ,@D_Age numeric(18,1)
    ,@tran_type char(1)
    ,@Address varchar(1000)
    ,@Share numeric(18,2)
    ,@Is_Resi  numeric(1,0) -- Change by Falak on 01-OCT-2010 -- added new field
    ,@NomineeFor Varchar(30) = ''
    ,@Login_Id int=0 -- Rathod '18/04/2012'
    ,@Pan_Card_No Varchar(20) = ''  --Added By Jimit 13022018
    ,@Adhar_Card_No Varchar(20) = ''  --Added By Jimit 13022018
    ,@Approved_Emp_ID int
	,@Approved_Date datetime = Null
	,@Rpt_Level int 
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
				If exists(select Row_ID from T0065_EMP_DEPENDANT_DETAIL_APP WITH (NOLOCK)
				where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID And RelationShip=@RelationShip And BirthDate = @BirthDate And Name=@Name)
				BEgin 
					Set @Row_ID = 0
					return
				End
				select @Row_ID = Isnull(max(Row_ID),0) + 1 	From T0065_EMP_DEPENDANT_DETAIL_APP WITH (NOLOCK)
				
				INSERT INTO T0065_EMP_DEPENDANT_DETAIL_APP
				                      (Row_ID,Emp_Tran_ID,Emp_Application_ID, Cmp_ID, Name, RelationShip, BirthDate,D_Age,Address,Share,Is_Resi,NomineeFor,Pan_Card_No,Adhar_Card_No,Approved_Emp_ID,Approved_Date,Rpt_Level)
				VALUES (@Row_ID,@Emp_Tran_ID,@Emp_Application_ID,@Cmp_ID,@Name,@RelationShip,@BirthDate,@Age,@Address,@Share ,@Is_Resi,@NomineeFor,@Pan_Card_No,@Adhar_Card_No,@Approved_Emp_ID,@Approved_Date,@Rpt_Level)
				
				
						
		End
	Else if @Tran_Type = 'U'
		begin
				If exists(select Row_ID from T0065_EMP_DEPENDANT_DETAIL_APP WITH (NOLOCK)
				where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID 
				And RelationShip=@RelationShip And BirthDate = @BirthDate And Name=@Name And Row_ID <> @Row_ID)
				BEgin 
					Set @Row_ID = 0
					return
				End
		UPDATE    T0065_EMP_DEPENDANT_DETAIL_APP
		SET              Cmp_ID = @Cmp_ID, Name = @Name, RelationShip = @RelationShip, BirthDate = @BirthDate,D_Age=@Age,Address =@Address,Share = @Share ,Is_Resi =@Is_Resi,NomineeFor=@NomineeFor
				  ,Pan_Card_No = @Pan_Card_No,Adhar_Card_No = @Adhar_Card_No,
				  Approved_Emp_ID=@Approved_Emp_ID,
				  Approved_Date=@Approved_Date,
				  Rpt_Level=@Rpt_Level
		WHERE     (Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID) AND (Row_ID = @Row_ID)
		
		
				
		   end
	Else if @Tran_Type = 'D'
		begin
			
			DELETE FROM T0065_EMP_DEPENDANT_DETAIL_APP
			WHERE     (Row_ID = @Row_ID)
		end

	RETURN


