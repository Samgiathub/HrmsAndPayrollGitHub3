using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110ClaimApprovalPurchaseDetail
{
    public int CpaId { get; set; }

    public int? CpaClaimAppId { get; set; }

    public int? CpaEmpId { get; set; }

    public int? CpaClaimId { get; set; }

    public string? CpaItemName { get; set; }

    public string? CpaSerialNo { get; set; }

    public string? CpaVendorName { get; set; }

    public string? CpaBillNo { get; set; }

    public DateTime? CpaBillDate { get; set; }

    public double? CpaBillAmount { get; set; }

    public double? CpaRequestedAmount { get; set; }
}
