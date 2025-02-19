  
  
 ---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0030_Hrms_Training_Category]  
  @TRAININGCATEGORY_ID NUMERIC(18, 0) OUTPUT  
 ,@CMP_ID     NUMERIC(18, 0)   
 ,@TRAININGCATEGORY_NAME VARCHAR(250)  
 ,@PARENT_CATEGORYID NUMERIC(18,0)----ADDED BY JAINA 27072015  
 ,@TRAN_TYPE    VARCHAR(1)   
 ,@USER_ID NUMERIC(18,0) = 0 -- ADDED BY MUKTI 19082015  
    ,@IP_ADDRESS VARCHAR(30)= '' -- ADDED BY MUKTI 19082015  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
--ADDED BY MUKTI 18082015(START)  
 DECLARE @OLDVALUE AS VARCHAR(MAX)  
 DECLARE @OLDTRAININGCATEGORY_NAME VARCHAR(250)  
 DECLARE @OLDPARENT_CATEGORYID VARCHAR(20)  
--ADDED BY MUKTI 18082015(END)  
   set @TRAININGCATEGORY_NAME = dbo.fnc_ReverseHTMLTags(@TRAININGCATEGORY_NAME)  --added by Ronak 221021   
BEGIN  
  IF UPPER(@TRAN_TYPE) ='I'   
  BEGIN  
   IF EXISTS(SELECT 1 FROM T0030_HRMS_TRAINING_CATEGORY WITH (NOLOCK) WHERE TRAINING_CATEGORY_NAME=@TRAININGCATEGORY_NAME AND TRAINING_CATEGORY_ID<>@TRAININGCATEGORY_ID AND CMP_ID=@CMP_ID)  
    BEGIN  
     --Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Duplicate entry of Training Category name',0,'Duplicate name',GetDate(),'TrainingCategory')  
     SET @TRAININGCATEGORY_ID=0  
     RETURN   
    END  
     
   SELECT @TRAININGCATEGORY_ID = ISNULL(MAX(TRAINING_CATEGORY_ID),0) + 1 FROM T0030_HRMS_TRAINING_CATEGORY WITH (NOLOCK)  
   INSERT INTO T0030_HRMS_TRAINING_CATEGORY(TRAINING_CATEGORY_ID,CMP_ID,TRAINING_CATEGORY_NAME,PARENT_CATEGORYID)  --ADDED BY JAINA 27072015  
   VALUES(@TRAININGCATEGORY_ID,@CMP_ID,@TRAININGCATEGORY_NAME,@PARENT_CATEGORYID) --ADDED BY JAINA 27072015  
     
   --ADDED BY MUKTI 19082015(START)  
       SET @OLDVALUE = 'New Value' + '#'+ 'Training Category Name:' + CAST(ISNULL(@TRAININGCATEGORY_NAME,'') AS VARCHAR(250))   
           + '#' + 'Company Id:' + CAST(ISNULL(@CMP_ID,0) AS VARCHAR(20))   
           + '#' + 'Parent Category Id:' + CAST(ISNULL(@PARENT_CATEGORYID,0) AS VARCHAR(20))  
   --ADDED BY MUKTI 19082015(END)  
  END  
  --added by jaina 24072015 (Start)  
 IF UPPER(@TRAN_TYPE) = 'U'  
  BEGIN  
    
  --Added By Ashwin 10102016  
   IF EXISTS(SELECT 1 FROM T0030_HRMS_TRAINING_CATEGORY WITH (NOLOCK) WHERE TRAINING_CATEGORY_NAME=@TRAININGCATEGORY_NAME AND TRAINING_CATEGORY_ID<>@TRAININGCATEGORY_ID AND CMP_ID=@CMP_ID)  
    BEGIN  
     SET @TRAININGCATEGORY_ID=0  
     RETURN   
    END  
    --Added By Ashwin 10102016(END)  
      
   --Added By Mukti 19082015(start)  
      SELECT @OLDTRAININGCATEGORY_NAME=TRAINING_CATEGORY_NAME, @OLDPARENT_CATEGORYID=PARENT_CATEGORYID   
      FROM T0030_HRMS_TRAINING_CATEGORY WITH (NOLOCK) WHERE TRAINING_CATEGORY_ID = @TRAININGCATEGORY_ID  
   --Added By Mukti 19082015(end)  
        
      UPDATE T0030_HRMS_TRAINING_CATEGORY SET TRAINING_CATEGORY_NAME=@TRAININGCATEGORY_NAME, PARENT_CATEGORYID=@PARENT_CATEGORYID   
      WHERE TRAINING_CATEGORY_ID = @TRAININGCATEGORY_ID   
     
   --Added By Mukti 19082015(start)  
       set @OldValue = 'Old Value' + '#'+ 'Training Category Name:' + cast(Isnull(@OldTrainingCategory_Name,'') as varchar(250)) + '#' +   
                  'Company Id:' + cast(Isnull(@Cmp_Id,0) as varchar(20)) + '#' +   
                  'Parent Category Id:' + cast(Isnull(@OldParent_categoryId,0) as varchar(20))  + '#' +   
        'New Value' + '#'+ 'Training Category Name:' + cast(Isnull(@TrainingCategory_Name,'') as varchar(250)) + '#' +   
                  'Company Id:' + cast(Isnull(@Cmp_Id,0) as varchar(20)) + '#' +   
                  'Parent Category Id:' + cast(Isnull(@Parent_categoryId,0) as varchar(20))  
   --Added By Mukti 19082015(end)  
  END  
  --added by jaina 24072015 (Start)  
 ELSE IF UPPER(@TRAN_TYPE) ='D'  
  BEGIN  
   IF EXISTS(SELECT * FROM T0040_HRMS_TRAINING_MASTER AS T  WITH (NOLOCK) WHERE   T.TRAINING_CATEGORY_ID= @TRAININGCATEGORY_ID )  
    BEGIN  
     --Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Delete is not possible',0,'Duplicate name',GetDate(),'TrainingCategory')  
     SET @TRAININGCATEGORY_ID=0  
     RETURN   
    END  
   ELSE  
   BEGIN  
    --Added By Mukti 19082015(start)  
       SELECT @OLDTRAININGCATEGORY_NAME=TRAINING_CATEGORY_NAME, @OLDPARENT_CATEGORYID=PARENT_CATEGORYID   
       FROM T0030_HRMS_TRAINING_CATEGORY WITH (NOLOCK) WHERE TRAINING_CATEGORY_ID = @TRAININGCATEGORY_ID  
    --Added By Mukti 19082015(end)  
      
    DELETE FROM T0030_HRMS_TRAINING_CATEGORY WHERE TRAINING_CATEGORY_ID = @TRAININGCATEGORY_ID   
      
    --Added By Mukti 19082015(start)  
     set @OldValue = 'Old Value' + '#'+ 'Training Category Name:' + cast(Isnull(@OldTrainingCategory_Name,'') as varchar(250)) + '#' +   
                'Company Id:' + cast(Isnull(@Cmp_Id,0) as varchar(20)) + '#' +   
                'Parent Category Id:' + cast(Isnull(@OldParent_categoryId,0) as varchar(20))    
    --Added By Mukti 19082015(end)  
   end   
  End  
 EXEC P9999_AUDIT_TRAIL @CMP_ID,@TRAN_TYPE,'Training Category',@OLDVALUE,@TRAININGCATEGORY_ID,@USER_ID,@IP_ADDRESS  
END  