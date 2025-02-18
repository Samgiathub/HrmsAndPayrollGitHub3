using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110ClaimBookDetail
{
    public int CbMainId { get; set; }

    public int? CbAppId { get; set; }

    public int? CbClaimId { get; set; }

    public int? CbEmpId { get; set; }

    public string? CbBookName { get; set; }

    public string? CbSubject { get; set; }

    public double? CbActualPrice { get; set; }

    public double? CbDiscountedPrice { get; set; }

    public double? CbAmount { get; set; }
}
