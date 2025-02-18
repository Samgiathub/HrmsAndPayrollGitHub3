using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110ClaimApprovalInsuranceDetails28122021
{
    public int CiaId { get; set; }

    public int? CiaClaimAppId { get; set; }

    public int? CiaEmpId { get; set; }

    public int? CiaClaimId { get; set; }

    public string? CiaVehicleNo { get; set; }

    public DateTime? CiaBillDate { get; set; }

    public double? CiaPaidAmount { get; set; }
}
