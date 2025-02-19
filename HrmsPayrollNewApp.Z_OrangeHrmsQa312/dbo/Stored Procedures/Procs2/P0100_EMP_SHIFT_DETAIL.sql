---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---      
CREATE PROCEDURE [dbo].[P0100_EMP_SHIFT_DETAIL]      
 @Shift_Tran_ID numeric output      
   ,@Emp_ID numeric      
   ,@Cmp_ID numeric      
   ,@Shift_ID numeric      
   ,@For_Date datetime      
   ,@tran_type varchar(1)      
   ,@Shift_type numeric      
   ,@User_Id numeric(18,0) = 0 -- Added for Audit Trail by Ali 09102013      
   ,@IP_Address varchar(30)= '' -- Added for Audit Trail by Ali 09102013      
         
AS      
SET NOCOUNT ON       
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED      
SET ARITHABORT ON      
      
 Declare @Max_Shift_ID numeric      
         -- Added for Audit Trail by Ali 09102013 -- Start      
         Declare @Old_Emp_Id as numeric      
         Declare @Old_Emp_Name as varchar(100)      
         Declare @Old_Shift_ID numeric      
         Declare @Old_Shift_Name as varchar(200)      
         Declare @New_Shift_Name as varchar(200)      
         Declare @Old_for_Date as datetime      
         Declare @Old_Shift_Type as numeric               
         Declare @OldValue as varchar(max)      
               
               
         Set @Old_Emp_Id = 0       
         Set @Old_Emp_Name  = ''      
         Set @Old_Shift_ID = 0      
         Set @Old_Shift_Name = ''      
         Set @New_Shift_Name = ''      
         Set @Old_for_Date = ''      
         Set @Old_Shift_Type = 0               
         Set @OldValue = ''      
               
	IF EXISTS(Select 1 from T0250_MONTHLY_LOCK_INFORMATION where MONTH = month(@For_Date) and YEAR = Year(@For_Date) and Cmp_ID = @Cmp_ID 
				and (Branch_ID = (Select Branch_ID from T0080_EMP_MASTER where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID) or Branch_ID = 0))      
     Begin       
            Raiserror('@@Same Date Month Is Locked@@',16,2)       
			return       
     End    	
         -- Added for Audit Trail by Ali 09102013 -- End      
 If @tran_type  = 'I'      
  Begin      
        Print 'insert'   
		

   IF EXISTS(Select Emp_ID From T0100_Emp_Shift_Detail WITH (NOLOCK)  Where Emp_ID = @Emp_ID and For_Date= @For_Date)      
     Begin       
            Raiserror('@@Shift Details Already Exist For This Date@@',16,2)       
      return       
     End      
         
   If Exists(Select Sal_tran_Id From T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID=@Emp_ID And Cmp_ID=@Cmp_ID And       
      @For_Date >= Month_St_Date and @For_Date <= Isnull(Cutoff_Date, Month_End_Date)) And @Shift_type=1      
    Begin      
     Raiserror('@@This Months Salary Exists.So You Can not Change Shift.@@',16,2)      
     return -1      
    End      
   Else If Exists(Select Sal_tran_Id From T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID=@Emp_ID And Cmp_ID=@Cmp_ID        
       AND ISNULL(Cutoff_Date, MONTH_END_DATE) >= @For_Date) And @Shift_type=0      
    Begin      
     Raiserror('@@This Months Salary Exists.So You Can not Change Shift.@@',16,2)      
     return -1      
    End      
   Else      
    begin      
     select @Shift_Tran_ID = Isnull(max(Shift_Tran_ID),0) + 1  From T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)      
           
     INSERT INTO T0100_EMP_SHIFT_DETAIL      
            (Shift_Tran_ID, Emp_ID, Cmp_ID, Shift_ID, For_Date,Shift_type)      
     VALUES     (@Shift_Tran_ID, @Emp_ID, @Cmp_ID, @Shift_ID, @For_Date,@Shift_type)      
                     
     Select @Max_Shift_ID=Shift_ID from T0100_Emp_shift_Detail I1 WITH (NOLOCK) inner join      
      (Select Max(For_Date)for_Date,Emp_ID from T0100_Emp_shift_Detail WITH (NOLOCK) where Emp_ID=@Emp_ID and Shift_type=0 group by emp_ID ,shift_type)I2 on      
      I1.Emp_ID= I2.Emp_ID  and I1.For_Date =I2.For_Date      
           
     --print @Max_Shift_ID      
           
     Update T0080_emp_Master      
       set Shift_ID = @Max_Shift_ID      
       where Emp_ID=@Emp_ID       
                
          Declare @SMS_Emp_Name Varchar(100)      
          Set @SMS_Emp_Name = ''      
                
          -- Added for Audit Trail by Ali 09102013 -- Start      
          Select @Old_Emp_Name =  ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,''),@SMS_Emp_Name = Emp_First_Name  from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Emp_ID      
          select @Old_Shift_Name = Shift_Name from T0040_SHIFT_MASTER WITH (NOLOCK) where Shift_ID = @Shift_ID  AND Cmp_ID = @Cmp_ID      
                
          set @OldValue = 'New Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'')       
            + '#' + 'Shift Name :' + ISNULL(@Old_Shift_Name,'')                   
            + '#' + 'Shift Type :' + CASE ISNULL(@Shift_type,0) WHEN 0 THEN 'Regular' ELSE 'Temporary' END      
            + '#' + 'For date :' + cast(ISNULL(@For_Date,'') as nvarchar(11))       
          exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Shift Change',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1       
          -- Added for Audit Trail by Ali 09102013 -- End      
                
          -- Added by nilesh patel on 19022018 for shift change SMS --Start      
          --Declare @SMS_old_Shift_ID numeric      
          --Set @SMS_old_Shift_ID = 0      
                
          --Declare @SMS_old_Shift_Name Varchar(100)      
          --Set @SMS_old_Shift_Name = ''      
                
          --Select @SMS_old_Shift_ID =Shift_ID       
          -- from T0100_Emp_shift_Detail I1       
          --inner join(      
          --    Select Max(For_Date)for_Date,Emp_ID       
          --     from T0100_Emp_shift_Detail        
          --    where Emp_ID=@Emp_ID and Shift_type=0 and For_Date < @For_Date      
          --    group by emp_ID ,shift_type      
          --    )I2 on I1.Emp_ID= I2.Emp_ID  and I1.For_Date =I2.For_Date      
                    
          --Select @SMS_old_Shift_Name = Shift_Name From T0040_SHIFT_MASTER Where Shift_ID = @SMS_old_Shift_ID      
                
          --Declare @SMS_Text Varchar(Max)      
          --Set @SMS_Text = ''      
          --Set @SMS_Text = 'Dear ' + @SMS_Emp_Name + ', your shift ' + @SMS_old_Shift_Name + ' is change from ' + CONVERT(VARCHAR(11), @For_Date, 103) + ' and new shift is ' + ISNULL(@Old_Shift_Name,'') + ' Regards, Team - HR'       
                
          --Exec P0100_SMS_Transcation 0,@Cmp_ID,@Emp_ID,'Shift change',@SMS_Text      
          -- Added by nilesh patel on 19022018 for shift change SMS --End      
    end      
  End      
 Else if @Tran_Type = 'U'      
  Begin      
	 
          -- Added for Audit Trail by Ali 09102013 -- Start      
          Select       
          @Old_Emp_Id = Emp_ID      
          ,@Old_Shift_ID =Shift_ID      
          ,@Old_for_Date = For_Date      
          ,@Old_Shift_Type = Shift_Type      
          from T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)      
          Where Shift_Tran_ID = @Shift_Tran_ID       
                
          Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')  from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Old_Emp_Id)      
          Set @Old_Shift_Name = (select Shift_Name from T0040_SHIFT_MASTER WITH (NOLOCK) where Shift_ID = @Old_Shift_ID  AND Cmp_ID = @Cmp_ID)      
                                    
          Set @New_Shift_Name = (select Shift_Name from T0040_SHIFT_MASTER WITH (NOLOCK) where Shift_ID = @Shift_ID  AND Cmp_ID = @Cmp_ID)      
                
          set @OldValue = 'old Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'')       
            + '#' + 'Shift Name :' + ISNULL(@Old_Shift_Name,'')                   
            + '#' + 'Shift Type :' + CASE ISNULL(@Old_Shift_Type,0) WHEN 0 THEN 'Regular' ELSE 'Temporary' END      
            + '#' + 'For date :' + cast(ISNULL(@Old_for_Date,'') as nvarchar(11))       
            + '#' +      
            + 'New Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'')       
            + '#' + 'Shift Name :' + ISNULL(@New_Shift_Name,'')                   
            + '#' + 'Shift Type :' + CASE ISNULL(@Shift_type,0) WHEN 0 THEN 'Regular' ELSE 'Temporary' END      
            + '#' + 'For date :' + cast(ISNULL(@For_Date,'') as nvarchar(11))       
          exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Shift Change',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1       
          -- Added for Audit Trail by Ali 09102013 -- End      
            
     IF EXISTS(Select Emp_ID From T0100_Emp_Shift_Detail WITH (NOLOCK) Where Emp_ID = @Emp_ID and For_Date= @For_Date and Shift_Tran_ID <> @Shift_Tran_ID )    
     Begin       
            Raiserror('@@Shift Details Already Exist For This Date@@',16,2)       
      return       
     End      
         
     If Exists(Select Sal_tran_Id From T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID=@Emp_ID And Cmp_ID=@Cmp_ID And       
        @For_Date >= Month_St_Date and @For_Date <= Isnull(Cutoff_Date, Month_End_Date)) And @Shift_type=1      
      Begin      
       Raiserror('@@This Months Salary Exists.So You Can not Change Shift.@@',16,2)      
       return -1      
      End      
     Else If Exists(Select Sal_tran_Id From T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID=@Emp_ID And Cmp_ID=@Cmp_ID        
         AND ISNULL(Cutoff_Date, MONTH_END_DATE) >= @For_Date) And @Shift_type=0      
      Begin      
       Raiserror('@@This Months Salary Exists.So You Can not Change Shift.@@',16,2)      
       return -1      
      End      
      
            
                
        
    UPDATE    T0100_EMP_SHIFT_DETAIL      
    SET              Shift_ID = @Shift_ID,       
        For_Date = @For_Date,      
        shift_Type=@Shift_Type      
    WHERE     (Shift_Tran_ID = @Shift_Tran_ID)      
        
  Select @Max_Shift_ID=Shift_ID from T0100_Emp_shift_Detail I1 WITH (NOLOCK) inner join      
   (Select Max(For_Date)for_Date,Emp_ID from T0100_Emp_shift_Detail WITH (NOLOCK) where Emp_ID=@Emp_ID and Shift_type=0 group by emp_ID ,shift_type)I2 on      
   I1.Emp_ID= I2.Emp_ID  and I1.For_Date =I2.For_Date      
        
  Update T0080_emp_Master      
    set Shift_ID = @Max_Shift_ID      
    where Emp_ID=@Emp_ID       
  end      
 Else if @Tran_Type = 'D'      
  Begin      
   Select @Emp_ID = Emp_ID, @For_Date = For_Date from T0100_EMP_SHIFT_DETAIL WITH (NOLOCK) Where Shift_Tran_ID = @Shift_Tran_ID       
   --Added By Mukti(start)23062016      
   declare @date_of_join as DATETIME      
   select @date_of_join=Date_Of_Join from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID=@Emp_ID --and Cmp_ID=@Cmp_ID      
   --Added By Mukti(end)23062016      
         
   If Exists(Select Sal_tran_Id From T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID=@Emp_ID --And Cmp_ID=@Cmp_ID    
   And   @For_Date >= Month_St_Date and @For_Date <= Isnull(Cutoff_Date, Month_End_Date)) And @Shift_type=1      
    Begin      
     Raiserror('@@This Months Salary Exists.So You Can not Change Shift.@@',16,2)      
     return -1      
    End      
   Else If Exists(Select Sal_tran_Id From T0200_MONTHLY_SALARY WITH (NOLOCK) where Emp_ID=@Emp_ID --And Cmp_ID=@Cmp_ID        
       AND ISNULL(Cutoff_Date, MONTH_END_DATE) >= @For_Date) And @Shift_type=0      
    Begin      
     Raiserror('@@This Months Salary Exists.So You Can not Change Shift.@@',16,2)      
     return -1      
    End      
   Else      
    begin      
          -- Added for Audit Trail by Ali 09102013 -- Start      
          Select       
          @Old_Emp_Id = Emp_ID      
          ,@Old_Shift_ID =Shift_ID      
          ,@Old_for_Date = For_Date      
          ,@Old_Shift_Type = Shift_Type      
          from T0100_EMP_SHIFT_DETAIL WITH (NOLOCK)      
          Where Shift_Tran_ID = @Shift_Tran_ID       
                
          Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')  from T0080_EMP_MASTER WITH (NOLOCK) where Emp_ID = @Old_Emp_Id)      
          Set @Old_Shift_Name = (select Shift_Name from T0040_SHIFT_MASTER WITH (NOLOCK) where Shift_ID = @Old_Shift_ID  AND Cmp_ID = @Cmp_ID)      
                
          set @OldValue = 'old Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'')       
            + '#' + 'Shift Name :' + ISNULL(@Old_Shift_Name,'')                   
            + '#' + 'Shift Type :' + CASE ISNULL(@Old_Shift_Type,0) WHEN 0 THEN 'Regular' ELSE 'Temporary' END      
            + '#' + 'For date :' + cast(ISNULL(@Old_for_Date,'') as nvarchar(11))       
          exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Shift Change',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1       
          -- Added for Audit Trail by Ali 09102013 -- End      
        
  Delete From T0100_EMP_SHIFT_DETAIL Where Shift_Tran_ID = @Shift_Tran_ID      
  and convert(varchar(15),For_Date,103) <> CONVERT(varchar(15),@date_of_join,103)      
        
  --Added By Mukti 23012015(start)       
  Select @Max_Shift_ID=Shift_ID from T0100_Emp_shift_Detail I1 WITH (NOLOCK) inner join      
  (Select Max(For_Date)for_Date,Emp_ID from T0100_Emp_shift_Detail  WITH (NOLOCK)      
  where Emp_ID=@Emp_ID and Shift_type=0 group by emp_ID ,shift_type)I2 on      
  I1.Emp_ID= I2.Emp_ID  and I1.For_Date =I2.For_Date      
        
  IF(isnull(@Max_Shift_ID,0)>0)      
  BEGIN      
   Update T0080_emp_Master  set Shift_ID = isnull(@Max_Shift_ID,0)  where Emp_ID=@Emp_ID          
  END      
  --Added By Mukti 23012015(end)        
      
   end      
  end      
RETURN      
      
      
      
      
      
      
      