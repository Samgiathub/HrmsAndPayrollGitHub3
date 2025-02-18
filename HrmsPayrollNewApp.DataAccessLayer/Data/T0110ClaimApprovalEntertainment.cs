using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110ClaimApprovalEntertainment
{
    public int EcaId { get; set; }

    public int? EcaClaimAppId { get; set; }

    public int? EcaClaimId { get; set; }

    public DateTime? EcaDate { get; set; }

    public string? EcaNoOfEntertained { get; set; }

    public double? EcaAmount { get; set; }
}
