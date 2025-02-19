
CREATE PROCEDURE [dbo].[P0040_Griev_Committee_Master]  
    @GrieId  numeric(9) output  
   ,@Cmp_ID   numeric(9)  
   ,@ComName nvarchar(max)
   ,@tran_type  varchar(1) 
   ,@StateID varchar(max)
   ,@DistrictID varchar(max)
   ,@TehsilID varchar(max)
   ,@BranchID varchar(max)
   ,@VerticalID varchar(max)
   ,@SubVerticalID varchar(max)
   ,@BussSgmtID varchar(max)
   ,@Chairperson int 
   ,@NodelHR int
   ,@ComMemID varchar(max)
   ,@EffDate Datetime
   ,@Branches nvarchar(max)
   ,@ComMemText nvarchar(max) --Added by ronakk 06052022
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
  --Created by Ronak Kumawat 28022022

 If @tran_type  = 'I'  
  Begin  
  if exists (Select GC_ID  from T0040_Griev_Committee_Master WITH (NOLOCK) Where GC_ID = @GrieId )   
    begin  
     set @GrieId = 0  
     Return  
    end  

	if exists (Select GC_ID  from T0040_Griev_Committee_Master WITH (NOLOCK) Where Com_Name = @ComName and Cmp_id=@Cmp_ID )   
    begin  
     set @GrieId = 0  
     Return  
    end  

    select @GrieId = Isnull(max(GC_ID),0) + 1  From T0040_Griev_Committee_Master  WITH (NOLOCK) 

    INSERT INTO T0040_Griev_Committee_Master (GC_ID,Com_Name,Cmp_id,State_ID,District_ID,Tehsil_ID,Branch_ID,Vertical_ID,SubVertical_ID,
	Business_Sgmt_ID,Chairperson_id,NodelHR_id,CommitteeMem_ID,CDTM,Effective_Date,BranchName,CommMemText)--Added by ronakk 06052022  
             VALUES(@GrieId,@ComName,@Cmp_ID,@StateID,@DistrictID,@TehsilID,@BranchID,@VerticalID,@SubVerticalID,
			 @BussSgmtID,@Chairperson,@NodelHR,@ComMemID,GETDATE(),@EffDate,@Branches,@ComMemText)--Added by ronakk 06052022

  End  
 Else if @Tran_Type = 'U'  
  begin  
   IF Not Exists(Select GC_ID  from T0040_Griev_Committee_Master WITH (NOLOCK) Where GC_ID = @GrieId)  
    Begin  
     set @GrieId = 0  
     Return   
    End  

		if exists (Select GC_ID  from T0040_Griev_Committee_Master WITH (NOLOCK) Where GC_ID <> @GrieId and Com_Name = @ComName and Cmp_id=@Cmp_ID)   
		begin  
		set @GrieId = 0  
		Return  
		end  


				 UPDATE T0040_Griev_Committee_Master  
				 SET Com_Name = @ComName
				 ,State_ID=@StateID
				 ,District_ID = @DistrictID
				 ,Tehsil_ID = @TehsilID
				 ,Branch_ID = @BranchID
				 ,Vertical_ID = @VerticalID
				 ,SubVertical_ID = @SubVerticalID
				 ,Business_Sgmt_ID =@BussSgmtID
				 ,Chairperson_id = @Chairperson
				 ,NodelHR_id = @NodelHR
				 ,CommitteeMem_ID = @ComMemID
				 ,Effective_Date = @EffDate
				 ,UDTM = getdate()
				 ,BranchName = @Branches
				 ,CommMemText = @ComMemText --Added by ronakk 06052022
				 where GC_ID = @GrieId  
		
  end  
 Else if @Tran_Type = 'D'  
  begin  
	if Exists(Select CommitteeID  from T0080_Griev_Application_Allocation WITH (NOLOCK) Where CommitteeID = @GrieId)  
		BEGIN
		
			Set @GrieId = 0
			RETURN 

		End
	ELSE
		Begin

				Delete From T0040_Griev_Committee_Master Where GC_ID = @GrieId --For Hard Delete

		End
   end  
 RETURN