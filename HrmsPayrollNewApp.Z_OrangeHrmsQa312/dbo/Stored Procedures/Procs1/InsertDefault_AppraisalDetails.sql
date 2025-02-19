

-- Created By Mukti on 01032018 for Insert Default Appraisal other Details
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- ===============================================================
CREATE PROCEDURE [dbo].[InsertDefault_AppraisalDetails] 
 @cmp_id as numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	if EXISTS(select AO_Id from T0030_Appraisal_OtherDetails WITH (NOLOCK) where Cmp_ID=@cmp_id)
		RETURN
	
	insert into T0030_Appraisal_OtherDetails(AO_Id,Cmp_ID,[Action],Desig_Required,From_Date_Required,To_Date_Required,Active)
	VALUES(1,@cmp_id,'Job enlargement (Additional responsibilities)',0,0,0,1)
	
	insert into T0030_Appraisal_OtherDetails(AO_Id,Cmp_ID,[Action],Desig_Required,From_Date_Required,To_Date_Required,Active)
	VALUES(2,@cmp_id,'Transfer',0,0,0,1)
	
	insert into T0030_Appraisal_OtherDetails(AO_Id,Cmp_ID,[Action],Desig_Required,From_Date_Required,To_Date_Required,Active)
	VALUES(3,@cmp_id,'Job Rotation',0,1,1,1)
	
	insert into T0030_Appraisal_OtherDetails(AO_Id,Cmp_ID,[Action],Desig_Required,From_Date_Required,To_Date_Required,Active)
	VALUES(4,@cmp_id,'Compensation Fitment',0,0,0,1)
	
	insert into T0030_Appraisal_OtherDetails(AO_Id,Cmp_ID,[Action],Desig_Required,From_Date_Required,To_Date_Required,Active)
	VALUES(5,@cmp_id,'Promotion to be given this year',1,1,0,1)
	
	insert into T0030_Appraisal_OtherDetails(AO_Id,Cmp_ID,[Action],Desig_Required,From_Date_Required,To_Date_Required,Active)
	VALUES(6,@cmp_id,'Improvement / Exit Plan (low performer)',0,0,0,1)
	
	insert into T0030_Appraisal_OtherDetails(AO_Id,Cmp_ID,[Action],Desig_Required,From_Date_Required,To_Date_Required,Active)
	VALUES(7,@cmp_id,'Increment to be given this year',0,0,0,1)
	
	insert into T0030_Appraisal_OtherDetails(AO_Id,Cmp_ID,[Action],Desig_Required,From_Date_Required,To_Date_Required,Active)
	VALUES(8,@cmp_id,'Any other',0,0,0,1)
	
	insert into T0030_Appraisal_OtherDetails(AO_Id,Cmp_ID,[Action],Desig_Required,From_Date_Required,To_Date_Required,Active)
	VALUES(9,@cmp_id,'Overall fitment in current Job Role',0,0,0,2)
	
	--insert into T0030_Appraisal_OtherDetails(AO_Id,Cmp_ID,[Action],Desig_Required,From_Date_Required,To_Date_Required,Active)
	--VALUES(10,@cmp_id,'Readiness to take up Higher Role',0,0,0,2)
END


