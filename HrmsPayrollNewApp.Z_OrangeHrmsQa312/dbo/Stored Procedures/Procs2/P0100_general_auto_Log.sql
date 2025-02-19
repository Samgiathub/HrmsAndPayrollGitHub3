


CREATE PROCEDURE [dbo].[P0100_general_auto_Log]  
   @Cmp_ID   numeric(18),
   @Emp_Id   numeric(18),
   @ModuleName varchar(150) =null,
   @Is_Success tinyint =0, 
   @Comment varchar(400) =null,
   @SystemDateTime datetime=null

AS  
	SET NOCOUNT ON 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON    
   
   if exists (select RowId from T0100_general_auto_Log WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Emp_Id=@Emp_Id AND ModuleName = @ModuleName AND ModuleName='Birthday Wishes' and year(SystemDateTime)=year(getdate()))   
      begin 
		Select 0
		return 
      end
   Else if exists (select RowId from T0100_general_auto_Log WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Emp_Id=@Emp_Id AND ModuleName = @ModuleName and ModuleName='Work Anniversary' and year(SystemDateTime)=year(getdate()))   
	  BEGIN
		Select 0
		return
	  End
   Else if exists (select RowId from T0100_general_auto_Log WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Emp_Id=@Emp_Id AND ModuleName = @ModuleName and ModuleName='Marriage Anniversary' and year(SystemDateTime)=year(getdate()))   
	  BEGIN
		Select 0
		return
	  End
   Else
	  Begin
		INSERT INTO dbo.T0100_general_auto_Log(Cmp_ID,Emp_Id,ModuleName,Is_Success,Comment,SystemDateTime)  
		VALUES(@Cmp_ID,@Emp_Id,@ModuleName,@Is_Success,@Comment,@SystemDateTime)
	  End
    /*
    if not exists (select RowId from T0100_general_auto_Log where Cmp_ID=@Cmp_ID and Emp_Id=@Emp_Id and ModuleName='Work Anniversary' and year(SystemDateTime)=year(getdate()))   
      begin  
		INSERT INTO dbo.T0100_general_auto_Log(Cmp_ID,Emp_Id,ModuleName,Is_Success,Comment,SystemDateTime)  
		VALUES(@Cmp_ID,@Emp_Id,@ModuleName,@Is_Success,@Comment,@SystemDateTime)
	  end
	Else
	  Begin
		Select 0
		return
	  End
		  
    
     if not exists (select RowId from T0100_general_auto_Log where Cmp_ID=@Cmp_ID and Emp_Id=@Emp_Id and ModuleName='Marriage Anniversary' and year(SystemDateTime)=year(getdate()))   
      begin  
		INSERT INTO dbo.T0100_general_auto_Log(Cmp_ID,Emp_Id,ModuleName,Is_Success,Comment,SystemDateTime)  
		VALUES(@Cmp_ID,@Emp_Id,@ModuleName,@Is_Success,@Comment,@SystemDateTime)
      end
     Else
	  Begin
		Select 0
		return
	  End   
    */
 
  return
  
  


