

-- =============================================
-- Author:		<Ankit>
-- Create date: <26092015,,>
-- Description:	<Employee Grade Change - Import,,>
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0100_EMP_GRADE_DETAIL]
	@Tran_ID	NUMERIC OUTPUT
   ,@Emp_ID		NUMERIC
   ,@Cmp_ID		NUMERIC
   ,@For_Date	DATETIME
   ,@To_Date	DATETIME = NULL
   ,@Grd_ID		NUMERIC
   ,@OT_Grd_ID	NUMERIC = NULL
   ,@tran_type	VARCHAR(1)
   ,@User_Id	NUMERIC(18,0)	= 0 
   ,@IP_Address VARCHAR(30)		= '' 
   
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	--Declare @Max_Grd_ID numeric
	--Declare @Old_Emp_Id as numeric
	--Declare @Old_Emp_Name as varchar(100)
	--Declare @Old_Grd_ID numeric
	--Declare @Old_Shift_Name as varchar(200)
	--Declare @New_Shift_Name as varchar(200)
	--Declare @Old_for_Date as datetime
	--Declare @OldValue as varchar(max)
									
									
	--Set @Old_Emp_Id = 0 
	--Set @Old_Emp_Name  = ''
	--Set @Old_Grd_ID = 0
	--Set @Old_Shift_Name = ''
	--Set @New_Shift_Name = ''
	--Set @Old_for_Date = ''
	--Set @OldValue = ''
	
	IF ISNULL(@To_Date,'') = ''
		SET @To_Date = @For_Date								
									
	IF @tran_type  = 'I'
		BEGIN
			
			WHILE (@For_Date <= @To_Date)
				BEGIN
					
					
					IF EXISTS(SELECT Sal_tran_Id FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND Cmp_ID=@Cmp_ID AND 
								@For_Date >= Month_St_Date AND @For_Date <= Month_End_Date)
						BEGIN
							RAISERROR('@@This Months Salary Exists.So You Can not Change Grade.@@',16,2)
							RETURN -1
						END
					ELSE
						BEGIN
							IF EXISTS(SELECT Emp_ID FROM T0100_EMP_GRADE_DETAIL WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND For_Date= @For_Date)-- AND Grd_id = @Grd_ID) ''Commented by Ramiz as their was a requirement to Update same Date Record , if new grade is assigned
								BEGIN 
									--RAISERROR('@@Grade Details Already Exist For This Date@@',16,2) 
									--RETURN
									 
									UPDATE	T0100_EMP_GRADE_DETAIL
									SET		Grd_id = @Grd_ID ,
											OT_Grd_ID = @OT_Grd_ID
									WHERE	Emp_ID = @Emp_ID AND For_Date= @For_Date --AND Grd_id = @Grd_ID
								END
							ELSE
								BEGIN	
									SELECT @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 	FROM T0100_EMP_GRADE_DETAIL WITH (NOLOCK)
									
									INSERT INTO T0100_EMP_GRADE_DETAIL
											   (Tran_ID, Emp_ID, Cmp_ID, Grd_ID, OT_Grd_ID , For_Date , System_Date)
									VALUES     (@Tran_ID, @Emp_ID, @Cmp_ID, @Grd_ID, @OT_Grd_ID , @For_Date , GETDATE())
								END
					
							--Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')  from T0080_EMP_MASTER where Emp_ID = @Emp_ID)
							--Set @Old_Shift_Name = (select Shift_Name from T0040_SHIFT_MASTER where Grd_ID = @Grd_ID  AND Cmp_ID = @Cmp_ID)
							
							--set @OldValue = 'New Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'') 
							--		+ '#' + 'Shift Name :' + ISNULL(@Old_Shift_Name,'') 												
							--		+ '#' + 'Shift Type :' + CASE ISNULL(@Shift_type,0) WHEN 0 THEN 'Regular' ELSE 'Temporary' END
							--		+ '#' + 'For date :' + cast(ISNULL(@For_Date,'') as nvarchar(11)) 
							--exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Shift Change',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1 
												
						END
						
					SET @For_Date = DATEADD(DAY,1,@For_Date)
					
				END
			
			
		END
	
	ELSE IF @Tran_Type = 'D'
		BEGIN
			SELECT @Emp_ID = Emp_ID, @For_Date = For_Date FROM T0100_EMP_GRADE_DETAIL WITH (NOLOCK) WHERE Tran_ID = @Tran_ID 
			
			IF EXISTS(SELECT Sal_tran_Id FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID=@Emp_ID AND 
						@For_Date >= Month_St_Date AND @For_Date <= Month_End_Date)
				BEGIN
					RAISERROR('@@This Months Salary Exists.So You Cant Delete This Record.@@',16,2)
					RETURN -1
				END
			ELSE
				BEGIN
					--Select 
					--@Old_Emp_Id = Emp_ID
					--,@Old_Grd_ID =Grd_ID
					--,@Old_for_Date = For_Date
					--,@Old_Shift_Type = Shift_Type
					--from T0100_EMP_GRADE_DETAIL 
					--Where Tran_ID = @Tran_ID 
					
					--Set @Old_Emp_Name = (Select ISNULL(Alpha_Emp_Code,'') + ' - ' + ISNULL(Emp_Full_Name,'')  from T0080_EMP_MASTER where Emp_ID = @Old_Emp_Id)
					--Set @Old_Shift_Name = (select Shift_Name from T0040_SHIFT_MASTER where Grd_ID = @Old_Grd_ID  AND Cmp_ID = @Cmp_ID)
					
					--set @OldValue = 'old Value' + '#'+ 'Employee Name :' + ISNULL( @Old_Emp_Name,'') 
					--		+ '#' + 'Shift Name :' + ISNULL(@Old_Shift_Name,'') 												
					--		+ '#' + 'Shift Type :' + CASE ISNULL(@Old_Shift_Type,0) WHEN 0 THEN 'Regular' ELSE 'Temporary' END
					--		+ '#' + 'For date :' + cast(ISNULL(@Old_for_Date,'') as nvarchar(11)) 
					--exec P9999_Audit_Trail @Cmp_ID,@tran_type,'Shift Change',@Oldvalue,@Emp_ID,@User_Id,@IP_Address,1 
		
					DELETE FROM T0100_EMP_GRADE_DETAIL WHERE Tran_ID = @Tran_ID 
				END
		END
		
RETURN



