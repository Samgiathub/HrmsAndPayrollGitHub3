using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110ClaimInsuranceDetail
{
    public int CiId { get; set; }

    public int? CiClaimAppId { get; set; }

    public int? CiEmpId { get; set; }

    public int? CiClaimId { get; set; }

    public string? CiVehicleNo { get; set; }

    public DateTime? CiBillDate { get; set; }

    public double? CiPaidAmount { get; set; }
}
