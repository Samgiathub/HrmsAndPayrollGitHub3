using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110ClaimApprovalBookDetail
{
    public int CbaMainId { get; set; }

    public int? CbaAppId { get; set; }

    public int? CbaClaimId { get; set; }

    public int? CbaEmpId { get; set; }

    public string? CbaBookName { get; set; }

    public string? CbaSubject { get; set; }

    public double? CbaActualPrice { get; set; }

    public double? CbaDiscountedPrice { get; set; }

    public double? CbaAmount { get; set; }
}
