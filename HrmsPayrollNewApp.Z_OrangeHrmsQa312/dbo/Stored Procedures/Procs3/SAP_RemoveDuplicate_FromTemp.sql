CREATE Procedure SAP_RemoveDuplicate_FromTemp
As
Begin

			DELETE FROM SAP_GDAPIdata_import
		 	WHERE ID NOT IN
		 	(
		 	    SELECT Min(ID) AS MaxRecordID
		 	    FROM SAP_GDAPIdata_import
		 	    GROUP BY Personnel_number_PERNR
		 	)

End