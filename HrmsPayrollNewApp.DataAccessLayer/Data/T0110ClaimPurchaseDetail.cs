using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110ClaimPurchaseDetail
{
    public int CpId { get; set; }

    public int? CpClaimAppId { get; set; }

    public int? CpEmpId { get; set; }

    public int? CpClaimId { get; set; }

    public string? CpItemName { get; set; }

    public string? CpSerialNo { get; set; }

    public string? CpVendorName { get; set; }

    public string? CpBillNo { get; set; }

    public DateTime? CpBillDate { get; set; }

    public double? CpBillAmount { get; set; }

    public double? CpRequestedAmount { get; set; }
}
