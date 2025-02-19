
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0065_EMP_CHILDRAN_DETAIL_APP]
	 @Row_ID int output
	,@Emp_Tran_ID bigint
	,@Emp_Application_ID int
    ,@Cmp_ID int
    ,@Name varchar(100)
    ,@Gender char(1)
    ,@Date_Of_Birth datetime
    ,@C_Age numeric(18,1)
    ,@RelationShip varchar(50)
    ,@Is_Resi  numeric(1,0)
    ,@Is_Dependant tinyint --Alpesh 06-Aug-2011
    ,@tran_type char(1)
    ,@Login_Id int=0 -- Rathod 18/04/2012	
    ,@Image_Path varchar(500) = NULL
    ,@Pan_Card_No Varchar(20) = ''  --Added By Jimit 13022018
    ,@Adhar_Card_No Varchar(20) = ''  --Added By Jimit 13022018
    ,@Approved_Emp_ID int
	,@Approved_Date datetime = Null
	,@Rpt_Level int 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

if @Date_Of_Birth = ''  
  SET @Date_Of_Birth  = NULL
  
  Declare @Age as numeric(18,2)
  set @Age = DateDiff(year,@Date_Of_Birth,getdate())
  
  
	If @tran_type  = 'I'
		Begin
			If exists(select Row_ID from T0065_EMP_CHILDRAN_DETAIL_APP WITH (NOLOCK) where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID And Name=@Name And Date_Of_Birth = @Date_Of_Birth And Gender=@Gender)
				BEgin 
					Set @Row_ID = 0
					return
				End
				select @Row_ID = Isnull(max(Row_ID),0) + 1 	From T0065_EMP_CHILDRAN_DETAIL_APP WITH (NOLOCK)
				
				insert into T0065_EMP_CHILDRAN_DETAIL_APP 
				(
				 Row_ID 
				,Emp_Tran_ID
				,Emp_Application_ID 
				,Cmp_ID 
				,Name 
				,Gender 
				,Date_Of_Birth
				,C_Age
				,Is_Resi
				,RelationShip
				,Is_Dependant --Alpesh 06-Aug-2011
				,Image_path
				,Pan_Card_No
				,Adhar_Card_No
				,Approved_Emp_ID
				,Approved_Date
				,Rpt_Level
				) values
				(
				 @Row_ID 
				,@Emp_Tran_ID
				,@Emp_Application_ID 
				,@Cmp_ID 
				,@Name 
				,@Gender
				,@Date_Of_Birth 
				,@Age
				,@Is_Resi
				,@RelationShip
				,@Is_Dependant--Alpesh 06-Aug-2011
				,@Image_Path
				,@Pan_Card_No
				,@Adhar_Card_No
				,@Approved_Emp_ID
				,@Approved_Date
				,@Rpt_Level
				)
				
			/*	insert into T0065_EMP_CHILDRAN_DETAIL_APP_Clone 
				(
				 Row_ID 
				,Emp_ID 
				,Cmp_ID 
				,Name 
				,Gender 
				,Date_Of_Birth
				,C_Age
				,Is_Resi
				,RelationShip
				,Is_Dependant 
				,System_Date
				,Login_Id
				,Image_path
				) values
				(
				 @Row_ID 
				,@Emp_ID 
				,@Cmp_ID 
				,@Name 
				,@Gender
				,@Date_Of_Birth 
				,@Age
				,@Is_Resi
				,@RelationShip
				,@Is_Dependant
				,GETDATE()
				,@Login_Id
				,@Image_Path
				)	*/			
								
		End
	Else if @Tran_Type = 'U'
		begin
				If exists(select Row_ID from T0065_EMP_CHILDRAN_DETAIL_APP WITH (NOLOCK)
				where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID 
				And Name=@Name And Date_Of_Birth = @Date_Of_Birth And Gender=@Gender And Row_ID <> @Row_ID)
				BEgin 
					Set @Row_ID = 0
					return
				End
			
		UPDATE    T0065_EMP_CHILDRAN_DETAIL_APP
		   SET              
				 Cmp_ID = @Cmp_ID
				,Name  = @Name
				,Gender = @Gender
				,Date_Of_Birth=@Date_Of_Birth
				,C_Age=@Age
				,Is_Resi = @Is_Resi
				,RelationShip=@RelationShip
				,Is_Dependant=@Is_Dependant
				,Image_path = @Image_Path
				,Pan_Card_No = @Pan_Card_No
				,Adhar_Card_No = @Adhar_Card_No
				
		   WHERE     (Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID) and Row_ID = @Row_ID
		   
		/*   insert into T0065_EMP_CHILDRAN_DETAIL_APP_Clone 
				(
				 Row_ID 
				,Emp_ID 
				,Cmp_ID 
				,Name 
				,Gender 
				,Date_Of_Birth
				,C_Age
				,Is_Resi
				,RelationShip
				,Is_Dependant 
				,System_Date
				,Login_Id
				,Image_path
				) values
				(
				 @Row_ID 
				,@Emp_ID 
				,@Cmp_ID 
				,@Name 
				,@Gender
				,@Date_Of_Birth 
				,@Age
				,@Is_Resi
				,@RelationShip
				,@Is_Dependant
				,GETDATE()
				,@Login_Id
				,@Image_Path
				)	
				*/	
		   end
	Else if @Tran_Type = 'D'
		begin
			DELETE FROM T0065_EMP_CHILDRAN_DETAIL_APP
			WHERE     (Emp_Tran_ID=@Emp_Tran_ID) and  Row_ID = @Row_ID				
		end

	RETURN


