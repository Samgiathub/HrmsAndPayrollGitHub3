
CREATE PROCEDURE [dbo].[P0090_EMP_IMMIGRATION_DETAIL]  
   @Row_ID numeric(18,0) output  
  ,@Emp_ID numeric(18,0)  
    ,@Cmp_ID numeric(18,0)  
    ,@Loc_ID numeric(18,0)  
  ,@Imm_Type varchar(20)  
  ,@Imm_No varchar(20)  
  ,@Imm_Issue_Date datetime  
  ,@Imm_Issue_Status varchar(20)  
  ,@Imm_Review_Date datetime  
  ,@Imm_Comments varchar(250)  
  ,@Imm_Date_of_Expiry datetime    
  ,@tran_type varchar(1)  
  ,@Login_id numeric(18,0)=0-- Rathod '18/04/2012'  
  ,@attach_doc nvarchar(max)=''  --Mukti 06072015  
   
AS  
  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  set @Imm_Comments = dbo.fnc_ReverseHTMLTags(@Imm_Comments)  --added by Ronak 100121  
  if @Imm_Review_Date = '01/01/1900'  
   Begin  
    Set @Imm_Review_Date = null  
   End   
  if @tran_type ='i'   
   begin  
     if exists( select Row_ID from T0090_EMP_IMMIGRATION_DETAIL WITH (NOLOCK) where (Emp_ID = @Emp_ID And cmp_ID = @cmp_ID AND Imm_type = @Imm_Type and Imm_No=@Imm_No) or (Imm_Issue_Date = @Imm_Issue_Date ))   --Added new condition by ronakk 30122022
     begin   
      set @Row_ID = 0  
      return  
     end   
     select @Row_ID = isnull(max(Row_ID),0) from T0090_EMP_IMMIGRATION_DETAIL WITH (NOLOCK)  
     if @Row_ID is null or @Row_ID = 0  
      set @Row_ID =1  
     else  
      set @Row_ID = @Row_ID + 1     
        
     INSERT INTO T0090_EMP_IMMIGRATION_DETAIL  
                           (Row_ID, Emp_ID, Cmp_ID, Imm_Type, Imm_No, Imm_Issue_Date, Imm_Issue_Status, Imm_Review_Date, Imm_Comments, Imm_Date_of_Expiry,Loc_ID,attach_doc)  
     VALUES     (@Row_ID,@Emp_ID,@Cmp_ID,@Imm_Type,@Imm_No,@Imm_Issue_Date,@Imm_Issue_Status,@Imm_Review_Date,@Imm_Comments,@Imm_Date_of_Expiry,@Loc_ID,@attach_doc)    
     INSERT INTO T0090_EMP_IMMIGRATION_DETAIL_Clone  
                           (Row_ID, Emp_ID, Cmp_ID, Imm_Type, Imm_No, Imm_Issue_Date, Imm_Issue_Status, Imm_Review_Date, Imm_Comments, Imm_Date_of_Expiry,Loc_ID,System_Date,Login_id)  
     VALUES     (@Row_ID,@Emp_ID,@Cmp_ID,@Imm_Type,@Imm_No,@Imm_Issue_Date,@Imm_Issue_Status,@Imm_Review_Date,@Imm_Comments,@Imm_Date_of_Expiry,@Loc_ID,GETDATE(),@Login_id)    
    end   
 else if @tran_type ='u'   
    Begin  
    if exists(select Row_ID from T0090_EMP_IMMIGRATION_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_ID And cmp_ID = @cmp_ID And Imm_Issue_Date = @Imm_Issue_Date And Row_ID <> @Row_ID AND Imm_type = @Imm_Type)  
     begin   
      set @Row_ID = 0  
      return  
     end   
      
      
     UPDATE    T0090_EMP_IMMIGRATION_DETAIL  
     SET              Cmp_ID = @Cmp_ID, Imm_Type = @Imm_Type, Imm_No = @Imm_No, Imm_Issue_Date = @Imm_Issue_Date,   
                          Imm_Issue_Status = @Imm_Issue_Status, Imm_Date_of_Expiry = @Imm_Date_of_Expiry, Imm_Review_Date = @Imm_Review_Date,   
                          Imm_Comments = @Imm_Comments ,attach_doc=@attach_doc,  
                          Loc_ID  = @Loc_ID  
                          where Emp_ID = @Emp_ID and Row_ID = @Row_ID   
                            
           INSERT INTO T0090_EMP_IMMIGRATION_DETAIL_Clone  
                (Row_ID, Emp_ID, Cmp_ID, Imm_Type, Imm_No, Imm_Issue_Date, Imm_Issue_Status, Imm_Review_Date, Imm_Comments, Imm_Date_of_Expiry,Loc_ID,System_Date,Login_id)  
     VALUES     (@Row_ID,@Emp_ID,@Cmp_ID,@Imm_Type,@Imm_No,@Imm_Issue_Date,@Imm_Issue_Status,@Imm_Review_Date,@Imm_Comments,@Imm_Date_of_Expiry,@Loc_ID,GETDATE(),@Login_id)                     
    end  
 else if @tran_type ='d'  
     delete  from T0090_EMP_IMMIGRATION_DETAIL where Row_ID = @Row_ID  
 RETURN  
  
  
  
  