  
  
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P9999_Ax_Mapping]  
  @Tran_Id numeric(18,0) output  
 ,@Cmp_id  numeric(18,0)  
 ,@Head_Name nvarchar(100)  
 ,@Account nvarchar(100)  
 ,@Narration nvarchar(150)  
 ,@Month_Year tinyint  
 ,@Tran_Type varchar(1)  
 ,@AD_ID numeric(18,0)  
 ,@sorting_no numeric(18,0)  
 ,@Type nvarchar(50)  
 ,@Loan_id numeric(18,0) = 0  
 ,@Vender_Code nvarchar(100)=''  
 ,@Other_Account nvarchar(100) = ''  
 ,@Claim_ID numeric(18,0) = 0  
 ,@Is_Highlight Tinyint = 0  
 ,@BackColor varchar(20) = ''  
 ,@ForeColor varchar(20) = ''  
 ,@Center_ID numeric(18,0) = 0 --Added by Jaina 28-07-2020  
 ,@Segment_ID numeric(18,0) = 0  --Added by Jaina 28-07-2020  
 ,@Band_ID numeric(18,0) = 0 --Added by Mr.Mehul 15062022
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
   set @Narration = dbo.fnc_ReverseHTMLTags(@Narration)  --added by Ronak 251021   
   set @Account = dbo.fnc_ReverseHTMLTags(@Account)  --added by Ronak 251021   
   set @Other_Account = dbo.fnc_ReverseHTMLTags(@Other_Account)  --added by Ronak 251021   
  if @Tran_Type = 'I'  
   BEGIN  
    SELECT @Tran_Id = isnull(max(Tran_id),0) + 1 FROM T9999_Ax_Mapping WITH (NOLOCK)  
      
    INSERT INTO T9999_Ax_Mapping  
      (Tran_Id, Cmp_id, Head_Name, Account, Narration, Month_Year, lastUpdated, Ad_id, Sorting_no, Type, Loan_id,vender_Code , Other_Account , Claim_ID , Is_Highlight , BackColor , ForeColor,Center_ID,Segment_ID,Band_Id)  
    VALUES  (@Tran_Id,@Cmp_id,@Head_Name,@Account,@Narration,@Month_Year, GETDATE(),@AD_ID,@sorting_no,@Type,@Loan_id,@vender_Code , @Other_Account , @Claim_ID , @Is_Highlight , @BackColor , @ForeColor,@Center_ID,@Segment_ID,@Band_ID)  
   END  
  ELSE IF @Tran_Type = 'U'  
   BEGIN  
    UPDATE    T9999_Ax_Mapping  
    SET             Account = @Account, Narration = @Narration,   
        Month_Year = @Month_Year, lastUpdated = GETDATE()  
        ,AD_id = @AD_ID  
        ,sorting_no =@sorting_no  
        ,Type = @Type  
        ,Loan_id = @Loan_Id  
        ,Vender_Code = @Vender_Code  
        ,Other_Account = @Other_Account  
        ,Claim_ID = @Claim_ID  
        ,Is_Highlight = @Is_Highlight  
        ,BackColor = @BackColor  
        ,ForeColor = @ForeColor  
        ,Center_ID = @Center_ID  
        ,Segment_ID = @Segment_ID  
		,Band_Id = @Band_ID
    WHERE Tran_Id = @Tran_Id  
      
   end     
  else if @Tran_Type = 'D'  
   begin  
      
    DELETE FROM T9999_Ax_Mapping  
    WHERE Tran_Id = @Tran_Id  
      
   end  
     
RETURN  
  
  
  
  