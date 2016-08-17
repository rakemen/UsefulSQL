IF OBJECT_ID('tempdb..#TypeLookUpTable') IS NOT NULL DROP TABLE #TypeLookUpTable
CREATE TABLE #TypeLookUpTable ( OriginalCharID INT, NewSecurityTypeID INT )

IF OBJECT_ID('tempdb..#OldNewLookupTable') IS NOT NULL DROP TABLE #OldNewLookupTable
CREATE TABLE #OldNewLookupTable ( OldCharID INT, NewCharID INT, NewSecurityTypeID INT )

BEGIN -- Appreciation
	INSERT INTO #TypeLookUpTable (OriginalCharID, NewSecurityTypeID)
	SELECT sa.SecurityAppreciationID, stn.SecurityTypeID
	FROM SecurityAppreciation sa
	INNER JOIN SecurityType sto ON sto.SecurityTypeID = sa.SecurityTypeID
	INNER JOIN SecurityType stn ON stn.SecurityTypeName = sto.SecurityTypeName AND stn.CustomerID = @NewCustomerID
	WHERE sa.CustomerID = @TemplateCustomerID AND sa.SecurityID = 0

	-- INSERT into Appreciation
	MERGE SecurityAppreciation
	USING 
		(
		SELECT  st.NewSecurityTypeID AS SecurityTypeID, sa.FK_PricingFrequencyID, 
				sa.ValueAssignment, sa.AlwaysUpdate, sa.ValueCurrency, sa.FK_CharacteristicsFrequencyID, st.OriginalCharID
		FROM #TypeLookUpTable st
		INNER JOIN SecurityAppreciation sa ON sa.SecurityAppreciationID = st.OriginalCharID
		) old ON 1 = 0
	WHEN NOT MATCHED
	THEN 
		INSERT (AuditUser, AuditDate, SecurityID, SecurityTypeID, CustomerID, FK_PricingFrequencyID, ValueAssignment, AlwaysUpdate) 
		VALUES (@AuditUser, @AuditDate, 0, old.SecurityTypeID, @NewCustomerID, old.FK_PricingFrequencyID, old.ValueAssignment, old.AlwaysUpdate)
	OUTPUT old.OriginalCharID, Inserted.SecurityAppreciationID, Inserted.SecurityTypeID INTO #OldNewLookupTable;

	INSERT INTO SecurityCharacteristic ( AuditUser, AuditDate, SecurityCharacteristicType, ForeignID, SecurityID, SecurityTypeID, CustomerID )
	SELECT @AuditUser, @AuditDate, sc.SecurityCharacteristicType, oldnew.NewCharID, 0, oldnew.NewSecurityTypeID, @NewCustomerID
	FROM SecurityCharacteristic sc
	INNER JOIN #OldNewLookupTable oldnew ON oldnew.OldCharID = sc.ForeignID
	WHERE sc.CustomerID = @TemplateCustomerID AND sc.SecurityCharacteristicType = 'Appreciation' AND SecurityID = 0
END