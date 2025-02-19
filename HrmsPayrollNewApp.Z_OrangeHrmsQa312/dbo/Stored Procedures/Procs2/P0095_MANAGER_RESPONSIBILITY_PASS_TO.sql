

---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0095_MANAGER_RESPONSIBILITY_PASS_TO]
	 @Tran_id as	numeric(18, 0) 
	,@Manger_Emp_id	 as	numeric(18, 0)	 
	,@Pass_To_Emp_id	 as	numeric(18, 0)	 
	,@From_date	 as	datetime	 
	,@To_date	 as	datetime	 
	,@Type	 as	nvarchar(250)	 --Change by Jaina 14-03-2017
	,@Cmp_id as numeric(18,0)
	,@is_manual as tinyint  = 0
	,@Trans_type as char(1)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
		
		Declare @Responsible_For varchar(200)
		
		--SET @To_date = CAST(@To_date + '23:59:29' AS DATETIME) --Ankit 04082016
		
		if @Trans_type = 'I'
		   begin
				 if not exists (select 1 from T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) INNER JOIN (select max(Effect_Date) as Effect_Date,ERD1.R_Emp_ID from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK) where ERD1.Effect_Date <= getdate() GROUP by ERD1.R_Emp_ID ) Tbl1 ON Tbl1.R_Emp_ID = ERD.R_Emp_ID AND Tbl1.Effect_Date >= ERD.Effect_Date AND ERD.Cmp_ID=@Cmp_Id AND ERD.R_Emp_ID = @Manger_Emp_id)
				 BEGIN
					RETURN
				 END
				--IF exists (SELECT 1 from T0095_MANAGER_RESPONSIBILITY_PASS_TO where Manger_Emp_id=@Manger_Emp_id AND Pass_To_Emp_id=@Pass_To_Emp_id	and From_date=@FRom_Date AND To_date=@To_date and Type=@Type)
						
				 DECLARE Type_Cursor CURSOR FOR SELECT CAST(Data as varchar(200))  FROM dbo.Split(@Type,'#')
				       OPEN Type_Cursor 
						   FETCH NEXT from Type_Cursor into @Responsible_For
								while @@fetch_status = 0
									Begin
									    
									    IF exists (SELECT 1 from T0095_MANAGER_RESPONSIBILITY_PASS_TO WITH (NOLOCK) where Manger_Emp_id=@Manger_Emp_id AND Pass_To_Emp_id=@Pass_To_Emp_id	and
												@FRom_Date BETWEEN From_date AND To_date AND @To_date BETWEEN From_date and To_date and Type=@Responsible_For)
										BEGIN
												Raiserror('Duplicate Record',16,2)
												return -1	
										END								  
										
										  INSERT INTO T0095_MANAGER_RESPONSIBILITY_PASS_TO
													(Manger_Emp_id, Pass_To_Emp_id, From_date, To_date, Type,cmp_id,is_manual)
										   VALUES     (@Manger_Emp_id,@Pass_To_Emp_id,@From_date,@To_date,@Responsible_For,@Cmp_id,@is_manual)
				
										
										 fetch next from Type_Cursor into @Responsible_For
									End
				Close Type_Cursor 
				DEALLOCATE Type_Cursor
							  
				
			end
		else if @Trans_type = 'U'
			begin
						
				UPDATE    T0095_MANAGER_RESPONSIBILITY_PASS_TO
				SET              
					Manger_Emp_id = @Manger_Emp_id, 
					Pass_To_Emp_id = @Pass_To_Emp_id, 
					From_date = @From_date,
					To_date = @To_date, 
					Type = @Type,
					Cmp_id=@Cmp_id,
					is_manual=@is_manual
				WHERE Tran_id = @Tran_id
				
			end
		else if @Trans_type = 'D'
			begin
				--Added by Jaina 14-03-2017
				IF @To_date	< getdate() 
				BEGIN
					Raiserror('Record can''t delete',16,2)
					return -1	
				END
				--Added by Jaina 21-07-2017
				if @From_date < getdate()
				BEGIN
					Raiserror('Record can''t delete',16,2)
					return -1	
				END
						
				DELETE FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO where Tran_id = @Tran_id
			end
END




