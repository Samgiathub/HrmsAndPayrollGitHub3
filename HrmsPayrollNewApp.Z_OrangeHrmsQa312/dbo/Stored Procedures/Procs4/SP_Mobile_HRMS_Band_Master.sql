--select * from tblBandMaster  
--declare @p7 varchar(1000) set @p7='' exec SP_Mobile_HRMS_Band_Master @BandID=0,@Cmp_ID=119,@BandCode='te',@BandName='Test',@SortingNo='234',@tran_type='Insert',@Result=@p7 output select @p7   
  
  
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_Band_Master]  
  @BandID numeric(18,0),  
  @Cmp_ID numeric(18,0),  
  @BandCode varchar(50),  
  @BandName varchar(100),  
  @SortingNo numeric(18,0),  
  @Login_ID numeric(18,0),  
  @Active int,  
  @InEffDate varchar(50),  
  @Tran_Type CHAR(1),  
  @Result VARCHAR(100) OUTPUT  
AS  
BEGIN  
  
IF @InEffDate = ''  
BEGIN   
 SET @InEffDate  = NULL  
END  
     set @BandCode = dbo.fnc_ReverseHTMLTags(@BandCode)  --added by mansi 121021  
	      set @BandName = dbo.fnc_ReverseHTMLTags(@BandName)  --added by mansi 121021  
		  
  IF @Tran_Type='I'  
  BEGIN  
   IF Exists (SELECT 1 FROM tblBandMaster WHERE Cmp_Id = @Cmp_ID AND (BandCode = @BandCode OR BandName=@BandName))  
   BEGIN  
    SET @Result = ''  
   END  
   ELSE  
   BEGIN  
    INSERT INTO tblBandMaster (Cmp_ID,BandCode,BandName,SortingNo,IsActive,IsActiveEffDate,CreatedBy,CreatedDate)  
    VALUES (@Cmp_ID,@BandCode,@BandName,@SortingNo,@Active,@InEffDate,@Login_ID,GETDATE())  
      
    SET @Result = 'Record Insert Sucessfully#True'  
   END  
  END  
  ELSE IF @Tran_Type='U'  
  BEGIN  
    
   IF EXISTS(SELECT 1 FROM tblBandMaster WITH(NOLOCK) WHERE BandId = @BandID)   
   BEGIN  
     
     IF Exists (SELECT 1 FROM tblBandMaster WITH(NOLOCK) WHERE Cmp_Id = @Cmp_ID AND BandId <> @BandID AND (BandCode = @BandCode OR BandName=@BandName))  
     BEGIN  
      SET @Result = ''  
     END  
     ELSE  
     BEGIN  
      if @Active = 1  
      Begin   
       UPDATE tblBandMaster  
       SET BandCode = @BandCode,  
        BandName = @BandName,  
        SortingNo = @SortingNo,  
        Cmp_ID = @Cmp_ID,  
        IsActive = @Active,  
        IsActiveEffDate =  convert(varchar(20),GETDATE() ,103)  
       WHERE BandId = @BandID  
      END  
      ELSE  
      BEGIN  
       UPDATE tblBandMaster  
       SET BandCode = @BandCode,  
        BandName = @BandName,  
        SortingNo = @SortingNo,  
        Cmp_ID = @Cmp_ID,  
        IsActive = @Active,  
        IsActiveEffDate =convert(varchar(20),@InEffDate ,103) 
       WHERE BandId = @BandID  
      END  
       SET @Result = 'Record Updated Sucessfully#True'  
     END  
   END  
   ELSE  
   BEGIN  
     SET @Result = 'Record Not Found#False'  
   END  
 END  
 ELSE IF @Tran_Type='D'  
 BEGIN  
     
  DELETE FROM tblBandMaster where  BandId = @BandID   
  --update  tblBandMaster Set IsActive = 0 where BandId = @BandID   
  SET @Result = 'Record Delete Sucessfully#True'  
 END  
END  
  
  