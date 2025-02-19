
--exec SP_MOBILE_HRMS_WEBSERVICE_UNISONMASTER 120,'SPORT',10

CREATE PROCEDURE [dbo].[SP_MOBILE_HRMS_WEBSERVICE_UNISONMASTER]               
		@Cmp_ID	INT
	   ,@MASTER VARCHAR(100)
	   ,@EMP_ID INT = 0	  
AS                    
BEGIN  
	IF(@MASTER = 'Sport')
		BEGIN	
			SELECT FS_ID,SPORT_NAME FROM T0040_FAV_SPORT_MASTER WHERE CMP_ID = @CMP_ID order by Sport_Name
			--SELECT FS_ID,SPORT_NAME FROM T0040_FAV_SPORT_MASTER WHERE CMP_ID = 120 order by Sport_Name
		END
	
	ELSE IF(@MASTER = 'Hobby')
			BEGIN
				SELECT H_ID,HobbyName FROM T0040_HOBBY_MASTER WHERE CMP_ID = @CMP_ID order by HobbyName
				--SELECT H_ID,HobbyName FROM T0040_HOBBY_MASTER WHERE CMP_ID = 120 order by HobbyName
			END
	
	ELSE IF(@MASTER = 'Occupation')
			BEGIN
				SELECT O_ID,Occupation_Name FROM T0040_OCCUPATION_MASTER WHERE CMP_ID = @CMP_ID	order by Occupation_Name
				--SELECT O_ID,Occupation_Name FROM T0040_OCCUPATION_MASTER WHERE CMP_ID = 120	order by Occupation_Name
			END

	ELSE IF(@MASTER = 'Standard')
			BEGIN
				SELECT S_ID,StandardName FROM T0040_DEP_STANDARD_MASTER WHERE CMP_ID = @CMP_ID order by Seq
			END
	ELSE IF(@MASTER = 'Relationship')
			BEGIN
				SELECT Relationship_ID,Relationship FROM T0040_Relationship_Master WHERE CMP_ID = @CMP_ID	order by Relationship
			END
END        
