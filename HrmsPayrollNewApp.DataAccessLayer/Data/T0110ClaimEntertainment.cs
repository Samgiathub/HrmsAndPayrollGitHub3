using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110ClaimEntertainment
{
    public int EcId { get; set; }

    public int? EcClaimAppId { get; set; }

    public int? EcClaimId { get; set; }

    public DateTime? EcDate { get; set; }

    public string? EcNoOfEntertained { get; set; }

    public double? EcAmount { get; set; }
}
