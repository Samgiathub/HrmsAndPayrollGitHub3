---09/3/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0040_Vehicle_Type_Master]  
   @Vehicle_ID numeric(18) output  
  ,@Cmp_ID numeric(18,0)  
  ,@Vehicle_Type varchar(50)  
  ,@Vehicle_Max_Limit numeric(18,2)   
  ,@Desig_Max_Limit Numeric = 0   
  ,@Desig_Max_Limit_String Varchar(MAX) = ''     
  ,@Grade_Max_Limit Numeric = 0   
  ,@Branch_Max_Limit Numeric = 0     
  ,@Attach_Mandatory bit   
  ,@Vehicle_Allow_Beyond_Limit tinyint   
  ,@User_Id numeric(18,0) = 0 -- Add By Mukti 08072016  
     ,@IP_Address varchar(30)= '' -- Add By Mukti 08072016    
  ,@No_Of_Year_Limit Numeric(18,0) = 0 --Added by Jaina 12-10-2020  
  ,@Eligible_Joining_Months int  
  ,@Deduction_Percentage float  
  ,@tran_type char  
AS  
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
  
 DECLARE @Tran_ID Numeric  
 DECLARE @Desi_ID Numeric(18,0)  
 DECLARE @Grade_ID Numeric(18,0) -- ADDED BY RAJPUT ON 14022018  
 DECLARE @Branch_ID Numeric(18,0) -- ADDED BY RAJPUT ON 27022018  
 DECLARE @Max_Limit Numeric(18,2)  
 DECLARE @Employee_Contribution Numeric(18,2)  
 DECLARE @String Varchar(MAX)  
 DECLARE @Max_Design_Tran_id Numeric(18,0)  
   
 SET @Tran_ID = 0  
 SET @Desi_ID = 0   
 SET @Grade_ID = 0 --ADDED BY RAJPUT ON 14022018  
 SET @Branch_ID = 0 --ADDED BY RAJPUT ON 27022018  
 SET @Max_Limit = 0  
 SET @Employee_Contribution = 0   
 SET @String = ''  
 SET @Max_Design_Tran_id = 0  
   
 -- Add By Mukti 08072016(start)  
 declare @OldValue as  varchar(max)  
 Declare @String_val as varchar(max)  
 set @String_val=''  
 set @OldValue =''  
 -- Add By Mukti 08072016(end)   
    set @Vehicle_Type = dbo.fnc_ReverseHTMLTags(@Vehicle_Type)  --added by Ronak 021121  
 if @tran_type ='I'   
  begin  
   if exists (Select Vehicle_ID  from T0040_VEHICLE_TYPE_MASTER WITH (NOLOCK) Where Upper(Vehicle_Type) = Upper(@Vehicle_Type)and Cmp_ID = @Cmp_ID)   
    begin  
     set @Vehicle_ID = 0  
    end  
   else  
    begin   
     insert into T0040_VEHICLE_TYPE_MASTER(Vehicle_Type,Cmp_ID,Vehicle_Max_Limit,Desig_Wise_Limit,Grade_Wise_Limit,Branch_Wise_Limit,Vehicle_Allow_Beyond_Limit,Attach_Mandatory,No_Of_Year_Limit,Eligible_Joining_Months,Deduction_Percentage)   
     values(@Vehicle_Type,@Cmp_ID,@Vehicle_Max_Limit,@Desig_Max_Limit,@Grade_Max_Limit,@Branch_Max_Limit,@Vehicle_Allow_Beyond_Limit,@Attach_Mandatory,@No_Of_Year_Limit,@Eligible_Joining_Months,@Deduction_Percentage)  
            
     -- Add By Mukti 08072016(start)  
      exec P9999_Audit_get @table = 'T0040_VEHICLE_TYPE_MASTER' ,@key_column='Vehicle_ID',@key_Values=@Vehicle_ID,@String=@String_val output  
      set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))    
     -- Add By Mukti 08072016(end)      
      set @Vehicle_ID = @@IDENTITY  
     IF @Desig_Max_Limit = 1 OR  @Grade_Max_Limit = 1 OR @Branch_Max_Limit = 1 -- @Grade_Max_Limit = 1 ADDED BY RAJPUT ON 15022018  
      BEGIN  
       SET @Tran_ID = 0  
        
       DECLARE Vehicle_Cursor CURSOR FOR   
        
                SELECT Data From dbo.split(@Desig_Max_Limit_String,'#')  
                  
                OPEN Vehicle_Cursor   
                  FETCH NEXT FROM Vehicle_Cursor INTO @String-- @Desi_ID,@Max_Limit,@Employee_Contribution  
                   WHILE @@fetch_status = 0  
        BEGIN  
           
         IF @DESIG_MAX_LIMIT = 1 --CONDITION CHANGED BY RAJPUT ON 15022018  
           BEGIN  
          SELECT @DESI_ID = DATA  FROM DBO.SPLIT(@STRING,',') WHERE ID=1  
           END  
         ELSE  
           BEGIN  
          SET @DESI_ID = NULL  
           END  
             
         IF @Grade_Max_Limit = 1 -- ADDED BY RAJPUT ON 15022018 FOR GRADE WISE Vehicle  
          BEGIN  
           SELECT @Grade_ID = DATA  FROM DBO.SPLIT(@STRING,',') WHERE ID=1  
          END  
         ELSE  
          BEGIN  
           SET @Grade_ID = NULL  
          END  
           
         IF @Branch_Max_Limit = 1 -- ADDED BY RAJPUT ON 27022018 FOR BRANCH WISE Vehicle  
          BEGIN  
           SELECT @Branch_ID = DATA  FROM DBO.SPLIT(@STRING,',') WHERE ID=1  
          END  
         ELSE  
          BEGIN  
           SET @Branch_ID = NULL  
          END  
           
            
          SELECT @Max_Limit = Data FROM dbo.split(@string,',') where ID=2  
          SELECT @Employee_Contribution = Data  FROM dbo.split(@string,',') where ID=3  
           
          SELECT @Tran_ID = isnull(max(Tran_ID),0) + 1 FROM dbo.T0041_Vehicle_Maxlimit_Design WITH (NOLOCK)  
            
            
          INSERT INTO dbo.T0041_Vehicle_Maxlimit_Design(Tran_ID,Vehicle_ID,Desig_Id,Grade_Id,Branch_ID,Max_Limit,Employee_Contribution)  
          VALUES(@Tran_ID,@Vehicle_ID,cast(@Desi_ID AS NUMERIC(18,0)),cast(@Grade_ID AS NUMERIC(18,0)),cast(@Branch_ID AS NUMERIC(18,0)),cast(@Max_Limit AS numeric(18,2)),cast(@Employee_Contribution AS numeric(18,2)))  
            
          FETCH NEXT FROM Vehicle_Cursor INTO @String--@Desi_ID,@Max_Limit,@Employee_Contribution  
        END  
                CLOSE Vehicle_Cursor   
                   DEALLOCATE Vehicle_Cursor  
                   
     end         
       
      
     return  
    end  
  end   
 else if @tran_type ='U'   
  begin  
   if exists (Select Vehicle_ID  from T0040_VEHICLE_TYPE_MASTER WITH (NOLOCK) Where Upper(Vehicle_Type )= upper(@Vehicle_Type) and Vehicle_ID <> @Vehicle_ID and Cmp_ID = @Cmp_ID)   
    BEGIN  
     SET @Vehicle_ID = 0  
    END       
   ELSE  
    BEGIN  
    -- Add By Mukti 08072016(start)  
     exec P9999_Audit_get @table='T0040_VEHICLE_TYPE_MASTER' ,@key_column='Vehicle_ID',@key_Values=@Vehicle_ID,@String=@String_val output  
     set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))  
    -- Add By Mukti 08072016(end)  
     
     UPDATE T0040_VEHICLE_TYPE_MASTER  
     SET Vehicle_Type = @Vehicle_Type,  
      Vehicle_Max_Limit=@Vehicle_Max_Limit,  
      Desig_Wise_Limit = @Desig_Max_Limit,  
      Grade_Wise_Limit = @Grade_Max_Limit,  
      Branch_Wise_Limit = @Branch_Max_Limit,        
      Vehicle_Allow_Beyond_Limit = @Vehicle_Allow_Beyond_Limit,   
      Attach_Mandatory = @Attach_Mandatory,        
      No_Of_Year_Limit = @No_Of_Year_Limit,  
      Eligible_Joining_Months=@Eligible_Joining_Months,  
      Deduction_Percentage=@Deduction_Percentage  
     WHERE Vehicle_ID = @Vehicle_ID and Cmp_ID = @Cmp_ID   
     
    -- Add By Mukti 08072016(start)  
     exec P9999_Audit_get @table = 'T0040_VEHICLE_TYPE_MASTER' ,@key_column='Vehicle_ID',@key_Values=@Vehicle_ID,@String=@String_val output  
     set @OldValue = @OldValue + 'New Value' + '#' + cast(@String_val as varchar(max))  
    -- Add By Mukti 08072016(end)   
       
      
     IF @Desig_Max_Limit = 1 OR @Grade_Max_Limit = 1 OR  @Branch_Max_Limit = 1  
      BEGIN   
           DELETE FROM T0041_Vehicle_MAXLIMIT_DESIGN WHERE Vehicle_ID = @Vehicle_ID   
           
         IF @DESIG_MAX_LIMIT = 1 OR  @GRADE_MAX_LIMIT = 1 OR @BRANCH_MAX_LIMIT = 1 -- @GRADE_MAX_LIMIT = 1 ADDED BY RAJPUT ON 15022018  
           BEGIN             
            SET @TRAN_ID = 0  
             
            DECLARE Vehicle_CURSOR CURSOR FOR   
             
            SELECT DATA FROM DBO.SPLIT(@DESIG_MAX_LIMIT_STRING,'#')  
                       
            OPEN Vehicle_CURSOR   
              FETCH NEXT FROM Vehicle_CURSOR INTO @STRING-- @DESI_ID,@Max_Limit,@Employee_Contribution  
            WHILE @@FETCH_STATUS = 0  
             BEGIN                
              IF @DESIG_MAX_LIMIT = 1 --CONDITION CHANGED BY RAJPUT ON 15022018  
                BEGIN  
               SELECT @DESI_ID = DATA  FROM DBO.SPLIT(@STRING,',') WHERE ID=1  
                END  
              ELSE  
                BEGIN  
               SET @DESI_ID = NULL  
                END  
                  
              IF @GRADE_MAX_LIMIT = 1 -- ADDED BY RAJPUT ON 15022018 FOR GRADE WISE Vehicle  
               BEGIN  
                SELECT @GRADE_ID = DATA  FROM DBO.SPLIT(@STRING,',') WHERE ID=1  
               END  
              ELSE  
               BEGIN  
                SET @GRADE_ID = NULL  
               END  
                
              IF @BRANCH_MAX_LIMIT = 1 -- ADDED BY RAJPUT ON 27022018 FOR BRANCH WISE Vehicle  
               BEGIN  
                SELECT @BRANCH_ID = DATA  FROM DBO.SPLIT(@STRING,',') WHERE ID=1  
               END  
              ELSE  
               BEGIN  
                SET @BRANCH_ID = NULL  
               END  
                
                 
               SELECT @Max_Limit = DATA FROM DBO.SPLIT(@STRING,',') WHERE ID=2  
               SELECT @Employee_Contribution = DATA  FROM DBO.SPLIT(@STRING,',') WHERE ID=3  
                
               SELECT @TRAN_ID = ISNULL(MAX(TRAN_ID),0) + 1 FROM DBO.T0041_Vehicle_MAXLIMIT_DESIGN WITH (NOLOCK)  
                 
                 
               INSERT INTO DBO.T0041_Vehicle_MAXLIMIT_DESIGN(TRAN_ID,Vehicle_ID,DESIG_ID,GRADE_ID,BRANCH_ID,MAX_LIMIT,Employee_Contribution)  
               VALUES(@TRAN_ID,@Vehicle_ID,CAST(@DESI_ID AS NUMERIC(18,0)),CAST(@GRADE_ID AS NUMERIC(18,0)),CAST(@BRANCH_ID AS NUMERIC(18,0)),CAST(@Max_Limit AS NUMERIC(18,2)),CAST(@Employee_Contribution AS NUMERIC(18,2)))  
                 
               FETCH NEXT FROM Vehicle_CURSOR INTO @STRING--@DESI_ID,@Max_Limit,@Employee_Contribution  
             END  
            CLOSE Vehicle_CURSOR   
            DEALLOCATE Vehicle_CURSOR                        
          END    
      END   
     ELSE  
      BEGIN  
       DELETE  FROM dbo.T0041_Vehicle_Maxlimit_Design WHERE Vehicle_ID = @Vehicle_ID  
      END       
    end  
  end   
 else if @tran_type ='D'  
  begin  
    -- Add By Mukti 08072016(start)  
     exec P9999_Audit_get @table='T0040_VEHICLE_TYPE_MASTER' ,@key_column='Vehicle_ID',@key_Values=@Vehicle_ID,@String=@String_val output  
     set @OldValue = @OldValue + 'old Value' + '#' + cast(@String_val as varchar(max))  
    -- Add By Mukti 08072016(end)     
     
   --IF EXISTS(SELECT 1 FROM T0140_Vehicle_TRANSACTION WHERE Vehicle_ID=@Vehicle_ID AND Cmp_ID=@Cmp_ID) -- ADDED BY RAJPUT ON 19032018  
   -- BEGIN   
    --  DELETE FROM T0140_Vehicle_TRANSACTION WHERE Vehicle_ID=@Vehicle_ID AND Cmp_ID=@Cmp_ID   
    --   AND ISNULL(Vehicle_Opening,0.00) = 0.00 AND ISNULL(Vehicle_Issue,0.00) = 0.00  
    --   AND ISNULL(Vehicle_Return,0.00) = 0.00 AND ISNULL(Vehicle_Closing,0.00) = 0.00  
    --END     
   delete  from T0041_Vehicle_Maxlimit_Design where Vehicle_ID=@Vehicle_ID   
   delete  from T0040_VEHICLE_TYPE_MASTER where Vehicle_ID=@Vehicle_ID    
  end  
   
  exec P9999_Audit_Trail @CMP_ID,@Tran_Type,'Vehicle Master',@OldValue,@Vehicle_ID,@User_Id,@IP_Address  
RETURN  
  
  
  
  