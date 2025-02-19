

-- =============================================
-- Author:		SHAIKH RAMIZ
-- Create date: 10082016
-- Description:	Created For Import file of SALES TARGET
-- =============================================
CREATE PROCEDURE [dbo].[P0050_Sales_Assigned_Target_Import]  
	@Tran_Id			Numeric(18,0) Output ,
	@Cmp_ID				Numeric(9),
	@Branch_Name		Varchar(100),
	@Sales_Code			Varchar(100),
	@Target_Month		Numeric(4) = 0,
	@Target_Year		Numeric(4) = 0,
	@Route_Name			Varchar(100) = '',
	@Route_Type			Varchar(50) = '',
	@First_WK_TRGT		Numeric(18,2),
	@First_WK_ACHV		Numeric(18,2),
	@Second_WK_TRGT		Numeric(18,2),
	@Second_WK_ACHV		Numeric(18,2),
	@Third_WK_TRGT		Numeric(18,2),
	@Third_WK_ACHV		Numeric(18,2),
	@Fourth_WK_TRGT		Numeric(18,2),
	@Fourth_WK_ACHV		Numeric(18,2),
	@Fifth_WK_TRGT		Numeric(18,2),
	@Fifth_WK_ACHV		Numeric(18,2),
	@Monthly_TRGT		Numeric(18,2),
	@Monthly_ACHV		Numeric(18,2),
	@Tran_Type			Char(1) = 'I',
	@Log_Status		Int = 0 Output
AS
		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

DECLARE @MAX_TRAN_ID	NUMERIC(18,0)
DECLARE @EMP_ID			NUMERIC(18,0)
DECLARE @ROUTE_ID		NUMERIC(18,0)
DECLARE @Branch_ID		NUMERIC(18,0)
DECLARE @WEEK_TRAN_ID   NUMERIC(18,0)
DECLARE @PERCENT_TRGT	NUMERIC(18,0)

	SET @MAX_TRAN_ID = 0
	SET @EMP_ID = 0
	SET @ROUTE_ID = 0
	SET @Branch_ID = 0
	SET @WEEK_TRAN_ID = 0
	SET @PERCENT_TRGT = 0
	
	
BEGIN
	If @Target_Month Is NULL
		Set @Target_Month = 0	
		
	If @Target_Year Is NULL
		Set @Target_Year = 0

		IF @TRAN_TYPE = 'I'
			BEGIN
				SET @EMP_ID = 0
				SET @TRAN_ID = 0
				
				IF @Route_Name = '' and @Route_Type = ''
					BEGIN
						SET @ROUTE_ID = 0
						SELECT @Branch_ID = ISNULL(Branch_ID,0) From T0030_BRANCH_MASTER WITH (NOLOCK) where Branch_Name = @Branch_Name and Cmp_ID = @Cmp_ID
					END
				ELSE
					BEGIN
						SELECT @ROUTE_ID = ISNULL(ROUTE_ID,0) From T0040_Sales_Route_Master WITH (NOLOCK) where Route_Name = @Route_Name and Route_Type = @Route_Type and Cmp_ID = @Cmp_ID 
						SELECT @Branch_ID = ISNULL(Branch_ID,0) From T0030_BRANCH_MASTER WITH (NOLOCK) where Branch_Name = @Branch_Name and Cmp_ID = @Cmp_ID
					END

				--if @Emp_ID = 0
				--	Begin
				--		SET @Log_Status = 1
				--		Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@Sales_Code,'Sales Code Doesn''t exists',@Alpha_Emp_Code,'Employee Doesn''t exists',GetDate(),'Sales Assigned Target',0)
				--		return
				--		--RAISERROR('Employee Doesn''t exists' , 16 , 2)
				--		--RETURN
				--	End
					
				if @Target_Month = 0
					Begin
						--SET @Log_Status = 1
						--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@Alpha_Emp_Code,'Enter Valid Month Details',@Alpha_Emp_Code,'Enter Valid Month Details',GetDate(),'Sales Assigned Target',0)
						--return
						RAISERROR('Enter Valid Month Details' , 16 , 2)
						RETURN
					End
				
				if @Target_Year = 0
					Begin
						--SET @Log_Status = 1
						--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@Alpha_Emp_Code,'Enter Valid Year Details',@Alpha_Emp_Code,'Enter Valid Year Details',GetDate(),'Sales Assigned Target',0)
						--return
						RAISERROR('Enter Valid Year Details' , 16 , 2)
						RETURN
					End
					
				if @ROUTE_ID = 0 AND @Route_Name <> '' AND @Route_Type <> ''
					BEGIN
						--SET @Log_Status = 1
						--Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@Alpha_Emp_Code,'Enter Valid Year Details',@Alpha_Emp_Code,'Enter Valid Year Details',GetDate(),'Sales Assigned Target',0)
						--return
						RAISERROR('Enter Valid Route Name' , 16 , 2)
						RETURN
					END
					
			IF NOT EXISTS (Select 1 from T0040_Sales_Assigned_Target WITH (NOLOCK) where Sales_Code = @Sales_Code and Branch_ID = @Branch_ID and Route_ID = @ROUTE_ID and Target_Month = @Target_Month and Target_Year = @Target_Year and @ROUTE_ID <> 0)
				BEGIN
					SELECT @Max_Tran_Id = Isnull(max(Target_Tran_ID),0) + 1 From T0040_Sales_Assigned_Target WITH (NOLOCK)
					SET @TRAN_ID = @MAX_TRAN_ID
					
					INSERT INTO T0040_Sales_Assigned_Target
					(
						Target_Tran_ID,Cmp_ID,Branch_ID,Sales_Code,Route_ID,Target_Month,Target_Year
					)
					SELECT	@Max_Tran_Id,@Cmp_Id , @Branch_ID , @Sales_Code , @ROUTE_ID , @Target_Month , @Target_Year
					
					--INSERT INTO T0040_Sales_Assigned_Target
					--(
					--	Target_Tran_ID,Emp_ID,Cmp_ID,Branch_ID,Branch_Name,Desig_ID,Desig_Name,Dept_ID,Dept_Name,Grd_ID,Grd_Name,Cat_ID,Cat_Name,Route_ID,Target_Month,Target_Year
					--)
					--SELECT	@Max_Tran_Id,I.Emp_ID, I.Cmp_ID, I.Branch_ID, BM.Branch_Name,I.Desig_ID, DGM.Desig_Name,I.Dept_ID, DM.Dept_Name, I.Grd_ID, GM.Grd_Name,
					--		  I.Cat_ID, CM.Cat_Name ,@ROUTE_ID, @Target_Month, @Target_Year
					--FROM	T0095_INCREMENT I 
					--INNER JOIN (SELECT	MAX(INCREMENT_ID) AS INCREMENT_ID, I1.Emp_ID
					--				FROM	T0095_INCREMENT I1
					--						INNER JOIN (
					--									SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I2.EMP_ID
					--									FROM	T0095_INCREMENT I2
					--									WHERE	I2.INCREMENT_EFFECTIVE_DATE <= GETDATE() AND I2.Emp_ID=@Emp_ID AND I2.CMP_ID=@Cmp_ID
					--									GROUP BY I2.EMP_ID
					--									) I2 ON I1.EMP_ID=I2.EMP_ID AND I1.INCREMENT_EFFECTIVE_DATE=I2.INCREMENT_EFFECTIVE_DATE
					--				WHERE	I1.Increment_Effective_Date <= GETDATE() AND I1.Emp_ID=@Emp_ID AND I1.CMP_ID=@Cmp_ID
					--				GROUP BY I1.Emp_ID
					--			) I1 ON I.INCREMENT_ID = I1.INCREMENT_ID
					--INNER JOIN     	T0030_BRANCH_MASTER BM ON I.BRANCH_ID = BM.BRANCH_ID and BM.CMp_ID=I.Cmp_ID 	
					--INNER JOIN		T0040_GRADE_MASTER GM ON I.Grd_ID = GM.Grd_ID AND GM.Cmp_ID=I.Cmp_ID 
					--LEFT OUTER JOIN	T0040_TYPE_MASTER ETM ON I.Type_ID = ETM.Type_ID AND ETM.CMp_ID=I.Cmp_ID 
					--LEFT OUTER JOIN	T0040_DESIGNATION_MASTER DGM ON I.Desig_Id = DGM.Desig_Id AND DGM.Cmp_ID=I.Cmp_ID 
					--LEFT OUTER JOIN	T0040_DEPARTMENT_MASTER DM ON I.Dept_Id = DM.Dept_Id AND DM.Cmp_Id=I.Cmp_ID 
					--LEFT OUTER JOIN T0030_CATEGORY_MASTER CM ON I.Cat_ID = CM.Cat_ID AND CM.Cmp_ID = I.Cmp_ID
					--WHERE	I.Increment_Effective_Date <= GETDATE() AND I.Emp_ID=@Emp_ID AND I.CMP_ID=@Cmp_ID
				END
			ELSE
				BEGIN
					SET @TRAN_ID = 0
					SELECT @TRAN_ID = ISNULL(TARGET_TRAN_ID,0) From T0040_Sales_Assigned_Target WITH (NOLOCK) WHERE Sales_Code = @Sales_Code And Route_ID = @ROUTE_ID 
									  And Target_Month = @Target_Month and Target_Year = @Target_Year 
					--If That Data is Already Exists then that will be Deleted and new Data will be Inserted for that Employee
					DELETE FROM T0050_SALES_ASSIGNED_DETAIL WHERE TARGET_TRAN_ID = @TRAN_ID
				END	
					
					
					--FIRST WEEK TARGET ENTRY
						IF @First_WK_TRGT <> 0 and @First_WK_ACHV <> 0
							BEGIN
								SELECT @Week_Tran_ID = ISNULL(Week_Tran_ID,0) FROM dbo.T0040_Sales_Week_Master WITH (NOLOCK) WHERE W_Month = @Target_Month AND W_Year = @Target_Year AND Cmp_ID = @CMP_ID AND WEEK_ORDER = 'First Week'
								SET @PERCENT_TRGT = ((@First_WK_ACHV * 100)/@First_WK_TRGT)
								IF @Week_Tran_ID <> 0
									BEGIN
										INSERT INTO T0050_Sales_Assigned_Detail(Cmp_ID , Target_Tran_ID , Week_Tran_ID , Assigned_Target , Achieved_Target , Achieved_Percent)
										VALUES (@CMP_ID , @TRAN_ID , @Week_Tran_ID , @First_WK_TRGT , @First_WK_ACHV , @PERCENT_TRGT)
									END
								ELSE
									BEGIN
										RAISERROR('First Week is not Created' , 16 , 2)
										RETURN
									END
										
								SET @WEEK_TRAN_ID = 0
								SET @PERCENT_TRGT = 0
							END
					
					--SECOND WEEK TARGET ENTRY	
						IF @Second_WK_TRGT <> 0 and @Second_WK_ACHV <> 0
							BEGIN
								SELECT @Week_Tran_ID = ISNULL(Week_Tran_ID,0) FROM dbo.T0040_Sales_Week_Master WITH (NOLOCK) WHERE W_Month = @Target_Month AND W_Year = @Target_Year AND Cmp_ID = @CMP_ID AND WEEK_ORDER = 'Second Week'
								SET @PERCENT_TRGT = ((@Second_WK_ACHV * 100)/@Second_WK_TRGT)
								IF @Week_Tran_ID <> 0
									BEGIN
										INSERT INTO T0050_Sales_Assigned_Detail(Cmp_ID , Target_Tran_ID , Week_Tran_ID , Assigned_Target , Achieved_Target , Achieved_Percent)
										VALUES (@CMP_ID , @TRAN_ID , @Week_Tran_ID , @Second_WK_TRGT , @Second_WK_ACHV , @PERCENT_TRGT)
									END
								ELSE
									BEGIN
										RAISERROR('Second Week is not Created' , 16 , 2)
										RETURN
									END
										
								SET @WEEK_TRAN_ID = 0
								SET @PERCENT_TRGT = 0
							END
					
					--THIRD WEEK TARGET ENTRY	
						IF @Third_WK_TRGT <> 0 and @Third_WK_ACHV <> 0
							BEGIN
						
								SELECT @Week_Tran_ID = ISNULL(Week_Tran_ID,0) FROM dbo.T0040_Sales_Week_Master WITH (NOLOCK) WHERE W_Month = @Target_Month AND W_Year = @Target_Year AND Cmp_ID = @CMP_ID AND WEEK_ORDER = 'Third Week'
								SET @PERCENT_TRGT = ((@Third_WK_ACHV * 100)/@Third_WK_TRGT)
								
								IF @Week_Tran_ID <> 0
									BEGIN
										INSERT INTO T0050_Sales_Assigned_Detail(Cmp_ID , Target_Tran_ID , Week_Tran_ID , Assigned_Target , Achieved_Target , Achieved_Percent)
										VALUES (@CMP_ID , @TRAN_ID , @Week_Tran_ID , @Third_WK_TRGT , @Third_WK_ACHV , @PERCENT_TRGT)
									END
								ELSE
									BEGIN
										RAISERROR('Third Week is not Created' , 16 , 2)
										RETURN
									END
									
								SET @WEEK_TRAN_ID = 0
								SET @PERCENT_TRGT = 0
							END
					
					--FOURTH WEEK TARGET ENTRY	
						IF @Fourth_WK_TRGT <> 0 and @Fourth_WK_ACHV <> 0
							BEGIN
								SELECT @Week_Tran_ID = ISNULL(Week_Tran_ID,0) FROM dbo.T0040_Sales_Week_Master WITH (NOLOCK) WHERE W_Month = @Target_Month AND W_Year = @Target_Year AND Cmp_ID = @CMP_ID AND WEEK_ORDER = 'Fourth Week'
								SET @PERCENT_TRGT = ((@Fourth_WK_ACHV * 100)/@Fourth_WK_TRGT)
								
								IF @Week_Tran_ID <> 0
									BEGIN
										INSERT INTO T0050_Sales_Assigned_Detail(Cmp_ID , Target_Tran_ID , Week_Tran_ID , Assigned_Target , Achieved_Target , Achieved_Percent)
										VALUES (@CMP_ID , @TRAN_ID , @Week_Tran_ID , @Fourth_WK_TRGT , @Fourth_WK_ACHV , @PERCENT_TRGT)
									END
								ELSE
									BEGIN
										RAISERROR('Fourth Week is not Created' , 16 , 2)
										RETURN
									END
										
								SET @WEEK_TRAN_ID = 0
								SET @PERCENT_TRGT = 0
							END	
					
					--FIFTH WEEK TARGET ENTRY	
						IF @Fifth_WK_TRGT <> 0 and @Fifth_WK_ACHV <> 0
							BEGIN
								SELECT @Week_Tran_ID = ISNULL(Week_Tran_ID,0) FROM dbo.T0040_Sales_Week_Master WITH (NOLOCK) WHERE W_Month = @Target_Month AND W_Year = @Target_Year AND Cmp_ID = @CMP_ID AND WEEK_ORDER = 'Fifth Week'
								SET @PERCENT_TRGT = ((@Fifth_WK_ACHV * 100)/@Fifth_WK_TRGT)
								
								IF @Week_Tran_ID <> 0
									BEGIN
										INSERT INTO T0050_Sales_Assigned_Detail(Cmp_ID , Target_Tran_ID , Week_Tran_ID , Assigned_Target , Achieved_Target , Achieved_Percent)
										VALUES (@CMP_ID , @TRAN_ID , @Week_Tran_ID , @Fifth_WK_TRGT , @Fifth_WK_ACHV , @PERCENT_TRGT)
									END
								ELSE
									BEGIN
										RAISERROR('Fifth Week is not Created' , 16 , 2)
										RETURN
									END	
								SET @WEEK_TRAN_ID = 0
								SET @PERCENT_TRGT = 0
							END
					
					--MONTHLY TARGET ENTRY
						IF @Monthly_TRGT <> 0 and @Monthly_ACHV <> 0
							BEGIN
								SELECT @Week_Tran_ID = ISNULL(Week_Tran_ID,0) FROM dbo.T0040_Sales_Week_Master WITH (NOLOCK) WHERE W_Month = @Target_Month AND W_Year = @Target_Year AND Cmp_ID = @CMP_ID AND WEEK_ORDER = 'Monthly'
								SET @PERCENT_TRGT = ((@Monthly_ACHV * 100)/@Monthly_TRGT)
			
								IF @Week_Tran_ID <> 0
									BEGIN
										INSERT INTO T0050_Sales_Assigned_Detail(Cmp_ID , Target_Tran_ID , Week_Tran_ID , Assigned_Target , Achieved_Target , Achieved_Percent)
										VALUES (@CMP_ID , @TRAN_ID , @Week_Tran_ID , @Monthly_TRGT , @Monthly_ACHV , @PERCENT_TRGT)
									END
								ELSE
									BEGIN
										RAISERROR('Monthly not Created' , 16 , 2)
										RETURN
									END	
									
								SET @WEEK_TRAN_ID = 0
								SET @PERCENT_TRGT = 0
							END
							
						RETURN @TRAN_ID	
				END
END




