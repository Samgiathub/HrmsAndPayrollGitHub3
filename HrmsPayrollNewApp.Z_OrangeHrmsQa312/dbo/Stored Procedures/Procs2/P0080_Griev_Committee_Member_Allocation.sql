
CREATE PROCEDURE [dbo].[P0080_Griev_Committee_Member_Allocation]  
    @GrieId  numeric(9) output  
   ,@Cmp_ID   numeric(9)  
   ,@GCom_EmpID numeric(9) 
   ,@tran_type  varchar(1) 
   ,@MemberType numeric(9)
   
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
  --Created by Ronak Kumawat 24022022


 If @tran_type  = 'I'  
  Begin  
  if exists (Select GCMID  from T0080_Griev_Committee_Member_Allocation WITH (NOLOCK) Where GCMEmpID=@GCom_EmpID and MemberType=@MemberType and Cmp_ID=@Cmp_ID  )   
    begin  
     set @GrieId = 0  
     Return  
    end  


    select @GrieId = Isnull(max(GCMID),0) + 1  From T0080_Griev_Committee_Member_Allocation  WITH (NOLOCK) 
    INSERT INTO T0080_Griev_Committee_Member_Allocation (GCMID,GCMEmpID,Cmp_ID,MemberType)  
             VALUES(@GrieId,@GCom_EmpID,@Cmp_ID,@MemberType)


  End  
 Else if @Tran_Type = 'U'  
  begin  
   IF Not Exists(Select GCMID  from T0080_Griev_Committee_Member_Allocation WITH (NOLOCK) Where GCMID = @GrieId)  
    Begin  
     set @GrieId = 0  
     Return   
    End  

	

			Declare @IsActive int 
			select @IsActive=Is_Active from T0080_Griev_Committee_Member_Allocation where GCMID = @GrieId


			if @IsActive = 0 
			begin
			 

				 UPDATE T0080_Griev_Committee_Member_Allocation  
				 SET Is_Active = 1
				 where GCMID = @GrieId and Cmp_ID=@Cmp_ID

			end
			else if @IsActive = 1
			begin
		
					UPDATE T0080_Griev_Committee_Member_Allocation  
					SET Is_Active = 0
					where GCMID = @GrieId and Cmp_ID=@Cmp_ID
			end

				 
		
  end  
 Else if @Tran_Type = 'D'  
  begin  
	if Not Exists(Select GCMID  from T0080_Griev_Committee_Member_Allocation WITH (NOLOCK) Where GCMID = @GrieId)  
		BEGIN
		
			Set @GrieId = 0
			RETURN 
		End
	ELSE
		Begin

						Delete From T0080_Griev_Committee_Member_Allocation Where GCMID = @GrieId --For Hard Delete

		End
   end  
 RETURN