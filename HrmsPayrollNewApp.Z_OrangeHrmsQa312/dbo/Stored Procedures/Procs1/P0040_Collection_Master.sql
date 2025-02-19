

 ---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE  [dbo].[P0040_Collection_Master]      
@Collection_ID NUMERIC output,
@CollectionMonth varchar(50),
@CollectionYear numeric(18,0),
@Manager_ID numeric(18,0),
@Details XML,
--@Project_ID numeric(18,2),
--@Service_Type varchar(50),
--@Contract_Type varchar(50),
--@Practice_Collection numeric(18,2),
--@Charges_Per numeric(18,2), 
--@Fedora_Charges numeric(18,2), 
--@Exchange_Rate numeric(18,2), 
--@Total_Fedora_Charges numeric(18,2),
--@Other_Remarks varchar(100),
@Cmp_ID numeric(18,0),       
@Created_By numeric(18,0),       
@Trans_Type varchar(1)      
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


DECLARE @Collection_Detail_ID numeric
DECLARE @Project numeric
DECLARE @Service varchar(50)
DECLARE @Contract varchar(50)
DECLARE @FCharges varchar(50)
DECLARE @PCollection varchar(50)
DECLARE @TCharges varchar(50)
DECLARE @ERate varchar(50)
DECLARE @TFedoracharges varchar(50)
DECLARE @ORemarks varchar(50)
DECLARE @OInvoice int
DECLARE @OPayment int


	If @Trans_Type  = 'I'      
		BEGIN
			If Exists (SELECT Collection_ID FROM T0040_Collection_Master WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND UPPER(CollectionMonth) = UPPER(@CollectionMonth) AND CollectionYear = @CollectionYear AND Manager_ID = @Manager_ID )      
			 BEGIN      
			  SET @Collection_ID = 0      
			  RETURN      
			 END      
			--INSERT INTO T0040_Collection_Master(Collection_ID,CollectionMonth,CollectionYear,Project_ID,Service_Type,Contract_Type,Practice_Collection,Charges_Per,Fedora_Charges,Exchange_Rate,Total_Fedora_Charges,Other_Remarks,Cmp_ID,Created_By,Created_Date)VALUES      
			--(@Collection_ID,@CollectionMonth,@CollectionYear,@Project_ID,@Service_Type,@Contract_Type,@Practice_Collection,@Charges_Per,@Fedora_Charges,@Exchange_Rate,@Total_Fedora_Charges,@Other_Remarks,@Cmp_ID,@Created_By,GETDATE() )      
			
			SELECT @Collection_ID = ISNULL(MAX(Collection_ID), 0) + 1 FROM T0040_Collection_Master WITH (NOLOCK)
			INSERT INTO T0040_Collection_Master(Collection_ID,CollectionMonth,CollectionYear,Manager_ID,Cmp_ID,Created_By,Created_Date)
			VALUES(@Collection_ID,@CollectionMonth,@CollectionYear,@Manager_ID,@Cmp_ID,@Created_By,GETDATE())
			
			select Table1.value('(Project_ID/text())[1]','numeric(18,0)') as Project_ID,
			Table1.value('(Project_Name/text())[1]','varchar(50)') as Project_Name,
			Table1.value('(ServiceType/text())[1]','varchar(50)') as ServiceType,
			Table1.value('(ContractType/text())[1]','varchar(50)') as ContractType,
			Table1.value('(FedoraCharges/text())[1]','varchar(50)') as FedoraCharges,
			Table1.value('(PracticeCollection/text())[1]','varchar(50)') as PracticeCollection,
			Table1.value('(TotalCharges/text())[1]','varchar(50)') as TotalCharges,
			Table1.value('(ExchangeRate/text())[1]','varchar(50)') as ExchangeRate,
			Table1.value('(TotalFedoracharges/text())[1]','varchar(50)') as TotalFedoracharges,
			Table1.value('(Remarks/text())[1]','varchar(100)') as Remarks,
			Table1.value('(Invoice/text())[1]','int') as Invoice,
			Table1.value('(Payment/text())[1]','int') as Payment
			into #ICollection from @Details.nodes('/Collection/Table1')  as Temp(Table1)
			
			DECLARE ICOLLECTION_CURSOR CURSOR  Fast_forward FOR
			SELECT Project_ID,ServiceType,ContractType,FedoraCharges,PracticeCollection,TotalCharges,ExchangeRate,TotalFedoracharges,Remarks,Invoice,Payment from #ICollection
			OPEN ICOLLECTION_CURSOR
			FETCH NEXT FROM ICOLLECTION_CURSOR INTO @Project,@Service,@Contract,@FCharges,@PCollection,@TCharges,@ERate,@TFedoracharges,@ORemarks,@OInvoice,@OPayment
			while @@fetch_status = 0
				Begin
					SELECT @Collection_Detail_ID = ISNULL(MAX(Collection_Detail_ID), 0) + 1 FROM T0050_Collection_Details WITH (NOLOCK)
					
					INSERT INTO T0050_Collection_Details(Collection_Detail_ID,Collection_ID,Project_ID,Service_Type,Contract_Type,FedoraCharges,
					Practice_Collection,TotalCharges,Exchange_Rate,Total_Fedora_Charges, Other_Remarks,Invoice,Payment)
					VALUES(@Collection_Detail_ID,@Collection_ID,@Project,@Service,@Contract,@FCharges,@PCollection,@TCharges,@ERate,@TFedoracharges,@ORemarks,@OInvoice,@OPayment) 
					
					FETCH NEXT FROM ICOLLECTION_CURSOR INTO @Project,@Service,@Contract,@FCharges,@PCollection,@TCharges,@ERate,@TFedoracharges,@ORemarks,@OInvoice,@OPayment
				End
			CLOSE ICOLLECTION_CURSOR     
			DEALLOCATE ICOLLECTION_CURSOR
		END
	ELSE IF @Trans_Type = 'U'      
		BEGIN
		 
			--If Exists (SELECT Collection_ID FROM T0040_Collection_Master WHERE Cmp_ID = @Cmp_ID AND UPPER(Month) = UPPER(@Month) AND Collection_ID <> @Collection_ID)      
			-- BEGIN       
			--  SET @Collection_ID = 0      
			--  Return      
			-- END      
			--UPDATE T0040_Collection_Master SET CollectionMonth = @CollectionMonth,CollectionYear = @CollectionYear,Project_ID = @Project_ID,Service_Type = @Service_Type,
			--Contract_Type=@Contract_Type,Practice_Collection=@Practice_Collection,Charges_Per= @Charges_Per,Fedora_Charges=@Fedora_Charges,
			--Exchange_Rate =@Exchange_Rate,Total_Fedora_Charges=@Total_Fedora_Charges,Other_Remarks = @Other_Remarks,Cmp_ID = @Cmp_ID,Modify_By = @Created_By,Modify_Date = GETDATE()       
			--WHERE Collection_ID = @Collection_ID
			UPDATE T0040_Collection_Master SET CollectionMonth = @CollectionMonth,CollectionYear = @CollectionYear,
			Manager_ID = @Manager_ID,Cmp_ID = @Cmp_ID,Modify_By = @Created_By,Modify_Date = GETDATE()
			WHERE Collection_ID = @Collection_ID
			
			DELETE FROM T0050_Collection_Details WHERE Collection_ID = @Collection_ID
			
			select Table1.value('(Project_ID/text())[1]','numeric(18,0)') as Project_ID,
			Table1.value('(Project_Name/text())[1]','varchar(50)') as Project_Name,
			Table1.value('(ServiceType/text())[1]','varchar(50)') as ServiceType,
			Table1.value('(ContractType/text())[1]','varchar(50)') as ContractType,
			Table1.value('(FedoraCharges/text())[1]','varchar(50)') as FedoraCharges,
			Table1.value('(PracticeCollection/text())[1]','varchar(50)') as PracticeCollection,
			Table1.value('(TotalCharges/text())[1]','varchar(50)') as TotalCharges,
			Table1.value('(ExchangeRate/text())[1]','varchar(50)') as ExchangeRate,
			Table1.value('(TotalFedoracharges/text())[1]','varchar(50)') as TotalFedoracharges,
			Table1.value('(Remarks/text())[1]','varchar(100)') as Remarks,
			Table1.value('(Invoice/text())[1]','int') as Invoice,
			Table1.value('(Payment/text())[1]','int') as Payment
			into #UCollection from @Details.nodes('/Collection/Collection1')  as Temp(Table1)
			
			DECLARE UCOLLECTION_CURSOR CURSOR  Fast_forward FOR
			SELECT Project_ID,ServiceType,ContractType,FedoraCharges,PracticeCollection,TotalCharges,ExchangeRate,TotalFedoracharges,Remarks,Invoice,Payment  from #UCollection
			OPEN UCOLLECTION_CURSOR
			FETCH NEXT FROM UCOLLECTION_CURSOR INTO @Project,@Service,@Contract,@FCharges,@PCollection,@TCharges,@ERate,@TFedoracharges,@ORemarks,@OInvoice,@OPayment
			while @@fetch_status = 0
				BEGIN
					SELECT @Collection_Detail_ID = ISNULL(MAX(Collection_Detail_ID), 0) + 1 FROM T0050_Collection_Details WITH (NOLOCK)
					
					INSERT INTO T0050_Collection_Details(Collection_Detail_ID,Collection_ID,Project_ID,Service_Type,Contract_Type,FedoraCharges,
					Practice_Collection,TotalCharges,Exchange_Rate,Total_Fedora_Charges, Other_Remarks,Invoice,Payment)
					VALUES(@Collection_Detail_ID,@Collection_ID,@Project,@Service,@Contract,@FCharges,@PCollection,@TCharges,@ERate,@TFedoracharges,@ORemarks,@OInvoice,@OPayment ) 
					FETCH NEXT FROM UCOLLECTION_CURSOR INTO @Project,@Service,@Contract,@FCharges,@PCollection,@TCharges,@ERate,@TFedoracharges,@ORemarks,@OInvoice,@OPayment 
				END
			CLOSE UCOLLECTION_CURSOR     
			DEALLOCATE UCOLLECTION_CURSOR
		END
	ELSE IF @Trans_Type = 'D'      
		BEGIN
		DELETE FROM T0050_Collection_Details WHERE Collection_ID = @Collection_ID
			DELETE FROM T0040_Collection_Master WHERE Collection_ID = @Collection_ID
		END



