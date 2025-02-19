--select * from KPMS_T0020_BatchYear_Detail  
--select * from T0011_LOGIN where Login_ID = 7013  
--exec KPMS_SP0020_Insert_BatchYear_Details 1,0,'Xyz','Tcs',1,1  
CREATE PROCEDURE [dbo].[KPMS_SP0020_Insert_BatchYear_Details]  
(  
@Batch_Detail_Id Int,  
@Title VARCHAR(100),  
@Fromdate VARCHAR(50),  
@Todate VARCHAR(50),  
@IsActive Int,  
@Scheme INT,
@IsDefault Int,  
@Cmp_ID Int  
)  
as  
 SELECT @Fromdate = CASE ISNULL(@Fromdate,'') WHEN '' THEN '' ELSE CONVERT(VARCHAR(10), CONVERT(DATE, @Fromdate, 105), 23) END  
 SELECT @Todate = CASE ISNULL(@Todate,'') WHEN '' THEN '' ELSE CONVERT(VARCHAR(10), CONVERT(DATE, @Todate, 105), 23) END  
   
  
IF @Batch_Detail_Id = 0  
 BEGIN  
   
 IF Exists(select 1 From dbo.KPMS_T0020_BatchYear_Detail WITH (NOLOCK) Where upper(Batch_Title) = upper(@Title) and Cmp_ID = @Cmp_ID and IsActive < 2)    
    
  Begin   
   select -108  
   return  
  End   
    
  
 SELECT  @Batch_Detail_Id = Isnull(Max(Batch_Detail_Id),0)+1 from KPMS_T0020_BatchYear_Detail  
  
 INSERT INTO [KPMS_T0020_BatchYear_Detail]  
    (  [Cmp_ID],  
       [Batch_Detail_Id]  
       ,[Batch_Title]  
       ,[From_Date]  
        ,[To_Date]   
         ,[IsActive]  
       ,[IsDefault]  
	   ,[GoalScheme_Id]
      )  
   VALUES  
      (  
     @Cmp_ID  ,  
     @Batch_Detail_Id ,  
     @Title,  
     @Fromdate,  
     @Todate,  
     @IsActive,  
     @IsDefault,
	 @Scheme
	 
    )  
 if(@IsDefault)=1  
    BEGIN  
     UPDATE KPMS_T0020_BatchYear_Detail SET IsDefault = 0 WHERE Batch_Detail_Id <> @Batch_Detail_Id  
    END   
  SELECT 1 AS res  
 END  
      
 ELSE  
  
 BEGIN  
   
 IF Exists(select 1 From dbo.KPMS_T0020_BatchYear_Detail WITH (NOLOCK) Where upper(Batch_Title) = upper(@Title) and Cmp_ID = @Cmp_ID and Batch_Detail_Id<>@Batch_Detail_Id and IsActive < 2)    
  Begin   
   select -108  
   return  
  End    
  
  UPDATE KPMS_T0020_BatchYear_Detail SET IsDefault = 0 WHERE Batch_Detail_Id <> @Batch_Detail_Id  
  
     UPDATE [KPMS_T0020_BatchYear_Detail]  
     SET [Cmp_ID] =@Cmp_ID,  
       [Batch_Title] =@Title  
       ,[From_Date] =@Fromdate  
    ,[To_Date] =@Todate        
    ,[IsActive] =@IsActive  
    ,[IsDefault] = @IsDefault  
	   ,[GoalScheme_Id] =  @Scheme
       WHERE [Batch_Detail_Id] =@Batch_Detail_Id  
 END  
 