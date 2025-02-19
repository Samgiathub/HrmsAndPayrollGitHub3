
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_Attribute_Skill_Detail]
	@Tran_Id AS NUMERIC OUTPUT,
	@CMP_ID AS NUMERIC,
	@Designation_ID AS VARCHAR(MAX),		
	@Skill_Weightage AS NUMERIC(18,2),
	@Attr_Weightage AS NUMERIC(18,2),	
	@Effective_Date AS DATETIME,
	@Skill_Detail VARCHAR(MAX),
	@Attribute_Detail VARCHAR(MAX),
	@Type AS NUMERIC(18,0),--Mukti(01122017) 0 for Probation,1 for Trainee
	@Assignment_Type varchar(15),
	@tran_type VARCHAR(1)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	DECLARE @Row_ID NUMERIC(18,0)
	DECLARE @Skill_ID NUMERIC(18,0) 
	DECLARE @Skill_Amount NUMERIC(18,2) 
	DECLARE @Attribute_ID NUMERIC(18,0) 
	DECLARE @Attribute_Amount NUMERIC(18,2)
	DECLARE @Skill_ID1 NUMERIC(18,0)
	DECLARE @Attribute_ID1 NUMERIC(18,0)
	DECLARE @Desig_Id	NUMERIC(18,0)
	--DECLARE @Dept_Id NUMERIC(18,0)
	DECLARE @OldValue as varchar(MAX) = ''
	
	IF @tran_type  = 'I'
		BEGIN

			DECLARE Desi_Cur CURSOR FOR 
				SELECT Data FROM dbo.Split(@Designation_ID,'#')
			OPEN Desi_Cur 
			FETCH NEXT FROM Desi_Cur INTO @Desig_Id
			WHILE @@FETCH_STATUS = 0
			BEGIN
			
				IF @Assignment_Type ='DesignationWise'
					BEGIN
						IF EXISTS (SELECT 1 FROM T0100_EMP_SKILL_ATTR_ASSIGN WITH (NOLOCK) WHERE Cmp_ID = @CMP_ID AND Effect_Date = @Effective_Date AND Desig_Id = @Desig_Id and [Type] = @Type) 
									BEGIN								
										SELECT @Tran_Id  = tran_Id	FROM T0100_EMP_SKILL_ATTR_ASSIGN WITH (NOLOCK) WHERE Cmp_ID = @CMP_ID AND Effect_Date = @Effective_Date AND Desig_Id = @Desig_Id and [Type] = @Type
										
										UPDATE T0100_EMP_SKILL_ATTR_ASSIGN
										SET Desig_Id=@Desig_Id
											,Skill_Weightage = @Skill_Weightage
											,Attr_Weightage = @Attr_Weightage
											,Effect_Date = @Effective_Date
										WHERE tran_Id = @Tran_Id
										
									 DELETE FROM T0110_SKILL_WEIGHTAGE WHERE TRAN_ID = @TRAN_ID
									 DELETE FROM T0110_ATTRIBUTE_WEIGHTAGE  WHERE TRAN_ID = @TRAN_ID									
									END
								ELSE
									BEGIN
										
										SELECT @Tran_Id = ISNULL(MAX(tran_Id),0) + 1 	FROM t0100_emp_Skill_Attr_Assign WITH (NOLOCK)
										INSERT INTO T0100_EMP_SKILL_ATTR_ASSIGN(tran_Id,cmp_ID,Effect_date,Desig_Id,Skill_Weightage,Attr_Weightage,[Type],Dept_Id)
										VALUES     (@Tran_Id,@CMP_ID,@Effective_Date,@Desig_Id,@Skill_Weightage,@Attr_Weightage,@Type,NULL)
									END
					END
				ELSE
					BEGIN
						IF EXISTS (SELECT 1 FROM T0100_EMP_SKILL_ATTR_ASSIGN WITH (NOLOCK) WHERE Cmp_ID = @CMP_ID AND Effect_Date = @Effective_Date AND Dept_Id = @Desig_Id and [Type] = @Type) 
									BEGIN								
											SELECT @Tran_Id  = tran_Id	FROM T0100_EMP_SKILL_ATTR_ASSIGN WITH (NOLOCK) WHERE Cmp_ID = @CMP_ID AND Effect_Date = @Effective_Date AND Dept_Id = @Desig_Id and [Type] = @Type
											
											UPDATE T0100_EMP_SKILL_ATTR_ASSIGN
											SET Dept_Id=@Desig_Id
												,Skill_Weightage = @Skill_Weightage
												,Attr_Weightage = @Attr_Weightage
												,Effect_Date = @Effective_Date
											WHERE tran_Id = @Tran_Id
											
										 DELETE FROM T0110_SKILL_WEIGHTAGE WHERE TRAN_ID = @TRAN_ID
										 DELETE FROM T0110_ATTRIBUTE_WEIGHTAGE  WHERE TRAN_ID = @TRAN_ID									
									END
							ELSE
								BEGIN
									
									SELECT @Tran_Id = ISNULL(MAX(tran_Id),0) + 1 	FROM t0100_emp_Skill_Attr_Assign WITH (NOLOCK)
									INSERT INTO T0100_EMP_SKILL_ATTR_ASSIGN(tran_Id,cmp_ID,Effect_date,Desig_Id,Skill_Weightage,Attr_Weightage,[Type],Dept_Id)
									VALUES     (@Tran_Id,@CMP_ID,@Effective_Date,NULL,@Skill_Weightage,@Attr_Weightage,@Type,@Desig_Id)
								END
					END
						
						If @Skill_Detail <> '' 
						BEGIN  
							DECLARE Skill_Cursor CURSOR FOR 
								SELECT LEFT(DATA,CHARINDEX(',',DATA)-1), RIGHT(DATA,LEN(DATA)-CHARINDEX(',',DATA)) FROM dbo.Split(@Skill_Detail,'#')
							OPEN Skill_Cursor 
							FETCH NEXT FROM Skill_Cursor INTO @Skill_ID,@Skill_Amount
								WHILE @@FETCH_STATUS = 0
									BEGIN
									
										SELECT @Row_ID = ISNULL(MAX(Row_Id),0) + 1 FROM dbo.T0110_SKILL_WEIGHTAGE WITH (NOLOCK)
												 
										 INSERT INTO dbo.T0110_SKILL_WEIGHTAGE(Row_Id,Cmp_Id,Skill_Id,Tran_ID,Weightage)
										 VALUES(@Row_ID,@Cmp_Id,CAST(@Skill_ID AS NUMERIC(18,0)),@Tran_ID,CAST(@Skill_Amount AS NUMERIC(18,2)))
										 
										 FETCH NEXT FROM Skill_Cursor INTO @Skill_ID,@Skill_Amount
									END
							 CLOSE Skill_Cursor 
							 DEALLOCATE Skill_Cursor
							END
						 SET @Row_ID = 0       
				            
				        IF @Attribute_Detail <> ''
							BEGIN   
						       	 DECLARE Attribute_Cursor CURSOR FOR 
									SELECT LEFT(DATA,CHARINDEX(',',DATA)-1), RIGHT(DATA,LEN(DATA)-CHARINDEX(',',DATA)) FROM dbo.Split(@Attribute_Detail,'#')
								 OPEN Attribute_Cursor 
								 FETCH NEXT FROM Attribute_Cursor INTO @Attribute_ID,@Attribute_Amount
									WHILE @@FETCH_STATUS = 0
										BEGIN
											 SELECT @Row_ID = ISNULL(MAX(Row_Id),0) + 1 FROM dbo.T0110_Attribute_Weightage WITH (NOLOCK)
											 
											 INSERT INTO dbo.T0110_Attribute_Weightage(Row_Id,Cmp_Id,Attr_Id,Tran_ID,Weightage)
											 VALUES(@Row_ID,@Cmp_Id,CAST(@Attribute_ID AS NUMERIC(18,0)),@Tran_ID,CAST(@Attribute_Amount AS NUMERIC(18,2)))
											 
											 FETCH NEXT FROM Attribute_Cursor INTO @Attribute_ID,@Attribute_Amount
										END
								 CLOSE Attribute_Cursor 
								 DEALLOCATE Attribute_Cursor
							END
							
				FETCH NEXT FROM Desi_Cur INTO @Desig_Id
					END
			 CLOSE Desi_Cur 
			 DEALLOCATE Desi_Cur

		END
	ELSE IF @Tran_Type = 'U'
		BEGIN
				
				
			UPDATE T0100_EMP_SKILL_ATTR_ASSIGN
			SET Desig_Id=@Designation_ID
			    ,Skill_Weightage = @Skill_Weightage
			    ,Attr_Weightage = @Attr_Weightage
			    ,Effect_Date = @Effective_Date
			WHERE tran_Id = @Tran_Id				
				
			set @OldValue = 'New Value' + '#'+ 'Tran_ID :' + cast(ISNULL(@Tran_ID,0) as varchar(5)) 
					+ '#' + 'Designation_ID :' + cast(ISNULL(@Designation_ID,0) as varchar(50)) 
					+ '#' + 'Skill_Weightage :' + cast(isnull(@Skill_Weightage,0) as varchar(10)) 
					+ '#' + 'Attr_Weightage :' + cast(isnull(@Attr_Weightage,0) as varchar(20))  
					+ '#' + 'Effective_Date  :' + cast(isnull(@Effective_Date,0) as varchar(5)) 
					+ '#' + 'Skill_Detail  :' + cast(isnull(@Skill_Detail,0) as varchar(5)) 
					+ '#' + 'Attribute_Detail  :' + cast(isnull(@Attribute_Detail,0) as varchar(5)) 
					
             
             DELETE FROM T0110_SKILL_WEIGHTAGE WHERE TRAN_ID = @TRAN_ID
             DELETE FROM T0110_ATTRIBUTE_WEIGHTAGE  WHERE TRAN_ID = @TRAN_ID            
			 
			 If @Skill_Detail <> '' 
			 BEGIN            
				DECLARE Skill_Cursor CURSOR FOR SELECT LEFT(DATA,CHARINDEX(',',DATA)-1), RIGHT(DATA,LEN(DATA)-CHARINDEX(',',DATA)) FROM dbo.Split(@Skill_Detail,'#')
	               
				 OPEN Skill_Cursor 
				   FETCH NEXT FROM Skill_Cursor INTO @Skill_ID,@Skill_Amount
					WHILE @@FETCH_STATUS = 0
						BEGIN
							
							 SELECT @Row_ID = ISNULL(MAX(Row_Id),0) + 1 FROM dbo.T0110_SKILL_WEIGHTAGE WITH (NOLOCK)
							 
							 INSERT INTO dbo.T0110_SKILL_WEIGHTAGE(Row_Id,Cmp_Id,Skill_Id,Tran_ID,Weightage)
							 VALUES(@Row_ID,@Cmp_Id,CAST(@Skill_ID AS NUMERIC(18,0)),@Tran_ID,CAST(@Skill_Amount AS NUMERIC(18,2)))
							 
							 FETCH NEXT FROM Skill_Cursor INTO @Skill_ID,@Skill_Amount
						END
				 CLOSE Skill_Cursor 
				 DEALLOCATE Skill_Cursor
			 END
					
			 IF @Attribute_Detail <> ''
			 BEGIN              
				 DECLARE Attribute_Cursor CURSOR FOR 
						SELECT LEFT(DATA,CHARINDEX(',',DATA)-1), RIGHT(DATA,LEN(DATA)-CHARINDEX(',',DATA)) FROM dbo.Split(@Attribute_Detail,'#')
		               
						OPEN Attribute_Cursor 
							FETCH NEXT FROM Attribute_Cursor INTO @Attribute_ID,@Attribute_Amount
								WHILE @@FETCH_STATUS = 0
								BEGIN
								
								 SELECT @Row_ID = ISNULL(MAX(Row_Id),0) + 1 FROM dbo.T0110_Attribute_Weightage WITH (NOLOCK)
								 
								 INSERT INTO dbo.T0110_Attribute_Weightage(Row_Id,Cmp_Id,Attr_Id,Tran_ID,Weightage)
								 VALUES(@Row_ID,@Cmp_Id,CAST(@Attribute_ID AS NUMERIC(18,0)),@Tran_ID,CAST(@Attribute_Amount AS NUMERIC(18,2)))
								 
								 FETCH NEXT FROM Attribute_Cursor INTO @Attribute_ID,@Attribute_Amount
							END
					 CLOSE Attribute_Cursor 
					 DEALLOCATE Attribute_Cursor
		       END

			exec P9999_Audit_Trail @Cmp_ID,@Tran_Type,'Attribute Skill Details',@OldValue,0,0,0
		END
	ELSE IF @Tran_Type = 'D'
		BEGIN
			SELECT @Desig_Id=Desig_Id FROM t0100_emp_Skill_Attr_Assign WITH (NOLOCK) WHERE tran_Id = @Tran_Id 
			
			IF EXISTS(SELECT 1 from T0095_EMP_PROBATION_MASTER EP WITH (NOLOCK)
						INNER JOIN V0080_EMP_MASTER_INCREMENT_GET  EM on EP.Emp_ID=EM.Emp_ID
						INNER JOIN T0100_EMP_SKILL_ATTR_ASSIGN ES WITH (NOLOCK) ON EM.Desig_Id=ES.Desig_Id 
						WHERE EP.Cmp_ID=@CMP_ID AND ES.Desig_Id=@Desig_Id)
					BEGIN
						SET @Tran_Id=0
						RETURN 
					END
				DELETE FROM T0110_SKILL_WEIGHTAGE WHERE tran_Id = @Tran_Id 
				DELETE FROM T0110_Attribute_Weightage WHERE tran_Id = @Tran_Id 
				DELETE FROM t0100_emp_Skill_Attr_Assign WHERE tran_Id = @Tran_Id 				
		END

	RETURN




